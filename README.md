# PRTG-Seatel-sensor
## Custom Seatel DAC/MXP and Arbitrator XML Sensor for PRTG

1. Please the Seatel.ps1 and Arbitrator.ps1 files in the Custom Sensors\EXEXML\ folder and put the *.ovl in lookups\custom\

2. Restart your PRTG Core server after that.

3. Create a Advanced EXE/XML sensor for your iDirect modem's Sensor and select my iDirect.ps1 script from the drop down.

4. Pass the following string as parameters,
-User %linuxserver -Password %linuxpassword -RemoteHost %host

5. Make sure you have specified the correct login credentials (the Linux ones) for your iDirect Sensor.
