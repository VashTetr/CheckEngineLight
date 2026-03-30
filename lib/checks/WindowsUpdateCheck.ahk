class WindowsUpdateCheck {
    checkName := "Windows Update"
    enabled := true
    lastUpdateList := []

    __New(configManager) {
        this.enabled := configManager.Get("WindowsUpdateEnabled", 1)
    }

    Run() {
        results := []
        if (!this.enabled)
            return results

        try {
            updates := this._GetPendingUpdates()
            this.lastUpdateList := updates

            if (updates.Length == 0) {
                results.Push(Map(
                    "type", "winupdate",
                    "label", "Windows Update",
                    "status", "OK",
                    "updateCount", 0,
                    "criticalCount", 0,
                    "message", "Up to date"
                ))
            } else {
                ; Count critical/important updates
                critCount := 0
                for upd in updates {
                    if (upd["severity"] == "Critical" || upd["severity"] == "Important")
                        critCount++
                }

                status := critCount > 0 ? "CRITICAL" : "WARNING"
                msg := updates.Length " update(s) pending"
                if (critCount > 0)
                    msg .= " (" critCount " critical)"

                results.Push(Map(
                    "type", "winupdate",
                    "label", "Windows Update",
                    "status", status,
                    "updateCount", updates.Length,
                    "criticalCount", critCount,
                    "message", msg
                ))
            }
        } catch as err {
            results.Push(Map(
                "type", "winupdate",
                "label", "Windows Update",
                "status", "OK",
                "updateCount", 0,
                "criticalCount", 0,
                "message", "Could not check: " err.Message
            ))
        }
        return results
    }

    _GetPendingUpdates() {
        updates := []

        updateSession := ComObject("Microsoft.Update.Session")
        updateSearcher := updateSession.CreateUpdateSearcher()

        ; Search for updates not installed and not hidden
        searchResult := updateSearcher.Search("IsInstalled=0 AND IsHidden=0")

        count := searchResult.Updates.Count
        i := 0
        while (i < count) {
            update := searchResult.Updates.Item(i)
            title := ""
            severity := "Optional"
            try title := update.Title
            try {
                msrcSeverity := update.MsrcSeverity
                if (msrcSeverity != "")
                    severity := msrcSeverity
            }

            updates.Push(Map(
                "title", title,
                "severity", severity
            ))
            i++
        }

        return updates
    }
}
