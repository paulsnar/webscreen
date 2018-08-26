import Foundation
import Cocoa

protocol ConfigurationPanelDelegate {
  func configurationPanel(_: ConfigurationPanel, didChangeURLTo: URL, from: URL?)
  func configurationPanel(_: ConfigurationPanel, wasClosed: Void)
}

class ConfigurationPanel: NSWindowController {
  var previousURL: URL?
  var delegate: ConfigurationPanelDelegate?

  @IBOutlet weak var urlTextField: NSTextField!

  convenience init(fromURL: URL?) {
    let nibName = NSNib.Name.init(rawValue: "ConfigurationPanel")
    self.init(windowNibName: nibName)
    self.previousURL = fromURL
    if let url = fromURL {
      self.urlTextField.stringValue = url.absoluteString
    }
  }

  @IBAction func handleURLChanged(_ sender: NSTextField) {
    if let url = URL.init(string: sender.stringValue) {
      self.delegate?.configurationPanel(self,
          didChangeURLTo: url,
          from: self.previousURL)
      self.previousURL = url
    }
  }

  @IBAction func handleCloseClicked(_ sender: NSButton) {
    self.delegate?.configurationPanel(self, wasClosed: ())
  }
}
