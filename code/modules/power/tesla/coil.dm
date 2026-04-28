/obj/machinery/power/energy_accumulator/tesla_coil
	name = "tesla coil"
	desc = "For the union!"
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "coil0"

	// Executing a traitor caught releasing tesla was never this fun!
	can_buckle = TRUE
	buckle_lying = 0
	buckle_requires_restraints = TRUE

	circuit = /obj/item/circuitboard/machine/tesla_coil
	custom_price = 450

	/// Flags of the zap that the coil releases when the wire is pulsed
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_LOW_POWER_GEN
	/// Multiplier for power conversion
	var/input_power_multiplier = 1

	/// Calculated range of zap sounds based on power
	var/zap_sound_range = 0
	/// Calculated volume of zap sounds based on power
	var/zap_sound_volume = 0

	/// Cooldown between pulsed zaps
	var/cooldown_time = 10 SECONDS

	COOLDOWN_DECLARE(zap_cooldown)

/obj/machinery/power/energy_accumulator/tesla_coil/anchored
	anchored = TRUE

/obj/machinery/power/energy_accumulator/tesla_coil/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/tesla_coil(src)

/obj/machinery/power/energy_accumulator/tesla_coil/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/power/energy_accumulator/tesla_coil/RefreshParts()
	var/power_multiplier = 0
	cooldown_time = 10 SECONDS
	for(var/obj/item/stock_parts/capacitor/capacitor in component_parts)
		power_multiplier += capacitor.rating
		cooldown_time -= capacitor.rating * 2 SECONDS
	input_power_multiplier = max(power_multiplier / 8, 0.25) //Max out at 50% efficency.

/obj/machinery/power/energy_accumulator/tesla_coil/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads:<br>" + \
			"Power generation at <b>[input_power_multiplier * 100]%</b>.<br>" + \
			"Shock interval at <b>[cooldown_time * 0.1]</b> seconds.<br>" + \
			"Stored <b>[display_energy(get_stored_joules())]</b>.<br>" + \
			"Processing <b>[display_power(processed_energy)]</b>.")

/obj/machinery/power/energy_accumulator/tesla_coil/on_construction(mob/user)
	if(anchored)
		connect_to_network()

/obj/machinery/power/energy_accumulator/tesla_coil/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(panel_open)
			icon_state = "coil_open[anchored]"
		else
			icon_state = "coil[anchored]"
		if(anchored)
			connect_to_network()
		else
			disconnect_from_network()

/obj/machinery/power/energy_accumulator/tesla_coil/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "coil_open[anchored]", "coil[anchored]", W))
		return

	if(default_unfasten_wrench(user, W))
		return

	if(default_deconstruction_crowbar(W))
		return

	if(is_wire_tool(W) && panel_open)
		wires.interact(user)
		return

	return ..()

/obj/machinery/power/energy_accumulator/tesla_coil/zap_act(power, zap_flags)
	if(!anchored || panel_open)
		return ..()

	ADD_TRAIT(src, TRAIT_BEING_SHOCKED, WAS_SHOCKED)
	addtimer(TRAIT_CALLBACK_REMOVE(src, TRAIT_BEING_SHOCKED, WAS_SHOCKED), 1 SECONDS)
	flick("coilhit", src)

	if(!(zap_flags & ZAP_GENERATES_POWER)) //Prevent infinite recursive power
		return 0
	if(zap_flags & ZAP_LOW_POWER_GEN)
		power /= 10

	zap_buckle_check(power)

	var/power_removed = powernet ? power * input_power_multiplier : power
	stored_energy += max(power_removed, 0)

	return max(power - power_removed, 0)

/obj/machinery/power/energy_accumulator/tesla_coil/proc/zap()
	if(!COOLDOWN_FINISHED(src, zap_cooldown) || !powernet)
		return FALSE

	COOLDOWN_START(src, zap_cooldown, cooldown_time)

	// Always always always use more then you output for the love of god
	var/power = (powernet.avail) * 0.2 * input_power_multiplier  //Always always always use more then you output for the love of god
	power = min(surplus(), power) //Take the smaller of the two
	add_load(power)

	playsound(src, 'sound/magic/lightningshock.ogg', zap_sound_volume, TRUE, zap_sound_range)
	tesla_zap(
		source = src,
		zap_range = 10,
		power = power,
		cutoff = 1e3,
		zap_flags = zap_flags,
	)
	zap_buckle_check(power)

// Tesla R&D researcher
/obj/machinery/power/energy_accumulator/tesla_coil/research
	name = "Tesla Corona Analyzer"
	desc = "A modified Tesla Coil used to study the effects of Edison's Bane for research."
	icon_state = "rpcoil0"
	circuit = /obj/item/circuitboard/machine/tesla_coil/research
	input_power_multiplier = 0.05

	/// The techweb this coil is linked to, used for generating research points
	var/datum/techweb/linked_techweb

/obj/machinery/power/energy_accumulator/tesla_coil/research/anchored
	anchored = TRUE

/obj/machinery/power/energy_accumulator/tesla_coil/research/Initialize(mapload)
	. = ..()
	linked_techweb = SSresearch.science_tech

/obj/machinery/power/energy_accumulator/tesla_coil/research/Destroy()
	linked_techweb = null
	. = ..()

/obj/machinery/power/energy_accumulator/tesla_coil/research/zap_act(power, zap_flags)
	if(!anchored || panel_open)
		return ..()

	ADD_TRAIT(src, TRAIT_BEING_SHOCKED, WAS_SHOCKED)
	addtimer(TRAIT_CALLBACK_REMOVE(src, TRAIT_BEING_SHOCKED, WAS_SHOCKED), 1 SECONDS)
	flick("rpcoilhit", src)

	zap_buckle_check(power)

	var/power_removed = powernet ? power * input_power_multiplier : power
	stored_energy += max(power_removed, 0)

	// Give money and research points
	var/datum/bank_account/engineering_bank = SSeconomy.get_budget_account(ACCOUNT_ENG_ID)//x4 coils give ~ 768 credits per minute
	engineering_bank?.adjust_money(min(power_removed, 3)*2)

	if(linked_techweb)
		linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, min(power_removed, 3)*2)
		linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, min(power_removed, 3)*2) // x4 coils with a pulse per second or so = ~744/m point bonus for R&D

	return max(power - power_removed, 0)

/obj/machinery/power/energy_accumulator/tesla_coil/research/default_unfasten_wrench(mob/user, obj/item/wrench/wrench, time = 2 SECONDS)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(panel_open)
			icon_state = "rpcoil_open[anchored]"
		else
			icon_state = "rpcoil[anchored]"

/obj/machinery/power/energy_accumulator/tesla_coil/research/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "rpcoil_open[anchored]", "rpcoil[anchored]", W))
		return
	return ..()

/obj/machinery/power/energy_accumulator/tesla_coil/research/on_construction(mob/user)
	if(anchored)
		connect_to_network()

/obj/machinery/power/energy_accumulator/grounding_rod
	name = "grounding rod"
	desc = "Keeps an area from being fried by Edison's Bane."
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "grounding_rod0"
	wants_powernet = FALSE
	circuit = /obj/item/circuitboard/machine/grounding_rod
	can_buckle = TRUE
	buckle_lying = 0
	buckle_requires_restraints = TRUE
	custom_price = 350

/obj/machinery/power/energy_accumulator/grounding_rod/anchored
	anchored = TRUE

/obj/machinery/power/energy_accumulator/grounding_rod/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads:<br>" + \
			"Recently grounded <b>[display_energy(get_stored_joules())]</b>.<br>" + \
			"This energy would sustainably release <b>[display_power(calculate_sustainable_power())]</b>.")

/obj/machinery/power/energy_accumulator/grounding_rod/default_unfasten_wrench(mob/user, obj/item/wrench, time = 2 SECONDS)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(panel_open)
			icon_state = "grounding_rod_open[anchored]"
		else
			icon_state = "grounding_rod[anchored]"

/obj/machinery/power/energy_accumulator/grounding_rod/wrench_act(mob/living/user, obj/item/tool)
	return default_unfasten_wrench(user, tool)

/obj/machinery/power/energy_accumulator/grounding_rod/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	if(default_deconstruction_screwdriver(user, "grounding_rod_open[anchored]", "grounding_rod[anchored]", W))
		return

	if(default_deconstruction_crowbar(W))
		return

	return ..()

/obj/machinery/power/energy_accumulator/grounding_rod/zap_act(energy, zap_flags)
	if(anchored && !panel_open)
		flick("grounding_rodhit", src)
		zap_buckle_check(energy)
		stored_energy += energy
		return 0
	else
		return ..()

/obj/machinery/power/energy_accumulator/grounding_rod/release_energy(joules = 0)
	stored_energy -= joules
	processed_energy = joules
	return FALSE //Grounding rods don't release energy to the grid.
