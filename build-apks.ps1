$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    # Each APK contains only one CPU architecture, reducing download size.
    & flutter build apk --release --split-per-abi
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter APK build failed (exit code $LASTEXITCODE)."
    }
    Get-ChildItem -LiteralPath 'build/app/outputs/flutter-apk' -Filter 'app-*-release.apk' |
        Select-Object Name, @{Name='SizeMiB'; Expression={[math]::Round($_.Length / 1MB, 2)}}, FullName
} finally {
    Pop-Location
}
