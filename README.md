# dotfiles

### Linux command to install VS Code extentions
```sh
curl -s "https://raw.githubusercontent.com/benhengeveld/dotfiles/refs/heads/main/vscode/extensions.txt" | xargs -L 1 code --install-extension
```

### Windows command to install VS Code extentions
```powershell
(Invoke-WebRequest "https://raw.githubusercontent.com/benhengeveld/dotfiles/refs/heads/main/vscode/extensions.txt").Content -split "`n" | ForEach-Object { 
    $ext = $_.Trim()
    if ($ext) { code --install-extension $ext }
}
```
