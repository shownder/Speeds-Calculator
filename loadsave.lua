local _ = {}
local json = require("json")
local DefaultLocation = system.DocumentsDirectory
local RealDefaultLocation = DefaultLocation
local ValidLocations = {
   [system.DocumentsDirectory] = true,
   [system.CachesDirectory] = true,
   [system.TemporaryDirectory] = true
}

function _.saveTable(t, filename, location)
    if location and (not ValidLocations[location]) then
     error("Attempted to save a table to an invalid location", 2)
    elseif not location then
      location = DefaultLocation
    end
    
    local path = system.pathForFile( filename, location)
    local file = io.open(path, "w")
    if file then
        local contents = json.encode(t)
        file:write( contents )
        io.close( file )
        return true
    else
        return false
    end
end
 
function _.loadTable(filename, location)
    if location and (not ValidLocations[location]) then
     error("Attempted to load a table from an invalid location", 2)
    elseif not location then
      location = DefaultLocation
    end
    local path = system.pathForFile( filename, location)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
        -- read all contents of file into a string
        local contents = file:read( "*a" )
        myTable = json.decode(contents);
        io.close( file )
        return myTable
    end
    return nil
end

function _.changeDefault(location)
	if location and (not location) then
		error("Attempted to change the default location to an invalid location", 2)
	elseif not location then
		location = RealDefaultLocation
	end
	DefaultLocation = location
	return true
end

function _.makeTimeStamp(dateString, mode)
    local pattern = "(%d+)%-(%d+)%-(%d+)%a(%d+)%:(%d+)%:([%d%.]+)([Z%p])(%d*)%:?(%d*)";
    local xyear, xmonth, xday, xhour, xminute, xseconds, xoffset, xoffsethour, xoffsetmin
    local monthLookup = {Jan = 1, Feb = 2, Mar = 3, Apr = 4, May = 5, Jun = 6, Jul = 7, Aug = 8, Sep = 9, Oct = 10, Nov = 11, Dec = 12}
    local convertedTimestamp
    local offset = 0
    if mode and mode == "ctime" then
        pattern = "%w+%s+(%w+)%s+(%d+)%s+(%d+)%:(%d+)%:(%d+)%s+(%w+)%s+(%d+)"
        local monthName, TZName
        monthName, xday, xhour, xminute, xseconds, TZName, xyear = string.match(dateString,pattern)
        xmonth = monthLookup[monthName]
        convertedTimestamp = os.time({year = xyear, month = xmonth,
        day = xday, hour = xhour, min = xminute, sec = xseconds})
    else
        xyear, xmonth, xday, xhour, xminute, xseconds, xoffset, xoffsethour, xoffsetmin = string.match(dateString,pattern)
        convertedTimestamp = os.time({year = xyear, month = xmonth,
        day = xday, hour = xhour, min = xminute, sec = xseconds})
        if xoffsetHour then
            offset = xoffsethour * 60 + xoffsetmin
            if xoffset == "-" then
                offset = offset * -1
            end
        end
    end
    return convertedTimestamp + offset
end

return _