class NetworkCheck {
    checkName := "Network"
    enabled := true

    __New(configManager) {
        this.enabled := configManager.Get("NetworkEnabled", 1)
    }

    Run() {
        results := []
        if (!this.enabled)
            return results

        try {
            connected := this._IsConnected()
            if (connected) {
                results.Push(Map(
                    "type", "network",
                    "label", "Network",
                    "status", "OK",
                    "connected", true,
                    "message", "Connected"
                ))
            } else {
                results.Push(Map(
                    "type", "network",
                    "label", "Network",
                    "status", "CRITICAL",
                    "connected", false,
                    "message", "No internet connection"
                ))
            }
        } catch as err {
            results.Push(Map(
                "type", "network",
                "label", "Network",
                "status", "OK",
                "connected", false,
                "message", "Could not check: " err.Message
            ))
        }
        return results
    }

    _IsConnected() {
        ; Use InternetGetConnectedState from wininet.dll
        flags := 0
        return DllCall("wininet\InternetGetConnectedState", "UInt*", &flags, "UInt", 0)
    }
}
