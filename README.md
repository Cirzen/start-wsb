# About
Demo of how to start a Windows Sandbox with custom apps installed in parallel with Chocolatey

If you're not already up to speed with Windows Sandbox, go check out [here](https://techcommunity.microsoft.com/t5/windows-kernel-internals/windows-sandbox/ba-p/301849) first.

Windows Sandbox allows you to specify a number of folders to map into the container at startup, as well as a start up script.
Here, we demonstrate using this combination to install:
* [Chocolatey](https://www.chocolatey.org)
* [PowerShell 7 preview](https://github.com/PowerShell/PowerShell) (To take advantage of Foreach -Parallel)
* Followed by any number of desired source packages (in parallel)

# How to use
* Clone the repo or otherwise download to your system.
* Edit the `.wsb` file and edit the `<HostFolder>c:\temp\WindowsSandbox</HostFolder>` line to match the saved location.
* [Optional] Edit the `.ps1` file to amend the list of applications that will be installed into the sandbox.

Anything on its own in the $Packages array will be installed in its own runspace: `@("notepadplusplus")`   
Any array with multiple elements will be installed sequentially in their own runspace: `@("vscode",	"vscode-powershell")`

Save and double click the `.wsb` file to launch the container and wait for the script to finish processing!

# Caveats
* Nothing can be installed in the sandbox that requires a reboot, since that will reset the container to the initial state (maybe soon we'll get more persistent containers)
* There are downloads associated with each install, worth being aware of if on a managed or slow connection. You could amend to use a local Chocolatey repo if this is a concern.

## Why Powershell 7? Couldn't you have done this with `Start-Job` ??
Yes, but I wanted PS7 on my sandbox to begin with. Feel free to fork and pull if you want to remove the dependency on it.
