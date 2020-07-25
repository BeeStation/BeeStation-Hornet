/datum/guardian_ability/major/time
	name = "Time Distoration"
	desc = "Distorts time and space, causing fragments from other timelines to appear as distractions."
	ui_icon = "theater-masks"
	cost = 4
	arrow_weight = 0.2
	var/next_world_time = 0

/datum/guardian_ability/major/time/Apply()
	. = ..()

/datum/guardian_ability/major/time/AfterAttack(atom/target)
	. = ..()
	if(world.time >= next_world_time)
		//Spawn decoys
		next_world_time = world.time + (((5 - master_stats.potential) + 8) SECONDS)
		spawn_decoys()

/datum/guardian_ability/major/time/proc/spawn_decoys()
	var/list/immune = list()
	var/list/fakes = list()
	//Makes all of guardians immune
	var/mob/living/simple_animal/hostile/guardian/G = guardian
	if(G.summoner?.current)
		immune += G.summoner.current
		for(var/mob/living/simple_animal/hostile/guardian/GG in G.summoner.current.hasparasites())
			immune += GG
	for(var/mob/living/L in immune)
		SEND_SOUND(L, sound('sound/magic/timeparadox2.ogg'))
		if(isturf(L.loc))
			var/mob/living/simple_animal/hostile/illusion/doppelganger/E = new(L.loc)
			E.set_lifetime(60)
			E.setDir(L.dir)
			E.Copy_Parent(L, INFINITY, 100)
			E.target = null
			fakes += E
			E.remove_alt_appearance("decoy")
			var/image/I = image(icon = 'icons/mob/simple_human.dmi', icon_state = "faceless", loc = E)
			I.override = TRUE
			E.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/decoy, "decoy", I, NONE, immune)

/datum/atom_hud/alternate_appearance/basic/decoy
	var/list/immune

/datum/atom_hud/alternate_appearance/basic/decoy/New(key, image/I, options, list/immune)
	..()
	src.immune = immune
	for(var/mob/M in GLOB.mob_list)
		if(mobShouldSee(M))
			add_hud_to(M)
			M.reload_huds()

/datum/atom_hud/alternate_appearance/basic/decoy/mobShouldSee(mob/M)
	if(M in immune)
		return TRUE // They see the thing as a ghost
	return FALSE

/mob/living/simple_animal/hostile/illusion/doppelganger
	melee_damage = 0
	speed = -1
	obj_damage = 0
	vision_range = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	var/removal_timer = null

/mob/living/simple_animal/hostile/illusion/doppelganger/proc/set_lifetime(time)
	if(removal_timer)
		log_runtime("A doppelganger was set to be destroyed, but is already being destroyed!")
		return
	removal_timer = addtimer(CALLBACK(src, .proc/begin_fade_out), time, TIMER_UNIQUE)

/mob/living/simple_animal/hostile/illusion/doppelganger/proc/begin_fade_out()
	if(QDELETED(src))
		return
	playsound(get_turf(src), 'sound/magic/timeparadox2.ogg', 20, TRUE, frequency = -1) //reverse!
	animate(src, time=10, alpha=0)
	addtimer(CALLBACK(src, .proc/end_fade_out), 10, TIMER_UNIQUE)

/mob/living/simple_animal/hostile/illusion/doppelganger/proc/end_fade_out()
	if(!QDELETED(src))
		qdel(src)
