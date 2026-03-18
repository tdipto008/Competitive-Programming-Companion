param(
    [string]$actual,
    [string]$expected
)

$a = if (Test-Path $actual)   { Get-Content $actual }   else { @() }
$b = if (Test-Path $expected) { Get-Content $expected } else { @() }

$max = [Math]::Max($a.Length, $b.Length)

Write-Host "-----------------------------------------------"
Write-Host "| Your Output           | Expected Output      |"
Write-Host "-----------------------------------------------"

for ($i = 0; $i -lt $max; $i++) {
    $l = if ($i -lt $a.Length) { $a[$i] } else { "" }
    $r = if ($i -lt $b.Length) { $b[$i] } else { "" }

    $line = ("| {0,-22} | {1,-22} |" -f $l, $r)

    if ($l -eq $r) {
        Write-Host $line -ForegroundColor Green
    } else {
        Write-Host $line -ForegroundColor Red
    }
}

Write-Host "-----------------------------------------------"