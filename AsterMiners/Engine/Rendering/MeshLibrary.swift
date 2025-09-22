import Foundation
import MetalKit
import simd

struct Mesh {
    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let indexCount: Int

    func draw(with encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.drawIndexedPrimitives(type: .triangle, indexCount: indexCount, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
    }
}

final class MeshLibrary {
    private let device: MTLDevice
    private(set) var vertexDescriptor: MTLVertexDescriptor
    private var meshes: [MeshIdentifier: Mesh] = [:]

    init(device: MTLDevice) {
        self.device = device
        self.vertexDescriptor = Self.makeVertexDescriptor()
        buildMeshes()
    }

    private func buildMeshes() {
        meshes[.player] = makeQuad(size: 1.2)
        meshes[.swarmling] = makeQuad(size: 0.9)
        meshes[.burrower] = makeQuad(size: 1.1)
        meshes[.spitter] = makeQuad(size: 1.0)
        meshes[.shielder] = makeQuad(size: 1.3)
        meshes[.boss] = makeQuad(size: 2.5)
        meshes[.crystal] = makeHexagon(radius: 1.0)
        meshes[.projectile] = makeQuad(size: 0.4)
        meshes[.drone] = makeQuad(size: 0.6)
        meshes[.prop] = makeQuad(size: 1.5)
    }

    func mesh(for identifier: MeshIdentifier) -> Mesh? {
        meshes[identifier]
    }

    private func makeQuad(size: Float) -> Mesh {
        let half = size / 2
        let vertices: [Float] = [
            -half, 0, -half, 0, 0,
            half, 0, -half, 1, 0,
            half, 0, half, 1, 1,
            -half, 0, half, 0, 1
        ]
        let indices: [UInt16] = [0, 1, 2, 0, 2, 3]
        let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.size, options: [])!
        let indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])!
        return Mesh(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, indexCount: indices.count)
    }

    private func makeHexagon(radius: Float) -> Mesh {
        var vertices: [Float] = []
        var indices: [UInt16] = []
        for i in 0..<6 {
            let angle = Float(i) / 6.0 * Float.pi * 2
            vertices += [cos(angle) * radius, 0, sin(angle) * radius, 0.5, 0.5]
        }
        vertices += [0, 0, 0, 0.5, 0.5]
        let centerIndex: UInt16 = 6
        for i in 0..<6 {
            let next = UInt16((i + 1) % 6)
            indices += [centerIndex, UInt16(i), next]
        }
        let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.size, options: [])!
        let indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])!
        return Mesh(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, indexCount: indices.count)
    }

    private static func makeVertexDescriptor() -> MTLVertexDescriptor {
        let descriptor = MTLVertexDescriptor()
        descriptor.attributes[0].format = .float3
        descriptor.attributes[0].offset = 0
        descriptor.attributes[0].bufferIndex = 0
        descriptor.attributes[1].format = .float2
        descriptor.attributes[1].offset = MemoryLayout<Float>.size * 3
        descriptor.attributes[1].bufferIndex = 0
        descriptor.layouts[0].stride = MemoryLayout<Float>.size * 5
        return descriptor
    }
}

extension float4x4 {
    init(translation: SIMD3<Float>) {
        self.init(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(translation.x, translation.y, translation.z, 1)
        )
    }

    init(scaling: SIMD3<Float>) {
        self.init(
            SIMD4<Float>(scaling.x, 0, 0, 0),
            SIMD4<Float>(0, scaling.y, 0, 0),
            SIMD4<Float>(0, 0, scaling.z, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
    }
}
