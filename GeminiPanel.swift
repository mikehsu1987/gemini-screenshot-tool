import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let button = NSButton(title: "截图询问", target: self, action: #selector(captureScreenshot))
        button.bezelStyle = .rounded
        button.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false

        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 56))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        contentView.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 180),
            button.heightAnchor.constraint(equalToConstant: 32)
        ])

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 56),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentView = contentView
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces]
        window.isMovableByWindowBackground = true
        window.center()
        window.makeKeyAndOrderFront(nil)
    }

    @objc private func captureScreenshot() {
        window.orderOut(nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
            process.arguments = ["-i", "-c"]
            try? process.run()
            process.waitUntilExit()

            self.window.makeKeyAndOrderFront(nil)

            if process.terminationStatus == 0 {
                let notification = NSUserNotification()
                notification.title = "截图已复制"
                notification.informativeText = "已在剪贴板，按 ⌘V 粘贴。用完可复制一段普通文字覆盖。"
                NSUserNotificationCenter.default.deliver(notification)
            }
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
