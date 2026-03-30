class TestRunner {
    tests := []
    passed := 0
    failed := 0
    results := []

    Register(name, fn) {
        this.tests.Push(Map("name", name, "fn", fn))
    }

    RunAll() {
        this.passed := 0
        this.failed := 0
        this.results := []

        for test in this.tests {
            try {
                msg := test["fn"].Call()
                this.passed++
                this.results.Push(Map("name", test["name"], "status", "PASS", "msg", msg != "" ? msg : ""))
            } catch as err {
                this.failed++
                this.results.Push(Map("name", test["name"], "status", "FAIL", "msg", err.Message))
            }
        }
        return this.results
    }

    GetSummary() {
        total := this.passed + this.failed
        summary := "Test Results: " this.passed "/" total " passed"
        if (this.failed > 0)
            summary .= " (" this.failed " FAILED)"
        summary .= "`n`n"

        for result in this.results {
            icon := result["status"] == "PASS" ? "✅" : "❌"
            summary .= icon " " result["name"]
            if (result["msg"] != "")
                summary .= " — " result["msg"]
            summary .= "`n"
        }
        return summary
    }
}

Assert(condition, msg := "Assertion failed") {
    if (!condition)
        throw Error(msg)
}
