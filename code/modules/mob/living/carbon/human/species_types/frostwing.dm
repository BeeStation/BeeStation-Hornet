/datum/species/frostwing
	name = "\improper Frostwing"
	id = SPECIES_FROSTWING
	bodyflag = FLAG_FROSTWING
	species_traits = list(NO_UNDERWEAR, NOEYESPRITES)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_AVIAN)
	action
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC
	mutanttongue = /obj/item/organ/tongue/frostwing
	// Allow frozen, low pressure atmos. This doesn't cause damage for the station atmos, instead using bodytemp
	mutantlungs = /obj/item/organ/lungs/frostwing
	// Their biology requires less oxygen due to the low pressure environment, so they don't take as much oxyloss.
	oxymod = 0.5
	default_features = list("wings" = "Frostwing Light", "body_size" = "Normal", "frostwing_variant" = "Light")
	mutant_bodyparts = list("frostwing_wings")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/frostwing
	// Drop feathers
	skinned_type = /obj/item/stack/sheet/animalhide/frostwing
	// They cannot speak Common, only Icaelic
	species_language_holder = /datum/language_holder/frostwing

	species_chest = /obj/item/bodypart/chest/frostwing/light
	species_head = /obj/item/bodypart/head/frostwing/light
	species_l_arm = /obj/item/bodypart/l_arm/frostwing/light
	species_r_arm = /obj/item/bodypart/r_arm/frostwing/light
	species_l_leg = /obj/item/bodypart/l_leg/frostwing/light
	species_r_leg = /obj/item/bodypart/r_leg/frostwing/light

	// 310.15 (normal bodytemp) - 293.15 (normal atmos) = 17, 180 + 17 = 197
	body_temperature_normal = 197
	body_temperature_cold_damage_limit = 197 - 50
	body_temperature_heat_damage_limit = 197 + 30 // lower maximum, so they have a harder time in station atmos
	// Make us heat up as fast as we cool down
	body_temperature_heat_divisor = BODYTEMP_COLD_DIVISOR
	// We can heat up double a human in one tick
	body_temperature_heating_max = BODYTEMP_HEATING_MAX * 2

	/// Action used to show frostwings to other frostwings
	var/datum/action/cooldown/frostwing_call/call_action

/datum/species/frostwing/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.frostwing_names)]-[pick(GLOB.frostwing_names)][prob(50) ? "-[pick(GLOB.frostwing_names)]" : ""][prob(10) ? "-[pick(GLOB.frostwing_names)]" : ""]"
	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, null, ++attempts)

/datum/species/frostwing/CanFly(mob/living/carbon/human/H)
	// Make sure we have frostwing arms that work
	var/obj/item/bodypart/l_arm/frostwing/l_arm = H.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/r_arm/frostwing/r_arm = H.get_bodypart(BODY_ZONE_R_ARM)
	if(!istype(l_arm) || !istype(r_arm) || l_arm.disabled || r_arm.disabled)
		to_chat(H, "<span class='warning'>You need both arms to fly!</span>")
		return FALSE
	// Thick clothing
	var/obj/item/clothing/chest_item = H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	if(istype(chest_item) && chest_item.clothing_flags & THICKMATERIAL)
		to_chat(H, "<span class='warning'>Your wings are inside of [chest_item]!</span>")
		return FALSE
	if(H.stat || !(H.mobility_flags & MOBILITY_STAND) || H.restrained(ignore_grab = TRUE))
		return FALSE
	var/turf/T = get_turf(H)
	if(!T)
		return FALSE
	var/datum/gas_mixture/environment = T.return_air()
	if(environment && !(environment.return_pressure() > 30))
		to_chat(H, "<span class='warning'>The atmosphere is too thin for you to fly!</span>")
		return FALSE
	return TRUE

/datum/species/frostwing/toggle_flight(mob/living/carbon/human/H)
	. = ..()
	// Sound credit
	// https://freesound.org/people/ani_music/sounds/244978/
	playsound(H, 'sound/effects/wings_fold.ogg', 100, TRUE)
	if(H.movement_type & FLYING)
		H.dna.species.mutant_bodyparts |= "wingsopen"
	else
		H.dna.species.mutant_bodyparts -= "wingsopen"
	H.update_body()
	H.update_inv_hands() // hide/show inhands
	return TRUE

/datum/species/frostwing/proc/toggle_wings_cosmetic(mob/living/carbon/human/H)
	playsound(H, 'sound/effects/wings_fold.ogg', 100, TRUE)
	if("wingsopen" in H.dna.species.mutant_bodyparts)
		H.dna.species.mutant_bodyparts -= "wingsopen"
	else
		H.dna.species.mutant_bodyparts |= "wingsopen"
	H.update_body()
	H.update_inv_hands() // hide/show inhands
	return TRUE

/datum/species/frostwing/modify_body(mob/living/carbon/C, var/datum/species/new_species)
	switch(C.dna.features["frostwing_variant"])
		if("Light")
			species_chest = /obj/item/bodypart/chest/frostwing/light
			species_head = /obj/item/bodypart/head/frostwing/light
			species_l_arm = /obj/item/bodypart/l_arm/frostwing/light
			species_r_arm = /obj/item/bodypart/r_arm/frostwing/light
			species_l_leg = /obj/item/bodypart/l_leg/frostwing/light
			species_r_leg = /obj/item/bodypart/r_leg/frostwing/light
			return
		if("Dark")
			species_chest = /obj/item/bodypart/chest/frostwing/dark
			species_head = /obj/item/bodypart/head/frostwing/dark
			species_l_arm = /obj/item/bodypart/l_arm/frostwing/dark
			species_r_arm = /obj/item/bodypart/r_arm/frostwing/dark
			species_l_leg = /obj/item/bodypart/l_leg/frostwing/dark
			species_r_leg = /obj/item/bodypart/r_leg/frostwing/dark
			return

/datum/species/frostwing/on_species_gain(mob/living/carbon/C)
	. = ..()
	if(ishuman(C) && !fly)
		fly = new
		fly.Grant(C)
	if(islist(C.dna?.features))
		C.dna.features["wings"] = C.dna.features["frostwing_variant"] == "Light" ? "Frostwing Light" : "Frostwing Dark"
	var/datum/component/tracking_beacon/component_beacon = C.AddComponent(/datum/component/tracking_beacon, "frostwing", null, null, FALSE, "#2fd6db", TRUE, TRUE, "#005e61")
	component_beacon.attached_monitor = C.AddComponent(/datum/component/team_monitor, "frostwing", 1, component_beacon, TRUE)
	component_beacon.attached_monitor.show_hud(C)
	// For some reason doing this initially doesn't work
	component_beacon.toggle_visibility(FALSE)
	call_action = new()
	call_action.Grant(C)

/datum/species/frostwing/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(ishuman(C) && fly)
		fly.Remove(C)
		toggle_flight(C)
	call_action.Remove(C)
	QDEL_NULL(call_action)
	var/datum/component/tracking_beacon/beacon = C.GetComponent(/datum/component/tracking_beacon)
	if(beacon)
		beacon.RemoveComponent()
	var/datum/component/team_monitor/monitor = C.GetComponent(/datum/component/team_monitor)
	if(monitor)
		monitor.RemoveComponent()

/datum/species/frostwing/spec_life(mob/living/carbon/human/H)
	..()
	if(call_action)
		call_action.UpdateButtonIcon()

/datum/action/cooldown/frostwing_call
	name = "Call"
	desc = "Performs a loud bird call, allowing your fellow frostwings to pinpoint you if they're close enough."
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	button_icon_state = "call"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	cooldown_time = 15 SECONDS

/datum/action/cooldown/frostwing_call/Trigger()
	if(!..())
		return FALSE
	var/mob/living/carbon/H = owner
	var/obj/item/organ/tongue/tongue = H.getorgan(/obj/item/organ/tongue)
	if(!tongue)
		to_chat(H, "<span class='warning'>You try to call out, but you have no tongue!</span>")
		return
	if(HAS_TRAIT(H, TRAIT_MUTE))
		to_chat(H, "<span class='warning'>You can't speak!</span>")
		return
	to_chat(H, "<span class='notice'>You call out loudly to your fellow frostwings...</span>")
	H.emote("acaw")
	var/turf/turf_source = get_turf(H)
	var/list/listeners = list()
	if(is_station_level(turf_source.z))
		for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
			listeners += SSmobs.clients_by_zlevel[z]
	else
		listeners += SSmobs.clients_by_zlevel[turf_source.z]
		var/turf/above_turf = SSmapping.get_turf_above(turf_source)
		var/turf/below_turf = SSmapping.get_turf_below(turf_source)
		if(above_turf)
			listeners += SSmobs.clients_by_zlevel[above_turf.z]
		if(below_turf)
			listeners += SSmobs.clients_by_zlevel[below_turf.z]

	for(var/mob/living/carbon/human/listening_mob in listeners)
		if(!isfrostwing(listening_mob) || get_dist(listening_mob, turf_source) > 75 || !listening_mob.can_hear())
			continue
		SEND_SOUND(listening_mob, sound(pick('sound/emotes/caw3.ogg', 'sound/emotes/caw4.ogg'), volume=75))
		to_chat(listening_mob, "<span class='notice'>You hear a distant call...</span>")
	var/datum/component/tracking_beacon/beacon = H.GetComponent(/datum/component/tracking_beacon)
	if(beacon)
		beacon.toggle_visibility(TRUE)
		addtimer(CALLBACK(beacon, TYPE_PROC_REF(/datum/component/tracking_beacon, toggle_visibility), FALSE), 5 SECONDS)
	StartCooldown()
	return TRUE

/datum/action/cooldown/frostwing_call/IsAvailable()
	if(..())
		var/mob/living/carbon/human/H = owner
		return !HAS_TRAIT(H, TRAIT_MUTE) && H.getorgan(/obj/item/organ/tongue)
	return FALSE

/datum/species/frostwing/handle_environment(datum/gas_mixture/environment, mob/living/carbon/human/H)
	..()
	if(!environment)
		return
	if(istype(H.loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		return
	// Heal small amounts of burn while outside the station
	if(prob(15) && H.bodytemperature < H.get_bodytemp_heat_damage_limit() && H.bodytemperature > H.get_bodytemp_cold_damage_limit())
		H.heal_overall_damage(burn = 2)

// Hide inhands if the wings are open
/datum/species/frostwing/process_inhands(mob/living/carbon/human/H, mutable_appearance/hand_overlay, is_right_hand)
	return !("wingsopen" in H.dna.species.mutant_bodyparts)

/datum/species/frostwing/z_impact_damage(mob/living/carbon/human/H, turf/T, levels)
	//Check to make sure legs are working
	var/obj/item/bodypart/left_leg = H.get_bodypart(BODY_ZONE_L_LEG)
	var/obj/item/bodypart/right_leg = H.get_bodypart(BODY_ZONE_R_LEG)
	if(!left_leg || !right_leg || left_leg.disabled || right_leg.disabled)
		return ..()
	if(levels == 1)
		//Nailed it!
		H.visible_message("<span class='notice'>[H] lands elegantly on [H.p_their()] feet!</span>",
			"<span class='warning'>You fall [levels] level\s into [T], perfecting the landing!</span>")
		H.Stun(levels * 35)
	else
		H.visible_message("<span class='danger'>[H] falls [levels] level\s into [T], barely landing on [H.p_their()] feet, with a sickening crunch!</span>")
		var/amount_total = H.get_distributed_zimpact_damage(levels) * 0.5
		H.apply_damage(amount_total * 0.35, BRUTE, BODY_ZONE_L_LEG)
		H.apply_damage(amount_total * 0.35, BRUTE, BODY_ZONE_R_LEG)
		H.adjustBruteLoss(amount_total * 0.1)
		H.Stun(levels * 50)
		// owie
		// 5: 32%, 4: 24%, 3: 16%
		if(levels >= 3 && prob(min((levels - 1) * 8, 75)))
			if(levels >= 3 && prob(25))
				for(var/selected_part in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
					var/obj/item/bodypart/bp = H.get_bodypart(selected_part)
					if(bp)
						bp.dismember()
				return
			var/selected_part = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			var/obj/item/bodypart/bp = H.get_bodypart(selected_part)
			if(bp)
				bp.dismember()
				return

/datum/species/frostwing/get_thermal_protection(mob/living/carbon/human/H)
	var/thermal_protection = 0
	if(H.wear_suit)
		if(H.wear_suit.max_heat_protection_temperature >= FIRE_SUIT_MAX_TEMP_PROTECT)
			thermal_protection += (H.wear_suit.max_heat_protection_temperature*THERMAL_PROTECTION_SUIT)
	if(H.head) // greatly reduced protection from helmets - otherwise fire helmets are super abusable
		if(H.head.max_heat_protection_temperature >= FIRE_HELM_MAX_TEMP_PROTECT)
			thermal_protection += (H.head.max_heat_protection_temperature*0.1) // reduced head protection
	thermal_protection = round(thermal_protection)
	return thermal_protection

// Reduces their ability to just slap on a fire helmet and be immune, since fire helmets don't block flight
/datum/species/frostwing/get_heat_protection(mob/living/carbon/human/H, temperature)
	var/thermal_protection = ..()
	var/thermal_protection_flags = get_heat_protection_flags(H, temperature)
	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection -= (THERMAL_PROTECTION_HEAD - 0.1) // adjusting to match target of 0.1
	return thermal_protection


