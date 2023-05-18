#define ATMOSBOT_MAX_AREA_SCAN 100
#define ATMOSBOT_HOLOBARRIER_COOLDOWN 150

#define ATMOSBOT_MAX_PRESSURE_CHANGE 150
#define ATMOSBOT_MAX_SCRUB_CHANGE 15

#define ATMOSBOT_CHECK_BREACH 0
#define ATMOSBOT_LOW_OXYGEN 1
#define ATMOSBOT_HIGH_TOXINS 2
#define ATMOSBOT_BAD_TEMP 3
#define ATMOSBOT_AREA_STABLE 4

#define ATMOSBOT_NOTHING 0
#define ATMOSBOT_DEPLOY_BARRIER 1
#define ATMOSBOT_VENT_AIR 2
#define ATMOSBOT_SCRUB_TOXINS 3
#define ATMOSBOT_TEMPERATURE_CONTROL 4

//Floorbot
/mob/living/simple_animal/bot/atmosbot
	name = "\improper Atmosbot"
	desc = "A little robot that just seems happy to keep you alive!"
	icon = 'icons/mob/aibots.dmi'
	icon_state = "atmosbot0"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	spacewalk = TRUE

	radio_key = /obj/item/encryptionkey/headset_eng
	radio_channel = RADIO_CHANNEL_ENGINEERING
	bot_type = FLOOR_BOT
	model = "Floorbot"
	bot_core = /obj/machinery/bot_core/floorbot
	window_id = "autofloor"
	window_name = "Automatic Station Atmospherics Restabilizer v1.1"
	path_image_color = "#FFA500"

	auto_patrol = TRUE

	var/action
	var/turf/target
	//The pressure at which the bot scans for breaches
	var/breached_pressure = 20
	//Are we adjusting the temperature of the air?
	var/temperature_control = FALSE
	var/ideal_temperature = T20C
	//Weakref of deployed barrier
	var/datum/weakref/deployed_holobarrier
	//Deployment time of last barrier
	var/last_barrier_tick
	//Gasses
	var/list/gasses = list(
		GAS_BZ = 1,
		GAS_CO2 = 1,
		GAS_HYPERNOB = 1,
		GAS_NITROUS = 1,
		GAS_NITRYL = 1,
		GAS_PLASMA = 1,
		GAS_PLUOXIUM = 0,
		GAS_STIMULUM = 0,
		GAS_TRITIUM = 1,
		GAS_H2O = 0,
	)
	//Tank type
	var/tank_type = /obj/item/tank/internals/oxygen/empty

/mob/living/simple_animal/bot/atmosbot/Initialize(mapload, new_toolbox_color)
	. = ..()
	var/datum/job/J = SSjob.GetJob(JOB_NAME_STATIONENGINEER)
	access_card.access = J.get_access()
	prev_access = access_card.access.Copy()

/mob/living/simple_animal/bot/atmosbot/turn_on()
	. = ..()
	update_icon()

/mob/living/simple_animal/bot/atmosbot/turn_off()
	. = ..()
	update_icon()

/mob/living/simple_animal/bot/atmosbot/bot_reset()
	. = ..()
	target = null
	ignore_list = list()
	update_icon()

/mob/living/simple_animal/bot/atmosbot/set_custom_texts()
	text_hack = "You corrupt [name]'s safety protocols."
	text_dehack = "You detect errors in [name] and reset his programming."
	text_dehack_fail = "[name] is not responding to reset commands!"

/mob/living/simple_animal/bot/atmosbot/on_emag(mob/user)
	. = ..()
	if(emagged == 2)
		audible_message("<span class='danger'>[src] whirs ominously.</span>")
		playsound(src, "sparks", 75, TRUE)

/mob/living/simple_animal/bot/atmosbot/handle_automated_action()
	if(!..())
		return

	if(prob(5))
		audible_message("[src] makes an excited whirring sound!")

	action = ATMOSBOT_NOTHING
	if(!isspaceturf(get_turf(src)))
		switch(check_area_atmos())
			if(ATMOSBOT_CHECK_BREACH)
				if(last_barrier_tick + ATMOSBOT_HOLOBARRIER_COOLDOWN < world.time)
					target = return_nearest_breach()
					action = ATMOSBOT_DEPLOY_BARRIER
					if(!target)
						target = get_vent_turf()
						action = ATMOSBOT_VENT_AIR
				else
					target = get_vent_turf()
					action = ATMOSBOT_VENT_AIR
			if(ATMOSBOT_LOW_OXYGEN)
				target = get_vent_turf()
				action = ATMOSBOT_VENT_AIR
			if(ATMOSBOT_HIGH_TOXINS)
				target = get_vent_turf()
				action = ATMOSBOT_SCRUB_TOXINS
			if(ATMOSBOT_BAD_TEMP)
				target = get_vent_turf()
				action = ATMOSBOT_TEMPERATURE_CONTROL
			if(ATMOSBOT_AREA_STABLE)
				if(emagged == 2)
					if(prob(20))
						target = get_vent_turf()
						action = ATMOSBOT_VENT_AIR
	update_icon()

	if(!target)
		if(auto_patrol)
			if(mode == BOT_IDLE || mode == BOT_START_PATROL)
				start_patrol()

			if(mode == BOT_PATROL)
				bot_patrol()

	if(target)
		if(loc == get_turf(target))
			if(check_bot(target))
				if(prob(50))
					target = null
					path = list()
					return
			//Do actions here
			switch(action)
				if(ATMOSBOT_DEPLOY_BARRIER)
					deploy_holobarrier()
					target = get_vent_turf()
				if(ATMOSBOT_VENT_AIR)
					vent_air()
				if(ATMOSBOT_SCRUB_TOXINS)
					scrub_toxins()
				if(ATMOSBOT_TEMPERATURE_CONTROL)
					change_temperature()
			return

		if(!LAZYLEN(path))
			var/turf/target_turf = get_turf(target)
			path = get_path_to(src, target_turf, 30, id=access_card, simulated_only = FALSE)

			if(!bot_move(target))
				add_to_ignore(target)
				target = null
				mode = BOT_IDLE
				return

		else if(!bot_move(target))
			target = null
			mode = BOT_IDLE
			return

/mob/living/simple_animal/bot/atmosbot/proc/change_temperature()
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment = T.return_air()
	environment.set_temperature(ideal_temperature)

/mob/living/simple_animal/bot/atmosbot/proc/vent_air()
	//Just start pumping out air
	var/turf/T = get_turf(src)

	var/datum/gas_mixture/environment = T.return_air()
	var/environment_pressure = environment.return_pressure()

	var/pressure_delta = min(ATMOSBOT_MAX_PRESSURE_CHANGE, (ONE_ATMOSPHERE - environment_pressure))

	if(pressure_delta > 0)
		var/transfer_moles = pressure_delta*environment.return_volume()/(T20C * R_IDEAL_GAS_EQUATION)
		if(emagged == 2)
			environment.adjust_moles(GAS_CO2, transfer_moles)
		else
			environment.adjust_moles(GAS_N2, transfer_moles * 0.7885)
			environment.adjust_moles(GAS_O2, transfer_moles * 0.2115)
		air_update_turf()
		new /obj/effect/temp_visual/vent_wind(get_turf(src))

/mob/living/simple_animal/bot/atmosbot/proc/scrub_toxins()
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment = T.return_air()
	for(var/G in gasses)
		if(gasses[G])
			var/moles_in_atmos = environment.get_moles(G)
			environment.adjust_moles(G, -min(moles_in_atmos, ATMOSBOT_MAX_SCRUB_CHANGE))

/mob/living/simple_animal/bot/atmosbot/proc/deploy_holobarrier()
	if(deployed_holobarrier)
		qdel(deployed_holobarrier.resolve())
	deployed_holobarrier = WEAKREF(new /obj/structure/holosign/barrier/atmos(get_turf(src)))
	last_barrier_tick = world.time

//Analyse the atmosphere to see if there is a potential breach nearby
/mob/living/simple_animal/bot/atmosbot/proc/check_area_atmos()
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/gas_mix = T.return_air()
	if(gas_mix.return_pressure() < breached_pressure)
		return ATMOSBOT_CHECK_BREACH
	//Toxins in the air
	if(emagged != 2)
		for(var/G in gasses)
			if(gasses[G] && gas_mix.get_moles(G) > 0.2)
				return ATMOSBOT_HIGH_TOXINS
	//Too little oxygen or too little pressure
	var/partial_pressure = R_IDEAL_GAS_EQUATION * gas_mix.return_temperature() / gas_mix.return_volume()
	var/oxygen_moles = gas_mix.get_moles(GAS_O2) * partial_pressure
	if(oxygen_moles < 20 || gas_mix.return_pressure() < WARNING_LOW_PRESSURE)
		return ATMOSBOT_LOW_OXYGEN
	//Check temperature
	if(temperature_control && (gas_mix.return_temperature() > ideal_temperature + 0.5 || gas_mix.return_temperature() < ideal_temperature - 0.5))
		return ATMOSBOT_BAD_TEMP
	return ATMOSBOT_AREA_STABLE

/mob/living/simple_animal/bot/atmosbot/proc/get_vent_turf()
	var/turf/target_turf = get_turf(src)
	var/blocked = FALSE
	for(var/obj/structure/holosign/barrier/atmos/A in target_turf)
		blocked = TRUE
		break
	if(!target_turf.CanAtmosPass(target_turf) || blocked)
		//Pressumable from being inside a holobarrier, move somewhere nearby
		var/turf/open/floor/floor_turf = pick(view(3, src))
		if(floor_turf && istype(floor_turf))
			target_turf = floor_turf
	return target_turf

//Returns the closest turf that needs a holoprojection set up
/mob/living/simple_animal/bot/atmosbot/proc/return_nearest_breach()
	var/turf/origin = get_turf(src)

	if(isclosedturf(origin))
		return null

	var/room_limit = ATMOSBOT_MAX_AREA_SCAN
	var/list/checked_turfs = list()
	var/list/to_check_turfs = list(origin)
	while(room_limit > 0 && LAZYLEN(to_check_turfs))
		room_limit --
		var/turf/checking_turf = to_check_turfs[1]
		//We have checked this turf
		checked_turfs += checking_turf
		to_check_turfs -= checking_turf
		var/blocked = FALSE
		for(var/obj/structure/holosign/barrier/atmos/A in checking_turf)
			blocked = TRUE
			break
		if(blocked || !checking_turf.CanAtmosPass(checking_turf))
			continue
		//Add adjacent turfs
		for(var/direction in list(NORTH, SOUTH, EAST, WEST))
			var/turf/adjacent_turf = get_step(checking_turf, direction)
			if(adjacent_turf in checked_turfs || !adjacent_turf.CanAtmosPass(adjacent_turf) || istype(adjacent_turf.loc, /area/space))
				continue
			if(isspaceturf(adjacent_turf))
				return checking_turf
			to_check_turfs |= adjacent_turf
	return null

/mob/living/simple_animal/bot/atmosbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += "<tt><b>Atmospheric Stabilizer Controls v1.1</b></tt><br><br>"
	dat += "Status: <a href='?src=[REF(src)];power=1'>[on ? "On" : "Off"]</a><br>"
	dat += "Maintenance panel panel is [open ? "opened" : "closed"]<br>"
	if(!locked || issilicon(user) || IsAdminGhost(user))
		dat += "Breach Pressure: <a href='?src=[REF(src)];set_breach_pressure=1'>[breached_pressure]</a><br>"
		dat += "Temperature Control: <a href='?src=[REF(src)];toggle_temp_control=1'>[temperature_control?"Enabled":"Disabled"]</a><br>"
		dat += "Temperature Target: <a href='?src=[REF(src)];set_ideal_temperature=[ideal_temperature]'>[ideal_temperature]C</a><br>"
		dat += "Gas Scrubbing Controls<br>"
		for(var/gas_id in gasses)
			var/gas_enabled = gasses[gas_id]
			dat += "[GLOB.gas_data.names[gas_id]]: <a href='?src=[REF(src)];toggle_gas=[gas_id]'>[gas_enabled?"Scrubbing":"Not Scrubbing"]</a><br>"
		dat += "Patrol Station: <A href='?src=[REF(src)];operation=patrol'>[auto_patrol ? "Yes" : "No"]</A><BR>"
	return dat

/mob/living/simple_animal/bot/atmosbot/Topic(href, href_list)
	if(..())
		return TRUE

	if(href_list["set_breach_pressure"])
		var/new_breach_pressure = input(usr, "Pressure to scan for breaches at? (0 to 100)", "Breach Pressure") as num
		if(!isnum(new_breach_pressure) || new_breach_pressure < 0 || new_breach_pressure > 100)
			return
		breached_pressure = new_breach_pressure
	else if(href_list["toggle_temp_control"])
		temperature_control = temperature_control ? FALSE : TRUE
	else if(href_list["toggle_gas"])
		var/gas_id = href_list["toggle_gas"]
		for(var/G in gasses)
			if("[G]" == gas_id)
				gasses[G] = gasses[G] ? FALSE : TRUE
	else if(href_list["set_ideal_temperature"])
		var/new_temp = input(usr, "Set Target Temperature ([T0C] to [T20C + 20])", "Target Temperature") as num
		if(!isnum(new_temp) || new_temp < T0C || new_temp > T20C + 20)
			return
		ideal_temperature = new_temp

	update_controls()
	update_icon()

/mob/living/simple_animal/bot/atmosbot/update_icon()
	if(action == ATMOSBOT_VENT_AIR && emagged == 2)
		icon_state = "atmosbot[on][on?"_5":""]"
		return
	icon_state = "atmosbot[on][on?"_[action]":""]"

/mob/living/simple_animal/bot/atmosbot/UnarmedAttack(atom/A, proximity)
	if(isturf(A) && A == get_turf(src))
		return deploy_holobarrier()
	return ..()

/mob/living/simple_animal/bot/atmosbot/explode()
	on = FALSE
	visible_message("<span class='boldannounce'>[src] blows apart!</span>")

	var/atom/Tsec = drop_location()

	new /obj/item/assembly/prox_sensor(Tsec)
	new /obj/item/analyzer(Tsec)
	var/obj/item/tank/tank = new tank_type(Tsec)
	var/datum/gas_mixture/GM = Tsec.return_air()
	if(tank && GM)
		GM.merge(tank.air_contents)
		new /obj/effect/temp_visual/vent_wind(Tsec)
	if(deployed_holobarrier)
		qdel(deployed_holobarrier.resolve())

	if(prob(50))
		drop_part(robot_arm, Tsec)

	do_sparks(3, TRUE, src)
	..()
