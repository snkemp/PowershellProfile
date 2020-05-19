# Define Aliases
New-Alias -Name WoW		-Value "C:\Program Files (x86)\Battle.net\Battle.net.exe"
New-Alias -Name ConEmu	-Value "C:\Program Files (x86)\ConEmu\ConEmu.exe"
New-Alias -Name Chrome	-Value "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
New-Alias -Name IIS		-Value "C:\Program Files (x86)\IIS Express\iisexpress.exe"
New-Alias -Name NPP		-Value "C:\Program Files (x86)\Notepad++\notepad++.exe"
New-Alias -Name Origin	-Value "C:\Program Files (x86)\Origin\Origin.exe"
New-Alias -Name Steam	-Value "C:\Program Files (x86)\Steam\steam.exe"
New-Alias -Name Android	-Value "C:\Program Files (x86)\Android\Android Studio\bin\studio64.exe"
New-Alias -Name Atom	-Value "C:\Users\Spencer\AppData\Local\atom\atom.exe"


# Export Aliases
Export-ModuleMember -Alias -Name WoW
Export-ModuleMember -Alias -Name Chrome
Export-ModuleMember -Alias -Name IIS
Export-ModuleMember -Alias -Name NPP
Export-ModuleMember -Alias -Name Origin
Export-ModuleMember -Alias -Name Steam
Export-ModuleMember -Alias -Name Android
Export-ModuleMember -Alias -Name Atom