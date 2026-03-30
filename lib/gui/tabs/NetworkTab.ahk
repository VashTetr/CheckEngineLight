class NetworkTab {
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

        this.controls["title"] := g.Add("Text", "x" x " y" y " w" w " h30 Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent, "Network")
        this.controls["title"].SetFont("s16 bold", "Segoe UI")

        this.controls["status"] := g.Add("Text", "x" x " y" (y + 50) " w" w " h30 Hidden c" ThemeManager.TextSecondary " Background" ThemeManager.BgContent, "Waiting for scan...")
        this.controls["status"].SetFont("s14", "Segoe UI")
    }

    Update(results) {
        for r in results {
            if (r.Has("type") && r["type"] == "network") {
                color := ThemeManager.StatusOK
                if (r["status"] == "CRITICAL")
                    color := ThemeManager.StatusCrit
                else if (r["status"] == "WARNING")
                    color := ThemeManager.StatusWarn

                this.controls["status"].Text := r["message"]
                this.controls["status"].Opt("c" color)
                return
            }
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
