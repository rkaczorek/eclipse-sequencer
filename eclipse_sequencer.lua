-- Eclipse Sequencer
-- Version 1.0.0
-- Auto Sequencer for Total Solar Eclipse
--
-- Copyright 2019 by Radek Kaczorek, rkaczorek@gmail.com
-- Distributed under the GNU General Public License.
-- Inspired by Eclipse Magic by Brian Greenberg, grnbrg@grnbrg.org

require ("logger")

--
--	Script init parameters. DO NOT change these
--
TestStartTime = 0		-- do not change, global init
LoggingFile = nil		-- do not change, global init
c1 = {}					-- do not change, global init
c2 = {}					-- do not change, global init
c3 = {}					-- do not change, global init
c4 = {}					-- do not change, global init

--
--	Eclipse timing parameters. SET reliable times for each phase
--	You can use Solar Eclipse Calculator: http://xjubier.free.fr/en/site_pages/SolarEclipseCalc_Diagram.html
--

-- Chile 2019 (local time): 15:22:15 16:38:19 16:39:53 17:46:25
c1.hr = 15; c1.min = 22; c1.sec = 16;	--	Set C1 time here
c2.hr = 16; c2.min = 38; c2.sec = 19;	--	Set C2 time here
c3.hr = 16; c3.min = 39; c3.sec = 55;	--	Set C3 time here
c4.hr = 17; c4.min = 46; c4.sec = 26;	--	Set C4 time here

-- Local adjustment based on Solar Eclipse Calculator
-- Set DeltaTime to LC parameter from the Solar Eclipse Calculator
DeltaTime = 2

--
--	Configurable parameters. YOU CAN change these
--
TestMode = 0			-- can be changed from menu
LogToFile = 1			-- set to 0 to disable logging to eclipse.log file
MinShutter = (1/4096)	-- depends on camera model
MaxShutter = 30			-- depends on camera model
TimeZone = -4			-- local time zone
UseUTC = 0				-- set to 1 if you use UTC time on your camera
LeadTime = 180			-- number of seconds to start sequence before c1
TrailTime = 180			-- number of seconds to end sequence after c4
PartialDelay = 30		-- number of seconds between partial images

--
--	==============================================
--		DO NOT change anything below this line
--	==============================================
--

if (TestMode == 1)
then
	c1.hr = 0; c1.min =  1; c1.sec = 00;
	c2.hr = 0; c2.min =  2; c2.sec = 00;
	c3.hr = 0; c3.min =  3; c3.sec = 00;
	c4.hr = 0; c4.min =  4; c4.sec = 00;
end

if (UseUTC == 1)	-- Change local time to UTC
then
	c1.hr = c1.hr + TimeZone
	c2.hr = c2.hr + TimeZone
	c3.hr = c3.hr + TimeZone
	c4.hr = c4.hr + TimeZone
end

--
-- Change time to seconds from midnight. We use this for timing all events
-- This approach ensures that the sequence resumes in proper time if you need
-- to change battery or you start the sequence in the middle of the event
--
c1_sec = c1.hr * 3600 + c1.min * 60 + c1.sec 
c2_sec = c2.hr * 3600 + c2.min * 60 + c2.sec 
c3_sec = c3.hr * 3600 + c3.min * 60 + c3.sec 
c4_sec = c4.hr * 3600 + c4.min * 60 + c4.sec

totality_sec = math.floor(c2_sec + ((c3_sec - c2_sec) / 2))
c2_sec = c2_sec + DeltaTime
c3_sec = c3_sec - DeltaTime

function sequence_partial (start_time, end_time, shutter_start, shutter_end, iso)
	local timenow = now()
	local counter = 1
	local shutter_speed = shutter_start
	local shutter_step = 0
	if (timenow >= end_time)
	then
		log ("%s: Skipping partial sequence due to time passed %d seconds ago", pretty_time(timenow), (timenow - end_time))
		return
	end
	log ("%s: Partial sequence starting in %d seconds", pretty_time(timenow), (start_time - timenow))
	sleep_until (start_time) -- wait for sequence start
	-- The sequence
	log ("%s: Partial sequence starting now", pretty_time(timenow))	

	if ((end_time - timenow) > PartialDelay)
	then
		counter = math.floor((end_time - timenow) / PartialDelay)	-- calculate number of images we can capture
	end

	if (shutter_end ~= shutter_start)	-- calculate shutter speed step throughout the sequence
	then
		shutter_step = (math.log((shutter_end / shutter_start),2) / counter)
	end

	for i = 1,counter,1	-- run the sequence
	do
		log ("%s: Partial sequence image %d/%d @ iso: %d, shutter speed: %s", pretty_time(timenow), i, counter, iso, pretty_shutter(shutter_speed))
		timenow = now()
		if (timenow >= end_time)
		then
			log ("%s: No time for another image. Quiting sequence.", pretty_time(timenow))
			return
		end
		capture_image (iso, shutter_speed)
		shutter_speed = shutter_speed * 2.0^shutter_step
		
		timenow = now()
		if ((timenow + PartialDelay) < end_time)
		then
			sleep_until (timenow + PartialDelay)
		else
			return
		end
	end
end

function sequence_diamond_ring (start_time, end_time, shutter_speed, iso)
	local timenow = now()
	if (timenow >= end_time)
	then
		log ("%s: Skipping diamond ring sequence due to time passed %d seconds ago", pretty_time(timenow), (timenow - end_time))
		return
	end
	log ("%s: Diamond ring sequence starting in %d seconds", pretty_time(timenow), (start_time - timenow))
	sleep_until (start_time) -- wait for sequence start
	-- The sequence
	log ("%s: Diamond ring sequence starting now", pretty_time(timenow))
	repeat
		timenow = now()
		capture_image (iso, shutter_speed)
	until (timenow >= end_time)
end

function sequence_baileys_beads (start_time, end_time, shutter_speed, iso)
	local timenow = now()
	if (timenow >= end_time)
	then
		log ("%s: Skipping baileys beads sequence due to time passed %d seconds ago", pretty_time(timenow), (timenow - end_time))
		return
	end
	log ("%s: Bailey's beads sequence starting in %d seconds", pretty_time(timenow), (start_time - timenow))
	sleep_until (start_time) -- wait for sequence start
	-- The sequence
	log ("%s: Bailey's beads sequence starting now", pretty_time(timenow))
	repeat
		timenow = now()
		capture_image (iso, shutter_speed)
	until (timenow >= end_time)	
end

function sequence_chromosphere (start_time, end_time, shutter_speed, iso)
	local timenow = now()
	if (timenow >= end_time)
	then
		log ("%s: Skipping chromosphere sequence due to time passed %d seconds ago", pretty_time(timenow), (timenow - end_time))
		return
	end
	log ("%s: Chromosphere sequence starting in %d seconds", pretty_time(timenow), (start_time - timenow))
	sleep_until (start_time) -- wait for sequence start
	-- The sequence
	log ("%s: Chromosphere sequence starting now", pretty_time(timenow))
	repeat
		timenow = now()
		capture_image (iso, shutter_speed)
	until (timenow >= end_time)	
end

function sequence_totality (start_time, end_time, shutter_start, shutter_end, iso)
	local timenow = now()
	local counter = 1
	local shutter_speed = shutter_start	-- preset shutter for the first loop
	if (timenow > totality_sec)			-- reverse shutter changes after mid totality
	then
		shutter_speed = shutter_end
	end
	local shutter_step = 0.5
	if (timenow >= end_time)
	then
		log ("%s: Skipping totality sequence due to time passed %d seconds ago", pretty_time(timenow), (timenow - end_time))
		return
	end
	log ("%s: Totality sequence starting in %d seconds", pretty_time(timenow), (start_time - timenow))
	sleep_until (start_time) -- wait for sequence start
	-- The sequence
	log ("%s: Totality sequence starting now", pretty_time(timenow))	

	counter = math.floor(math.log((shutter_end / shutter_start),2) / shutter_step)	-- calculate number of images we can capture
	
	local loopcount = 1	
	repeat	-- run the sequence
		log ("%s: Totality sequence loop %d", pretty_time(timenow), loopcount)
		for i = 1,counter,1
		do		
			log ("%s: Totality sequence image %d/%d @ iso: %d, shutter speed: %s", pretty_time(timenow), i, counter, iso, pretty_shutter(shutter_speed))
			timenow = now()	-- security valve
			if (timenow >= end_time)
			then
				log ("%s: No time for another image. Quiting sequence.", pretty_time(timenow))
				return
			end
			capture_image (iso, shutter_speed)
			if (timenow < totality_sec)
			then
				shutter_speed = shutter_speed * 2.0^shutter_step
			else
			 	shutter_speed = shutter_speed / 2.0^shutter_step
			end
		end
		loopcount = loopcount + 1
		timenow = now()
		shutter_speed = shutter_start	-- reset shutter for the next loop
		if (timenow > totality_sec)		-- reverse shutter changes after mid totality
		then
			shutter_speed = shutter_end
		end
	until (timenow >= end_time)
end

function sequence_eartshine (start_time, end_time, shutter_speed, iso)
	local timenow = now()
	if (timenow >= end_time)
	then
		log ("%s: Skipping eartshine sequence due to time passed %d seconds ago", pretty_time(timenow), (timenow - end_time))
		return
	end
	log ("%s: Earthshine sequence starting in %d seconds", pretty_time(timenow), (start_time - timenow))
	sleep_until (start_time) -- wait for sequence start
	-- The sequence
	log ("%s: Earthshine sequence starting now", pretty_time(timenow))
	repeat
		timenow = now()
		capture_image (iso, shutter_speed)
	until (timenow >= end_time)
end

function filter_warning (warning_time)
	local timenow = now()
	if (timenow >= warning_time)
	then
		log ("%s: Skipping filter warning due to time passed %d seconds ago", pretty_time(timenow), (timenow - warning_time))
		return
	end
	log ("==================================")
	log ("==================================")
	log ("%s: Filter warning in %d seconds", pretty_time(timenow), (warning_time - timenow))
	log ("==================================")
	log ("==================================")
	sleep_until (warning_time) -- wait for sequence start
	if (timenow < totality_sec)
	then
		log ("==================================")
		log ("==================================")
		log ("%s: Remove filter !!!", pretty_time(timenow))
		log ("==================================")
		log ("==================================")
	else
		log ("==================================")
		log ("==================================")
		log ("%s: Replace filter !!!", pretty_time(timenow))
		log ("==================================")
		log ("==================================")
	end
end

--
-- Open log file
--
function log_start ()
	if (LogToFile ~= 0)
	then
		local now = dryos.date
		local filename = string.format("eclipse.log")
		print (string.format ("Open log file %s", filename))
		LoggingFile = logger (filename)
	else
		print (string.format ("Logging disabled"))
	end
end

--
-- Close log file
--
function log_stop ()
	if (LogToFile ~= 0)
	then
		print (string.format ("Close log file"))
		LoggingFile:close ()
	end
end

--
-- Log to file
--
function log (s, ...)
	local str = string.format (s, ...)
	str = str .. "\n"
	if (LogToFile == 1)
	then
		LoggingFile:write (str)
	end
	return
end

--
--	Get current time in seconds (from midnight)
--
function now()
	local now = dryos.date
	local seconds = (now.hour * 3600 + now.min * 60 + now.sec)

	if (TestMode == 1)
	then
		seconds = (seconds - TestStartTime)
	end
	return seconds
end

--
--	Sleep predefined number of seconds
--
function sleep_until (targettime)
	local timenow = now()
	log ("%s: Sleeping %d seconds until %s.", pretty_time(now()), targettime - timenow, pretty_time(targettime))
	repeat
		msleep(500)
		timenow = now()
	until((timenow > (targettime - 1)))
end

--
-- Take current time in seconds (from midnight) and convert it to HH:MM:SS
--
function pretty_time (time_secs)
	local text_time = ""
	local hrs = 0
	local mins = 0
	local secs = 0
	
	hrs =  math.floor(time_secs / 3600)
    mins = math.floor((time_secs - (hrs * 3600)) / 60)
	secs = (time_secs - (hrs*3600) - (mins * 60))
	text_time = string.format("%02d:%02d:%02d", hrs, mins, secs)
	return text_time
end

--
-- Take shutter speed expressed in fractional seconds and convert it to 1/x
--
function pretty_shutter (shutter_speed)
	local text_time = ""

	if (shutter_speed >= 1.0)
	then
		text_time = tostring (shutter_speed)
	else
		text_time = string.format ("1/%s", tostring (1/shutter_speed))
	end
	return text_time
end

--
-- Capture an image with or without bracketing. Sequence: -,0,+
--
function capture_image(iso, shutter_speed, bktcount, bktstep)
	bktcount = bktcount or 0
	bktstep = bktstep or 0
	
	local bktspeed = 0.0	
	camera.iso.value = iso

	if (shutter_speed < MinShutter or shutter_speed > MaxShutter ) -- warn user of invalid shutter speed and skip image capture
	then
	
		log ("%s: Skipping image! Invalid shutter speed!!! (Min: %s s, Max: %s s)", 
			pretty_time(now()), pretty_shutter(MinShutter), pretty_shutter(MaxShutter))
		return 
	end
	
	-- If braketing run - brackets
	if (bktcount > 0)
	then
		log ("%s: Capturing image with bracketing @ Brackets: %d Step: %s", 
			pretty_time(now()), bktcount, tostring(bktstep))

		for i = bktcount,1,-1
		do
			bktspeed = shutter_speed / (2.0^(i * bktstep))

			if (bktspeed < MinShutter) -- prevent shutter speed going below minimum
			then
				bktspeed = MinShutter
			end

			camera.shutter.value = bktspeed
			
			log ("%s: Capturing - bracket image %d/%d @ ISO: %s Shutter: %s", 
				pretty_time(now()), (bktcount - i + 1), bktcount, tostring(camera.iso.value), pretty_shutter(camera.shutter.value))

			if (TestMode == 0)
			then
				camera.shoot(false)
				msleep(100)
			else		
				msleep(camera.shutter.ms + 100)		
			end
		end
	end

	-- Just capture an image without brackets
	camera.shutter.value = shutter_speed

	log ("%s: Capturing image @ ISO: %s Shutter: %s", 
		pretty_time(now()), tostring(camera.iso.value), pretty_shutter(camera.shutter.value))

	if (TestMode == 0) 
	then
		camera.shoot(false)
		msleep(100)
	else
		msleep(camera.shutter.ms + 100)
	end

	-- If braketing run + brackets
	if (bktcount > 0)
	then
		for i = 1,bktcount,1
		do
			bktspeed = shutter_speed * (2.0^(i * bktstep))

			if (bktspeed > MaxShutter) -- prevent shutter speed going over maximum
			then
				bktspeed = MaxShutter
			end
			
			camera.shutter.value = bktspeed
			
			log ("%s: Capturing + bracket image %d/%d @ ISO: %s Shutter: %s", 
				pretty_time(now()), i, bktcount, tostring(camera.iso.value), pretty_shutter(camera.shutter.value))

			if (TestMode == 0)
			then
				camera.shoot(false)
				msleep(100)
			else		
				msleep(camera.shutter.ms + 100)		
			end
		end
	end
end

--
-- Capture images in burst mode
--
function capture_burst(iso, shutter_speed, counter)
	camera.shutter.value = shutter_speed
	camera.iso.value = iso
		
	log ("%s: Capturing %d images in burst", 
		pretty_time(now()), counter)
	for i = 1,counter,1
	do
		log ("%s: Capturing image %d/%d @ ISO: %s shutter: %s", 
			pretty_time(now()), i, counter, tostring(camera.iso.value), pretty_shutter(camera.shutter.value))

		if (TestMode == 0)
		then
			capture_image(iso, shutter_speed)
			msleep(100)
		else
			msleep(counter * (camera.shutter.ms + 100))		
		end
	end
end

--
--	Main routine
--
function main()
	TestStartTime = now()
	
	menu.close()
	console.show()
	log_start ()


	if (eclipse_menu.submenu["Test Mode"].value == "ON")
	then
		TestMode = 1
	else
		TestMode = 0
	end

	print ()
	print ("-------------------------------------")
	print ("  Eclipse Sequencer")
	print ("  Copyright 2019, rkaczorek@gmail.com")
	print ("  Released under the GNU GPL")
	print ("-------------------------------------")
	print ()

	if (TestMode == 1)
	then
		log ("==================")
		log ("== Test Mode ON ==")
		log ("==================")
	end

	if (camera.mode ~= MODE.M)
	then
		log  ("Camera must be in manual (M) mode")
		display.print("Press any button to exit the script. Change the mode and re-run.")		
		key.wait()
		console.hide()
		display.clear()
		display.off()
		menu.block(false)
		return
	end

	local timenow = now()
	log("System Time: %d", timenow)
	log("C1: %d", c1_sec)
	log("C2: %d", c2_sec)
	log("C3: %d", c3_sec)
	log("C4: %d", c4_sec)

	--
	--	Sequence of events at Total Solar Eclipse
	--
	--		Example exposures for focal ratio: F/9		ISO		Exposure
	--													---		-------------
	-- c1 to c2:			partial eclipse				100		1/500 - 1/250
	-- c2-20s:				remove camera filter!
	-- c2-15s to c2-11s:	diamond ring				100		1/80
	-- c2-10s to c2-3s:		bailey's beads				100		1/2000
	-- c2-2s to c2+5s:		chromosphere				100		1/1000 - 1/500
	-- totality start		lower to outer corona		100		1/250 - 1
	-- totality mid			eartshine					1600	1
	-- totality end			lower to outer corona		100		1/250 - 1
	-- c3-5s to c3+2s:		chromosphere				100		1/1000 - 1/500
	-- c3+3s to c3+10s:		bailey's beads				100		1/2000
	-- c3+11s to c3+15s:	diamond ring				100		1/80
	-- c3+20s:				replace camera filter!
	-- c3 to c4:			partial eclipse				100		1/250 - 1/2

	-- Main solar eclipse sequence
	sequence_partial ((c1_sec - LeadTime), (c2_sec - 21), (1/500), (1/250), 100)
	filter_warning ((c2_sec - 20))
	sequence_diamond_ring ((c2_sec - 15), (c2_sec - 11), (1/40), 100)
	sequence_baileys_beads ((c2_sec - 10), (c2_sec - 3), (1/2000), 100)
	sequence_chromosphere ((c2_sec - 2), (c2_sec + 5), (1/1000), 100)
	sequence_totality ((c2_sec + 6), (totality_sec - 11), (1/250), 1.0, 200)
	sequence_eartshine ((totality_sec - 10), (totality_sec + 10), 1.0, 1600)
	sequence_totality ((totality_sec + 11), (c3_sec - 6), (1/250), 1.0, 200)
	sequence_chromosphere ((c3_sec - 5), (c3_sec + 2), (1/1000), 100)
	sequence_baileys_beads ((c3_sec + 3), (c3_sec + 10), (1/2000), 100)
	sequence_diamond_ring ((c3_sec + 11), (c3_sec + 15), (1/40), 100)
	filter_warning ((c3_sec + 20))
	sequence_partial ((c3_sec + 21), (c4_sec + TrailTime), (1/250), (1/2), 100)

	log ("%s: All done", pretty_time(now()))
	log_stop ()
	print("Press any button to exit")
	key.wait()
	console.hide()
end

--
-- Menu item
--
eclipse_menu = menu.new
{
    name   = "Eclipse Sequencer",
    help   = "Auto Sequencer for Solar Eclipse",
    submenu = 
    {
        {
            name = "Run",
            help = "Run this script",
            select = function(this) task.create(main) end
        },
        {
            name = "Test Mode",
            help = "Run test or real world",
            choices = {"ON", "OFF"}
        }
    }
}
