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

/mob/living/carbon/human/species/twistedmen
    race = /datum/species/twistedmen


/mob/living/carbon/human/species/twistedmen/Initialize()
  ..()
  deathsound = pick('sound/voice/twisted/twisteddeath_1.ogg',
                    'sound/voice/twisted/twisteddeath_2.ogg',
                    'sound/voice/twisted/twisteddeath_3.ogg')

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
