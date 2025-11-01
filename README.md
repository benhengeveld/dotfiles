# dotfiles

https://github.com/benhengeveld/dotfiles/blob/main/vscode/extensions.txt
```sh
curl -s "link to raw extensions.txt file" | xargs -L 1 code --install-extension
```

```powershell
(Invoke-WebRequest "link to raw extensions.txt file").Content -split "`n" | ForEach-Object { 
    $ext = $_.Trim()
    if ($ext) { code --install-extension $ext }
}
```
