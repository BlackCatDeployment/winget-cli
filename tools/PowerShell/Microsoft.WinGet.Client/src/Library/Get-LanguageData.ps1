Function Get-LanguageData {
    PARAM(
        [Parameter(Position=0)] $Language = (Get-UICulture).Name.Substring(0,2)
    )

    $languageData = $(
        $hash = @{}

        $(try {
            # We have to trim the leading BOM for .NET's XML parser to correctly read Microsoft's own files - go figure
            $LgFolder = ((Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/tree/master/Localization/Resources").Links | ? {$_.innerText -like "$Language-[A-Z][A-Z]"})[0]            
            ([xml](((Invoke-WebRequest -Uri "https://raw.githubusercontent.com/microsoft/winget-cli/master/Localization/Resources/$($LgFolder.title)/winget.resw" -ErrorAction Stop).Content -replace "\uFEFF", ""))).root.data
        } catch {
            # Fall back to English if a locale file doesn't exist
            (
                ('SearchName','Name'),
                ('SearchID','Id'),
                ('SearchVersion','Version'),
                ('AvailableHeader','Available'),
                ('SearchSource','Source'),
                ('ShowVersion','Version'),
                ('GetManifestResultVersionNotFound','No version found matching:'),
                ('InstallerFailedWithCode','Installer failed with exit code:'),
                ('UninstallFailedWithCode','Uninstall failed with exit code:')
            ) | ForEach-Object {[pscustomobject]@{name = $_[0]; value = $_[1]}}
        }) | ForEach-Object {
            # Convert the array into a hashtable
            $hash[$_.name] = $_.value
        }

        $hash
    )

    return $languageData
}
