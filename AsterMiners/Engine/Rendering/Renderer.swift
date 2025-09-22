import Foundation
import MetalKit
import simd

final class Renderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let library: MTLLibrary
    private var pipelineState: MTLRenderPipelineState!
    private var depthState: MTLDepthStencilState!
    private var particleSystem: ParticleSystem?
    private(set) var world: World?
    private var meshLibrary: MeshLibrary
    private let postProcessor: PostProcessor
    private var hudMetrics: HUDMetrics = .init()
    var debugHudMessage: String = ""
    var metrics: HUDMetrics { hudMetrics }

    init(device: MTLDevice) {
        self.device = device
        guard let queue = device.makeCommandQueue() else {
            fatalError("Unable to create command queue")
        }
        commandQueue = queue
        library = try! device.makeDefaultLibrary(bundle: .main)
        meshLibrary = MeshLibrary(device: device)
        postProcessor = PostProcessor(device: device)
        super.init()
        buildPipeline()
    }

    func bind(world: World, particleSystem: ParticleSystem) {
        self.world = world
        self.particleSystem = particleSystem
    }

    func enqueueFrame(world: World, deltaTime: TimeInterval) {
        self.world = world
        hudMetrics.frameTime = deltaTime
    }

    func setDebugMessage(_ message: String) {
        debugHudMessage = message
    }

    func setBloom(enabled: Bool) {
        postProcessor.bloomEnabled = enabled
    }

    private func buildPipeline() {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.vertexDescriptor = meshLibrary.vertexDescriptor
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)

        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        depthState = device.makeDepthStencilState(descriptor: depthDescriptor)
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.02, green: 0.02, blue: 0.05, alpha: 1)
        descriptor.depthAttachment.loadAction = .clear
        descriptor.depthAttachment.clearDepth = 1.0

        if let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) {
            encoder.setRenderPipelineState(pipelineState)
            encoder.setDepthStencilState(depthState)
            drawWorld(with: encoder)
            encoder.endEncoding()
        }

        if let particleSystem {
            particleSystem.encode(commandBuffer: commandBuffer)
        }

        postProcessor.encode(commandBuffer: commandBuffer, texture: drawable.texture)
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    private func drawWorld(with encoder: MTLRenderCommandEncoder) {
        guard let world else { return }
        for (entity, transform) in world.transforms {
            guard let render = world.renderables[entity], let mesh = meshLibrary.mesh(for: render.mesh) else { continue }
            var modelMatrix = float4x4(translation: transform.position)
            modelMatrix = modelMatrix * float4x4(scaling: transform.scale)
            var color = render.color
            encoder.setVertexBytes(&modelMatrix, length: MemoryLayout<float4x4>.stride, index: 1)
            encoder.setFragmentBytes(&color, length: MemoryLayout<SIMD4<Float>>.stride, index: 0)
            mesh.draw(with: encoder)
        }
    }
}

struct HUDMetrics {
    var frameTime: TimeInterval = 0
}
