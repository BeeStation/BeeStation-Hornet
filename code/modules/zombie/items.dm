/obj/item/mutant_hand/zombie
	name = "zombie claw"
	desc = "A zombie's claw is its primary tool, capable of infecting \
		humans, butchering all other living things to \
		sustain the zombie, smashing open airlock doors and opening \
		child-safe caps on bottles."
	var/viral = FALSE
	hitsound = 'sound/hallucinations/growl1.ogg'
	force = 21 // Just enough to break airlocks with melee attacks
	damtype = BRUTE
	/// Base infection chance of 80%, gets lowered with armour
	var/base_infection_chance = 80

/obj/item/mutant_hand/zombie/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		return
	if(isliving(target))
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/flesh_wound = ran_zone(user.get_combat_bodyzone(target))
			if(H.check_shields(src, 0))
				return
			if(prob(base_infection_chance-H.getarmor(flesh_wound, MELEE, armour_penetration)))
				if(viral && isliving(user))
					var/mob/living/L = user
					var/mob/living/T = target
					for(var/datum/disease/advance/D in L.diseases)
						if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS) || (D.spread_flags & DISEASE_SPREAD_FALTERED) || D.dormant)
							continue
						T.ForceContractDisease(D)
				else
					try_to_zombie_infect(target)
		else
			check_feast(target, user)
	if((istype(target, /obj/structure) || istype(target, /obj/machinery)) && viral)
		var/obj/O = target
		O.take_damage(21, BRUTE, MELEE, 0)

/proc/try_to_zombie_infect(mob/living/carbon/human/target)
	CHECK_DNA_AND_SPECIES(target)

	if(HAS_TRAIT(target, TRAIT_NO_ZOMBIFY))
		// cannot infect any TRAIT_NO_ZOMBIFY human
		return

	var/obj/item/organ/zombie_infection/infection
	infection = target.get_organ_slot(ORGAN_SLOT_ZOMBIE)
	if(!infection)
		infection = new()
		infection.Insert(target)

/obj/item/mutant_hand/zombie/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is ripping [user.p_their()] brains out! It looks like [user.p_theyre()] trying to commit suicide!"))
	var/obj/item/bodypart/head = user.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.dismember()
	return BRUTELOSS

/obj/item/mutant_hand/zombie/proc/check_feast(mob/living/target, mob/living/user)
	if(target.stat == DEAD)
		var/hp_gained = target.maxHealth
		target.investigate_log("has been devoured by a zombie.", INVESTIGATE_DEATHS)
		target.gib()
		var/need_mob_update
		need_mob_update = user.adjustBruteLoss(-hp_gained, updating_health = FALSE)
		need_mob_update += user.adjustToxLoss(-hp_gained, updating_health = FALSE)
		need_mob_update += user.adjustFireLoss(-hp_gained, updating_health = FALSE)
		need_mob_update += user.adjustCloneLoss(-hp_gained, updating_health = FALSE)
		need_mob_update += user.adjustOrganLoss(ORGAN_SLOT_BRAIN, -hp_gained) // Zom Bee gibbers "BRAAAAISNSs!1!"
		user.set_nutrition(min(user.nutrition + hp_gained, NUTRITION_LEVEL_FULL))
		if(need_mob_update)
			user.updatehealth()

/obj/item/mutant_hand/zombie/proc/try_infect(mob/living/carbon/human/target, mob/living/user)
	CHECK_DNA_AND_SPECIES(target)

	if(HAS_TRAIT(target, TRAIT_NO_ZOMBIFY))
		// cannot infect any TRAIT_NO_ZOMBIFY human
		return

/obj/item/mutant_hand/zombie/infectious
	name = "infected zombie claw"
	viral = TRUE
	force = 15
