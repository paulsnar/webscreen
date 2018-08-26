import Foundation
import Cocoa

protocol ConfigurationPanelDelegate {
  func configurationPanel(_: ConfigurationPanel, didChangeURLTo: URL, from: URL?)
  func configurationPanel(_: ConfigurationPanel, didClose: Void)
}

class ConfigurationPanel: NSWindowController, NSWindowDelegate, NSTextFieldDelegate {
  var previousURL: URL?
  var delegate: ConfigurationPanelDelegate?

  private var urlDirty = false

  @IBOutlet weak var urlTextField: NSTextField!

  convenience init(fromURL url: URL?) {
    let nibName = NSNib.Name.init(rawValue: "ConfigurationPanel")
    self.init(windowNibName: nibName)
    self.previousURL = url
  }

  override func loadWindow() {
    super.loadWindow()

    // This is a hacky place to do this but right now my windowDidLoad is not
    // working correctly so I'll fix it in post
    if let url = self.previousURL {
      self.urlTextField.stringValue = url.absoluteString
    }
  }

  @IBAction func handleURLChanged(_ sender: NSTextField) {
    if let url = URL.init(string: sender.stringValue) {
      self.urlDirty = false
      self.delegate?.configurationPanel(self,
          didChangeURLTo: url,
          from: self.previousURL)
      self.previousURL = url
    }
  }

  @IBAction func handleCloseClicked(_ sender: NSButton) {
    if self.urlDirty {
      self.handleURLChanged(self.urlTextField)
    }
    self.window!.close()
    self.delegate?.configurationPanel(self, didClose: ())
  }

  override func controlTextDidChange(_ obj: Notification) {
    self.urlDirty = true
  }
}
