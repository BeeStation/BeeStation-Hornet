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

	//Security modes
	can_be_hacked_or_unlocked = TRUE
	var/security_interface_locked = TRUE
	var/hacked = FALSE

	categories = list(
		RND_CATEGORY_TOOLS,
		RND_CATEGORY_ELECTRONICS,
		RND_CATEGORY_CONSTRUCTION,
		RND_CATEGORY_TELECOMMS,
		RND_CATEGORY_SECURITY,
		RND_CATEGORY_MACHINERY,
		RND_CATEGORY_MEDICAL,
		RND_CATEGORY_MISC,
		RND_CATEGORY_DINNERWARE,
		RND_CATEGORY_IMPORTED,
	)

	accepts_disks = TRUE
	allowed_buildtypes = AUTOLATHE
	stored_research = /datum/techweb/autounlocking/autolathe

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
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/modular_fabricator/autolathe/ui_static_data(mob/user)
	var/list/data = ..()

	if(hacked && istype(stored_research, /datum/techweb/autounlocking))
		var/datum/techweb/autounlocking/autounlocking_web = stored_research
		data["items"] += handle_designs(autounlocking_web.hacked_designs)

	return data

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
			hacked = !hacked
			update_static_data_for_all_viewers()
			wires.ui_update()
			return FALSE // Lets avoid an unnecessary UI update, update_static_data_for_all_viewers() already did it for us

		if("toggle_lock")
			if(obj_flags & EMAGGED)
				return FALSE
			if (!security_interface_locked)
				security_interface_locked = TRUE
			else
				var/obj/item/id_slot = usr.get_idcard(TRUE)
				if((ACCESS_SECURITY in id_slot.GetAccess()) && !(obj_flags & EMAGGED))
					security_interface_locked = FALSE
					to_chat(usr, span_warning("You unlock the security controls of [src]."))
			return TRUE

/obj/machinery/modular_fabricator/autolathe/attackby(obj/item/attacking_item, mob/living/user, params)
	if((ACCESS_SECURITY in attacking_item.GetAccess()) && !(obj_flags & EMAGGED))
		security_interface_locked = !security_interface_locked
		to_chat(user, span_warning("You [security_interface_locked?"lock":"unlock"] the security controls of [src]."))
		return TRUE

	if(busy)
		balloon_alert(user, "it's busy!")
		return TRUE

	if(default_deconstruction_crowbar(attacking_item))
		return TRUE

	if(panel_open && is_wire_tool(attacking_item))
		wires.interact(user)
		return TRUE

	if(user.combat_mode) //so we can hit the machine
		return ..()

	if(machine_stat)
		return TRUE

	if(istype(attacking_item, /obj/item/disk/design_disk))
		user.visible_message("[user] loads \the [attacking_item] into \the [src]...",
			"You load a design from \the [attacking_item]...",
			"You hear the chatter of a floppy drive.")
		inserted_disk = attacking_item
		attacking_item.forceMove(src)
		update_static_data_for_all_viewers()
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
				hacked = FALSE
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

/obj/machinery/modular_fabricator/autolathe/on_emag(mob/user)
	..()
	security_interface_locked = FALSE
	update_static_data_for_all_viewers()
	wires.ui_update()
	playsound(src, "sparks", 100, TRUE)

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

/obj/machinery/modular_fabricator/autolathe/hacked
	hacked = TRUE
