/obj/item/grenade/chem_grenade
	name = "chemical grenade"
	desc = "A custom made grenade."
	icon_state = "chemg"
	item_state = "flashbang"
	w_class = WEIGHT_CLASS_SMALL
	force = 2
	var/stage = GRENADE_EMPTY
	/// The set of reagent containers that have been added to this grenade casing.
	var/list/obj/item/reagent_containers/cup/beakers = list()
	/// The types of reagent containers that can be added to this grenade casing.
	var/list/allowed_containers = list(
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/cup/glass/waterbottle
	)
	/// The types of reagent containers that can't be added to this grenade casing.
	var/list/banned_containers = list(/obj/item/reagent_containers/cup/beaker/bluespace)
	var/affected_area = 3
	var/ignition_temp = 10 // The amount of heat added to the reagents when this grenade goes off.
	var/threatscale = 1 // Used by advanced grenades to make them slightly more worthy.
	var/no_splash = FALSE //If the grenade deletes even if it has no reagents to splash with. Used for slime core reactions.
	var/casedesc = "This basic model accepts both beakers and bottles. It heats contents by 10 K upon ignition." // Appears when examining empty casings.
	var/obj/item/assembly/prox_sensor/landminemode = null

/obj/item/grenade/chem_grenade/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_WIRES)

/obj/item/grenade/chem_grenade/Initialize(mapload)
	. = ..()
	create_reagents(1000)
	stage_change() // If no argument is set, it will change the stage to the current stage, useful for stock grenades that start READY.
	wires = new /datum/wires/explosive/chem_grenade(src)

/obj/item/grenade/chem_grenade/Destroy()
	QDEL_LIST(beakers)
	QDEL_NULL(wires)
	return ..()

/obj/item/grenade/chem_grenade/examine(mob/user)
	display_timer = (stage == GRENADE_READY)	//show/hide the timer based on assembly state
	. = ..()
	if(user.can_see_reagents())
		if(beakers.len)
			. += span_notice("You scan the grenade and detect the following reagents:")
			for(var/obj/item/reagent_containers/cup/G in beakers)
				for(var/datum/reagent/R in G.reagents.reagent_list)
					. += span_notice("[R.volume] units of [R.name] in the [G.name].")
			if(beakers.len == 1)
				. += span_notice("You detect no second beaker in the grenade.")
		else
			. += span_notice("You scan the grenade, but detect nothing.")
	else if(stage != GRENADE_READY && beakers.len)
		if(beakers.len == 2 && beakers[1].name == beakers[2].name)
			. += span_notice("You see two [beakers[1].name]s inside the grenade.")
		else
			for(var/obj/item/reagent_containers/cup/G in beakers)
				. += span_notice("You see a [G.name] inside the grenade.")

/obj/item/grenade/chem_grenade/attack_self(mob/user)
	if(stage == GRENADE_READY && !active)
		..()
	if(stage == GRENADE_WIRED)
		wires.interact(user)

/obj/item/grenade/chem_grenade/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/assembly) && stage == GRENADE_WIRED)
		wires.interact(user)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(dud_flags & GRENADE_USED)
			to_chat(user, span_notice("You started to reset the trigger."))
			if (do_after(user, 2 SECONDS, src))
				to_chat(user, span_notice("You reset the trigger."))
				dud_flags &= ~GRENADE_USED
			return
		if(stage == GRENADE_WIRED)
			if(beakers.len)
				stage_change(GRENADE_READY)
				to_chat(user, span_notice("You lock the [initial(name)] assembly."))
				I.play_tool_sound(src, 25)
			else
				to_chat(user, span_warning("You need to add at least one beaker before locking the [initial(name)] assembly!"))
		else if(stage == GRENADE_READY)
			det_time = det_time == 50 ? 30 : 50 //toggle between 30 and 50
			if(landminemode)
				landminemode.time = det_time * 0.1	//overwrites the proxy sensor activation timer

			to_chat(user, span_notice("You modify the time delay. It's set for [DisplayTimeText(det_time)]."))
		else
			to_chat(user, span_warning("You need to add a wire!"))
		return
	else if(stage == GRENADE_WIRED && is_type_in_list(I, allowed_containers))
		. = TRUE //no afterattack
		if(is_type_in_list(I, banned_containers))
			to_chat(user, span_warning("[src] is too small to fit [I]!")) // this one hits home huh anon?
			return
		if(beakers.len == 2)
			to_chat(user, span_warning("[src] can not hold more containers!"))
			return
		else
			if(I.reagents.total_volume)
				if(!user.transferItemToLoc(I, src))
					return
				to_chat(user, span_notice("You add [I] to the [initial(name)] assembly."))
				beakers += I
				var/reagent_list = pretty_string_from_reagent_list(I.reagents)
				user.log_message("inserted [I] ([reagent_list]) into [src]",LOG_GAME)
			else
				to_chat(user, span_warning("[I] is empty!"))

	else if(stage == GRENADE_EMPTY && istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		if (C.use(1))
			det_time = 50 // In case the cable_coil was removed and readded.
			stage_change(GRENADE_WIRED)
			to_chat(user, span_notice("You rig the [initial(name)] assembly."))
		else
			to_chat(user, span_warning("You need one length of coil to wire the assembly!"))
			return

	else if(stage == GRENADE_READY && I.tool_behaviour == TOOL_WIRECUTTER && !active)
		stage_change(GRENADE_WIRED)
		to_chat(user, span_notice("You unlock the [initial(name)] assembly."))

	else if(stage == GRENADE_WIRED && I.tool_behaviour == TOOL_WRENCH)
		if(beakers.len)
			for(var/obj/O in beakers)
				O.forceMove(drop_location())
				if(!O.reagents)
					continue
				var/reagent_list = pretty_string_from_reagent_list(O.reagents)
				user.log_message("removed [O] ([reagent_list]) from [src]", LOG_GAME)
			beakers = list()
			to_chat(user, span_notice("You open the [initial(name)] assembly and remove the payload."))
			wires.detach_assembly(wires.get_wire(1))
			return
		new /obj/item/stack/cable_coil(get_turf(src),1)
		stage_change(GRENADE_EMPTY)
		to_chat(user, span_notice("You remove the activation mechanism from the [initial(name)] assembly."))
	else
		return ..()

/obj/item/grenade/chem_grenade/proc/stage_change(N)
	if(N)
		stage = N
	if(stage == GRENADE_EMPTY)
		name = "[initial(name)] casing"
		desc = "A do it yourself [initial(name)]! [initial(casedesc)]"
		icon_state = initial(icon_state)
	else if(stage == GRENADE_WIRED)
		name = "unsecured [initial(name)]"
		desc = "An unsecured [initial(name)] assembly."
		icon_state = "[initial(icon_state)]_ass"
	else if(stage == GRENADE_READY)
		name = initial(name)
		desc = initial(desc)
		icon_state = "[initial(icon_state)]_locked"

/obj/item/grenade/chem_grenade/on_found(mob/finder)
	var/obj/item/assembly/A = wires.get_attached(wires.get_wire(1))
	if(A)
		A.on_found(finder)

/obj/item/grenade/chem_grenade/log_grenade(mob/user, turf/T)
	var/reagent_string = ""
	var/beaker_number = 1
	for(var/obj/exploded_beaker in beakers)
		if(!exploded_beaker.reagents)
			continue
		reagent_string += " ([exploded_beaker.name] [beaker_number++] : " + pretty_string_from_reagent_list(exploded_beaker.reagents.reagent_list) + ");"
	if(landminemode)
		log_bomber(user, "activated a proxy", src, "containing:[reagent_string]", message_admins = !dud_flags)
	else
		log_bomber(user, "primed a", src, "containing:[reagent_string]", message_admins = !dud_flags)

/obj/item/grenade/chem_grenade/preprime(mob/user, delayoverride, msg = TRUE, volume = 60)
	var/turf/T = get_turf(src)
	log_grenade(user, T) //Inbuilt admin procs already handle null users
	if(user)
		add_fingerprint(user)
		if(msg)
			if(landminemode)
				to_chat(user, span_warning("You prime [src], activating its proximity sensor."))
			else
				to_chat(user, span_warning("You prime [src]! [DisplayTimeText(det_time)]!"))
	playsound(src, 'sound/weapons/armbomb.ogg', volume, 1)
	icon_state = initial(icon_state) + "_active"
	if(landminemode)
		landminemode.activate()
		return
	active = TRUE
	addtimer(CALLBACK(src, PROC_REF(prime)), isnull(delayoverride)? det_time : delayoverride)

/obj/item/grenade/chem_grenade/prime(mob/living/lanced_by)
	if(stage != GRENADE_READY)
		return

	. = ..()
	if(!.)
		return

	var/list/datum/reagents/reactants = list()
	for(var/obj/item/reagent_containers/cup/G in beakers)
		reactants += G.reagents

	var/turf/detonation_turf = get_turf(src)

	if(!chem_splash(detonation_turf, affected_area, reactants, ignition_temp, threatscale, override_atom = src) && !no_splash)
		playsound(src, 'sound/items/screwdriver2.ogg', 50, 1)
		if(beakers.len)
			for(var/obj/O in beakers)
				O.forceMove(drop_location())
			beakers = list()
		stage_change(GRENADE_EMPTY)
		active = FALSE
		return
//	logs from custom assemblies priming are handled by the wire component
	log_game("A grenade detonated at [AREACOORD(detonation_turf)]")

	update_mob()

	qdel(src)

//Large chem grenades accept slime cores and use the appropriately.
/obj/item/grenade/chem_grenade/large
	name = "large grenade"
	desc = "A custom made large grenade. Larger splash range and increased ignition temperature compared to basic grenades. Fits exotic and bluespace based containers."
	casedesc = "This casing affects a larger area than the basic model and can fit exotic containers, including slime cores and bluespace beakers. Heats contents by 25 K upon ignition."
	icon_state = "large_grenade"
	allowed_containers = list(
		/obj/item/reagent_containers/cup,
		/obj/item/reagent_containers/condiment,
		/obj/item/reagent_containers/cup/glass,
	)
	banned_containers = list()
	affected_area = 5
	ignition_temp = 25 // Large grenades are slightly more effective at setting off heat-sensitive mixtures than smaller grenades.
	threatscale = 1.1	// 10% more effective.

/obj/item/grenade/chem_grenade/large/prime(mob/living/lanced_by)
	if(stage != GRENADE_READY || dud_flags)
		active = FALSE
		update_icon()
		return

	for(var/obj/item/slime_extract/S in beakers)
		if(S.Uses)
			for(var/obj/item/reagent_containers/cup/G in beakers)
				G.reagents.trans_to(S, G.reagents.total_volume)

			//If there is still a core (sometimes it's used up)
			//and there are reagents left, behave normally,
			//otherwise drop it on the ground for timed reactions like gold.

			if(S)
				if(S.reagents?.total_volume)
					for(var/obj/item/reagent_containers/cup/G in beakers)
						S.reagents.trans_to(G, S.reagents.total_volume)
				else
					S.forceMove(get_turf(src))
					no_splash = TRUE
	..()

	//I tried to just put it in the allowed_containers list but
	//if you do that it must have reagents.  If you're going to
	//make a special case you might as well do it explicitly. -Sayu
/obj/item/grenade/chem_grenade/large/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/slime_extract) && stage == GRENADE_WIRED)
		if(!user.transferItemToLoc(I, src))
			return
		to_chat(user, span_notice("You add [I] to the [initial(name)] assembly."))
		beakers += I
	else
		return ..()

/obj/item/grenade/chem_grenade/cryo // Intended for rare cryogenic mixes. Cools the area moderately upon detonation.
	name = "cryo grenade"
	desc = "A custom made cryogenic grenade. Rapidly cools contents upon ignition."
	casedesc = "Upon ignition, it rapidly cools contents by 100 K. Smaller splash range than regular casings."
	icon_state = "cryog"
	affected_area = 2
	ignition_temp = -100

/obj/item/grenade/chem_grenade/pyro // Intended for pyrotechnical mixes. Produces a small fire upon detonation, igniting potentially flammable mixtures.
	name = "pyro grenade"
	desc = "A custom made pyrotechnical grenade. Heats up contents upon ignition."
	casedesc = "Upon ignition, it rapidly heats contents by 500 K."
	icon_state = "pyrog"
	ignition_temp = 500 // This is enough to expose a hotspot.

/obj/item/grenade/chem_grenade/adv_release // Intended for weaker, but longer lasting effects. Could have some interesting uses.
	name = "advanced release grenade"
	desc = "A custom made advanced release grenade. It is able to be detonated more than once. Can be configured using a multitool."
	casedesc = "This casing is able to detonate more than once. Can be configured using a multitool."
	icon_state = "timeg"
	var/unit_spread = 10 // Amount of units per repeat. Can be altered with a multitool.

/obj/item/grenade/chem_grenade/adv_release/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		switch(unit_spread)
			if(0 to 24)
				unit_spread += 5
			if(25 to 99)
				unit_spread += 25
			else
				unit_spread = 5
		to_chat(user, span_notice(" You set the time release to [unit_spread] units per detonation."))
		return
	..()

/obj/item/grenade/chem_grenade/adv_release/prime(mob/living/lanced_by)
	if(stage != GRENADE_READY || dud_flags)
		active = FALSE
		update_icon()
		return

	var/total_volume = 0
	for(var/obj/item/reagent_containers/RC in beakers)
		total_volume += RC.reagents.total_volume
	if(!total_volume)
		qdel(src)
		return
	var/fraction = unit_spread/total_volume
	var/datum/reagents/reactants = new(unit_spread)
	reactants.my_atom = src
	for(var/obj/item/reagent_containers/RC in beakers)
		RC.reagents.trans_to(reactants, RC.reagents.total_volume*fraction, threatscale, 1, 1)
	chem_splash(get_turf(src), affected_area, list(reactants), ignition_temp, threatscale)

	var/turf/DT = get_turf(src)
	addtimer(CALLBACK(src, PROC_REF(prime)), det_time)
	log_game("A grenade detonated at [AREACOORD(DT)]")
