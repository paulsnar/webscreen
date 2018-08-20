import Foundation
import ScreenSaver

let PreferencesKeyAddressList = "conf.addresses"

class WebscreenConfiguration: NSObject, NSTableViewDataSource,
    NSTableViewDelegate {
  let defaults: UserDefaults
  var addresses: [WebscreenAddress]
    
  init(fromUserDefaults defaults: UserDefaults) {
    self.defaults = defaults
        
    var addresses = defaults.array(forKey: PreferencesKeyAddressList)
    if addresses == nil {
      addresses = []
    }
        
    self.addresses = (addresses as! [NSDictionary]).map {
      WebscreenAddress.fromDictionary($0) }
    if self.addresses.count == 0 {
      let defAddress = WebscreenAddress.init(
        withAddressString:
          "https://masu.p22.co/~paulsnar/bounce.html?screensaver",
        duration: .infinity)
      self.addresses = [defAddress]
    }
  
    super.init()
  }
    
  static func loadFromDefaults() -> WebscreenConfiguration {
    let defaults = ScreenSaverDefaults.init(forModuleWithName: WebscreenModuleName)!
    return WebscreenConfiguration.init(fromUserDefaults: defaults)
  }
  
  func persist() {
    NSLog("persisting")
    let addressDicts = self.addresses.map { $0.dictionaryRepresentation() }
    let addresses = NSArray.init(array: addressDicts)
    self.defaults.set(addresses, forKey: PreferencesKeyAddressList)
  
    //self.defaults.synchronize()
  }
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return self.addresses.count
  }
  
  func tableView(_ tableView: NSTableView,
       viewFor column: NSTableColumn?,
       row: Int) -> NSView? {
    if let column = column {
      let addr = self.addresses[row]
      
      let view = tableView.makeView(
        withIdentifier: column.identifier, owner: self) as! NSTableCellView
      
      switch column.identifier.rawValue {
      case "url":
        view.textField!.stringValue = "\(addr.url)"
        
      case "duration":
        view.textField!.stringValue = "\(addr.displayDuration)"
      
      default:
        fatalError("requested unknown column \(column.identifier)")
      }
      
      return view
    }
    
    return nil
  }
}
