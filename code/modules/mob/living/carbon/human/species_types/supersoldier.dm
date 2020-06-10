/datum/species/human/supersoldier
	name = "Super Soldier" //inherited from the real species, for health scanners and things
	id = "supersoldier"
	species_traits = list(NOTRANSSTING) //all of these + whatever we inherit from the real species
	inherent_traits = list(TRAIT_NOLIMBDISABLE,TRAIT_NOHUNGER,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER,TRAIT_IGNORESLOWDOWN,TRAIT_IGNOREDAMAGESLOWDOWN,TRAIT_STUNIMMUNE,TRAIT_CONFUSEIMMUNE,TRAIT_SLEEPIMMUNE,TRAIT_PUSHIMMUNE,TRAIT_VIRUSIMMUNE,TRAIT_NODISMEMBER,TRAIT_NOSLIPALL,TRAIT_THERMAL_VISION,TRAIT_STRONG_GRABBER,TRAIT_LAW_ENFORCEMENT_METABOLISM,TRAIT_ALWAYS_CLEAN,TRAIT_FEARLESS)
	mutanteyes = /obj/item/organ/eyes/night_vision
	changesource_flags = MIRROR_BADMIN | ERT_SPAWN
	var/heal_modifier = 1

/datum/species/human/supersoldier/spec_life(mob/living/carbon/human/H)
    if(H.stat == DEAD)
        return
    var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
    if(isturf(H.loc)) //else, there's considered to be no light
        var/turf/T = H.loc
        light_amount = min(1,T.get_lumcount()) - 0.5
        if(light_amount > 0) //if there's any light, heal
            H.heal_overall_damage(heal_modifier, heal_modifier, 0, BODYPART_ORGANIC)
            H.adjustToxLoss(-heal_modifier)
            H.adjustOxyLoss(-heal_modifier)

/datum/species/human/supersoldier/syndie
	id = "supersoldier_syndie"
	species_traits = list(NOTRANSSTING) //all of these + whatever we inherit from the real species
	inherent_traits = list(TRAIT_NOHUNGER,TRAIT_IGNORESLOWDOWN,TRAIT_IGNOREDAMAGESLOWDOWN,TRAIT_STUNIMMUNE,TRAIT_CONFUSEIMMUNE,TRAIT_SLEEPIMMUNE,TRAIT_VIRUSIMMUNE,TRAIT_STRONG_GRABBER,TRAIT_ALWAYS_CLEAN,TRAIT_FEARLESS,SYNDIE_SUPERSOLDIER_EYES)
	heal_modifier = 0.75
/datum/species/human/supersoldier/syndie/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	var/t_His = C.gender == "male" ? "his" : "her"
	if( HAS_TRAIT(src, SYNDIE_SUPERSOLDIER_EYES))
		. += "<span class='warning'><B>[t_His] eyes are glowing with abnormal rage!</B></span>"
