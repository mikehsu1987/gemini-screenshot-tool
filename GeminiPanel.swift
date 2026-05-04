import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var userApp: NSRunningApplication?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 记录启动时用户正在用的 App
        userApp = NSWorkspace.shared.frontmostApplication

        // 持续追踪用户最后使用的 App
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(activeAppChanged(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )

        let button = NSButton(title: "截图询问", target: self, action: #selector(captureScreenshot))
        button.bezelStyle = .rounded
        button.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false

        let closeButton = NSButton(title: "×", target: self, action: #selector(closePanel))
        closeButton.bezelStyle = .inline
        closeButton.font = NSFont.systemFont(ofSize: 15, weight: .regular)
        closeButton.isBordered = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 330, height: 56))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        contentView.addSubview(button)
        contentView.addSubview(closeButton)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 180),
            button.heightAnchor.constraint(equalToConstant: 32),

            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 330, height: 56),
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

    @objc private func activeAppChanged(_ notification: Notification) {
        if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
           app.bundleIdentifier != Bundle.main.bundleIdentifier,
           app.activationPolicy == .regular {
            userApp = app
        }
    }

    @objc private func captureScreenshot() {
        window.orderOut(nil)

        // 切回用户正在用的 App
        if let app = userApp, !app.isTerminated {
            app.activate(options: [])
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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

    @objc private func closePanel() {
        NSApplication.shared.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
