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
        guard let layer = self.view.layer else { return }

        layer.backgroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
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

    }
}
