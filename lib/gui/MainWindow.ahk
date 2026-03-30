class MainWindow {
    gui := ""
    tabs := Map()
    sidebarBtns := []
    activeTab := "status"
    imgDir := ""
    lastResults := []
    sidebarW := 60
    windowW := 700
    windowH := 500
    built := false
    configManager := ""

    __New(imgDir, configManager := "") {
        this.imgDir := imgDir
        this.configManager := configManager
    }

    _Build() {
        if (this.built)
            return

        splash := Gui("+AlwaysOnTop -Caption +Border", "")
        splash.BackColor := ThemeManager.BgDark
        splash.SetFont("s12 c" ThemeManager.TextPrimary, "Segoe UI")
        splash.Add("Text", "w250 h40 Center", "Check Engine Light`nBuilding GUI...")
        splash.Show("w250 h60")

        this.gui := Gui("-MaximizeBox", "Check Engine Light")
        this.gui.OnEvent("Close", (*) => this.gui.Hide())
        this.gui.BackColor := ThemeManager.BgSidebar
        this.gui.SetFont("s10 c" ThemeManager.TextPrimary, "Segoe UI")

        ; Content area background
        this.gui.Add("Text", "x" this.sidebarW " y0 w" (this.windowW - this.sidebarW) " h" this.windowH " Background" ThemeManager.BgContent)

        ; Init scroll manager
        ScrollManager.Init(0, this.windowH)

        ; Sidebar buttons
        this._AddSidebarBtn(1, "status", "dashboard", "top")
        this._AddSidebarBtn(2, "drives", "drives", "top")
        this._AddSidebarBtn(3, "chipset", "cpu", "top")
        this._AddSidebarBtn(4, "gpu", "gpu", "top")
        this._AddSidebarBtn(5, "ram", "ram", "top")
        this._AddSidebarBtn(6, "network", "network", "top")
        this._AddSidebarBtn(7, "winupdate", "windows", "top")
        this._AddSidebarBtn(1, "settings", "settings", "bottom")

        contentX := this.sidebarW
        contentY := 0
        contentW := this.windowW - this.sidebarW

        ; Create all tabs
        this.tabs["status"] := StatusTab(this.gui, this.imgDir, contentX, contentY, contentW)
        this.tabs["status"].Create()

        this.tabs["drives"] := DrivesTab(this.gui, contentX, contentY, contentW)
        this.tabs["drives"].Create()

        this.tabs["chipset"] := ChipsetTab(this.gui, contentX, contentY, contentW)
        this.tabs["chipset"].Create()

        this.tabs["gpu"] := GPUTab(this.gui, contentX, contentY, contentW)
        this.tabs["gpu"].Create()

        this.tabs["ram"] := RAMTab(this.gui, contentX, contentY, contentW)
        this.tabs["ram"].Create()

        this.tabs["network"] := NetworkTab(this.gui, contentX, contentY, contentW)
        this.tabs["network"].Create()

        this.tabs["winupdate"] := WindowsUpdateTab(this.gui, contentX, contentY, contentW)
        this.tabs["winupdate"].Create()

        if (this.configManager) {
            this.tabs["settings"] := SettingsTab(this.gui, contentX, contentY, contentW, this.configManager)
            this.tabs["settings"].Create()
        }

        ; Register all tab controls with scroll manager
        for name, tab in this.tabs {
            allCtrls := this._CollectTabControls(tab)
            totalH := this._EstimateTabHeight(tab)
            ScrollManager.RegisterTab(name, allCtrls, totalH)
        }

        ; Hide ALL tabs
        for name, tab in this.tabs
            tab.Hide()

        ; Show active tab
        this.tabs["status"].Show()
        this._UpdateSidebarIcons("status")
        ScrollManager.SetActiveTab("status")

        if (this.lastResults.Length > 0) {
            for name, tab in this.tabs
                tab.Update(this.lastResults)
        }

        ; Hook mouse wheel
        guiHwnd := this.gui.Hwnd
        guiRef := this.gui
        OnMessage(0x020A, (wParam, lParam, msg, hwnd) => this._OnMouseWheel(wParam, lParam, msg, hwnd))

        this.built := true
        splash.Destroy()
    }

    _CollectTabControls(tab) {
        ctrls := []
        if tab.HasOwnProp("controls") {
            for key, ctrl in tab.controls
                ctrls.Push(ctrl)
        }
        if tab.HasOwnProp("fields") {
            for key, ctrl in tab.fields
                ctrls.Push(ctrl)
        }
        if tab.HasOwnProp("driveRows") {
            for row in tab.driveRows {
                for key, ctrl in row
                    ctrls.Push(ctrl)
            }
        }
        if tab.HasOwnProp("driverRows") {
            for row in tab.driverRows {
                for key, ctrl in row
                    ctrls.Push(ctrl)
            }
        }
        if tab.HasOwnProp("updateRows") {
            for row in tab.updateRows {
                for key, ctrl in row
                    ctrls.Push(ctrl)
            }
        }
        return ctrls
    }

    _EstimateTabHeight(tab) {
        maxY := 0
        ctrls := this._CollectTabControls(tab)
        for ctrl in ctrls {
            try {
                ctrl.GetPos(, &cy, , &ch)
                bottom := cy + ch
                if (bottom > maxY)
                    maxY := bottom
            }
        }
        return maxY + 20  ; padding
    }

    _OnMouseWheel(wParam, lParam, msg, hwnd) {
        ; Check if mouse is over our window
        if !WinExist("ahk_id " this.gui.Hwnd)
            return

        delta := (wParam >> 16) & 0xFFFF
        if (delta > 0x7FFF)
            delta := delta - 0x10000

        ScrollManager.OnWheel(this.gui, delta)
    }

    _AddSidebarBtn(index, tabName, iconName, position := "top") {
        btnSize := 40
        padding := 10

        if (position == "bottom")
            y := this.windowH - padding - btnSize * index - padding * (index - 1)
        else
            y := padding + (index - 1) * (btnSize + padding)

        x := (this.sidebarW - btnSize) // 2
        iconPath := this.imgDir "\lightgrey_" iconName ".png"

        btn := this.gui.Add("Picture", "x" x " y" y " w" btnSize " h" btnSize, iconPath)
        btn.OnEvent("Click", (*) => this._SwitchTab(tabName))

        this.sidebarBtns.Push(Map(
            "ctrl", btn,
            "tabName", tabName,
            "iconName", iconName
        ))
    }

    _SwitchTab(tabName) {
        ; Reset scroll on old tab
        ScrollManager.ResetScroll(this.activeTab)

        this.activeTab := tabName

        for name, tab in this.tabs
            tab.Hide()

        if this.tabs.Has(tabName) {
            if (this.lastResults.Length > 0)
                this.tabs[tabName].Update(this.lastResults)
            this.tabs[tabName].Show()
        }

        ScrollManager.SetActiveTab(tabName)
        this._UpdateSidebarIcons(tabName)
    }

    _UpdateSidebarIcons(tabName) {
        for btnInfo in this.sidebarBtns {
            if (btnInfo["tabName"] == tabName)
                btnInfo["ctrl"].Value := this.imgDir "\white_" btnInfo["iconName"] ".png"
            else
                btnInfo["ctrl"].Value := this.imgDir "\lightgrey_" btnInfo["iconName"] ".png"
        }
    }

    UpdateResults(results) {
        this.lastResults := results
        if (this.built && this.tabs.Has(this.activeTab))
            this.tabs[this.activeTab].Update(results)
    }

    UpdateDriverDetails(type, driverList, maxAgeMonths) {
        if (!this.built)
            return
        if (type == "chipset" && this.tabs.Has("chipset"))
            this.tabs["chipset"].SetDriverDetails(driverList, maxAgeMonths)
        else if (type == "gpu" && this.tabs.Has("gpu"))
            this.tabs["gpu"].SetDriverDetails(driverList, maxAgeMonths)
    }

    UpdateUpdateDetails(updateList) {
        if (!this.built)
            return
        if this.tabs.Has("winupdate")
            this.tabs["winupdate"].SetUpdateDetails(updateList)
    }

    SetStatus(text) {
        if (!this.built)
            return
        if (text == "")
            this.gui.Title := "Check Engine Light"
        else
            this.gui.Title := "Check Engine Light - " text
    }

    Show() {
        this._Build()
        this.gui.Show("w" this.windowW " h" this.windowH)
    }

    Toggle() {
        if (this.built && WinExist("ahk_id " this.gui.Hwnd)) {
            if DllCall("IsWindowVisible", "Ptr", this.gui.Hwnd)
                this.gui.Hide()
            else
                this.gui.Show()
        } else {
            this.Show()
        }
    }
}
