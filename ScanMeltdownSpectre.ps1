# ScanMeltdownSpectre.PS1
# By : Bruce Langworthy
# V 1.1 
# 1/30/2018
#
#
# Summary:
#
# This script will scan to see if OS, IE, and Edge mitigations for Meltdown / Spectre are present.
# If so it will add the registry keys defined in the article below to enable the OS patches.
# https://support.microsoft.com/en-us/help/4072698/windows-server-guidance-to-protect-against-the-speculative-execution
#


# Does not check client OS, or Itanium SKU's or server core

# Note: The value for Edge patching will always be $False on OS < WS 2016

# Init

$OSPatched   = $False
$IEPatched   = $False
$EdgePatched = $False

function ScanMeltdownSpectre 
{
    Param(
    [Parameter(Mandatory=$True,Position=1)]
    $Computername
    )

    foreach ($Computer in $Computername)
    {
        
        $Hotfixes = Get-Hotfix

        # Check to see if any OS patches are installed.
        if ($hotfixes | ? HotfixID -match KB4056894 )# 2008 R2 X64 SP1 Monthly Rollup
        {
            $OSPatched=$True
        }
        elseif ($hotfixes | ? HotfixID -match KB4056897 )# 2008 R2 X64 SP1 Security fix only
            {
            $OSPatched=$True
            }
        elseif ($hotfixes | ? HotfixID -match KB4056895 )# 2012 R2 X64 Monthly Rollup
            {
            $OSPatched=$True
            }
        elseif ($hotfixes | ? HotfixID -match KB4056898 ) # 2012 R2 X64 Security fix only
            {
            $OSPatched=$True
            }
        elseif ($hotfixes | ? HotfixID -match KB4056890 )# 2016
            {
            $OSPatched=$True
        }
        else 
            {
            $OSPached=$False
            }

            # write-host "OS is $OSPatched"


        # Internet Explorer Patches
        if ($hotfixes | ? HotfixID -match KB4056895 )# IE 11 - WS 2012 R2 Monthly Rollup
            {
            $IEPatched = $True
            }
        elseif ($hotfixes | ? HotfixID -match KB4056568 )# IE 11 - WS 2012 R2 IE Cumulative Rollup
            {
            $IEPatched = $True
            }
        elseif ($hotfixes | ? HotfixID -match KB4056894 ) # IE 11 - WS 2008 R2 X64 SP1 - Monthly Rollup
            {
            $IEPatched = $True
            }
        elseif ($hotfixes | ? HotfixID -match KB4056568 ) # IE 11 - WS 2008 R2 X64 SP1 - IE Cumulative Rollup
            {
            $IEPatched = $True
            }
        elseif ($hotfixes | ? HotfixID -match KB4056890 )# IE 11 - WS 2016
            {
            $IEPatched = $True
            }
        else
            {
            $IEPatched = $False
            }

            # write-host "IE is $IEPatched"

        # Edge Browser Explorer Patches
        if ($hotfixes | ? HotfixID -match KB4056890 )# Edge Browser - WS 2016
        {
            $EdgePatched = $True    
        }
        else
        {
            $EdgePatched = $False
        }
        # write-host "Edge is $EdgePatched"

        if ($OSPatched -and $IEPatched)
        {
            EnableRegKey
        }

        if ($OSPatched -and $EdgePatched)
        {
            EnableRegKey
        }

        if (!$EdgePatched -and !$OSPatched)
        {
            write-host "$ENV:Computername has no OS Patches present, not adding registry keys" -ForegroundColor Yellow
        }

        
    }
}

function EnableRegKey # Restart is required to take effect.
{

    write-host "$ENV:Computername has required patches, adding registry keys. Reboot is required" -ForegroundColor Green

    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /t REG_DWORD /d 3 /f | Out-Null
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization" /v MinVmVersionForCpuBasedMitigations /t REG_SZ /d "1.0" /f | Out-Null
}



