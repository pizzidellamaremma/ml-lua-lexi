
-- MagicLantern long exposure intervalometer for stacking
-- v0.01 by Pizzi DellaMaremma 

require("logger")
local loglev = false  -- true if logging needed (log on console and file LEXI.LOG)

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
    }
}

-- trigger
function event.keypress(key)
	-- check halfshutter and enable
	if key == KEY.HALFSHUTTER and lexi.submenu["Enable"].value == "On" then
		
		-- setup logger
		if loglev == true then
			local log = logger("LEXI.LOG")
			log:write("LEXI - Init logging\n")
		end
		
		-- check bulb mode
		if camera.mode == MODE.BULB then
		
			-- set variables
			local init_delay = lexi.submenu["Initial delay"].value
			local exp_length = lexi.submenu["Exposure length"].value
			local dly = lexi.submenu["Delay"].value
			local reps = lexi.submenu["Repetitions"].value
			if loglev == true then
				log:write(string.format("LEXI - Entering cycle - init_delay: %s, exp_length: %s, delay: %s, reps: %s\n", 
					init_delay, exp_length, dly, reps))
			end
			
			display.notify_box("Starting LEXI...")
			sleep(init_delay)
			
			-- repeated shots
			local n = 1
			for i = reps, 1, -1 do
				display.notify_box(string.format("Running cycle %s", n))
				if loglev == true then
					log:write(string.format("LEXI - Running cycle %s\n", n))
				end
				camera.bulb(exp_length)
				
				if n == reps then 
					break
				else
					sleep(dly)
					n = n + 1
				end
			end	
			
			lexi.submenu["Enable"].value = "Off"
			if loglev == true then
				log:write("LEXI - End Cycle\n")
			end
			
			
		elseif camera.mode ~= MODE.BULB then 
			display.notify_box("LEXI error: not in Bulb mode.")
			if loglev == true then
				log:write("LEXI - Not in Bulb mode\n")
			end
		end
		if loglev == true then
			log:write("------------------------------\n")
			log:close()
		end
	end
end