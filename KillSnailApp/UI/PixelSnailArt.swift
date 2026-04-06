import AppKit

enum PixelSnailFacing {
    case left
    case right
}

final class PixelSnailArt {
    static let shared = PixelSnailArt()

    private let manifest: PixelSnailManifest
    private let palette: [String: NSColor]

    private init(bundle: Bundle = .main) {
        guard let url = bundle.url(forResource: "PixelSnailArt", withExtension: "json") else {
            fatalError("Missing PixelSnailArt.json in app bundle")
        }

        do {
            let data = try Data(contentsOf: url)
            manifest = try JSONDecoder().decode(PixelSnailManifest.self, from: data)
            var resolvedPalette: [String: NSColor] = [:]
            for (name, hex) in manifest.palette {
                guard let color = NSColor(pixelHex: hex) else {
                    throw PixelSnailArtError.invalidColor(hex)
                }
                resolvedPalette[name] = color
            }
            palette = resolvedPalette
        } catch {
            fatalError("Failed to load pixel snail art: \(error)")
        }
    }

    func drawSprite(in rect: CGRect, facing: PixelSnailFacing, alpha: CGFloat, context: CGContext) {
        draw(rects: manifest.sprite, in: rect, facing: facing, alpha: alpha, context: context)
    }

    func makeStatusImage(pointSize: CGFloat, isPaused: Bool) -> NSImage {
        makeImage(pointSize: pointSize, alpha: isPaused ? 0.6 : 1.0)
    }

    private func makeImage(pointSize: CGFloat, alpha: CGFloat) -> NSImage {
        let scale = NSScreen.main?.backingScaleFactor ?? 2
        let pixelsWide = max(1, Int((pointSize * scale).rounded(.up)))
        let pixelsHigh = max(1, Int((pointSize * scale).rounded(.up)))

        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: pixelsWide,
            pixelsHigh: pixelsHigh,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            return NSImage(size: NSSize(width: pointSize, height: pointSize))
        }

        bitmap.size = NSSize(width: pointSize, height: pointSize)

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)

        if let context = NSGraphicsContext.current?.cgContext {
            context.clear(CGRect(origin: .zero, size: CGSize(width: pointSize, height: pointSize)))
            drawSprite(in: CGRect(origin: .zero, size: CGSize(width: pointSize, height: pointSize)), facing: .right, alpha: alpha, context: context)
        }

        NSGraphicsContext.restoreGraphicsState()

        let image = NSImage(size: NSSize(width: pointSize, height: pointSize))
        image.addRepresentation(bitmap)
        image.isTemplate = false
        return image
    }

    private func draw(rects: [PixelRect], in rect: CGRect, facing: PixelSnailFacing, alpha: CGFloat, context: CGContext) {
        let cellSize = max(1, floor(min(rect.width / CGFloat(manifest.canvas.width), rect.height / CGFloat(manifest.canvas.height))))
        let drawingSize = CGSize(
            width: CGFloat(manifest.canvas.width) * cellSize,
            height: CGFloat(manifest.canvas.height) * cellSize
        )
        let origin = CGPoint(
            x: rect.minX + ((rect.width - drawingSize.width) / 2),
            y: rect.minY + ((rect.height - drawingSize.height) / 2)
        )

        context.saveGState()
        context.setAllowsAntialiasing(false)
        context.interpolationQuality = .none

        for pixelRect in rects {
            guard let color = palette[pixelRect.color] else { continue }

            let mirroredX = facing == .left
                ? manifest.canvas.width - pixelRect.x - pixelRect.width
                : pixelRect.x
            let cgRect = CGRect(
                x: origin.x + (CGFloat(mirroredX) * cellSize),
                y: origin.y + (CGFloat(manifest.canvas.height - pixelRect.y - pixelRect.height) * cellSize),
                width: CGFloat(pixelRect.width) * cellSize,
                height: CGFloat(pixelRect.height) * cellSize
            )

            context.setFillColor(color.multipliedAlpha(alpha).cgColor)
            context.fill(cgRect.integral)
        }

        context.restoreGState()
    }
}

private struct PixelSnailManifest: Decodable {
    let canvas: PixelCanvas
    let palette: [String: String]
    let sprite: [PixelRect]
}

private struct PixelCanvas: Decodable {
    let width: Int
    let height: Int
}

private struct PixelRect: Decodable {
    let color: String
    let x: Int
    let y: Int
    let width: Int
    let height: Int
}

private enum PixelSnailArtError: Error {
    case invalidColor(String)
}

private extension NSColor {
    convenience init?(pixelHex hex: String) {
        let normalized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let length = normalized.count

        guard length == 6 || length == 8, let value = UInt64(normalized, radix: 16) else {
            return nil
        }

        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let alpha: CGFloat

        if length == 8 {
            red = CGFloat((value & 0xFF00_0000) >> 24) / 255
            green = CGFloat((value & 0x00FF_0000) >> 16) / 255
            blue = CGFloat((value & 0x0000_FF00) >> 8) / 255
            alpha = CGFloat(value & 0x0000_00FF) / 255
        } else {
            red = CGFloat((value & 0xFF0000) >> 16) / 255
            green = CGFloat((value & 0x00FF00) >> 8) / 255
            blue = CGFloat(value & 0x0000FF) / 255
            alpha = 1
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    func multipliedAlpha(_ multiplier: CGFloat) -> NSColor {
        guard let converted = usingColorSpace(.deviceRGB) else {
            return withAlphaComponent(alphaComponent * multiplier)
        }

        return NSColor(
            calibratedRed: converted.redComponent,
            green: converted.greenComponent,
            blue: converted.blueComponent,
            alpha: converted.alphaComponent * multiplier
        )
    }
}
