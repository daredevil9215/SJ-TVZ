function Watch-FolderChanges {

    <#

    .SYNOPSIS
    Displays and writes to file any changes occuring in the specified directory.

    .DESCRIPTION
    Watch-FolderChanges displays and writes to a log file any changes that occur in the specified directory.

    Specified directory is the current working directory by default.

    Log file location is the parent directory of the current working directory by default.

    The setting to watch for subdirectory changes is available and is disabled by default.

    .PARAMETER FolderPath
    Specifies the directory path to be watched.

    .PARAMETER Subdirectories
    Specifies whether to watch for subdirectory changes.

    .PARAMETER LogPath
    Specifies the path of the log file.

    .EXAMPLE
    Watch-FolderChanges
    Watches for current directory changes, log file set to parent directory.

    .EXAMPLE
    Watch-FolderChanges -Subdirectories
    Watches for current directory and subdirectory changes, log file set to parent directory.

    .EXAMPLE
    Watch-FolderChanges -FolderPath "/home/Grgo/Desktop/Faks/Skriptni jezici/Powershell" -LogPath "/home/Grgo/Desktop/changesLog.txt" -Subdirectories
    Watches for specified directory and subdirectory changes, log file set to desktop.

    #>

    [CmdletBinding()]

    param(

        [string]$FolderPath = $PWD.Path,

        [switch]$Subdirectories = $false,
        
        [string]$LogPath = (Split-Path -Path $FolderPath -Parent) + "/changesLog.txt"
    )

    $global:Log = $LogPath

    # Kreiranje Watcher objekta pomocu New-Object cmdleta
    $watcher = New-Object System.IO.FileSystemWatcher

    # Atributi klase FileSystemWatcher
    $watcher.Path = $FolderPath
    $watcher.IncludeSubdirectories = $Subdirectories
    $watcher.EnableRaisingEvents = $true;

    # Pretplacivanje na eventove FileSystemWatchera koristeci Register-ObjectEvent cmdlet
    Register-ObjectEvent -InputObject $watcher -EventName Created -Action {
        $formattedDateTime = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
        $info = "File created: $($eventArgs.FullPath)"
        $all = $formattedDateTime + " " + $info
        Write-Host $all
        Add-Content -Path $global:Log -Value $all
    }

    Register-ObjectEvent -InputObject $watcher -EventName Changed -Action {
        $formattedDateTime = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
        $info = "File changed: $($eventArgs.FullPath)"
        $all = $formattedDateTime + " " + $info
        Write-Host $all
        Add-Content -Path $global:Log -Value $all
    }

    Register-ObjectEvent -InputObject $watcher -EventName Deleted -Action {
        $formattedDateTime = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
        $info = "File deleted: $($eventArgs.FullPath)"
        $all = $formattedDateTime + " " + $info
        Write-Host $all
        Add-Content -Path $global:Log -Value $all
    }

    Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action {
        $formattedDateTime = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
        $info = "File renamed: $($eventArgs.FullPath)"
        $all = $formattedDateTime + " " + $info
        Write-Host $all
        Add-Content -Path $global:Log -Value $all
    }

    try {
        while ($true) {
            Start-Sleep -Seconds 1
        }
    } finally {
        $watcher.Dispose()
        Get-EventSubscriber | Unregister-Event
    }

}