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
    Write-Host "by Ike4Roo"
	Write-Host "=========================="
}

# Удаление Microsoft Edge
Function Remove-MicrosoftEdge {
    Write-Host "Starting Microsoft Edge removal..." -ForegroundColor Yellow
    $EdgePath = "$env:ProgramFiles(x86)\Microsoft\Edge\Application"
    If (Test-Path $EdgePath) {
        Write-Host "Microsoft Edge found. Attempting to remove..." -ForegroundColor Green
        ForEach ($Version in Get-ChildItem -Path $EdgePath -Directory) {
            $InstallerPath = Join-Path -Path $Version.FullName -ChildPath "Installer\setup.exe"
            If (Test-Path $InstallerPath) {
                & $InstallerPath --uninstall --force-uninstall --system-level --verbose-logging
                Write-Host "Removed version: $($Version.Name)" -ForegroundColor Green
            }
        }
    } Else {
        Write-Host "Microsoft Edge not installed. Skipping..." -ForegroundColor Red
    }

    Write-Host "Attempting to remove legacy Microsoft Edge (UWP)..." -ForegroundColor Yellow
    $RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages"
    Get-ChildItem -Path $RegKeyPath | Where-Object { $_.Name -like "*Microsoft-Windows-Internet-Browser-Package*" } | ForEach-Object {
        Try {
            Remove-ItemProperty -Path $_.PSPath -Name Visibility -ErrorAction Stop
            Remove-Item -Path "$($_.PSPath)\Owners" -Recurse -Force -ErrorAction Stop
            dism /online /Remove-Package /PackageName:$($_.Name)
            Write-Host "Removed package: $($_.Name)" -ForegroundColor Green
        } Catch {
            Write-Host "Failed to remove package: $($_.Name)" -ForegroundColor Red
        }
    }
    Write-Host "Microsoft Edge removal complete!" -ForegroundColor Green
}

# Удаление OneDrive
Function Remove-OneDrive {
    Write-Host "Starting OneDrive removal..." -ForegroundColor Yellow
    $OneDrivePath = "$env:LocalAppData\Microsoft\OneDrive\OneDrive.exe"
    If (Test-Path $OneDrivePath) {
        & $OneDrivePath /uninstall
        Write-Host "OneDrive uninstalled successfully." -ForegroundColor Green
    } Else {
        Write-Host "OneDrive not found. Skipping..." -ForegroundColor Red
    }

    # Удаление остатков OneDrive
    Try {
        Remove-Item -Path "$env:UserProfile\OneDrive" -Recurse -Force
        Remove-Item -Path "$env:ProgramData\Microsoft OneDrive" -Recurse -Force
        Write-Host "Removed residual OneDrive files." -ForegroundColor Green
    } Catch {
        Write-Host "Failed to remove residual OneDrive files." -ForegroundColor Red
    }

    Write-Host "OneDrive removal complete!" -ForegroundColor Green
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
