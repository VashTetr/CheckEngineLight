class DrivesTab {
    controls := Map()
    driveRows := []
    gui := ""
    contentX := 0
    contentY := 0
    contentW := 0
    maxDrives := 8
    activeDriveCount := 0

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

        this.controls["title"] := g.Add("Text", "x" x " y" y " w" w " h30 Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent, "Drives")
        this.controls["title"].SetFont("s16 bold", "Segoe UI")

        rowY := y + 45
        barH := 18
        rowSpacing := 60

        Loop this.maxDrives {
            row := Map()
            row["label"] := g.Add("Text", "x" x " y" rowY " w" w " h20 Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent, "")
            row["label"].SetFont("s10", "Segoe UI")

            barY := rowY + 24
            row["barBg"] := g.Add("Progress", "x" x " y" barY " w" w " h" barH " Hidden Background" ThemeManager.ProgressBg " c" ThemeManager.StatusOK " Range0-100", 0)

            this.driveRows.Push(row)
            rowY += rowSpacing
        }
    }

    Update(results) {
        driveResults := []
        for r in results {
            rType := r.Has("type") ? r["type"] : "disk"
            if (rType == "disk")
                driveResults.Push(r)
        }

        this.activeDriveCount := driveResults.Length

        Loop this.maxDrives {
            i := A_Index
            row := this.driveRows[i]

            if (i <= driveResults.Length) {
                dr := driveResults[i]
                usedPercent := Round(100 - dr["freePercent"], 1)
                freeGB := Round(dr["freeSpace"] / 1024, 1)
                totalGB := Round(dr["totalSize"] / 1024, 1)

                row["label"].Text := dr["drive"] " — " dr["freePercent"] "% free (" freeGB " / " totalGB " GB)"

                barColor := ThemeManager.StatusOK
                if (dr["status"] == "WARNING")
                    barColor := ThemeManager.StatusWarn
                else if (dr["status"] == "CRITICAL")
                    barColor := ThemeManager.StatusCrit

                row["barBg"].Opt("c" barColor)
                row["barBg"].Value := usedPercent
            } else {
                row["label"].Text := ""
                row["barBg"].Value := 0
            }
        }
    }

    Show() {
        this.controls["title"].Visible := true
        Loop this.maxDrives {
            i := A_Index
            row := this.driveRows[i]
            visible := (i <= this.activeDriveCount)
            row["label"].Visible := visible
            row["barBg"].Visible := visible
        }
    }

    Hide() {
        this.controls["title"].Visible := false
        for row in this.driveRows {
            row["label"].Visible := false
            row["barBg"].Visible := false
        }
    }
}
