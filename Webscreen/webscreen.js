(function() {
  "use strict";

  var Events = {
    listeners: { },

    gc: function() {
      var events = Object.keys(this.listeners)
      for (var i = events.length - 1; i >= 0; i -= 1) {
        var eventName = events[i],
            listeners = this.listeners[eventName]
        if (listeners.length === 0) {
          delete this.listeners[eventName]
        }
      }
    },

    once: function(name, listener) {
      if (name in this.listeners) {
        this.listeners[name].push({ oneshot: true, listener: listener })
        return
      }

      this.listeners[name] = [
        { oneshot: true, listener: listener },
      ]
    },

    on: function(name, listener) {
      if (name in this.listeners) {
        this.listeners[name].push({ listener: listener })
        return
      }

      this.listeners[name] = [ { listener: listener } ]
    },

    off: function(name, listener) {
      if ( ! (name in this.listeners)) {
        return
      }

      var listeners = this.listeners[name]
      for (var i = listeners.length - 1; i >= 0; i -= 1) {
        if (listeners[i].listener === listener) {
          listeners.splice(i, 1)
          return
        }
      }
    },

    trigger: function(name, arg) {
      if ( ! (name in this.listeners)) {
        return
      }

      var event = { stopIteration: false, data: arg }

      var listeners = this.listeners[name]
      for (var i = 0; i < listeners.length; i += 1) {
        var listener = listeners[i]
        try {
          listener.listener(event)
        } catch (e) { }
        if (listener.oneshot) {
          listeners.splice(i, 1)
          i -= 1
        }
      }

      this.gc()
    },
  }

  window.WSKit = {
    display: null,
    totalDisplays: null,

    addEventListener: function(name, listener, config) {
      config = config || { }

      if (config.oneshot) {
        Events.once(name, listener)
      } else {
        Events.on(name, listener)
      }
    },
    removeEventListener: function(name, listener) {
      Events.off(name, listener)
    },
    dispatchEvent: function(name, arg) {
      console.log('[WSKit] event: %s %o', name, arg)
      Events.trigger(name, arg)
    },
  }

  WSKit.addEventListener('configuration', function(ev) {
    var config = ev.data
    WSKit.display = config.display
    WSKit.totalDisplays = config.totalDisplays
  })
  window.webkit.messageHandlers.webscreen.postMessage('obtainconfiguration')
})();
