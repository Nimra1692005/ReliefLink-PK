$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8081/")
$listener.Start()
Write-Host "Server running at http://localhost:8081"
$basePath = "c:\Users\zohaib Ahmad\Documents\Qoder\2026-08-27\chat-1\relieflink\admin"
$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
}
while ($listener.IsListening) {
    $context = $listener.GetContext()
    $urlPath = $context.Request.Url.LocalPath
    if ($urlPath -eq "/" -or $urlPath -eq "") { $urlPath = "/preview.html" }
    $filePath = Join-Path $basePath ($urlPath.TrimStart("/").Replace("/","\"))
    if (Test-Path $filePath -PathType Leaf) {
        $ext = [System.IO.Path]::GetExtension($filePath)
        $contentType = if ($mimeTypes.ContainsKey($ext)) { $mimeTypes[$ext] } else { "application/octet-stream" }
        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $context.Response.ContentType = $contentType
        $context.Response.ContentLength64 = $bytes.Length
        $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $content = Get-Content -Raw -Encoding UTF8 (Join-Path $basePath "preview.html")
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
        $context.Response.ContentType = "text/html; charset=utf-8"
        $context.Response.ContentLength64 = $bytes.Length
        $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    }
    $context.Response.Close()
}
