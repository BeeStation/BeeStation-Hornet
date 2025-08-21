// stored_energy += (pulse_strength-RAD_COLLECTOR_EFFICIENCY)*RAD_COLLECTOR_COEFFICIENT
#define RAD_COLLECTOR_EFFICIENCY 80 	// radiation needs to be over this amount to get power
#define RAD_COLLECTOR_COEFFICIENT 100
#define RAD_COLLECTOR_STORED_OUT 0.04	// (this*100)% of stored power outputted per tick. Doesn't actualy change output total, lower numbers just means collectors output for longer in absence of a source
#define RAD_COLLECTOR_MINING_CONVERSION_RATE 0.0001 //This is gonna need a lot of tweaking to get right. This is the number used to calculate the conversion of watts to research points per process()
#define RAD_COLLECTOR_OUTPUT min(stored_energy, (stored_energy*RAD_COLLECTOR_STORED_OUT)+1000) //Produces at least 1000 watts if it has more than that stored


/obj/machinery/power/rad_collector
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking Radiation and plasma to produce power."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "ca"
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_ENGINE_EQUIP)
//	use_power = NO_POWER_USE
	max_integrity = 350
	integrity_failure = 0.2
	circuit = /obj/item/circuitboard/machine/rad_collector
	rad_insulation = RAD_EXTREME_INSULATION
	var/obj/item/tank/internals/plasma/loaded_tank = null
	var/stored_energy = 0
	var/active = 0
	var/locked = FALSE
	var/drainratio = 0.5
	var/powerproduction_drain = 0.01
	var/bitcoinproduction_drain = 0.15
	var/bitcoinmining = FALSE
	var/obj/item/radio/radio

/obj/machinery/power/rad_collector/Initialize(mapload)
	. = ..()

	radio = new(src)
	radio.keyslot = new /obj/item/encryptionkey/headset_eng
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()

/obj/machinery/power/rad_collector/anchored/Initialize(mapload)
	. = ..()
	set_anchored(TRUE)

/obj/machinery/power/rad_collector/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/power/rad_collector/process(delta_time)
	if(!loaded_tank)
		return
	if(!bitcoinmining)
		if(GET_MOLES(/datum/gas/plasma, loaded_tank.air_contents) < 0.0001)
			investigate_log("<font color='red'>out of fuel</font>.", INVESTIGATE_ENGINES)
			playsound(src, 'sound/machines/ding.ogg', 50, 1)
			var/msg = "Plasma depleted, recommend replacing tank."
			radio.talk_into(src, msg, RADIO_CHANNEL_ENGINEERING)
			eject()
		else
			var/gasdrained = min(powerproduction_drain*drainratio*delta_time,GET_MOLES(/datum/gas/plasma, loaded_tank.air_contents))
			REMOVE_MOLES(/datum/gas/plasma, loaded_tank.air_contents, gasdrained)
			ADD_MOLES(/datum/gas/tritium, loaded_tank.air_contents, gasdrained)
			var/power_produced = RAD_COLLECTOR_OUTPUT
			add_avail(power_produced)
			stored_energy-=power_produced
	else if(is_station_level(z) && SSresearch.science_tech)
		if(!GET_MOLES(/datum/gas/tritium, loaded_tank.air_contents) || !GET_MOLES(/datum/gas/oxygen, loaded_tank.air_contents))
			playsound(src, 'sound/machines/ding.ogg', 50, 1)
			eject()
		else
			var/gasdrained = min(bitcoinproduction_drain*drainratio*delta_time,GET_MOLES(/datum/gas/tritium, loaded_tank.air_contents),GET_MOLES(/datum/gas/oxygen, loaded_tank.air_contents))
			REMOVE_MOLES(/datum/gas/tritium, loaded_tank.air_contents, gasdrained)
			REMOVE_MOLES(/datum/gas/oxygen, loaded_tank.air_contents, gasdrained)
			ADD_MOLES(/datum/gas/carbon_dioxide, loaded_tank.air_contents, gasdrained*2)
			var/bitcoins_mined = RAD_COLLECTOR_OUTPUT
			var/datum/bank_account/D = SSeconomy.get_budget_account(ACCOUNT_ENG_ID)
			if(D)
				D.adjust_money(bitcoins_mined*RAD_COLLECTOR_MINING_CONVERSION_RATE)//about 1500 credits per minute with 2 emitters and 6 collectors with stock parts
			SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, bitcoins_mined*RAD_COLLECTOR_MINING_CONVERSION_RATE)//about 1300 points per minute with the above set up
			SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, bitcoins_mined*RAD_COLLECTOR_MINING_CONVERSION_RATE)//same here
			stored_energy-=bitcoins_mined

/obj/machinery/power/rad_collector/interact(mob/user)
	if(anchored)
		if(!src.locked)
			toggle_power()
			user.visible_message("[user.name] turns the [src.name] [active? "on":"off"].", \
			span_notice("You turn the [src.name] [active? "on":"off"]."))
			var/fuel = 0
			if(loaded_tank)
				fuel = GET_MOLES(/datum/gas/plasma, loaded_tank.air_contents)
			investigate_log("turned [active?"<font color='green'>on</font>":"<font color='red'>off</font>"] by [key_name(user)]. [loaded_tank?"Fuel: [round(fuel/0.29)]%":"<font color='red'>It is empty</font>"].", INVESTIGATE_ENGINES)
			return
		else
			to_chat(user, span_warning("The controls are locked!"))
			return

/obj/machinery/power/rad_collector/can_be_unfasten_wrench(mob/user, silent)
	if(loaded_tank)
		if(!silent)
			to_chat(user, span_warning("Remove the plasma tank first!"))
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/power/rad_collector/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return //no need to process if we didn't change anything.
	if(anchorvalue)
		connect_to_network()
	else
		disconnect_from_network()

/obj/machinery/power/rad_collector/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/tank/internals/plasma))
		if(!anchored)
			to_chat(user, span_warning("[src] needs to be secured to the floor first!"))
			return TRUE
		if(loaded_tank)
			to_chat(user, span_warning("There's already a plasma tank loaded!"))
			return TRUE
		if(panel_open)
			to_chat(user, span_warning("Close the maintenance panel first!"))
			return TRUE
		if(!user.transferItemToLoc(W, src))
			return
		loaded_tank = W
		update_icon()
	else if(W.GetID())
		if(allowed(user))
			if(active)
				locked = !locked
				to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the controls."))
			else
				to_chat(user, span_warning("The controls can only be locked when \the [src] is active!"))
		else
			to_chat(user, span_danger("Access denied."))
			return TRUE
	else
		return ..()

/obj/machinery/power/rad_collector/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I)
	return TRUE

/obj/machinery/power/rad_collector/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(loaded_tank)
		to_chat(user, span_warning("Remove the plasma tank first!"))
	else
		default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	return TRUE

/obj/machinery/power/rad_collector/crowbar_act(mob/living/user, obj/item/I)
	if(loaded_tank)
		if(locked)
			to_chat(user, span_warning("The controls are locked!"))
			return TRUE
		eject()
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE
	to_chat(user, span_warning("There isn't a tank loaded!"))
	return TRUE

/obj/machinery/power/rad_collector/multitool_act(mob/living/user, obj/item/I)
	if(!is_station_level(z) && !SSresearch.science_tech)
		to_chat(user, span_warning("[src] isn't linked to a research system!"))
		return TRUE
	if(locked)
		to_chat(user, span_warning("[src] is locked!"))
		return TRUE
	if(active)
		to_chat(user, span_warning("[src] is currently active, producing [bitcoinmining ? "research points":"power"]."))
		return TRUE
	bitcoinmining = !bitcoinmining
	to_chat(user, span_warning("You [bitcoinmining ? "enable":"disable"] the research point production feature of [src]."))
	return TRUE

/obj/machinery/power/rad_collector/return_analyzable_air()
	if(loaded_tank)
		return loaded_tank.return_analyzable_air()
	else
		return null

/obj/machinery/power/rad_collector/examine(mob/user)
	. = ..()
	if(active)
		if(!bitcoinmining)
			// stored_energy is converted directly to watts every SSmachines.wait * 0.1 seconds.
			// Therefore, its units are joules per SSmachines.wait * 0.1 seconds.
			// So joules = stored_energy * SSmachines.wait * 0.1
			var/joules = stored_energy * SSmachines.wait * 0.1
			. += span_notice("[src]'s display states that it has stored <b>[display_joules(joules)]</b>, and is processing <b>[display_power(RAD_COLLECTOR_OUTPUT)]</b>.")
		else
			. += span_notice("[src]'s display states that it has stored a total of <b>[stored_energy*RAD_COLLECTOR_MINING_CONVERSION_RATE]</b>, and is producing [RAD_COLLECTOR_OUTPUT*RAD_COLLECTOR_MINING_CONVERSION_RATE] research points per minute.")
	else
		if(!bitcoinmining)
			. += span_notice("<b>[src]'s display displays the words:</b> \"Power production mode. Please insert <b>Plasma</b>. Use a multitool to change production modes.\"")
		else
			. += span_notice("<b>[src]'s display displays the words:</b> \"Research point production mode. Please insert <b>Tritium</b> and <b>Oxygen</b>. Use a multitool to change production modes.\"")

/obj/machinery/power/rad_collector/atom_break(damage_flag)
	. = ..()
	if(.)
		eject()

/obj/machinery/power/rad_collector/proc/eject()
	locked = FALSE
	var/obj/item/tank/internals/plasma/Z = src.loaded_tank
	if (!Z)
		return
	Z.forceMove(drop_location())
	Z.layer = initial(Z.layer)
	Z.plane = initial(Z.plane)
	src.loaded_tank = null
	if(active)
		toggle_power()
	else
		update_icon()

/obj/machinery/power/rad_collector/rad_act(pulse_strength)
	. = ..()
	if(loaded_tank && active && pulse_strength > RAD_COLLECTOR_EFFICIENCY)
		stored_energy += (pulse_strength-RAD_COLLECTOR_EFFICIENCY)*RAD_COLLECTOR_COEFFICIENT

/obj/machinery/power/rad_collector/update_icon()
	cut_overlays()
	if(loaded_tank)
		add_overlay("ptank")
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(active)
		add_overlay("on")


/obj/machinery/power/rad_collector/proc/toggle_power()
	active = !active
	if(active)
		icon_state = "ca_on"
		flick("ca_active", src)
	else
		icon_state = "ca"
		flick("ca_deactive", src)
	update_icon()
	return

#undef RAD_COLLECTOR_EFFICIENCY
#undef RAD_COLLECTOR_COEFFICIENT
#undef RAD_COLLECTOR_STORED_OUT
#undef RAD_COLLECTOR_MINING_CONVERSION_RATE
#undef RAD_COLLECTOR_OUTPUT
