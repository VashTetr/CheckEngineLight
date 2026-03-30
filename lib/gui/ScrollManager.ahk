class ScrollManager {
    static scrollOffsets := Map()
    static scrollControls := Map()
    static activeTab := ""
    static contentY := 0
    static contentH := 0
    static scrollStep := 30

    static Init(contentY, contentH) {
        this.contentY := contentY
        this.contentH := contentH
    }

    static RegisterTab(tabName, controls, totalHeight) {
        this.scrollOffsets[tabName] := 0
        this.scrollControls[tabName] := Map(
            "controls", controls,
            "totalHeight", totalHeight
        )
    }

    static SetActiveTab(tabName) {
        this.activeTab := tabName
    }

    static OnWheel(gui, delta) {
        tabName := this.activeTab
        if (!this.scrollControls.Has(tabName))
            return

        tabData := this.scrollControls[tabName]
        totalH := tabData["totalHeight"]
        maxScroll := Max(0, totalH - this.contentH)

        if (maxScroll == 0)
            return  ; Content fits, no scrolling needed

        offset := this.scrollOffsets[tabName]

        ; delta > 0 = scroll up, delta < 0 = scroll down
        if (delta > 0)
            offset := Max(0, offset - this.scrollStep)
        else
            offset := Min(maxScroll, offset + this.scrollStep)

        if (offset == this.scrollOffsets[tabName])
            return  ; No change

        diff := this.scrollOffsets[tabName] - offset
        this.scrollOffsets[tabName] := offset

        ; Move all controls
        controls := tabData["controls"]
        for ctrl in controls {
            if (ctrl.Visible) {
                ctrl.GetPos(&cx, &cy)
                ctrl.Move(cx, cy + diff)
            }
        }

        ; Force redraw to prevent visual artifacts
        DllCall("InvalidateRect", "Ptr", gui.Hwnd, "Ptr", 0, "Int", 1)
    }

    static ResetScroll(tabName) {
        if (!this.scrollControls.Has(tabName))
            return

        offset := this.scrollOffsets.Has(tabName) ? this.scrollOffsets[tabName] : 0
        if (offset == 0)
            return

        controls := this.scrollControls[tabName]["controls"]
        for ctrl in controls {
            ctrl.GetPos(&cx, &cy)
            ctrl.Move(cx, cy + offset)
        }
        this.scrollOffsets[tabName] := 0
    }
}
