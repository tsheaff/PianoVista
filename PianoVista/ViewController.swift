import Cocoa
import MIKMIDI

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true

        listenForMidiEventsFromFirstSource()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func awakeFromNib() {
        view.layer?.backgroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
    }

    private func listenForMidiEventsFromFirstSource() {
        guard let firstSource = MIKMIDIDeviceManager.shared.virtualSources.first else { return }
        _ = try? MIKMIDIDeviceManager.shared.connectInput(firstSource) { (endpoint, commands) in
            commands.forEach { [weak self] (command) in
                self?.handleMidiCommand(command)
            }
        }
    }

    private func handleMidiCommand(_ command: MIKMIDICommand) {
        if command.commandType == .noteOn {
            if let noteOnCommand = command as? MIKMIDINoteOnCommand {
                createColoredCircleForNoteOn(noteOnCommand)
            }
        }
    }

    private var circleLayersByKey: [String: CALayer] = [:]

    private func frameForNote(_ note: MIKMIDINoteOnCommand) -> CGRect {
        // piano notes range 21 -> 108
        let dimension = 35 + CGFloat(note.velocity)
        let minNote: UInt = 21
        let maxNote: UInt = 108
        let portionInPianoRange = CGFloat(max(note.note, minNote) - minNote) / CGFloat(maxNote - minNote)
        let centerX = portionInPianoRange * view.frame.size.width
        let centerY = CGFloat.random(in: 0 ... view.frame.size.height)
        return CGRect(x: centerX - 0.5 * dimension, y: centerY - 0.5 * dimension, width: dimension, height: dimension)
    }

    private func createColoredCircleForNoteOn(_ noteOnCommand: MIKMIDINoteOnCommand) {
        let circleLayer = CAShapeLayer()
        let frame = frameForNote(noteOnCommand)
        circleLayer.path = NSBezierPath(ovalIn: frame).cgPath
        circleLayer.fillColor = ColorPallette.randomColor()
        self.view.layer?.addSublayer(circleLayer)

        let layerKey = UUID().uuidString
        circleLayersByKey[layerKey] = circleLayer

        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.setValue(layerKey, forKey: "circleLayerKey")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 1
        fadeAnimation.delegate = self
        circleLayer.add(fadeAnimation, forKey: layerKey)
        circleLayer.opacity = 0
    }
}

extension ViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let key = anim.value(forKey: "circleLayerKey") as? String else { return }
        guard let circleLayer = circleLayersByKey[key] else { return }
        circleLayer.removeFromSuperlayer()
        circleLayersByKey[key] = nil
    }
}

struct ColorPallette {
    static var color0 = CGColor.fromRGB(0x511845)
    static var color1 = CGColor.fromRGB(0x900c3f)
    static var color2 = CGColor.fromRGB(0xc70039)
    static var color3 = CGColor.fromRGB(0xff5733)

    static var colors: [CGColor] {
        return [color0, color1, color2, color3]
    }

    static func randomColor() -> CGColor {
        return colors.randomElement() ?? color0
    }
}

public extension CGColor {
    static func fromRedGreenBlue(red: Int, green: Int, blue: Int) -> CGColor {
        return CGColor(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: 1
        )
    }

    static func fromRGB(_ rgb: Int) -> CGColor {
        return CGColor.fromRedGreenBlue(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

public extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
                case .moveTo: path.move(to: points[0])
                case .lineTo: path.addLine(to: points[0])
                case .curveTo: path.addCurve(to: points[2], control1: points[0], control2: points[1])
                case .closePath: path.closeSubpath()
                default: break
            }
        }
        return path
    }
}
