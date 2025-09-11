/obj/item/export_scanner
	name = "export scanner"
	desc = "A device used to check objects against Nanotrasen exports and bounty database."
	icon = 'icons/obj/device.dmi'
	icon_state = "export_scanner"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	siemens_coefficient = 1
	var/obj/machinery/computer/cargo/cargo_console = null

/obj/item/export_scanner/examine(user)
	. = ..()
	if(!cargo_console)
		. += span_notice("[src] is not currently linked to a cargo console.")

/obj/item/export_scanner/afterattack(obj/O, mob/user, proximity)
	. = ..()
	if(!istype(O) || !proximity || HAS_TRAIT(O, TRAIT_IGNORE_EXPORT_SCAN))
		if(HAS_TRAIT(O, TRAIT_IGNORE_EXPORT_SCAN))
			to_chat(user, "<span class='warning'>[O] cannot be scanned!</span>")
			playsound(user, 'sound/machines/terminal_error.ogg', 30, TRUE)
		return

	if(istype(O, /obj/machinery/computer/cargo))
		var/obj/machinery/computer/cargo/C = O
		if(!C.requestonly)
			cargo_console = C
			to_chat(user, span_notice("Scanner linked to [C]."))
			playsound(user, 'sound/effects/fastbeep.ogg', 30)
	else if(!istype(cargo_console))
		to_chat(user, span_warning("You must link [src] to a cargo console first!"))
		playsound(user, 'sound/machines/terminal_error.ogg', 30, TRUE)
	else
		// Before you fix it:
		// yes, checking manifests is a part of intended functionality.

		var/datum/export_report/ex = export_item_and_contents(O, cargo_console.get_export_categories(), dry_run=TRUE)
		var/price = 0
		for(var/x in ex.total_amount)
			price += ex.total_value[x]

		var/datum/obj_demand_state/demand = get_obj_demand_state(O.type)
		var/current = demand.current_demand
		var/maximum = demand.max_demand
		var/stock = (maximum - current)
		if(stock < 0)	// Boilerplate
			stock = 0
		var/obj/effect/dummy/lighting_obj/glow = new(get_turf(O))
		glow.light_system = STATIC_LIGHT
		QDEL_IN(glow, 0.25 SECONDS)
		if(price)
			glow.set_light(1, 0.6, LIGHT_COLOR_GREEN)
			playsound(user, 'sound/effects/fastbeep.ogg', 30)
			balloon_alert(user, "<font color='#66c427'>Value:</font> [price] cr")
			to_chat(user, "Current stock of [O]: <span class='cfc_orange'><b>[stock]</span>/<span class='cfc_orange'>[demand.max_demand]</b></span>. Value: <span class='cfc_green'><b>[price] cr</b></span>[O.contents.len ? " (contents included)" : ""].")
		else
			glow.set_light(1, 0.6, LIGHT_COLOR_RED)
			playsound(user, 'sound/machines/terminal_error.ogg', 30, TRUE)
			balloon_alert(user, "<font color='#c41d1d'>Value:</font> [price] cr")
			to_chat(user, "No export value for <span class='cfc_red'>[O]</span>")

		if(istype(O, /obj/machinery/portable_atmospherics))
			var/obj/machinery/portable_atmospherics/canister/C = O
			var/datum/gas_mixture/canister_mix = C.return_air()
			var/canister_gas = canister_mix.gases
			for(var/id in canister_gas)
				var/datum/gas/path = gas_id2path(id)
				var/moles = canister_gas[id][MOLES]
				var/datum/obj_demand_state/gas_demand = get_obj_demand_state(path)
				var/gas_current = gas_demand.current_demand
				var/gas_maximum = gas_demand.max_demand
				var/gas_stock = (gas_maximum - gas_current)
				to_chat(user, ("Detected: [path.name] [round(moles)] mol / Current stock: <span class='cfc_orange'><b>[gas_stock]</span>/<span class='cfc_orange'>[gas_demand.max_demand]</b></span> Value: <span class='cfc_green'><b>[get_gas_value(path, moles)] cr</b></span>"))
		var/sound_played = FALSE
		if(O.is_contraband)
			to_chat(user, ("<span class='cfc_red'>CONTRABAND DETECTED:</span> <b>[O.name]</b>"))
			if(!sound_played)
				sound_played = TRUE
				playsound(user, 'sound/machines/uplinkerror.ogg', 30, TRUE)
		for(var/obj/thing in O.contents)
			if(thing.is_contraband)
				to_chat(user, ("<span class='cfc_red'>CONTRABAND DETECTED:</span> <b>[thing.name]</b>"))
				if(!sound_played)
					sound_played = TRUE
					playsound(user, 'sound/machines/uplinkerror.ogg', 30, TRUE)

		if(bounty_ship_item_and_contents(O, dry_run=TRUE))
			to_chat(user, ("<span class='cfc_soul_glimmer_azure'>[O.name] is eligible for one or more <b>bounties!</b></span>"))
