# dotfiles

https://github.com/benhengeveld/dotfiles/blob/main/vscode/extensions.txt
```sh
curl -s "https://raw.githubusercontent.com/benhengeveld/dotfiles/refs/heads/main/vscode/extensions.txt" | xargs -L 1 code --install-extension
```

```powershell
(Invoke-WebRequest "https://raw.githubusercontent.com/benhengeveld/dotfiles/refs/heads/main/vscode/extensions.txt").Content -split "`n" | ForEach-Object { 
    $ext = $_.Trim()
    if ($ext) { code --install-extension $ext }
}
```
