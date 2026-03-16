#define CRYOMOBS 'icons/obj/cryo_mobs.dmi'
#define CRYO_MULTIPLY_FACTOR 1.5 // Multiply factor is used with efficiency to multiply Tx quantity and how much extra is transfered to occupant magically.
#define CRYO_TX_QTY 0.4 // Tx quantity is how much volume should be removed from the cell's beaker - multiplied by delta_time
#define CRYO_MIN_GAS_MOLES 5
#define MAX_TEMPERATURE 4000


/obj/machinery/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "pod-off"
	density = TRUE
	max_integrity = 350
	armor_type = /datum/armor/unary_cryo_cell
	layer = ABOVE_WINDOW_LAYER
	state_open = FALSE
	circuit = /obj/item/circuitboard/machine/cryo_tube
	flags_1 = PREVENT_CLICK_UNDER_1
	occupant_typecache = list(/mob/living/carbon, /mob/living/simple_animal)

	var/autoeject = TRUE
	var/volume = 100

	var/efficiency = 1
	var/sleep_factor = 0.00125
	var/unconscious_factor = 0.001
	/// Our approximation of a mob's heat capacity.
	var/heat_capacity = 20000
	var/conduction_coefficient = 0.3

	var/obj/item/reagent_containers/cup/beaker = null

	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/headset_med
	var/radio_channel = RADIO_CHANNEL_MEDICAL

	var/running_anim = FALSE

	var/escape_in_progress = FALSE
	var/message_cooldown
	var/breakout_time = 300
	fair_market_price = 10

	/// Reference to the datum connector we're using to interface with the pipe network
	var/datum/gas_machine_connector/internal_connector
	/// Check if the machine has been turned on
	var/on = FALSE


/datum/armor/unary_cryo_cell
	energy = 100
	fire = 30
	acid = 30

/obj/machinery/cryo_cell/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.keyslot = new radio_key
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()
	internal_connector = new(loc, src, dir, CELL_VOLUME * 0.5)

/obj/machinery/cryo_cell/set_occupant(atom/movable/new_occupant)
	. = ..()
	update_icon()

/obj/machinery/cryo_cell/on_construction()
	..(dir, dir)

/obj/machinery/cryo_cell/RefreshParts()
	var/C
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		C += M.rating

	efficiency = initial(efficiency) * C
	sleep_factor = initial(sleep_factor) * C
	unconscious_factor = initial(unconscious_factor) * C
	heat_capacity = initial(heat_capacity) / C
	conduction_coefficient = initial(conduction_coefficient) * C

/obj/machinery/cryo_cell/examine(mob/user) //this is leaving out everything but efficiency since they follow the same idea of "better beaker, better results"
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Efficiency at <b>[efficiency*100]%</b>.")

/obj/machinery/cryo_cell/add_context_self(datum/screentip_context/context, mob/user)
	context.add_ctrl_click_action("Turn [on ? "off" : "on"]")
	context.add_alt_click_action("[state_open ? "Close" : "Open"] door")

/obj/machinery/cryo_cell/Destroy()
	QDEL_NULL(radio)
	QDEL_NULL(beaker)
	QDEL_NULL(internal_connector)
	return ..()

/obj/machinery/cryo_cell/contents_explosion(severity, target)
	..()
	if(beaker)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += beaker
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += beaker
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += beaker

/obj/machinery/cryo_cell/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		updateUsrDialog()

/obj/machinery/cryo_cell/on_deconstruction()
	if(beaker)
		beaker.forceMove(drop_location())
		beaker = null

/obj/machinery/cryo_cell/update_icon()

	cut_overlays()

	if(panel_open)
		add_overlay("pod-panel")

	if(state_open)
		icon_state = "pod-open"
		return

	if(occupant)
		var/image/occupant_overlay

		if(ismonkey(occupant)) // Monkey
			occupant_overlay = image(CRYOMOBS, "monkey")
		else if(isalienadult(occupant))
			if(isalienroyal(occupant)) // Queen and prae
				occupant_overlay = image(CRYOMOBS, "alienq")
			else if(isalienhunter(occupant)) // Hunter
				occupant_overlay = image(CRYOMOBS, "alienh")
			else if(isaliensentinel(occupant)) // Sentinel
				occupant_overlay = image(CRYOMOBS, "aliens")
			else // Drone or other
				occupant_overlay = image(CRYOMOBS, "aliend")

		else if(ishuman(occupant) || islarva(occupant) || (isanimal(occupant) && !ismegafauna(occupant))) // Mobs that are smaller than cryotube
			occupant_overlay = image(occupant.icon, occupant.icon_state)
			occupant_overlay.copy_overlays(occupant)

		else
			occupant_overlay = image(CRYOMOBS, "generic")

		occupant_overlay.dir = SOUTH
		occupant_overlay.pixel_y = 22

		if(on && !running_anim && is_operational)
			icon_state = "pod-on"
			running_anim = TRUE
			run_anim(TRUE, occupant_overlay)
		else
			icon_state = "pod-off"
			add_overlay(occupant_overlay)
			add_overlay("cover-off")

	else if(on && is_operational)
		icon_state = "pod-on"
		add_overlay("cover-on")
	else
		icon_state = "pod-off"
		add_overlay("cover-off")

/obj/machinery/cryo_cell/proc/run_anim(anim_up, image/occupant_overlay)
	if(!on || !occupant || !is_operational)
		running_anim = FALSE
		return
	cut_overlays()
	if(occupant_overlay.pixel_y != 23) // Same effect as occupant_overlay.pixel_y == 22 || occupant_overlay.pixel_y == 24
		anim_up = occupant_overlay.pixel_y == 22 // Same effect as if(occupant_overlay.pixel_y == 22) anim_up = TRUE ; if(occupant_overlay.pixel_y == 24) anim_up = FALSE
	if(anim_up)
		occupant_overlay.pixel_y++
	else
		occupant_overlay.pixel_y--
	add_overlay(occupant_overlay)
	add_overlay("cover-on")
	addtimer(CALLBACK(src, PROC_REF(run_anim), anim_up, occupant_overlay), 7, TIMER_UNIQUE)

/obj/machinery/cryo_cell/nap_violation(mob/violator)
	open_machine()

/obj/machinery/cryo_cell/proc/set_on(active)
	if(on == active)
		return
	SEND_SIGNAL(src, COMSIG_CRYO_SET_ON, active)
	. = on
	on = active
	update_appearance()

/obj/machinery/cryo_cell/process(delta_time)
	if(!on)
		return

	if(!is_operational)
		on = FALSE
		update_icon()
		return

	if(!occupant)//Won't operate unless there's an occupant.
		on = FALSE
		update_icon()
		var/msg = "Aborting. No occupant detected."
		radio.talk_into(src, msg, radio_channel)
		return

	if(!beaker?.reagents?.reagent_list.len) //No beaker or beaker without reagents with stop the machine from running.
		on = FALSE
		update_icon()
		var/msg = "Aborting. No beaker or chemicals installed."
		radio.talk_into(src, msg, radio_channel)
		return

	var/mob/living/mob_occupant = occupant
	if(mob_occupant.on_fire) //Extinguish occupant, happens after the occupant is healed and ejected.
		mob_occupant.extinguish_mob()
	if(!check_nap_violations())
		return
	if(mob_occupant.stat == DEAD) // We don't bother with dead people.
		return

	if(mob_occupant.get_organic_health() >= mob_occupant.getMaxHealth()) // Don't bother with fully healed people.
		on = FALSE
		update_icon()
		playsound(src, 'sound/machines/cryo_warning.ogg', volume) // Bug the doctors.
		var/msg = "Patient fully restored."
		if(autoeject) // Eject if configured.
			msg += " Auto ejecting patient now."
			open_machine()
		radio.talk_into(src, msg, radio_channel)
		return

	var/datum/gas_mixture/air1 = internal_connector.gas_connector.airs[1]

	if(air1.total_moles())
		if(mob_occupant.bodytemperature < T0C) // Sleepytime. Why? More cryo magic.
			mob_occupant.Sleeping((mob_occupant.bodytemperature * sleep_factor) * 1000 * delta_time)
			mob_occupant.Unconscious((mob_occupant.bodytemperature * unconscious_factor) * 1000 * delta_time)
		if(beaker)//How much to transfer. As efficiency is increased, less reagent from the beaker is used and more is magically transferred to occupant
			beaker.reagents.trans_to(occupant, (CRYO_TX_QTY / (efficiency * CRYO_MULTIPLY_FACTOR)) * delta_time, efficiency * CRYO_MULTIPLY_FACTOR, method = VAPOR) // Transfer reagents.
		use_power(1000 * efficiency)

	return TRUE

/obj/machinery/cryo_cell/process_atmos()
	..()

	if(!on)
		return

	var/datum/gas_mixture/air1 = internal_connector.gas_connector.airs[1]

	if(!internal_connector.gas_connector.nodes[1] || !internal_connector.gas_connector.airs[1] || !air1.gases.len || air1.total_moles() < CRYO_MIN_GAS_MOLES) // Turn off if the machine won't work due to not having enough moles to operate.
		on = FALSE
		update_icon()
		var/msg = "Aborting. Not enough gas present to operate."
		radio.talk_into(src, msg, radio_channel)
		return

	if(occupant)
		var/mob/living/mob_occupant = occupant
		var/cold_protection = 0
		var/temperature_delta = air1.return_temperature() - mob_occupant.bodytemperature // The only semi-realistic thing here: share temperature between the cell and the occupant.

		if(ishuman(mob_occupant))
			var/mob/living/carbon/human/H = mob_occupant
			cold_protection = H.get_cold_protection(air1.return_temperature())

		if(abs(temperature_delta) > 1)
			var/air_heat_capacity = air1.heat_capacity()

			var/heat = ((1 - cold_protection) * 0.1 + conduction_coefficient) * CALCULATE_CONDUCTION_ENERGY(temperature_delta, heat_capacity, air_heat_capacity)

			mob_occupant.adjust_bodytemperature(heat / heat_capacity, TCMB)
			air1.temperature = clamp(air1.temperature - heat / air_heat_capacity, TCMB, MAX_TEMPERATURE)

		SET_MOLES(/datum/gas/oxygen, air1, max(0,GET_MOLES(/datum/gas/oxygen, air1) - 0.5 / efficiency)) // Magically consume gas? Why not, we run on cryo magic.

	internal_connector.gas_connector.update_parents()

/obj/machinery/cryo_cell/relaymove(mob/living/user, direction)
	if(message_cooldown <= world.time)
		message_cooldown = world.time + 50
		to_chat(user, span_warning("[src]'s door won't budge!"))

/obj/machinery/cryo_cell/open_machine(drop = FALSE)
	if(!state_open && !panel_open)
		on = FALSE
	for(var/mob/M in contents) //only drop mobs
		M.forceMove(get_turf(src))
	set_occupant(null)
	flick("pod-open-anim", src)
	..()

/obj/machinery/cryo_cell/close_machine(mob/living/carbon/user)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		flick("pod-close-anim", src)
		..(user)
		return occupant

/obj/machinery/cryo_cell/container_resist(mob/living/user)
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(span_notice("You see [user] kicking against the glass of [src]!"), \
		span_notice("You struggle inside [src], kicking the release with your foot... (this will take about [DisplayTimeText(breakout_time)].)"), \
		span_italics("You hear a thump from [src]."))
	if(do_after(user, breakout_time, target = src, hidden = TRUE))
		if(!user || user.stat != CONSCIOUS || user.loc != src )
			return
		user.visible_message(span_warning("[user] successfully broke out of [src]!"), \
			span_notice("You successfully break out of [src]!"))
		open_machine()

/obj/machinery/cryo_cell/examine(mob/user)
	. = ..()
	if(occupant)
		if(on)
			. += "Someone's inside [src]!"
		else
			. += "You can barely make out a form floating in [src]."
	else
		. += "[src] seems empty."

/obj/machinery/cryo_cell/MouseDrop_T(mob/target, mob/user)
	if(user.incapacitated || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !ISADVANCEDTOOLUSER(user))
		return
	if(isliving(target))
		var/mob/living/L = target
		if(L.incapacitated)
			close_machine(target)
	else
		user.visible_message("<b>[user]</b> starts shoving [target] inside [src].", span_notice("You start shoving [target] inside [src]."))
		if (do_after(user, 25, target=target))
			close_machine(target)

/obj/machinery/cryo_cell/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/cup))
		. = 1 //no afterattack
		if(beaker)
			to_chat(user, span_warning("A beaker is already loaded into [src]!"))
			return
		if(!user.transferItemToLoc(I, src))
			return
		beaker = I
		user.visible_message("[user] places [I] in [src].", \
							span_notice("You place [I] in [src]."))
		var/reagentlist = pretty_string_from_reagent_list(I.reagents.reagent_list)
		log_game("[key_name(user)] added an [I] to cryo containing [reagentlist]")
		return
	if(!on && !occupant && !state_open && (default_deconstruction_screwdriver(user, "pod-off", "pod-off", I)) \
		|| default_change_direction_wrench(user, I) \
		|| default_pry_open(I))
		update_icon()
		return
	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		to_chat(user, span_notice("You can't access the maintenance panel while the pod is [on ? "active" : (occupant ? "full" : "open")]"))
		return
	return ..()

/obj/machinery/cryo_cell/crowbar_act(mob/living/user, obj/item/tool)
	if(on || state_open)
		return FALSE
	if(!panel_open)
		balloon_alert(user, "open panel!")
		return TRUE

	var/unsafe_wrenching = FALSE
	var/filled_pipe = FALSE
	var/datum/gas_mixture/environment_air = loc.return_air()
	var/datum/gas_mixture/inside_air = internal_connector.gas_connector.airs[1]
	var/obj/machinery/atmospherics/node = internal_connector.gas_connector.nodes[1]
	var/internal_pressure = 0

	if(istype(node, /obj/machinery/atmospherics/components/unary/portables_connector))
		var/obj/machinery/atmospherics/components/unary/portables_connector/portable_devices_connector = node
		internal_pressure = !portable_devices_connector.connected_device ? 1 : 0

	if(inside_air.total_moles() > 0)
		filled_pipe = TRUE
		if(!node || internal_pressure > 0)
			internal_pressure = inside_air.return_pressure() - environment_air.return_pressure()

	if(!filled_pipe)
		default_deconstruction_crowbar(tool)
		return TRUE

	to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...")

	if(internal_pressure > 2 * ONE_ATMOSPHERE)
		to_chat(user, span_warning("As you begin deconstructing  the [src] a gush of air blows in your face... maybe you should reconsider?"))
		unsafe_wrenching = TRUE

	if(!do_after(user, 2 SECONDS, src))
		return
	if(unsafe_wrenching)
		internal_connector.gas_connector.unsafe_pressure_release(user, internal_pressure)

	tool.play_tool_sound(src, 50)
	deconstruct(TRUE)
	return TRUE

/obj/machinery/cryo_cell/ui_state(mob/user)
	return GLOB.notcontained_state

/obj/machinery/cryo_cell/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Cryo")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/cryo_cell/ui_data()
	var/list/data = list()
	data["isOperating"] = on
	data["hasOccupant"] = occupant ? TRUE : FALSE
	data["isOpen"] = state_open
	data["autoEject"] = autoeject

	data["occupant"] = list()
	if(occupant)
		var/mob/living/mob_occupant = occupant
		data["occupant"]["name"] = mob_occupant.name
		switch(mob_occupant.stat)
			if(CONSCIOUS)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "good"
			if(SOFT_CRIT)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "average"
			if(UNCONSCIOUS, HARD_CRIT)
				data["occupant"]["stat"] = "Unconscious"
				data["occupant"]["statstate"] = "average"
			if(DEAD)
				data["occupant"]["stat"] = "Dead"
				data["occupant"]["statstate"] = "bad"
		data["occupant"]["health"] = round(mob_occupant.health, 1)
		data["occupant"]["maxHealth"] = mob_occupant.maxHealth
		data["occupant"]["minHealth"] = HEALTH_THRESHOLD_DEAD
		data["occupant"]["bruteLoss"] = round(mob_occupant.getBruteLoss(), 1)
		data["occupant"]["oxyLoss"] = round(mob_occupant.getOxyLoss(), 1)
		data["occupant"]["toxLoss"] = round(mob_occupant.getToxLoss(), 1)
		data["occupant"]["fireLoss"] = round(mob_occupant.getFireLoss(), 1)
		data["occupant"]["bodyTemperature"] = round(mob_occupant.bodytemperature, 1)
		if(mob_occupant.bodytemperature < TCRYO)
			data["occupant"]["temperaturestatus"] = "good"
		else if(mob_occupant.bodytemperature < T0C)
			data["occupant"]["temperaturestatus"] = "average"
		else
			data["occupant"]["temperaturestatus"] = "bad"

	var/datum/gas_mixture/air1 = internal_connector.gas_connector.airs[1]
	data["cellTemperature"] = round(air1.return_temperature(), 1)

	data["isBeakerLoaded"] = beaker ? TRUE : FALSE
	var/beakerContents = list()
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents += list(list("name" = R.name, "volume" = R.volume))
	data["beakerContents"] = beakerContents
	return data

/obj/machinery/cryo_cell/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			if(on)
				on = FALSE
			else if(!state_open)
				on = TRUE
			update_icon()
			. = TRUE
		if("door")
			if(state_open)
				close_machine()
			else
				open_machine()
			. = TRUE
		if("autoeject")
			autoeject = !autoeject
			. = TRUE
		if("ejectbeaker")
			if(beaker)
				beaker.forceMove(drop_location())
				if(Adjacent(usr) && !issilicon(usr))
					usr.put_in_hands(beaker)
				beaker = null
				. = TRUE

/obj/machinery/cryo_cell/CtrlClick(mob/user)
	if(user.canUseTopic(src, !issilicon(user)) && !state_open && occupant != user)
		set_on(!on)
		update_icon()
	return ..()

/obj/machinery/cryo_cell/AltClick(mob/user)
	if(user.canUseTopic(src, !issilicon(user)) && occupant != user)
		if(state_open)
			close_machine()
		else
			open_machine()
	return

/obj/machinery/cryo_cell/get_remote_view_fullscreens(mob/user)
	user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 1)

/obj/machinery/cryo_cell/return_temperature()
	var/datum/gas_mixture/G = internal_connector.gas_connector.airs[1]

	if(G.total_moles() > 10)
		return G.return_temperature()
	return ..()

#undef CRYOMOBS
#undef CRYO_MULTIPLY_FACTOR
#undef CRYO_TX_QTY
#undef CRYO_MIN_GAS_MOLES
#undef MAX_TEMPERATURE
