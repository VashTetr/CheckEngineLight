class TestNetworkCheck {
    static Register(runner) {
        runner.Register("Network: returns results array", ObjBindMethod(this, "TestReturnsArray"))
        runner.Register("Network: results have required fields", ObjBindMethod(this, "TestResultFields"))
        runner.Register("Network: status is valid value", ObjBindMethod(this, "TestValidStatus"))
        runner.Register("Network: disabled returns empty", ObjBindMethod(this, "TestDisabled"))
        runner.Register("Network: result type is network", ObjBindMethod(this, "TestResultType"))
        runner.Register("Network: [INFO] connectivity status", ObjBindMethod(this, "TestShowInfo"))
    }

    static _MakeConfig() {
        return ConfigManager(A_ScriptDir "\..\config.ini")
    }

    static TestReturnsArray() {
        check := NetworkCheck(this._MakeConfig())
        results := check.Run()
        Assert(Type(results) == "Array", "Expected Array, got " Type(results))
    }

    static TestResultFields() {
        check := NetworkCheck(this._MakeConfig())
        results := check.Run()
        Assert(results.Length > 0, "Expected at least one result")
        r := results[1]
        Assert(r.Has("type"), "Missing 'type'")
        Assert(r.Has("status"), "Missing 'status'")
        Assert(r.Has("message"), "Missing 'message'")
        Assert(r.Has("connected"), "Missing 'connected'")
    }

    static TestValidStatus() {
        check := NetworkCheck(this._MakeConfig())
        results := check.Run()
        for r in results {
            s := r["status"]
            Assert(s == "OK" || s == "WARNING" || s == "CRITICAL", "Invalid status: " s)
        }
    }

    static TestDisabled() {
        tempPath := A_Temp "\checkengine_test_net.ini"
        tempConfig := "[Network]`nEnabled=0`n"
        if FileExist(tempPath)
            FileDelete(tempPath)
        FileAppend(tempConfig, tempPath)
        cfg := ConfigManager(tempPath)
        check := NetworkCheck(cfg)
        results := check.Run()
        Assert(results.Length == 0, "Disabled should return empty")
        FileDelete(tempPath)
    }

    static TestResultType() {
        check := NetworkCheck(this._MakeConfig())
        results := check.Run()
        for r in results
            Assert(r["type"] == "network", "Expected 'network', got '" r["type"] "'")
    }

    static TestShowInfo() {
        check := NetworkCheck(this._MakeConfig())
        results := check.Run()
        return results[1]["message"]
    }
}
