import Foundation

var defaultUrl = "https://masu.p22.co/~paulsnar/bounce.php"

var kURL = "URL"

class Configuration: NSObject {
  private var _url: URL
  var url: URL {
    get {
      return self._url
    }
    set {
      self._url = newValue
      self.persist(url: newValue)
    }
  }

  var defaults: UserDefaults?

  init(withURL url: URL?) {
    if let url = url {
      self._url = url
    } else {
      self._url = URL(string: defaultUrl)!
    }

    super.init()
    self.persist(url: self._url)
  }

  convenience init(fromDefaults defaults: UserDefaults) {
    var url: URL? = nil
    if let storedUrlString = defaults.string(forKey: kURL) {
      url = URL(string: storedUrlString)
    }
    self.init(withURL: url)
    self.defaults = defaults
  }

  func persist(url: URL) {
    self.defaults?.set(url.absoluteString, forKey: kURL)
  }
}
