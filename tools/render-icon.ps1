# Renders the in-game clock icon: Media\icon.tga (128x128, 32-bit with alpha)
# plus Media\icon-preview.png to look at. The game masks it to a circle and
# draws its own status ring around it, so this is just a round watch face.
param([int]$Size = 128)
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$root = Split-Path $PSScriptRoot -Parent
$media = Join-Path $root "Media"
New-Item -ItemType Directory -Force $media | Out-Null

$S = $Size
$k = $S / 128.0  # everything below is drawn for 128 px and scaled
$bmp = New-Object System.Drawing.Bitmap $S, $S, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = "AntiAlias"
$g.PixelOffsetMode = "HighQuality"
$g.Clear([System.Drawing.Color]::Transparent)
$g.ScaleTransform($k, $k)

function C($a, $r, $gg, $b) { [System.Drawing.Color]::FromArgb($a, $r, $gg, $b) }
$cx = 64.0; $cy = 64.0

# gold case filling the whole circle
$gold = New-Object System.Drawing.Drawing2D.LinearGradientBrush (New-Object System.Drawing.PointF 0, 0), (New-Object System.Drawing.PointF 0, 128), (C 255 255 228 135), (C 255 160 104 26)
$g.FillEllipse($gold, 0, 0, 128, 128)
$g.FillEllipse((New-Object System.Drawing.SolidBrush (C 255 96 60 14)), 9, 9, 110, 110)

# dark face with a light center
$facePath = New-Object System.Drawing.Drawing2D.GraphicsPath
$facePath.AddEllipse(13, 13, 102, 102)
$face = New-Object System.Drawing.Drawing2D.PathGradientBrush $facePath
$face.CenterPoint = New-Object System.Drawing.PointF 58, 52
$face.CenterColor = C 255 46 52 70
$face.SurroundColors = @(C 255 12 13 19)
$g.FillPath($face, $facePath)

$ink = C 255 246 206 104

# four bold marks at 12, 3, 6, 9
for ($i = 0; $i -lt 4; $i++) {
    $a = $i * [Math]::PI / 2
    $p = New-Object System.Drawing.Pen $ink, 7
    $p.StartCap = "Round"; $p.EndCap = "Round"
    $r1 = 43; $r2 = 33
    $g.DrawLine($p, [float]($cx + $r1*[Math]::Sin($a)), [float]($cy - $r1*[Math]::Cos($a)), [float]($cx + $r2*[Math]::Sin($a)), [float]($cy - $r2*[Math]::Cos($a)))
}

# hands at 10:10
function Hand([double]$deg, [double]$len, [double]$w) {
    $a = $deg * [Math]::PI / 180
    $p = New-Object System.Drawing.Pen $ink, $w
    $p.StartCap = "Round"; $p.EndCap = "Round"
    $g.DrawLine($p, [float]$cx, [float]$cy, [float]($cx + $len*[Math]::Sin($a)), [float]($cy - $len*[Math]::Cos($a)))
}
Hand (-55) 25 9
Hand 60 36 6
$g.FillEllipse((New-Object System.Drawing.SolidBrush $ink), 56, 56, 16, 16)
$g.FillEllipse((New-Object System.Drawing.SolidBrush (C 255 96 60 14)), 61, 61, 6, 6)

# small highlight on the glass, top-left
$shine = New-Object System.Drawing.Drawing2D.GraphicsPath
$shine.AddEllipse(26, 20, 44, 26)
$shineBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush $shine
$shineBrush.CenterColor = C 46 255 255 255
$shineBrush.SurroundColors = @(C 0 255 255 255)
$g.FillPath($shineBrush, $shine)
$g.Dispose()

$bmp.Save((Join-Path $media "icon-preview.png"), [System.Drawing.Imaging.ImageFormat]::Png)

# TGA: 18-byte header, then raw BGRA rows from the top (descriptor bit 5)
$rect = New-Object System.Drawing.Rectangle 0, 0, $S, $S
$data = $bmp.LockBits($rect, "ReadOnly", ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb))
$bytes = New-Object byte[] ($S * $S * 4)
for ($y = 0; $y -lt $S; $y++) {
    $row = [IntPtr]::Add($data.Scan0, $y * $data.Stride)
    [System.Runtime.InteropServices.Marshal]::Copy($row, $bytes, $y * $S * 4, $S * 4)
}
$bmp.UnlockBits($data)
$bmp.Dispose()

$header = New-Object byte[] 18
$header[2] = 2                      # uncompressed true-color
$header[12] = $S -band 0xFF; $header[13] = ($S -shr 8) -band 0xFF
$header[14] = $S -band 0xFF; $header[15] = ($S -shr 8) -band 0xFF
$header[16] = 32                    # bits per pixel
$header[17] = 0x28                  # 8 alpha bits, origin top-left

$tga = Join-Path $media "icon.tga"
$fs = [System.IO.File]::Create($tga)
$fs.Write($header, 0, 18)
$fs.Write($bytes, 0, $bytes.Length)
$fs.Close()
Write-Host "saved $tga"
