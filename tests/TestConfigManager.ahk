class TestConfigManager {
    static Register(runner) {
        runner.Register("Config: loads default interval", ObjBindMethod(this, "TestDefaultInterval"))
        runner.Register("Config: loads default warning percent", ObjBindMethod(this, "TestDefaultWarning"))
        runner.Register("Config: loads default critical percent", ObjBindMethod(this, "TestDefaultCritical"))
        runner.Register("Config: Get returns default for missing key", ObjBindMethod(this, "TestMissingKey"))
        runner.Register("Config: creates config file if missing", ObjBindMethod(this, "TestCreatesFile"))
    }

    static TestDefaultInterval() {
        cfg := ConfigManager(A_ScriptDir "\..\config.ini")
        Assert(cfg.Get("CheckIntervalMinutes") == 10, "Expected 10, got " cfg.Get("CheckIntervalMinutes"))
    }

    static TestDefaultWarning() {
        cfg := ConfigManager(A_ScriptDir "\..\config.ini")
        Assert(cfg.Get("WarningPercent") == 10, "Expected 10, got " cfg.Get("WarningPercent"))
    }

    static TestDefaultCritical() {
        cfg := ConfigManager(A_ScriptDir "\..\config.ini")
        Assert(cfg.Get("CriticalPercent") == 5, "Expected 5, got " cfg.Get("CriticalPercent"))
    }

    static TestMissingKey() {
        cfg := ConfigManager(A_ScriptDir "\..\config.ini")
        result := cfg.Get("NonExistentKey", "fallback")
        Assert(result == "fallback", "Expected 'fallback', got '" result "'")
    }

    static TestCreatesFile() {
        tempPath := A_Temp "\checkengine_test_config.ini"
        if FileExist(tempPath)
            FileDelete(tempPath)
        cfg := ConfigManager(tempPath)
        Assert(FileExist(tempPath), "Config file was not created")
        FileDelete(tempPath)
    }
}
