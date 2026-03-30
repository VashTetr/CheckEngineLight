class RAMTab {
    controls := Map()
    gui := ""
    contentX := 0
    contentY := 0
    contentW := 0

    __New(gui, contentX, contentY, contentW) {
        this.gui := gui
        this.contentX := contentX
        this.contentY := contentY
        this.contentW := contentW
    }

    Create() {
        g := this.gui
        x := this.contentX + 20
        y := this.contentY + 15
        w := this.contentW - 40

        this.controls["title"] := g.Add("Text", "x" x " y" y " w" w " h30 Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent, "RAM Usage")
        this.controls["title"].SetFont("s16 bold", "Segoe UI")

        ; Usage summary
        this.controls["summary"] := g.Add("Text", "x" x " y" (y + 45) " w" w " h25 Hidden c" ThemeManager.TextSecondary " Background" ThemeManager.BgContent, "Waiting for scan...")
        this.controls["summary"].SetFont("s11", "Segoe UI")

        ; Progress bar
        barY := y + 80
        this.controls["barBg"] := g.Add("Progress", "x" x " y" barY " w" w " h24 Hidden Background" ThemeManager.ProgressBg " c" ThemeManager.StatusOK " Range0-100", 0)

        ; Detail labels
        detailY := barY + 40
        this.controls["usedLabel"] := g.Add("Text", "x" x " y" detailY " w" w " h25 Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent, "Used: --")
        this.controls["usedLabel"].SetFont("s10", "Segoe UI")

        this.controls["freeLabel"] := g.Add("Text", "x" x " y" (detailY + 30) " w" w " h25 Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent, "Free: --")
        this.controls["freeLabel"].SetFont("s10", "Segoe UI")

        this.controls["totalLabel"] := g.Add("Text", "x" x " y" (detailY + 60) " w" w " h25 Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent, "Total: --")
        this.controls["totalLabel"].SetFont("s10", "Segoe UI")
    }

    Update(results) {
        for r in results {
            rType := r.Has("type") ? r["type"] : ""
            if (rType != "ram")
                continue

            usedPct := r.Has("usedPercent") ? r["usedPercent"] : 0
            freeGB := r.Has("freeGB") ? r["freeGB"] : 0
            totalGB := r.Has("totalGB") ? r["totalGB"] : 0
            usedGB := r.Has("usedGB") ? r["usedGB"] : 0
            status := r["status"]

            ; Summary
            color := ThemeManager.StatusOK
            if (status == "WARNING")
                color := ThemeManager.StatusWarn
            else if (status == "CRITICAL")
                color := ThemeManager.StatusCrit

            this.controls["summary"].Text := usedPct "% used — " status
            this.controls["summary"].Opt("c" color)

            ; Progress bar
            this.controls["barBg"].Opt("c" color)
            this.controls["barBg"].Value := Round(usedPct)

            ; Details
            this.controls["usedLabel"].Text := "Used: " usedGB " GB (" usedPct "%)"
            this.controls["freeLabel"].Text := "Free: " freeGB " GB"
            this.controls["totalLabel"].Text := "Total: " totalGB " GB"
            return
        }
    }

    Show() {
        for key, ctrl in this.controls
            ctrl.Visible := true
    }

    Hide() {
        for key, ctrl in this.controls
            ctrl.Visible := false
    }
}
