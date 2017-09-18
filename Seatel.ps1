Param (
        [string]$RemoteHost = ""
 )
    
Function Get-Telnet
{   Param (
        [String[]]$Commands = @(""),
        [string]$Port = "2001",
        [int]$WaitTime = 200
    )
    #Attach to the remote device, setup streaming requirements
    $Socket = New-Object System.Net.Sockets.TcpClient($RemoteHost, $Port)

    Write-Host "<?xml version="1.0" encoding="Windows-1252" ?><prtg>"

    If ($Socket)
    {   $Stream = $Socket.GetStream()
        $Writer = New-Object System.IO.StreamWriter($Stream)
        $Buffer = New-Object System.Byte[] 1024 
        $Encoding = New-Object System.Text.AsciiEncoding

        #Now start issuing the commands
        ForEach ($Command in $Commands)
        {   $Writer.WriteLine($Command) 
            $Writer.Flush()
            Start-Sleep -Milliseconds $WaitTime
        }
        #All commands issued, but since the last command is usually going to be
        #the longest let's wait a little longer for it to finish
        Start-Sleep -Milliseconds ($WaitTime * 4)
        $Result = ""
        #Save all the results
        While($Stream.DataAvailable) 
        {   $Read = $Stream.Read($Buffer, 0, 1024) 
            $Result += ($Encoding.GetString($Buffer, 0, $Read))
        }
        $Writer.Close()
        $Stream.Close()

        Return $Result
    }
    Else     
    {
       Write-Host "<Text> Error connecting to $Host</Text><Error>1</Error>"
       Write-Host '</prtg>'
         Exit 1
    }
}

#
$Process = Get-Telnet -Commands "H", "P", "q", "S", "u", "%"


$Relative = [regex]::Match($Process, '\>R([0-9]+)H([0-9]+)S([0-9]+)').Groups[1].Value -replace "`n|`r"

$Heading = [regex]::Match($Process, '\>R([0-9]+)H([0-9]+)S([0-9]+)').Groups[2].Value -replace "`n|`r"

$UnknownS= [regex]::Match($Process, '\>R([0-9]+)H([0-9]+)S([0-9]+)').Groups[3].Value -replace "`n|`r"

$Elevation = [regex]::Match($Process, '\>E([0-9]+)A([0-9]+)C([0-9]+)').Groups[1].Value -replace "`n|`r"

$Azimuth = [regex]::Match($Process, '\>E([0-9]+)A([0-9]+)C([0-9]+)').Groups[2].Value -replace "`n|`r"

$CrossLevel= [regex]::Match($Process, '\>E([0-9]+)A([0-9]+)C([0-9]+)').Groups[3].Value -replace "`n|`r"

$Freq = [regex]::Match($Process, '\>Q([0-9]+)\s([0-9]+)\s([0-9]+)').Groups[1].Value -replace "`n|`r"

$Unknown = [regex]::Match($Process, '\>Q([0-9]+)\s([0-9]+)\s([0-9]+)').Groups[2].Value -replace "`n|`r"

$NID = [regex]::Match($Process, '\>Q([0-9]+)\s([0-9]+)\s([0-9]+)').Groups[3].Value -replace "`n|`r"

$DACStatus = [regex]::Match($Process, '\>S(....)L([0-9]+)').Groups[1].Value -replace "`n|`r"

$Signal2 = [regex]::Match($Process, '\>S(....)L([0-9]+)').Groups[2].Value -replace "`n|`r"

$Polang = [regex]::Match($Process, '\>G([0-9]+)V([0-9]+)T([0-9]+)').Groups[1].Value -replace "`n|`r"

$ExtAGC = [regex]::Match($Process, '\>G([0-9]+)V([0-9]+)T([0-9]+)').Groups[2].Value -replace "`n|`r"

$Threshold = [regex]::Match($Process, '\>G([0-9]+)V([0-9]+)T([0-9]+)').Groups[3].Value -replace "`n|`r"

$Signal = [regex]::Match($Process, '\>L([0-9]+)\s').Groups[1].Value -replace "`n|`r"



$DACStatusBinary = [system.Text.Encoding]::Default.GetBytes($DACStatus) | %{[System.Convert]::ToString($_,2).PadLeft(8,'0') }

$SlowScanMode = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[3].Value -replace "`n|`r"
$SatRefMode = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[4].Value -replace "`n|`r"
$TrackingOn = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[5].Value -replace "`n|`r"
$Unwrap = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[6].Value -replace "`n|`r"
$PCUStatusBit1 = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[7].Value -replace "`n|`r"
$PCUStatusBit0 = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[8].Value -replace "`n|`r"

$AzTargetting = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[11].Value -replace "`n|`r"
$ElPolangTargetting = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[12].Value -replace "`n|`r"
$InclinedOrbitTarget = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[13].Value -replace "`n|`r"
$BlockedMuted = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[14].Value -replace "`n|`r"
$Initializing = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[15].Value -replace "`n|`r"
$Searching = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[16].Value -replace "`n|`r"

$SatOutOfRange = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[19].Value -replace "`n|`r"
$DishScanError = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[20].Value -replace "`n|`r"
$PCUError = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[21].Value -replace "`n|`r"
$CommsError = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[22].Value -replace "`n|`r"
$WrongSyncroError = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[23].Value -replace "`n|`r"
$GyroReadError = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[24].Value -replace "`n|`r"

$StabLimit = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[28].Value -replace "`n|`r"
$AzRefError = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[29].Value -replace "`n|`r"
$AzServoLimit = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[30].Value -replace "`n|`r"
$LvServoLimit = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[31].Value -replace "`n|`r"
$ClServoLimit = [regex]::Match($DACStatusBinary, '^([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])\s([01])([01])([01])([01])([01])([01])([01])([01])').Groups[32].Value -replace "`n|`r"




Write-Host "
<result>
       <channel>AGC</channel>
       <unit>Custom</unit>
       <customUnit></customUnit>
       <customUnit>#</customUnit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($Signal)</value>
</result>"


Write-Host "
<result>
       <channel>Azimuth</channel>
       <unit>Custom</unit>
       <customUnit>&#176;</customUnit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>1</float>
       <value>$($Azimuth.Insert(3,"."))</value>
       </result>"

Write-Host "
<result>
       <channel>Elevation</channel>
       <unit>Custom</unit>
       <customUnit>&#176;</customUnit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>1</float>
       <value>$($Elevation.Insert(3,"."))</value>
       </result>"

Write-Host "
<result>
       <channel>Relative</channel>
       <unit>Custom</unit>
       <customUnit>&#176;</customUnit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>1</float>
       <value>$($Relative.Insert(3,"."))</value>
       </result>"

Write-Host "
<result>
       <channel>Heading</channel>
       <unit>Custom</unit>
       <customUnit>&#176;</customUnit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>1</float>
       <value>$($Heading.Insert(3,"."))</value>
       </result>"

Write-Host "
<result>
       <channel>CrossLevel</channel>
       <unit>Custom</unit>
       <customUnit>&#176;</customUnit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>1</float>
       <value>$($CrossLevel.Insert(3,"."))</value>
       </result>"

Write-Host "
<result>
       <channel>NID</channel>
       <unit>Custom</unit>
       <customUnit></customUnit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($NID)</value>
       </result>"

Write-Host "
<result>
       <channel>Polang</channel>
       <unit>Custom</unit>
       <customUnit>&#176;</customUnit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>1</float>
       <value>$($Polang.Insert(3,"."))</value>
       </result>"

Write-Host "
<result>
       <channel>Threshold</channel>
       <unit>Custom</unit>
       <customUnit></customUnit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($Threshold)</value>
       </result>"




Write-Host "
<result>
       <channel>Slow Scan Mode</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($SlowScanMode)</value>
       <ValueLookup>seatel.preferoff</ValueLookup>
   </result>"

Write-Host "
<result>
       <channel>Satellite Reference Mode</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($SatRefMode)</value>
       <ValueLookup>seatel.preferoff</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Tracking</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($TrackingOn)</value>
       <ValueLookup>seatel.preferon</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Unwrap</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($Unwrap)</value>
       <ValueLookup>seatel.preferoff</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>PCU Status Bit1</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($PCUStatusBit1)</value>
       <ValueLookup>seatel.preferoff</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>PCU Status Bit0</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($PCUStatusBit0)</value>
       <ValueLookup>seatel.preferoff</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Az Targetting</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($AzTargetting)</value>
       <ValueLookup>seatel.preferoff</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Elevation & Polang Targetting</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($ElPolangTargetting)</value>
       <ValueLookup>seatel.preferoff</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Inclined Orbit Initial Target</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($InclinedOrbitTarget)</value>
       <ValueLookup>seatel.preferoff</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Blocked/Muted</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($BlockedMuted)</value>
       <ValueLookup>seatel.preferoff</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Initializing</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($Initializing)</value>
       <ValueLookup>seatel.preferoff</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Searching</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($Searching)</value>
       <ValueLookup>seatel.preferoff</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Satellite Out Of Range</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($SatOutOfRange)</value>
       <ValueLookup>seatel.preferofferror</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>DishScan Error</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($DishScanError)</value>
       <ValueLookup>seatel.preferofferror</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>PCU Error</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($PCUError)</value>
       <ValueLookup>seatel.preferofferror</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Comms Error</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($CommsError)</value>
       <ValueLookup>seatel.preferoff</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Wrong Synchro Converter Type</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($WrongSyncroError)</value>
       <ValueLookup>seatel.preferofferror</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Gyro Read Error</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($GyroReadError)</value>
       <ValueLookup>seatel.preferofferror</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Stab Limit</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($StabLimit)</value>
       <ValueLookup>seatel.preferofferror</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Az Reference Error</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($AzRefError)</value>
       <ValueLookup>seatel.preferofferror</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Az Servo Limit Error</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($AzServoLimit)</value>
       <ValueLookup>seatel.preferofferror</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Lv Servo Limit Error</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($LvServoLimit)</value>
       <ValueLookup>seatel.preferofferror</ValueLookup>
   </result>"


Write-Host "
<result>
       <channel>Cl Servo Limit Error</channel>
       <unit>Custom</unit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($ClServoLimit)</value>
       <ValueLookup>seatel.preferofferror</ValueLookup>
   </result>"

Write-Host '</prtg>'

exit 0