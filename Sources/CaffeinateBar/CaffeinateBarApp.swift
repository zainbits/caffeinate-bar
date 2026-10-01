import SwiftUI

@main
struct CaffeinateBarApp: App {
    @StateObject private var controller = AwakeController()

    var body: some Scene {
        MenuBarExtra {
            MenuContent(controller: controller)
        } label: {
            Image(nsImage: StatusIcon.image(for: controller.mode))
                .accessibilityLabel("CaffeinateBar: \(controller.mode.title)")
        }
        .menuBarExtraStyle(.menu)
    }
}

private struct MenuContent: View {
    @ObservedObject var controller: AwakeController

    var body: some View {
        Picker("Mode", selection: Binding(
            get: { controller.mode },
            set: { controller.setMode($0) }
        )) {
            ForEach(AwakeMode.allCases) { mode in
                Text(mode.title).tag(mode)
            }
        }
        .pickerStyle(.inline)
        .labelsHidden()

        if let error = controller.lastError {
            Divider()
            Text(error)
        }

        Divider()

        Button("Quit CaffeinateBar") {
            controller.setMode(.off)
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
