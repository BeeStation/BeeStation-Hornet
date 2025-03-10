/// how many things can we knock off a table at once by diving into it?
#define MAX_TABLE_MESSES 18

/**
 * For when you want to throw a person at something and have fun stuff happen
 *
 * This component is made for carbon mobs (really, humans), and allows its parent to throw themselves and perform tackles. This is done by enabling throw mode, then clicking on your
 *   intended target with an empty hand. You will then launch toward your target. If you hit a carbon, you'll roll to see how hard you hit them. If you hit a solid non-mob, you'll
 *   roll to see how badly you just messed yourself up. If, along your journey, you hit a table, you'll slam onto it and send up to MAX_TABLE_MESSES (8) /obj/items on the table flying,
 *   and take a bit of extra damage and stun for each thing launched.
 *
 * There are 2 separate """skill rolls""" involved here, which are handled and explained in [rollTackle()][/datum/component/tackler/proc/rollTackle] (for roll 1, carbons), and [splat()][/datum/component/tackler/proc/splat] (for roll 2, walls and solid objects)
*/
/datum/component/tackler
	dupe_mode = COMPONENT_DUPE_UNIQUE

	///If we're currently tackling or are on cooldown. Actually, shit, if I use this to handle cooldowns, then getting thrown by something while on cooldown will count as a tackle..... whatever, i'll fix that next commit
	var/tackling = TRUE
	///How much stamina it takes to launch a tackle
	var/stamina_cost
	///Launching a tackle calls Knockdown on you for this long, so this is your cooldown. Once you stand back up, you can tackle again.
	var/base_knockdown
	///Your max range for how far you can tackle.
	var/range
	///How fast you sail through the air. Standard tackles are 1 speed, but gloves that throw you faster come at a cost: higher speeds make it more likely you'll be badly injured if you fly into a non-mob obstacle.
	var/speed
	///A flat modifier to your roll against your target, as described in [rollTackle()][/datum/component/tackler/proc/rollTackle]. Slightly misleading, skills aren't relevant here, this is a matter of what type of gloves (or whatever) is granting you the ability to tackle.
	var/skill_mod
	///Some gloves, generally ones that increase mobility, may have a minimum distance to fly. Rocket gloves are especially dangerous with this, be sure you'll hit your target or have a clear background if you miss, or else!
	var/min_distance
	///A wearkef to the throwdatum we're currently dealing with, if we need it
	var/datum/weakref/tackle_ref

/datum/component/tackler/Initialize(stamina_cost = 25, base_knockdown = 1 SECONDS, range = 4, speed = 1, skill_mod = 0, min_distance = min_distance)
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

	src.stamina_cost = stamina_cost
	src.base_knockdown = base_knockdown
	src.range = range
	src.speed = speed
	src.skill_mod = skill_mod
	src.min_distance = min_distance

	var/mob/P = parent
	to_chat(P, "<span class='notice'>You are now able to launch tackles! You can do so by activating throw mode, and " + "<b>clicking</b> on your target with an empty hand.</span>")

	addtimer(CALLBACK(src, PROC_REF(resetTackle)), base_knockdown, TIMER_STOPPABLE)

/datum/component/tackler/Destroy()
	var/mob/P = parent
	to_chat(P, "<span class='notice'>You can no longer tackle.</span>")
	return ..()

/datum/component/tackler/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLICKON, PROC_REF(checkTackle))
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_IMPACT, PROC_REF(sack))
	RegisterSignal(parent, COMSIG_MOVABLE_POST_THROW, PROC_REF(registerTackle))

/datum/component/tackler/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_CLICKON, COMSIG_MOVABLE_PRE_IMPACT, COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_POST_THROW))

///Store the thrownthing datum for later use
/datum/component/tackler/proc/registerTackle(mob/living/carbon/user, datum/thrownthing/tackle)
	SIGNAL_HANDLER

	tackle_ref = WEAKREF(tackle)
	tackle.thrower = WEAKREF(user)

///See if we can tackle or not. If we can, leap!
/datum/component/tackler/proc/checkTackle(mob/living/carbon/user, atom/clicked_atom, params)
	SIGNAL_HANDLER

	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, ALT_CLICK) || LAZYACCESS(modifiers, SHIFT_CLICK) || LAZYACCESS(modifiers, CTRL_CLICK) || LAZYACCESS(modifiers, MIDDLE_CLICK))
		return

	if(!user.throw_mode || user.get_active_held_item() || user.pulling || user.buckled || user.incapacitated())
		return

	if(!clicked_atom || !(isturf(clicked_atom) || isturf(clicked_atom.loc)))
		return

	if(HAS_TRAIT(user, TRAIT_HULK))
		to_chat(user, "<span class='warning'>You're too angry to remember how to tackle!</span>")
		return

	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, "<span class='warning'>You need free use of your hands to tackle!</span>")
		return

	if(user.body_position == LYING_DOWN)
		to_chat(user, "<span class='warning'>You must be standing to tackle!</span>")
		return

	if(tackling)
		to_chat(user, "<span class='warning'>You're not ready to tackle!</span>")
		return

	if(user.has_status_effect(/datum/status_effect/staggered)) // can't tackle if you're staggered
		to_chat(user, "<span class='warning'>You're too off balance to tackle!</span>")
		return

	user.face_atom(clicked_atom)

	tackling = TRUE
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(checkObstacle))
	playsound(user, 'sound/weapons/thudswoosh.ogg', 40, TRUE, -1)

	var/leap_word = iscatperson(user) ? "pounce" : "leap" //If cat, "pounce" instead of "leap".
	if(can_see(user, clicked_atom, 7))
		user.visible_message("<span class='warning'>[user] [leap_word]s at [clicked_atom]!</span>",
							"<span class='danger'>You [leap_word] at [clicked_atom]!</span>")
	else
		user.visible_message("<span class='warning'>[user] [leap_word]s!</span>",
							"<span class='danger'>You [leap_word]!</span>")

	if(get_dist(user, clicked_atom) < min_distance)
		var/tackle_angle = get_angle(user, clicked_atom)
		clicked_atom = get_turf_in_angle(tackle_angle, get_turf(user), min_distance)

	user.Knockdown(base_knockdown, ignore_canstun = TRUE)
	user.adjustStaminaLoss(stamina_cost)
	user.throw_at(clicked_atom, range, speed, user, FALSE, force = MOVE_FORCE_WEAK)
	addtimer(CALLBACK(src, PROC_REF(resetTackle)), base_knockdown, TIMER_STOPPABLE)
	return(COMSIG_MOB_CANCEL_CLICKON)

/**
 * sack() is called when you actually smack into something, assuming we're mid-tackle. First it deals with smacking into non-carbons, in two cases:
 * * If it's a non-carbon mob, we don't care, get out of here and do normal thrown-into-mob stuff
 * * Else, if it's something dense (walls, machinery, structures, most things other than the floor), go to [/datum/component/tackler/proc/splat] and get ready for some high grade shit
 *
 * If it's a carbon we hit, we'll call rollTackle() which rolls a die and calculates modifiers for both the tackler and target, then gives us a number. Negatives favor the target, while positives favor the tackler.
 * Check [rollTackle()][/datum/component/tackler/proc/rollTackle] for a more thorough explanation on the modifiers at play.
 *
 * Then, we figure out what effect we want, and we get to work! Note that with standard gripper gloves and no modifiers, the range of rolls is (-3, 3). The results are as follows, based on what we rolled:
 * * -inf to -1: We have a negative roll result, which means something unfortunate or less than ideal happens to our sacker! Could mean just getting knocked down, but it could also mean they get a concussion. Ouch.
 * * 0: We get a relatively neutral result, mildly favouring the tackler.
 * * 1 to inf: We get a positive roll result, which means we get a reasonable to significant advantage against the target!
 *
 * Finally, we return a bitflag to [COMSIG_MOVABLE_IMPACT] that forces the hitpush to false so that we don't knock them away.
*/
/datum/component/tackler/proc/sack(mob/living/carbon/user, atom/hit)
	SIGNAL_HANDLER

	var/datum/thrownthing/tackle = tackle_ref?.resolve()
	if(!tackling || !tackle)
		tackle = null
		return

	user.toggle_throw_mode()
	if(!iscarbon(hit))
		if(hit.density)
			INVOKE_ASYNC(src, PROC_REF(splat), user, hit)
		return

	var/mob/living/carbon/human/target = hit
	var/tackle_word = iscatperson(user) ? "pounce" : "tackle" //If cat, "pounce" instead of "tackle".

	var/roll = rollTackle(target)
	tackling = FALSE
	tackle.force = MOVE_FORCE_WEAK

	if(target.check_shields(user, 0, user.name, attack_type = LEAP_ATTACK))
		user.visible_message("<span class='danger'>[user]'s tackle is blocked by [target], softening the effect!</span>",
							"<span class='userdanger'>Your tackle is blocked by [target], softening the effect!</span>", ignored_mobs = target)
		to_chat(target, "<span class='userdanger'>[target] blocks [user]'s tackle attempt, softening the effect!</span>")
		neutral_outcome(user, target, tackle_word) //Forces a neutral outcome so you're not screwed too much from being blocked while tackling
		return COMPONENT_MOVABLE_IMPACT_FLIP_HITPUSH

	switch(roll)
		if(-INFINITY to -1)
			negative_outcome(user, target, roll, tackle_word) //OOF

		if(0) //nothing good, nothing bad
			neutral_outcome(user, target, tackle_word)

		if(1 to INFINITY)
			positive_outcome(user, target, roll, tackle_word)

	return COMPONENT_MOVABLE_IMPACT_FLIP_HITPUSH

/// Helper to do a grab and then adjust the grab state if necessary
/datum/component/tackler/proc/do_grab(mob/living/carbon/tackler, mob/living/carbon/tackled, skip_to_state = GRAB_PASSIVE)
	set waitfor = FALSE

	if(!tackled.grabbedby(tackler, TRUE) || tackler.pulling != tackled)
		return
	if(tackler.grab_state != skip_to_state)
		tackler.setGrabState(skip_to_state)

/**
 * Our positive tackling outcomes.
 *
 * We pass our tackle result here to determine the potential outcome of the tackle. Typically, this results in a very poor state for the tackled, and a positive outcome for the tackler.
 *
 * First, we determine severity by taking our roll result, multiplying it by 10, and then rolling within that value.
 *
 * If our target is human, their armor will reduce the severity of the roll. We pass along any MELEE armor as a percentage reduction.
 * If they're not human (such as a carbon), we give them a small grace of a 10% reduction.
 *
 * Finally, we figure out what effect our target receives. Note that all positive outcomes inflict staggered, resulting in a much harder time escaping the potential grab:
 * * 1 to 20: Our target is briefly stunned and knocked down. suffers 30 stamina damage, and our tackler is also knocked down.
 * * 21 to 49: Our target is knocked down, dealt 40 stamina damage, and put into a passive grab. Given they are staggered, this means the target must resist to escape!
 * * 50 to inf: Our target is hit with a significant chunk of stamina damage, put into an aggressive grab, and knocked down. They're probably not escaping after this. If our tackler is stamcrit when they land this, so is our target.
*/

/datum/component/tackler/proc/positive_outcome(mob/living/carbon/user, mob/living/carbon/target, roll = 1, tackle_word = "tackle")
	var/potential_outcome = (roll * 10)

	if(ishuman(target))
		potential_outcome *= ((100 - target.run_armor_check(BODY_ZONE_CHEST, MELEE)) /100)
	else
		potential_outcome *= 0.9

	switch(potential_outcome)
		if(-INFINITY to 0) //I don't want to know how this has happened, okay?
			neutral_outcome(user, target, roll, tackle_word) //Default to neutral

		if(1 to 20)
			user.visible_message("<span class='warning'>[user] lands a solid [tackle_word] on [target], knocking them both down hard!</span>",
								"<span class='userdanger'>You land a solid [tackle_word] on [target], knocking you both down hard!</span>", ignored_mobs = target)
			to_chat(target, "<span class='userdanger'>[user] lands a solid [tackle_word] on you, knocking you both down hard!</span>")

			target.apply_damage(30, STAMINA)
			target.Paralyze(0.5 SECONDS)
			user.Knockdown(1 SECONDS)
			target.Knockdown(2 SECONDS)
			adjust_staggered_up_to(target, STAGGERED_SLOWDOWN_LENGTH * 2, 10 SECONDS)

		if(21 to 49) // really good hit, the target is definitely worse off here. Without positive modifiers, this is as good a tackle as you can land
			user.visible_message("<span class='warning'>[user] lands an expert [tackle_word] on [target], knocking [target.p_them()] down hard while landing on [user.p_their()] feet with a passive grip!</span>",
								"<span class='userdanger'>You land an expert [tackle_word] on [target], knocking [target.p_them()] down hard while landing on your feet with a passive grip!</span>", ignored_mobs = target)
			to_chat(target, "<span class='userdanger'>[user] lands an expert [tackle_word] on you, knocking you down hard and maintaining a passive grab!</span>")

			// Ignore_canstun has to be true, or else a stunimmune user would stay knocked down.
			user.SetKnockdown(0, ignore_canstun = TRUE)
			user.get_up(TRUE)
			user.forceMove(get_turf(target))
			target.apply_damage(40, STAMINA)
			target.Paralyze(0.5 SECONDS)
			target.Knockdown(3 SECONDS)
			adjust_staggered_up_to(target, STAGGERED_SLOWDOWN_LENGTH * 2, 10 SECONDS)
			do_grab(user, target)

		if(50 to INFINITY) // absolutely BODIED
			var/stamcritted_user = HAS_TRAIT_FROM(user, TRAIT_INCAPACITATED, STAMINA)
			if(stamcritted_user) // in case the user went into stamcrit from the tackle itself and cannot actually aggro grab (since they will be crit) we make the tackle effectivelly mutually assured...stamina crit
				user.visible_message("<span class='warning'>[user] lands a monsterly reckless [tackle_word] on [target], knocking both of them senseless!</span>",
									"<span class='userdanger'>You land a monsterly reckless [tackle_word] on [target], knocking both of you senseless!</span>", ignored_mobs = target)
				to_chat(target, "<span class='userdanger'>[user] lands a monsterly reckless [tackle_word] on you, knocking the both of you senseless!</span>")
				user.forceMove(get_turf(target))
				target.apply_damage(100, STAMINA) // CRASHING THIS PLANE WITH NO SURVIVORS
				target.Paralyze(1 SECONDS)
				target.Knockdown(5 SECONDS)
				adjust_staggered_up_to(target, STAGGERED_SLOWDOWN_LENGTH * 3, 10 SECONDS)
			else
				user.visible_message("<span class='warning'>[user] lands a monster [tackle_word] on [target], knocking [target.p_them()] senseless and applying an aggressive pin!</span>",
									"<span class='userdanger'>You land a monster [tackle_word] on [target], knocking [target.p_them()] senseless and applying an aggressive pin!</span>", ignored_mobs = target)
				to_chat(target, "<span class='userdanger'>[user] lands a monster [tackle_word] on you, knocking you senseless and aggressively pinning you!</span>")

				// Ignore_canstun has to be true, or else a stunimmune user would stay knocked down.
				user.SetKnockdown(0, ignore_canstun = TRUE)
				user.get_up(TRUE)
				user.forceMove(get_turf(target))
				target.apply_damage(60, STAMINA)
				target.Paralyze(0.5 SECONDS)
				target.Knockdown(3 SECONDS)
				adjust_staggered_up_to(target, STAGGERED_SLOWDOWN_LENGTH * 3, 10 SECONDS)
				do_grab(user, target, GRAB_AGGRESSIVE)

/**
 * Our neutral tackling outcome.
 *
 * Our tackler and our target are staggered. The target longer than the tackler. However, the tackler stands up after this outcome. This is maybe less neutral than it appears, but the tackler initiated, so...
 * This outcome also occurs when our target has blocked the tackle in some way, preventing situations where someone tackling into a blocker is too severely punished as a result. Hence, this has its own proc.
*/

/datum/component/tackler/proc/neutral_outcome(mob/living/carbon/user, mob/living/carbon/target, roll = 1, tackle_word = "tackle")


	user.visible_message("<span class='warning'>[user] lands a [tackle_word] on [target], briefly staggering them both!</span>",
						"<span class='userdanger'>You land a [tackle_word] on [target], briefly staggering [target.p_them()] and yourself!</span>", ignored_mobs = target)
	to_chat(target, "<span class='userdanger'>[user] lands a [tackle_word] on you, briefly staggering you both!</span>")

	user.SetKnockdown(0, ignore_canstun = TRUE)
	user.get_up(TRUE)
	adjust_staggered_up_to(user, STAGGERED_SLOWDOWN_LENGTH, 10 SECONDS)
	adjust_staggered_up_to(target, STAGGERED_SLOWDOWN_LENGTH * 2, 10 SECONDS) //okay maybe slightly good for the sacker, it's a mild benefit okay?

/**
 * Our negative tackling outcomes.
 *
 * We pass our tackle result here to determine the potential outcome of the tackle. Typically, this results in a very poor state for the tackler, and a mostly okay outcome for the tackled.
 *
 * First, we determine severity by taking our roll result, multiplying it by -10, and then rolling within that value.
 *
 * If our tackler is human, their armor will reduce the severity of the roll. We pass along any MELEE armor as a percentage reduction.
 * If they're not human (such as a carbon), we give them a small grace of a 10% reduction.
 *
 * Finally, we figure out what effect our target receives and what our tackler receives:
 * * 1 to 20: Our tackler is knocked down and become staggered, and our target suffers stamina damage and is knocked staggered. So not all bad, but the target most likely can punish you for this.
 * * 21 to 49: Our tackler is knocked down, suffers stamina damage, and is staggered. Ouch.
 * * 50 to inf: Our tackler suffers a catastrophic failure, receiving significant stamina damage, a concussion, and is paralyzed for 3 seconds. Oh, and they're staggered for a LONG time.
*/

/datum/component/tackler/proc/negative_outcome(mob/living/carbon/user, mob/living/carbon/target, roll = -1, tackle_word = "tackle")
	var/potential_roll_outcome = (roll * -10)

	if(ishuman(user))
		potential_roll_outcome *= ((100 - target.run_armor_check(BODY_ZONE_CHEST, MELEE)) /100)
	else
		potential_roll_outcome *= 0.9

	var/actual_roll = rand(1, potential_roll_outcome)

	switch(actual_roll)

		if(-INFINITY to 0) //I don't want to know how this has happened, okay?
			neutral_outcome(user, target, roll, tackle_word) //Default to neutral

		if(1 to 20) // It's not completely terrible! But you are somewhat vulernable for doing it.
			user.visible_message("<span class='warning'>[user] lands a weak [tackle_word] on [target], briefly staggering [target.p_them()]!</span>",
								"<span class='userdanger'>You land a weak [tackle_word] on [target], briefly staggering [target.p_them()]!</span>", ignored_mobs = target)
			to_chat(target, "<span class='userdanger'>[user] lands a weak [tackle_word] on you, staggering you!</span>")

			user.Knockdown(1 SECONDS)
			adjust_staggered_up_to(user, STAGGERED_SLOWDOWN_LENGTH * 2, 10 SECONDS)
			target.apply_damage(20, STAMINA)
			adjust_staggered_up_to(target, STAGGERED_SLOWDOWN_LENGTH * 2, 10 SECONDS)

		if(21 to 49) // oughe
			user.visible_message("<span class='warning'>[user] lands a dreadful [tackle_word] on [target], briefly knocking [user.p_them()] to the ground!</span>",
								"<span class='userdanger'>You land a dreadful [tackle_word] on [target], briefly knocking you to the ground!</span>", ignored_mobs = target)
			to_chat(target, "<span class='userdanger'>[user] lands a dreadful [tackle_word] on you, briefly knocking [user.p_them()] to the ground!</span>")

			user.Knockdown(3 SECONDS)
			user.apply_damage(40, STAMINA)
			adjust_staggered_up_to(user, STAGGERED_SLOWDOWN_LENGTH * 2, 10 SECONDS)

		if(50 to INFINITY) // It has been decided that you will suffer
			user.visible_message("<span class='danger'>[user] botches [user.p_their()] [tackle_word] and slams [user.p_their()] head into [target], knocking [user.p_them()]self silly!</span>",
								"<span class='userdanger'>You botch your [tackle_word] and slam your head into [target], knocking yourself silly!</span>", ignored_mobs = target)
			to_chat(target, "<span class='userdanger'>[user] botches [user.p_their()] [tackle_word] and slams [user.p_their()] head into you, knocking [user.p_them()]self silly!</span>")

			user.Paralyze(3 SECONDS)
			user.apply_damage(80, STAMINA)
			user.apply_damage(20, BRUTE, BODY_ZONE_HEAD)
			user.gain_trauma(/datum/brain_trauma/mild/concussion)
			adjust_staggered_up_to(user, STAGGERED_SLOWDOWN_LENGTH * 3, 10 SECONDS)

/**
 * This handles all of the modifiers for the actual carbon-on-carbon tackling, and gets its own proc because of how many there are (with plenty more in mind!)
 *
 * The base roll is between (-3, 3), with negative numbers favoring the target, and positive numbers favoring the tackler. The target and the tackler are both assessed for
 * how easy they are to knock over, with clumsiness and dwarfiness being strong maluses for each, and gigantism giving a bonus for each. These numbers and ideas
 * are absolutely subject to change.

 * In addition, after subtracting the defender's mod and adding the attacker's mod to the roll, the component's base (skill) mod is added as well. Some sources of tackles
 * are better at taking people down, like the bruiser and rocket gloves, while the dolphin gloves have a malus in exchange for better mobility.
*/
/datum/component/tackler/proc/rollTackle(mob/living/carbon/target)
	var/defense_mod = 0
	var/attack_mod = 0

	// DE-FENSE

	// Drunks are easier to knock off balance
	var/target_drunkenness = target.drunkenness
	if(target_drunkenness > 60)
		defense_mod -= 3
	else if(target_drunkenness > 30)
		defense_mod -= 1

	if(HAS_TRAIT(target, TRAIT_CLUMSY))
		defense_mod -= 2
	if(HAS_TRAIT(target, TRAIT_OFF_BALANCE_TACKLER)) // chonkers are harder to knock over
		defense_mod += 1
	if(HAS_TRAIT(target, TRAIT_GRABWEAKNESS))
		defense_mod -= 2

	if(HAS_TRAIT(target, TRAIT_GIANT))
		defense_mod += 2
	if(target.health < 50)
		defense_mod -= 1

	if(ishuman(target))
		var/mob/living/carbon/human/tackle_target = target

		if(tackle_target.dna.current_body_size <= BODY_SIZE_SHORT) //WHO ARE YOU CALLING SHORT?
			defense_mod -= 2

		if(isnull(tackle_target.wear_suit) && isnull(tackle_target.w_uniform)) // who honestly puts all of their effort into tackling a naked guy?
			defense_mod += 2
		if(tackle_target.mob_negates_gravity())
			defense_mod += 1
		if(tackle_target.is_shove_knockdown_blocked()) // riot armor and such
			defense_mod += 5

		var/obj/item/organ/tail/lizard/el_tail = tackle_target.getorganslot(ORGAN_SLOT_TAIL)
		if(HAS_TRAIT(tackle_target, TRAIT_TACKLING_TAILED_DEFENDER) && !el_tail)
			defense_mod -= 1
		if(el_tail && el_tail.is_wagging()) // lizard tail wagging is robust and can swat away assailants!
			defense_mod += 1

	// OF-FENSE
	var/mob/living/carbon/sacker = parent
	var/sacker_drunkenness = sacker.drunkenness

	if(sacker_drunkenness > 60) // you're far too drunk to hold back!
		attack_mod += 1
	else if(sacker_drunkenness > 30) // if you're only a bit drunk though, you're just sloppy
		attack_mod -= 1

	if(HAS_TRAIT(sacker, TRAIT_CLUMSY))
		attack_mod -= 2
	if(HAS_TRAIT(sacker, TRAIT_GIANT))
		attack_mod += 2
	if(HAS_TRAIT(sacker, TRAIT_NOGUNS)) //Those dedicated to martial combat are particularly skilled tacklers
		attack_mod += 2

	if(HAS_TRAIT(sacker, TRAIT_TACKLING_WINGED_ATTACKER))
		var/obj/item/organ/wings/moth/sacker_moth_wing = sacker.getorganslot(ORGAN_SLOT_WINGS)
		if(!sacker_moth_wing || HAS_TRAIT(sacker_moth_wing, TRAIT_MOTH_BURNT))
			attack_mod -= 2
	var/obj/item/organ/wings/sacker_wing = sacker.getorganslot(ORGAN_SLOT_WINGS)
	if(sacker_wing)
		attack_mod += 2


	if(ishuman(sacker))
		var/mob/living/carbon/human/human_sacker = sacker

		if(human_sacker.dna.current_body_size <= BODY_SIZE_SHORT) //JUST YOU WAIT TILL I FIND A CHAIR, BUDDY, THEN YOU'LL BE SORRY
			attack_mod -= 2
		var/datum/component/mood/human_sacker_sanity = human_sacker.GetComponent(/datum/component/mood)
		if(human_sacker_sanity.sanity == SANITY_INSANE) //I've gone COMPLETELY INSANE
			attack_mod += 15
			human_sacker.adjustStaminaLoss(100) //AHAHAHAHAHAHAHAHA

		if(human_sacker.is_shove_knockdown_blocked()) // tackling with riot specialized armor, like riot armor, is effective but tiring
			attack_mod += 2
			human_sacker.adjustStaminaLoss(20)

	var/randomized_tackle_roll = rand(-3, 3) - defense_mod + attack_mod + skill_mod
	return randomized_tackle_roll


/**
 * This is where we handle diving into dense atoms, generally with effects ranging from bad to REALLY bad. This works as a percentile roll that is modified in two steps as detailed below. The higher
 * the roll, the more severe the result.
 *
 * Mod 1: Speed-
 * * Base tackle speed is 1, which is what normal gripper gloves use. For other sources with higher speed tackles, like dolphin and ESPECIALLY rocket gloves, we obey Newton's laws and hit things harder.
 * * For every unit of speed above 1, move the lower bound of the roll up by 15. Unlike Mod 2, this only serves to raise the lower bound, so it can't be directly counteracted by anything you can control.
 *
 * Mod 2: Misc-
 * -Flat modifiers, these take whatever you rolled and add/subtract to it, with the end result capped between the minimum from Mod 1 and 100. Note that since we can't roll higher than 100 to start with,
 * wearing a helmet should be enough to remove any chance of permanently paralyzing yourself and dramatically lessen knocking yourself unconscious, even with rocket gloves. Will expand on maybe
 * * Wearing a helmet: -6
 * * Wearing riot armor: -6
 * * Clumsy: +6
 *
 * Effects: Below are the outcomes based off your roll, in order of increasing severity
 *
 * * 1-67: Knocked down for a few seconds and a bit of brute and stamina damage
 * * 68-85: Knocked silly, gain some confusion as well as the above
 * * 86-92: Cranial trauma, get a concussion and more confusion, plus more damage
 * * 93-96: Knocked unconscious, get a random mild brain trauma, as well as a fair amount of damage
 * * 97-98: Massive head damage, probably crack your skull open, random mild brain trauma
 * * 99-Infinity: Break your spinal cord, get paralyzed, take a bunch of damage too. Very unlucky!
*/
/datum/component/tackler/proc/splat(mob/living/carbon/user, atom/hit)
	if(istype(hit, /obj/machinery/vending)) // before we do anything else-
		var/obj/machinery/vending/darth_vendor = hit
		darth_vendor.tilt(user, 100)
		return
	else if(istype(hit, /obj/structure/window))
		var/obj/structure/window/W = hit
		splatWindow(user, W)
		if(QDELETED(W))
			return COMPONENT_MOVABLE_IMPACT_NEVERMIND
		return
	else if(istype(hit, /obj/machinery/disposal/bin))
		var/obj/machinery/disposal/bin/bin = hit
		user.forceMove(bin)
		var/leap_word = iscatperson(user) ? "pounce" : "leap" //If cat, "pounce" instead of "leap".
		user.visible_message("<span class='warning'>[user] [leap_word]s into \the [hit]!</span>",
							"<span class='danger'>You [leap_word] into \the [hit]!</span>")
		return COMPONENT_MOVABLE_IMPACT_NEVERMIND

	var/oopsie_mod = 0
	var/danger_zone = (speed - 1) * 13 // for every extra speed we have over 1, take away 13 of the safest chance
	danger_zone = max(min(danger_zone, 100), 1)

	if(user.is_shove_knockdown_blocked())
		oopsie_mod -= 6

	if(HAS_TRAIT(user, TRAIT_CLUMSY))
		oopsie_mod += 6 //honk!

	if(HAS_TRAIT(user, TRAIT_TACKLING_FRAIL_ATTACKER))
		oopsie_mod += 6 // flies don't take smacking into a window/wall easily

	var/oopsie = rand(danger_zone, 100)
	if(oopsie >= 94 && oopsie_mod < 0) // good job avoiding getting paralyzed! gold star!
		to_chat(user, "<span class='notice'>You're really glad you're wearing protection!</span>")
	oopsie += oopsie_mod

	switch(oopsie)
		if(99 to INFINITY)
			// can you imagine standing around minding your own business when all of the sudden some guy fucking launches himself into a wall at full speed and irreparably paralyzes himself?
			user.visible_message("<span class='danger'>[user] slams face-first into [hit] at an awkward angle, severing [user.p_their()] spinal column with a sickening crack! Fucking shit!</span>",
								"<span class='userdanger'>You slam face-first into [hit] at an awkward angle, severing your spinal column with a sickening crack! Fucking shit!</span>")
			user.apply_damage(40, BRUTE, BODY_ZONE_HEAD)
			user.apply_damage(30, STAMINA)
			playsound(user, 'sound/effects/blobattack.ogg', 60, TRUE)
			playsound(user, 'sound/effects/splat.ogg', 70, TRUE)
			user.emote("scream")
			user.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic) // oopsie indeed!
			shake_camera(user, 7, 7)
			user.flash_act(1, TRUE, TRUE)

		if(97 to 98)
			user.visible_message("<span class='danger'>[user] slams skull-first into [hit] with a sound like crumpled paper, revealing a horrifying breakage in [user.p_their()] cranium! Holy shit!</span>",
								"<span class='userdanger'>You slam skull-first into [hit] and your senses are filled with warm goo flooding across your face! Your skull is open!</span>")
			user.apply_damage(30, BRUTE, BODY_ZONE_HEAD)
			user.apply_damage(30, STAMINA)
			user.gain_trauma_type(BRAIN_TRAUMA_MILD)
			playsound(user, 'sound/effects/blobattack.ogg', 60, TRUE)
			playsound(user, 'sound/effects/splat.ogg', 70, TRUE)
			user.emote("gurgle")
			shake_camera(user, 7, 7)
			user.flash_act(1, TRUE, TRUE)

		if(93 to 96)
			user.visible_message("<span class='danger'>[user] slams face-first into [hit] with a concerning squish, immediately going limp!</span>",
								"<span class='userdanger'>You slam face-first into [hit], and immediately lose consciousness!</span>")
			user.apply_damage(30, BRUTE)
			user.apply_damage(30, STAMINA)
			user.Unconscious(10 SECONDS)
			user.gain_trauma_type(BRAIN_TRAUMA_MILD)
			user.playsound_local(get_turf(user), 'sound/weapons/flashbang.ogg', 100, TRUE, 8)
			shake_camera(user, 6, 6)
			user.flash_act(1, TRUE, TRUE)

		if(86 to 92)
			user.visible_message("<span class='danger'>[user] slams head-first into [hit], suffering major cranial trauma!</span>",
								"<span class='userdanger'>You slam head-first into [hit], and the world explodes around you!</span>")
			user.apply_damage(30, BRUTE)
			user.apply_damage(30, STAMINA)
			user.confused += 15
			if(prob(80))
				user.gain_trauma(/datum/brain_trauma/mild/concussion)
			user.playsound_local(get_turf(user), 'sound/weapons/flashbang.ogg', 100, TRUE, 8)
			user.Knockdown(4 SECONDS)
			shake_camera(user, 5, 5)
			user.flash_act(1, TRUE, TRUE)

		if(68 to 85)
			user.visible_message("<span class='danger'>[user] slams hard into [hit], knocking [user.p_them()] senseless!</span>",
								"<span class='userdanger'>You slam hard into [hit], knocking yourself senseless!</span>")
			user.apply_damage(10, BRUTE)
			user.apply_damage(30, STAMINA)
			user.confused += 10
			user.Knockdown(3 SECONDS)
			shake_camera(user, 3, 4)

		if(1 to 67)
			user.visible_message("<span class='danger'>[user] slams into [hit]!</span>",
								"<span class='userdanger'>You slam into [hit]!</span>")
			user.apply_damage(10, BRUTE)
			user.apply_damage(20, STAMINA)
			user.Knockdown(2 SECONDS)
			shake_camera(user, 2, 2)

	playsound(user, 'sound/weapons/smash.ogg', 70, TRUE)


/datum/component/tackler/proc/resetTackle()
	tackling = FALSE
	QDEL_NULL(tackle_ref)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

///A special case for splatting for handling windows
/datum/component/tackler/proc/splatWindow(mob/living/carbon/user, obj/structure/window/windscreen_casualty)
	playsound(user, 'sound/effects/glasshit.ogg', 140, TRUE)

	if(windscreen_casualty.type in list(/obj/structure/window, /obj/structure/window/fulltile, /obj/structure/window/unanchored, /obj/structure/window/fulltile/unanchored)) // boring unreinforced windows
		for(var/i in 1 to 2)
			var/obj/item/shard/shard = new /obj/item/shard(get_turf(user))
			shard.tryEmbed(user)
		var/glass_breaking_sound = pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg')
		playsound(user, glass_breaking_sound, 140, TRUE)
		qdel(windscreen_casualty)
		user.adjustStaminaLoss(10 * speed)
		user.Paralyze(3 SECONDS)
		user.visible_message("<span class='danger'>[user] smacks into [windscreen_casualty] and shatters it, shredding [user.p_them()]self with glass!</span>",
							"<span class='userdanger'>You smacks into [windscreen_casualty] and shatter it, shredding yourself with glass!</span>")

	else
		user.visible_message("<span class='danger'>[user] smacks into [windscreen_casualty] like a bug!</span>",
							"<span class='userdanger'>You smacks into [windscreen_casualty] like a bug!</span>")
		user.Paralyze(1 SECONDS)
		user.Knockdown(3 SECONDS)
		windscreen_casualty.take_damage(30 * speed)
		user.adjustStaminaLoss(10 * speed, updating_health=FALSE)
		user.adjustBruteLoss(5 * speed)

///Check to see if we hit a table, and if so, make a big mess!
/datum/component/tackler/proc/checkObstacle(mob/living/carbon/owner)
	SIGNAL_HANDLER

	if(!tackling)
		return

	var/turf/our_turf = get_turf(owner)
	var/obj/structure/table/kevved = locate(/obj/structure/table) in our_turf.contents
	if(!kevved)
		return

	var/list/messes = list()

	// we split the mess-making into two parts (check what we're gonna send flying, intermission for dealing with the tackler, then actually send stuff flying) for the benefit of making sure the face-slam text
	// comes before the list of stuff that goes flying, but can still adjust text + damage to how much of a mess it made
	for(var/obj/item/item_in_turf in our_turf.contents)
		if(!item_in_turf.anchored)
			messes += item_in_turf
			if(messes.len >= MAX_TABLE_MESSES)
				break

	// for telling HOW big of a mess we just made
	var/HOW_big_of_a_miss_did_we_just_make = ""
	if(messes.len)
		if(messes.len < MAX_TABLE_MESSES * 0.125)
			HOW_big_of_a_miss_did_we_just_make = ", making a mess"
		else if(messes.len < MAX_TABLE_MESSES * 0.25)
			HOW_big_of_a_miss_did_we_just_make = ", making a big mess"
		else if(messes.len < MAX_TABLE_MESSES * 0.5)
			HOW_big_of_a_miss_did_we_just_make = ", making a giant mess"
		else if(messes.len < MAX_TABLE_MESSES)
			HOW_big_of_a_miss_did_we_just_make = ", making a gnarly mess"
		else
			HOW_big_of_a_miss_did_we_just_make = ", making a ginormous mess!" // an extra exclamation point!! for emphasis!!!

	owner.visible_message("<span class='danger'>[owner] trips over [kevved] and slams into it face-first[HOW_big_of_a_miss_did_we_just_make]!</span>",
						"<span class='userdanger'>You trip over [kevved] and slam into it face-first[HOW_big_of_a_miss_did_we_just_make]!</span>")
	owner.adjustStaminaLoss(15 + messes.len * 2, updating_health = FALSE)
	owner.adjustBruteLoss(8 + messes.len, updating_health = FALSE)
	owner.Paralyze(0.4 SECONDS * messes.len) // .4 seconds of paralyze for each thing you knock around
	owner.Knockdown(2 SECONDS + 0.4 SECONDS * messes.len) // 2 seconds of knockdown after the paralyze
	owner.updatehealth()

	for(var/obj/item/item_in_mess in messes)
		// The amount of distance the object flies away when launched by our tackle
		var/item_launch_distance = rand(1, 3)
		// The transfered speed at which an item is launched by our tackle
		var/item_launch_speed = 2
		if(prob(25 * (src.speed - 1))) // if our tackle speed is higher than 1, with chance (speed - 1 * 25%), throw the thing at our tackle speed + 1
			item_launch_speed = speed + 1
		item_in_mess.throw_at(get_ranged_target_turf(item_in_mess, pick(GLOB.alldirs), range = item_launch_distance), range = item_launch_distance, speed = item_launch_speed)
		item_in_mess.visible_message("<span class='danger'>[item_in_mess] goes flying[item_launch_speed < EMBED_THROWSPEED_THRESHOLD ? "" : " dangerously fast" ]!</span>") // standard embed speed

	var/datum/thrownthing/tackle = tackle_ref?.resolve()

	playsound(owner, 'sound/weapons/smash.ogg', 70, TRUE)
	if(tackle)
		tackle.finalize(hit=TRUE)
	resetTackle()

#undef MAX_TABLE_MESSES
