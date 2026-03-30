class ThemeManager {
    ; Discord/Kiro-style dark theme
    static BgDark := "1E1E1E"
    static BgSidebar := "2B2B2B"
    static BgContent := "252526"
    static BgCard := "2D2D30"
    static BgCardHover := "3E3E42"
    static TextPrimary := "E0E0E0"
    static TextSecondary := "A0A0A0"
    static TextMuted := "6E6E6E"
    static Accent := "4FC3F7"
    static StatusOK := "4CAF50"
    static StatusWarn := "FFC107"
    static StatusCrit := "F44336"
    static ProgressBg := "3E3E42"
    static SidebarActive := "37373D"
    static Border := "3E3E42"

    static Apply(guiObj) {
        guiObj.BackColor := this.BgDark
    }
}
