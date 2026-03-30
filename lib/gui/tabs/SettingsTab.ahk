class SettingsTab {
    controls := Map()
    fields := Map()
    gui := ""
    contentX := 0
    contentY := 0
    contentW := 0
    configManager := ""
    savedSnapshot := ""
    onSaveCallback := ""

    __New(gui, contentX, contentY, contentW, configManager) {
        this.gui := gui
        this.contentX := contentX
        this.contentY := contentY
        this.contentW := contentW
        this.configManager := configManager
        this.savedSnapshot := configManager.GetSnapshot()
    }

    Create() {
        g := this.gui
        x := this.contentX + 20
        y := this.contentY + 15
        w := this.contentW - 40
        labelW := 220
        inputW := 80
        inputX := x + labelW + 10

        ; Title
        this.controls["title"] := g.Add("Text", "x" x " y" y " w" w " h30 Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent, "Settings")
        this.controls["title"].SetFont("s16 bold", "Segoe UI")

        rowY := y + 45
        rowH := 28
        rowSpacing := 34

        ; --- General ---
        this.controls["generalHeader"] := g.Add("Text", "x" x " y" rowY " w" w " h24 Hidden c" ThemeManager.Accent " Background" ThemeManager.BgContent, "General")
        this.controls["generalHeader"].SetFont("s11 bold", "Segoe UI")
        rowY += 28

        this.controls["intervalLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Check Interval (minutes)")
        this.controls["intervalLabel"].SetFont("s10", "Segoe UI")
        this.fields["CheckIntervalMinutes"] := g.Add("Edit", "x" inputX " y" rowY " w" inputW " h" rowH " Hidden Number Background" ThemeManager.BgCard " c" ThemeManager.TextPrimary, this.configManager.Get("CheckIntervalMinutes"))
        rowY += rowSpacing

        ; --- Disk Space ---
        this.controls["diskHeader"] := g.Add("Text", "x" x " y" rowY " w" w " h24 Hidden c" ThemeManager.Accent " Background" ThemeManager.BgContent, "Disk Space")
        this.controls["diskHeader"].SetFont("s11 bold", "Segoe UI")
        rowY += 28

        this.controls["warnLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Warning Threshold (%)")
        this.controls["warnLabel"].SetFont("s10", "Segoe UI")
        this.fields["WarningPercent"] := g.Add("Edit", "x" inputX " y" rowY " w" inputW " h" rowH " Hidden Number Background" ThemeManager.BgCard " c" ThemeManager.TextPrimary, this.configManager.Get("WarningPercent"))
        rowY += rowSpacing

        this.controls["critLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Critical Threshold (%)")
        this.controls["critLabel"].SetFont("s10", "Segoe UI")
        this.fields["CriticalPercent"] := g.Add("Edit", "x" inputX " y" rowY " w" inputW " h" rowH " Hidden Number Background" ThemeManager.BgCard " c" ThemeManager.TextPrimary, this.configManager.Get("CriticalPercent"))
        rowY += rowSpacing

        ; --- Chipset Driver ---
        this.controls["chipsetHeader"] := g.Add("Text", "x" x " y" rowY " w" w " h24 Hidden c" ThemeManager.Accent " Background" ThemeManager.BgContent, "Chipset Driver")
        this.controls["chipsetHeader"].SetFont("s11 bold", "Segoe UI")
        rowY += 28

        this.controls["chipsetEnabledLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Enabled")
        this.controls["chipsetEnabledLabel"].SetFont("s10", "Segoe UI")
        this.fields["ChipsetDriverEnabled"] := g.Add("Checkbox", "x" inputX " y" rowY " w" inputW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent, "")
        this.fields["ChipsetDriverEnabled"].Value := this.configManager.Get("ChipsetDriverEnabled")
        rowY += rowSpacing

        this.controls["chipsetAgeLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Max Driver Age (months)")
        this.controls["chipsetAgeLabel"].SetFont("s10", "Segoe UI")
        this.fields["ChipsetDriverMaxAgeMonths"] := g.Add("Edit", "x" inputX " y" rowY " w" inputW " h" rowH " Hidden Number Background" ThemeManager.BgCard " c" ThemeManager.TextPrimary, this.configManager.Get("ChipsetDriverMaxAgeMonths"))
        rowY += rowSpacing

        ; --- GPU Driver ---
        this.controls["gpuHeader"] := g.Add("Text", "x" x " y" rowY " w" w " h24 Hidden c" ThemeManager.Accent " Background" ThemeManager.BgContent, "GPU Driver")
        this.controls["gpuHeader"].SetFont("s11 bold", "Segoe UI")
        rowY += 28

        this.controls["gpuEnabledLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Enabled")
        this.controls["gpuEnabledLabel"].SetFont("s10", "Segoe UI")
        this.fields["GPUDriverEnabled"] := g.Add("Checkbox", "x" inputX " y" rowY " w" inputW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent, "")
        this.fields["GPUDriverEnabled"].Value := this.configManager.Get("GPUDriverEnabled")
        rowY += rowSpacing

        this.controls["gpuAgeLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Max Driver Age (months)")
        this.controls["gpuAgeLabel"].SetFont("s10", "Segoe UI")
        this.fields["GPUDriverMaxAgeMonths"] := g.Add("Edit", "x" inputX " y" rowY " w" inputW " h" rowH " Hidden Number Background" ThemeManager.BgCard " c" ThemeManager.TextPrimary, this.configManager.Get("GPUDriverMaxAgeMonths"))
        rowY += rowSpacing

        ; --- RAM ---
        this.controls["ramHeader"] := g.Add("Text", "x" x " y" rowY " w" w " h24 Hidden c" ThemeManager.Accent " Background" ThemeManager.BgContent, "RAM")
        this.controls["ramHeader"].SetFont("s11 bold", "Segoe UI")
        rowY += 28

        this.controls["ramEnabledLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Enabled")
        this.controls["ramEnabledLabel"].SetFont("s10", "Segoe UI")
        this.fields["RAMEnabled"] := g.Add("Checkbox", "x" inputX " y" rowY " w" inputW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent, "")
        this.fields["RAMEnabled"].Value := this.configManager.Get("RAMEnabled")
        rowY += rowSpacing

        this.controls["ramIntervalLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Check Interval (seconds)")
        this.controls["ramIntervalLabel"].SetFont("s10", "Segoe UI")
        this.fields["RAMCheckIntervalSeconds"] := g.Add("Edit", "x" inputX " y" rowY " w" inputW " h" rowH " Hidden Number Background" ThemeManager.BgCard " c" ThemeManager.TextPrimary, this.configManager.Get("RAMCheckIntervalSeconds"))
        rowY += rowSpacing

        this.controls["ramWarnLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Warning Threshold (% used)")
        this.controls["ramWarnLabel"].SetFont("s10", "Segoe UI")
        this.fields["RAMWarningPercent"] := g.Add("Edit", "x" inputX " y" rowY " w" inputW " h" rowH " Hidden Number Background" ThemeManager.BgCard " c" ThemeManager.TextPrimary, this.configManager.Get("RAMWarningPercent"))
        rowY += rowSpacing

        this.controls["ramCritLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Critical Threshold (% used)")
        this.controls["ramCritLabel"].SetFont("s10", "Segoe UI")
        this.fields["RAMCriticalPercent"] := g.Add("Edit", "x" inputX " y" rowY " w" inputW " h" rowH " Hidden Number Background" ThemeManager.BgCard " c" ThemeManager.TextPrimary, this.configManager.Get("RAMCriticalPercent"))
        rowY += rowSpacing

        ; --- Network ---
        this.controls["netHeader"] := g.Add("Text", "x" x " y" rowY " w" w " h24 Hidden c" ThemeManager.Accent " Background" ThemeManager.BgContent, "Network")
        this.controls["netHeader"].SetFont("s11 bold", "Segoe UI")
        rowY += 28

        this.controls["netEnabledLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Enabled")
        this.controls["netEnabledLabel"].SetFont("s10", "Segoe UI")
        this.fields["NetworkEnabled"] := g.Add("Checkbox", "x" inputX " y" rowY " w" inputW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent, "")
        this.fields["NetworkEnabled"].Value := this.configManager.Get("NetworkEnabled")
        rowY += rowSpacing

        ; --- Windows Update ---
        this.controls["wuHeader"] := g.Add("Text", "x" x " y" rowY " w" w " h24 Hidden c" ThemeManager.Accent " Background" ThemeManager.BgContent, "Windows Update")
        this.controls["wuHeader"].SetFont("s11 bold", "Segoe UI")
        rowY += 28

        this.controls["wuEnabledLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Enabled")
        this.controls["wuEnabledLabel"].SetFont("s10", "Segoe UI")
        this.fields["WindowsUpdateEnabled"] := g.Add("Checkbox", "x" inputX " y" rowY " w" inputW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent, "")
        this.fields["WindowsUpdateEnabled"].Value := this.configManager.Get("WindowsUpdateEnabled")
        rowY += rowSpacing

        this.controls["wuIntervalLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Check Interval (hours)")
        this.controls["wuIntervalLabel"].SetFont("s10", "Segoe UI")
        this.fields["WindowsUpdateCheckIntervalHours"] := g.Add("Edit", "x" inputX " y" rowY " w" inputW " h" rowH " Hidden Number Background" ThemeManager.BgCard " c" ThemeManager.TextPrimary, this.configManager.Get("WindowsUpdateCheckIntervalHours"))
        rowY += rowSpacing + 10

        ; --- Buttons ---
        btnW := 100
        btnH := 32
        btnSpacing := 15

        this.controls["saveBtn"] := g.Add("Button", "x" x " y" rowY " w" btnW " h" btnH " Hidden", "Save")
        this.controls["saveBtn"].OnEvent("Click", (*) => this._OnSave())

        this.controls["resetBtn"] := g.Add("Button", "x" (x + btnW + btnSpacing) " y" rowY " w" btnW " h" btnH " Hidden", "Reset")
        this.controls["resetBtn"].OnEvent("Click", (*) => this._OnReset())

        this.controls["testBtn"] := g.Add("Button", "x" (x + (btnW + btnSpacing) * 2) " y" rowY " w" btnW " h" btnH " Hidden", "Run Tests")
        this.controls["testBtn"].OnEvent("Click", (*) => this._OnRunTests())

        this.controls["statusMsg"] := g.Add("Text", "x" (x + (btnW + btnSpacing) * 3 + 10) " y" rowY " w200 h" btnH " Hidden c" ThemeManager.StatusOK " Background" ThemeManager.BgContent " 0x200", "")
        this.controls["statusMsg"].SetFont("s10", "Segoe UI")
    }

    _OnSave() {
        ; Read all fields into config
        for key, ctrl in this.fields {
            if (ctrl is Gui.Checkbox)
                this.configManager.Set(key, ctrl.Value)
            else
                this.configManager.Set(key, Integer(ctrl.Value))
        }

        ; Save to disk
        this.configManager.Save()

        ; Update snapshot for reset
        this.savedSnapshot := this.configManager.GetSnapshot()

        ; Show confirmation
        this.controls["statusMsg"].Text := "✓ Saved"
        this.controls["statusMsg"].Opt("c" ThemeManager.StatusOK)

        ; Notify engine to reload if callback set
        if (this.onSaveCallback)
            this.onSaveCallback.Call()

        ; Clear message after 3 seconds
        SetTimer((*) => (this.controls["statusMsg"].Text := ""), -3000)
    }

    _OnReset() {
        ; Restore to last saved state
        this.configManager.RestoreSnapshot(this.savedSnapshot)
        this._RefreshFields()

        this.controls["statusMsg"].Text := "↩ Reset to last save"
        this.controls["statusMsg"].Opt("c" ThemeManager.StatusWarn)
        SetTimer((*) => (this.controls["statusMsg"].Text := ""), -3000)
    }

    _OnRunTests() {
        testScript := A_ScriptDir "\tests\RunTests.ahk"
        if FileExist(testScript)
            Run('"' A_AhkPath '" "' testScript '"')
        else
            MsgBox("Test script not found", "Check Engine", "Icon!")
    }

    _RefreshFields() {
        for key, ctrl in this.fields {
            val := this.configManager.Get(key)
            if (ctrl is Gui.Checkbox)
                ctrl.Value := val
            else
                ctrl.Value := val
        }
    }

    OnSave(callback) {
        this.onSaveCallback := callback
    }

    Update(results) {
        ; Settings tab doesn't need result updates
    }

    Show() {
        for key, ctrl in this.controls
            ctrl.Visible := true
        for key, ctrl in this.fields
            ctrl.Visible := true
    }

    Hide() {
        for key, ctrl in this.controls
            ctrl.Visible := false
        for key, ctrl in this.fields
            ctrl.Visible := false
    }
}
