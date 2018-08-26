import Foundation

var defaultUrl = "https://masu.p22.co/~paulsnar/bounce.php"

class Configuration: NSObject {
  var url: URL

  init(withURL url: URL?) {
    if let url = url {
      self.url = url
    } else {
      self.url = URL(string: defaultUrl)!
    }

    super.init()
  }
}
