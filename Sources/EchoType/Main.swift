import AppKit
import EchoTypeCore
import SwiftUI

@main
@MainActor
final class MainApp: NSObject, NSApplicationDelegate {
    private var appState: AppState!
    private var dictationController: DictationController!
    private var statusBarController: StatusBarController!
    private var settingsWindowController: SettingsWindowController?
    private var shortcutMonitor: GlobalShortcutMonitor!

    static func main() {
        let app = NSApplication.shared
        if CommandLine.arguments.contains("--notify-smoke-test") {
            app.setActivationPolicy(.accessory)
            UserNotifier.notify(title: "EchoType", body: "Notifier smoke test")
            return
        }

        let delegate = MainApp()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        withExtendedLifetime(delegate) {
            app.run()
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        appState = AppState()
        dictationController = DictationController(appState: appState)

        statusBarController = StatusBarController(
            appState: appState,
            dictationController: dictationController,
            openSettings: { [weak self] in self?.showSettings() }
        )

        shortcutMonitor = GlobalShortcutMonitor(
            keyCode: appState.settings.shortcutKeyCode,
            requiresOption: appState.settings.shortcutRequiresOption
        )
        shortcutMonitor.onShortcutDown = { [weak self] in
            self?.dictationController.beginDictation()
        }
        shortcutMonitor.onShortcutUp = { [weak self] in
            self?.dictationController.endDictation()
        }

        if PermissionsManager.accessibilityGranted(prompt: false) {
            shortcutMonitor.start()
        }

        statusBarController.refresh()
    }

    private func showSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController(appState: appState) { [weak self] in
                guard let self else { return }
                self.shortcutMonitor.keyCode = self.appState.settings.shortcutKeyCode
                self.shortcutMonitor.requiresOption = self.appState.settings.shortcutRequiresOption
                if PermissionsManager.accessibilityGranted(prompt: false) {
                    self.shortcutMonitor.start()
                }
                self.statusBarController.refresh()
            }
        }
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
