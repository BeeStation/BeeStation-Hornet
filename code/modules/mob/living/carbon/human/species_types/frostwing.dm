/datum/species/frostwing
	name = "\improper Frostwing"
	id = SPECIES_FROSTWING
	bodyflag = FLAG_FROSTWING
	default_color = "00FFFF"
	species_traits = list(NO_UNDERWEAR, NOEYESPRITES)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_AVIAN)
	mutanttongue = /obj/item/organ/tongue/frostwing
	// Lungs are what actually allow them to breathe low pressure, prefer cold temps, and take damage in station atmos
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

/datum/species/frostwing/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.frostwing_names)]-[pick(GLOB.frostwing_names)][prob(50) ? "-[pick(GLOB.frostwing_names)]" : ""][prob(10) ? "-[pick(GLOB.frostwing_names)]" : ""]"
	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, null, ++attempts)

/datum/species/frostwing/CanFly(mob/living/carbon/human/H)
	var/obj/item/bodypart/l_arm = H.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/r_arm = H.get_bodypart(BODY_ZONE_R_ARM)
	if(!istype(l_arm) || !istype(r_arm) || l_arm.disabled || r_arm.disabled)
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
