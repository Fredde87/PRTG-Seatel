Param (
        [string]$User = "",
        [string]$Password = "",
        [string]$RemoteHost = ""
 )
    
Function Get-Telnet
{   Param (
        [String[]]$Commands = @(""),
        [string]$Port = "23",
        [int]$WaitTime = 100
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
$Process = Get-Telnet -Commands "$User","$Password","show all"



$Mode = [regex]::Match($Process, 'SET SYSTEM MODE (.+)').Groups[1].Value -replace "`n|`r"

$ActiveAnt = [regex]::Match($Process, 'SET ANTENNA (.) ACTIVE').Groups[1].Value -replace "`n|`r"


If($Mode -eq 'AUTO') {
    $ModeInt = 1
} else {
    $ModeInt = 0
}

If($ActiveAnt -eq 'A') {
    $ActiveAntInt = 1
} elseif ($ActiveAnt -eq 'B') {
    $ActiveAntInt = 2
} else {
    $ActiveAntInt = 3
}



Write-Host "
<result>
       <channel>Auto Selection</channel>
       <unit>Custom</unit>
       <customUnit></customUnit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($ModeInt)</value>
       <ValueLookup>seatel.preferon</ValueLookup>
       </result>
"

Write-Host "
<result>
       <channel>Active Antenna</channel>
       <unit>Custom</unit>
       <customUnit></customUnit>
       <mode>Absolute</mode>
       <showChart>1</showChart>
       <showTable>1</showTable>
       <warning>0</warning>
       <float>0</float>
       <value>$($ActiveAntInt)</value>
       <ValueLookup>seatel.antenna</ValueLookup>
       </result>
"

 Write-Host '</prtg>'

exit 0