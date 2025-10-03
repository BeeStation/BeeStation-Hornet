/obj/item/zombie_hand
	name = "zombie claw"
	desc = "A zombie's claw is its primary tool, capable of infecting \
		humans, butchering all other living things to \
		sustain the zombie, smashing open airlock doors and opening \
		child-safe caps on bottles."
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	var/icon_left = "bloodhand_left"
	var/icon_right = "bloodhand_right"
	var/viral = FALSE
	hitsound = 'sound/hallucinations/growl1.ogg'
	force = 21 // Just enough to break airlocks with melee attacks
	/// Base infection chance of 80%, gets lowered with armour
	var/base_infection_chance = 80
	damtype = BRUTE

/obj/item/zombie_hand/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/zombie_hand/visual_equipped(mob/user, slot)
	. = ..()
	//these are intentionally inverted
	var/i = user.get_held_index_of_item(src)
	if(!(i % 2))
		icon_state = icon_left
	else
		icon_state = icon_right

/obj/item/zombie_hand/afterattack(atom/target, mob/user, proximity_flag)
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

	if(NOZOMBIE in target.dna.species.species_traits)
		// cannot infect any NOZOMBIE subspecies (such as high functioning
		// zombies)
		return

	var/obj/item/organ/zombie_infection/infection
	infection = target.get_organ_slot(ORGAN_SLOT_ZOMBIE)
	if(!infection)
		infection = new()
		infection.Insert(target)

/obj/item/zombie_hand/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is ripping [user.p_their()] brains out! It looks like [user.p_theyre()] trying to commit suicide!"))
	var/obj/item/bodypart/head = user.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.dismember()
	return BRUTELOSS

/obj/item/zombie_hand/proc/check_feast(mob/living/target, mob/living/user)
	if(target.stat == DEAD)
		var/hp_gained = target.maxHealth
		target.investigate_log("has been devoured by a zombie.", INVESTIGATE_DEATHS)
		target.gib()
		// zero as argument for no instant health update
		user.adjustBruteLoss(-hp_gained, 0)
		user.adjustToxLoss(-hp_gained, 0)
		user.adjustFireLoss(-hp_gained, 0)
		user.adjustCloneLoss(-hp_gained, 0)
		user.updatehealth()
		user.adjustOrganLoss(ORGAN_SLOT_BRAIN, -hp_gained) // Zom Bee gibbers "BRAAAAISNSs!1!"
		user.set_nutrition(min(user.nutrition + hp_gained, NUTRITION_LEVEL_FULL))

/obj/item/zombie_hand/proc/try_infect(mob/living/carbon/human/target, mob/living/user)
	CHECK_DNA_AND_SPECIES(target)

	if(NOZOMBIE in target.dna.species.species_traits)
		// cannot infect any NOZOMBIE subspecies (such as high functioning
		// zombies)
		return

/obj/item/zombie_hand/infectious
	name = "infected zombie claw"
	viral = TRUE
	force = 15


