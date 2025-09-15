param(
  [Alias('Archivo','ArchivoSalida')]
  [string]$Output = "files.txt",

  [Alias('Ext','Extension')]
  [string[]]$Extensions,

  [Alias('Base','Raiz')]
  [string]$Root,

  # Si lo especificás, sobrescribe el archivo en vez de agregar al final
  [switch]$Overwrite
)

if (-not $Root -or [string]::IsNullOrWhiteSpace($Root)) {
  $Root = (Get-Location).Path
}
$Root = (Resolve-Path -LiteralPath $Root).Path

if ([System.IO.Path]::IsPathRooted($Output)) {
  $outputPath = $Output
} else {
  $outputPath = Join-Path -Path $Root -ChildPath $Output
}

$extSet = @()
if ($Extensions) {
  $extSet = $Extensions |
    ForEach-Object { $_.Trim().TrimStart('.','*').ToLowerInvariant() } |
    Where-Object { $_ } | Select-Object -Unique
}

$null = New-Item -ItemType Directory -Path ([System.IO.Path]::GetDirectoryName($outputPath)) -Force 2>$null

# Preparar salida según modo
if ($Overwrite) {
  # Crea/limpia para sobrescribir
  if (Test-Path -LiteralPath $outputPath) {
    Clear-Content -LiteralPath $outputPath -ErrorAction SilentlyContinue
  } else {
    New-Item -ItemType File -Path $outputPath -Force | Out-Null
  }
}

$outputLeaf = Split-Path -Path $outputPath -Leaf

$pipeline = Get-ChildItem -LiteralPath $Root -Recurse -File -Force |
  Where-Object {
    $_.FullName -ne $outputPath -and $_.Name -ne $outputLeaf -and
    ( $extSet.Count -eq 0 -or $extSet -contains ($_.Extension.TrimStart('.').ToLowerInvariant()) )
  } |
  ForEach-Object {
    $full = $_.FullName
    if ($full.StartsWith($Root, [StringComparison]::OrdinalIgnoreCase)) {
      $rel = $full.Substring($Root.Length).TrimStart('\','/')
    } else {
      try { $rel = (Resolve-Path -LiteralPath $full -Relative) -replace '^\.[\\/]', '' }
      catch { $rel = $full }
    }

    "=== $rel ==="
    try { Get-Content -LiteralPath $full -ErrorAction Stop }
    catch { "[[ERROR al leer: $($_.Exception.Message)]]" }
    ""
  }

if ($Overwrite) {
  $pipeline | Out-File -LiteralPath $outputPath -Encoding utf8
} else {
  $pipeline | Add-Content -LiteralPath $outputPath -Encoding utf8
}

Write-Host ("Escrito: {0} ({1})" -f $outputPath, ($(if($Overwrite){"overwrite"}else{"append"})))