# ScanMeltdownSpectre
Script to scan for presence of patches for Spectre and meltdown, and add required registry keys if needed to enable the OS patches.

Note: 

This script does not currently scan the following scenarios;

- Server core OS installations
- Client OS installations
- SQL specific patches for Spectre / Meltdown.


It does support remote query using a list when using -Computername param.

