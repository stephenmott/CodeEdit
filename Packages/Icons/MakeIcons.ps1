Add-Type -AssemblyName System.Drawing

# Each entry: ClassName, BackgroundHexColor, ForegroundHexColor, Glyph (1-3 chars)
$icons = @(
    @{ Name = 'TCodeEditor';                Bg = '#2D2D30'; Fg = '#9CDCFE'; Glyph = 'Aa' },
    @{ Name = 'TKeywordCompletionProvider'; Bg = '#0E639C'; Fg = '#FFFFFF'; Glyph = '<>' },
    @{ Name = 'TCodeTemplateProvider';      Bg = '#6A1B9A'; Fg = '#FFFFFF'; Glyph = 'TPL' },
    @{ Name = 'TDelphiCodeHighlighter';     Bg = '#A0252A'; Fg = '#FFFFFF'; Glyph = 'DP' },
    @{ Name = 'TJavaScriptCodeHighlighter'; Bg = '#F7DF1E'; Fg = '#000000'; Glyph = 'JS' },
    @{ Name = 'TSqlCodeHighlighter';        Bg = '#336791'; Fg = '#FFFFFF'; Glyph = 'SQL' },
    @{ Name = 'TTungliCodeHighlighter';     Bg = '#1B7A3A'; Fg = '#FFFFFF'; Glyph = 'TG' },
    @{ Name = 'TBatchCodeHighlighter';      Bg = '#1E1E1E'; Fg = '#7FDB7F'; Glyph = '>_' },
    @{ Name = 'TPowerShellCodeHighlighter'; Bg = '#012456'; Fg = '#FFFFFF'; Glyph = 'PS' },
    @{ Name = 'TIniCodeHighlighter';        Bg = '#5A5A5A'; Fg = '#FFFFFF'; Glyph = '[ ]' },
    @{ Name = 'TYamlCodeHighlighter';       Bg = '#CB171E'; Fg = '#FFFFFF'; Glyph = 'YML' },
    @{ Name = 'TPythonCodeHighlighter';     Bg = '#3776AB'; Fg = '#FFD43B'; Glyph = 'PY' }
)

$outDir = Split-Path -Parent $MyInvocation.MyCommand.Path

foreach ($icon in $icons) {
    # Draw at 24-bit first (so we get nice anti-aliased text), then convert to 8-bit indexed
    $bmp24 = New-Object System.Drawing.Bitmap 24, 24, ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp24)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::SingleBitPerPixelGridFit

    $bgColor = [System.Drawing.ColorTranslator]::FromHtml($icon.Bg)
    $fgColor = [System.Drawing.ColorTranslator]::FromHtml($icon.Fg)
    $g.Clear($bgColor)

    $borderColor = [System.Drawing.Color]::FromArgb(
        [Math]::Max(0, $bgColor.R - 40),
        [Math]::Max(0, $bgColor.G - 40),
        [Math]::Max(0, $bgColor.B - 40))
    $borderPen = New-Object System.Drawing.Pen $borderColor, 1
    $g.DrawRectangle($borderPen, 0, 0, 23, 23)

    $glyph = $icon.Glyph
    $size = switch ($glyph.Length) { 1 { 14 } 2 { 12 } 3 { 9 } default { 8 } }
    $font = New-Object System.Drawing.Font 'Segoe UI', $size, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Object System.Drawing.SolidBrush $fgColor
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $rect = New-Object System.Drawing.RectangleF 0, 0, 24, 24
    $g.DrawString($glyph, $font, $brush, $rect, $sf)

    $font.Dispose()
    $brush.Dispose()
    $borderPen.Dispose()
    $g.Dispose()

    # Convert to 8-bit indexed using Bitmap.Clone
    $rectFull = New-Object System.Drawing.Rectangle 0, 0, 24, 24
    $bmp8 = $bmp24.Clone($rectFull, [System.Drawing.Imaging.PixelFormat]::Format8bppIndexed)

    $bmpPath = Join-Path $outDir ($icon.Name + '.bmp')
    $bmp8.Save($bmpPath, [System.Drawing.Imaging.ImageFormat]::Bmp)

    $bmp24.Dispose()
    $bmp8.Dispose()

    Write-Host "Wrote $bmpPath"
}
