
/mob/living/simple_animal/slime/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	if(!forced)
		burn_damage_stored += abs(amount)
		amount = -abs(amount)
	return ..() //Heals them

/mob/living/simple_animal/slime/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	powerlevel = 0 // oh no, the power!

/mob/living/simple_animal/slime/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		attacked_stacks += 10

/mob/living/simple_animal/slime/attack_paw(mob/living/carbon/monkey/M)
	if(..()) //successful monkey bite.
		attacked_stacks += 10

/mob/living/simple_animal/slime/attack_larva(mob/living/carbon/alien/larva/L, list/modifiers)
	if(..()) //successful larva bite.
		attacked_stacks += 10

/mob/living/simple_animal/slime/attack_hulk(mob/living/carbon/human/user)
	discipline_slime(user)
	return ..()

/mob/living/simple_animal/slime/attack_hand(mob/living/carbon/human/M, modifiers)
	if(buckled)
		M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
		if(bucklestrength >= 0)
			M.visible_message(span_warning("[M] attempts to wrestle \the [name] off!"), \
				span_danger("You attempt to wrestle \the [name] off!"))
			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			bucklestrength --

		else
			M.visible_message(span_warning("[M] manages to wrestle \the [name] off!"), \
				span_notice("You manage to wrestle \the [name] off!"))
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

			discipline_slime(M)
	else
		if(stat == DEAD && surgeries.len)
			if(!M.combat_mode || LAZYACCESS(modifiers, RIGHT_CLICK))
				for(var/datum/surgery/operations as anything in surgeries)
					if(operations.next_step(M, modifiers))
						return TRUE
		if(..()) //successful attack
			attacked_stacks += 10

/mob/living/simple_animal/slime/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent.
		attacked_stacks += 10
		discipline_slime(M)

/mob/living/simple_animal/slime/attackby(obj/item/W, mob/living/user, list/modifiers)
	if(stat == DEAD && surgeries.len)
		if(!user.combat_mode || (LAZYACCESS(modifiers, RIGHT_CLICK)))
			for(var/datum/surgery/operations as anything in surgeries)
				if(operations.next_step(user, modifiers))
					return 1
	if(istype(W, /obj/item/stack/sheet/mineral/plasma) && !stat) //Let's you feed slimes plasma.
		add_friendship(user, 1)
		to_chat(user, span_notice("You feed the slime the plasma. It chirps happily."))
		var/obj/item/stack/sheet/mineral/plasma/S = W
		S.use(1)
		return
	if(istype(W, /obj/item/organ/regenerative_core) && !stat && slime_type.colour == SLIME_TYPE_PINK)
		to_chat(user, span_warning("The slime absorbs the regenerative core, pink darkening to an ominous grey"))
		special_mutation = TRUE
		special_mutation_type = SLIME_TYPE_DARK_GREY
		var/obj/item/organ/regenerative_core/R = W
		qdel(R)
		return
	if(W.force > 0)
		attacked_stacks += 10
		if(prob(25))
			user.do_attack_animation(src)
			user.changeNext_move(CLICK_CD_MELEE)
			to_chat(user, span_danger("[W] passes right through [src]!"))
			return
		if(discipline_stacks && prob(50)) // wow, buddy, why am I getting attacked??
			discipline_stacks = 0
	if(W.force >= 3)
		var/force_effect = 2 * W.force
		if(life_stage == SLIME_LIFE_STAGE_ADULT)
			force_effect = round(W.force/2)
		if(prob(10 + force_effect))
			discipline_slime(user)
	if(!istype(W, /obj/item/storage/bag/bio))
		return ..()

	var/obj/item/storage/xeno_bag = W
	if(!crossbreed_modification)
		to_chat(user, span_warning("The slime is not currently being mutated."))
		return
	var/has_output = FALSE //Have we outputted text?
	var/has_found = FALSE //Have we found an extract to be added?
	for(var/obj/item/slime_extract/extract in xeno_bag.contents)
		if(extract.crossbreed_modification == crossbreed_modification)
			xeno_bag.atom_storage.attempt_remove(extract, get_turf(src), silent = TRUE)
			qdel(extract)
			applied_crossbreed_amount++
			has_found = TRUE
		if(applied_crossbreed_amount >= SLIME_EXTRACT_CROSSING_REQUIRED)
			to_chat(user, span_notice("You feed the slime as many of the extracts from the bag as you can, and it mutates!"))
			playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)
			spawn_corecross(user)
			has_output = TRUE
			break

	if(has_output)
		return

	if(!has_found)
		to_chat(user, span_warning("There are no extracts in the bag that this slime will accept!"))
	else
		to_chat(user, span_notice("You feed the slime some extracts from the bag."))
		playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)
