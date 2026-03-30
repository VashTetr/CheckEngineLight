class ConfigManager {
    configPath := ""
    settings := Map()

    __New(configPath) {
        this.configPath := configPath
        this._EnsureDefaults()
        this._Load()
    }

    _EnsureDefaults() {
        if !FileExist(this.configPath) {
            defaultConfig := ""
            defaultConfig .= "[General]`n"
            defaultConfig .= "CheckIntervalMinutes=10`n"
            defaultConfig .= "`n"
            defaultConfig .= "[DiskSpace]`n"
            defaultConfig .= "WarningPercent=10`n"
            defaultConfig .= "CriticalPercent=5`n"
            defaultConfig .= "`n"
            defaultConfig .= "[ChipsetDriver]`n"
            defaultConfig .= "Enabled=1`n"
            defaultConfig .= "MaxDriverAgeMonths=9`n"
            defaultConfig .= "`n"
            defaultConfig .= "[GPUDriver]`n"
            defaultConfig .= "Enabled=1`n"
            defaultConfig .= "MaxDriverAgeMonths=6`n"
            defaultConfig .= "`n"
            defaultConfig .= "[RAM]`n"
            defaultConfig .= "Enabled=1`n"
            defaultConfig .= "CheckIntervalSeconds=5`n"
            defaultConfig .= "WarningPercent=85`n"
            defaultConfig .= "CriticalPercent=95`n"
            defaultConfig .= "`n"
            defaultConfig .= "[Network]`n"
            defaultConfig .= "Enabled=1`n"
            defaultConfig .= "`n"
            defaultConfig .= "[WindowsUpdate]`n"
            defaultConfig .= "Enabled=1`n"
            defaultConfig .= "CheckIntervalHours=8`n"
            FileAppend(defaultConfig, this.configPath)
        }
    }

    _Load() {
        this.settings["CheckIntervalMinutes"] := Integer(IniRead(this.configPath, "General", "CheckIntervalMinutes", "10"))
        this.settings["WarningPercent"] := Integer(IniRead(this.configPath, "DiskSpace", "WarningPercent", "10"))
        this.settings["CriticalPercent"] := Integer(IniRead(this.configPath, "DiskSpace", "CriticalPercent", "5"))
        this.settings["ChipsetDriverEnabled"] := Integer(IniRead(this.configPath, "ChipsetDriver", "Enabled", "1"))
        this.settings["ChipsetDriverMaxAgeMonths"] := Integer(IniRead(this.configPath, "ChipsetDriver", "MaxDriverAgeMonths", "6"))
        this.settings["GPUDriverEnabled"] := Integer(IniRead(this.configPath, "GPUDriver", "Enabled", "1"))
        this.settings["GPUDriverMaxAgeMonths"] := Integer(IniRead(this.configPath, "GPUDriver", "MaxDriverAgeMonths", "6"))
        this.settings["RAMEnabled"] := Integer(IniRead(this.configPath, "RAM", "Enabled", "1"))
        this.settings["RAMCheckIntervalSeconds"] := Integer(IniRead(this.configPath, "RAM", "CheckIntervalSeconds", "5"))
        this.settings["RAMWarningPercent"] := Integer(IniRead(this.configPath, "RAM", "WarningPercent", "85"))
        this.settings["RAMCriticalPercent"] := Integer(IniRead(this.configPath, "RAM", "CriticalPercent", "95"))
        this.settings["NetworkEnabled"] := Integer(IniRead(this.configPath, "Network", "Enabled", "1"))
        this.settings["WindowsUpdateEnabled"] := Integer(IniRead(this.configPath, "WindowsUpdate", "Enabled", "1"))
        this.settings["WindowsUpdateCheckIntervalHours"] := Integer(IniRead(this.configPath, "WindowsUpdate", "CheckIntervalHours", "8"))
    }

    Get(key, default := "") {
        return this.settings.Has(key) ? this.settings[key] : default
    }

    Set(key, value) {
        this.settings[key] := value
    }

    Save() {
        IniWrite(this.settings["CheckIntervalMinutes"], this.configPath, "General", "CheckIntervalMinutes")
        IniWrite(this.settings["WarningPercent"], this.configPath, "DiskSpace", "WarningPercent")
        IniWrite(this.settings["CriticalPercent"], this.configPath, "DiskSpace", "CriticalPercent")
        IniWrite(this.settings["ChipsetDriverEnabled"], this.configPath, "ChipsetDriver", "Enabled")
        IniWrite(this.settings["ChipsetDriverMaxAgeMonths"], this.configPath, "ChipsetDriver", "MaxDriverAgeMonths")
        IniWrite(this.settings["GPUDriverEnabled"], this.configPath, "GPUDriver", "Enabled")
        IniWrite(this.settings["GPUDriverMaxAgeMonths"], this.configPath, "GPUDriver", "MaxDriverAgeMonths")
        IniWrite(this.settings["RAMEnabled"], this.configPath, "RAM", "Enabled")
        IniWrite(this.settings["RAMCheckIntervalSeconds"], this.configPath, "RAM", "CheckIntervalSeconds")
        IniWrite(this.settings["RAMWarningPercent"], this.configPath, "RAM", "WarningPercent")
        IniWrite(this.settings["RAMCriticalPercent"], this.configPath, "RAM", "CriticalPercent")
        IniWrite(this.settings["NetworkEnabled"], this.configPath, "Network", "Enabled")
        IniWrite(this.settings["WindowsUpdateEnabled"], this.configPath, "WindowsUpdate", "Enabled")
        IniWrite(this.settings["WindowsUpdateCheckIntervalHours"], this.configPath, "WindowsUpdate", "CheckIntervalHours")
    }

    Reload() {
        this._Load()
    }

    GetSnapshot() {
        ; Returns a copy of current settings for reset functionality
        snapshot := Map()
        for key, val in this.settings
            snapshot[key] := val
        return snapshot
    }

    RestoreSnapshot(snapshot) {
        for key, val in snapshot
            this.settings[key] := val
    }
}
