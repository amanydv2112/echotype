import AppKit
import Combine
import EchoTypeCore
import Foundation

@MainActor
final class StatusBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let appState: AppState
    private let dictationController: DictationController
    private let openSettings: () -> Void
    private var cancellables: Set<AnyCancellable> = []

    init(appState: AppState, dictationController: DictationController, openSettings: @escaping () -> Void) {
        self.appState = appState
        self.dictationController = dictationController
        self.openSettings = openSettings

        appState.$lastMessage.sink { [weak self] _ in self?.refresh() }.store(in: &cancellables)
        appState.$isPaused.sink { [weak self] _ in self?.refresh() }.store(in: &cancellables)
        dictationController.$status.sink { [weak self] _ in self?.refresh() }.store(in: &cancellables)
    }

    func refresh() {
        let currentTitle = title
        let currentMenu = buildMenu()
        DispatchQueue.main.async { [weak self] in
            self?.statusItem.button?.title = currentTitle
            self?.statusItem.menu = currentMenu
        }
    }

    private var title: String {
        switch dictationController.status {
        case .idle:
            return appState.isPaused ? "Flow Paused" : "Flow"
        case .recording:
            return "Recording"
        case .processing:
            return "Processing"
        case .failed:
            return "Flow Error"
        }
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(withTitle: appState.lastMessage, action: nil, keyEquivalent: "")
        menu.addItem(.separator())

        let pauseTitle = appState.isPaused ? "Resume Dictation" : "Pause Dictation"
        let pauseItem = NSMenuItem(title: pauseTitle, action: #selector(togglePaused), keyEquivalent: "")
        pauseItem.target = self
        menu.addItem(pauseItem)

        let permissionItem = NSMenuItem(title: "Check Permissions", action: #selector(checkPermissions), keyEquivalent: "")
        permissionItem.target = self
        menu.addItem(permissionItem)

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettingsAction), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())
        for record in recentRecords().prefix(5) {
            let text = (record.polishedText ?? record.rawTranscript ?? record.errorMessage ?? "Transcript")
                .replacingOccurrences(of: "\n", with: " ")
            let clipped = text.count > 60 ? String(text.prefix(57)) + "..." : text
            let item = NSMenuItem(title: clipped, action: #selector(copyHistoryItem(_:)), keyEquivalent: "")
            item.representedObject = record.polishedText ?? record.rawTranscript
            item.target = self
            menu.addItem(item)
        }

        if !recentRecords().isEmpty {
            let clearItem = NSMenuItem(title: "Clear History", action: #selector(clearHistory), keyEquivalent: "")
            clearItem.target = self
            menu.addItem(clearItem)
        }

        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "Quit EchoType", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        return menu
    }

    private func recentRecords() -> [HistoryRecord] {
        (try? appState.historyStore?.recent(limit: 5)) ?? []
    }

    @objc private func togglePaused() {
        appState.isPaused.toggle()
    }

    @objc private func checkPermissions() {
        _ = PermissionsManager.accessibilityGranted(prompt: true)
        Task { _ = await PermissionsManager.requestMicrophone() }
    }

    @objc private func openSettingsAction() {
        openSettings()
    }

    @objc private func copyHistoryItem(_ sender: NSMenuItem) {
        guard let value = sender.representedObject as? String else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
    }

    @objc private func clearHistory() {
        try? appState.historyStore?.deleteAll()
        refresh()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
