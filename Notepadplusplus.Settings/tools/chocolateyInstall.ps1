
$packageName = 'Notepadplusplus.Settings'

try {
	$params = $env:chocolateyPackageParameters -split ';' | ConvertFrom-StringData
	$url = $params.url;
	$programFiles = if (${env:ProgramFiles(x86)} -ne $null) { ${env:ProgramFiles(x86)} } else { $env:ProgramFiles }
	
	if ($url) {
		Write-Host "Downloading from URL $url"
		try { 
			$settings = "$PSScriptRoot\settings"
			Remove-Item -Path $settings -Force -ErrorAction SilentlyContinue
			$null = New-Item -Path $settings -ItemType Directory -Force -ErrorAction SilentlyContinue

			Get-ChocolateyWebFile $packageName "$settings\config.xml" "$url/config.xml"
			Get-ChocolateyWebFile $packageName "$settings\contextMenu.xml" "$url/contextMenu.xml"
			Get-ChocolateyWebFile $packageName "$settings\functionList.xml" "$url/functionList.xml"
			Get-ChocolateyWebFile $packageName "$settings\langs.xml" "$url/langs.xml"
			Get-ChocolateyWebFile $packageName "$settings\shortcuts.xml" "$url/shortcuts.xml"
			Get-ChocolateyWebFile $packageName "$settings\stylers.xml" "$url/stylers.xml"

			$params = @("$settings\", "$env:appdata\Notepad++\", '/MOVE', '/E', '/IS', '/r:10', '/w:10', '/NP',  '/NC', '/ETA', '/FP' )
    
			& c:\windows\System32\Robocopy.exe $params 
		
			# Find the theme file
			$themeNode = Select-Xml -Path "$env:appdata\notepad++\config.xml" -XPath "//GUIConfig[@name='stylerTheme']"
			$themePath = $themeNode.node.path
			$themeFile = Split-Path $themePath -Leaf
			Get-ChocolateyWebFile $packageName "settings\$themeFile" "$url/$themeFile"
			if (Test-Path -Path "${env:ProgramFiles(x86)}\Notepad++") {
				$dest = "${env:ProgramFiles(x86)}\Notepad++"
			}
			if (Test-Path -Path "${env:ProgramFiles}\Notepad++") {
				$dest = "${env:ProgramFiles}\Notepad++"
			}
			if ($dest) { 
				$params = @("$settings\", "$dest\", '/MOVE', '/E', '/IS', '/r:10', '/w:10', '/NP',  '/NC', '/ETA', '/FP' )
				& c:\windows\System32\Robocopy.exe $params 
			}
		} catch {
			Write-Host "$packageName exception ignored [$_]"
		}
	} else {
		throw "No URL specified. Try calling choco install Notepadplusplus.Settings -params 'url=http://example.com/NotepadSettings/'"
	}
	
	Write-ChocolateySuccess "$packageName"
} catch {
	Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
	throw
}
