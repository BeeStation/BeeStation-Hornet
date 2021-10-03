/datum/species/squid
	name = "Squidperson"
	id = "squid"
	default_color = "b8dfda"
	species_traits = list(MUTCOLORS,EYECOLOR)
	inherent_traits = list(TRAIT_NOSLIPALL,TRAIT_EASYDISMEMBER)
	default_features = list("mcolor" = "FFF") // bald
	speedmod = 0.5
	burnmod = 1.5
	heatmod = 1.4
	coldmod = 1.5
	punchdamage = 7 // Lower max damage in melee. It's just a tentacle
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | SLIME_EXTRACT
	attack_verb = "lash"
	attack_sound = 'sound/weapons/whip.ogg'
	miss_sound = 'sound/weapons/etherealmiss.ogg'
	grab_sound = 'sound/weapons/whipgrab.ogg'
	deathsound = 'sound/voice/hiss1.ogg'
	use_skintones = 0
	no_equip = list(ITEM_SLOT_FEET)
	skinned_type = /obj/item/stack/sheet/animalhide/human
	toxic_food = FRIED
	species_language_holder = /datum/language_holder/squid
	swimming_component = /datum/component/swimming/squid

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
	var/datum/action/innate/squid_change/S = new
	S.Grant(H)

/datum/species/squid/on_species_loss(mob/living/carbon/human/H)
	fixed_mut_color = rgb(128,128,128)
	H.update_body()
	var/datum/action/innate/squid_change/S = locate(/datum/action/innate/squid_change) in H.actions
	qdel(S)

/datum/action/innate/squid_change
	name = "Color Change"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions.dmi'
	button_icon_state = "squid"
	var/cooldown = 0

/datum/action/innate/squid_change/IsAvailable()
	if(cooldown > world.time)
		return FALSE
	return ..()

/datum/action/innate/squid_change/Activate()
	var/mob/living/carbon/human/H = owner
	var/new_color = input(usr, "Choose a new skin color:", "Color Change", H.dna.species.fixed_mut_color) as color|null
	if(new_color)
		var/temp_hsv = RGBtoHSV(new_color)
		if(ReadHSV(temp_hsv)[3] >= ReadHSV("#7F7F7F")[3])
			H.dna.species.fixed_mut_color = sanitize_hexcolor(new_color)
			H.update_body()
			cooldown = world.time + 50
			active = TRUE
		else
			to_chat(usr, "<span class='danger'>Invalid color. Your color is not bright enough.</span>")
	UpdateButtonIcon()

/datum/action/innate/squid_change/Deactivate()
	active = FALSE
	UpdateButtonIcon()
