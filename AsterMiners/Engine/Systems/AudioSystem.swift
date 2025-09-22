import Foundation
import AVFoundation

final class AudioSystem {
    private let engine = AVAudioEngine()
    private let musicPlayer = AVAudioPlayerNode()
    private var sfxPlayers: [AVAudioPlayerNode] = []
    private let musicBuffer: AVAudioPCMBuffer

    init() {
        let sampleRate: Double = 44100
        let frameCount = AVAudioFrameCount(sampleRate * 4)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        musicBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        musicBuffer.frameLength = frameCount
        if let pointer = musicBuffer.floatChannelData?[0] {
            for frame in 0..<Int(frameCount) {
                let t = Double(frame) / sampleRate
                pointer[frame] = Float(sin(t * 2 * Double.pi * 120) * 0.2 + sin(t * 2 * Double.pi * 240) * 0.1)
            }
        }
        engine.attach(musicPlayer)
        engine.connect(musicPlayer, to: engine.mainMixerNode, format: format)
    }

    func start() {
        do {
            try engine.start()
            musicPlayer.scheduleBuffer(musicBuffer, at: nil, options: [.loops], completionHandler: nil)
            musicPlayer.play()
        } catch {
            print("Audio start failed: \(error)")
        }
    }

    func stop() {
        musicPlayer.stop()
        engine.stop()
    }

    func update(world: World) {
        // Could respond to events for sfx.
    }
}
