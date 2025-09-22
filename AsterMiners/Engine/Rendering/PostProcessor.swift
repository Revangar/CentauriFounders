import Foundation
import Metal

final class PostProcessor {
    private let device: MTLDevice
    private var bloomPipeline: MTLComputePipelineState?
    var bloomEnabled: Bool = true

    init(device: MTLDevice) {
        self.device = device
        if let library = try? device.makeDefaultLibrary(bundle: .main), let kernel = library.makeFunction(name: "bloomKernel") {
            bloomPipeline = try? device.makeComputePipelineState(function: kernel)
        }
    }

    func encode(commandBuffer: MTLCommandBuffer, texture: MTLTexture) {
        guard bloomEnabled, let bloomPipeline, let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
        encoder.setComputePipelineState(bloomPipeline)
        encoder.setTexture(texture, index: 0)
        let threadGroup = MTLSize(width: 8, height: 8, depth: 1)
        let width = (texture.width + 7) / 8
        let height = (texture.height + 7) / 8
        let grid = MTLSize(width: width, height: height, depth: 1)
        encoder.dispatchThreads(grid, threadsPerThreadgroup: threadGroup)
        encoder.endEncoding()
    }
}
