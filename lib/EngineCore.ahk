class CheckEngine {
    configManager := ""
    trayManager := ""
    soundManager := ""
    mainWindow := ""
    checks := []
    slowChecks := []
    fastChecks := []
    verySlowChecks := []
    lastResults := []
    lastSlowResults := []
    lastFastResults := []
    lastVerySlowResults := []
    timerFn := ""
    slowTimerFn := ""
    fastTimerFn := ""
    verySlowTimerFn := ""

    __New(configManager, trayManager, soundManager) {
        this.configManager := configManager
        this.trayManager := trayManager
        this.soundManager := soundManager
        this.trayManager.OnScanRequested(ObjBindMethod(this, "ScanNow"))
    }

    SetMainWindow(window) {
        this.mainWindow := window
    }

    RegisterCheck(check) {
        this.checks.Push(check)
    }

    RegisterSlowCheck(check) {
        this.slowChecks.Push(check)
    }

    RegisterFastCheck(check) {
        this.fastChecks.Push(check)
    }

    RegisterVerySlowCheck(check) {
        this.verySlowChecks.Push(check)
    }

    Start() {
        ; Run all checks immediately
        this.RunChecks()
        this.RunSlowChecks()
        this.RunFastChecks()
        this.RunVerySlowChecks()

        ; Normal timer (disk space, etc.)
        intervalMs := this.configManager.Get("CheckIntervalMinutes", 10) * 60 * 1000
        this.timerFn := ObjBindMethod(this, "RunChecks")
        SetTimer(this.timerFn, intervalMs)

        ; Slow timer (chipset, GPU — WMI heavy)
        if (this.slowChecks.Length > 0) {
            slowIntervalMs := this.configManager.Get("ChipsetDriverCheckInterval", 120) * 60 * 1000
            this.slowTimerFn := ObjBindMethod(this, "RunSlowChecks")
            SetTimer(this.slowTimerFn, slowIntervalMs)
        }

        ; Fast timer (RAM, Network — lightweight API calls)
        if (this.fastChecks.Length > 0) {
            fastIntervalMs := this.configManager.Get("RAMCheckIntervalSeconds", 5) * 1000
            this.fastTimerFn := ObjBindMethod(this, "RunFastChecks")
            SetTimer(this.fastTimerFn, fastIntervalMs)
        }

        ; Very slow timer (Windows Update — COM heavy, every 8 hours)
        if (this.verySlowChecks.Length > 0) {
            verySlowMs := this.configManager.Get("WindowsUpdateCheckIntervalHours", 8) * 3600 * 1000
            this.verySlowTimerFn := ObjBindMethod(this, "RunVerySlowChecks")
            SetTimer(this.verySlowTimerFn, verySlowMs)
        }
    }

    ScanNow() {
        this.soundManager.Reset()
        this.trayManager.SetState("IDLE", [])
        this.lastResults := []
        this.lastSlowResults := []
        this.lastFastResults := []
        this.lastVerySlowResults := []
        Sleep(500)
        this.RunChecks()
        this.RunSlowChecks()
        this.RunFastChecks()
        this.RunVerySlowChecks()
    }

    RunChecks() {
        this.lastResults := this._ExecuteChecks(this.checks)
        this._UpdateState()
    }

    RunSlowChecks() {
        this.lastSlowResults := this._ExecuteChecks(this.slowChecks)
        this._UpdateState()
    }

    RunFastChecks() {
        this.lastFastResults := this._ExecuteChecks(this.fastChecks)
        this._UpdateState()
    }

    RunVerySlowChecks() {
        this.lastVerySlowResults := this._ExecuteChecks(this.verySlowChecks)
        this._UpdateState()
    }

    _ExecuteChecks(checkList) {
        results := []
        for check in checkList {
            try {
                ; Update title bar with current check name
                if (this.mainWindow && check.HasOwnProp("checkName"))
                    this.mainWindow.SetStatus("Checking " check.checkName)

                checkResults := check.Run()
                for result in checkResults
                    results.Push(result)
            } catch as err {
                ; If a check fails, don't crash everything
            }
        }

        ; Reset title when done
        if (this.mainWindow)
            this.mainWindow.SetStatus("")

        return results
    }

    _UpdateState() {
        ; Merge all result tiers
        allResults := []
        for r in this.lastResults
            allResults.Push(r)
        for r in this.lastSlowResults
            allResults.Push(r)
        for r in this.lastFastResults
            allResults.Push(r)
        for r in this.lastVerySlowResults
            allResults.Push(r)

        worstStatus := "OK"
        for result in allResults {
            status := result["status"]
            if (status == "CRITICAL")
                worstStatus := "CRITICAL"
            else if (status == "WARNING" && worstStatus != "CRITICAL")
                worstStatus := "WARNING"
        }

        this.trayManager.SetState(worstStatus, allResults)
        this.soundManager.PlayIfChanged(worstStatus)

        if (this.mainWindow) {
            this.mainWindow.UpdateResults(allResults)

            for check in this.checks {
                if (check is ChipsetDriverCheck && check.lastDriverList.Length > 0)
                    this.mainWindow.UpdateDriverDetails("chipset", check.lastDriverList, check.maxAgeMonths)
                if (check is GPUDriverCheck && check.lastDriverList.Length > 0)
                    this.mainWindow.UpdateDriverDetails("gpu", check.lastDriverList, check.maxAgeMonths)
            }
            for check in this.verySlowChecks {
                if (check is WindowsUpdateCheck && check.lastUpdateList.Length > 0)
                    this.mainWindow.UpdateUpdateDetails(check.lastUpdateList)
            }
        }
    }
}
