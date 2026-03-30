class StatusTab {
    controls := Map()
    gui := ""
    imgDir := ""
    contentX := 0
    contentY := 0
    contentW := 0

    __New(gui, imgDir, contentX, contentY, contentW) {
        this.gui := gui
        this.imgDir := imgDir
        this.contentX := contentX
        this.contentY := contentY
        this.contentW := contentW
    }

    Create() {
        g := this.gui
        x := this.contentX + 20
        y := this.contentY + 15
        w := this.contentW - 40

        this.controls["title"] := g.Add("Text", "x" x " y" y " w" w " h30 Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent, "Status Overview")
        this.controls["title"].SetFont("s16 bold", "Segoe UI")

        imgSize := 96
        imgX := x + w - imgSize
        ; Background panel behind the image so transparency matches content color
        this.controls["engineImgBg"] := g.Add("Text", "x" imgX " y" y " w" imgSize " h" imgSize " Hidden Background" ThemeManager.BgContent)
        this.controls["engineImg"] := g.Add("Picture", "x" imgX " y" y " w" imgSize " h" imgSize " Hidden BackgroundTrans", this.imgDir "\black_mkl.png")

        rowY := y + 50
        rowH := 40
        labelW := w - imgSize - 20

        this.controls["drivesLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Drives: --")
        this.controls["drivesLabel"].SetFont("s12", "Segoe UI")
        rowY += rowH + 5

        this.controls["chipsetLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "CPU Chipset: --")
        this.controls["chipsetLabel"].SetFont("s12", "Segoe UI")
        rowY += rowH + 5

        this.controls["gpuLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "GPU Driver: --")
        this.controls["gpuLabel"].SetFont("s12", "Segoe UI")
        rowY += rowH + 5

        this.controls["ramLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "RAM: --")
        this.controls["ramLabel"].SetFont("s12", "Segoe UI")
        rowY += rowH + 5

        this.controls["networkLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Network: --")
        this.controls["networkLabel"].SetFont("s12", "Segoe UI")
        rowY += rowH + 5

        this.controls["winupdateLabel"] := g.Add("Text", "x" x " y" rowY " w" labelW " h" rowH " Hidden c" ThemeManager.TextPrimary " Background" ThemeManager.BgContent " 0x200", "Windows Update: --")
        this.controls["winupdateLabel"].SetFont("s12", "Segoe UI")
    }

    Update(results) {
        driveStatus := "OK"
        chipsetStatus := "OK"
        gpuStatus := "OK"
        ramStatus := "OK"
        networkStatus := "OK"
        winupdateStatus := "OK"
        driveMsg := ""
        chipsetMsg := ""
        gpuMsg := ""
        ramMsg := ""
        networkMsg := ""
        winupdateMsg := ""

        for r in results {
            rType := r.Has("type") ? r["type"] : "disk"
            if (rType == "disk") {
                if (r["status"] == "CRITICAL") {
                    driveStatus := "CRITICAL"
                    driveMsg := r["drive"] " " r["freePercent"] "% free"
                } else if (r["status"] == "WARNING" && driveStatus != "CRITICAL") {
                    driveStatus := "WARNING"
                    driveMsg := r["drive"] " " r["freePercent"] "% free"
                }
            } else if (rType == "chipset") {
                chipsetStatus := r["status"]
                chipsetMsg := r["message"]
            } else if (rType == "gpu") {
                gpuStatus := r["status"]
                gpuMsg := r["message"]
            } else if (rType == "ram") {
                ramStatus := r["status"]
                ramMsg := r["message"]
            } else if (rType == "network") {
                networkStatus := r["status"]
                networkMsg := r["message"]
            } else if (rType == "winupdate") {
                winupdateStatus := r["status"]
                winupdateMsg := r["message"]
            }
        }

        this._SetStatusLabel("drivesLabel", "Drives", driveStatus, driveMsg)
        this._SetStatusLabel("chipsetLabel", "CPU Chipset", chipsetStatus, chipsetMsg)
        this._SetStatusLabel("gpuLabel", "GPU Driver", gpuStatus, gpuMsg)
        this._SetStatusLabel("ramLabel", "RAM", ramStatus, ramMsg)
        this._SetStatusLabel("networkLabel", "Network", networkStatus, networkMsg)
        this._SetStatusLabel("winupdateLabel", "Windows Update", winupdateStatus, winupdateMsg)

        worst := "OK"
        for s in [driveStatus, chipsetStatus, gpuStatus, ramStatus, networkStatus, winupdateStatus] {
            if (s == "CRITICAL")
                worst := "CRITICAL"
            else if (s == "WARNING" && worst != "CRITICAL")
                worst := "WARNING"
        }
        imgFile := "black_mkl.png"
        switch worst {
            case "OK": imgFile := "green_mkl.png"
            case "WARNING": imgFile := "yellow_mkl.png"
            case "CRITICAL": imgFile := "red_mkl.png"
        }
        try this.controls["engineImg"].Value := this.imgDir "\" imgFile
    }

    _SetStatusLabel(key, name, status, msg) {
        color := ThemeManager.StatusOK
        symbol := "✓"
        if (status == "WARNING") {
            color := ThemeManager.StatusWarn
            symbol := "⚠"
        } else if (status == "CRITICAL") {
            color := ThemeManager.StatusCrit
            symbol := "✗"
        }
        text := symbol " " name ": " status
        if (msg != "")
            text .= " — " msg
        try {
            this.controls[key].Text := text
            this.controls[key].Opt("c" color)
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
