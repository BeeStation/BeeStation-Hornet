/obj/item/integrated_circuit/mining/ore_analyzer
	name = "ore analyzer"
	desc = "Analyzes a rock for its ore type."
	extended_desc = "Takes a reference for an object and checks if it is a rock first. If that is the case, it outputs the mineral \
	inside the rock."
	category_text = "Mining"
	ext_cooldown = 1
	complexity = 20
	cooldown_per_use = 1 SECONDS
	inputs = list(
		"rock" = IC_PINTYPE_REF
		)
	outputs = list(
		"ore type" = IC_PINTYPE_STRING,
		"amount" = IC_PINTYPE_NUMBER
		)
	activators = list(
		"analyze" = IC_PINTYPE_PULSE_IN,
		"on analyzed" = IC_PINTYPE_PULSE_OUT,
		"on found" = IC_PINTYPE_PULSE_OUT
		)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 20
	var/turf/closed/mineral/rock
	var/mineral


/obj/item/integrated_circuit/mining/ore_analyzer/do_work()
	rock = get_pin_data(IC_INPUT, 1)
	if(!istype(rock,/turf/closed/mineral))
		mineral = null
		set_pin_data(IC_OUTPUT, 1, null)
		set_pin_data(IC_OUTPUT, 2, null)

		push_data()
		activate_pin(2)
		return

	if(rock.mineralType)
		mineral = "[rock.mineralType]"
		mineral = copytext(mineral, findlasttextEx(mineral, "/")+1)
	else
		mineral = "rock"

	set_pin_data(IC_OUTPUT, 1, mineral)
	set_pin_data(IC_OUTPUT, 2, rock.mineralAmt)
	push_data()

	activate_pin(2)
	activate_pin(3)


/obj/item/integrated_circuit/mining/mining_drill
	name = "mining drill"
	desc = "A mining drill that can drill through rocks."
	extended_desc = "A mining drill that activates on sensing a mineable rock. It takes some time to get the job done and \
	has to not be moved during that time."
	category_text = "Mining"
	ext_cooldown = 1
	complexity = 20
	cooldown_per_use = 3 SECONDS
	inputs = list(
		"rock" = IC_PINTYPE_REF
		)
	outputs = list()
	activators = list(
		"mine" = IC_PINTYPE_PULSE_IN,
		"on success" = IC_PINTYPE_PULSE_OUT,
		"on failure" = IC_PINTYPE_PULSE_OUT
		)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 100

	var/busy = FALSE
	var/usedx
	var/usedy
	var/turf/closed/mineral/rock

/obj/item/integrated_circuit/mining/mining_drill/do_work()
	rock = get_pin_data(IC_INPUT, 1)

	if(!rock)
		activate_pin(3)
		return
	if(!(ismineralturf(rock) && rock.Adjacent(assembly)) || busy)
		activate_pin(3)
		return

	busy = TRUE
	usedx = assembly.loc.x
	usedy = assembly.loc.y
	playsound(src, 'sound/items/drill_use.ogg',50,1)
	addtimer(CALLBACK(src, .proc/drill), 50)


/obj/item/integrated_circuit/mining/mining_drill/proc/drill()
	busy = FALSE
	// The assembly was moved, hence stopping the mining OR the rock was mined before
	if(usedx != assembly.loc.x || usedy != assembly.loc.y || !rock)	
		activate_pin(3)
		return FALSE

	activate_pin(2)
	rock.gets_drilled()
	return(TRUE)
