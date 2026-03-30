class WindowsUpdateTab {
    controls := Map()
    updateRows := []
    gui := ""
    contentX := 0
    contentY := 0
    contentW := 0
    maxUpdates := 12
    activeUpdateCount := 0

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

        this.controls["title"] := g.Add("Text", "x" x " y" y " w" w " h30 Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent, "Windows Update")
        this.controls["title"].SetFont("s16 bold", "Segoe UI")

        this.controls["summary"] := g.Add("Text", "x" x " y" (y + 40) " w" w " h25 Hidden c" ThemeManager.TextSecondary " Background" ThemeManager.BgContent, "Waiting for scan...")
        this.controls["summary"].SetFont("s10", "Segoe UI")

        rowY := y + 75
        rowSpacing := 28

        Loop this.maxUpdates {
            row := Map()
            row["label"] := g.Add("Text", "x" x " y" rowY " w" w " h24 Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "")
            row["label"].SetFont("s9", "Segoe UI")
            this.updateRows.Push(row)
            rowY += rowSpacing
        }
    }

    Update(results) {
        for r in results {
            if (!r.Has("type") || r["type"] != "winupdate")
                continue

            color := ThemeManager.StatusOK
            if (r["status"] == "CRITICAL")
                color := ThemeManager.StatusCrit
            else if (r["status"] == "WARNING")
                color := ThemeManager.StatusWarn

            this.controls["summary"].Text := r["message"]
            this.controls["summary"].Opt("c" color)
            return
        }
    }

    SetUpdateDetails(updateList) {
        this.activeUpdateCount := updateList.Length

        Loop this.maxUpdates {
            i := A_Index
            row := this.updateRows[i]
            if (i <= updateList.Length) {
                upd := updateList[i]
                sevColor := ThemeManager.TextPrimary
                if (upd["severity"] == "Critical")
                    sevColor := ThemeManager.StatusCrit
                else if (upd["severity"] == "Important")
                    sevColor := ThemeManager.StatusWarn

                row["label"].Text := "[" upd["severity"] "] " upd["title"]
                row["label"].Opt("c" sevColor)
            } else {
                row["label"].Text := ""
            }
        }
    }

    Show() {
        this.controls["title"].Visible := true
        this.controls["summary"].Visible := true
        Loop this.maxUpdates {
            i := A_Index
            this.updateRows[i]["label"].Visible := (i <= this.activeUpdateCount)
        }
    }

    Hide() {
        this.controls["title"].Visible := false
        this.controls["summary"].Visible := false
        for row in this.updateRows
            row["label"].Visible := false
    }
}
