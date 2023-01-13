Import-Module .\ShowUI\ShowUI.psm1
[string]$BorderThickness = "2"
[string]$borderBrush = "aliceblue"

function New-CommonButton([string]$Content, [double]$Row, [double]$Column) { 
    return Border -Row $Row -Column $Column -BorderThickness $BorderThickness -BorderBrush $borderBrush {
        Button -Content $content -On_Click {
            $formula = Get-ChildControl -ByControlName "formula"
            $formula.Text += $this.Content
        } 
    }
}

function New-FunctionButton([string]$Content, [double]$Row, [double]$Column) { 
    switch ($Content) {
        "←" {
            return Border -Row $Row -Column $Column -BorderThickness $BorderThickness -BorderBrush $borderBrush {
                Button -Content $Content -On_Click {
                    $formula = Get-ChildControl -ByControlName "formula"
                    $formula.Text = $formula.Text.Substring(0, $formula.Text.Length - 1); 
                }
            }
            break; 
        }
        "=" {
            return Border -Row $Row -Column $Column -BorderThickness $BorderThickness -BorderBrush $borderBrush {
                Button -Content $Content -On_Click {
                    $formula = Get-ChildControl -ByControlName "formula"
                    $reselt = Get-ChildControl -ByControlName "reselt"
                    $reselt.Text = Invoke-Expression $formula.Text | Out-String
                }
            }
            break; 
        }
    }
}

window -Width 300 -Height 400 -Title "Show-UI で電卓" -FontFamily "Meiryo UI" -FontSize 24 {
    Grid -Rows 6 -Columns 4 {
        StackPanel -Row 0 -Column 0 -ColumnSpan 4 -Children {
            TextBox -ControlName "formula" -Background gainsboro -FontSize 16
            TextBox -ControlName "reselt" -IsReadOnly
        }
        
        New-FunctionButton -Content "←" -Row 1 -Column 0
        New-CommonButton -Content "(" -Row 1 -Column 1
        New-CommonButton -Content ")" -Row 1 -Column 2
        New-CommonButton -Content "/" -Row 1 -Column 3

        New-CommonButton -Content "7" -Row 2 -Column 0
        New-CommonButton -Content "8" -Row 2 -Column 1
        New-CommonButton -Content "9" -Row 2 -Column 2
        New-CommonButton -Content "*" -Row 2 -Column 3

        New-CommonButton -Content "4" -Row 3 -Column 0
        New-CommonButton -Content "5" -Row 3 -Column 1
        New-CommonButton -Content "6" -Row 3 -Column 2
        New-CommonButton -Content "-" -Row 3 -Column 3

        New-CommonButton -Content "1" -Row 4 -Column 0
        New-CommonButton -Content "2" -Row 4 -Column 1
        New-CommonButton -Content "3" -Row 4 -Column 2
        New-CommonButton -Content "+" -Row 4 -Column 3

        New-CommonButton -Content "0" -Row 5 -Column 0
        New-CommonButton -Content "." -Row 5 -Column 1
        New-CommonButton -Content "%" -Row 5 -Column 2
        New-FunctionButton -Content "=" -Row 5 -Column 3
    }
} -show -On_KeyDown {
    $formula = Get-ChildControl -ByControlName "formula"
    $reselt = Get-ChildControl -ByControlName "reselt"
    [string]$retValue
    write-host $PSItem.Key
    if (!$formula.IsFocused) {
        switch ($PSItem.Key) {
            ({ $_ -in ("D") }) { Get-ParentControl | Out-GridView; break }
            ({ $_ -in ("D1", "NumPad1") }) { $retValue = 1; break }
            ({ $_ -in ("D2", "NumPad2") }) { $retValue = 2; break }
            ({ $_ -in ("D3", "NumPad3") }) { $retValue = 3; break }
            ({ $_ -in ("D4", "NumPad4") }) { $retValue = 4; break }
            ({ $_ -in ("D5", "NumPad5") }) { $retValue = 5; break }
            ({ $_ -in ("D6", "NumPad6") }) { $retValue = 6; break }
            ({ $_ -in ("D7", "NumPad7") }) { $retValue = 7; break }
            ({ $_ -in ("D8", "NumPad8") }) { $retValue = 8; break }
            ({ $_ -in ("D9", "NumPad9") }) { $retValue = 9; break }
            ({ $_ -in ("D0", "NumPad0") }) { $retValue = 0; break }
            ({ $_ -in ("Decimal", "OemPeriod") }) { $retValue = "."; break }
            ({ $_ -in ("Add", "OemPlus") }) { $retValue = "+"; break }
            ({ $_ -in ("Subtract", "OemMinus") }) { $retValue = "-"; break }
            ({ $_ -in ("Multiply", "Oem1") }) { $retValue = "*"; break }
            ({ $_ -in ("Divide", "OemQuestion") }) { $retValue = "/"; break }
            ({ $_ -in ("OemOpenBrackets") }) { $retValue = "("; break }
            ({ $_ -in ("Oem6") }) { $retValue = ")"; break }
            ({ $_ -in ("Back", "Delete") }) { $formula.Text = $formula.Text.Substring(0, $formula.Text.Length - 1); break }
            ({ $_ -in ("Return", "Space") }) { $reselt.Text = Invoke-Expression $formula.Text | Out-String; break }
        } 
        $formula.Text += $retValue
    }
}