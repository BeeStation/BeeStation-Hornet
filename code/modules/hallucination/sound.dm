/datum/hallucination/battle

/datum/hallucination/battle/New(mob/living/carbon/C, forced = TRUE, battle_type)
	set waitfor = FALSE
	..()
	var/turf/source = random_far_turf()
	if(!battle_type)
		battle_type = pick("laser","disabler","esword","gun","stunprod","harmbaton","bomb")
	feedback_details += "Type: [battle_type]"
	switch(battle_type)
		if("laser")
			var/hits = 0
			for(var/i in 1 to rand(5, 10))
				target.playsound_local(source, 'sound/weapons/laser.ogg', 25, 1)
				if(prob(50))
					addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, 'sound/weapons/sear.ogg', 25, 1), rand(5,10))
					hits++
				else
					addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, 'sound/weapons/effects/searwall.ogg', 25, 1), rand(5,10))
				sleep(rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 6))
				if(hits >= 4 && prob(70))
					target.playsound_local(source, get_sfx("bodyfall"), 25, 1)
					break
		if("disabler")
			var/hits = 0
			for(var/i in 1 to rand(5, 10))
				target.playsound_local(source, 'sound/weapons/taser2.ogg', 25, 1)
				if(prob(50))
					addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, 'sound/weapons/tap.ogg', 25, 1), rand(5,10))
					hits++
				else
					addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, 'sound/weapons/effects/searwall.ogg', 25, 1), rand(5,10))
				sleep(rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 6))
				if(hits >= 3 && prob(70))
					target.playsound_local(source, get_sfx("bodyfall"), 25, 1)
					break
		if("esword")
			target.playsound_local(source, 'sound/weapons/saberon.ogg',15, 1)
			for(var/i in 1 to rand(4, 8))
				target.playsound_local(source, 'sound/weapons/blade1.ogg', 50, 1)
				if(i == 4)
					target.playsound_local(source, get_sfx("bodyfall"), 25, 1)
				sleep(rand(CLICK_CD_MELEE, CLICK_CD_MELEE + 6))
			target.playsound_local(source, 'sound/weapons/saberoff.ogg', 15, 1)
		if("gun")
			var/hits = 0
			for(var/i in 1 to rand(3, 6))
				target.playsound_local(source, "sound/weapons/gunshot.ogg", 25, TRUE)
				if(prob(60))
					addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, 'sound/weapons/pierce.ogg', 25, 1), rand(5,10))
					hits++
				else
					addtimer(CALLBACK(target, /mob/.proc/playsound_local, source, "ricochet", 25, 1), rand(5,10))
				sleep(rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 6))
				if(hits >= 2 && prob(80))
					target.playsound_local(source, get_sfx("bodyfall"), 25, 1)
					break
		if("stunprod") //Stunprod + cablecuff
			target.playsound_local(source, 'sound/weapons/egloves.ogg', 40, 1)
			target.playsound_local(source, get_sfx("bodyfall"), 25, 1)
			sleep(20)
			target.playsound_local(source, 'sound/weapons/cablecuff.ogg', 15, 1)
		if("harmbaton") //zap n slap
			target.playsound_local(source, 'sound/weapons/egloves.ogg', 40, 1)
			target.playsound_local(source, get_sfx("bodyfall"), 25, 1)
			sleep(20)
			for(var/i in 1 to rand(5, 12))
				target.playsound_local(source, "swing_hit", 50, 1)
				sleep(rand(CLICK_CD_MELEE, CLICK_CD_MELEE + 4))
		if("bomb") // Tick Tock
			for(var/i in 1 to rand(3, 11))
				target.playsound_local(source, 'sound/items/timer.ogg', 25, 0)
				sleep(15)
	qdel(src)
/datum/hallucination/sounds

/datum/hallucination/sounds/New(mob/living/carbon/C, forced = TRUE, sound_type)
	set waitfor = FALSE
	..()
	var/turf/source = random_far_turf()
	if(!sound_type)
		sound_type = pick("airlock","airlock pry","console","explosion","far explosion","mech","glass","alarm","beepsky","mech","wall decon","door hack")
	feedback_details += "Type: [sound_type]"
	//Strange audio
	switch(sound_type)
		if("airlock")
			target.playsound_local(source,'sound/machines/airlock.ogg', 30, 1)
		if("airlock pry")
			target.playsound_local(source,'sound/machines/airlock_alien_prying.ogg', 100, 1)
			sleep(50)
			target.playsound_local(source, 'sound/machines/airlockforced.ogg', 30, 1)
		if("console")
			target.playsound_local(source,'sound/machines/terminal_prompt.ogg', 25, 1)
		if("explosion")
			if(prob(50))
				target.playsound_local(source,'sound/effects/explosion1.ogg', 50, 1)
			else
				target.playsound_local(source, 'sound/effects/explosion2.ogg', 50, 1)
		if("far explosion")
			target.playsound_local(source, 'sound/effects/explosionfar.ogg', 50, 1)
		if("glass")
			target.playsound_local(source, pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg'), 50, 1)
		if("alarm")
			target.playsound_local(source, 'sound/machines/alarm.ogg', 100, 0)
		if("beepsky")
			target.playsound_local(source, 'sound/voice/beepsky/freeze.ogg', 35, 0)
		if("mech")
			var/mech_dir = pick(GLOB.cardinals)
			for(var/i in 1 to rand(4,9))
				if(prob(75))
					target.playsound_local(source, 'sound/mecha/mechstep.ogg', 40, 1)
					source = get_step(source, mech_dir)
				else
					target.playsound_local(source, 'sound/mecha/mechturn.ogg', 40, 1)
					mech_dir = pick(GLOB.cardinals)
				sleep(10)
		//Deconstructing a wall
		if("wall decon")
			target.playsound_local(source, 'sound/items/welder.ogg', 50, 1)
			sleep(105)
			target.playsound_local(source, 'sound/items/welder2.ogg', 50, 1)
			sleep(15)
			target.playsound_local(source, 'sound/items/ratchet.ogg', 50, 1)
		//Hacking a door
		if("door hack")
			target.playsound_local(source, 'sound/items/screwdriver.ogg', 50, 1)
			sleep(rand(40,80))
			target.playsound_local(source, 'sound/machines/airlockforced.ogg', 30, 1)
	qdel(src)

/datum/hallucination/weird_sounds

/datum/hallucination/weird_sounds/New(mob/living/carbon/C, forced = TRUE, sound_type)
	set waitfor = FALSE
	..()
	var/turf/source = random_far_turf()
	if(!sound_type)
		sound_type = pick("phone","hallelujah","highlander","laughter","hyperspace","game over","creepy","tesla")
	feedback_details += "Type: [sound_type]"
	//Strange audio
	switch(sound_type)
		if("phone")
			target.playsound_local(source, 'sound/weapons/ring.ogg', 15)
			sleep(25)
			target.playsound_local(source, 'sound/weapons/ring.ogg', 15)
			sleep(25)
			target.playsound_local(source, 'sound/weapons/ring.ogg', 15)
			sleep(25)
			target.playsound_local(source, 'sound/weapons/ring.ogg', 15)
		if("hyperspace")
			target.playsound_local(null, 'sound/effects/hyperspace_begin.ogg', 50)
		if("hallelujah")
			target.playsound_local(source, 'sound/effects/pray_chaplain.ogg', 50)
		if("highlander")
			target.playsound_local(null, 'sound/misc/highlander.ogg', 50)
		if("game over")
			target.playsound_local(source, 'sound/misc/compiler-failure.ogg', 50)
		if("laughter")
			if(prob(50))
				target.playsound_local(source, 'sound/voice/human/womanlaugh.ogg', 50, 1)
			else
				target.playsound_local(source, pick('sound/voice/human/manlaugh1.ogg', 'sound/voice/human/manlaugh2.ogg'), 50, 1)
		if("creepy")
		//These sounds are (mostly) taken from Hidden: Source
			target.playsound_local(source, pick(GLOB.creepy_ambience), 50, 1)
		if("tesla") //Tesla loose!
			target.playsound_local(source, 'sound/magic/lightningbolt.ogg', 35, 1)
			sleep(30)
			target.playsound_local(source, 'sound/magic/lightningbolt.ogg', 65, 1)
			sleep(30)
			target.playsound_local(source, 'sound/magic/lightningbolt.ogg', 100, 1)

	qdel(src)
