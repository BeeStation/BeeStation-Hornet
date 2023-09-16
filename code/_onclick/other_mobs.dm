/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/
/mob/living/carbon/human/primary_interact(atom/A, proximity)

	if(!has_active_hand()) //can't attack without a hand.
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

//Return TRUE to cancel other attack hand effects that respect it.
/atom/proc/attack_hand(mob/user)
	. = FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND))
		add_fingerprint(user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_NO_ATTACK_HAND)
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

/*
/mob/living/carbon/human/RestrainedClickOn(var/atom/A) ---carbons will handle this
	return
*/

/mob/living/carbon/RestrainedClickOn(atom/A)
	return 0

/mob/living/carbon/primary_ranged_attack(atom/A, mouseparams)
	. = ..()
	if(!dna)
		return
	for(var/datum/mutation/HM as() in dna.mutations)
		HM.on_ranged_attack(A, mouseparams)

/mob/living/carbon/human/primary_ranged_attack(atom/A, mouseparams)
	. = ..()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		if(istype(G) && G.Touch(A,0)) // for magic gloves
			return

	if(isturf(A) && get_dist(src,A) <= 1)
		src.Move_Pulled(A)
		return

/*
	Animals & All Unspecified
*/
/mob/living/primary_interact(atom/A)
	A.attack_animal(src)

/atom/proc/attack_animal(mob/user)
	SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_ANIMAL, user)
	return

/mob/living/RestrainedClickOn(atom/A)
	return

/*
	Monkeys
*/
/mob/living/carbon/monkey/primary_interact(atom/A, proximity)
	var/override = 0
	for(var/datum/mutation/HM as() in dna.mutations)
		override += HM.on_attack_hand(A, proximity)
	if(override)
		return

	A.attack_paw(src)

/atom/proc/attack_paw(mob/user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_PAW, user) & COMPONENT_NO_ATTACK_HAND)
		return TRUE
	return FALSE

/*
	Monkey RestrainedClickOn() was apparently the
	one and only use of all of the restrained click code
	(except to stop you from doing things while handcuffed);
	moving it here instead of various hand_p's has simplified
	things considerably
*/
/mob/living/carbon/monkey/RestrainedClickOn(atom/A)
	if(..())
		return
	if(a_intent != INTENT_HARM || !ismob(A))
		return
	if(is_muzzled())
		return
	var/mob/living/carbon/ML = A
	if(istype(ML))
		var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		if(prob(75))
			var/datum/damage_source/sharp/light/bite_source = FIND_DAMAGE_SOURCE
			ML.visible_message("<span class='danger'>[name] bites [ML]!</span>", \
							"<span class='userdanger'>[name] bites you!</span>", null, COMBAT_MESSAGE_RANGE)
			// Returns false if blocked
			var/target_zone = ran_zone(dam_zone)
			if(!bite_source.deal_attack(src, null, ML, /datum/damage/brute, rand(1, 3), target_zone))
				return
			// Check bio armour
			if (prob(ML.run_armor_check(target_zone, BIO, silent = TRUE)))
				return
			for(var/thing in diseases)
				var/datum/disease/D = thing
				ML.ForceContractDisease(D)
		else
			ML.visible_message("<span class='danger'>[src]'s bite misses [ML]!</span>", \
							"<span class='danger'>[src]'s bite misses you!</span>", null, COMBAT_MESSAGE_RANGE)

/*
	Aliens
	Defaults to same as monkey in most places
*/
/mob/living/carbon/alien/primary_interact(atom/A)
	A.attack_alien(src)

/atom/proc/attack_alien(mob/living/carbon/alien/user)
	attack_paw(user)
	return

/mob/living/carbon/alien/RestrainedClickOn(atom/A)
	return

// Babby aliens
/mob/living/carbon/alien/larva/primary_interact(atom/A)
	if (A.larva_attack_intercept(src))
		return
	var/damage_dealt = deal_generic_attack(A)
	if (damage_dealt <= 0)
		return
	amount_grown = min(amount_grown + damage_dealt, max_grown)

/atom/proc/larva_attack_intercept(mob/user)
	return FALSE

/mob/living/carbon/alien/larva/deal_generic_attack(atom/target)
	switch(a_intent)
		if(INTENT_HELP)
			target.visible_message("<span class='notice'>[name] rubs its head against [target].</span>", \
							"<span class='notice'>[name] rubs its head against you.</span>")
			return FALSE

		else
			if(prob(90))
				log_combat(src, target, "attacked")
				var/datum/damage_source/source = GET_DAMAGE_SOURCE(/datum/damage_source/sharp/light)
				source.deal_attack(src, null, target, /datum/damage/brute, rand(3, 10), ran_zone(zone_selected))
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				return TRUE
			else
				do_attack_animation(target)
				target.visible_message("<span class='danger'>[name]'s bite misses [target]!</span>", \
								"<span class='userdanger'>[name]'s bite misses you!</span>", null, COMBAT_MESSAGE_RANGE)
	return FALSE

/*
	Slimes
	Nothing happening here
*/
/mob/living/simple_animal/slime/primary_interact(atom/A)
	deal_generic_attack(A)

/**
 * 
 */
/atom/proc/after_attacked_by_slime(mob/user)
	return

/mob/living/simple_animal/slime/RestrainedClickOn(atom/A)
	return


/*
	Drones
*/
/mob/living/simple_animal/drone/primary_interact(atom/A)
	A.attack_drone(src)

/atom/proc/attack_drone(mob/living/simple_animal/drone/user)
	attack_hand(user) //defaults to attack_hand. Override it when you don't want drones to do same stuff as humans.

/mob/living/simple_animal/slime/RestrainedClickOn(atom/A)
	return


/*
	True Devil
*/

/mob/living/carbon/true_devil/primary_interact(atom/A, proximity)
	A.attack_hand(src)

/*
	Brain
*/

/mob/living/brain/primary_interact(atom/A)//Stops runtimes due to attack_animal being the default
	return


/*
	pAI
*/

/mob/living/silicon/pai/primary_interact(atom/attack_target, proximity_flag, list/modifiers)
	attack_target.attack_pai(src, modifiers)

/atom/proc/attack_pai(mob/user, list/modifiers)
	return

/*
	Simple animals
*/

/mob/living/simple_animal/primary_interact(atom/A, proximity)
	if(!dextrous || a_intent == INTENT_HARM)
		return ..()
	if(!ismob(A))
		A.attack_hand(src)
		update_inv_hands()


/*
	Hostile animals
*/

/mob/living/simple_animal/hostile/primary_interact(atom/A)
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
