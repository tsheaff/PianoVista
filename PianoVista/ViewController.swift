import Cocoa

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
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
}
