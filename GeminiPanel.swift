import AppKit

private let panelSize = NSSize(width: 168, height: 42)
private let cornerRadius: CGFloat = 21

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var userApp: NSRunningApplication?

    func applicationDidFinishLaunching(_ notification: Notification) {
        userApp = NSWorkspace.shared.frontmostApplication

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(activeAppChanged(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )

        let button = NSButton(title: "截图", target: self, action: #selector(captureScreenshot))
        button.bezelStyle = .texturedRounded
        button.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        button.isBordered = false
        button.contentTintColor = NSColor.labelColor
        button.translatesAutoresizingMaskIntoConstraints = false

        let closeButton = NSButton(title: "×", target: self, action: #selector(closePanel))
        closeButton.bezelStyle = .inline
        closeButton.font = NSFont.systemFont(ofSize: 14, weight: .regular)
        closeButton.isBordered = false
        closeButton.contentTintColor = NSColor.secondaryLabelColor
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        let contentView = NSView(frame: NSRect(origin: .zero, size: panelSize))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.92).cgColor
        contentView.layer?.cornerRadius = cornerRadius
        contentView.layer?.borderWidth = 0.5
        contentView.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.45).cgColor
        contentView.layer?.shadowColor = NSColor.black.cgColor
        contentView.layer?.shadowOpacity = 0.16
        contentView.layer?.shadowRadius = 14
        contentView.layer?.shadowOffset = NSSize(width: 0, height: -4)
        contentView.addSubview(button)
        contentView.addSubview(closeButton)

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 110),
            button.heightAnchor.constraint(equalToConstant: 30),

            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            closeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 22),
            closeButton.heightAnchor.constraint(equalToConstant: 22)
        ])

        window = NSWindow(
            contentRect: NSRect(origin: .zero, size: panelSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentView = contentView
        window.isReleasedWhenClosed = false
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
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
                notification.informativeText = "按 ⌘V 粘贴。"
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
