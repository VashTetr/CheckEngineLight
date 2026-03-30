class DiskSpaceCheck {
    checkName := "Disk Space"
    warningPercent := 10
    criticalPercent := 5

    __New(configManager) {
        this.warningPercent := configManager.Get("WarningPercent", 10)
        this.criticalPercent := configManager.Get("CriticalPercent", 5)
    }

    Run() {
        results := []
        driveList := DriveGetList("FIXED")

        Loop Parse, driveList {
            driveLetter := A_LoopField ":"
            try {
                totalSize := DriveGetCapacity(driveLetter)
                freeSpace := DriveGetSpaceFree(driveLetter)

                if (totalSize <= 0)
                    continue

                freePercent := Round((freeSpace / totalSize) * 100, 1)

                status := "OK"
                if (freePercent <= this.criticalPercent)
                    status := "CRITICAL"
                else if (freePercent <= this.warningPercent)
                    status := "WARNING"

                results.Push(Map(
                    "type", "disk",
                    "drive", driveLetter,
                    "freeSpace", freeSpace,
                    "totalSize", totalSize,
                    "freePercent", freePercent,
                    "status", status
                ))
            } catch {
                ; Drive not ready or inaccessible, skip it
            }
        }
        return results
    }
}
