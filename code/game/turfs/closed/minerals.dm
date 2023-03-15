/**********************Mineral deposits**************************/

/turf/closed/mineral //wall piece
	name = "rock"
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock"
	base_icon_state = "smoothrocks"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_MINERAL_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_MINERAL_WALLS)
	var/smooth_icon = 'icons/turf/smoothrocks.dmi'
	baseturfs = /turf/open/floor/plating/asteroid/airless
	initial_gas_mix = AIRLESS_ATMOS
	opacity = 1
	density = TRUE
	layer = EDGED_TURF_LAYER
	initial_temperature = 293.15
	var/environment_type = "asteroid"
	var/turf/open/floor/plating/turf_type = /turf/open/floor/plating/asteroid/airless
	var/obj/item/stack/ore/mineralType = null
	var/mineralAmt = 3
	var/last_act = 0
	var/scan_state = "" //Holder for the image we display when we're pinged by a mining scanner
	var/defer_change = 0

/turf/closed/mineral/Initialize(mapload)
	var/matrix/M = new
	M.Translate(-4, -4)
	transform = M
	icon = smooth_icon
	. = ..()

/turf/closed/mineral/proc/Spread_Vein()
	var/spreadChance = initial(mineralType.spreadChance)
	if(spreadChance)
		for(var/dir in GLOB.cardinals)
			if(prob(spreadChance))
				var/turf/T = get_step(src, dir)
				var/turf/closed/mineral/random/M = T
				if(istype(M) && !M.mineralType)
					M.Change_Ore(mineralType)

/turf/closed/mineral/proc/Change_Ore(var/ore_type, random = 0)
	if(random)
		mineralAmt = rand(1, 5)
	if(ispath(ore_type, /obj/item/stack/ore)) //If it has a scan_state, switch to it
		var/obj/item/stack/ore/the_ore = ore_type
		scan_state = initial(the_ore.scan_state) // I SAID. SWITCH. TO. IT.
		mineralType = ore_type // Everything else assumes that this is typed correctly so don't set it to non-ores thanks.

/turf/closed/mineral/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	if(turf_type)
		underlay_appearance.icon = initial(turf_type.icon)
		underlay_appearance.icon_state = initial(turf_type.icon_state)
		return TRUE
	return ..()


/turf/closed/mineral/attackby(obj/item/I, mob/user, params)
	if (!user.IsAdvancedToolUser())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(I.tool_behaviour == TOOL_MINING)
		var/turf/T = user.loc
		if (!isturf(T))
			return

		if(last_act + (40 * I.toolspeed) > world.time)//prevents message spam
			return
		last_act = world.time
		to_chat(user, "<span class='notice'>You start picking...</span>")

		if(I.use_tool(src, user, 40, volume=50))
			if(ismineralturf(src))
				to_chat(user, "<span class='notice'>You finish cutting into the rock.</span>")
				gets_drilled(user)
				SSblackbox.record_feedback("tally", "pick_used_mining", 1, I.type)
	else
		return attack_hand(user)

/turf/closed/mineral/proc/gets_drilled()
	if (mineralType && (mineralAmt > 0))
		new mineralType(src, mineralAmt)
		SSblackbox.record_feedback("tally", "ore_mined", mineralAmt, mineralType)
	for(var/obj/effect/temp_visual/mining_overlay/M in src)
		qdel(M)
	var/flags = NONE
	if(defer_change) // TODO: make the defer change var a var for any changeturf flag
		flags = CHANGETURF_DEFER_CHANGE
	ScrapeAway(null, flags)
	addtimer(CALLBACK(src, PROC_REF(AfterChange)), 1, TIMER_UNIQUE)
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1) //beautiful destruction

/turf/closed/mineral/attack_animal(mob/living/simple_animal/user)
	if((user.environment_smash & ENVIRONMENT_SMASH_WALLS) || (user.environment_smash & ENVIRONMENT_SMASH_RWALLS))
		gets_drilled()
	..()

/turf/closed/mineral/attack_alien(mob/living/carbon/alien/M)
	to_chat(M, "<span class='notice'>You start digging into the rock...</span>")
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1)
	if(do_after(M, 40, target = src))
		to_chat(M, "<span class='notice'>You tunnel into the rock.</span>")
		gets_drilled(M)

/turf/closed/mineral/Bumped(atom/movable/AM)
	..()
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		var/obj/item/I = H.is_holding_tool_quality(TOOL_MINING)
		if(I)
			attackby(I, H)
		return
	else if(iscyborg(AM))
		var/mob/living/silicon/robot/R = AM
		if(R.module_active && R.module_active.tool_behaviour == TOOL_MINING)
			attackby(R.module_active, R)
			return
	else
		return

/turf/closed/mineral/acid_melt()
	ScrapeAway()

/turf/closed/mineral/ex_act(severity, target)
	..()
	switch(severity)
		if(3)
			if (prob(75))
				gets_drilled(null, 1)
		if(2)
			if (prob(90))
				gets_drilled(null, 1)
		if(1)
			gets_drilled(null, 1)
	return

/turf/closed/mineral/random
	var/list/mineralSpawnChanceList = list(/obj/item/stack/ore/uranium = 5, /obj/item/stack/ore/diamond = 1, /obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/silver = 12, /obj/item/stack/ore/plasma = 20, /obj/item/stack/ore/iron = 40, /obj/item/stack/ore/titanium = 11,
		/turf/closed/mineral/gibtonite = 4, /obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/ore/copper = 15)
		//Currently, Adamantine won't spawn as it has no uses. -Durandan
	var/mineralChance = 13

/turf/closed/mineral/random/Initialize(mapload)

	mineralSpawnChanceList = typelist("mineralSpawnChanceList", mineralSpawnChanceList)

	. = ..()
	if (prob(mineralChance))
		var/path = pickweight(mineralSpawnChanceList)
		if(ispath(path, /turf))
			var/turf/T = ChangeTurf(path,null,CHANGETURF_IGNORE_AIR)

			T.baseturfs = src.baseturfs
			if(ismineralturf(T))
				var/turf/closed/mineral/M = T
				M.turf_type = src.turf_type
				M.mineralAmt = rand(1, 5)
				M.environment_type = src.environment_type
				src = M
				M.levelupdate()
			else
				src = T
				T.levelupdate()

		else
			Change_Ore(path, 1)
			Spread_Vein(path)

/turf/closed/mineral/random/high_chance
	icon_state = "rock_highchance"
	mineralChance = 25
	mineralSpawnChanceList = list(
		/obj/item/stack/ore/uranium = 35, /obj/item/stack/ore/diamond = 30, /obj/item/stack/ore/gold = 45, /obj/item/stack/ore/titanium = 45,
		/obj/item/stack/ore/silver = 50, /obj/item/stack/ore/copper = 50, /obj/item/stack/ore/plasma = 50, /obj/item/stack/ore/bluespace_crystal = 20)

/turf/closed/mineral/random/high_chance/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1
	mineralSpawnChanceList = list(
		/obj/item/stack/ore/uranium = 35, /obj/item/stack/ore/diamond = 30, /obj/item/stack/ore/gold = 45, /obj/item/stack/ore/titanium = 45,
		/obj/item/stack/ore/silver = 50, /obj/item/stack/ore/copper = 50, /obj/item/stack/ore/plasma = 50, /obj/item/stack/ore/bluespace_crystal)


/turf/closed/mineral/random/low_chance
	icon_state = "rock_lowchance"
	mineralChance = 6
	mineralSpawnChanceList = list(
		/obj/item/stack/ore/uranium = 2, /obj/item/stack/ore/diamond = 1, /obj/item/stack/ore/gold = 4, /obj/item/stack/ore/titanium = 4,
		/obj/item/stack/ore/silver = 6, /obj/item/stack/ore/copper = 6, /obj/item/stack/ore/plasma = 15, /obj/item/stack/ore/iron = 40,
		/turf/closed/mineral/gibtonite = 2, /obj/item/stack/ore/bluespace_crystal = 1)


/turf/closed/mineral/random/snowmountain/cavern
	name = "ice cavern rock"
	icon = 'icons/turf/mining.dmi'
	smooth_icon = 'icons/turf/walls/icerock_wall.dmi'
	icon_state = "icerock_wall"
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	baseturfs = /turf/open/floor/plating/asteroid/basalt/iceland_surface
	environment_type = "snow_cavern"
	turf_type = /turf/open/floor/plating/asteroid/basalt/iceland_surface
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE
	mineralChance = 6
	mineralSpawnChanceList = list(
		/obj/item/stack/ore/uranium = 2, /obj/item/stack/ore/diamond = 1, /obj/item/stack/ore/gold = 4, /obj/item/stack/ore/titanium = 4,
		/obj/item/stack/ore/silver = 6, /obj/item/stack/ore/copper = 6, /obj/item/stack/ore/plasma = 15, /obj/item/stack/ore/iron = 40,
		/turf/closed/mineral/gibtonite = 2, /obj/item/stack/ore/bluespace_crystal = 1)


/turf/closed/mineral/random/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1

	mineralChance = 10
	mineralSpawnChanceList = list(
		/obj/item/stack/ore/uranium = 5, /obj/item/stack/ore/diamond = 1, /obj/item/stack/ore/gold = 10, /obj/item/stack/ore/titanium = 11,
		/obj/item/stack/ore/silver = 12, /obj/item/stack/ore/copper = 12, /obj/item/stack/ore/plasma = 20, /obj/item/stack/ore/iron = 40,
		/turf/closed/mineral/gibtonite/volcanic = 4, /obj/item/stack/ore/bluespace_crystal = 1)


/turf/closed/mineral/random/labormineral
	mineralSpawnChanceList = list(
		/obj/item/stack/ore/uranium = 3, /obj/item/stack/ore/diamond = 1, /obj/item/stack/ore/gold = 8, /obj/item/stack/ore/titanium = 8,
		/obj/item/stack/ore/silver = 20, /obj/item/stack/ore/copper = 20, /obj/item/stack/ore/plasma = 30, /obj/item/stack/ore/iron = 95,
		/turf/closed/mineral/gibtonite = 2)
	icon_state = "rock_labor"


/turf/closed/mineral/random/labormineral/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1
	mineralSpawnChanceList = list(
		/obj/item/stack/ore/uranium = 3, /obj/item/stack/ore/diamond = 1, /obj/item/stack/ore/gold = 8, /obj/item/stack/ore/titanium = 8,
		/obj/item/stack/ore/silver = 20, /obj/item/stack/ore/copper = 20, /obj/item/stack/ore/plasma = 30, /obj/item/stack/ore/bluespace_crystal = 1, /turf/closed/mineral/gibtonite/volcanic = 2,
		/obj/item/stack/ore/iron = 95)

// Subtypes for mappers placing ores manually.

/turf/closed/mineral/iron
	mineralType = /obj/item/stack/ore/iron
	scan_state = "rock_Iron"

/turf/closed/mineral/iron/ice
	environment_type = "snow_cavern"
	icon_state = "icerock_iron"
	base_icon_state = "icerock_wall"
	smooth_icon = 'icons/turf/walls/icerock_wall.dmi'
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/uranium
	mineralType = /obj/item/stack/ore/uranium
	scan_state = "rock_Uranium"

/turf/closed/mineral/uranium/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1


/turf/closed/mineral/diamond
	mineralType = /obj/item/stack/ore/diamond
	scan_state = "rock_Diamond"

/turf/closed/mineral/diamond/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1

/turf/closed/mineral/diamond/ice
	environment_type = "snow_cavern"
	icon_state = "icerock_iron"
	base_icon_state = "icerock_wall"
	smooth_icon = 'icons/turf/walls/icerock_wall.dmi'
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/gold
	mineralType = /obj/item/stack/ore/gold
	scan_state = "rock_Gold"

/turf/closed/mineral/gold/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1


/turf/closed/mineral/silver
	mineralType = /obj/item/stack/ore/silver
	scan_state = "rock_Silver"

/turf/closed/mineral/silver/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1

/turf/closed/mineral/copper
	mineralType = /obj/item/stack/ore/copper
	scan_state = "rock_Copper"

/turf/closed/mineral/copper/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1

/turf/closed/mineral/titanium
	mineralType = /obj/item/stack/ore/titanium
	scan_state = "rock_Titanium"

/turf/closed/mineral/titanium/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1


/turf/closed/mineral/plasma
	mineralType = /obj/item/stack/ore/plasma
	scan_state = "rock_Plasma"

/turf/closed/mineral/plasma/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1

/turf/closed/mineral/plasma/ice
	environment_type = "snow_cavern"
	icon_state = "icerock_plasma"
	base_icon_state = "icerock_wall"
	smooth_icon = 'icons/turf/walls/icerock_wall.dmi'
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/bananium
	mineralType = /obj/item/stack/ore/bananium
	mineralAmt = 3
	scan_state = "rock_Bananium"

/turf/closed/mineral/bscrystal
	mineralType = /obj/item/stack/ore/bluespace_crystal
	mineralAmt = 1
	scan_state = "rock_BScrystal"

/turf/closed/mineral/bscrystal/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1


/turf/closed/mineral/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt
	baseturfs = /turf/open/floor/plating/asteroid/basalt
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/closed/mineral/volcanic/lava_land_surface
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	defer_change = 1

/turf/closed/mineral/ash_rock //wall piece
	name = "rock"
	icon = 'icons/turf/mining.dmi'
	smooth_icon = 'icons/turf/walls/rock_wall.dmi'
	icon_state = "rock2"
	base_icon_state = "rock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	canSmoothWith = list(SMOOTH_GROUP_CLOSED_TURFS)
	baseturfs = /turf/open/floor/plating/ashplanet/wateryrock
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	environment_type = "waste"
	turf_type = /turf/open/floor/plating/ashplanet/rocky
	defer_change = 1

/turf/closed/mineral/snowmountain
	name = "snowy mountainside"
	icon = 'icons/turf/mining.dmi'
	smooth_icon = 'icons/turf/walls/mountain_wall.dmi'
	icon_state = "mountain_wall"
	base_icon_state = "mountain_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	canSmoothWith = list(SMOOTH_GROUP_CLOSED_TURFS)
	baseturfs = /turf/open/floor/plating/asteroid/snow
	initial_gas_mix = FROZEN_ATMOS
	environment_type = "snow"
	turf_type = /turf/open/floor/plating/asteroid/snow
	defer_change = TRUE

/turf/closed/mineral/snowmountain/cavern
	name = "ice cavern rock"
	icon = 'icons/turf/mining.dmi'
	smooth_icon = 'icons/turf/walls/icerock_wall.dmi'
	icon_state = "icerock_wall"
	base_icon_state = "icerock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	baseturfs = /turf/open/floor/plating/asteroid/basalt/iceland_surface
	environment_type = "snow_cavern"
	turf_type = /turf/open/floor/plating/asteroid/basalt/iceland_surface


//GIBTONITE

/turf/closed/mineral/gibtonite
	mineralAmt = 1
	scan_state = "rock_Gibtonite"
	var/det_time = 8 //Countdown till explosion, but also rewards the player for how close you were to detonation when you defuse it
	var/stage = GIBTONITE_UNSTRUCK //How far into the lifecycle of gibtonite we are
	var/activated_ckey = null //These are to track who triggered the gibtonite deposit for logging purposes
	var/activated_name = null
	var/mutable_appearance/activated_overlay

/turf/closed/mineral/gibtonite/Initialize(mapload)
	det_time = rand(8,10) //So you don't know exactly when the hot potato will explode
	. = ..()

/turf/closed/mineral/gibtonite/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mining_scanner) || istype(I, /obj/item/t_scanner/adv_mining_scanner) && stage == 1)
		user.visible_message("<span class='notice'>[user] holds [I] to [src]...</span>", "<span class='notice'>You use [I] to locate where to cut off the chain reaction and attempt to stop it...</span>")
		defuse()
	..()

/turf/closed/mineral/gibtonite/proc/explosive_reaction(mob/user = null, triggered_by_explosion = 0)
	if(stage == GIBTONITE_UNSTRUCK)
		activated_overlay = mutable_appearance('icons/turf/smoothrocks.dmi', "rock_Gibtonite_active", ON_EDGED_TURF_LAYER)
		add_overlay(activated_overlay)
		name = "gibtonite deposit"
		desc = "An active gibtonite reserve. Run!"
		stage = GIBTONITE_ACTIVE
		visible_message("<span class='danger'>There was gibtonite inside! It's going to explode!</span>")

		var/notify_admins = 0
		if(z != 5)
			notify_admins = TRUE

		if(!triggered_by_explosion)
			log_bomber(user, "has trigged a gibtonite deposit reaction via", src, null, notify_admins)
		else
			log_bomber(null, "An explosion has triggered a gibtonite deposit reaction via", src, null, notify_admins)

		countdown(notify_admins)

/turf/closed/mineral/gibtonite/proc/countdown(notify_admins = 0)
	set waitfor = 0
	while(istype(src, /turf/closed/mineral/gibtonite) && stage == GIBTONITE_ACTIVE && det_time > 0 && mineralAmt >= 1)
		det_time--
		sleep(5)
	if(istype(src, /turf/closed/mineral/gibtonite))
		if(stage == GIBTONITE_ACTIVE && det_time <= 0 && mineralAmt >= 1)
			var/turf/bombturf = get_turf(src)
			mineralAmt = 0
			stage = GIBTONITE_DETONATE
			explosion(bombturf,1,3,5, adminlog = notify_admins)

/turf/closed/mineral/gibtonite/proc/defuse()
	if(stage == GIBTONITE_ACTIVE)
		cut_overlay(activated_overlay)
		activated_overlay.icon_state = "rock_Gibtonite_inactive"
		add_overlay(activated_overlay)
		desc = "An inactive gibtonite reserve. The ore can be extracted."
		stage = GIBTONITE_STABLE
		if(det_time < 0)
			det_time = 0
		visible_message("<span class='notice'>The chain reaction was stopped! The gibtonite had [det_time] reactions left till the explosion!</span>")

/turf/closed/mineral/gibtonite/gets_drilled(mob/user, triggered_by_explosion = 0)
	if(stage == GIBTONITE_UNSTRUCK && mineralAmt >= 1) //Gibtonite deposit is activated
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		explosive_reaction(user, triggered_by_explosion)
		return
	if(stage == GIBTONITE_ACTIVE && mineralAmt >= 1) //Gibtonite deposit goes kaboom
		var/turf/bombturf = get_turf(src)
		mineralAmt = 0
		stage = GIBTONITE_DETONATE
		explosion(bombturf,1,2,5, adminlog = 0)
	if(stage == GIBTONITE_STABLE) //Gibtonite deposit is now benign and extractable. Depending on how close you were to it blowing up before defusing, you get better quality ore.
		var/obj/item/gibtonite/G = new (src)
		if(det_time <= 0)
			G.quality = 3
			G.icon_state = "Gibtonite ore 3"
		if(det_time >= 1 && det_time <= 2)
			G.quality = 2
			G.icon_state = "Gibtonite ore 2"

	var/flags = NONE
	if(defer_change)
		flags = CHANGETURF_DEFER_CHANGE
	ScrapeAway(null, flags)
	addtimer(CALLBACK(src, PROC_REF(AfterChange)), 1, TIMER_UNIQUE)


/turf/closed/mineral/gibtonite/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1
