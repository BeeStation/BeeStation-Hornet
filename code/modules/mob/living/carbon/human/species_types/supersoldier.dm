/datum/species/human/supersoldier
	name = "Super Soldier" //inherited from the real species, for health scanners and things
	id = "supersoldier"
	limbs_id = "human"
	species_traits = list(NOTRANSSTING) //all of these + whatever we inherit from the real species
	inherent_traits = list(TRAIT_NOLIMBDISABLE,TRAIT_NOHUNGER,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER,TRAIT_IGNORESLOWDOWN,TRAIT_IGNOREDAMAGESLOWDOWN,TRAIT_STUNIMMUNE,TRAIT_CONFUSEIMMUNE,TRAIT_SLEEPIMMUNE,TRAIT_PUSHIMMUNE,TRAIT_VIRUSIMMUNE,TRAIT_NODISMEMBER,TRAIT_NOSLIPALL,TRAIT_THERMAL_VISION,TRAIT_STRONG_GRABBER,TRAIT_LAW_ENFORCEMENT_METABOLISM,TRAIT_ALWAYS_CLEAN,TRAIT_FEARLESS)
	mutanteyes = /obj/item/organ/eyes/night_vision
	changesource_flags = MIRROR_BADMIN | ERT_SPAWN

/datum/species/human/supersoldier/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1,T.get_lumcount()) - 0.5
		if(light_amount > 0) //if there's any light, heal
			H.heal_overall_damage(1,1, 0, BODYPART_ORGANIC)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)