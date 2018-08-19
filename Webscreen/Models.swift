import Foundation

class WebscreenAddress: NSObject {
  var url: URL
  var displayDuration: TimeInterval
    
  init(withAddressString address: String, duration: TimeInterval) {
    self.url = URL(string: address)!
    self.displayDuration = duration
  
    super.init()
  }
  
  init(withURL url: URL, duration: TimeInterval) {
    self.url = url
    self.displayDuration = duration
  
    super.init()
  }
  
  static func fromDictionary(_ dict: NSDictionary) -> WebscreenAddress {
    let url = dict["url"] as! String,
        duration = dict["displayDuration"] as! TimeInterval
    return WebscreenAddress.init(withAddressString: url, duration: duration)
  }
  
  func dictionaryRepresentation() -> [String: Any] {
    return [
      "url": self.url.absoluteString,
      "displayDuration": self.displayDuration,
    ]
  }
}
