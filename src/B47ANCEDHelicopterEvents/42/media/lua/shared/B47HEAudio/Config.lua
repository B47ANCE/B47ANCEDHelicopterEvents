local Config = {}

function Config.finite(value)
    return type(value) == "number" and value == value and math.abs(value) <= 9007199254740991
end

function Config.integer(value, low, high)
    return Config.finite(value) and value >= low and value <= high and value == math.floor(value)
end

-- Missing/invalid native configuration disables the whole feature, without guessed defaults.
function Config.read(vars)
    local c = type(vars) == "table" and vars.B47HE
    if type(c) ~= "table" or type(c.EnableAudioFlights) ~= "boolean"
        or not Config.integer(c.FlightIntervalDays, 1, 365)
        or not Config.integer(c.FlightDurationSeconds, 10, 180) then
        return { enabled = false, interval = 14, duration = 60, valid = false }
    end
    return { enabled = c.EnableAudioFlights, interval = c.FlightIntervalDays,
        duration = c.FlightDurationSeconds, valid = true }
end

return Config
