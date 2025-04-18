function Write-ColorOutput($ForegroundColor)
{
    $fc = $host.UI.RawUI.ForegroundColor

    $host.UI.RawUI.ForegroundColor = $ForegroundColor

    if ($args) {
        Write-Output $args
    }
    else {
        $input | Write-Output
    }

    $host.UI.RawUI.ForegroundColor = $fc
}

Get-ChildItem ".\Tests\" |
Foreach-Object {
    & $_.FullName
    if ($? -eq $true)
    {
        Write-ColorOutput green ("nice")
    }
    else {
        Write-ColorOutput yellow ("not nice")
    }
}