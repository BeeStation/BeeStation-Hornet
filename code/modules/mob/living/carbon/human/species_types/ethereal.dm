/datum/species/ethereal
	name = "\improper Ethereal"
	id = SPECIES_ETHEREAL
	attack_verb = "burn"
	attack_sound = 'sound/weapons/etherealhit.ogg'
	miss_sound = 'sound/weapons/etherealmiss.ogg'
	meat = /obj/item/food/meat/slab/human/mutant/ethereal
	mutantstomach = /obj/item/organ/stomach/battery/ethereal
	mutanttongue = /obj/item/organ/tongue/ethereal
	mutantheart = /obj/item/organ/heart/ethereal
	exotic_bloodtype = "E"
	siemens_coeff = 0.5 //They thrive on energy
	brutemod = 1.25 //They're weak to punches
	attack_type = BURN //burn bish
	species_traits = list(
		DYNCOLORS,
		AGENDER,
		HAIR
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/ethereal
	inherent_traits = list(TRAIT_POWERHUNGRY)
	sexes = FALSE //no fetish content allowed

	// Body temperature for ethereals is much higher then humans as they like hotter environments
	bodytemp_normal = (BODYTEMP_NORMAL + 50)
	bodytemp_heat_damage_limit = FIRE_MINIMUM_TEMPERATURE_TO_SPREAD // about 150C
	// Cold temperatures hurt faster as it is harder to move with out the heat energy
	bodytemp_cold_damage_limit = (T20C - 10) // about 10c
	hair_color = "fixedmutcolor"
	hair_alpha = 140
	swimming_component = /datum/component/swimming/ethereal
	inert_mutation = /datum/mutation/overload

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/ethereal,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/ethereal,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/ethereal,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/ethereal,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/ethereal,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/ethereal,
	)

	var/current_color
	var/default_color
	var/EMPeffect = FALSE
	var/emageffect = FALSE
	//this is shit but how do i fix it? no clue.
	var/drain_time = 0 //used to keep ethereals from spam draining power sources
	var/obj/effect/dummy/lighting_obj/ethereal_light

/datum/species/ethereal/Destroy(force)
	if(ethereal_light)
		QDEL_NULL(ethereal_light)
	return ..()

/datum/species/ethereal/on_species_gain(mob/living/carbon/new_ethereal, datum/species/old_species, pref_load)
	. = ..()
	if(!ishuman(new_ethereal))
		return
	var/mob/living/carbon/human/ethereal = new_ethereal
	default_color = ethereal.dna.features["ethcolor"]
	RegisterSignal(ethereal, COMSIG_ATOM_SHOULD_EMAG, PROC_REF(should_emag))
	RegisterSignal(ethereal, COMSIG_ATOM_ON_EMAG, PROC_REF(on_emag))
	RegisterSignal(ethereal, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))
	ethereal_light = ethereal.mob_light(light_type = /obj/effect/dummy/lighting_obj/moblight/species)
	spec_updatehealth(ethereal)

	new_ethereal.set_safe_hunger_level()

	var/obj/item/organ/heart/ethereal/ethereal_heart = new_ethereal.get_organ_slot(ORGAN_SLOT_HEART)
	ethereal_heart.ethereal_color = default_color

/datum/species/ethereal/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	UnregisterSignal(C, COMSIG_ATOM_SHOULD_EMAG)
	UnregisterSignal(C, COMSIG_ATOM_ON_EMAG)
	UnregisterSignal(C, COMSIG_ATOM_EMP_ACT)
	QDEL_NULL(ethereal_light)
	return ..()

/datum/species/ethereal/spec_updatehealth(mob/living/carbon/human/ethereal)
	. = ..()
	if(!ethereal_light)
		return
	if(ethereal.stat != DEAD && !EMPeffect)
		var/healthpercent = max(ethereal.health, 0) / 100
		if(!emageffect)
			var/static/list/skin_color = rgb2num("#eda495")
			var/list/colors = rgb2num(ethereal.dna.features["ethcolor"])
			var/list/built_color = list()
			for(var/i in 1 to 3)
				built_color += skin_color[i] + ((colors[i] - skin_color[i]) * healthpercent)
			current_color = rgb(built_color[1], built_color[2], built_color[3])

		ethereal_light.set_light_range_power_color(1 + (2 * healthpercent), 1 + (1 * healthpercent), current_color)
		ethereal_light.set_light_on(TRUE)
		fixed_mut_color = current_color
	else
		ethereal_light.set_light_on(FALSE)
		fixed_mut_color = COLOR_GRAY
	ethereal.update_body()
	//ethereal.update_hair()

/datum/species/ethereal/proc/on_emp_act(mob/living/carbon/human/H, severity)
	SIGNAL_HANDLER
	EMPeffect = TRUE
	spec_updatehealth(H)
	to_chat(H, span_notice("You feel the light of your body leave you."))
	switch(severity)
		if(EMP_LIGHT)
			addtimer(CALLBACK(src, PROC_REF(stop_emp), H), 10 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) //We're out for 10 seconds
		if(EMP_HEAVY)
			addtimer(CALLBACK(src, PROC_REF(stop_emp), H), 20 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) //We're out for 20 seconds

/datum/species/ethereal/proc/should_emag(mob/living/carbon/human/H, mob/user)
	SIGNAL_HANDLER
	return !(!emageffect || !istype(H)) // signal is inverted

/datum/species/ethereal/proc/on_emag(mob/living/carbon/human/H, mob/user, obj/item/card/emag/hacker)
	SIGNAL_HANDLER

	if(hacker)
		if(hacker.charges <= 0)
			to_chat(user, span_warning("[hacker] is out of charges and needs some time to restore them!"))
			user.balloon_alert(user, "out of charges!")
			return
		else
			hacker.use_charge()

	emageffect = TRUE
	if(user)
		to_chat(user, span_notice("You tap [H] on the back with your card."))
	H.visible_message(span_danger("[H] starts flickering in an array of colors!"))
	handle_emag(H)
	addtimer(CALLBACK(src, PROC_REF(stop_emag), H), 30 SECONDS) //Disco mode for 30 seconds! This doesn't affect the ethereal at all besides either annoying some players, or making someone look badass.

/datum/species/ethereal/proc/stop_emp(mob/living/carbon/human/H)
	EMPeffect = FALSE
	spec_updatehealth(H)
	to_chat(H, span_notice("You feel more energized as your shine comes back."))

/datum/species/ethereal/proc/handle_emag(mob/living/carbon/human/H)
	if(!emageffect)
		return
	current_color = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)] //Picks a random colour from the Ethereal colour list
	spec_updatehealth(H)
	addtimer(CALLBACK(src, PROC_REF(handle_emag), H), 5) //Call ourselves every 0.5 seconds to change color

/datum/species/ethereal/proc/stop_emag(mob/living/carbon/human/H)
	emageffect = FALSE
	spec_updatehealth(H)
	H.visible_message(span_danger("[H] stops flickering and goes back to their normal state!"))

/datum/species/ethereal/handle_charge(mob/living/carbon/human/H)
	brutemod = 1.25
	if(HAS_TRAIT(H, TRAIT_NOHUNGER))
		return
	switch(H.nutrition)
		if(NUTRITION_LEVEL_FED to INFINITY)
			H.clear_alert("nutrition")
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_FED)
			H.throw_alert("nutrition", /atom/movable/screen/alert/etherealcharge, 1)
			brutemod = 1.5
		if(1 to NUTRITION_LEVEL_STARVING)
			H.throw_alert("nutrition", /atom/movable/screen/alert/etherealcharge, 2)
			if(H.health > 10.5)
				H.apply_damage(0.65, TOX, null, null, H)
			brutemod = 1.75
		else
			H.throw_alert("nutrition", /atom/movable/screen/alert/etherealcharge, 3)
			if(H.health > 10.5)
				H.apply_damage(1, TOX, null, null, H)
			brutemod = 2

/datum/species/ethereal/get_cough_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_COUGH_SOUND(user)

/datum/species/ethereal/get_gasp_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_GASP_SOUND(user)

/datum/species/ethereal/get_sigh_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SIGH_SOUND(user)

/datum/species/ethereal/get_sneeze_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SNEEZE_SOUND(user)

/datum/species/ethereal/get_sniff_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SNIFF_SOUND(user)

/datum/species/ethereal/get_giggle_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_GIGGLE_SOUND(user)

/datum/species/ethereal/get_features()
	var/list/features = ..()

	features += "feature_ethcolor"

	return features

/datum/species/ethereal/get_scream_sound(mob/living/carbon/human/ethereal)
	return pick(
		'sound/voice/ethereal/ethereal_scream_1.ogg',
		'sound/voice/ethereal/ethereal_scream_2.ogg',
		'sound/voice/ethereal/ethereal_scream_3.ogg',
	)

/datum/species/ethereal/get_species_description()
	return "Ethereals are a unique species with liquid electricity for blood and a glowing body. They thrive on electricity, and are naturally agender."

/datum/species/ethereal/get_species_lore()
	return null

/datum/species/ethereal/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "lightbulb",
			SPECIES_PERK_NAME = "Disco Ball",
			SPECIES_PERK_DESC = "Ethereals passively generate their own light.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = "Starving Artist",
			SPECIES_PERK_DESC = "Ethereals take toxin damage while starving.",
		),
	)

	return to_add
