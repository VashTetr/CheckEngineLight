class ChipsetTab {
    controls := Map()
    driverRows := []
    gui := ""
    contentX := 0
    contentY := 0
    contentW := 0
    maxDrivers := 10
    cachedDrivers := []
    activeDriverCount := 0

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

        this.controls["title"] := g.Add("Text", "x" x " y" y " w" w " h30 Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent, "CPU Chipset Drivers")
        this.controls["title"].SetFont("s16 bold", "Segoe UI")

        this.controls["summary"] := g.Add("Text", "x" x " y" (y + 40) " w" w " h25 Hidden c" ThemeManager.TextSecondary " Background" ThemeManager.BgContent, "Waiting for scan...")
        this.controls["summary"].SetFont("s10", "Segoe UI")

        rowY := y + 75
        rowSpacing := 35

        Loop this.maxDrivers {
            row := Map()
            row["label"] := g.Add("Text", "x" x " y" rowY " w" w " h28 Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "")
            row["label"].SetFont("s9", "Segoe UI")
            this.driverRows.Push(row)
            rowY += rowSpacing
        }
    }

    Update(results) {
        status := "OK"
        driverCount := 0
        message := ""

        for r in results {
            rType := r.Has("type") ? r["type"] : "disk"
            if (rType == "chipset") {
                status := r["status"]
                message := r.Has("message") ? r["message"] : ""
                driverCount := r.Has("driverCount") ? r["driverCount"] : 0
            }
        }

        color := ThemeManager.StatusOK
        if (status == "WARNING")
            color := ThemeManager.StatusWarn
        else if (status == "CRITICAL")
            color := ThemeManager.StatusCrit

        if (driverCount > 0)
            this.controls["summary"].Text := driverCount " chipset driver(s) — " status ": " message
        else
            this.controls["summary"].Text := "Chipset: " message

        this.controls["summary"].Opt("c" color)
    }

    SetDriverDetails(allDrivers, maxAgeMonths) {
        this.cachedDrivers := allDrivers
        this.activeDriverCount := allDrivers.Length

        Loop this.maxDrivers {
            i := A_Index
            row := this.driverRows[i]
            if (i <= allDrivers.Length) {
                drv := allDrivers[i]
                age := this._GetAge(drv["date"])
                dateStr := this._FormatDate(drv["date"])
                drvColor := (age >= maxAgeMonths) ? ThemeManager.StatusWarn : ThemeManager.TextPrimary
                row["label"].Text := drv["name"] "  v" drv["version"] "  (" dateStr ", " Round(age) " months)"
                row["label"].Opt("c" drvColor)
            } else {
                row["label"].Text := ""
            }
        }
    }

    _GetAge(wmiDate) {
        if (StrLen(wmiDate) < 8)
            return 0
        year := Integer(SubStr(wmiDate, 1, 4))
        month := Integer(SubStr(wmiDate, 5, 2))
        day := Integer(SubStr(wmiDate, 7, 2))
        ageMonths := (Integer(A_Year) - year) * 12 + (Integer(A_Mon) - month)
        if (Integer(A_MDay) < day)
            ageMonths -= 1
        return Max(0, ageMonths)
    }

    _FormatDate(wmiDate) {
        if (StrLen(wmiDate) < 8)
            return "Unknown"
        months := Map("01","Jan","02","Feb","03","Mar","04","Apr","05","May","06","Jun","07","Jul","08","Aug","09","Sep","10","Oct","11","Nov","12","Dec")
        m := SubStr(wmiDate, 5, 2)
        return (months.Has(m) ? months[m] : m) " " SubStr(wmiDate, 7, 2) ", " SubStr(wmiDate, 1, 4)
    }

    Show() {
        this.controls["title"].Visible := true
        this.controls["summary"].Visible := true
        Loop this.maxDrivers {
            i := A_Index
            this.driverRows[i]["label"].Visible := (i <= this.activeDriverCount)
        }
    }

    Hide() {
        this.controls["title"].Visible := false
        this.controls["summary"].Visible := false
        for row in this.driverRows
            row["label"].Visible := false
    }
}
