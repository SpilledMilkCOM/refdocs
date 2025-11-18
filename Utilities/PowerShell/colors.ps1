
begin {

    add-type -AssemblyName System.Drawing

    function Get-RGBFromColorName {
        param (
            [string]$ColorName
        )
    
        try {
            # Create a color object from the color name
            $color = [System.Drawing.Color]::FromName($ColorName)
    
            # Check if the color is known
            if ($color.IsKnownColor) {
                return @{
                    Red   = $color.R
                    Green = $color.G
                    Blue  = $color.B
                }
            }
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
}
process {

    # Get the current console colors
    $foregroundColor = $Host.UI.RawUI.ForegroundColor
    $backgroundColor = $Host.UI.RawUI.BackgroundColor

    Write-Host "Foreground: $foregroundColor      Background: $backgroundColor"

    # Define all the console colors
    $colors = [System.Enum]::GetValues([System.ConsoleColor])

    # Loop through each color and display it
    foreach ($color in $colors) {
        $column1 = "{0,-12} " -f $color
        Write-Host $column1 -NoNewline

        $rgb = Get-RGBFromColorName $color

        if ($rgb) {
            $column2 = "{0,-16}" -f "($($rgb.Red), $($rgb.Green), $($rgb.Blue))"

        }
        else {
            $column2 = "{0,-16}" -f "? NAME ?"
        }

        Write-Host $column2 -NoNewline

        Write-Host "The quick brown fox jumped over the lazy dog." -ForegroundColor $color
    }
}
end {

}