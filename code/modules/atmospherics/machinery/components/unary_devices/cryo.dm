#define CRYOMOBS 'icons/obj/cryo_mobs.dmi'
#define CRYO_TX_QTY 0.4 // Tx quantity is how much volume should be removed from the cell's beaker - multiplied by delta_time
#define MODE_OFF	0
#define MODE_CRYOSLEEP 	1

/obj/machinery/atmospherics/components/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "pod-off"
	density = TRUE
	max_integrity = 350
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 30, "acid" = 30, "stamina" = 0)
	layer = ABOVE_WINDOW_LAYER
	state_open = FALSE
	circuit = /obj/item/circuitboard/machine/cryo_tube


	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	occupant_typecache = list(/mob/living/carbon, /mob/living/simple_animal)

	var/volume = 100

	var/efficiency = 1
	var/sleep_factor = 0.00125
	var/unconscious_factor = 0.001
	var/heat_capacity = 20000
	var/conduction_coefficient = 0.3

	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/headset_med
	var/radio_channel = RADIO_CHANNEL_MEDICAL

	var/running_anim = FALSE

	var/escape_in_progress = FALSE
	var/message_cooldown
	var/breakout_time = 300
	var/enchanted_scan = FALSE
	var/list/chemicals_queue = list()
	var/injecting = FALSE			//are we injecting anything right now?
	var/mode = MODE_OFF
	fair_market_price = 10
	payment_department = ACCOUNT_MED


/obj/machinery/atmospherics/components/unary/cryo_cell/Initialize()
	create_reagents(100, OPENCONTAINER)		//reagents need to be initialized before calling parent proc
	. = ..()
	initialize_directions = dir

	radio = new(src)
	radio.keyslot = new radio_key
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()
	reagents.flags |= NO_REACT

/obj/machinery/atmospherics/components/unary/cryo_cell/Exited(atom/movable/AM, atom/newloc)
	var/old_occupant = occupant
	. = ..() // Parent proc takes care of removing occupant if necessary
	if (AM == old_occupant)
		update_icon()

/obj/machinery/atmospherics/components/unary/cryo_cell/on_construction()
	..(dir, dir)

/obj/machinery/atmospherics/components/unary/cryo_cell/RefreshParts()
	var/conduction_efficency		//from matter bins
	var/efficency_multiplier		//chemical efficency from manipulators
	var/sleep_multiplier			//from manipulator
	for(var/obj/item/stock_parts/S in component_parts)
		if(istype(S, /obj/item/stock_parts/matter_bin))
			conduction_efficency += S.rating / 2
		else if(istype(S, /obj/item/stock_parts/manipulator))
			efficency_multiplier += S.rating / 2
		else if(istype(S, /obj/item/stock_parts/scanning_module))
			sleep_multiplier += S.rating
			if(S.rating >= 3)
				enchanted_scan = TRUE
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.maximum_volume += G.volume
		G.reagents.trans_to(src, G.reagents.total_volume)

	efficiency = initial(efficiency) * efficency_multiplier				//how much power are we using, how much fuel we use, how much we inject per tick
	sleep_factor = initial(sleep_factor) * sleep_multiplier
	unconscious_factor = initial(unconscious_factor) * sleep_multiplier
	heat_capacity = initial(heat_capacity) / conduction_efficency
	conduction_coefficient = initial(conduction_coefficient) * conduction_efficency

/obj/machinery/atmospherics/components/unary/cryo_cell/examine(mob/user) //this is leaving out everything but efficiency since they follow the same idea of "better beaker, better results"
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Efficiency at <b>[efficiency*100]%</b>.</span>"

/obj/machinery/atmospherics/components/unary/cryo_cell/emag_act()
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(4, 0, src.loc)
	spark_system.start()
	playsound(src, "sparks", 50, 1)

/obj/machinery/atmospherics/components/unary/cryo_cell/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/on_deconstruction()
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)

/obj/machinery/atmospherics/components/unary/cryo_cell/update_icon()

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

		if(on && !running_anim && is_operational())
			icon_state = "pod-on"
			running_anim = TRUE
			run_anim(TRUE, occupant_overlay)
		else
			icon_state = "pod-off"
			add_overlay(occupant_overlay)
			add_overlay("cover-off")

	else if(on && is_operational())
		icon_state = "pod-on"
		add_overlay("cover-on")
	else
		icon_state = "pod-off"
		add_overlay("cover-off")

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/run_anim(anim_up, image/occupant_overlay)
	if(!on || !occupant || !is_operational())
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
	addtimer(CALLBACK(src, .proc/run_anim, anim_up, occupant_overlay), 7, TIMER_UNIQUE)

/obj/machinery/atmospherics/components/unary/cryo_cell/nap_violation(mob/violator)
	open_machine()

/obj/machinery/atmospherics/components/unary/cryo_cell/process(delta_time)
	..()


	if(!on)
		mode = MODE_OFF
		injecting = FALSE
		return

	if(!is_operational())
		on = FALSE
		mode = MODE_OFF
		injecting = FALSE
		update_icon()
		return

	if(!occupant)//Won't operate unless there's an occupant.
		on = FALSE
		mode = MODE_OFF
		injecting = FALSE
		update_icon()
		radio.talk_into(src, "Aborting. No occupant detected.", radio_channel)
		return

	if(injecting)
		inject_patient()

	if(!reagents) //No reagents will stop the machine from running.
		on = FALSE
		mode = MODE_OFF
		update_icon()
		radio.talk_into(src, "Aborting. No chemicals installed.", radio_channel)
		return

	var/mob/living/mob_occupant = occupant
	if(mob_occupant.on_fire) //Extinguish occupant, happens after the occupant is healed and ejected.
		mob_occupant.ExtinguishMob()
	if(!check_nap_violations())
		return

	var/datum/gas_mixture/air1 = airs[1]

	if(air1.total_moles() && mode == MODE_CRYOSLEEP)
		if(mob_occupant.bodytemperature < T0C && reagents.has_reagent(/datum/reagent/medicine/cryoxadone)) // Sleepytime. Why? More cryo magic.
			mob_occupant.Sleeping((mob_occupant.bodytemperature * sleep_factor) * 1000 * delta_time)//delta_time is roughly ~2 seconds
			mob_occupant.Unconscious((mob_occupant.bodytemperature * unconscious_factor) * 1000 * delta_time)
			if(mob_occupant.stat == UNCONSCIOUS && !mob_occupant.reagents?.has_reagent(/datum/reagent/medicine/cryoxadone, 3))
				reagents.trans_id_to(occupant, /datum/reagent/medicine/cryoxadone, 1/efficiency, multiplier = efficiency)
		else
			mode = MODE_OFF
		use_power(1000 * efficiency)

	return TRUE

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/inject_patient()
	if(!chemicals_queue || !chemicals_queue.len || !occupant)
		injecting = FALSE
		return

	for(var/reagent in chemicals_queue)
		reagents.trans_id_to(occupant, GLOB.name2reagent[lowertext(reagent)], efficiency / chemicals_queue.len, multiplier = get_total_multiplier())
		chemicals_queue[reagent] -= efficiency / chemicals_queue.len
		if(chemicals_queue[reagent] <= 0)
			chemicals_queue -= reagent

	use_power(100 * efficiency)

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/get_total_multiplier()
	if(obj_flags & EMAGGED)		//50% chance to not inject anything, but use chemical, if emagged
		if(prob(50))
			return 0
	if(!occupant)
		return 1		//No boost
	var/mob/living/mob_occupant = occupant
	if(mob_occupant?.stat != UNCONSCIOUS || mode != MODE_CRYOSLEEP)
		return 1		//No boost here either
	return 1 + (efficiency / 2)	//minimum 1.5, maximum 3.5

/obj/machinery/atmospherics/components/unary/cryo_cell/process_atmos()
	..()

	if(!on)
		return

	var/datum/gas_mixture/air1 = airs[1]

	if(!nodes[1] || !airs[1] || air1.get_moles(/datum/gas/oxygen) < 5) // Turn off if the machine won't work due to not having enough moles to operate.
		on = FALSE
		update_icon()
		var/msg = "Aborting. Not enough gas present to operate."
		radio.talk_into(src, msg, radio_channel)
		return

	if(occupant)
		var/mob/living/mob_occupant = occupant
		var/cold_protection = 0
		var/temperature_delta = air1.return_temperature() - mob_occupant.bodytemperature // The only semi-realistic thing here: share temperature between the cell and the occupant.

		if(ishuman(occupant))
			var/mob/living/carbon/human/H = occupant
			cold_protection = H.get_cold_protection(air1.return_temperature())

		if(obj_flags & EMAGGED)
			mob_occupant.apply_damage(efficiency * 0.5, BURN, forced = TRUE)

		if(abs(temperature_delta) > 1)
			var/air_heat_capacity = air1.heat_capacity()

			var/heat = ((1 - cold_protection) * 0.1 + conduction_coefficient) * temperature_delta * (air_heat_capacity * heat_capacity / (air_heat_capacity + heat_capacity))
			air1.set_temperature(max(air1.return_temperature() - heat / air_heat_capacity, TCMB))
			mob_occupant.adjust_bodytemperature(heat / heat_capacity, TCMB)

		air1.set_moles(/datum/gas/oxygen, max(0,air1.get_moles(/datum/gas/oxygen) - 0.5 / efficiency)) // Magically consume gas? Why not, we run on cryo magic.

/obj/machinery/atmospherics/components/unary/cryo_cell/power_change()
	..()
	update_icon()

/obj/machinery/atmospherics/components/unary/cryo_cell/relaymove(mob/user)
	if(message_cooldown <= world.time)
		message_cooldown = world.time + 50
		to_chat(user, "<span class='warning'>[src]'s door won't budge!</span>")

/obj/machinery/atmospherics/components/unary/cryo_cell/open_machine(drop = FALSE)
	if(!state_open && !panel_open)
		on = FALSE
	for(var/mob/M in contents) //only drop mobs
		M.forceMove(get_turf(src))
		if(isliving(M))
			var/mob/living/L = M
			L.update_mobility()
	occupant = null
	flick("pod-open-anim", src)
	..()

/obj/machinery/atmospherics/components/unary/cryo_cell/close_machine(mob/living/carbon/user)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		flick("pod-close-anim", src)
		..(user)
		return occupant

/obj/machinery/atmospherics/components/unary/cryo_cell/container_resist(mob/living/user)
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message("<span class='notice'>You see [user] kicking against the glass of [src]!</span>", \
		"<span class='notice'>You struggle inside [src], kicking the release with your foot... (this will take about [DisplayTimeText(breakout_time)].)</span>", \
		"<span class='italics'>You hear a thump from [src].</span>")
	if(do_after(user, breakout_time, target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src )
			return
		user.visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>", \
			"<span class='notice'>You successfully break out of [src]!</span>")
		open_machine()

/obj/machinery/atmospherics/components/unary/cryo_cell/examine(mob/user)
	. = ..()
	if(occupant)
		if(on)
			. += "Someone's inside [src]!"
		else
			. += "You can barely make out a form floating in [src]."
	else
		. += "[src] seems empty."

/obj/machinery/atmospherics/components/unary/cryo_cell/MouseDrop_T(mob/target, mob/user)
	if(user.incapacitated() || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !user.IsAdvancedToolUser())
		return
	if(isliving(target))
		var/mob/living/L = target
		if(L.incapacitated())
			close_machine(target)
	else
		user.visible_message("<b>[user]</b> starts shoving [target] inside [src].", "<span class='notice'>You start shoving [target] inside [src].</span>")
		if (do_after(user, 25, target=target))
			close_machine(target)

/obj/machinery/atmospherics/components/unary/cryo_cell/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/glass))
		. = 1 //no afterattack
	if(!on && !occupant && !state_open && (default_deconstruction_screwdriver(user, "pod-off", "pod-off", I)) \
		|| default_change_direction_wrench(user, I) \
		|| default_pry_open(I) \
		|| default_deconstruction_crowbar(I))
		update_icon()
		return
	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		to_chat(user, "<span class='notice'>You can't access the maintenance panel while the pod is " \
		+ (on ? "active" : (occupant ? "full" : "open")) + ".</span>")
		return
	return ..()


/obj/machinery/atmospherics/components/unary/cryo_cell/ui_state(mob/user)
	return GLOB.notcontained_state

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Cryo")
		ui.open()

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_data()
	var/list/data = list()
	data["isOperating"] = on
	data["hasOccupant"] = occupant ? TRUE : FALSE
	data["isOpen"] = state_open
	data["oxygenSupply"] = airs[1].get_moles(/datum/gas/oxygen)
	data["cryoxadoneSupply"] = round(reagents.get_reagent_amount(/datum/reagent/medicine/cryoxadone), 0.0001)
	data["currentMode"] = mode
	data["multiplier"] = get_total_multiplier()

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
			if(UNCONSCIOUS)
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
		var/occupant_reagent_list = list()
		if(mob_occupant.reagents)
			for(var/datum/reagent/R in mob_occupant.reagents.reagent_list)
				occupant_reagent_list += list(list("name" = R.name, "volume" = round(R.volume, 0.1)))
		data["occupantChemicals"] = occupant_reagent_list

	var/datum/gas_mixture/air1 = airs[1]
	data["cellTemperature"] = round(air1.return_temperature(), 1)

	var/reagent_list = list()
	var/chemicals_queue_list = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		if(istype(R, /datum/reagent/medicine/cryoxadone))
			continue
		reagent_list += list(list("name" = R.name, "volume" = round(R.volume - chemicals_queue[R.name], 0.1)))
	for(var/reagent in chemicals_queue)
		chemicals_queue_list += list(list("name" = reagent, "volume" = chemicals_queue[reagent]))
	data["reagents"] = reagent_list
	data["queue"] = chemicals_queue_list
	data["injecting"] = injecting ? 1 : 0

	return data

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("add")
			var/list/chemical = params["reagent"]
			var/amount = text2num(params["amount"])
			if(obj_flags & EMAGGED)
				if(prob(50))
					amount += rand(-10,10)
			add_to_queue(chemical, amount)
			. = TRUE
		if("remove")
			var/list/chemical = params["reagent"]
			remove_from_queue(chemical)
			. = TRUE
		if("remove_all")
			chemicals_queue.Cut()
			. = TRUE
		if("inject")
			if(occupant)
				injecting = TRUE
			. = TRUE
		if("stop_injecting")
			injecting = FALSE
			. = TRUE
		if("change_mode")
			if(mode == MODE_CRYOSLEEP)
				mode = MODE_OFF
			else
				mode = MODE_CRYOSLEEP
			. = TRUE
		if("destroy")
			for(var/chemical_name in chemicals_queue)
				reagents.remove_reagent(GLOB.name2reagent[lowertext(chemical_name)], chemicals_queue[chemical_name])
			chemicals_queue.Cut()
			. = TRUE
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

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/add_to_queue(list/chemical, amount)
	if(amount <= 0)
		return

	if(amount > chemical["volume"])
		return

	chemicals_queue[chemical["name"]] += amount

/obj/machinery/atmospherics/components/unary/cryo_cell/proc/remove_from_queue(list/chemical)
	if(!LAZYLEN(chemical))
		return

	chemicals_queue -= chemical["name"]

/obj/machinery/atmospherics/components/unary/cryo_cell/CtrlClick(mob/user)
	if(can_interact(user) && !state_open)
		on = !on
		update_icon()
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/AltClick(mob/user)
	if(can_interact(user))
		if(state_open)
			close_machine()
		else
			open_machine()
	return

/obj/machinery/atmospherics/components/unary/cryo_cell/update_remote_sight(mob/living/user)
	return // we don't see the pipe network while inside cryo.

/obj/machinery/atmospherics/components/unary/cryo_cell/get_remote_view_fullscreens(mob/user)
	user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 1)

/obj/machinery/atmospherics/components/unary/cryo_cell/can_crawl_through()
	return // can't ventcrawl in or out of cryo.

/obj/machinery/atmospherics/components/unary/cryo_cell/can_see_pipes()
	return 0 // you can't see the pipe network when inside a cryo cell.

/obj/machinery/atmospherics/components/unary/cryo_cell/return_temperature()
	var/datum/gas_mixture/G = airs[1]

	if(G.total_moles() > 10)
		return G.return_temperature()
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/default_change_direction_wrench(mob/user, obj/item/wrench/W)
	. = ..()
	if(.)
		SetInitDirections()
		var/obj/machinery/atmospherics/node = nodes[1]
		if(node)
			node.disconnect(src)
			nodes[1] = null
		nullifyPipenet(parents[1])
		atmosinit()
		node = nodes[1]
		if(node)
			node.atmosinit()
			node.addMember(src)
		SSair.add_to_rebuild_queue(src)

#undef CRYOMOBS
#undef CRYO_TX_QTY
#undef MODE_OFF
#undef MODE_CRYOSLEEP
