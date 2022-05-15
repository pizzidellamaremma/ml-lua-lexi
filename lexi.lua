
-- MagicLantern long exposure intervalometer for stacking
-- v0.01 by Pizzi DellaMaremma 

-- ********************************************************
require("logger")

TestBeepNoShutter = 0

--local log = logger("LEXI.LOG")
--log:write("LEXI - Init logging\n")

lexi = menu.new
{
    parent = "Shoot",
    name = "LExI",
    help = "Long Exposure Intervalometer (w/reps)",
    submenu =
    {
		{
            name = "Enable",
            help = "Enable LEXI",
			choices = {"Off","On"}
        },
		{
            name = "Initial delay",
            help = "Initial delay after shutter start.",
			min = 5,
			max = 20,
			value = 10,
			unit = UNIT.TIME
        },
		{
			name = "Exposure length",
			help = "Length of the exposure.",
			min = 0,
			max = 900,
			value = 20,
			unit = UNIT.TIME
		},
		{
			name = "Delay",
			help = "Delay between shoots.",
			min = 5,
			max = 30,
			value = 8,
			unit = UNIT.TIME
		},
		{
			name = "Repetitions",
			help = "Number of repetitions.",
			min = 1,
			max = 999,
			value = 1,
			unit = UNIT.INT
		},
		{
			name = "Debug",
			help = "Enable logfile inside ML directory.",
			choices = {"Off", "On"},
			value = "Off"
		},
    }
}

-- Utility function: countdown in seconds
function countdown(sec)
	while sec > 0 do
		display.notify_box(string.format("Starting in %ss", sec))
		task.yield(1000)
		sec = sec - 1
	end
end

-- Add some checks to verify before starting (return bool)
function check_control()  -- Check before starting cycle
	-- Bulb mode
	if camera.mode ~= MODE.BULB then
		display.notify_box("LEXI checks - Not in Bulb!")
		return false
	end
	-- TO REMOVE
	-- display.notify_box(string.format("Camera AF: %s", lens.af))
	-- task.yield(10000)
	-- TO REMOVE
	if lens.af == true then
		display.notify_box("LEXI checks - Disable AF!")
		
		return false
	end
	return true
end

-- Main function
function main(init_delay, exp_length, dly, reps)  -- Execute the cycle
	
	display.notify_box("Starting LEXI...")
	task.yield(500)
	
	-- Initial delay
	countdown(init_delay)
			
	-- Repeated shots
	local n = 1
	for i = reps, 0, -1 do
		
		display.notify_box(string.format("Running shot %s", n))
		if TestBeepNoShutter == 0 then
			camera.bulb(exp_length)
			task.yield(10)
		else
			beep(1,50)
			task.yield(600 + camera.shutter.ms)
		end
		
		-- Delay between shots
		if n < reps then 
			countdown(dly)
		
		elseif n == reps then
			break
		end
		
		n = n + 1 -- Increment n (shot number)
	end	
end

-- Trigger function
function event.keypress(key)
	-- check halfshutter and enable
	if key == KEY.HALFSHUTTER and lexi.submenu["Enable"].value == "On" then
		
		-- Check function
		if check_control() == true then
			
			-- Call the cycle
			main(
				lexi.submenu["Initial delay"].value,
				lexi.submenu["Exposure length"].value,
				lexi.submenu["Delay"].value,
				lexi.submenu["Repetitions"].value
			)
			
			-- ERROR: BLOCK NEW CYCLE 
			lexi.submenu["Enable"].value = "Off"
			
		end
	end
end
