/datum/species/moth
	name = "Mothman"
	id = "moth"
	say_mod = "flutters"
	default_color = "00FF00"
	species_traits = list(LIPS, NOEYESPRITES)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_BUG)
	mutant_bodyparts = list("moth_wings")
	default_features = list("moth_wings" = "Plain")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/moth
	liked_food = VEGETABLES | DAIRY | CLOTH
	disliked_food = FRUIT | GROSS
	toxic_food = MEAT | RAW
	mutanteyes = /obj/item/organ/eyes/moth
	mutantwings = /obj/item/organ/wings/moth
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/moth

/datum/species/moth/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_moth_name()

	var/randname = moth_name()

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/moth/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..()
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)

/datum/reagent/toxin/mothbgon/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(!ismoth(M))
		return

	var/mob/living/carbon/victim = M
	if(method == TOUCH || method == VAPOR)
		//check for protection
		//actually handle the pepperspray effects
		if(!victim.is_eyes_covered() || !victim.is_mouth_covered())
			victim.blur_eyes(2)
			victim.blind_eyes(2) // 6 seconds
			victim.Knockdown(1 SECONDS)
			victim.emote("scream")
			victim.emote("spin")
			victim.adjustToxLoss(8)
			victim.adjustOxyLoss(8)
			victim.confused = max(M.confused, 10) // 10 seconds
			victim.add_movespeed_modifier(MOVESPEED_ID_PEPPER_SPRAY, update=TRUE, priority=100, multiplicative_slowdown=0.25, blacklisted_movetypes=(FLYING|FLOATING))
			addtimer(CALLBACK(victim, /mob.proc/remove_movespeed_modifier, MOVESPEED_ID_PEPPER_SPRAY), 10 SECONDS)
		victim.update_damage_hud()


/datum/species/moth/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 9 //flyswatters deal 10x damage to moths
	return 0

/datum/species/moth/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter/moth))
		return 29 //flyswatters deal 30x damage to moths
	return 0