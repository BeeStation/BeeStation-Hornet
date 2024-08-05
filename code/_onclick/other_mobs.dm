/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/
/mob/living/carbon/human/UnarmedAttack(atom/A, proximity)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		if(src == A)
			check_self_for_injuries()
		return
	if(!has_active_hand()) //can't attack without a hand.
		var/obj/item/bodypart/check_arm = get_active_hand()
		if(check_arm?.bodypart_disabled)
			to_chat(src, "<span class='warning'>Your [check_arm.name] is in no condition to be used.</span>")
			return

		to_chat(src, "<span class='notice'>You look at your arm and sigh.</span>")
		return

	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines
	if(proximity && istype(G) && G.Touch(A,1))
		return

	var/override = 0

	for(var/datum/mutation/HM as() in dna.mutations)
		override += HM.on_attack_hand(A, proximity)

	if(override)
		return

	SEND_SIGNAL(src, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, A)
	A.attack_hand(src)

/// Return TRUE to cancel other attack hand effects that respect it.
/atom/proc/attack_hand(mob/user)
	. = FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND))
		add_fingerprint(user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		. = TRUE
	if(interaction_flags_atom & INTERACT_ATOM_ATTACK_HAND)
		. = _try_interact(user)

//Return a non FALSE value to cancel whatever called this from propagating, if it respects it.
/atom/proc/_try_interact(mob/user)
	if(IsAdminGhost(user))		//admin abuse
		return interact(user)
	if(can_interact(user))
		return interact(user)
	return FALSE

/atom/proc/can_interact(mob/user)
	if(!user.can_interact_with(src, interaction_flags_atom & INTERACT_ATOM_ALLOW_USER_LOCATION))
		return FALSE
	if((interaction_flags_atom & INTERACT_ATOM_REQUIRES_DEXTERITY) && !user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_IGNORE_INCAPACITATED) && user.incapacitated((interaction_flags_atom & INTERACT_ATOM_IGNORE_RESTRAINED), !(interaction_flags_atom & INTERACT_ATOM_CHECK_GRAB)))
		return FALSE
	return TRUE

/atom/ui_status(mob/user)
	. = ..()
	//Check if both user and atom are at the same location
	if(!can_interact(user))
		. = min(., UI_UPDATE)

/atom/movable/can_interact(mob/user)
	. = ..()
	if(!.)
		return
	if(!anchored && (interaction_flags_atom & INTERACT_ATOM_REQUIRES_ANCHORED))
		return FALSE

/atom/proc/interact(mob/user)
	if(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_INTERACT)
		add_hiddenprint(user)
	else
		add_fingerprint(user)
	if(interaction_flags_atom & INTERACT_ATOM_UI_INTERACT)
		return ui_interact(user)
	return FALSE

/mob/living/carbon/RangedAttack(atom/A, mouseparams)
	. = ..()
	if(!dna)
		return
	for(var/datum/mutation/HM as() in dna.mutations)
		HM.on_ranged_attack(A, mouseparams)

/mob/living/carbon/human/RangedAttack(atom/A, mouseparams)
	. = ..()
	if(.)
		return
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		if(istype(G) && G.Touch(A,0)) // for magic gloves
			return TRUE

	if(isturf(A) && get_dist(src,A) <= 1)
		Move_Pulled(A)
		return TRUE

/*
	Animals & All Unspecified
*/
/mob/living/UnarmedAttack(atom/A)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	A.attack_animal(src)

/atom/proc/attack_animal(mob/user)
	SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_ANIMAL, user)
	return

/atom/proc/attack_basic_mob(mob/user)
	SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_BASIC_MOB, user)
	return

/*
	Monkeys
*/
/mob/living/carbon/monkey/UnarmedAttack(atom/A, proximity)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		if(a_intent != INTENT_HARM || is_muzzled())
			return
		if(!iscarbon(A))
			return
		var/mob/living/carbon/victim = A
		var/obj/item/bodypart/affecting = null
		if(ishuman(victim))
			var/mob/living/carbon/human/human_victim = victim
			affecting = human_victim.get_bodypart(pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/armor = victim.run_armor_check(affecting, MELEE)
		if(prob(25))
			victim.visible_message("<span class='danger'>[src]'s bite misses [victim]!</span>",
				"<span class='danger'>You avoid [src]'s bite!</span>", "<span class='hear'>You hear jaws snapping shut!</span>", COMBAT_MESSAGE_RANGE, src)
			to_chat(src, "<span class='danger'>Your bite misses [victim]!</span>")
			return
		victim.apply_damage(rand(1, 3), BRUTE, affecting, armor)
		victim.visible_message("<span class='danger'>[name] bites [victim]!</span>",
			"<span class='userdanger'>[name] bites you!</span>", "<span class='hear'>You hear a chomp!</span>", COMBAT_MESSAGE_RANGE, name)
		to_chat(name, "<span class='danger'>You bite [victim]!</span>")
		if(armor >= 2)
			return
		for(var/d in diseases)
			var/datum/disease/bite_infection = d
			victim.ForceContractDisease(bite_infection)
		return
	A.attack_paw(src)

/atom/proc/attack_paw(mob/user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_PAW, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	return FALSE

/mob/living/carbon/alien/UnarmedAttack(atom/A)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	A.attack_alien(src)

/atom/proc/attack_alien(mob/living/carbon/alien/user)
	attack_paw(user)
	return

// Babby aliens
/mob/living/carbon/alien/larva/UnarmedAttack(atom/A)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	A.attack_larva(src)
/atom/proc/attack_larva(mob/user)
	return


/*
	Slimes
	Nothing happening here
*/
/mob/living/simple_animal/slime/UnarmedAttack(atom/A)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	A.attack_slime(src)

/atom/proc/attack_slime(mob/user)
	return

/*
	Drones
*/
/mob/living/simple_animal/drone/UnarmedAttack(atom/A)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	A.attack_drone(src)

/atom/proc/attack_drone(mob/living/simple_animal/drone/user)
	attack_hand(user) //defaults to attack_hand. Override it when you don't want drones to do same stuff as humans.

/*
	True Devil
*/

/mob/living/carbon/true_devil/UnarmedAttack(atom/A, proximity)
	A.attack_hand(src)

/*
	Brain
*/

/mob/living/brain/UnarmedAttack(atom/A)//Stops runtimes due to attack_animal being the default
	return


/*
	pAI
*/

/mob/living/silicon/pai/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	attack_target.attack_pai(src, modifiers)

/atom/proc/attack_pai(mob/user, list/modifiers)
	return

/*
	Simple animals
*/

/mob/living/simple_animal/UnarmedAttack(atom/A, proximity)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(!dextrous || a_intent == INTENT_HARM)
		return ..()
	if(!ismob(A))
		A.attack_hand(src)
		update_inv_hands()


/*
	Hostile animals
*/

/mob/living/simple_animal/hostile/UnarmedAttack(atom/A)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	GiveTarget(A)
	if(dextrous && !ismob(A))
		..()
	else
		AttackingTarget()



/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/dead/new_player/ClickOn()
	return
