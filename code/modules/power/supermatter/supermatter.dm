//Ported from /vg/station13, which was in turn forked from baystation12;
//Please do not bother them with bugs from this port, however, as it has been modified quite a bit.
//Modifications include removing the world-ending full supermatter variation, and leaving only the shard.

GLOBAL_DATUM(main_supermatter_engine, /obj/machinery/power/supermatter_crystal)

/obj/machinery/power/supermatter_crystal
	name = "supermatter crystal"
	desc = "A strangely translucent and iridescent crystal."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "darkmatter"
	base_icon_state = "darkmatter"
	layer = ABOVE_MOB_LAYER
	density = TRUE
	anchored = TRUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	light_range = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	critical_machine = TRUE

	///The id of our supermatter
	var/unique_id = 1
	///The amount of supermatters that have been created this round
	var/static/gl_uid = 1
	/*
	///Tracks the bolt color we are using
	var/zap_icon = DEFAULT_ZAP_ICON_STATE
	*/
	///The portion of the gasmix we're on that we should remove
	var/gas_efficency = 0.15
	///Are we exploding?
	var/final_countdown = FALSE

	var/damage = 0
	var/damage_archived = 0
	var/safe_alert = "Crystalline hyperstructure returning to safe operating parameters."
	var/warning_point = 50
	///The alert we send when we've reached warning_point
	var/warning_alert = "Danger! Crystal hyperstructure integrity faltering!"
	///The point at which we start sending messages to the common channel
	var/emergency_point = 700
	///The alert we send when we've reached emergency_point
	var/emergency_alert = "CRYSTAL DELAMINATION IMMINENT."
	///The point at which we delam
	var/explosion_point = 900
	///When we pass this amount of damage we start shooting bolts
	var/damage_penalty_point = 550

	///A scaling value that affects the severity of explosions.
	var/explosion_power = 35
	///Time in 1/10th of seconds since the last sent warning
	var/last_warning = 0
	///Refered to as eer on the monitor. This value effects gas output, heat, damage, and radiation.
	var/power = 0
	///Determines the rate of positive change in gas comp values
	var/gas_change_rate = 0.05
	var/list/gas_comp = list()

	///The last air sample's total molar count, will always be above or equal to 0
	var/combined_gas = 0
	///Affects the power gain the sm experiences from heat
	var/gasmix_power_ratio = 0
	///Affects the amount of damage and minimum point at which the sm takes heat damage
	var/dynamic_heat_resistance = 1
	///Uses powerloss_dynamic_scaling and combined_gas to lessen the effects of our powerloss functions
	var/powerloss_inhibitor = 1
	//Based on co2 percentage, slowly moves between 0 and 1. We use it to calc the powerloss_inhibitor
	var/powerloss_dynamic_scaling= 0
	///Used to increase or lessen the amount of damage the sm takes from heat based on molar counts.
	var/mole_heat_penalty = 0
	///Takes the energy throwing things into the sm generates and slowly turns it into actual power
	var/matter_power = 0
	/*
	///The cutoff for a bolt jumping, grows with heat, lowers with higher mol count,
	var/zap_cutoff = 1500
	*/
	///How much the bullets damage should be multiplied by when it is added to the internal variables
	var/bullet_energy = 2
	///How much hallucination should we produce per unit of power?
	var/hallucination_power = 0.1

	var/last_rads = 0

	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/headset_eng
	var/engineering_channel = "Engineering"
	var/common_channel = null

	//for logging
	var/has_been_powered = FALSE
	var/has_reached_emergency = FALSE

	///An effect we show to admins and ghosts the percentage of delam we're at
	var/obj/effect/countdown/supermatter/countdown

	var/is_main_engine = FALSE

	var/datum/looping_sound/supermatter/soundloop

	///Can it be moved?
	var/moveable = FALSE

	/// cooldown tracker for accent sounds,
	var/last_accent_sound = 0

	//For making hugbox supermatters
	///Disables all methods of taking damage
	var/takes_damage = TRUE
	///Disables the production of gas, and pretty much any handling of it we do.
	var/produces_gas = TRUE
	///Disables power changes
	var/power_changes = TRUE
	///Disables the sm's proccessing totally.
	var/processes = TRUE
	///Timer id for the disengage_field proc timer
	var/disengage_field_timer = null

	///Can the crystal trigger the station wide anomaly spawn?
	var/anomaly_event = TRUE

/obj/machinery/power/supermatter_crystal/Initialize()
	. = ..()
	SSair.atmos_air_machinery += src
	countdown = new(src)
	countdown.start()
	GLOB.poi_list |= src
	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = 0
	radio.recalculateChannels()
	investigate_log("has been created.", INVESTIGATE_ENGINES)
	if(is_main_engine)
		GLOB.main_supermatter_engine = src

	AddElement(/datum/element/bsa_blocker)
	RegisterSignal(src, COMSIG_ATOM_BSA_BEAM, PROC_REF(call_delamination_event))

	soundloop = new(src, TRUE)

/obj/machinery/power/supermatter_crystal/Destroy()
	investigate_log("has been destroyed.", INVESTIGATE_ENGINES)
	SSair.atmos_air_machinery -= src
	QDEL_NULL(radio)
	GLOB.poi_list -= src
	QDEL_NULL(countdown)
	if(is_main_engine && GLOB.main_supermatter_engine == src)
		GLOB.main_supermatter_engine = null
	return ..()

/obj/machinery/power/supermatter_crystal/examine(mob/user)
	. = ..()
	var/immune = HAS_TRAIT(user, TRAIT_MADNESS_IMMUNE) || HAS_TRAIT(user.mind, TRAIT_MADNESS_IMMUNE)
	if (!isliving(user) && !immune && (get_dist(user, src) < HALLUCINATION_RANGE(power)))
		. += "<span class='danger'>You get headaches just from looking at it.</span>"

// SupermatterMonitor UI for ghosts only. Inherited attack_ghost will call this.
/obj/machinery/power/supermatter_crystal/ui_interact(mob/user, datum/tgui/ui)
	if(!isobserver(user))
		return FALSE
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "SupermatterMonitor")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/power/supermatter_crystal/ui_data(mob/user)
	var/list/data = list()
	var/turf/local_turf = get_turf(src)
	var/datum/gas_mixture/air = local_turf.return_air()
	// standalone_mode hides the "Back" button.
	data["standalone_mode"] = TRUE
	data["active"] = TRUE
	data["SM_integrity"] = get_integrity()
	data["SM_power"] = power
	data["SM_radiation"] = last_rads
	data["SM_ambienttemp"] = air.return_temperature()
	data["SM_ambientpressure"] = air.return_pressure()
	data["SM_bad_moles_amount"] = MOLE_PENALTY_THRESHOLD / gas_efficency
	data["SM_moles"] = 0
	data["SM_uid"] = unique_id
	var/list/gasdata = list()
	if(air.total_moles())
		data["SM_moles"] = air.total_moles()
		for(var/gas_ID in air.get_gases())
			gasdata.Add(list(list(
			"name"= GLOB.gas_data.names[gas_ID],
			"amount" = round(100*air.get_moles(gas_ID)/air.total_moles(),0.01))))
	else
		for(var/gas_ID in air.get_gases())
			gasdata.Add(list(list(
				"name"= GLOB.gas_data.names[gas_ID],
				"amount" = 0)))
	data["gases"] = gasdata
	return data

/obj/machinery/power/supermatter_crystal/proc/get_status()
	var/turf/source_turf = get_turf(src)
	if(!source_turf)
		return SUPERMATTER_ERROR
	var/datum/gas_mixture/air = source_turf.return_air()
	if(!air)
		return SUPERMATTER_ERROR

	var/integrity = get_integrity()
	if(integrity < SUPERMATTER_DELAM_PERCENT)
		return SUPERMATTER_DELAMINATING

	if(integrity < SUPERMATTER_EMERGENCY_PERCENT)
		return SUPERMATTER_EMERGENCY

	if(integrity < SUPERMATTER_DANGER_PERCENT)
		return SUPERMATTER_DANGER

	if((integrity < SUPERMATTER_WARNING_PERCENT) || (air.return_temperature() > CRITICAL_TEMPERATURE))
		return SUPERMATTER_WARNING

	if(air.return_temperature() > (CRITICAL_TEMPERATURE * 0.8))
		return SUPERMATTER_NOTIFY

	if(power > 5)
		return SUPERMATTER_NORMAL
	return SUPERMATTER_INACTIVE

/obj/machinery/power/supermatter_crystal/proc/alarm()
	switch(get_status())
		if(SUPERMATTER_DELAMINATING)
			playsound(src, 'sound/misc/bloblarm.ogg', 100, FALSE, 40, 30, falloff_distance = 10)
		if(SUPERMATTER_EMERGENCY)
			playsound(src, 'sound/machines/engine_alert1.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(SUPERMATTER_DANGER)
			playsound(src, 'sound/machines/engine_alert2.ogg', 100, FALSE, 30, 30, falloff_distance = 10)
		if(SUPERMATTER_WARNING)
			playsound(src, 'sound/machines/terminal_alert.ogg', 75)

/obj/machinery/power/supermatter_crystal/proc/get_integrity()
	var/integrity = damage / explosion_point
	integrity = round(100 - integrity * 100, 0.01)
	integrity = integrity < 0 ? 0 : integrity
	return integrity

/obj/machinery/power/supermatter_crystal/update_overlays()
	. = ..()
	if(final_countdown)
		. += "casuality_field"

/obj/machinery/power/supermatter_crystal/proc/countdown()
	set waitfor = FALSE

	if(final_countdown) // We're already doing it go away
		return
	final_countdown = TRUE
	update_icon()

	var/speaking = "[emergency_alert] The supermatter has reached critical integrity failure. Emergency causality destabilization field has been activated."
	radio.talk_into(src, speaking, common_channel, language = get_selected_language())
	for(var/i in SUPERMATTER_COUNTDOWN_TIME to 0 step -10)
		if(damage < explosion_point) // Cutting it a bit close there engineers
			radio.talk_into(src, "[safe_alert] Failsafe has been disengaged.", common_channel)
			update_icon()
			final_countdown = FALSE
			return
		else if((i % 50) != 0 && i > 50) // A message once every 5 seconds until the final 5 seconds which count down individualy
			sleep(10)
			continue
		else if(i > 50)
			speaking = "[DisplayTimeText(i, TRUE)] remain before causality stabilization."
		else
			speaking = "[i*0.1]..."
		radio.talk_into(src, speaking, common_channel, list(SPAN_COMMAND)) // IT GOT WORSE, LOUD TIME
		sleep(10)

	delamination_event()

/obj/machinery/power/supermatter_crystal/proc/delamination_event()
	var/can_spawn_anomalies = is_station_level(loc.z) && is_main_engine && anomaly_event
	new /datum/supermatter_delamination(power, combined_gas, get_turf(src), explosion_power, gasmix_power_ratio, can_spawn_anomalies)

	if(combined_gas > MOLE_PENALTY_THRESHOLD) // kept as /datum does not inherit /investigate_log()
		investigate_log("has collapsed into a singularity.", INVESTIGATE_ENGINES)
	else if(power > POWER_PENALTY_THRESHOLD)
		investigate_log("has spawned additional energy balls.", INVESTIGATE_ENGINES)

	qdel(src)

//this is here to eat arguments
/obj/machinery/power/supermatter_crystal/proc/call_delamination_event()
	delamination_event()

/obj/machinery/power/supermatter_crystal/process_atmos()
	if(!processes) //Just fuck me up bro
		return
	var/turf/source_turf = loc

	if(isnull(source_turf)) // We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!istype(source_turf)) //We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.

	if(isclosedturf(source_turf))
		var/turf/did_it_melt = source_turf.Melt()
		if(!isclosedturf(did_it_melt)) //In case some joker finds way to place these on indestructible walls
			visible_message("<span class='warning'>[src] melts through [source_turf]!</span>")
		return

	//We vary volume by power, and handle OH FUCK FUSION IN COOLING LOOP noises.
	if(power)
		soundloop.volume = clamp((50 + (power / 50)), 50, 100)
	if(damage >= 300)
		soundloop.mid_sounds = list('sound/machines/sm/loops/delamming.ogg' = 1)
	else
		soundloop.mid_sounds = list('sound/machines/sm/loops/calm.ogg' = 1)

	//We play delam/neutral sounds at a rate determined by power and damage
	if(last_accent_sound < world.time && prob(20))
		var/aggression = min(((damage / 800) * (power / 2500)), 1.0) * 100
		if(damage >= 300)
			playsound(src, "smdelam", max(50, aggression), FALSE, 10)
		else
			playsound(src, "smcalm", max(50, aggression), FALSE, 10)
		var/next_sound = round((100 - aggression) * 5)
		last_accent_sound = world.time + max(SUPERMATTER_ACCENT_SOUND_MIN_COOLDOWN, next_sound)

	//Ok, get the air from the turf
	var/datum/gas_mixture/env = source_turf.return_air()

	var/datum/gas_mixture/removed
	if(produces_gas)
		//Remove gas from surrounding area
		removed = env.remove_ratio(gas_efficency)
	else
		// Pass all the gas related code an empty gas container
		removed = new()
	damage_archived = damage

	var/list/gas_info = GLOB.gas_data.supermatter

	var/list/gases_we_care_about = gas_info[ALL_SUPERMATTER_GASES]

	/********
	EXPERIMENTAL, HUGBOXY AS HELL CITADEL CHANGES: Even in a vaccum, update gas composition and modifiers.
	This means that the SM will usually have a very small explosion if it ends up being breached to space,
	and CO2 tesla delaminations basically require multiple grounding rods to stabilize it long enough to not have it vent.
	*********/

	if(!removed || !removed.total_moles() || isspaceturf(source_turf)) //we're in space or there is no gas to process
		if(takes_damage)
			damage += max((power / 1000) * DAMAGE_INCREASE_MULTIPLIER, 0.1) // always does at least some damage
		combined_gas = max(0, combined_gas - 0.5) // Slowly wear off.
		for(var/gas_ID in gas_comp)
			gas_comp[gas_ID] = max(0, gas_comp[gas_ID] - 0.05) //slowly ramp down
	else
		if(takes_damage)
			//causing damage
			//Due to DAMAGE_INCREASE_MULTIPLIER, we only deal one 4th of the damage the statements otherwise would cause

			//((((some value between 0.5 and 1 * temp - ((273.15 + 40) * some values between 1 and 10)) * some number between 0.25 and knock your socks off / 150) * 0.25
			//Heat and mols account for each other, a lot of hot mols are more damaging then a few
			//Mols start to have a positive effect on damage after 350
			damage = max(damage + (max(clamp(removed.total_moles() / 200, 0.5, 1) * removed.return_temperature() - ((T0C + HEAT_PENALTY_THRESHOLD)*dynamic_heat_resistance), 0) * mole_heat_penalty / 150 ) * DAMAGE_INCREASE_MULTIPLIER, 0)
			//Power only starts affecting damage when it is above 5000
			damage = max(damage + (max(power - POWER_PENALTY_THRESHOLD, 0)/500) * DAMAGE_INCREASE_MULTIPLIER, 0)
			//Molar count only starts affecting damage when it is above 1800
			damage = max(damage + (max(combined_gas - MOLE_PENALTY_THRESHOLD, 0)/80) * DAMAGE_INCREASE_MULTIPLIER, 0)

			//There might be a way to integrate healing and hurting via heat
			//healing damage
			if(combined_gas < MOLE_PENALTY_THRESHOLD)
				//Only has a net positive effect when the temp is below 313.15, heals up to 2 damage. Psycologists increase this temp min by up to 45
				damage = max(damage + (min(removed.return_temperature() - (T0C + HEAT_PENALTY_THRESHOLD), 0) / 150), 0)

			//caps damage rate

			//Takes the lower number between archived damage + (1.8) and damage
			//This means we can only deal 1.8 damage per function call
			damage = min(damage_archived + (DAMAGE_HARDCAP * explosion_point), damage)

			//calculating gas related values
			//Wanna know a secret? See that max() to zero? it's used for error checking. If we get a mol count in the negative, we'll get a divide by zero error
			combined_gas = max(removed.total_moles(), 0)

			//This is more error prevention, according to all known laws of atmos, gas_mix.remove() should never make negative mol values.
			//But this is tg

			//Lets get the proportions of the gasses in the mix and then slowly move our comp to that value
			//Can cause an overestimation of mol count, should stabalize things though.
			//Prevents huge bursts of gas/heat when a large amount of something is introduced
			//They range between 0 and 1
			for(var/gas_ID in gases_we_care_about)
				if(!(gas_ID in gas_comp))
					gas_comp[gas_ID] = 0
				gas_comp[gas_ID] += clamp(max(removed.get_moles(gas_ID)/combined_gas, 0) - gas_comp[gas_ID], -1, gas_change_rate)

	var/list/threshold_mod = gases_we_care_about.Copy()

	var/list/powermix = gas_info[POWER_MIX]
	var/list/heat = gas_info[HEAT_PENALTY]
	var/list/transmit = gas_info[TRANSMIT_MODIFIER]
	var/list/resist = gas_info[HEAT_RESISTANCE]
	var/list/radioactivity = gas_info[RADIOACTIVITY_MODIFIER]
	var/list/inhibition = gas_info[POWERLOSS_INHIBITION]

	//We're concerned about pluoxium being too easy to abuse at low percents, so we make sure there's a substantial amount.
	var/pluoxiumbonus = (gas_comp[GAS_PLUOXIUM] >= 0.15) //makes pluoxium only work at 15%+
	var/h2obonus = 1 - (gas_comp[GAS_H2O] * 0.25)//At min this value should be 0.75
//		var/freonbonus = (gas_comp[/datum/gas/freon] <= 0.03) //Let's just yeet power output if this shit is high

	threshold_mod[GAS_PLUOXIUM] = pluoxiumbonus

	//No less then zero, and no greater then one, we use this to do explosions and heat to power transfer
	//Be very careful with modifing this var by large amounts, and for the love of god do not push it past 1
	gasmix_power_ratio = 0
	//Affects the amount of o2 and plasma the sm outputs, along with the heat it makes.
	var/dynamic_heat_modifier = 0
	//Effects the damage heat does to the crystal.
	dynamic_heat_resistance = 0
	//We multiply this with power to find the rads.
	var/power_transmission_bonus = 0
	var/powerloss_inhibition_gas = 0
	var/radioactivity_modifier = 0
	for(var/gas_ID in gas_comp)
		var/this_comp = gas_comp[gas_ID] * (isnull(threshold_mod[gas_ID] ? 1 : threshold_mod[gas_ID]))
		gasmix_power_ratio += this_comp * powermix[gas_ID]
		dynamic_heat_modifier += this_comp * heat[gas_ID]
		dynamic_heat_resistance += this_comp * resist[gas_ID]
		power_transmission_bonus += this_comp * transmit[gas_ID]
		powerloss_inhibition_gas += this_comp * inhibition[gas_ID]
		radioactivity_modifier += this_comp * radioactivity[gas_ID]
	dynamic_heat_modifier *= h2obonus
	power_transmission_bonus *= h2obonus
	gasmix_power_ratio = clamp(gasmix_power_ratio, 0, 1)
	dynamic_heat_modifier = max(dynamic_heat_modifier, 0.5)

	//more moles of gases are harder to heat than fewer, so let's scale heat damage around them
	mole_heat_penalty = max(combined_gas / MOLE_HEAT_PENALTY, 0.25)

	//Ramps up or down in increments of 0.02 up to the proportion of co2
	//Given infinite time, powerloss_dynamic_scaling = co2comp
	//Some value between 0 and 1
	if (combined_gas > POWERLOSS_INHIBITION_MOLE_THRESHOLD && powerloss_inhibition_gas > POWERLOSS_INHIBITION_GAS_THRESHOLD) //If there are more then 20 mols, and more then 20% co2
		powerloss_dynamic_scaling = clamp(powerloss_dynamic_scaling + clamp(powerloss_inhibition_gas - powerloss_dynamic_scaling, -0.02, 0.02), 0, 1)
	else
		powerloss_dynamic_scaling = clamp(powerloss_dynamic_scaling - 0.05, 0, 1)
	//Ranges from 0 to 1(1-(value between 0 and 1 * ranges from 1 to 1.5(mol / 500)))
	//We take the mol count, and scale it to be our inhibitor
	powerloss_inhibitor = clamp(1-(powerloss_dynamic_scaling * clamp(combined_gas/POWERLOSS_INHIBITION_MOLE_BOOST_THRESHOLD, 1, 1.5)), 0, 1)

	//Releases stored power into the general pool
	//We get this by consuming shit or being scalpeled
	if(matter_power && power_changes)
		//We base our removed power off one 10th of the matter_power.
		var/removed_matter = max(matter_power/MATTER_POWER_CONVERSION, 40)
		//Adds at least 40 power
		power = max(power + removed_matter, 0)
		//Removes at least 40 matter power
		matter_power = max(matter_power - removed_matter, 0)

	var/temp_factor = 50
	if(gasmix_power_ratio > 0.8)
		//with a perfect gas mix, make the power more based on heat
		icon_state = "[base_icon_state]_glow"
	else
		//in normal mode, power is less effected by heat
		temp_factor = 30
		icon_state = base_icon_state

	//if there is more pluox and n2 then anything else, we receive no power increase from heat
	if(power_changes)
		power = max((removed.return_temperature() * temp_factor / T0C) * gasmix_power_ratio + power, 0)

	if(prob(50))
		//(1 + (tritRad + pluoxDampen * bzDampen * o2Rad * plasmaRad / (10 - bzrads))) * freonbonus
		radiation_pulse(src, power * max(0, (1 + (power_transmission_bonus/(10-radioactivity_modifier)))))//freonbonus))// RadModBZ(500%)
	if(radioactivity_modifier >= 2 && prob(6 * radioactivity_modifier))
		src.fire_nuclear_particle()

	//Power * 0.55 * a value between 1 and 0.8
	var/device_energy = power * REACTION_POWER_MODIFIER

	removed.set_temperature(removed.return_temperature() + ((device_energy * dynamic_heat_modifier) / THERMAL_RELEASE_MODIFIER))
	//We don't want our output to be too hot
	removed.set_temperature(max(0, min(removed.return_temperature(), 2500 * dynamic_heat_modifier)))

	//Calculate how much gas to release
	//Varies based on power and gas content
	removed.adjust_moles(GAS_PLASMA, max((device_energy * dynamic_heat_modifier) / PLASMA_RELEASE_MODIFIER, 0))
	//Varies based on power, gas content, and heat
	removed.adjust_moles(GAS_O2, max(((device_energy + removed.return_temperature() * dynamic_heat_modifier) - T0C) / OXYGEN_RELEASE_MODIFIER, 0))

	if(produces_gas)
		env.merge(removed)
		air_update_turf()

		/*********
		END CITADEL CHANGES
		*********/

	//Makes em go mad and accumulate rads.
	for(var/mob/living/carbon/human/l in viewers(HALLUCINATION_RANGE(power), src)) // If they can see it without mesons on.  Bad on them.
		if(!HAS_TRAIT(l.mind, TRAIT_MADNESS_IMMUNE) && !HAS_TRAIT(l, TRAIT_MADNESS_IMMUNE))
			var/D = sqrt(1 / max(1, get_dist(l, src)))
			l.hallucination += power * hallucination_power * D
			l.hallucination = clamp(l.hallucination, 0, 200)
	for(var/mob/living/l in range(src, round((power / 100) ** 0.25)))

	//Transitions between one function and another, one we use for the fast inital startup, the other is used to prevent errors with fusion temperatures.
	//Use of the second function improves the power gain imparted by using co2
	if(power_changes)
		power =  max(power - min(((power/500)**3) * powerloss_inhibitor, power * 0.83 * powerloss_inhibitor),1)
	if(power > POWER_PENALTY_THRESHOLD || damage > damage_penalty_point)

		if(power > POWER_PENALTY_THRESHOLD)
			playsound(src.loc, 'sound/weapons/emitter2.ogg', 100, 1, extrarange = 10)
			supermatter_zap(src, 5, min(power*2, 20000))
			supermatter_zap(src, 5, min(power*2, 20000))
			if(power > SEVERE_POWER_PENALTY_THRESHOLD)
				supermatter_zap(src, 5, min(power*2, 20000))
				if(power > CRITICAL_POWER_PENALTY_THRESHOLD)
					supermatter_zap(src, 5, min(power*2, 20000))
		else if (damage > damage_penalty_point && prob(20))
			playsound(src.loc, 'sound/weapons/emitter2.ogg', 100, 1, extrarange = 10)
			supermatter_zap(src, 5, CLAMP(power*2, 4000, 20000))

		if(prob(5))
			supermatter_anomaly_gen(src, ANOMALY_FLUX, rand(5, 10))
		if(prob(5))
			supermatter_anomaly_gen(src, ANOMALY_HALLUCINATION, rand(5, 10))
		if(power > SEVERE_POWER_PENALTY_THRESHOLD && prob(5) || prob(1))
			supermatter_anomaly_gen(src, ANOMALY_GRAVITATIONAL, rand(5, 10))
		if((power > SEVERE_POWER_PENALTY_THRESHOLD && prob(2)) || (prob(0.3) && power > POWER_PENALTY_THRESHOLD))
			supermatter_anomaly_gen(src, ANOMALY_PYRO, rand(5, 10))

	if(prob(15) && power > POWER_PENALTY_THRESHOLD)
		supermatter_pull(loc, min(power/850, 3))//850, 1700, 2550

	//Tells the engi team to get their butt in gear
	if(damage > warning_point) // while the core is still damaged and it's still worth noting its status
		if(damage_archived < warning_point) //If damage_archive is under the warning point, this is the very first cycle that we've reached said point.
			SEND_SIGNAL(src, COMSIG_SUPERMATTER_DELAM_START_ALARM)
		if((REALTIMEOFDAY - last_warning) / 10 >= WARNING_DELAY)
			alarm()

			//Oh shit it's bad, time to freak out
			if(damage > emergency_point)
				// it's bad, LETS YELL
				radio.talk_into(src, "[emergency_alert] Integrity: [get_integrity()]%", common_channel, list(SPAN_YELL))
				SEND_SIGNAL(src, COMSIG_SUPERMATTER_DELAM_ALARM)
				last_warning = REALTIMEOFDAY
				if(!has_reached_emergency)
					investigate_log("has reached the emergency point for the first time.", INVESTIGATE_ENGINES)
					message_admins("[src] has reached the emergency point [ADMIN_JMP(src)].")
					has_reached_emergency = TRUE
			else if(damage >= damage_archived) // The damage is still going up
				radio.talk_into(src, "[warning_alert] Integrity: [get_integrity()]%", engineering_channel)
				SEND_SIGNAL(src, COMSIG_SUPERMATTER_DELAM_ALARM)
				last_warning = REALTIMEOFDAY - (WARNING_DELAY * 5)

			else                                                 // Phew, we're safe
				radio.talk_into(src, "[safe_alert] Integrity: [get_integrity()]%", engineering_channel)
				last_warning = REALTIMEOFDAY

			if(power > POWER_PENALTY_THRESHOLD)
				radio.talk_into(src, "Warning: Hyperstructure has reached dangerous power level.", engineering_channel)
				if(powerloss_inhibitor < 0.5)
					radio.talk_into(src, "DANGER: CHARGE INERTIA CHAIN REACTION IN PROGRESS.", engineering_channel)

			if(combined_gas > MOLE_PENALTY_THRESHOLD)
				radio.talk_into(src, "Warning: Critical coolant mass reached.", engineering_channel)
		//Boom (Mind blown)
		if(damage > explosion_point)
			countdown()

	return 1

/obj/machinery/power/supermatter_crystal/bullet_act(obj/item/projectile/Proj)
	var/turf/listener = loc
	if(!istype(listener))
		return FALSE
	if(!istype(Proj.firer, /obj/machinery/power/emitter) && power_changes)
		investigate_log("has been hit by [Proj] fired by [key_name(Proj.firer)]", INVESTIGATE_ENGINES)
	if(Proj.armor_flag != BULLET)
		if(power_changes) //This needs to be here I swear
			power += Proj.damage * bullet_energy
			if(!has_been_powered)
				investigate_log("has been powered for the first time.", INVESTIGATE_ENGINES)
				message_admins("[src] has been powered for the first time [ADMIN_JMP(src)].")
				has_been_powered = TRUE
	else if(takes_damage)
		matter_power += Proj.damage * bullet_energy
	return BULLET_ACT_HIT

/obj/machinery/power/supermatter_crystal/singularity_act()
	var/gain = 100
	investigate_log("Supermatter shard consumed by singularity.", INVESTIGATE_ENGINES)
	message_admins("Singularity has consumed a supermatter shard and can now become stage six.")
	visible_message("<span class='userdanger'>[src] is consumed by the singularity!</span>")
	for(var/mob/M in GLOB.player_list)
		if(M.z == z)
			SEND_SOUND(M, 'sound/effects/supermatter.ogg') //everyone goan know bout this
			to_chat(M, "<span class='boldannounce'>A horrible screeching fills your ears, and a wave of dread washes over you...</span>")
	qdel(src)
	return gain

/obj/machinery/power/supermatter_crystal/blob_act(obj/structure/blob/B)
	if(B && !isspaceturf(loc)) //does nothing in space
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
		damage += B.obj_integrity * 0.5 //take damage equal to 50% of remaining blob health before it tried to eat us
		if(B.obj_integrity > 100)
			B.visible_message("<span class='danger'>\The [B] strikes at \the [src] and flinches away!</span>",\
			"<span class='hear'>You hear a loud crack as you are washed with a wave of heat.</span>")
			B.take_damage(100, BURN)
		else
			B.visible_message("<span class='danger'>\The [B] strikes at \the [src] and rapidly flashes to ash.</span>",\
			"<span class='hear'>You hear a loud crack as you are washed with a wave of heat.</span>")
			Consume(B)

/obj/machinery/power/supermatter_crystal/attack_tk(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		log_game("[key_name(C)] has been disintegrated by a telekenetic grab on a supermatter crystal.</span>")
		to_chat(C, "<span class='userdanger'>That was a really dense idea.</span>")
		C.visible_message("<span class='userdanger'>A bright flare of radiation is seen from [C]'s head, shortly before you hear a sickening sizzling!</span>")
		C.ghostize()
		var/obj/item/organ/brain/rip_u = locate(/obj/item/organ/brain) in C.internal_organs
		rip_u.Remove(C)
		qdel(rip_u)

/obj/machinery/power/supermatter_crystal/attack_paw(mob/user)
	dust_mob(user, cause = "monkey attack")

/obj/machinery/power/supermatter_crystal/attack_alien(mob/user)
	dust_mob(user, cause = "alien attack")

/obj/machinery/power/supermatter_crystal/attack_animal(mob/living/simple_animal/S)
	var/murder
	if(!S.melee_damage)
		murder = S.friendly
	else
		murder = S.attacktext
	dust_mob(S, \
	"<span class='danger'>[S] unwisely [murder] [src], and [S.p_their()] body burns brilliantly before flashing into ash!</span>", \
	"<span class='userdanger'>You unwisely touch [src], and your vision glows brightly as your body crumbles to dust. Oops.</span>", \
	"simple animal attack")

/obj/machinery/power/supermatter_crystal/attack_robot(mob/user)
	if(Adjacent(user))
		dust_mob(user, cause = "cyborg attack")

/obj/machinery/power/supermatter_crystal/attack_ai(mob/user)
	return

/obj/machinery/power/supermatter_crystal/attack_hand(mob/living/user)
	. = ..()
	dust_mob(user, cause = "hand")

/obj/machinery/power/supermatter_crystal/proc/dust_mob(mob/living/nom, vis_msg, mob_msg, cause)
	if(nom.incorporeal_move || nom.status_flags & GODMODE) //try to keep supermatter sliver's + hemostat's dust conditions in sync with this too
		return
	if(!vis_msg)
		vis_msg = "<span class='danger'>[nom] reaches out and touches [src], inducing a resonance... [nom.p_their()] body starts to glow and burst into flames before flashing into dust!</span>"
	if(!mob_msg)
		mob_msg = "<span class='userdanger'>You reach out and touch [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>"
	if(!cause)
		cause = "contact"
	nom.visible_message(vis_msg, mob_msg, "<span class='hear'>You hear an unearthly noise as a wave of heat washes over you.</span>")
	investigate_log("has been attacked ([cause]) by [key_name(nom)]", INVESTIGATE_ENGINES)
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	Consume(nom)

/obj/machinery/power/supermatter_crystal/attackby(obj/item/used_item, mob/living/user, params)
	if(!istype(used_item) || (used_item.item_flags & ABSTRACT) || !istype(user))
		return
	if(istype(used_item, /obj/item/melee/roastingstick))
		return ..()
	if(istype(used_item, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/cig = used_item
		var/clumsy = HAS_TRAIT(user, TRAIT_CLUMSY)
		if(clumsy)
			var/which_hand = BODY_ZONE_L_ARM
			if(!(user.active_hand_index % 2))
				which_hand = BODY_ZONE_R_ARM
			var/obj/item/bodypart/dust_arm = user.get_bodypart(which_hand)
			dust_arm.dismember()
			user.visible_message("<span class='danger'>The [used_item] flashes out of existence on contact with \the [src], resonating with a horrible sound...</span>",\
				"<span class='danger'>Oops! The [used_item] flashes out of existence on contact with \the [src], taking your arm with it! That was clumsy of you!</span>")
			playsound(src, 'sound/effects/supermatter.ogg', 150, TRUE)
			Consume(dust_arm)
			qdel(used_item)
			return
		if(cig.lit || user.a_intent != INTENT_HELP)
			user.visible_message("<span class='danger'>A hideous sound echoes as [used_item] is ashed out on contact with \the [src]. That didn't seem like a good idea...</span>")
			playsound(src, 'sound/effects/supermatter.ogg', 150, TRUE)
			Consume(used_item)
			radiation_pulse(src, 150, 4)
			return ..()
		else
			cig.light()
			user.visible_message("<span class='danger'>As [user] lights \their [used_item] on \the [src], silence fills the room...</span>",\
				"<span class='danger'>Time seems to slow to a crawl as you touch \the [src] with \the [used_item].</span>\n<span class='notice'>\The [used_item] flashes alight with an eerie energy as you nonchalantly lift your hand away from \the [src]. Damn.</span>")
			playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
			radiation_pulse(src, 50, 3)
			return
	if(istype(used_item, /obj/item/scalpel/supermatter))
		var/obj/item/scalpel/supermatter/scalpel = used_item
		to_chat(user, "<span class='notice'>You carefully begin to scrape \the [src] with \the [used_item]...</span>")
		if(used_item.use_tool(src, user, 60, volume=100))
			if (scalpel.usesLeft)
				to_chat(user, "<span class='danger'>You extract a sliver from \the [src]. \The [src] begins to react violently!</span>")
				new /obj/item/nuke_core/supermatter_sliver(drop_location())
				matter_power += 800
				scalpel.usesLeft--
				if (!scalpel.usesLeft)
					to_chat(user, "<span class='notice'>A tiny piece of \the [used_item] falls off, rendering it useless!</span>")
			else
				to_chat(user, "<span class='warning'>You fail to extract a sliver from \The [src]. \the [used_item] isn't sharp enough anymore.</span>")
	else if(user.dropItemToGround(used_item))
		user.visible_message("<span class='danger'>As [user] touches \the [src] with \a [used_item], silence fills the room...</span>",\
			"<span class='userdanger'>You touch \the [src] with \the [used_item], and everything suddenly goes silent.</span>\n<span class='notice'>\The [used_item] flashes into dust as you flinch away from \the [src].</span>",\
			"<span class='hear'>Everything suddenly goes silent.</span>")
		investigate_log("has been attacked ([used_item]) by [key_name(user)]", INVESTIGATE_ENGINES)
		Consume(used_item)
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)

		radiation_pulse(src, 150, 4)

	else if(Adjacent(user)) //if the item is stuck to the person, kill the person too instead of eating just the item.
		var/vis_msg = "<span class='danger'>[user] reaches out and touches [src] with [used_item], inducing a resonance... [used_item] starts to glow briefly before the light continues up to [user]'s body. [user.p_they(TRUE)] bursts into flames before flashing into dust!</span>"
		var/mob_msg = "<span class='userdanger'>You reach out and touch [src] with [used_item]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>"
		dust_mob(user, vis_msg, mob_msg)

/obj/machinery/power/supermatter_crystal/wrench_act(mob/user, obj/item/tool)
	..()
	if (moveable)
		default_unfasten_wrench(user, tool, time = 20)
	return TRUE

/obj/machinery/power/supermatter_crystal/Bumped(atom/movable/AM)
	if(isliving(AM))
		AM.visible_message("<span class='danger'>\The [AM] slams into \the [src] inducing a resonance... [AM.p_their()] body starts to glow and burst into flames before flashing into dust!</span>",\
		"<span class='userdanger'>You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class='hear'>You hear an unearthly noise as a wave of heat washes over you.</span>")
	else if(isobj(AM) && !iseffect(AM))
		AM.visible_message("<span class='danger'>\The [AM] smacks into \the [src] and rapidly flashes to ash.</span>", null,\
		"<span class='hear'>You hear a loud crack as you are washed with a wave of heat.</span>")
	else
		return

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	Consume(AM)

/obj/machinery/power/supermatter_crystal/intercept_zImpact(atom/movable/AM, levels)
	. = ..()
	Bumped(AM)
	. |= FALL_STOP_INTERCEPTING | FALL_INTERCEPTED

/obj/machinery/power/supermatter_crystal/proc/Consume(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/user = AM
		if(user.status_flags & GODMODE)
			return
		var/add
		if(user?.mind?.assigned_role == "Clown")
			var/denergy = rand(-1000, 1000)
			var/ddamage = rand(-150, clamp(150, 0, (explosion_point - damage) + 150))
			power += denergy
			damage += ddamage
			add = ", adding [denergy] energy and [ddamage] damage to the crystal"
		message_admins("[src] has consumed [key_name_admin(user)] [ADMIN_JMP(src)][add].")
		investigate_log("has consumed [key_name(user)][add].", INVESTIGATE_ENGINES)
		user.dust(force = TRUE)
		if(power_changes)
			matter_power += 200
	else if(istype(AM, /obj/anomaly/singularity))
		return
	else if(isobj(AM))
		if(!iseffect(AM))
			var/suspicion = ""
			if(AM.fingerprintslast)
				suspicion = "last touched by [AM.fingerprintslast]"
				message_admins("[src] has consumed [AM], [suspicion] [ADMIN_JMP(src)].")
			investigate_log("has consumed [AM] - [suspicion].", INVESTIGATE_ENGINES)
		qdel(AM)
	if(!iseffect(AM) && power_changes)
		matter_power += 200

	//Some poor sod got eaten, go ahead and irradiate people nearby.
	radiation_pulse(src, 3000, 2, TRUE)
	for(var/mob/living/listener in range(10))
		investigate_log("has irradiated [key_name(listener)] after consuming [AM].", INVESTIGATE_ENGINES)
		var/list/viewers = viewers(src)
		if(listener in viewers)
			listener.show_message("<span class='danger'>As \the [src] slowly stops resonating, you find your skin covered in new radiation burns.</span>", MSG_VISUAL,\
				"<span class='danger'>The unearthly ringing subsides and you notice you have new radiation burns.</span>", MSG_AUDIBLE)
		else
			listener.show_message("<span class='hear'>You hear an unearthly ringing and notice your skin is covered in fresh radiation burns.</span>", MSG_AUDIBLE)

/obj/machinery/power/supermatter_crystal/proc/consume_turf(turf/source_turf)
	var/old_type = source_turf.type
	var/turf/new_turf = source_turf.ScrapeAway()
	if(new_turf.type == old_type)
		return
	playsound(source_turf, 'sound/effects/supermatter.ogg', 50, 1)
	source_turf.visible_message("<span class='danger'>[source_turf] smacks into [src] and rapidly flashes to ash.</span>",\
	"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	CALCULATE_ADJACENT_TURFS(source_turf)

//Do not blow up our internal radio
/obj/machinery/power/supermatter_crystal/contents_explosion(severity, target)
	return

/obj/machinery/power/supermatter_crystal/engine
	is_main_engine = TRUE

/obj/machinery/power/supermatter_crystal/shard
	name = "supermatter shard"
	desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure."
	base_icon_state = "darkmatter_shard"
	icon_state = "darkmatter_shard"
	anchored = FALSE
	gas_efficency = 0.125
	explosion_power = 12
	layer = ABOVE_MOB_LAYER
	moveable = TRUE
	anomaly_event = FALSE

/obj/machinery/power/supermatter_crystal/shard/examine(mob/user)
	. = ..()
	if(anchored)
		. += "<span class='notice'>[src] is <b>anchored</b> to the floor.</span>"
	else
		. += "<span class='notice'>[src] is <i>unanchored</i>, but can be <b>bolted</b> down.</span>"

/obj/machinery/power/supermatter_crystal/shard/engine
	name = "anchored supermatter shard"
	is_main_engine = TRUE
	anchored = TRUE
	moveable = FALSE

// When you wanna make a supermatter shard for the dramatic effect, but
// don't want it exploding suddenly
/obj/machinery/power/supermatter_crystal/shard/hugbox
	name = "anchored supermatter shard"
	takes_damage = FALSE
	produces_gas = FALSE
	power_changes = FALSE
	processes = FALSE //SHUT IT DOWN
	moveable = FALSE
	anchored = TRUE

/obj/machinery/power/supermatter_crystal/shard/hugbox/fakecrystal //Hugbox shard with crystal visuals, used in the Supermatter/Hyperfractal shuttle
	name = "supermatter crystal"
	base_icon_state = "darkmatter"
	icon_state = "darkmatter"

/obj/machinery/power/supermatter_crystal/proc/supermatter_pull(turf/center, pull_range = 3)
	playsound(src.loc, 'sound/weapons/marauder.ogg', 100, TRUE, extrarange = 7)
	for(var/atom/movable/P in orange(pull_range,center))
		if((P.anchored || P.move_resist >= MOVE_FORCE_EXTREMELY_STRONG)) //move resist memes.
			if(istype(P, /obj/structure/closet))
				var/obj/structure/closet/toggle = P
				toggle.open()
			continue
		if(ismob(P))
			var/mob/M = P
			if(M.mob_negates_gravity())
				continue //You can't pull someone nailed to the deck
		step_towards(P,center)

/proc/supermatter_anomaly_gen(turf/anomalycenter, type = ANOMALY_FLUX, anomalyrange = 5, has_weak_lifespan = TRUE)
	var/turf/listener = pick(orange(anomalyrange, anomalycenter))
	if(!listener)
		return

	switch(type)
		if(ANOMALY_DELIMBER)
			new /obj/effect/anomaly/delimber(listener, null)
		if(ANOMALY_FLUX)
			var/explosive = has_weak_lifespan ? ANOMALY_FLUX_NO_EXPLOSION : ANOMALY_FLUX_LOW_EXPLOSIVE
			new /obj/effect/anomaly/flux(listener, has_weak_lifespan ? rand(250, 300) : null, TRUE, explosive)
		if(ANOMALY_GRAVITATIONAL)
			new /obj/effect/anomaly/grav(listener, has_weak_lifespan ? rand(200, 300) : null)
		if(ANOMALY_HALLUCINATION)
			new /obj/effect/anomaly/hallucination(listener, has_weak_lifespan ? rand(150, 250) : null)
		if(ANOMALY_PYRO)
			new /obj/effect/anomaly/pyro(listener, has_weak_lifespan ? rand(150, 250) : null)
		if(ANOMALY_VORTEX)
			new /obj/effect/anomaly/bhole(listener, 20)

/obj/machinery/power/supermatter_crystal/proc/supermatter_zap(atom/zapstart, range = 3, power)
	. = zapstart.dir
	if(power < 1000)
		return

	var/target_atom
	var/mob/living/target_mob
	var/obj/machinery/target_machine
	var/obj/structure/target_structure
	var/list/arctargetsmob = list()
	var/list/arctargetsmachine = list()
	var/list/arctargetsstructure = list()

	if(prob(20)) //let's not hit all the engineers with every beam and/or segment of the arc
		for(var/mob/living/Z in ohearers(range+2, zapstart))
			arctargetsmob += Z
	if(arctargetsmob.len)
		var/mob/living/H = pick(arctargetsmob)
		var/atom/A = H
		target_mob = H
		target_atom = A

	else
		for(var/obj/machinery/X in oview(range+2, zapstart))
			arctargetsmachine += X
		if(arctargetsmachine.len)
			var/obj/machinery/M = pick(arctargetsmachine)
			var/atom/A = M
			target_machine = M
			target_atom = A

		else
			for(var/obj/structure/Y in oview(range+2, zapstart))
				arctargetsstructure += Y
			if(arctargetsstructure.len)
				var/obj/structure/O = pick(arctargetsstructure)
				var/atom/A = O
				target_structure = O
				target_atom = A

	if(target_atom)
		zapstart.Beam(target_atom, icon_state="nzcrentrs_power", time=5)
		var/zapdir = get_dir(zapstart, target_atom)
		if(zapdir)
			. = zapdir

	if(target_mob)
		target_mob.electrocute_act(rand(5,10), "Supermatter Discharge Bolt", 1, stun = 0)
		if(prob(15))
			supermatter_zap(target_mob, 5, power / 2)
			supermatter_zap(target_mob, 5, power / 2)
		else
			supermatter_zap(target_mob, 5, power / 1.5)

	else if(target_machine)
		if(prob(15))
			supermatter_zap(target_machine, 5, power / 2)
			supermatter_zap(target_machine, 5, power / 2)
		else
			supermatter_zap(target_machine, 5, power / 1.5)

	else if(target_structure)
		if(prob(15))
			supermatter_zap(target_structure, 5, power / 2)
			supermatter_zap(target_structure, 5, power / 2)
		else
			supermatter_zap(target_structure, 5, power / 1.5)

#undef HALLUCINATION_RANGE
