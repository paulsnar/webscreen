import Foundation
import ScreenSaver

let PreferencesKeyAddressList = "conf.addresses"

class WebscreenConfiguration: NSObject {
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
}
