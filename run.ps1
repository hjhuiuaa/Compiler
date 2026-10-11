$ErrorActionPreference = 'Stop'
$localPath = $PSScriptRoot
$linuxPath = '/mnt/' + $localPath.Substring(0,1).ToLower() + $localPath.Substring(2).Replace('\','/')
wsl -d CompilerLab --cd $linuxPath -- python3 scripts/build.py
if ($LASTEXITCODE -ne 0) { throw 'Build failed' }
wsl -d CompilerLab --cd $linuxPath -- python3 scripts/test.py
if ($LASTEXITCODE -ne 0) { throw 'Tests failed' }
