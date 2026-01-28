# File: test-protected-route.ps1
# This script tests accessing a protected backend route using Supabase authentication.
# Now decodes JWT locally to inspect 'exp' claim.

# --------------------------
# 1️⃣ Supabase credentials from .env
# --------------------------
$envFile = "C:\Users\STRENGTH AWA\Desktop\Journey to Job\Project A\Month 1\Week 1\Deliverables for week 1\backend\.env"

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
# 3️⃣ Decode JWT locally to inspect 'exp' claim
# --------------------------
try {
    # JWT structure: header.payload.signature
    $parts = $accessToken -split "\."
    if ($parts.Count -ne 3) {
        throw "Invalid JWT format"
    }

    $payloadBase64 = $parts[1]

    # Pad base64 if needed
    switch ($payloadBase64.Length % 4) {
        2 { $payloadBase64 += "==" }
        3 { $payloadBase64 += "=" }
    }

    # Decode payload
    $payloadJson = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($payloadBase64))
    $payload = $payloadJson | ConvertFrom-Json

    $expTimestamp = [int]$payload.exp
    $currentTimestamp = [int][double]::Parse((Get-Date -UFormat %s))
    $expDate = Get-Date -Date ([System.DateTimeOffset]::FromUnixTimeSeconds($expTimestamp).DateTime)

    Write-Host "🕒 Token expiry info:" -ForegroundColor Cyan
    Write-Host "Token 'exp' (timestamp): $expTimestamp"
    Write-Host "Token expires at   : $expDate"
    Write-Host "Current time       : $(Get-Date)"
    if ($currentTimestamp -ge $expTimestamp) {
        Write-Host "⚠️ Token has expired!" -ForegroundColor Red
    } else {
        Write-Host "✅ Token is still valid." -ForegroundColor Green
    }
}
catch {
    Write-Host "❌ Failed to decode JWT: $_" -ForegroundColor Red
}

# --------------------------
# 4️⃣ Call protected backend route immediately
# --------------------------
try {
    $headers = @{
        "Authorization" = "Bearer $accessToken"
    }

    $response = Invoke-RestMethod -Uri "http://localhost:5000/protected" -Method GET -Headers $headers

    Write-Host "✅ Response from protected route:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10
}
catch {
    Write-Host "❌ Request to protected route failed:" -ForegroundColor Red
    Write-Host $_
}
