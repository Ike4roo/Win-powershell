# Проверка, запущен ли скрипт с правами администратора
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator!" -ForegroundColor Red
    Pause
    Exit
}

# Главное меню
Function Show-Menu {
    Clear-Host
    Write-Host "Bloatware Removal Tool" -ForegroundColor Green
    Write-Host "=========================="
    Write-Host "Please choose an option:"
    Write-Host "1. Remove Microsoft Edge"
    Write-Host "2. Remove OneDrive"
    Write-Host "3. Remove All Bloatware"
    Write-Host "4. Exit"
    Write-Host "=========================="
    Write-Host "+++ by Ike4Roo +++"
    Write-Host "=========================="
}

# Функция для принудительного удаления программы
Function Remove-Program {
    param (
        [string]$ProgramName,
        [string[]]$ProcessNames,
        [string[]]$Directories,
        [string[]]$RegistryPaths,
        [string[]]$StartMenuPaths
    )

    Write-Host "Starting removal of $ProgramName..." -ForegroundColor Yellow

    # Закрытие процессов
    foreach ($ProcessName in $ProcessNames) {
        Get-Process -Name $ProcessName -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Host "Closed $ProcessName processes." -ForegroundColor Green
    }

    # Удаление директорий
    foreach ($Directory in $Directories) {
        if (Test-Path $Directory) {
            Remove-Item -Path $Directory -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Removed directory: $Directory" -ForegroundColor Green
        } else {
            Write-Host "Directory not found: $Directory" -ForegroundColor Red
        }
    }

    # Удаление из реестра
    foreach ($RegistryPath in $RegistryPaths) {
        if (Test-Path $RegistryPath) {
            Remove-Item -Path $RegistryPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Removed registry key: $RegistryPath" -ForegroundColor Green
        } else {
            Write-Host "Registry key not found: $RegistryPath" -ForegroundColor Red
        }
    }

    # Удаление ярлыков из меню "Пуск"
    foreach ($StartMenuPath in $StartMenuPaths) {
        if (Test-Path $StartMenuPath) {
            Remove-Item -Path $StartMenuPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Removed Start Menu shortcut: $StartMenuPath" -ForegroundColor Green
        } else {
            Write-Host "Start Menu shortcut not found: $StartMenuPath" -ForegroundColor Red
        }
    }

    Write-Host "$ProgramName removal complete!" -ForegroundColor Green
}

# Удаление Microsoft Edge
Function Remove-MicrosoftEdge {
    $ProgramName = "Microsoft Edge"
    $ProcessNames = @("msedge", "MicrosoftEdge")
    $Directories = @(
        "${env:ProgramFiles(x86)}\Microsoft\Edge",
        "${env:ProgramFiles}\Microsoft\Edge",
        "${env:LocalAppData}\Microsoft\Edge",
        "${env:ProgramData}\Microsoft\Edge"
    )
    $RegistryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe"
    )
    $StartMenuPaths = @(
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
        "$env:AppData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk"
    )

    Remove-Program -ProgramName $ProgramName -ProcessNames $ProcessNames -Directories $Directories -RegistryPaths $RegistryPaths -StartMenuPaths $StartMenuPaths
}

# Удаление OneDrive
Function Remove-OneDrive {
    $ProgramName = "OneDrive"
    $ProcessNames = @("OneDrive", "OneDriveStandaloneUpdater")
    $Directories = @(
        "$env:LocalAppData\Microsoft\OneDrive",
        "$env:ProgramData\Microsoft OneDrive",
        "$env:UserProfile\OneDrive"
    )
    $RegistryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\OneDrive"
    )
    $StartMenuPaths = @(
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk",
        "$env:AppData\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"
    )

    Remove-Program -ProgramName $ProgramName -ProcessNames $ProcessNames -Directories $Directories -RegistryPaths $RegistryPaths -StartMenuPaths $StartMenuPaths
}

# Удаление всех Bloatware
Function Remove-AllBloatware {
    Remove-MicrosoftEdge
    Remove-OneDrive
    Write-Host "All bloatware removed!" -ForegroundColor Green
}

# Основной цикл программы
Do {
    Show-Menu
    $Choice = Read-Host "Enter your choice (1-4)"
    Switch ($Choice) {
        "1" { Remove-MicrosoftEdge }
        "2" { Remove-OneDrive }
        "3" { Remove-AllBloatware }
        "4" { Write-Host "Exiting..." -ForegroundColor Green; Break }
        Default { Write-Host "Invalid option. Please try again." -ForegroundColor Red }
    }
    Pause
} While ($Choice -ne "4")
