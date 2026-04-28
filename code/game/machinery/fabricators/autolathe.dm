/obj/machinery/modular_fabricator/autolathe
	name = "autolathe"
	desc = "It produces items using iron, copper, and glass."
	icon_state = "autolathe"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/autolathe

	var/shocked = FALSE
	var/hack_wire
	var/disable_wire
	var/shock_wire

	//Security modes
	can_be_hacked_or_unlocked = TRUE
	var/security_interface_locked = TRUE
	var/hacked = FALSE

	categories = list(
		"Tools",
		"Electronics",
		"Construction",
		"T-Comm",
		"Security",
		"Machinery",
		"Medical",
		"Misc",
		"Dinnerware",
		"Imported"
		)

	accepts_disks = TRUE

	stored_research_type = /datum/techweb/specialized/autounlocking/autolathe

/obj/machinery/modular_fabricator/autolathe/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/autolathe(src)

/obj/machinery/modular_fabricator/autolathe/ui_interact(mob/user, datum/tgui/ui = null)
	if(!is_operational)
		return

	if(shocked && !(machine_stat & NOPOWER))
		shock(user,50)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ModularFabricator")
		ui.open()
		ui.set_autoupdate(TRUE)
		viewing_mobs += user

/obj/machinery/modular_fabricator/autolathe/ui_data(mob/user)
	var/list/data = ..()

	//Security interface
	data["sec_interface_unlock"] = !security_interface_locked
	data["hacked"] = hacked

	//Being Build
	return data

/obj/machinery/modular_fabricator/autolathe/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_safety")
			if(security_interface_locked)
				return
			adjust_hacked(!hacked)
			. = TRUE

		if("toggle_lock")
			if(obj_flags & EMAGGED)
				return
			if (!security_interface_locked)
				security_interface_locked = TRUE
			else
				var/obj/item/id_slot = usr.get_idcard(TRUE)
				if((ACCESS_SECURITY in id_slot.GetAccess()) && !(obj_flags & EMAGGED))
					security_interface_locked = FALSE
					to_chat(usr, span_warning("You unlock the security controls of [src]."))
			. = TRUE

/obj/machinery/modular_fabricator/autolathe/attackby(obj/item/O, mob/living/user, params)

	if((ACCESS_SECURITY in O.GetAccess()) && !(obj_flags & EMAGGED))
		security_interface_locked = !security_interface_locked
		to_chat(user, span_warning("You [security_interface_locked?"lock":"unlock"] the security controls of [src]."))
		return TRUE

	if(busy)
		balloon_alert(user, "it's busy!")
		return TRUE

	if(default_deconstruction_crowbar(O))
		return TRUE

	if(panel_open && is_wire_tool(O))
		wires.interact(user)
		return TRUE

	if(user.combat_mode) //so we can hit the machine
		return ..()

	if(machine_stat)
		return TRUE

	if(istype(O, /obj/item/disk/design_disk))
		user.visible_message("[user] loads \the [O] into \the [src]...",
			"You load a design from \the [O]...",
			"You hear the chatter of a floppy drive.")
		inserted_disk = O
		O.forceMove(src)
		update_viewer_statics()
		return TRUE

	if(panel_open)
		balloon_alert(user, "close the panel first!")
		return FALSE

	return ..()

/obj/machinery/modular_fabricator/autolathe/attackby_secondary(obj/item/weapon, mob/living/user, params)
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(busy)
		balloon_alert(user, "it's busy!")
		return

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", weapon))
		return

	if(machine_stat)
		return SECONDARY_ATTACK_CALL_NORMAL

	if(panel_open)
		balloon_alert(user, "close the panel first!")
		return

	return SECONDARY_ATTACK_CALL_NORMAL

/obj/machinery/modular_fabricator/autolathe/proc/reset(wire)
	switch(wire)
		if(WIRE_HACK)
			if(!wires.is_cut(wire))
				adjust_hacked(FALSE)
		if(WIRE_SHOCK)
			if(!wires.is_cut(wire))
				shocked = FALSE
		if(WIRE_DISABLE)
			if(!wires.is_cut(wire))
				disabled = FALSE
	wires.ui_update()

/obj/machinery/modular_fabricator/autolathe/proc/shock(mob/user, prb)
	if(machine_stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7, TRUE))
		return TRUE
	else
		return FALSE

/obj/machinery/modular_fabricator/autolathe/proc/adjust_hacked(state)
	hacked = state
	for(var/id in SSresearch.techweb_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(id)
		if((D.build_type & AUTOLATHE) && ("hacked" in D.category))
			if(hacked)
				stored_research.add_design(D)
			else
				stored_research.remove_design(D)
	update_viewer_statics()
	wires.ui_update()

/obj/machinery/modular_fabricator/autolathe/on_emag(mob/user)
	..()
	security_interface_locked = FALSE
	adjust_hacked(TRUE)
	playsound(src, "sparks", 100, 1)

/obj/machinery/modular_fabricator/autolathe/hacked/Initialize(mapload)
	. = ..()
	adjust_hacked(TRUE)

/obj/machinery/modular_fabricator/autolathe/AfterMaterialInsert(item_inserted, id_inserted, amount_inserted)
	. = ..()
	if(custom_materials && custom_materials.len && custom_materials[SSmaterials.GetMaterialRef(/datum/material/glass)])
		flick("autolathe_r",src)//plays glass insertion animation by default otherwise
	else
		flick("autolathe_o",src)//plays metal insertion animation

/obj/machinery/modular_fabricator/autolathe/set_default_sprite()
	icon_state = "autolathe"

/obj/machinery/modular_fabricator/autolathe/set_working_sprite()
	icon_state = "autolathe_n"
