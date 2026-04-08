/datum/round_event_control/spacevine
	name = "Spacevine"
	typepath = /datum/round_event/spacevine
	weight = 15
	max_occurrences = 3
	min_players = 10

/datum/round_event/spacevine
	fakeable = FALSE

/datum/round_event/spacevine/start()
	var/list/turfs = get_area_turfs(/area/station/maintenance, SSmapping.levels_by_trait(ZTRAIT_STATION)[1], TRUE)

	var/obj/structure/spacevine/SV = new()

	for(var/turf/T in turfs)
		if(!T.Enter(SV) || isspaceturf(T))
			turfs -= T

	qdel(SV)

	if(turfs.len) //Pick a turf to spawn at if we can
		var/turf/T = pick(turfs)
		new /datum/spacevine_controller(T, list(pick(subtypesof(/datum/spacevine_mutation))), rand(10,100), rand(1,6)) //spawn a controller at turf with randomized stats and a single random mutation
		message_admins("Event spacevine has been spawned in [ADMIN_VERBOSEJMP(T)].")

// SPACE VINES (Note that this code is very similar to Biomass code)
/obj/structure/spacevine
	name = "space vines"
	desc = "An extremely expansionistic species of vine."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light1"
	anchored = TRUE
	density = FALSE
	layer = SPACEVINE_LAYER
	mouse_opacity = MOUSE_OPACITY_OPAQUE //Clicking anywhere on the turf is good enough
	pass_flags = PASSTABLE | PASSGRILLE
	max_integrity = 50
	var/energy = 0
	var/datum/spacevine_controller/master = null
	var/list/mutations = list()

/obj/structure/spacevine/Initialize(mapload)
	. = ..()
	add_atom_colour(COLOR_WHITE, FIXED_COLOUR_PRIORITY)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/spacevine/examine(mob/user)
	. = ..()
	var/text = "This one is a"
	if(mutations.len)
		for(var/A in mutations)
			var/datum/spacevine_mutation/SM = A
			text += " [SM.name]"
	else
		text += " normal"
	text += " vine."
	. += text

/obj/structure/spacevine/Destroy()
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_death(src)
	if(master)
		master.VineDestroyed(src)
	mutations = list()
	set_opacity(0)
	if(has_buckled_mobs())
		unbuckle_all_mobs(force=1)
	return ..()

/obj/structure/spacevine/proc/on_chem_effect(datum/reagent/R)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_chem(src, R)
	if(!override && istype(R, /datum/reagent/toxin/plantbgone))
		if(prob(50))
			qdel(src)

/obj/structure/spacevine/proc/eat(mob/eater)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_eat(src, eater)
	if(!override)
		qdel(src)

/obj/structure/spacevine/attacked_by(obj/item/I, mob/living/user)
	var/damage_dealt = I.force
	if(I.get_sharpness())
		damage_dealt *= 4
	if(I.damtype == BURN)
		damage_dealt *= 4

	for(var/datum/spacevine_mutation/SM in mutations)
		damage_dealt = SM.on_hit(src, user, I, damage_dealt) //on_hit now takes override damage as arg and returns new value for other mutations to permutate further
	take_damage(damage_dealt, I.damtype, MELEE, 1)

/obj/structure/spacevine/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/slash.ogg', 50, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/structure/spacevine/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(isliving(AM))
		for(var/datum/spacevine_mutation/SM in mutations)
			SM.on_cross(src, AM)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/spacevine/attack_hand(mob/user, list/modifiers)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_hit(src, user)
	user_unbuckle_mob(user, user)
	. = ..()

/obj/structure/spacevine/attack_paw(mob/living/user)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_hit(src, user)
	user_unbuckle_mob(user,user)

/obj/structure/spacevine/attack_alien(mob/living/user)
	eat(user)

/datum/spacevine_controller
	var/list/obj/structure/spacevine/vines
	var/list/growth_queue
	var/spread_multiplier = 5
	var/spread_cap = 30
	var/list/vine_mutations_list
	var/mutativeness = 1

/datum/spacevine_controller/New(turf/location, list/muts, potency, production)
	vines = list()
	growth_queue = list()
	spawn_spacevine_piece(location, null, muts)
	notify_ghosts("Kudzu has been deployed!", source=location, header="Kudzu")
	START_PROCESSING(SSobj, src)
	vine_mutations_list = list()
	init_subtypes(/datum/spacevine_mutation/, vine_mutations_list)
	if(potency != null)
		mutativeness = potency / 10
	if(production != null && production <= 10) //Prevents runtime in case production is set to 11.
		spread_cap *= (11 - production) / 5 //Best production speed of 1 doubles spread_cap to 60 while worst speed of 10 lowers it to 6. Even distribution.
		spread_multiplier /= (11 - production) / 5
		if(!spread_multiplier) // Division by 0 protection
			spread_multiplier = 1

/datum/spacevine_controller/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_SPACEVINE_PURGE, "Delete Vines")

/datum/spacevine_controller/vv_do_topic(href_list)
	. = ..()
	if(href_list[VV_HK_SPACEVINE_PURGE])
		if(alert(usr, "Are you sure you want to delete this spacevine cluster?", "Delete Vines", "Yes", "No") == "Yes")
			DeleteVines()

/datum/spacevine_controller/proc/DeleteVines()	//this is kill
	QDEL_LIST(vines)	//this will also qdel us

/datum/spacevine_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/spacevine_controller/proc/spawn_spacevine_piece(turf/location, obj/structure/spacevine/parent, list/muts)
	var/obj/structure/spacevine/SV = new(location)
	growth_queue += SV
	vines += SV
	SV.master = src
	if(muts?.len)
		for(var/datum/spacevine_mutation/M in muts)
			M.add_mutation_to_vinepiece(SV)
		return
	if(parent)
		SV.mutations |= parent.mutations
		var/parentcolor = parent.atom_colours[FIXED_COLOUR_PRIORITY]
		SV.add_atom_colour(parentcolor, FIXED_COLOUR_PRIORITY)
		if(prob(mutativeness))
			var/datum/spacevine_mutation/randmut = pick(vine_mutations_list - SV.mutations)
			randmut.add_mutation_to_vinepiece(SV)

	for(var/datum/spacevine_mutation/SM in SV.mutations)
		SM.on_birth(SV)
	location.Entered(SV, null)
	return SV

/datum/spacevine_controller/proc/VineDestroyed(obj/structure/spacevine/S)
	S.master = null
	vines -= S
	growth_queue -= S
	if(!length(vines))
		return
	//if we were the last man standing, drop a seed packet to recreate us
	var/obj/item/plant_seeds/preset/kudzu/KZ = new(get_turf(S))
	KZ.mutations |= S.mutations
	qdel(src)

/datum/spacevine_controller/process(delta_time)
	if(!LAZYLEN(vines))
		qdel(src) //space vines exterminated. Remove the controller
		return
	if(!growth_queue)
		qdel(src) //Sanity check
		return

	var/length = round(min( spread_cap , max( 1 , delta_time * 0.5 *vines.len / spread_multiplier)))
	var/i = 0
	var/list/obj/structure/spacevine/queue_end = list()

	for(var/obj/structure/spacevine/SV in growth_queue)
		if(QDELETED(SV))
			continue
		i++
		queue_end += SV
		growth_queue -= SV
		for(var/datum/spacevine_mutation/SM in SV.mutations)
			SM.process_mutation(SV)
		if(SV.energy < 2) //If tile isn't fully grown
			if(DT_PROB(10, delta_time))
				SV.grow()
		else //If tile is fully grown
			SV.entangle_mob()

		SV.spread()
		if(i >= length)
			break

	growth_queue = growth_queue + queue_end

/obj/structure/spacevine/proc/grow()
	if(!energy)
		src.icon_state = pick("Med1", "Med2", "Med3")
		energy = 1
		set_opacity(1)
	else
		src.icon_state = pick("Hvy1", "Hvy2", "Hvy3")
		energy = 2

	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_grow(src)

/obj/structure/spacevine/proc/entangle_mob()
	if(!has_buckled_mobs() && prob(25))
		for(var/mob/living/V in src.loc)
			entangle(V)
			if(has_buckled_mobs())
				break //only capture one mob at a time


/obj/structure/spacevine/proc/entangle(mob/living/V)
	if(!V || isvineimmune(V))
		return
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_buckle(src, V)
	if((V.stat != DEAD) && (V.buckled != src)) //not dead or captured
		to_chat(V, span_danger("The vines [pick("wind", "tangle", "tighten")] around you!"))
		buckle_mob(V, 1)

/// Finds a target tile to spread to. If checks pass it will spread to it and also proc on_spread on target.
/obj/structure/spacevine/proc/spread()
	var/turf/startturf = get_turf(src)
	var/direction = pick(GLOB.cardinals_multiz)
	var/turf/stepturf = get_step_multiz(src,direction)
	if(direction == UP || direction == DOWN)
		var/ladder = FALSE
		for(var/obj/structure/ladder/L in startturf.contents)
			if(!L.up && direction == UP)
				continue
			else if(!L.down && direction == DOWN)
				continue
			ladder = TRUE
		if((!stepturf?.zPassIn(direction) || !startturf.zPassOut(direction)) && !ladder) //We can't zmove, choose another direction
			direction = pick(GLOB.cardinals)
			stepturf = get_step(src,direction)
	if(locate(/obj/structure, stepturf) || locate(/obj/machinery, stepturf))//if we can't grow into a turf, we'll start digging into it
		for(var/obj/structure/S in stepturf)
			if(S.density && !istype(S, /obj/structure/alien/resin/flower_bud) && !istype(S, /obj/structure/reagent_dispensers/fueltank)) //don't breach the station!
				S.take_damage(25)
		for(var/obj/machinery/M in stepturf)
			if(M.density && !istype(M, /obj/machinery/power/smes) && !istype(M, /obj/machinery/door/airlock/external) && !istype(M, /obj/machinery/door/firedoor)) //please don't sabotage power or cause a hullbreach!
				M.take_damage(40) //more damage, because machines are more commonplace and tend to be more durable
	if(!isspaceturf(stepturf) && stepturf.Enter(src))
		var/obj/structure/spacevine/spot_taken = locate() in stepturf //Locates any vine on target turf. Calls that vine "spot_taken".
		var/datum/spacevine_mutation/vine_eating/E = locate() in mutations //Locates the vine eating trait in our own seed and calls it E.
		if(!spot_taken || (E && (spot_taken && !spot_taken.mutations.Find(E)))) //Proceed if there isn't a vine on the target turf, OR we have vine eater AND target vine is from our seed and doesn't. Vines from other seeds are eaten regardless.
			if(master)
				for(var/datum/spacevine_mutation/SM in mutations)
					SM.on_spread(src, stepturf) //Only do the on_spread proc if it actually spreads.
					stepturf = get_step_multiz(src,direction) //in case turf changes, to make sure no runtimes happen
				master.spawn_spacevine_piece(stepturf, src)

/obj/structure/spacevine/ex_act(severity, target)
	var/i
	for(var/datum/spacevine_mutation/SM in mutations)
		i += SM.on_explosion(severity, target, src)
	if(!i && prob(100/severity))
		qdel(src)

/obj/structure/spacevine/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD //if you're cold you're safe

/obj/structure/spacevine/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	var/volume = air.return_volume()
	for(var/datum/spacevine_mutation/SM in mutations)
		if(SM.process_temperature(src, exposed_temperature, volume)) //If it's ever true we're safe
			return
	qdel(src)

/obj/structure/spacevine/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(isvineimmune(mover))
		return TRUE

/proc/isvineimmune(atom/A)
	if(isliving(A))
		var/mob/living/M = A
		if((FACTION_VINES in M.faction) || (FACTION_VINES in M.faction))
			return TRUE
	return FALSE
