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
        self.view.layer?.backgroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
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

    private func createColoredCircleForNoteOn(_ noteOnCommand: MIKMIDINoteOnCommand) {
        let circleFrame = CGRect(x: CGFloat.random(in: 0 ... 1000), y: CGFloat.random(in: 0 ... 1000), width: 100, height: 100)
        let circleLayer = CAShapeLayer()
        circleLayer.path = NSBezierPath(ovalIn: circleFrame).cgPath
        circleLayer.fillColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
        self.view.layer?.addSublayer(circleLayer)
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
