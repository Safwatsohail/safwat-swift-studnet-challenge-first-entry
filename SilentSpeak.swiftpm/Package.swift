// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "SilentSpeak",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .iOSApplication(
            name: "SilentSpeak",
            targets: ["AppModule"],
            bundleIdentifier: "com.silentspeak.app",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .hands),
            accentColor: .presetColor(.brown),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .camera(purposeString: "SilentSpeak uses the camera to recognize ASL gestures and translate them into speech."),
                .microphone(purposeString: "SilentSpeak uses the microphone to convert speech into ASL signs for deaf users.")
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)