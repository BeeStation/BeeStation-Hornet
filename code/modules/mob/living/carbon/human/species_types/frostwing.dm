/datum/species/frostwing
	name = "\improper Frostwing"
	id = SPECIES_FROSTWING
	bodyflag = FLAG_FROSTWING
	default_color = "00FFFF"
	species_traits = list(NO_UNDERWEAR, NOEYESPRITES)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_AVIAN)
	mutanttongue = /obj/item/organ/tongue/frostwing
	// Allow frozen, low pressure atmos. This doesn't cause damage for the station atmos, instead using bodytemp
	mutantlungs = /obj/item/organ/lungs/frostwing
	// Their biology requires less oxygen due to the low pressure environment, so they don't take as much oxyloss.
	oxymod = 0.5
	default_features = list("legs" = "Normal Legs", "body_size" = "Normal")
	//changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/frostwing
	// Drop feathers
	skinned_type = /obj/item/stack/sheet/animalhide/frostwing
	// They cannot speak Common, only Icaelic
	species_language_holder = /datum/language_holder/frostwing

	species_chest = /obj/item/bodypart/chest/frostwing
	species_head = /obj/item/bodypart/head/frostwing
	species_l_arm = /obj/item/bodypart/l_arm/frostwing
	species_r_arm = /obj/item/bodypart/r_arm/frostwing
	species_l_leg = /obj/item/bodypart/l_leg/frostwing
	species_r_leg = /obj/item/bodypart/r_leg/frostwing

	// 310.15 (normal bodytemp) - 293.15 (normal atmos) = 17, 180 + 17 = 197
	body_temperature_normal = 197
	body_temperature_cold_damage_limit = 197 - 50
	body_temperature_heat_damage_limit = 197 + 30 // lower maximum, so they have a harder time in station atmos
	// Make us heat up as fast as we cool down
	body_temperature_heat_divisor = BODYTEMP_COLD_DIVISOR
	// We can heat up double a human in one tick
	body_temperature_heating_max = BODYTEMP_HEATING_MAX * 2

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
	if(H.stat || !(H.mobility_flags & MOBILITY_STAND))
		return FALSE
	var/turf/T = get_turf(H)
	if(!T)
		return FALSE
	var/datum/gas_mixture/environment = T.return_air()
	if(environment && !(environment.return_pressure() > 30))
		to_chat(H, "<span class='warning'>The atmosphere is too thin for you to fly!</span>")
		return FALSE
	return TRUE

/datum/species/frostwing/on_species_gain(mob/living/carbon/C)
	. = ..()
	if(ishuman(C) && !fly)
		fly = new
		fly.Grant(C)

/datum/species/frostwing/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(ishuman(C) && fly)
		fly.Remove(C)
		toggle_flight(C)

/datum/species/frostwing/handle_environment(datum/gas_mixture/environment, mob/living/carbon/human/H)
	..()
	if(!environment)
		return
	if(istype(H.loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		return
	// Heal small amounts of burn while outside the station
	if(prob(15) && H.bodytemperature < H.get_bodytemp_heat_damage_limit() && H.bodytemperature > H.get_bodytemp_cold_damage_limit())
		H.apply_damage(-2, BURN)

