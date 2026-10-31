$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$port = 8787
$prefix = "http://127.0.0.1:$port/"
$mime = @{
  ".html" = "text/html; charset=utf-8"
  ".css"  = "text/css; charset=utf-8"
  ".js"   = "text/javascript; charset=utf-8"
  ".json" = "application/json; charset=utf-8"
  ".svg"  = "image/svg+xml"
  ".csv"  = "text/csv; charset=utf-8"
  ".png"  = "image/png"
  ".ico"  = "image/x-icon"
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
try {
  $listener.Start()
} catch {
  Write-Host "Tidak dapat membuka $prefix"
  Write-Host $_.Exception.Message
  Write-Host "Pasang Python dari python.org, atau jalankan ulang setelah menutup aplikasi yang memakai port 8787."
  exit 1
}

Write-Host "Aplikasi siap di $prefix"
Write-Host "Jangan tutup jendela ini selama raport dipakai."
Start-Process $prefix

while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  try {
    $path = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath)
    if ($path -eq "/") { $path = "/index.html" }
    $rel = $path.TrimStart("/").Replace("/", [IO.Path]::DirectorySeparatorChar)
    if ($rel -match "\.\.") { throw "Jalur tidak diizinkan" }
    $full = [IO.Path]::GetFullPath((Join-Path $root $rel))
    $rootFull = [IO.Path]::GetFullPath($root)
    if (-not $full.StartsWith($rootFull, [StringComparison]::OrdinalIgnoreCase)) { throw "Jalur tidak diizinkan" }
    if (Test-Path -LiteralPath $full -PathType Leaf) {
      $bytes = [IO.File]::ReadAllBytes($full)
      $ext = [IO.Path]::GetExtension($full).ToLowerInvariant()
      $ctx.Response.ContentType = $(if ($mime.ContainsKey($ext)) { $mime[$ext] } else { "application/octet-stream" })
      $ctx.Response.Headers.Add("Cache-Control", "no-store")
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
      $buf = [Text.Encoding]::UTF8.GetBytes("Berkas tidak ditemukan")
      $ctx.Response.OutputStream.Write($buf, 0, $buf.Length)
    }
  } catch {
    $ctx.Response.StatusCode = 400
  } finally {
    $ctx.Response.Close()
  }
}
