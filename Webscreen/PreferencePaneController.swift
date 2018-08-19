import Foundation
import Cocoa

protocol PreferencePaneControllerDelegate {
  func preferencePaneWillClose(_ notification: Notification)
}

class PreferencePaneController: NSObject, NSWindowDelegate {
  @IBOutlet var panel: NSPanel!
  @IBOutlet var panelContents: NSView!
  @IBOutlet var tableView: NSTableView!
  
  var delegate: PreferencePaneControllerDelegate?
  
  override init() {
    super.init()
    
    let ownBundle = Bundle(for: NSClassFromString(className)!)
    let paneNib = NSNib.init(
      nibNamed: NSNib.Name.init("PreferencePane"),
      bundle: ownBundle)!
    
    paneNib.instantiate(withOwner: self, topLevelObjects: nil)
  }
  
  @IBAction func didClickCloseButton(_ sender: Any) {
    self.panel.close()
  }
  
  func windowWillClose(_ notification: Notification) {
    if let delegate = self.delegate {
      let notif = Notification.init(
        name: Notification.Name.init("PreferencePane.willClose"),
        object: self,
        userInfo: nil)
      delegate.preferencePaneWillClose(notif)
    }
  }
}
