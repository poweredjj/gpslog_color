# GPS logger for EdgeTX (color only)
For color screen radios that can use widgets.

## INSTALLATION AND USAGE
1. Create new folder named ```GPSLog``` in ```/WIDGETS```.
2. Copy ```main.lua``` to ```/WIDGETS/GPSLog/```.
3. Add "GPS Logger" widget to one of your screens.
4. GPS logging will be automatic during arm - disarm period.
5. If GPS fix is acquired, GPX logs will be saved to ```/LOGS```.

If you get an error, go to ```TELEMETRY``` tab and use ```Sensors``` / ```Discover new```, then restart the radio.

```ELRS```: if acquired tracks are not very detailed (especially if you are using a slower packet rate), go to ExpressLRS configurator app and increase ```telemetry ratio```.

Make sure ```telemetry``` is enabled in Betaflight ```receiver``` tab.

Tested on RadioMaster TX16S, ExpressLRS / Crossfire and M8 / M10 / M100 GPS.

You can freely use and modify this script.


<img align="left" width="300" height="167" src="screenshot.jpg">
<img align="left" width="300" height="300" src="example_track_preview.jpeg">
