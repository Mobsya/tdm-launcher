/*
    This file is part of tdm-launcher.
    Copyright 2022 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE,
    Miniature Mobile Robots group, Switzerland
    Author: Yves Piguet
*/

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private var process: Process? = nil

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        killCurrentTDM()
        launchTDM()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setIcon(process != nil)
        let menu = NSMenu()
        let menuItem = NSMenuItem(title: "Quit Thymio Device Manager",
                                  action: #selector(NSApplication.terminate(_:)),
                                  keyEquivalent: "")
        menu.addItem(menuItem)
        statusItem.menu = menu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if let process = self.process {
            process.interrupt()
            self.process = nil
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func lightBackground() -> Bool {
        if let button = statusItem.button {
            return !button.effectiveAppearance.name.rawValue.contains("Dark")
        } else {
            return false
        }
    }

    func setIcon(_ running: Bool) {
        if let button = statusItem.button {
            button.image = NSImage(
                size: NSSize.init(width: 20, height: 20),
                flipped: false,
                drawingHandler: { (dstRect: NSRect) -> Bool in
                    let path = NSBezierPath()
                    path.move(to: NSPoint(x: 3, y: 3))
                    path.line(to: NSPoint(x: 17, y: 3))
                    path.line(to: NSPoint(x: 17, y: 13))
                    path.curve(to: NSPoint(x: 3, y: 13),
                               controlPoint1: NSPoint(x: 13, y: 17),
                               controlPoint2: NSPoint(x: 7, y: 17))
                    if self.lightBackground() {
                        NSColor.black.setFill()
                    } else {
                        NSColor.white.setFill()
                    }
                    path.fill()
                    if !running {
                        // draw "transparent" cross
                        let pathCross = NSBezierPath()
                        pathCross.move(to: NSPoint(x: 8, y: 7))
                        pathCross.line(to: NSPoint(x: 12, y: 11))
                        pathCross.move(to: NSPoint(x: 8, y: 11))
                        pathCross.line(to: NSPoint(x: 12, y: 7))
                        if let context = NSGraphicsContext.current?.cgContext {
                            NSColor.white.setStroke()
                            context.setBlendMode(.destinationOut)
                        } else {
                            // cannot change blend mode; use solid gray
                            NSColor.systemGray.setStroke()
                        }
                        pathCross.lineWidth = 2
                        pathCross.lineCapStyle = .round
                        pathCross.stroke()
                    }
                    return true
                })
        }

    }

    @discardableResult
    func killCurrentTDM() -> Int32 {
        let shellProcess = Process()
        shellProcess.executableURL = URL(fileURLWithPath: "/bin/bash")
        /* lockfile path: see the definitions of lock_file_path
           in aseba/aseba/thymio-device-manager/main.cpp
           and of method boost::filesystem::temp_directory_path()
           in boost source code filesystem/src/operations.cpp
        */
        shellProcess.arguments = [
            "-c",
            """
            killall thymio-device-manager;
            d=$TMPDIR || $TMP || $TEMP || $TEMPDIR;
            p="$d/mobsya-tdm-0accdcbf-eeb2";
            if [ -f "$p" ]; then rm -f "$p"; fi
            """
        ]
        do {
            try shellProcess.run()
            shellProcess.waitUntilExit()
            return shellProcess.terminationStatus
        } catch {
            return 2
        }
    }

    func launchTDM() {
        self.process = Process()
        if let process = self.process {
            process.executableURL = URL(fileURLWithPath: "thymio-device-manager")
            process.terminationHandler = { (process) in
                self.process = nil
                self.setIcon(false)
            }
            do {
                try process.run()
            } catch {
                self.process = nil
            }
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
