#!/usr/bin/env pwsh

function Ask-YesNo {
	param([string]$Prompt)

	while ($true) {
		$response = Read-Host "$Prompt (y/n)"
		switch ($response.ToLower()) {
			'y' { return $true }
			'n' { return $false }
		}
	}
}

# Check if VS Code CLI is available
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
	Write-Host "VS Code CLI ('code') not found. Install VS Code and enable 'code' in PATH."
	exit 1
}

$BaseRaw = "https://raw.githubusercontent.com/benhengeveld/dotfiles/main/vscode"

$ExtensionsUrl = "$BaseRaw/extensions.txt"
$SettingsUrl = "$BaseRaw/settings.json"
$KeybindingsUrl = "$BaseRaw/keybindings.json"

$VscodeUserDir = "$env:APPDATA\Code\User"

# Create directory if it doesn't exist
New-Item -ItemType Directory -Force -Path $VscodeUserDir | Out-Null

# Install extensions
if (Ask-YesNo "Install VS Code extensions?") {
	try {
		$extensions = Invoke-WebRequest -Uri $ExtensionsUrl -UseBasicParsing
		$extensions.Content -split "`n" | ForEach-Object {
			$line = $_.Trim()
			# Skip empty lines and comments
			if ($line -and -not $line.StartsWith('#')) {
				Write-Host "Installing extension: $line"
				try {
					code --install-extension $line
				} catch {
					Write-Host "Warning: Failed to install $line" -ForegroundColor Yellow
				}
			}
		}
	} catch {
		Write-Host "Error: Failed to download extensions list" -ForegroundColor Red
		exit 1
	}
} else {
	Write-Host "Skipped extension installation"
}

# Update settings.json
if (Ask-YesNo "Update settings.json? (this will overwrite existing)") {
	$settingsPath = Join-Path $VscodeUserDir "settings.json"
	$backupPath = "$settingsPath.backup"

	# Backup if exists
	if (Test-Path $settingsPath) {
		Copy-Item $settingsPath $backupPath
	}

	Write-Host "Updating settings.json"
	try {
		Invoke-WebRequest -Uri $SettingsUrl -OutFile $settingsPath -UseBasicParsing

		# Validate downloaded file
		if (-not (Test-Path $settingsPath) -or (Get-Item $settingsPath).Length -eq 0) {
			Write-Host "Warning: Downloaded settings.json is empty" -ForegroundColor Yellow
			# Restore backup
			if (Test-Path $backupPath) {
				Move-Item $backupPath $settingsPath -Force
				Write-Host "Restored backup"
			}
			exit 1
		}

		# Delete backup after successful replacement
		if (Test-Path $backupPath) {
			Remove-Item $backupPath -Force
		}
	} catch {
		Write-Host "Error: Failed to download settings.json" -ForegroundColor Red
		# Restore backup if download failed
		if (Test-Path $backupPath) {
			Move-Item $backupPath $settingsPath -Force
			Write-Host "Restored backup"
		}
		exit 1
	}
} else {
	Write-Host "Skipped settings.json"
}

# Update keybindings.json
if (Ask-YesNo "Update keybindings.json? (this will overwrite existing)") {
	$keybindingsPath = Join-Path $VscodeUserDir "keybindings.json"
	$backupPath = "$keybindingsPath.backup"

	# Backup if exists
	if (Test-Path $keybindingsPath) {
		Copy-Item $keybindingsPath $backupPath
	}

	Write-Host "Updating keybindings.json"
	try {
		Invoke-WebRequest -Uri $KeybindingsUrl -OutFile $keybindingsPath -UseBasicParsing

		# Validate downloaded file
		if (-not (Test-Path $keybindingsPath) -or (Get-Item $keybindingsPath).Length -eq 0) {
			Write-Host "Warning: Downloaded keybindings.json is empty" -ForegroundColor Yellow
			# Restore backup
			if (Test-Path $backupPath) {
				Move-Item $backupPath $keybindingsPath -Force
				Write-Host "Restored backup"
			}
			exit 1
		}

		# Delete backup after successful replacement
		if (Test-Path $backupPath) {
			Remove-Item $backupPath -Force
		}
	} catch {
		Write-Host "Error: Failed to download keybindings.json" -ForegroundColor Red
		# Restore backup if download failed
		if (Test-Path $backupPath) {
			Move-Item $backupPath $keybindingsPath -Force
			Write-Host "Restored backup"
		}
		exit 1
	}
} else {
	Write-Host "Skipped keybindings.json"
}

Write-Host ""
Write-Host "VS Code setup complete"
Write-Host "You may need to reload or restart VS Code for all changes to take effect."
