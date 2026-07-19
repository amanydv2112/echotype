import AVFoundation
import Foundation

public struct RecordingResult: Equatable, Sendable {
    public var fileURL: URL
    public var duration: TimeInterval
    public var byteCount: Int64

    public init(fileURL: URL, duration: TimeInterval, byteCount: Int64) {
        self.fileURL = fileURL
        self.duration = duration
        self.byteCount = byteCount
    }
}

public final class AudioRecorder: @unchecked Sendable {
    private let engine = AVAudioEngine()
    private var audioSink: AudioFileSink?
    private var recordingURL: URL?
    private var startedAt: Date?

    public private(set) var isRecording = false

    public init() {}

    public func start() throws -> URL {
        guard !isRecording else {
            return recordingURL ?? temporaryRecordingURL()
        }

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        let url = temporaryRecordingURL()
        let sink = try AudioFileSink(url: url, settings: format.settings)
        audioSink = sink
        recordingURL = url
        startedAt = Date()

        input.installTap(onBus: 0, bufferSize: 4096, format: format) { buffer, _ in
            sink.write(buffer)
        }

        engine.prepare()
        try engine.start()
        isRecording = true
        return url
    }

    public func stop(minimumDuration: TimeInterval = 0.3) throws -> RecordingResult {
        guard isRecording, let recordingURL else {
            throw FlowError.recordingTooShort
        }

        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        audioSink?.close()
        audioSink = nil
        isRecording = false

        let duration = Date().timeIntervalSince(startedAt ?? Date())
        startedAt = nil
        self.recordingURL = nil

        guard duration >= minimumDuration else {
            try? FileManager.default.removeItem(at: recordingURL)
            throw FlowError.recordingTooShort
        }

        let values = try recordingURL.resourceValues(forKeys: [.fileSizeKey])
        return RecordingResult(
            fileURL: recordingURL,
            duration: duration,
            byteCount: Int64(values.fileSize ?? 0)
        )
    }

    private func temporaryRecordingURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("echotype-\(UUID().uuidString)")
            .appendingPathExtension("wav")
    }
}

private final class AudioFileSink: @unchecked Sendable {
    private let lock = NSLock()
    private var audioFile: AVAudioFile?

    init(url: URL, settings: [String: Any]) throws {
        audioFile = try AVAudioFile(forWriting: url, settings: settings)
    }

    func write(_ buffer: AVAudioPCMBuffer) {
        lock.lock()
        defer { lock.unlock() }
        do {
            try audioFile?.write(from: buffer)
        } catch {
            NSLog("EchoType audio write failed: \(error.localizedDescription)")
        }
    }

    func close() {
        lock.lock()
        audioFile = nil
        lock.unlock()
    }
}
