/obj/item/export_scanner
	name = "export scanner"
	desc = "A device used to check objects against Nanotrasen exports and bounty database."
	icon = 'icons/obj/device.dmi'
	icon_state = "export_scanner"
	inhand_icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	siemens_coefficient = 1
	/// This stops the export scanner not being able to scan storages without going inside them, by adding a on and off state
	var/is_on = TRUE
	var/obj/machinery/computer/cargo/cargo_console = null

/obj/item/export_scanner/examine(user)
	. = ..()
	. += span_notice("Scanning is [is_on ? "<span class='cfc_green'>Enabled</span>" : "<span class='cfc_red'>Disabled</span>"]")
	if(!cargo_console)
		. += span_notice("[src] is not currently linked to a cargo console.")

/obj/item/export_scanner/pre_attack(obj/current_object, mob/user, proximity)
	. = ..()
	if(!is_on)
		return FALSE
	if(!istype(current_object) || !proximity || HAS_TRAIT(current_object, TRAIT_IGNORE_EXPORT_SCAN))
		if(HAS_TRAIT(current_object, TRAIT_IGNORE_EXPORT_SCAN))
			to_chat(user, span_warning("[current_object] cannot be scanned!"))
			playsound(user, 'sound/machines/terminal_error.ogg', 30, TRUE)
		return

	if(istype(current_object, /obj/machinery/computer/cargo))
		var/obj/machinery/computer/cargo/console = current_object
		if(!console.requestonly)
			cargo_console = console
			to_chat(user, span_notice("Scanner linked to [console]."))
			playsound(user, 'sound/effects/fastbeep.ogg', 30)
	else if(!istype(cargo_console))
		to_chat(user, span_warning("You must link [src] to a cargo console first!"))
		playsound(user, 'sound/machines/terminal_error.ogg', 30, TRUE)
	else
		// Before you fix it:
		// yes, checking manifests is a part of intended functionality.

		var/datum/export_report/ex = export_item_and_contents(current_object, cargo_console.get_export_categories(), dry_run=TRUE)
		var/price = 0
		for(var/x in ex.total_amount)
			price += ex.total_value[x]

		var/datum/demand_state/demand = SSdemand.get_demand_state(current_object.type)
		var/current = demand.current_demand
		var/maximum = demand.max_demand
		var/stock = max(maximum - current, 0)
		var/obj/effect/dummy/lighting_obj/glow = new(get_turf(current_object))
		glow.light_system = STATIC_LIGHT
		QDEL_IN(glow, 0.25 SECONDS)
		if(price)
			glow.set_light(1, 0.6, LIGHT_COLOR_GREEN)
			playsound(user, 'sound/effects/fastbeep.ogg', 30)
			balloon_alert(user, "<font color='#66c427'>Value:</font> [price] cr")
			to_chat(user, "Current stock of [current_object]: <span class='cfc_orange'><b>[stock]</span>/<span class='cfc_orange'>[demand.max_demand]</b></span>. Value: <span class='cfc_green'><b>[price] cr</b></span>[length(current_object.contents) ? " (contents included)" : ""].")
		else
			glow.set_light(1, 0.6, LIGHT_COLOR_RED)
			playsound(user, 'sound/machines/terminal_error.ogg', 30, TRUE)
			balloon_alert(user, "<font color='#c41d1d'>Value:</font> [price] cr")
			if(current == 0)	// If demand is 0, price will always be 0
				to_chat(user, "Current stock of [current_object]: <span class='cfc_orange'><b>[stock]</span>/<span class='cfc_orange'>[demand.max_demand]</b></span>. Value: <span class='cfc_red'><b>[price] cr</b></span>[length(current_object.contents) ? " (contents included)" : ""].")
			else
				to_chat(user, "No export value for <span class='cfc_red'>[current_object]</span>")

		if(istype(current_object, /obj/machinery/portable_atmospherics))
			var/obj/machinery/portable_atmospherics/canister/gas_can = current_object
			var/datum/gas_mixture/canister_mix = gas_can.return_air()
			var/canister_gas = canister_mix.gases
			for(var/id in canister_gas)
				var/datum/gas/path = gas_id2path(id)
				var/moles = canister_gas[id][MOLES]
				var/datum/demand_state/gas_demand = SSdemand.get_demand_state(path)
				var/gas_current = gas_demand.current_demand
				var/gas_maximum = gas_demand.max_demand
				var/gas_stock = (gas_maximum - gas_current)
				to_chat(user, "Detected: [path.name] [round(moles)] mol / Current stock: <span class='cfc_orange'><b>[gas_stock]</span>/<span class='cfc_orange'>[gas_demand.max_demand]</b></span> Value: <span class='cfc_green'><b>[SSdemand.get_gas_value(path, moles)] cr</b></span>")
		var/sound_played = FALSE
		if(current_object.trade_flags & TRADE_CONTRABAND)
			to_chat(user, "<span class='cfc_red'>CONTRABAND DETECTED:</span> <b>[current_object.name]</b>")
			if(!sound_played)
				sound_played = TRUE
				playsound(user, 'sound/machines/uplinkerror.ogg', 30, TRUE)
		for(var/obj/thing in current_object.contents)
			if(thing.trade_flags & TRADE_CONTRABAND)
				to_chat(user, "<span class='cfc_red'>CONTRABAND DETECTED:</span> <b>[thing.name]</b>")
				if(!sound_played)
					sound_played = TRUE
					playsound(user, 'sound/machines/uplinkerror.ogg', 30, TRUE)

		if(bounty_ship_item_and_contents(current_object, dry_run=TRUE))
			to_chat(user, "<span class='cfc_soul_glimmer_azure'>[current_object.name] is eligible for one or more <b>bounties!</b></span>")
		return TRUE

/obj/item/export_scanner/attack_self(mob/user, modifiers)
	. = ..()
	is_on = !is_on
	playsound(src, 'sound/weapons/pistolrack.ogg', 50)
	flick("export_scanner_rack", src)
	balloon_alert(user, "Scanning: [is_on ? "<font color='#66c427'>Enabled</font>" : "<font color='#c41d1d'>Disabled</font>"]")
