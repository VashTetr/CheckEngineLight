class RAMCheck {
    checkName := "RAM"
    warningPercent := 85
    criticalPercent := 95
    enabled := true

    __New(configManager) {
        this.enabled := configManager.Get("RAMEnabled", 1)
        this.warningPercent := configManager.Get("RAMWarningPercent", 85)
        this.criticalPercent := configManager.Get("RAMCriticalPercent", 95)
    }

    Run() {
        results := []
        if (!this.enabled)
            return results

        try {
            memInfo := this._GetMemoryInfo()
            usedPercent := Round(memInfo["usedPercent"], 1)
            freeGB := Round(memInfo["availMB"] / 1024, 1)
            totalGB := Round(memInfo["totalMB"] / 1024, 1)
            usedGB := Round((memInfo["totalMB"] - memInfo["availMB"]) / 1024, 1)

            status := "OK"
            if (usedPercent >= this.criticalPercent)
                status := "CRITICAL"
            else if (usedPercent >= this.warningPercent)
                status := "WARNING"

            results.Push(Map(
                "type", "ram",
                "label", "RAM",
                "usedPercent", usedPercent,
                "freeGB", freeGB,
                "totalGB", totalGB,
                "usedGB", usedGB,
                "availMB", memInfo["availMB"],
                "totalMB", memInfo["totalMB"],
                "status", status,
                "message", usedPercent "% used (" freeGB " GB free of " totalGB " GB)"
            ))
        } catch as err {
            results.Push(Map(
                "type", "ram",
                "label", "RAM",
                "status", "OK",
                "message", "Could not check: " err.Message
            ))
        }
        return results
    }

    _GetMemoryInfo() {
        ; MEMORYSTATUSEX structure
        ; Size: 64 bytes
        buf := Buffer(64, 0)
        NumPut("UInt", 64, buf, 0)  ; dwLength

        if !DllCall("GlobalMemoryStatusEx", "Ptr", buf)
            throw Error("GlobalMemoryStatusEx failed")

        memLoad := NumGet(buf, 4, "UInt")           ; dwMemoryLoad (% used)
        totalPhys := NumGet(buf, 8, "UInt64")        ; ullTotalPhys
        availPhys := NumGet(buf, 16, "UInt64")       ; ullAvailPhys

        return Map(
            "usedPercent", memLoad,
            "totalMB", Round(totalPhys / 1048576),
            "availMB", Round(availPhys / 1048576)
        )
    }
}
