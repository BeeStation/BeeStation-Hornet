/datum/martial_art/krav_maga
	name = "Krav Maga"
	id = MARTIALART_KRAVMAGA
	var/datum/action/neck_chop/neckchop = new/datum/action/neck_chop()
	var/datum/action/leg_sweep/legsweep = new/datum/action/leg_sweep()
	var/datum/action/lung_punch/lungpunch = new/datum/action/lung_punch()
	bypass_blocking = FALSE

/datum/action/neck_chop
	name = "Neck Chop - Injures the neck, stopping the victim from speaking for a while."
	button_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "neckchop"
	check_flags = AB_CHECK_INCAPACITATED

/datum/action/neck_chop/on_activate(mob/user, atom/target)
	if(owner.incapacitated)
		to_chat(owner, span_warning("You can't use [name] while you're incapacitated."))
		return
	if (owner.mind.martial_art.streak == "neck_chop")
		owner.visible_message(span_danger("[owner] assumes a neutral stance."), "<b><i>Your next attack is cleared.</i></b>")
		owner.mind.martial_art.streak = ""
	else
		owner.visible_message(span_danger("[owner] assumes the Neck Chop stance!"), "<b><i>Your next attack will be a Neck Chop.</i></b>")
		owner.mind.martial_art.streak = "neck_chop"

/datum/action/leg_sweep
	name = "Leg Sweep - Trips the victim, knocking them down for a brief moment."
	button_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "legsweep"
	check_flags = AB_CHECK_INCAPACITATED

/datum/action/leg_sweep/on_activate()
	if(owner.incapacitated)
		to_chat(owner, span_warning("You can't use [name] while you're incapacitated."))
		return
	if (owner.mind.martial_art.streak == "leg_sweep")
		owner.visible_message(span_danger("[owner] assumes a neutral stance."), "<b><i>Your next attack is cleared.</i></b>")
		owner.mind.martial_art.streak = ""
	else
		owner.visible_message(span_danger("[owner] assumes the Leg Sweep stance!"), "<b><i>Your next attack will be a Leg Sweep.</i></b>")
		owner.mind.martial_art.streak = "leg_sweep"

/datum/action/lung_punch//referred to internally as 'quick choke'
	name = "Lung Punch - Delivers a strong punch just above the victim's abdomen, constraining the lungs. The victim will be unable to breathe for a short time."
	button_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "lungpunch"
	check_flags = AB_CHECK_INCAPACITATED

/datum/action/lung_punch/on_activate()
	if(owner.incapacitated)
		to_chat(owner, span_warning("You can't use [name] while you're incapacitated."))
		return
	if (owner.mind.martial_art.streak == "quick_choke")
		owner.visible_message(span_danger("[owner] assumes a neutral stance."), "<b><i>Your next attack is cleared.</i></b>")
		owner.mind.martial_art.streak = ""
	else
		owner.visible_message(span_danger("[owner] assumes the Lung Punch stance!"), "<b><i>Your next attack will be a Lung Punch.</i></b>")
		owner.mind.martial_art.streak = "quick_choke"//internal name for lung punch

/datum/martial_art/krav_maga/teach(mob/living/owner, make_temporary=FALSE)
	if(..())
		to_chat(owner, span_userdanger("You know the arts of [name]!"))
		to_chat(owner, span_danger("Place your cursor over a move at the top of the screen to see what it does."))
		neckchop.Grant(owner)
		legsweep.Grant(owner)
		lungpunch.Grant(owner)

/datum/martial_art/krav_maga/on_remove(mob/living/owner)
	to_chat(owner, span_userdanger("You suddenly forget the arts of [name]..."))
	neckchop.Remove(owner)
	legsweep.Remove(owner)
	lungpunch.Remove(owner)

/datum/martial_art/krav_maga/proc/check_streak(mob/living/A, mob/living/D)
	switch(streak)
		if("neck_chop")
			streak = ""
			neck_chop(A,D)
			return 1
		if("leg_sweep")
			streak = ""
			leg_sweep(A,D)
			return 1
		if("quick_choke")//is actually lung punch
			streak = ""
			quick_choke(A,D)
			return 1
	return 0

/datum/martial_art/krav_maga/proc/leg_sweep(mob/living/A, mob/living/D)
	if(D.stat || D.IsParalyzed())
		return 0
	var/obj/item/bodypart/affecting = D.get_bodypart(BODY_ZONE_CHEST)
	var/armor_block = D.run_armor_check(affecting, MELEE)
	D.visible_message(span_warning("[A] leg sweeps [D]!"), \
					span_userdanger("Your legs are sweeped by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, A)
	to_chat(A, span_danger("You leg sweep [D]!"))
	playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	D.apply_damage(rand(20,30), STAMINA, affecting, armor_block)
	D.Knockdown(60)
	log_combat(A, D, "leg sweeped", name)
	return TRUE

/datum/martial_art/krav_maga/proc/quick_choke(mob/living/A, mob/living/D)//is actually lung punch
	D.visible_message(span_warning("[A] pounds [D] on the chest!"), \
					span_userdanger("Your chest is slammed by [A]! You can't breathe!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
	to_chat(A, span_danger("You pound [D] on the chest!"))
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	if(D.losebreath <= 10)
		D.losebreath = clamp(D.losebreath + 5, 0, 10)
	D.adjustOxyLoss(10)
	log_combat(A, D, "quickchoked", name)
	return TRUE

/datum/martial_art/krav_maga/proc/neck_chop(mob/living/A, mob/living/D)
	D.visible_message(span_warning("[A] karate chops [D]'s neck!"), \
					span_userdanger("Your neck is karate chopped by [A], rendering you unable to speak!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
	to_chat(A, span_danger("You karate chop [D]'s neck, rendering [D.p_them()] unable to speak!"))
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.apply_damage(5, A.get_attack_type())
	D.adjust_silence_up_to(20 SECONDS, 20 SECONDS)
	log_combat(A, D, "neck chopped", name)
	return TRUE

/datum/martial_art/krav_maga/grab_act(mob/living/A, mob/living/D)
	if(check_streak(A,D))
		return TRUE
	log_combat(A, D, "grabbed (Krav Maga)", name)
	..()

/datum/martial_art/krav_maga/harm_act(mob/living/A, mob/living/D)
	if(check_streak(A,D))
		return TRUE
	var/obj/item/bodypart/affecting = D.get_bodypart(D.get_random_valid_zone(A.get_combat_bodyzone(D)))
	var/armor_block = D.run_armor_check(affecting, MELEE)
	var/picked_hit_type = pick("punch", "kick")
	var/bonus_damage = 0
	if(D.body_position == LYING_DOWN)
		bonus_damage += 5
		picked_hit_type = "stomp"
	D.apply_damage(rand(5,10) + bonus_damage, A.get_attack_type(), affecting, armor_block)
	if(picked_hit_type == "kick" || picked_hit_type == "stomp")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		playsound(get_turf(D), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	else
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		playsound(get_turf(D), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.visible_message(span_danger("[A] [picked_hit_type]s [D]!"), \
					span_userdanger("You're [picked_hit_type]ed by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
	to_chat(A, span_danger("You [picked_hit_type] [D]!"))
	log_combat(A, D, "[picked_hit_type] with [name]", name)
	return 1

/datum/martial_art/krav_maga/disarm_act(mob/living/A, mob/living/D)
	if(check_streak(A,D))
		return 1
	var/obj/item/bodypart/affecting = D.get_bodypart(D.get_random_valid_zone(A.get_combat_bodyzone(D)))
	var/armor_block = D.run_armor_check(affecting, MELEE)
	if(D.body_position == STANDING_UP)
		D.visible_message(span_danger("[A] reprimands [D]!"), \
					span_userdanger("You're slapped by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
		to_chat(A, span_danger("You jab [D]!"))
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		playsound(D, 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
		D.apply_damage(rand(5,10), STAMINA, affecting, armor_block)
		log_combat(A, D, "punched nonlethally", name)
	if(D.body_position == LYING_DOWN)
		D.visible_message(span_danger("[A] reprimands [D]!"), \
					span_userdanger("You're manhandled by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, A)
		to_chat(A, span_danger("You stomp [D]!"))
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		playsound(D, 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
		D.apply_damage(rand(10,15), STAMINA, affecting, armor_block)
		log_combat(A, D, "stomped nonlethally", name)
	if(prob(D.getStaminaLoss()))
		D.visible_message(span_warning("[D] sputters and recoils in pain!"), span_userdanger("You recoil in pain as you are jabbed in a nerve!"))
		D.drop_all_held_items()
	return 1

//Krav Maga Gloves

/obj/item/clothing/gloves/krav_maga
	name = "krav maga gloves"
	desc = "These gloves can teach you to perform Krav Maga using nanochips."
	icon_state = "fightgloves"
	inhand_icon_state = "fightgloves"
	worn_icon_state = "fightgloves"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	var/datum/martial_art/krav_maga/style = new

/obj/item/clothing/gloves/krav_maga/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_GLOVES)
		style.teach(user, TRUE)

/obj/item/clothing/gloves/krav_maga/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		style.remove(user)

/obj/item/clothing/gloves/krav_maga/combatglovesplus
	name = "combat gloves plus"
	desc = "These tactical gloves are fireproof and shock resistant, and using nanochip technology it teaches you the powers of krav maga."
	icon_state = "cgloves"
	inhand_icon_state = "combatgloves"
	worn_icon_state = "combatgloves"
	siemens_coefficient = 0
	strip_delay = 80
	armor_type = /datum/armor/krav_maga_combatglovesplus

/datum/armor/krav_maga_combatglovesplus
	bio = 90
	fire = 80
	acid = 50
