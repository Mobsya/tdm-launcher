# TDM Launcher

Minimum user interface to control the Thymio Device Manager. Adds a menu with a Quit or Exit entry as a status item on macOS or a system notification item (tray item) on Windows. The TDM is launched as a subprocess.

The Thymio Device Manager doesn't require any modification.

## macOS

The application is implemented in Swift. As a command-line program, it can be compiled with the `swiftc` compiler. It expects a command `tdm` in the same directory. This can be bundled as a standard self-contained Mac application in a `.app` directory.

## Windows

The application is implemented in C# with resources (icons etc.) created in Visual Studio. The compiled program is a single `.exe` file which expects `thymio-device-manager.exe` in the same directory.
