#region LoadFunctions

$paths = @(
    'Private',
    'Public'
)

foreach ($path in $paths) {
    "$(Split-Path -Path $MyInvocation.MyCommand.Path)\$path\*.ps1" | 
        Resolve-Path | 
            ForEach-Object { 
                . $_.ProviderPath 
            }
}

#endregion LoadFunctions

foreach ($value in ([SeceditUserRights].GetEnumNames())) {
    Set-Content "Function:Get-$value" -Value '[SeceditObject]::new($MyInvocation.MyCommand.Noun, "USER_RIGHTS")'
    Export-ModuleMember -Function "Get-$value"
}
