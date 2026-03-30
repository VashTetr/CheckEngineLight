class TestSoundManager {
    static Register(runner) {
        runner.Register("Sound: initial state is IDLE", ObjBindMethod(this, "TestInitialState"))
        runner.Register("Sound: state updates after play", ObjBindMethod(this, "TestStateUpdates"))
        runner.Register("Sound: no repeat on same state", ObjBindMethod(this, "TestNoRepeat"))
        runner.Register("Sound: reset returns to IDLE", ObjBindMethod(this, "TestReset"))
    }

    static TestInitialState() {
        sm := SoundManager()
        Assert(sm.lastState == "IDLE", "Initial state should be IDLE, got " sm.lastState)
    }

    static TestStateUpdates() {
        sm := SoundManager()
        sm.PlayIfChanged("OK")
        Assert(sm.lastState == "OK", "State should be OK after playing, got " sm.lastState)
    }

    static TestNoRepeat() {
        sm := SoundManager()
        sm.PlayIfChanged("WARNING")
        ; Call again with same state — should not error or change behavior
        sm.PlayIfChanged("WARNING")
        Assert(sm.lastState == "WARNING", "State should still be WARNING")
    }

    static TestReset() {
        sm := SoundManager()
        sm.PlayIfChanged("CRITICAL")
        sm.Reset()
        Assert(sm.lastState == "IDLE", "State should be IDLE after reset, got " sm.lastState)
    }
}
