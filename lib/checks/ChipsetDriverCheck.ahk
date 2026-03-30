class ChipsetDriverCheck {
    checkName := "CPU Chipset"
    maxAgeMonths := 9
    enabled := true
    lastDriverList := []

    __New(configManager) {
        this.enabled := configManager.Get("ChipsetDriverEnabled", 1)
        this.maxAgeMonths := configManager.Get("ChipsetDriverMaxAgeMonths", 9)
    }

    Run() {
        results := []
        if (!this.enabled)
            return results

        try {
            allDrivers := this._GetAllChipsetDrivers()
            this.lastDriverList := allDrivers

            if (allDrivers.Length == 0)
                return results

            ; Find the oldest driver
            oldestDriver := false
            oldestAge := -1

            for drv in allDrivers {
                age := this._GetDriverAgeMonths(drv["date"])
                if (age > oldestAge) {
                    oldestAge := age
                    oldestDriver := drv
                }
            }

            if (!oldestDriver)
                return results

            dateStr := this._FormatWmiDate(oldestDriver["date"])

            if (oldestAge >= this.maxAgeMonths) {
                results.Push(Map(
                    "type", "chipset",
                    "label", "Chipset Driver",
                    "detail", oldestDriver["name"],
                    "version", oldestDriver["version"],
                    "driverDate", oldestDriver["date"],
                    "dateStr", dateStr,
                    "ageMonths", oldestAge,
                    "driverCount", allDrivers.Length,
                    "status", "WARNING",
                    "message", oldestDriver["name"] " is " Round(oldestAge) "mo old (" dateStr ")"
                ))
            } else {
                ; All drivers are within threshold — report newest for a positive message
                newestDriver := false
                newestAge := 999
                for drv in allDrivers {
                    age := this._GetDriverAgeMonths(drv["date"])
                    if (age < newestAge) {
                        newestAge := age
                        newestDriver := drv
                    }
                }
                newestDate := this._FormatWmiDate(newestDriver["date"])
                results.Push(Map(
                    "type", "chipset",
                    "label", "Chipset Driver",
                    "detail", newestDriver["name"],
                    "version", newestDriver["version"],
                    "driverDate", newestDriver["date"],
                    "dateStr", newestDate,
                    "ageMonths", newestAge,
                    "driverCount", allDrivers.Length,
                    "status", "OK",
                    "message", allDrivers.Length " drivers OK (newest: " newestDate ")"
                ))
            }
        } catch as err {
            results.Push(Map(
                "type", "chipset",
                "label", "Chipset Driver",
                "status", "OK",
                "message", "Could not check: " err.Message
            ))
        }
        return results
    }

    _GetAllChipsetDrivers() {
        allDrivers := []

        wmi := ComObject("WbemScripting.SWbemLocator")
        service := wmi.ConnectServer(".", "root\cimv2")

        query := "SELECT DeviceName, DriverVersion, DriverDate, DriverProviderName "
            . "FROM Win32_PnPSignedDriver "
            . "WHERE ("
            . "DriverProviderName LIKE '%AMD%' OR "
            . "DriverProviderName LIKE '%Advanced Micro Devices%' OR "
            . "DriverProviderName LIKE '%Intel%' OR "
            . "DriverProviderName LIKE '%Qualcomm%'"
            . ") AND ("
            . "DeviceName LIKE '%chipset%' OR "
            . "DeviceName LIKE '%SMBus%' OR "
            . "DeviceName LIKE '%GPIO%' OR "
            . "DeviceName LIKE '%PSP%' OR "
            . "DeviceName LIKE '%I2C%' OR "
            . "DeviceName LIKE '%Host Bridge%' OR "
            . "DeviceName LIKE '%PCI Express%' OR "
            . "DeviceName LIKE '%SPI%' OR "
            . "DeviceName LIKE '%IOMMU%'"
            . ")"

        drivers := service.ExecQuery(query)

        enum := drivers._NewEnum()
        while enum(&driver) {
            driverName := ""
            driverVersion := ""
            driverDate := ""
            driverProvider := ""
            try driverName := driver.DeviceName
            try driverVersion := driver.DriverVersion
            try driverDate := driver.DriverDate
            try driverProvider := driver.DriverProviderName

            if (driverName == "" || driverDate == "")
                continue

            allDrivers.Push(Map(
                "name", driverName,
                "version", driverVersion,
                "date", driverDate,
                "provider", driverProvider
            ))
        }

        return allDrivers
    }

    _GetDriverAgeMonths(wmiDate) {
        if (StrLen(wmiDate) < 8)
            return 0

        year := Integer(SubStr(wmiDate, 1, 4))
        month := Integer(SubStr(wmiDate, 5, 2))
        day := Integer(SubStr(wmiDate, 7, 2))

        nowYear := Integer(A_Year)
        nowMonth := Integer(A_Mon)
        nowDay := Integer(A_MDay)

        ageMonths := (nowYear - year) * 12 + (nowMonth - month)
        if (nowDay < day)
            ageMonths -= 1

        return Max(0, ageMonths)
    }

    _FormatWmiDate(wmiDate) {
        if (StrLen(wmiDate) < 8)
            return "Unknown"

        year := SubStr(wmiDate, 1, 4)
        month := SubStr(wmiDate, 5, 2)
        day := SubStr(wmiDate, 7, 2)

        months := Map(
            "01", "Jan", "02", "Feb", "03", "Mar", "04", "Apr",
            "05", "May", "06", "Jun", "07", "Jul", "08", "Aug",
            "09", "Sep", "10", "Oct", "11", "Nov", "12", "Dec"
        )

        monthName := months.Has(month) ? months[month] : month
        return monthName " " day ", " year
    }
}
