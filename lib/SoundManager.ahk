class SoundManager {
    lastState := "IDLE"

    PlayIfChanged(newState) {
        if (newState == this.lastState)
            return

        this.lastState := newState

        if (newState == "CRITICAL")
            SoundPlay("*16")  ; Windows error sound
        else if (newState == "WARNING")
            SoundPlay("*64")  ; Windows notification sound
        ; OK and IDLE = no sound
    }

    Reset() {
        this.lastState := "IDLE"
    }
}
