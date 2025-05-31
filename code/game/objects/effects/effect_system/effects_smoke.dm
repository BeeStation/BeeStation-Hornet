/////////////////////////////////////////////
//// SMOKE SYSTEMS
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke
	name = "smoke"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke"
	pixel_x = -32
	pixel_y = -32
	opacity = FALSE
	layer = FLY_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	animate_movement = FALSE
	var/amount = 4
	var/lifetime = 5
	var/opaque = 1 //whether the smoke can block the view when in enough amountz
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(mob_entered),
	)

/obj/effect/particle_effect/smoke/proc/fade_out(frames = 16)
	if(alpha == 0) //Handle already transparent case
		return
	if(frames == 0)
		frames = 1 //We will just assume that by 0 frames, the coder meant "during one frame".
	var/step = alpha / frames
	for(var/i in 1 to frames)
		alpha -= step
		if(alpha < 160)
			set_opacity(0) //if we were blocking view, we aren't now because we're fading out
		stoplag()

/obj/effect/particle_effect/smoke/Initialize(mapload)
	. = ..()
	create_reagents(500)
	START_PROCESSING(SSobj, src)
	// Smoke out any mobs on initialise
	for (var/mob/living/target in loc)
		target.apply_status_effect(/datum/status_effect/smoke)

/obj/effect/particle_effect/smoke/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/connect_loc_behalf, src, connections)

/obj/effect/particle_effect/smoke/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/particle_effect/smoke/proc/kill_smoke()
	STOP_PROCESSING(SSobj, src)
	INVOKE_ASYNC(src, PROC_REF(fade_out))
	QDEL_IN(src, 10)

/obj/effect/particle_effect/smoke/process()
	lifetime--
	if(lifetime < 1)
		kill_smoke()
		return FALSE
	for(var/mob/living/L in get_turf(src))
		smoke_mob(L)
	return TRUE

/obj/effect/particle_effect/smoke/proc/mob_entered(datum/source, mob/living/target)
	SIGNAL_HANDLER
	if (!istype(target))
		return
	// Mobs inside the smoke get slowed if they can't see through it
	target.apply_status_effect(/datum/status_effect/smoke)

/obj/effect/particle_effect/smoke/proc/smoke_mob(mob/living/carbon/C)
	if(!istype(C))
		return FALSE
	if(lifetime<1)
		return FALSE
	if(C.internal != null || C.has_smoke_protection())
		return FALSE
	if(C.smoke_delay)
		return FALSE
	C.smoke_delay++
	addtimer(CALLBACK(src, PROC_REF(remove_smoke_delay), C), 10)
	return TRUE

/obj/effect/particle_effect/smoke/proc/remove_smoke_delay(mob/living/carbon/C)
	if(C)
		C.smoke_delay = 0

/obj/effect/particle_effect/smoke/proc/spread_smoke(circle = TRUE)
	var/turf/t_loc = get_turf(src)
	if(!t_loc)
		return
	var/list/newsmokes = list()
	for(var/turf/T in t_loc.get_atmos_adjacent_turfs(!circle))
		var/obj/effect/particle_effect/smoke/foundsmoke = locate() in T //Don't spread smoke where there's already smoke!
		if(foundsmoke)
			continue
		for(var/mob/living/L in T)
			smoke_mob(L)
		var/obj/effect/particle_effect/smoke/S = new type(T)
		reagents.copy_to(S, reagents.total_volume)
		S.setDir(pick(GLOB.cardinals))
		S.amount = amount-1
		S.add_atom_colour(color, FIXED_COLOUR_PRIORITY)
		S.lifetime = lifetime
		if(S.amount>0)
			if(opaque)
				S.set_opacity(TRUE)
			newsmokes.Add(S)

	if(newsmokes.len)
		spawn(1) //the smoke spreads rapidly but not instantly
			for(var/obj/effect/particle_effect/smoke/SM in newsmokes)
				SM.spread_smoke(circle)

/datum/effect_system/smoke_spread
	var/amount = 10
	var/circle = TRUE
	effect_type = /obj/effect/particle_effect/smoke

/datum/effect_system/smoke_spread/set_up(radius = 5, loca, circle = TRUE)
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)
	amount = radius
	src.circle = TRUE

/datum/effect_system/smoke_spread/start()
	if(holder)
		location = get_turf(holder)
	var/obj/effect/particle_effect/smoke/S = new effect_type(location)
	S.amount = amount
	if(S.amount)
		S.spread_smoke(circle)


/////////////////////////////////////////////
// Bad smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/bad
	lifetime = 8

/obj/effect/particle_effect/smoke/bad/smoke_mob(mob/living/carbon/M)
	. = ..()
	if(.)
		M.drop_all_held_items()
		M.adjustOxyLoss(1)
		M.emote("cough")
		return TRUE


/datum/effect_system/smoke_spread/bad
	effect_type = /obj/effect/particle_effect/smoke/bad

/////////////////////////////////////////////
// Nanofrost smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/freezing
	name = "nanofrost smoke"
	color = "#B2FFFF"
	opaque = FALSE

/datum/effect_system/smoke_spread/freezing
	effect_type = /obj/effect/particle_effect/smoke/freezing
	var/blast = 0
	var/temperature = 2
	var/weldvents = TRUE
	var/distcheck = TRUE

/datum/effect_system/smoke_spread/freezing/proc/Chilled(turf/open/T)
	if(!istype(T))
		return
	if(T.air)
		var/datum/gas_mixture/G = T.air
		if(!distcheck || get_dist(T, location) < blast) // Otherwise we'll get silliness like people using Nanofrost to kill people through walls with cold air
			G.temperature = temperature
		T.air_update_turf(FALSE, FALSE)
		for(var/obj/effect/hotspot/H in T)
			qdel(H)
		if(G.gases[/datum/gas/plasma][MOLES])
			ADD_MOLES(/datum/gas/nitrogen, G, G.gases[/datum/gas/plasma][MOLES])
			G.gases[/datum/gas/plasma][MOLES] = 0

	if (weldvents)
		for(var/obj/machinery/atmospherics/components/unary/U in T)
			if(!isnull(U.welded) && !U.welded) //must be an unwelded vent pump or vent scrubber.
				U.welded = TRUE
				U.update_icon()
				U.visible_message(span_danger("[U] was frozen shut!"))
	for(var/mob/living/L in T)
		L.ExtinguishMob()
	for(var/obj/item/Item in T)
		Item.extinguish()

/datum/effect_system/smoke_spread/freezing/set_up(radius = 5, loca, blast_radius = 0, circle = TRUE)
	..(radius, loca, circle)
	blast = blast_radius

/datum/effect_system/smoke_spread/freezing/start()
	if(blast)
		for(var/turf/open/T in RANGE_TURFS(blast, location))
			Chilled(T)
	..()

/datum/effect_system/smoke_spread/freezing/decon
	temperature = T20C
	distcheck = FALSE
	weldvents = FALSE


/////////////////////////////////////////////
// Sleep smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/sleeping
	color = "#9C3636"
	lifetime = 10

/obj/effect/particle_effect/smoke/sleeping/smoke_mob(mob/living/carbon/M)
	if(..())
		M.Sleeping(200)
		M.emote("cough")
		return 1

/datum/effect_system/smoke_spread/sleeping
	effect_type = /obj/effect/particle_effect/smoke/sleeping

/////////////////////////////////////////////
// Chem smoke
/////////////////////////////////////////////

/obj/effect/particle_effect/smoke/chem
	lifetime = 10


/obj/effect/particle_effect/smoke/chem/process()
	. = ..()
	if(.)
		var/turf/T = get_turf(src)
		var/fraction = 1/initial(lifetime)
		for(var/atom/movable/AM in T)
			if(AM.type == src.type)
				continue
			reagents.expose(AM, TOUCH, fraction)

		reagents.expose(T, TOUCH, fraction)
		return TRUE

/obj/effect/particle_effect/smoke/chem/smoke_mob(mob/living/carbon/M)
	if(lifetime<1)
		return FALSE
	if(!istype(M))
		return FALSE
	var/mob/living/carbon/C = M
	if(C.internal != null || C.has_smoke_protection())
		return FALSE
	var/fraction = 1/initial(lifetime)
	reagents.copy_to(C, fraction*reagents.total_volume)
	reagents.expose(M, INGEST, fraction)
	if(isapid(C))
		C.SetSleeping(50) // Bees sleep when smoked
	M.log_message("breathed in some smoke with reagents [english_list(reagents.reagent_list)]", LOG_ATTACK, null, FALSE) // Do not log globally b/c spam
	return TRUE



/datum/effect_system/smoke_spread/chem
	var/obj/chemholder
	effect_type = /obj/effect/particle_effect/smoke/chem

/datum/effect_system/smoke_spread/chem/New()
	..()
	chemholder = new /obj()
	var/datum/reagents/R = new/datum/reagents(500)
	chemholder.reagents = R
	R.my_atom = chemholder

/datum/effect_system/smoke_spread/chem/Destroy()
	qdel(chemholder)
	chemholder = null
	return ..()

/datum/effect_system/smoke_spread/chem/set_up(datum/reagents/carry = null, radius = 1, loca, silent = FALSE, circle = TRUE)
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)
	amount = radius
	carry.copy_to(chemholder, carry.total_volume)
	src.circle = circle

	if(!silent)
		var/contained = ""
		for(var/reagent in carry.reagent_list)
			contained += " [reagent] "
		if(contained)
			contained = "\[[contained]\]"

		var/where = "[AREACOORD(location)]"
		if(carry.my_atom.fingerprintslast)
			var/mob/M = get_mob_by_ckey(carry.my_atom.fingerprintslast)
			var/more = ""
			if(M)
				more = "[ADMIN_LOOKUPFLW(M)] "
			if(!istype(carry.my_atom, /obj/machinery/plumbing))
				message_admins("Smoke: ([ADMIN_VERBOSEJMP(location)])[contained]. Key: [more ? more : carry.my_atom.fingerprintslast].")
			log_game("A chemical smoke reaction has taken place in ([where])[contained]. Last touched by [carry.my_atom.fingerprintslast].")
		else
			if(!istype(carry.my_atom, /obj/machinery/plumbing))
				message_admins("Smoke: ([ADMIN_VERBOSEJMP(location)])[contained]. No associated key.")
			log_game("A chemical smoke reaction has taken place in ([where])[contained]. No associated key.")


/datum/effect_system/smoke_spread/chem/start()
	var/mixcolor = mix_color_from_reagents(chemholder.reagents.reagent_list)
	if(holder)
		location = get_turf(holder)
	var/obj/effect/particle_effect/smoke/chem/S = new effect_type(location)

	if(chemholder.reagents.total_volume > 1) // can't split 1 very well
		chemholder.reagents.copy_to(S, chemholder.reagents.total_volume)

	if(mixcolor)
		S.add_atom_colour(mixcolor, FIXED_COLOUR_PRIORITY) // give the smoke color, if it has any to begin with
	S.amount = amount
	if(S.amount)
		S.spread_smoke(circle) //calling process right now so the smoke immediately attacks mobs.
	return S

/////////////////////////////////////////////
// Transparent smoke
/////////////////////////////////////////////

//Same as the base type, but the smoke produced is not opaque
/datum/effect_system/smoke_spread/transparent
	effect_type = /obj/effect/particle_effect/smoke/transparent

/obj/effect/particle_effect/smoke/transparent
	opaque = FALSE

/proc/do_smoke(range=0, location=null, smoke_type=/obj/effect/particle_effect/smoke)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.effect_type = smoke_type
	smoke.set_up(range, location)
	smoke.start()
