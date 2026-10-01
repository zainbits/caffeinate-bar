import Foundation
import IOKit.pwr_mgt

enum AwakeMode: String, CaseIterable, Identifiable {
    case off
    /// Same as `caffeinate -i`.
    case system
    /// Same as `caffeinate -id`.
    case systemAndDisplay

    var id: String { rawValue }

    var title: String {
        switch self {
        case .off: return "Off"
        case .system: return "Keep Mac Awake (-i)"
        case .systemAndDisplay: return "Keep Mac and Display Awake (-id)"
        }
    }

    var symbolName: String {
        switch self {
        case .off: return "cup.and.saucer"
        case .system: return "cup.and.saucer.fill"
        case .systemAndDisplay: return "cup.and.heat.waves.fill"
        }
    }

    /// The IOKit power assertions `caffeinate` creates for the matching flags.
    fileprivate var assertionTypes: [String] {
        switch self {
        case .off:
            return []
        case .system:
            return [kIOPMAssertionTypePreventUserIdleSystemSleep]
        case .systemAndDisplay:
            return [kIOPMAssertionTypePreventUserIdleSystemSleep,
                    kIOPMAssertionTypePreventUserIdleDisplaySleep]
        }
    }
}

/// Holds power assertions directly, the same way `caffeinate` does.
/// macOS releases them automatically if this process exits for any reason,
/// so a crash can never leave the Mac stuck awake.
@MainActor
final class AwakeController: ObservableObject {
    @Published private(set) var mode: AwakeMode = .off
    @Published private(set) var lastError: String?

    private var assertionIDs: [IOPMAssertionID] = []

    func setMode(_ newMode: AwakeMode) {
        guard newMode != mode else { return }
        releaseAll()
        lastError = nil

        for type in newMode.assertionTypes {
            var assertionID = IOPMAssertionID(0)
            let result = IOPMAssertionCreateWithName(
                type as CFString,
                IOPMAssertionLevel(kIOPMAssertionLevelOn),
                "CaffeinateBar: \(newMode.title)" as CFString,
                &assertionID
            )
            guard result == kIOReturnSuccess else {
                releaseAll()
                mode = .off
                lastError = "Could not hold power assertion (error \(result))"
                return
            }
            assertionIDs.append(assertionID)
        }

        mode = newMode
    }

    private func releaseAll() {
        for assertionID in assertionIDs {
            IOPMAssertionRelease(assertionID)
        }
        assertionIDs.removeAll()
    }
}
