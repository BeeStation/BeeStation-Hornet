/datum/martial_art/boxing
	name = "Boxing"
	id = MARTIALART_BOXING
	pacifist_style = TRUE

/datum/martial_art/boxing/disarm_act(mob/living/A, mob/living/D)
	to_chat(A, span_warning("Can't disarm while boxing!"))
	return TRUE

/datum/martial_art/boxing/grab_act(mob/living/A, mob/living/D)
	to_chat(A, span_warning("Can't grab while boxing!"))
	return TRUE

/datum/martial_art/boxing/harm_act(mob/living/A, mob/living/D)

	var/mob/living/carbon/human/attacker_human = A
	var/datum/species/species = attacker_human.dna.species

	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	var/atk_verb = pick("left hook","right hook","straight punch")

	var/damage = 6 +species.punchdamage
	if(!damage)
		playsound(D.loc, species.miss_sound, 25, TRUE, -1)
		D.visible_message(span_warning("[A]'s [atk_verb] misses [D]!"), \
			span_userdanger("[A]'s [atk_verb] misses you!"), null, COMBAT_MESSAGE_RANGE)
		log_combat(A, D, "attempted to hit", atk_verb, important = FALSE)
		return FALSE


	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.get_combat_bodyzone(D)))
	var/armor_block = D.run_armor_check(affecting, MELEE)

	playsound(D.loc, species.attack_sound, 25, TRUE, -1)

	D.visible_message(span_danger("[A] [atk_verb]ed [D]!"), \
			span_userdanger("[A] [atk_verb]ed you!"), null, COMBAT_MESSAGE_RANGE)

	D.apply_damage(damage, STAMINA, affecting, armor_block)
	log_combat(A, D, "punched (boxing) ", name)
	if(D.getStaminaLoss() > 50 && istype(D.mind?.martial_art, /datum/martial_art/boxing))
		var/knockout_prob = D.getStaminaLoss() + rand(-15,15)
		if((D.stat != DEAD) && prob(knockout_prob))
			D.visible_message(span_danger("[A] knocks [D] out with a haymaker!"), \
							span_userdanger("You're knocked unconscious by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
			to_chat(A, span_danger("You knock [D] out with a haymaker!"))
			D.apply_effect(200,EFFECT_KNOCKDOWN,armor_block)
			D.SetSleeping(100)
			log_combat(A, D, "knocked out (boxing) ", name)
	return TRUE

/datum/martial_art/boxing/can_use(mob/living/owner)
	if (!ishuman(owner))
		return FALSE
	return ..()

/obj/item/clothing/gloves/boxing
	var/datum/martial_art/boxing/style = new

/obj/item/clothing/gloves/boxing/equipped(mob/user, slot)
	..()
	// boxing requires human
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_GLOVES)
		var/mob/living/student = user
		style.teach(student, 1)
	return

/obj/item/clothing/gloves/boxing/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/owner = user
	style.remove(owner)
	return
