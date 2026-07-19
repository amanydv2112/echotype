import Foundation

public struct AppSettings: Equatable, Codable, Sendable {
    public var sttBaseURL: String
    public var sttModel: String
    public var sttLanguage: String
    public var sttPrompt: String
    public var sttResponseFormat: String
    public var cleanupEnabled: Bool
    public var cleanupModel: String
    public var saveHistory: Bool
    public var restoreClipboard: Bool
    public var shortcutKeyCode: Int
    public var shortcutRequiresOption: Bool

    public init(
        sttBaseURL: String = "https://api.openai.com/v1",
        sttModel: String = "gpt-4o-mini-transcribe",
        sttLanguage: String = "",
        sttPrompt: String = "",
        sttResponseFormat: String = "text",
        cleanupEnabled: Bool = true,
        cleanupModel: String = "gpt-4.1-mini",
        saveHistory: Bool = true,
        restoreClipboard: Bool = true,
        shortcutKeyCode: Int = 49,
        shortcutRequiresOption: Bool = true
    ) {
        self.sttBaseURL = sttBaseURL
        self.sttModel = sttModel
        self.sttLanguage = sttLanguage
        self.sttPrompt = sttPrompt
        self.sttResponseFormat = sttResponseFormat
        self.cleanupEnabled = cleanupEnabled
        self.cleanupModel = cleanupModel
        self.saveHistory = saveHistory
        self.restoreClipboard = restoreClipboard
        self.shortcutKeyCode = shortcutKeyCode
        self.shortcutRequiresOption = shortcutRequiresOption
    }

    public func sttConfig(apiKey: String) -> STTProviderConfig {
        STTProviderConfig(
            baseURL: sttBaseURL,
            apiKey: apiKey,
            model: sttModel,
            language: sttLanguage.isEmpty ? nil : sttLanguage,
            prompt: sttPrompt.isEmpty ? nil : sttPrompt,
            responseFormat: sttResponseFormat
        )
    }

    public func polisherConfig(apiKey: String) -> PolisherConfig {
        PolisherConfig(
            enabled: cleanupEnabled,
            baseURL: sttBaseURL,
            apiKey: apiKey,
            model: cleanupModel
        )
    }
}

