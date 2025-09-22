import Foundation
import Metal
import simd

final class ParticleSystem: System {
    private let device: MTLDevice
    private var computePipeline: MTLComputePipelineState?
    private var particleBuffer: MTLBuffer?
    private var particleCount: Int = 1024

    init(device: MTLDevice) {
        self.device = device
        setup()
    }

    private func setup() {
        guard let library = try? device.makeDefaultLibrary(bundle: .main), let function = library.makeFunction(name: "updateParticles") else { return }
        computePipeline = try? device.makeComputePipelineState(function: function)
        particleBuffer = device.makeBuffer(length: MemoryLayout<SIMD4<Float>>.stride * particleCount, options: [.storageModeShared])
    }

    func setQuality(level: Int) {
        let counts = [256, 512, 1024]
        let index = max(0, min(level, counts.count - 1))
        particleCount = counts[index]
        particleBuffer = device.makeBuffer(length: MemoryLayout<SIMD4<Float>>.stride * particleCount, options: [.storageModeShared])
    }

    func update(world: inout World, input: InputStateActor) {
        // CPU fallback updates
        guard let pointer = particleBuffer?.contents().bindMemory(to: SIMD4<Float>.self, capacity: particleCount) else { return }
        for index in 0..<particleCount {
            let progress = Float(index) / Float(particleCount)
            pointer[index] = SIMD4<Float>(progress, 1 - progress, 0.5, 1)
        }
    }

    func encode(commandBuffer: MTLCommandBuffer) {
        guard let computePipeline, let encoder = commandBuffer.makeComputeCommandEncoder(), let buffer = particleBuffer else { return }
        encoder.setComputePipelineState(computePipeline)
        encoder.setBuffer(buffer, offset: 0, index: 0)
        let grid = MTLSize(width: particleCount, height: 1, depth: 1)
        let thread = MTLSize(width: 32, height: 1, depth: 1)
        encoder.dispatchThreads(grid, threadsPerThreadgroup: thread)
        encoder.endEncoding()
    }
}
