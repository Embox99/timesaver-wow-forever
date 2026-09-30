# Local build: packs the addon into dist\QuickToggle-<version>.zip.
# Releases to CurseForge are built by GitHub Actions (.github\workflows\release.yml);
# this script is for testing the same package by hand.
$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$addon = "QuickToggle"
# files that ship in the zip; keep in sync with the ignore list in .pkgmeta
$files = @("QuickToggle.toc", "Locales.lua", "Core.lua", "UI.lua", "LICENSE", "CHANGELOG.md")

# same version the packager would use: latest tag, or "dev" without tags
$version = (git -C $root describe --tags --always 2>$null)
if (-not $version) { $version = "dev" }

$dist = Join-Path $root "dist"
$stage = Join-Path $dist $addon
$zip = Join-Path $dist "$addon-$version.zip"

if (Test-Path $stage) { Remove-Item -Recurse -Force -Confirm:$false $stage }
if (Test-Path $zip) { Remove-Item -Force -Confirm:$false $zip }
New-Item -ItemType Directory -Force $stage | Out-Null

foreach ($f in $files) { Copy-Item (Join-Path $root $f) $stage }

$toc = Join-Path $stage "$addon.toc"
$text = [IO.File]::ReadAllText($toc).Replace("@project-version@", $version)
[IO.File]::WriteAllText($toc, $text, (New-Object Text.UTF8Encoding $false))

# Compress-Archive in PowerShell 5.1 writes "\" into entry names, which breaks
# unpacking on macOS/Linux, so entries are added by hand with "/".
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::Open($zip, "Create")
try {
    Get-ChildItem $stage -File | ForEach-Object {
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $_.FullName, "$addon/$($_.Name)") | Out-Null
    }
} finally {
    $archive.Dispose()
}
Remove-Item -Recurse -Force -Confirm:$false $stage

Write-Host "Built $zip"
