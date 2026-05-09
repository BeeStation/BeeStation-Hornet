/obj/machinery/modular_fabricator/autolathe
	name = "autolathe"
	desc = "It produces items using iron, copper, and glass."
	icon_state = "autolathe"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/autolathe
	can_be_hacked_or_unlocked = TRUE
	accepts_disks = TRUE
	allowed_buildtypes = AUTOLATHE
	stored_research = /datum/techweb/autounlocking/autolathe

	var/shocked = FALSE

/obj/machinery/modular_fabricator/autolathe/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/autolathe(src)

/obj/machinery/modular_fabricator/autolathe/ui_interact(mob/user, datum/tgui/ui)
	if(!is_operational)
		return

	if(shocked)
		shock(user, 50)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ModularFabricator")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/modular_fabricator/autolathe/attackby(obj/item/attacking_item, mob/living/user, params)
	if(operating)
		balloon_alert(user, "it's busy!")
		return FALSE

	if(panel_open && is_wire_tool(attacking_item))
		wires.interact(user)
		return TRUE

	if(user.combat_mode) //so we can hit the machine
		return ..()

	if(machine_stat)
		return FALSE

	if(panel_open)
		balloon_alert(user, "close the panel first!")
		return FALSE

	return ..()

/obj/machinery/modular_fabricator/autolathe/crowbar_act_secondary(mob/living/user, obj/item/tool)
	if(operating)
		balloon_alert(user, "it's busy!")
		return
	return default_deconstruction_crowbar(tool)

/obj/machinery/modular_fabricator/autolathe/crowbar_act(mob/living/user, obj/item/tool)
	if(operating)
		balloon_alert(user, "it's busy!")
		return
	return default_deconstruction_crowbar(tool)

/obj/machinery/modular_fabricator/autolathe/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(operating)
		balloon_alert(user, "it's busy!")
		return
	return default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", tool)

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

/obj/machinery/modular_fabricator/autolathe/proc/shock(mob/user, chance)
	if(machine_stat & (BROKEN|NOPOWER)) // unpowered, no shock
		return FALSE
	if(!prob(chance))
		return FALSE
	var/datum/effect_system/spark_spread/sparks = new()
	sparks.set_up(5, 1, src)
	sparks.start()
	electrocute_mob(user, get_area(src), src, 0.7, 1)

/obj/machinery/modular_fabricator/autolathe/on_emag(mob/user)
	. = ..()
	security_interface_locked = FALSE
	hacked = TRUE
	update_static_data_for_all_viewers()
	wires.ui_update()
	playsound(src, "sparks", 100, TRUE)

/obj/machinery/modular_fabricator/autolathe/after_material_insert(item_inserted, id_inserted, amount_inserted)
	. = ..()
	if(length(custom_materials) && custom_materials[SSmaterials.GetMaterialRef(/datum/material/glass)])
		flick("autolathe_r", src)//plays glass insertion animation by default otherwise
	else
		flick("autolathe_o", src)//plays metal insertion animation

/obj/machinery/modular_fabricator/autolathe/set_default_sprite()
	icon_state = "autolathe"

/obj/machinery/modular_fabricator/autolathe/set_working_sprite()
	icon_state = "autolathe_n"

/obj/machinery/modular_fabricator/autolathe/hacked
	hacked = TRUE
