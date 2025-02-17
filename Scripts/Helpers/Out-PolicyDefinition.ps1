function Out-PolicyDefinition {
    [CmdletBinding()]
    param (
        $Definition,
        $Folder,
        [hashtable] $PolicyPropertiesByName,
        $InvalidChars,
        $Id,
        $FileExtension
    )

    # Fields to calculate file name
    $name = $Definition.name
    $properties = $Definition.properties
    $displayName = $properties.displayName
    if ($null -eq $displayName -or $displayName -eq "") {
        $displayName = $name
    }
    $metadata = $properties.metadata
    $subFolder = "Unknown Category"
    if ($null -ne $metadata) {
        $category = $metadata.category
        if ($null -ne $category -and $category -ne "") {
            $subFolder = $category
        }
    }

    # Build folder and path
    $fullPath = Get-DefinitionsFullPath `
        -Folder $Folder `
        -RawSubFolder $subFolder `
        -Name $name `
        -DisplayName $displayName `
        -InvalidChars $InvalidChars `
        -MaxLengthSubFolder 30 `
        -MaxLengthFileName 100 `
        -FileExtension $FileExtension

    # Detect duplicates

    if ($PolicyPropertiesByName.ContainsKey($name)) {
        $duplicateProperties = $PolicyPropertiesByName.$name
        # quietly ignore
        #
        # $exactDuplicate = Confirm-ObjectValueEqualityDeep $duplicateProperties $properties
        # if ($exactDuplicate) {
        #     # Write-Warning "'$displayName' - '$Id' is an exact duplicate" -WarningAction Continue
        #     # Quietly ignore
        #     $null = $properties
        # }
        # else {
        #     $guid = (New-Guid)
        #     $fullPath = "$Folder/Duplicates/$($guid.Guid).$FileExtension"
        #     Write-Warning "'$displayName' - '$Id' is a duplicate with different properties; writing to file $fullPath" -WarningAction Continue
        #     $Definition | Add-Member -MemberType NoteProperty -Name 'id' -Value $Id
        # }
    }
    else {
        # Unique name
        Write-Debug "'$displayName' - '$Id'"
        $null = $PolicyPropertiesByName.Add($name, $properties)
    }

    # Write the content
    Remove-NullFields $Definition
    $json = ConvertTo-Json $Definition -Depth 100
    $null = New-Item $fullPath -Force -ItemType File -Value $json
}
