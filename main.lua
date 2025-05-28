-- GPS Logger 1.0 for EdgeTX (widget version for color screen radios) by Marcin Śmidowicz.
-- Logs GPS coordinates for each arm-disarm cycle and saves them as a GPX file.

-- INSTALLATION AND USAGE

-- 1. Create new folder named GPSLog in /WIDGETS.
-- 2. Copy main.lua to /WIDGETS/GPSLog/
-- 3. Add "GPS Logger" widget to one of your screens.
-- 4. GPS logging will be automatic during arm - disarm period.
-- 5. If GPS fix is acquired, GPX logs will be saved to /LOGS.

local name = "GPS Logger"

local options = {
}

local gpsLatLonId
local gpsAltId
local chArmedId
local armed
local arm_time = 0 -- timestamp when armed
local waypoints_recorded = 0
local latitude, longitude = 0.0, 0.0
local altitude = 0.0
local gpx_path = ""

local function create(zone, options)
    gpsLatLonId = getFieldInfo("GPS") and getFieldInfo("GPS").id or nil;
    gpsAltId  = getFieldInfo("Alt") and getFieldInfo("Alt").id or nil;
    chArmedId = getFieldInfo('ch5').id

	local widget = {
		zone = zone,
		options = options
	}

	return widget
end

local function write_gps_file_header()
	local dt = getDateTime()		
	local timestamp = string.format(
	"%d-%02d-%02dT%02d:%02d:%02d",
	tonumber(dt.year), tonumber(dt.mon ), tonumber(dt.day),
	tonumber(dt.hour), tonumber(dt.min ), tonumber(dt.sec))
		
	io.write(log_file, "<?xml version='1.0' encoding='UTF-8'?>\n")
	io.write(log_file, "<gpx version='1.1' creator='EdgeTX Lua Script' xmlns='http://www.topografix.com/GPX/1/1'>\n")	
	io.write(log_file, string.format("<metadata><time>%s</time></metadata>\n", timestamp))
	io.write(log_file, string.format("<trk><name>Flight Log</name><trkseg>\n", timestamp))
end

local function write_gps_file_footer()
	io.write(log_file, "</trkseg></trk>\n</gpx>")
end

local function update(widget, options)
	widget.options = options
end

local function draw()
	lcd.clear()
	
	lcd.drawText(5, 0, "GPS logger", MIDSIZE)
	lcd.drawText(5, 40, "GPS: " .. tostring(latitude) .. ", " .. tostring(longitude), 0)
	lcd.drawText(5, 60, string.format("altitude %f", altitude), 0)
	
    if armed then
        local elapsed_time = (getTime() - arm_time) / 100  -- seconds
		lcd.drawText(5, 20, string.format("REC (waypoints: %d)", waypoints_recorded), 0)
		lcd.drawText(5, 30, string.format("Time: %d sec", elapsed_time), 0)
    else
        lcd.drawText(5, 20, "IDLE", 0)
    end	
end

local function background(widget)
	armed = getValue(chArmedId) > 0
	
	if log_file == nil and armed then
		arm_time = getTime()
		
		local dt = getDateTime()		
		local timestamp = string.format(
		"%d-%02d-%02d_%02d_%02d_%02d",
		tonumber(dt.year), tonumber(dt.mon), tonumber(dt.day),
		tonumber(dt.hour), tonumber(dt.min), tonumber(dt.sec))
		
		gpx_path = string.format("/LOGS/gps_log_%s.gpx", timestamp)			
		log_file = io.open(gpx_path, "a")	
		waypoints_recorded = 0

		write_gps_file_header()
	end	
		
	if not armed and log_file ~= nil then
		if waypoints_recorded < 6 then -- no point in storing empty (or very small) logs
			io.close(log_file)
			del(gpx_path)	
		else
			write_gps_file_footer()
			io.close(log_file)
		end
		
		log_file = nil
		gpx_path = ""
		waypoints_recorded = 0	
	end
	
	local gpsLatLon = getValue(gpsLatLonId)
	local altitude_new = getValue(gpsAltId)
			
	if armed
	and gpsLatLon ~= 0
	and (gpsLatLon.lat ~= latitude or gpsLatLon.lon ~= longitude or altitude_new ~= altitude) then	
		latitude = gpsLatLon.lat
		longitude = gpsLatLon.lon
		altitude = altitude_new
	
		local dt = getDateTime()
		local timestamp = string.format(
		"%d-%02d-%02dT%02d:%02d:%02d",
		tonumber(dt.year), tonumber(dt.mon), tonumber(dt.day),
		tonumber(dt.hour), tonumber(dt.min), tonumber(dt.sec))
					
		io.write(log_file, string.format(
		"<trkpt lat='%f' lon='%f'><ele>%f</ele><time>%s</time></trkpt>\n", 
		latitude, longitude, altitude, timestamp))
		
		waypoints_recorded = waypoints_recorded + 1
	end		
end

local function refresh(widget, event, touchState)
	background()
	draw()
end

return {
  name = name,
  options = options,
  create = create,
  update = update,
  refresh = refresh,
  background = background
}