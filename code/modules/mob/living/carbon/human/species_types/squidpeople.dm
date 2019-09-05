/datum/species/squid
    name = "Squidperson"
    id = "squid"
    default_color = "b8dfda"
    species_traits = list(MUTCOLORS,EYECOLOR,TRAIT_EASYDISMEMBER)
    inherent_traits = list(TRAIT_NOSLIPALL)
    default_features = list("mcolor" = "FFF") // bald
    speedmod = 0.5
    burnmod = 1.5
    heatmod = 1.4
    coldmod = 1.5
    punchdamagehigh = 7 // Lower max damage in melee. It's just a tentacle
    changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | SLIME_EXTRACT
    attack_verb = list("whipped", "lashed", "disciplined")
    attack_sound = 'sound/weapons/whip.ogg'
    miss_sound = 'sound/weapons/etherealmiss.ogg'
    grab_sound = 'sound/weapons/whipgrab.ogg'
    deathsound = 'sound/voice/hiss1.ogg'
    use_skintones = 0
    no_equip = list(SLOT_SHOES)
    skinned_type = /obj/item/stack/sheet/animalhide/human
    toxic_food = FRIED

/mob/living/carbon/human/species/squid
    race = /datum/species/squid

/datum/species/squid/qualifies_for_rank(rank, list/features)
    return TRUE

/datum/species/squid/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_squid_name(genderToFind = gender)
	var/randname = squid_name(gender)
	if(lastname)
		randname += " [lastname]"
	return randname

/proc/random_unique_squid_name(attempts_to_find_unique_name=10, genderToFind)
    for(var/i in 1 to attempts_to_find_unique_name)
        . = capitalize(squid_name(genderToFind))
        if(!findname(.))
            break

/datum/species/squid/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	H.grant_language(/datum/language/rlyehian)
	var/datum/action/innate/squid_change/S = locate(/datum/action/innate/squid_change) in M.actions
	S?.Remove(M)
	S.Grant(H)

/datum/species/squid/on_species_loss(mob/living/carbon/human/H)
	fixed_mut_color = rgb(128,128,128)
	H.update_body()

/datum/action/innate/squid_change
	name = "Color Change"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/animal.dmi'
	button_icon_state = "squid"
	var/cooldown = 0

/datum/action/innate/squid_change/IsAvailable()
    if(cooldown > world.time)
        return FALSE
    return ..()

/datum/action/innate/squid_change/Activate()
	var/mob/living/carbon/human/H = owner
	switch(rand(1,20))
		if(1) // "orange"
			H.dna.features["mcolor"] = "#FFA500"
		if(2) // "purple"
			H.dna.features["mcolor"] = "#B19CD9"
		if(3) // "blue"
			H.dna.features["mcolor"] = "#ADD8E6"
		if(4) //"metal"
			H.dna.features["mcolor"] = "#7E7E7E"
		if(5) // "yellow"
			H.dna.features["mcolor"] = "#FFFF00"
		if(6) // "dark purple"
			H.dna.features["mcolor"] = "#551A8B"
		if(7) // "dark blue"
			H.dna.features["mcolor"] = "#0000FF"
		if(8) // "silver"
			H.dna.features["mcolor"] = "#D3D3D3"
		if(9) // "bluespace"
			H.dna.features["mcolor"] = "#32CD32"
		if(10) // "sepia"
			H.dna.features["mcolor"] = "#704214"
		if(11) // "cerulean"
			H.dna.features["mcolor"] = "#2956B2"
		if(12) // "pyrite"
			H.dna.features["mcolor"] = "#FAFAD2"
		if(13) // "red"
			H.dna.features["mcolor"] = "#FF0000"
		if(14) // "green"
			H.dna.features["mcolor"] = "#00FF00"
		if(15) // "pink"
			H.dna.features["mcolor"] = "#FF69B4"
		if(16) // "gold"
			H.dna.features["mcolor"] = "#FFD700"
		if(17) // "oil"
			H.dna.features["mcolor"] = "#505050"
		if(18) // "black"
			H.dna.features["mcolor"] = "#000000"
		if(19) // "light pink"
			H.dna.features["mcolor"] = "#FFB6C1"
		if(20) // "adamantine"
			H.dna.features["mcolor"] = "#008B8B"
	H.update_body()
	cooldown = world.time + 50
	active = TRUE
	UpdateButtonIcon()

/datum/action/innate/squid_change/Deactivate()
    active = FALSE
    UpdateButtonIcon()
