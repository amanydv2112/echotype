import AppKit
import SwiftUI

@MainActor
final class RecordingHUD {
    private var panel: NSPanel?
    private var hostingView: NSHostingView<HUDView>?

    func show() {
        setState(.recording)
    }

    func showProcessing() {
        setState(.processing)
    }

    func hide() {
        panel?.orderOut(nil)
    }

    private func setState(_ state: HUDView.State) {
        if panel == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 180, height: 54),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            panel.level = .floating
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.hasShadow = true
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            self.panel = panel
        }

        hostingView = NSHostingView(rootView: HUDView(state: state))
        panel?.contentView = hostingView
        positionPanel()
        panel?.orderFrontRegardless()
    }

    private func positionPanel() {
        guard let panel, let screen = NSScreen.main else { return }
        let frame = screen.visibleFrame
        panel.setFrameOrigin(
            NSPoint(
                x: frame.midX - panel.frame.width / 2,
                y: frame.maxY - panel.frame.height - 24
            )
        )
    }
}

private struct HUDView: View {
    enum State {
        case recording
        case processing
    }

    let state: State

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(state == .recording ? Color.red : Color.orange)
                .frame(width: 10, height: 10)
            Text(state == .recording ? "Recording" : "Processing")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .frame(width: 180, height: 54)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

