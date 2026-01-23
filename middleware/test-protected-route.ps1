# --------------------------
# 1️⃣ Supabase credentials from .env
# --------------------------
$envFile = "C:\Users\STRENGTH AWA\Desktop\Journey to Job\Project A\Month 1\Week 1\Deliverables for week 1\.env"

# Read SUPABASE_URL
$supabaseUrl = (Get-Content $envFile | ForEach-Object {
    if ($_ -match "^\s*SUPABASE_URL\s*=\s*(.+)$") { $matches[1] }
})

# Read SUPABASE_PUBLISHABLE_KEY
$publishableKey = (Get-Content $envFile | ForEach-Object {
    if ($_ -match "^\s*SUPABASE_PUBLISHABLE_KEY\s*=\s*(.+)$") { $matches[1] }
})

$email = "awapenn17@gmail.com"
$password = "R@gn@rok17.35"

# --------------------------
# 2️⃣ Sign in to Supabase and get a fresh access token
# --------------------------
try {
    $signInResponse = Invoke-RestMethod -Uri "$supabaseUrl/auth/v1/token?grant_type=password" `
        -Method POST `
        -ContentType "application/json" `
        -Headers @{ "apikey" = $publishableKey } `
        -Body (@{
            email = $email
            password = $password
        } | ConvertTo-Json -Compress)

    $accessToken = $signInResponse.access_token

    if (-not $accessToken) {
        Write-Host "❌ Sign-in failed!" -ForegroundColor Red
        exit
    }

    Write-Host "✅ Access token obtained:" -ForegroundColor Green
    Write-Host $accessToken
}
catch {
    Write-Host "❌ Sign-in request failed: $_" -ForegroundColor Red
    exit
}

# --------------------------
# 3️⃣ Call protected backend route immediately
# --------------------------
try {
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }

    # This will print the response from the server in JSON
    $response = Invoke-RestMethod -Uri "http://localhost:5000/protected" -Method GET -Headers $headers

    Write-Host "✅ Response from protected route:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10
}
catch {
    Write-Host "❌ Request to protected route failed:" -ForegroundColor Red
    Write-Host $_
}
