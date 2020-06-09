/datum/species/human/supersoldier
	name = "Super Soldier" //inherited from the real species, for health scanners and things
	id = "supersoldier"
	species_traits = list(NOTRANSSTING) //all of these + whatever we inherit from the real species
	inherent_traits = list(TRAIT_NOLIMBDISABLE,TRAIT_NOHUNGER,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER,TRAIT_IGNORESLOWDOWN,TRAIT_IGNOREDAMAGESLOWDOWN,TRAIT_STUNIMMUNE,TRAIT_CONFUSEIMMUNE,TRAIT_SLEEPIMMUNE,TRAIT_PUSHIMMUNE,TRAIT_VIRUSIMMUNE,TRAIT_NODISMEMBER,TRAIT_NOSLIPALL,TRAIT_THERMAL_VISION,TRAIT_STRONG_GRABBER,TRAIT_LAW_ENFORCEMENT_METABOLISM,TRAIT_ALWAYS_CLEAN,TRAIT_FEARLESS)
	mutanteyes = /obj/item/organ/eyes/night_vision
	changesource_flags = MIRROR_BADMIN | ERT_SPAWN

/datum/species/human/supersoldier/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	var/heal_modifier = 1

/datum/species/human/supersoldier/syndie
	id = "supersoldier_syndie"
	species_traits = list(NOTRANSSTING) //all of these + whatever we inherit from the real species
	inherent_traits = list(TRAIT_NOHUNGER,TRAIT_IGNORESLOWDOWN,TRAIT_STUNIMMUNE,TRAIT_CONFUSEIMMUNE,TRAIT_SLEEPIMMUNE,TRAIT_VIRUSIMMUNE,TRAIT_STRONG_GRABBER,TRAIT_ALWAYS_CLEAN,TRAIT_FEARLESS)

/datum/species/human/supersoldier/syndie/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	var/heal_modifier = 0.25
