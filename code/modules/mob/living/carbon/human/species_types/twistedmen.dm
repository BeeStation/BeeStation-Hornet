// Icewalkers made for Spooktober 2023

/datum/species/twistedmen

	name = "\improper Twisted man"
	plural_form = "Twisted men"
	id = SPECIES_TWISTED
	sexes = 0
	species_traits = list(NOBLOOD,NOHUSK,NOREAGENTS,NO_UNDERWEAR,NOEYESPRITES,)
	inherent_traits = list(TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_NOMETABOLISM,TRAIT_NOGUNS)
	inherent_biotypes = list(MOB_UNDEAD,MOB_HUMANOID)
	damage_overlay_type = "" //normal sprite already shows wounds, likely to remain empty
	changesource_flags = MIRROR_BADMIN //The species is not balanced for normal rounds, considering leaving this empty
	species_language_holder = /datum/language_holder/construct

	species_chest = /obj/item/bodypart/head/twisted
	species_head = /obj/item/bodypart/chest/twisted
	species_l_arm = /obj/item/bodypart/l_arm/twisted
	species_r_arm = /obj/item/bodypart/r_arm/twisted
	species_l_leg = /obj/item/bodypart/l_leg/twisted
	species_r_leg = /obj/item/bodypart/r_leg/twisted
	var/datum/action/innate/dispenser/dispenser

/mob/living/carbon/human/species/twistedmen
    race = /datum/species/twistedmen


/mob/living/carbon/human/species/twistedmen/Initialize()
  ..()
  deathsound = pick('sound/voice/twisted/twisteddeath_1.ogg',
                    'sound/voice/twisted/twisteddeath_2.ogg',
                    'sound/voice/twisted/twisteddeath_3.ogg')

/datum/species/twistedmen/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		dispenser = new
		dispenser.Grant(C)

/datum/species/twistedmen/get_scream_sound(mob/living/carbon/user)
	return pick(
		'sound/voice/twisted/twistedscream_1.ogg',
		'sound/voice/twisted/twistedscream_2.ogg',
		'sound/voice/twisted/twistedscream_3.ogg',
		'sound/voice/twisted/twistedscream_4.ogg',
	)

/datum/species/twistedmen/get_laugh_sound(mob/living/carbon/user)
	return pick(
		'sound/voice/twisted/twistedlaugh_1.ogg',
		'sound/voice/twisted/twistedlaugh_2.ogg',
		'sound/voice/twisted/twistedlaugh_3.ogg',
		'sound/voice/twisted/twistedlaugh_4.ogg',
	)

/datum/species/twistedmen/get_species_description()
	return "A twisted husk of flesh and metal, haunting the wastes of Iceland in search of sacrifices to offer to the Unshaped."

/datum/species/twistedmen/get_species_lore()
	return list("Shapeless shadows roaming the wastes of Iceland, these ominous creatures bear strange ressemblances to humans and are highly aggressive. They seem to be in a state of constant agony, their defiled bodies made of a twisted metal and flesh, a trickle of blood pouring out of what seems to be wounds. They band together in settlements and organize hunting parties to find victims to brutally sacrifice in honor of their terrible god.")

/datum/action/innate/dispenser
	name = "Flesh craft"
	desc = "Craft tools using chunks of your body"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "transmute"
	icon_icon = 'icons/mob/actions/actions_cult.dmi'//NEEDS ICON
	background_icon_state = "bg_cult"
	COOLDOWN_DECLARE(dispense_cooldown)
	var/metal_reserves = 4
	var/static/list/absorbeable = typecacheof(list(/obj/item/restraints/handcuffs/cable/zipties,/obj/item/restraints/legcuffs/bola,/obj/item/shield/energy))


/datum/action/innate/dispenser/Activate()
	var/held_item = owner.get_active_held_item()
	if(held_item)
		if(is_type_in_typecache(held_item, absorbeable))
			to_chat(owner, "<span class='warning'>We reintegrate [held_item] back into our body!</span>")//NEEDS LOCALIZATION
			qdel(held_item)
			metal_reserves++
			return
		else
			to_chat(owner, "<span class='warning'>We can't reintegrate this!</span>")//NEEDS LOCALIZATION
	var/list/dispense_list = list(
		"Zipties" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "cuff"),//NEEDS ICON (?)
		"Bola" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "bola"),//NEEDS ICON (?)
		"Shield" = image(icon = 'icons/obj/shields.dmi', icon_state = "eshield1"),)//NEEDS ICON (?)
	if(!COOLDOWN_FINISHED(src,dispense_cooldown))
		return
	if(!metal_reserves > 0)
		to_chat(owner, "<span class='warning'>You are out of Metal! Reabsorb something you've made!</span>")//NEEDS LOCALIZATION
	var/choice = show_radial_menu(owner, owner, dispense_list, radius = 42)
	switch(choice)
		if("Zipties")
			choice = new /obj/item/restraints/handcuffs/cable/zipties
		if("Bola")
			choice = new /obj/item/restraints/legcuffs/bola
		if("Shield")
			choice = new /obj/item/shield/energy
	if(!choice)
		return
	if(!owner.put_in_active_hand(choice))
		to_chat(owner, "<span class='warning'>Your hand is full!</span>")//NEEDS LOCALIZATION
		qdel(choice)
		return
	metal_reserves--
	to_chat(owner, "<span class='warning'>Your fabricate [choice]!</span>")//NEEDS LOCALIZATION
	COOLDOWN_START(src,dispense_cooldown,10 SECONDS)

