
//Hydraulic clamp, Kill clamp, Extinguisher, RCD, Cable layer.


/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp
	name = "hydraulic clamp"
	desc = "Equipment for engineering exosuits. Lifts objects and loads them into cargo."
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 10
	tool_behaviour = TOOL_RETRACTOR
	range = MECHA_MELEE
	toolspeed = 0.8
	harmful = TRUE
	mech_flags = EXOSUIT_MODULE_RIPLEY
	///Bool for whether we beat the hell out of things we punch (and tear off their arms)
	var/killer_clamp = FALSE
	///How much base damage this clamp does
	var/clamp_damage = 20
	///Var for the chassis we are attached to, needed to access ripley contents and such
	var/obj/vehicle/sealed/mecha/working/ripley/cargo_holder
	///Audio for using the hydraulic clamp
	var/clampsound = 'sound/mecha/hydraulic.ogg'

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/can_attach(obj/vehicle/sealed/mecha/M)
	. = ..()
	if(!.)
		return
	if(!istype(M, /obj/vehicle/sealed/mecha/working/ripley))
		return FALSE

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/attach(obj/vehicle/sealed/mecha/M)
	. = ..()
	cargo_holder = M

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/detach(atom/moveto = null)
	. = ..()
	cargo_holder = null

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/action(mob/living/source, atom/target, list/modifiers)
	if(!action_checks(target))
		return
	if(!cargo_holder)
		return
	if(ismecha(target))
		var/obj/vehicle/sealed/mecha/M = target
		var/have_ammo
		for(var/obj/item/mecha_ammo/box in cargo_holder.cargo)
			if(istype(box, /obj/item/mecha_ammo) && box.rounds)
				have_ammo = TRUE
				if(M.ammo_resupply(box, source, TRUE))
					return
		if(have_ammo)
			to_chat(source, "No further supplies can be provided to [M].")
		else
			to_chat(source, "No providable supplies found in cargo hold")

	else if(isobj(target))
		var/obj/clamptarget = target
		if(istype(clamptarget, /obj/machinery/door/firedoor))
			var/obj/machinery/door/firedoor/targetfiredoor = clamptarget
			playsound(chassis, clampsound, 50, FALSE, -6)
			targetfiredoor.try_to_crowbar(src, source)
			return
		if(istype(clamptarget, /obj/machinery/door/airlock/))
			var/obj/machinery/door/airlock/targetairlock = clamptarget
			playsound(chassis, clampsound, 50, FALSE, -6)
			targetairlock.try_to_crowbar(src, source)
			return
		if(clamptarget.anchored)
			balloon_alert(source, "[target] is firmly secured!")
			return
		if(LAZYLEN(cargo_holder.cargo) >= cargo_holder.cargo_capacity)
			balloon_alert(source, "Not enough room in cargo compartment.")
			return
		chassis.visible_message("[chassis] lifts [target] and starts to load it into it's cargo compartment.")
		clamptarget.set_anchored(TRUE)
		if(!do_after_cooldown(target, source))
			clamptarget.set_anchored(initial(clamptarget.anchored))
			return
		LAZYADD(cargo_holder.cargo, clamptarget)
		clamptarget.forceMove(chassis)
		clamptarget.set_anchored(FALSE)
		if(!cargo_holder.box && istype(clamptarget, /obj/structure/ore_box))
			cargo_holder.box = clamptarget
		balloon_alert(source, "[target] has been loaded.")
		log_message("Loaded [clamptarget]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]", LOG_MECHA)


	else if(isliving(target))
		var/mob/living/M = target
		if(M.stat == DEAD)
			return

		if(!source.combat_mode)
			step_away(M,chassis)
			if(killer_clamp)
				target.visible_message(span_danger("[chassis] tosses [target] like a piece of paper!"), \
					span_userdanger("[chassis] tosses you like a piece of paper!"))
			else
				to_chat(source, "[icon2html(src, source)][span_notice("You push [target] out of the way.")]")
				playsound(chassis, clampsound, 50, FALSE, -6)
				chassis.visible_message(span_notice("[chassis] pushes [target] out of the way."), \
				span_notice("[chassis] pushes you aside."))
			return ..()
		else if(LAZYACCESS(modifiers, RIGHT_CLICK) && iscarbon(M))//meme clamp here
			if(!killer_clamp)
				to_chat(source, span_notice("You longingly wish to tear [M]'s arms off."))
				return
			var/mob/living/carbon/C = target
			var/torn_off = FALSE
			var/obj/item/bodypart/affected = C.get_bodypart(BODY_ZONE_L_ARM)
			if(affected != null)
				affected.dismember(damtype)
				torn_off = TRUE
			affected = C.get_bodypart(BODY_ZONE_R_ARM)
			if(affected != null)
				affected.dismember(damtype)
				torn_off = TRUE
			if(!torn_off)
				to_chat(source, span_notice("[M]'s arms are already torn off, you must find a challenger worthy of the kill clamp!"))
				return
			playsound(src, get_dismember_sound(), 80, TRUE)
			target.visible_message(span_danger("[chassis] rips [target]'s arms off!"), \
						   span_userdanger("[chassis] rips your arms off!"))
			log_combat(source, M, "removed both arms with a real clamp,", "[name]", "(COMBAT MODE: [uppertext(source.combat_mode)] (DAMTYPE: [uppertext(damtype)])")
			return ..()

		M.take_overall_damage(clamp_damage)
		if(!M) //get gibbed stoopid
			return
		M.adjustOxyLoss(round(clamp_damage/2))
		M.updatehealth()
		target.visible_message(span_danger("[chassis] squeezes [target]!"), \
							span_userdanger("[chassis] squeezes you!"),\
							span_hear("You hear something crack."))
		log_combat(source, M, "attacked", "[name]", "(Combat mode: [source.combat_mode ? "On" : "Off"]) (DAMTYPE: [uppertext(damtype)])")
	return ..()

//This is pretty much just for the death-ripley
/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill
	name = "\improper KILL CLAMP"
	desc = "They won't know what clamped them! This time for real!"
	killer_clamp = TRUE

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/fake//harmless fake for pranks
	desc = "They won't know what clamped them!"
	energy_drain = 0
	clamp_damage = 0
	killer_clamp = FALSE

/obj/item/mecha_parts/mecha_equipment/extinguisher
	name = "exosuit extinguisher"
	desc = "Equipment for engineering exosuits. A rapid-firing high capacity fire extinguisher."
	icon_state = "mecha_exting"
	equip_cooldown = 5
	energy_drain = 0
	range = MECHA_MELEE|MECHA_RANGED
	mech_flags = EXOSUIT_MODULE_RIPLEY
	var/sprays_left = 0

/obj/item/mecha_parts/mecha_equipment/extinguisher/Initialize(mapload)
	. = ..()
	create_reagents(1000)
	reagents.add_reagent(/datum/reagent/water, 1000)

/obj/item/mecha_parts/mecha_equipment/extinguisher/action(mob/source, atom/target, list/modifiers)
	if(!action_checks(target) || get_dist(chassis, target)>3)
		return

	if(istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(chassis,target) <= 1)
		var/obj/structure/reagent_dispensers/watertank/WT = target
		WT.reagents.trans_to(src, 1000)
		to_chat(source, "[icon2html(src, source)][span_notice("Extinguisher refilled.")]")
		playsound(chassis, 'sound/effects/refill.ogg', 50, 1, -6)
	else
		if(reagents.total_volume <= 0)
			return
		playsound(chassis, 'sound/effects/extinguish.ogg', 75, 1, -3)
		sprays_left += 5
		spray_extinguisher(target)

/obj/item/mecha_parts/mecha_equipment/extinguisher/proc/spray_extinguisher(atom/target)
	var/direction = get_dir(chassis, target)
	var/turf/T1 = get_turf(target)
	var/turf/T2 = get_step(T1,turn(direction, 90))
	var/turf/T3 = get_step(T1,turn(direction, -90))
	var/list/targets = list(T1,T2,T3)

	var/obj/effect/particle_effect/water/extinguisher/water = new /obj/effect/particle_effect/water/extinguisher(get_turf(chassis))
	var/datum/reagents/water_reagents = new /datum/reagents(5)
	water.reagents = water_reagents
	water_reagents.my_atom = water
	reagents.trans_to(water, 1)

	var/delay = 2
	var/datum/move_loop/our_loop = SSmove_manager.move_towards_legacy(water, pick(targets), delay, timeout = delay * 4, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(our_loop, COMSIG_PARENT_QDELETING, PROC_REF(water_finished_moving))

/obj/item/mecha_parts/mecha_equipment/extinguisher/proc/water_finished_moving(datum/move_loop/has_target/source)
	SIGNAL_HANDLER
	sprays_left--
	if(!sprays_left)
		return
	extinguish(source.target)

/obj/item/mecha_parts/mecha_equipment/extinguisher/get_equip_info()
	return "[..()] \[[src.reagents.total_volume]\]"

/obj/item/mecha_parts/mecha_equipment/extinguisher/can_attach(obj/vehicle/sealed/mecha/M)
	. = ..()
	if(!.)
		return
	if(!istype(M, /obj/vehicle/sealed/mecha/working))
		return FALSE


#define MODE_DECONSTRUCT	0
#define MODE_WALL			1
#define MODE_AIRLOCK		2

/obj/item/mecha_parts/mecha_equipment/rcd
	name = "mounted RCD"
	desc = "An exosuit-mounted Rapid Construction Device."
	icon_state = "mecha_rcd"
	equip_cooldown = 10
	energy_drain = 250
	range = MECHA_MELEE|MECHA_RANGED
	item_flags = NO_MAT_REDEMPTION | ISWEAPON
	///determines what we'll so when clicking on a turf
	var/mode = MODE_DECONSTRUCT

/obj/item/mecha_parts/mecha_equipment/rcd/Initialize(mapload)
	. = ..()
	GLOB.rcd_list += src

/obj/item/mecha_parts/mecha_equipment/rcd/Destroy()
	GLOB.rcd_list -= src
	return ..()

/obj/item/mecha_parts/mecha_equipment/rcd/action(mob/source, atom/target, list/modifiers)
	if(!isturf(target) && !istype(target, /obj/machinery/door/airlock))
		target = get_turf(target)
	if(!action_checks(target) || get_dist(chassis, target)>3 || istype(target, /turf/open/space/transit))
		return
	playsound(chassis, 'sound/machines/click.ogg', 50, 1)

	switch(mode)
		if(MODE_DECONSTRUCT)
			to_chat(source, "[icon2html(src, source)][span_notice("Deconstructing [target]...")]")
			if(iswallturf(target))
				var/turf/closed/wall/W = target
				if(!do_after_cooldown(W, source))
					return
				W.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
			else if(isfloorturf(target))
				var/turf/open/floor/F = target
				if(!do_after_cooldown(target, source))
					return
				F.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
			else if (istype(target, /obj/machinery/door/airlock))
				if(!do_after_cooldown(target, source))
					return
				qdel(target)
		if(MODE_WALL)
			if(isspaceturf(target))
				var/turf/open/space/S = target
				to_chat(source, "[icon2html(src, source)][span_notice("Building Floor...")]")
				if(!do_after_cooldown(S, source))
					return
				S.PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			else if(isfloorturf(target))
				var/turf/open/floor/F = target
				to_chat(source, "[icon2html(src, source)][span_notice("Building Wall...")]")
				if(!do_after_cooldown(F, source))
					return
				F.PlaceOnTop(/turf/closed/wall)
		if(MODE_AIRLOCK)
			if(isfloorturf(target))
				to_chat(source, "[icon2html(src, source)][span_notice("Building Airlock...")]")
				if(!do_after_cooldown(target, source))
					return
				var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock(target)
				T.autoclose = TRUE
				playsound(target, 'sound/effects/sparks2.ogg', 50, TRUE)
	chassis.spark_system.start()
	playsound(target, 'sound/items/deconstruct.ogg', 50, TRUE)
	return ..()

/obj/item/mecha_parts/mecha_equipment/rcd/Topic(href,href_list)
	..()
	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		switch(mode)
			if(MODE_DECONSTRUCT)
				to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("Switched RCD to Deconstruct.")]")
				energy_drain = initial(energy_drain)
			if(MODE_WALL)
				to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("Switched RCD to Construct Walls and Flooring.")]")
				energy_drain = 2*initial(energy_drain)
			if(MODE_AIRLOCK)
				to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("Switched RCD to Construct Airlock.")]")
				energy_drain = 2*initial(energy_drain)

/obj/item/mecha_parts/mecha_equipment/rcd/get_equip_info()
	return "[..()] \[<a href='byond://?src=[REF(src)];mode=0'>D</a>|<a href='byond://?src=[REF(src)];mode=1'>C</a>|<a href='byond://?src=[REF(src)];mode=2'>A</a>\]"

#undef MODE_DECONSTRUCT
#undef MODE_WALL
#undef MODE_AIRLOCK

/*

/obj/item/mecha_parts/mecha_equipment/cable_layer
	name = "cable layer"
	desc = "Equipment for engineering exosuits. Lays cable along the exosuit's path."
	icon_state = "mecha_wire"
	var/datum/callback/event
	var/turf/old_turf
	var/obj/structure/cable/last_piece
	var/obj/item/stack/cable_coil/cable
	var/max_cable = 1000

/obj/item/mecha_parts/mecha_equipment/cable_layer/Initialize(mapload)
	. = ..()
	cable = new(src, 0)

/obj/item/mecha_parts/mecha_equipment/cable_layer/can_attach(obj/vehicle/sealed/mecha/working/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/cable_layer/attach()
	..()
	event = chassis.events.addEvent("onMove", CALLBACK(src, PROC_REF(layCable)))
	return

/obj/item/mecha_parts/mecha_equipment/cable_layer/detach()
	chassis.events.clearEvent("onMove",event)
	return ..()

/obj/item/mecha_parts/mecha_equipment/cable_layer/Destroy()
	if(chassis)
		chassis.events.clearEvent("onMove",event)
	return ..()

/obj/item/mecha_parts/mecha_equipment/cable_layer/action(var/obj/item/stack/cable_coil/target)
	if(!action_checks(target))
		return
	if(istype(target) && target.amount)
		var/cur_amount = cable? cable.amount : 0
		var/to_load = max(max_cable - cur_amount,0)
		if(to_load)
			to_load = min(target.amount, to_load)
			if(!cable)
				cable = new(src, 0)
			cable.amount += to_load
			target.use(to_load)
			occupant_message(span_notice("[to_load] meters of cable successfully loaded."))
			send_byjax(chassis.occupant,"exosuit.browser","[REF(src)]",src.get_equip_info())
		else
			occupant_message(span_warning("Reel is full."))
	else
		occupant_message(span_warning("Unable to load [target] - no cable found."))


/obj/item/mecha_parts/mecha_equipment/cable_layer/Topic(href,href_list)
	..()
	if(href_list["toggle"])
		set_ready_state(!equip_ready)
		occupant_message("[src] [equip_ready?"dea":"a"]ctivated.")
		log_message("[equip_ready?"Dea":"A"]ctivated.", LOG_MECHA)
		return
	if(href_list["cut"])
		if(cable?.amount)
			var/m = round(input(chassis.occupant,"Please specify the length of cable to cut","Cut cable",min(cable.amount,30)) as num, 1)
			m = min(m, cable.amount)
			if(m)
				use_cable(m)
				new /obj/item/stack/cable_coil(get_turf(chassis), m)
		else
			occupant_message("There's no more cable on the reel.")
	return

/obj/item/mecha_parts/mecha_equipment/cable_layer/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[Cable: [cable ? cable.amount : 0] m\][(cable && cable.amount) ? "- <a href='byond://?src=[REF(src)];toggle=1'>[!equip_ready?"Dea":"A"]ctivate</a>|<a href='byond://?src=[REF(src)];cut=1'>Cut</a>" : null]"
	return

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/use_cable(amount)
	if(!cable || cable.amount<1)
		set_ready_state(1)
		occupant_message("Cable depleted, [src] deactivated.")
		log_message("Cable depleted, [src] deactivated.", LOG_MECHA)
		return
	if(cable.amount < amount)
		occupant_message("No enough cable to finish the task.")
		return
	cable.use(amount)
	update_equip_info()
	return 1

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/reset()
	last_piece = null

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/dismantleFloor(var/turf/new_turf)
	if(isfloorturf(new_turf))
		var/turf/open/floor/T = new_turf
		if(!isplatingturf(T))
			if(!T.broken && !T.burnt)
				new T.floor_tile(T)
			T.make_plating()
	return !new_turf.underfloor_accessibility

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/layCable(var/turf/new_turf)
	if(equip_ready || !istype(new_turf) || !dismantleFloor(new_turf))
		return reset()
	var/fdirn = turn(chassis.dir,180)
	for(var/obj/structure/cable/LC in new_turf)		// check to make sure there's not a cable there already
		if(LC.d1 == fdirn || LC.d2 == fdirn)
			return reset()
	if(!use_cable(1))
		return reset()
	var/obj/structure/cable/NC = new(new_turf, "red")
	NC.d1 = 0
	NC.d2 = fdirn
	NC.update_icon()

	var/datum/powernet/PN
	if(last_piece && last_piece.d2 != chassis.dir)
		last_piece.d1 = min(last_piece.d2, chassis.dir)
		last_piece.d2 = max(last_piece.d2, chassis.dir)
		last_piece.update_icon()
		PN = last_piece.powernet

	if(!PN)
		PN = new()
		GLOB.powernets += PN
	NC.powernet = PN
	PN.cables += NC
	NC.mergeConnectedNetworks(NC.d2)

	//NC.mergeConnectedNetworksOnTurf()
	last_piece = NC
	return 1
*/

//Dunno where else to put this so shrug
/obj/item/mecha_parts/mecha_equipment/ripleyupgrade
	name = "Ripley MK-II Conversion Kit"
	desc = "A pressurized canopy attachment kit for an Autonomous Power Loader Unit \"Ripley\" MK-I mecha, to convert it to the slower, but space-worthy MK-II design. This kit cannot be removed, once applied."
	icon_state = "ripleyupgrade"
	mech_flags = EXOSUIT_MODULE_RIPLEY

/obj/item/mecha_parts/mecha_equipment/ripleyupgrade/can_attach(obj/vehicle/sealed/mecha/working/ripley/M)
	if(M.type != /obj/vehicle/sealed/mecha/working/ripley)
		to_chat(loc, span_warning("This conversion kit can only be applied to APLU MK-I models."))
		return FALSE
	if(LAZYLEN(M.cargo))
		to_chat(loc, span_warning("[M]'s cargo hold must be empty before this conversion kit can be applied."))
		return FALSE
	if(!(M.mecha_flags & ADDING_MAINT_ACCESS_POSSIBLE)) //non-removable upgrade, so lets make sure the pilot or owner has their say.
		to_chat(loc, span_warning("[M] must have maintenance protocols active in order to allow this conversion kit."))
		return FALSE
	if(LAZYLEN(M.occupants)) //We're actualy making a new mech and swapping things over, it might get weird if players are involved
		to_chat(loc, span_warning("[M] must be unoccupied before this conversion kit can be applied."))
		return FALSE
	if(!M.cell) //Turns out things break if the cell is missing
		to_chat(loc, span_warning("The conversion process requires a cell installed."))
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/ripleyupgrade/attach(obj/vehicle/sealed/mecha/markone)
	var/obj/vehicle/sealed/mecha/working/ripley/mk2/marktwo = new (get_turf(markone),1)
	if(!marktwo)
		return
	QDEL_NULL(marktwo.cell)
	if (markone.cell)
		marktwo.cell = markone.cell
		markone.cell.forceMove(marktwo)
		markone.cell = null
	QDEL_NULL(marktwo.scanmod)
	if (markone.scanmod)
		marktwo.scanmod = markone.scanmod
		markone.scanmod.forceMove(marktwo)
		markone.scanmod = null
	QDEL_NULL(marktwo.capacitor)
	if (markone.capacitor)
		marktwo.capacitor = markone.capacitor
		markone.capacitor.forceMove(marktwo)
		markone.capacitor = null
	marktwo.update_part_values()
	for(var/obj/item/mecha_parts/equipment in markone.contents)
		if(istype(equipment, /obj/item/mecha_parts/concealed_weapon_bay)) //why is the bay not just a variable change who did this
			equipment.forceMove(marktwo)
	for(var/obj/item/mecha_parts/mecha_equipment/equipment in markone.equipment) //Move the equipment over...
		equipment.detach(marktwo)
		equipment.attach(marktwo)
	marktwo.mecha_flags = markone.mecha_flags
	marktwo.strafe = markone.strafe
	//Integ set to the same percentage integ as the old mecha, rounded to be whole number
	marktwo.update_integrity(round((markone.get_integrity() / markone.max_integrity) * marktwo.get_integrity()))
	if(markone.name != initial(markone.name))
		marktwo.name = markone.name
	markone.wreckage = FALSE
	qdel(markone)
	playsound(get_turf(marktwo),'sound/items/ratchet.ogg',50,TRUE)
