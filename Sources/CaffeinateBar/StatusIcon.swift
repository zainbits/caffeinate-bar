import AppKit

/// Menu bar icons drawn on one fixed canvas so switching modes never changes
/// the item's size or the cup's position. Only the indicators change:
/// outline cup = off, filled cup = -i, filled cup + display badge = -id.
enum StatusIcon {
    private static let canvas = NSSize(width: 22, height: 18)
    private static let cupPointSize: CGFloat = 14
    private static let badgeSize = NSSize(width: 8, height: 7)
    private static let badgeGap: CGFloat = 1.25

    private static let images: [AwakeMode: NSImage] = Dictionary(
        uniqueKeysWithValues: AwakeMode.allCases.map { ($0, render($0)) }
    )

    static func image(for mode: AwakeMode) -> NSImage {
        images[mode] ?? render(mode)
    }

    private static func symbol(_ name: String, pointSize: CGFloat, weight: NSFont.Weight) -> NSImage? {
        NSImage(systemSymbolName: name, accessibilityDescription: nil)?
            .withSymbolConfiguration(.init(pointSize: pointSize, weight: weight))
    }

    private static func render(_ mode: AwakeMode) -> NSImage {
        let image = NSImage(size: canvas, flipped: false) { rect in
            let cupName = mode == .off ? "cup.and.saucer" : "cup.and.saucer.fill"
            guard let cup = symbol(cupName, pointSize: cupPointSize, weight: .medium) else { return false }

            let cupOrigin = NSPoint(
                x: ((rect.width - cup.size.width) / 2).rounded(),
                y: ((rect.height - cup.size.height) / 2).rounded()
            )
            cup.draw(at: cupOrigin, from: .zero, operation: .sourceOver, fraction: 1)

            guard mode == .systemAndDisplay else { return true }

            let badgeRect = NSRect(
                x: rect.maxX - badgeSize.width,
                y: rect.minY,
                width: badgeSize.width,
                height: badgeSize.height
            )

            // Punch a small gap around the badge so it reads cleanly over the cup.
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current?.compositingOperation = .destinationOut
            NSColor.black.setFill()
            let gap = badgeRect.insetBy(dx: -badgeGap, dy: -badgeGap)
            NSBezierPath(roundedRect: gap, xRadius: 2.5, yRadius: 2.5).fill()
            NSGraphicsContext.restoreGraphicsState()

            drawDisplay(in: badgeRect)
            return true
        }
        image.isTemplate = true
        return image
    }

    /// A tiny solid monitor: screen on top, short neck, and a base.
    private static func drawDisplay(in rect: NSRect) {
        NSColor.black.setFill()
        let screen = NSRect(x: rect.minX, y: rect.minY + 2.25, width: rect.width, height: rect.height - 2.25)
        NSBezierPath(roundedRect: screen, xRadius: 1.25, yRadius: 1.25).fill()
        NSRect(x: rect.midX - 0.75, y: rect.minY + 1, width: 1.5, height: 1.5).fill()
        NSBezierPath(roundedRect: NSRect(x: rect.midX - 2.25, y: rect.minY, width: 4.5, height: 1.1),
                     xRadius: 0.5, yRadius: 0.5).fill()
    }
}
