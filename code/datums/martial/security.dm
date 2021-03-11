/datum/martial_art/security_cqc
	name = "Security CQC"
	id = MARTIALART_SECURITY //ID, used by mind/has_martialart
	var/datum/action/forceful_disarm/forcefuldisarm = new/datum/action/forceful_disarm()
	var/datum/action/pressure_point_strike/pressurepointstrike = new/datum/action/pressure_point_strike()

/datum/action/forceful_disarm
	name = "Forceful Disarm - removes items from targets hands, and causes you to do a backstep"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "ForcefulDisarm"

/datum/action/forceful_disarm/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't use [name] while you're incapacitated.</span>")
		return
	var/mob/living/carbon/human/H = owner
	if (H.mind.martial_art.streak == "forceful_disarm")
		owner.visible_message("<span class='danger'>[owner] assumes a neutral stance.</span>", "<b><i>Your next attack is cleared.</i></b>")
		H.mind.martial_art.streak = ""
	else
		owner.visible_message("<span class='danger'>[owner] assumes the Forceful Disarm stance!</span>", "<b><i>Your next attack will be a Forceful Disarm.</i></b>")
		H.mind.martial_art.streak = "forceful_disarm"

/datum/action/pressure_point_strike
	name = "Pressure Point Strike - Deals stamina damage to a targeted limb"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "PressurePoint"

/datum/action/pressure_point_strike/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't use [name] while you're incapacitated.</span>")
		return
	var/mob/living/carbon/human/H = owner
	if (H.mind.martial_art.streak == "pressure_point_strike")
		owner.visible_message("<span class='danger'>[owner] assumes a neutral stance.</span>", "<b><i>Your next attack is cleared.</i></b>")
		H.mind.martial_art.streak = ""
	else
		owner.visible_message("<span class='danger'>[owner] assumes the Pressure Point stance!</span>", "<b><i>Your next attack will be a Pressure Point Strike.</i></b>")
		H.mind.martial_art.streak = "pressure_point_strike"


/datum/martial_art/security_cqc/teach(mob/living/carbon/human/H, make_temporary=0)
	if(..())
		to_chat(H, "<span class = 'userdanger'>You know the arts of [name]!</span>")
		to_chat(H, "<span class = 'danger'>Place your cursor over a move at the top of the screen to see what it does.</span>")
		forcefuldisarm.Grant(H)
		pressurepointstrike.Grant(H)

/datum/martial_art/security_cqc/on_remove(mob/living/carbon/human/H)
	to_chat(H, "<span class = 'userdanger'>You suddenly forget the arts of [name]...</span>")
	forcefuldisarm.Remove(H)
	pressurepointstrike.Remove(H)

/datum/martial_art/security_cqc/proc/check_streak(mob/living/carbon/human/U, mob/living/carbon/human/T)
	switch(streak)
		if("forceful_disarm")
			forceful_disarm(U, T)
			streak = ""
			return 1
		if("pressure_point_strike")
			pressure_point_strike(U, T)
			streak = ""
			return 1
	return 0

/datum/martial_art/security_cqc/proc/forceful_disarm(mob/living/carbon/human/U, mob/living/carbon/human/T)//User is U, target is T
	T.visible_message("<span class = 'warning'>[U] attempts to forcefully disarm [T]!</span>", "<span class = 'userdanger'>[U] attempts to forcefully disarm you!", null, COMBAT_MESSAGE_RANGE)
	playsound(get_turf(U), 'sound/effects/grillehit.ogg', 50, 1, -1)
	var/obj/item/bodypart/affecting = T.get_bodypart(ran_zone(U.zone_selected))
	if(affecting == l_arm || r_arm)
		if(!H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))//Are they blocking?
			if(U.targetedZone == l_arm)
				var/obj/item/targetedItem = T.HAND_LEFT
				T.dropItemToGround(activeItem)
				var/disarmDir = get_dir(U, T)
				var/turf/throwAt = get_ranged_target_turf(activeItem, disarmDir, 2)
				activeItem.throw_at(throwAt, 7, 1)
				log_combat(U, T, "Forceful Disarm")
			else
				var/obj/item/targetedItem = T.HAND_RIGHT
				T.dropItemToGround(activeItem)
				var/disarmDir = get_dir(U, T)
				var/turf/throwAt = get_ranged_target_turf(activeItem, disarmDir, 2)
				activeItem.throw_at(throwAt, 7, 1)
				log_combat(U, T, "Forceful Disarm")

/datum/martial_art/security_cqc/proc/pressure_point_strike(mob/living/carbon/human/U, mob/living/carbon/human/T)
	var/obj/item/bodypart/targetedZone = T.get_bodypart(ran_zone(U.zone_selected))
	var/armorBlock = T.run_armor_check(targetedZone, "melee")
	T.visible_message("<span class = 'warning'>[U] hits you with a pressure point strike [T]!</span>", \
	 "<span class = 'userdanger'>[U] hits a pressure point on your [targetedZone]!", null, COMBAT_MESSAGE_RANGE)
	playsound(get_turf(U), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	T.apply_damage(1, BRUTE, targetedZone, armorBlock)
	T.apply_damage(20, STAMINA, targetedZone, armorBlock)
	log_combat(U, T, "Pressure Point")

/datum/martial_art/security_cqc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	log_combat(A, D, "grabbed (Security CQC)")
	..()

/datum/martial_art/security_cqc/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")
	var/picked_hit_type = pick("punched", "kicked")
	var/bonus_damage = 0
	if(!(D.mobility_flags & MOBILITY_STAND))
		bonus_damage += 5
		picked_hit_type = "stomped"
	D.apply_damage(5 + bonus_damage, STAMINA, affecting, armor_block)
	if(picked_hit_type == "kicked" || picked_hit_type == "stomped")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		playsound(get_turf(D), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	else
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		playsound(get_turf(D), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] [picked_hit_type] you!</span>", null, COMBAT_MESSAGE_RANGE)
	log_combat(A, D, "[picked_hit_type] with [name]")
	return 1

/datum/martial_art/security_cqc/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	log_combat(A, D, "shoved (Security CQC)" )
	..()
