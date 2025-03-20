/datum/martial_art/krav_maga
	name = "Krav Maga"
	id = MARTIALART_KRAVMAGA
	var/datum/action/krav_maga/neck_chop/neckchop = new/datum/action/krav_maga/neck_chop()
	var/datum/action/krav_maga/leg_sweep/legsweep = new/datum/action/krav_maga/leg_sweep()
	var/datum/action/krav_maga/martial_strikes/martial_strikes = new/datum/action/krav_maga/martial_strikes()

/datum/action/krav_maga
	icon_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "martialstrike" //if I don't define something here it fails lint.
	check_flags = AB_CHECK_INCAPACITATED

/datum/action/krav_maga/on_activate(mob/user, atom/target)
	if(owner.incapacitated())
		to_chat(owner, span_warning("You can't use [name] while you're incapacitated."))
		return

/datum/action/krav_maga/neck_chop
	name = "Neck Chop"
	desc = "Stops the victim from being able to speak for a short while"
	button_icon_state = "neckchop"

/datum/action/krav_maga/neck_chop/on_activate(mob/user, atom/target)
	..()
	if (owner.mind.martial_art.streak == "neck_chop")
		owner.visible_message(span_danger("[owner] assumes a neutral stance."), "<b><i>Your next attack will be normal.</i></b>")
		owner.mind.martial_art.streak = ""
	else
		owner.visible_message(span_danger("[owner] assumes the Neck Chop stance!"), "<b><i>Your next attack will be a Neck Chop.</i></b>")
		owner.mind.martial_art.streak = "neck_chop"

/datum/action/krav_maga/leg_sweep
	name = "Leg Sweep"
	desc = "Trips the victim, knocking them down for a short while"
	button_icon_state = "legsweep"

/datum/action/krav_maga/leg_sweep/on_activate()
	..()
	if (owner.mind.martial_art.streak == "leg_sweep")
		owner.visible_message(span_danger("[owner] assumes a neutral stance."), "<b><i>Your next attack will be normal.</i></b>")
		owner.mind.martial_art.streak = ""
	else
		owner.visible_message(span_danger("[owner] assumes the Leg Sweep stance!"), "<b><i>Your next attack will be a Leg Sweep.</i></b>")
		owner.mind.martial_art.streak = "leg_sweep"

/datum/action/krav_maga/martial_strikes
	name = "Martial Strikes"
	desc = "Assume a stance that allows repeated strikes which will fatigue your enemy while doing less long-term harm."
	button_icon_state = "martialstrike" //This is where the icon is actually intended


/datum/action/krav_maga/martial_strikes/on_activate()
	..()
	if (owner.mind.martial_art.streak == "martial_strikes")
		owner.visible_message(span_danger("[owner] assumes a neutral stance."), "<b><i>Your next attack will be normal.</i></b>")
		owner.mind.martial_art.streak = ""
	else
		owner.visible_message(span_danger("[owner] assumes the Martial Strikes stance!"), "<b><i>Your unarmed strikes will inflict additional fatigue.</i></b>")
		owner.mind.martial_art.streak = "martial_strikes"

/datum/martial_art/krav_maga/teach(mob/living/owner, make_temporary=FALSE)
	if(..())
		to_chat(owner, span_userdanger("You know the arts of [name]!"))
		to_chat(owner, span_danger("Place your cursor over a move at the top of the screen to see what it does."))
		neckchop.Grant(owner)
		legsweep.Grant(owner)
		martial_strikes.Grant(owner)

/datum/martial_art/krav_maga/on_remove(mob/living/owner)
	to_chat(owner, span_userdanger("You suddenly forget the arts of [name]..."))
	neckchop.Remove(owner)
	legsweep.Remove(owner)
	martial_strikes.Remove(owner)

/datum/martial_art/krav_maga/proc/check_streak(mob/living/user, mob/living/target)
	switch(streak)
		if("neck_chop")
			streak = ""
			return neck_chop(user,target)
		if("leg_sweep")
			streak = ""
			return leg_sweep(user,target)
		if("martial_strikes")
			//This one does not reset streak, it can be used consecutively on purpose
			return martial_strikes(user,target)
	return FALSE

/datum/martial_art/krav_maga/proc/leg_sweep(mob/living/user, mob/living/target)
	if(target.stat || target.IsParalyzed() || target.IsKnockdown())
		return FALSE
	var/obj/item/bodypart/affecting = target.get_bodypart(BODY_ZONE_CHEST)
	var/armor_block = target.run_armor_check(affecting, MELEE)
	target.visible_message(span_warning("[user] leg sweeps [target]!"), \
					span_userdanger("Your legs are sweeped by [user]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, user)
	to_chat(user, span_danger("You leg sweep [target]!"))
	playsound(get_turf(user), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	target.apply_damage(rand(15,25), STAMINA, affecting, armor_block)
	target.Knockdown(4 SECONDS)
	log_combat(user, target, "leg sweeped", name)
	return TRUE

/datum/martial_art/krav_maga/proc/neck_chop(mob/living/user, mob/living/target)
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/carbon_defender = target
	target.visible_message(span_warning("[user] karate chops [target]'s neck!"), \
					span_userdanger("Your neck is karate chopped by [user], rendering you unable to speak!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_danger("You karate chop [target]'s neck, rendering [target.p_them()] unable to speak!"))
	playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	target.apply_damage(5, user.get_attack_type())
	log_combat(user, target, "neck chopped", name)
	carbon_defender.silent = 10 //10 life() ticks without the ability to speak
	return TRUE


/datum/martial_art/krav_maga/proc/martial_strikes(mob/living/user, mob/living/target)
	if(!iscarbon(target))
		return FALSE

	//I don't really know what I'm describing myself tbh, but it does less damage and more stamina so I went with this

	var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(user.get_combat_bodyzone(target)))
	var/limb_armor = target.run_armor_check(affecting, MELEE)

	//Minor damage, high stamina for an unarmed strike but still not great. This is intended as a "better than nothing" if officer is disarmed.
	target.apply_damage(2, user.get_attack_type(), affecting, limb_armor)
	target.apply_damage(17, STAMINA, affecting, limb_armor)

	target.visible_message(span_warning("[user] deftly strikes at [target] in the [affecting.plaintext_zone] with an open palm!"), \
					span_userdanger("[user] attacks you in the [affecting.plaintext_zone] with an open palm!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_danger("You strike at [target] in the [affecting.plaintext_zone] with an open palm!"))
	playsound(get_turf(user), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	return TRUE

/datum/martial_art/krav_maga/harm_act(mob/living/user, mob/living/target)
	if(check_streak(user,target))
		return TRUE

/datum/martial_art/krav_maga/disarm_act(mob/living/user, mob/living/target)
	if(check_streak(user,target))
		return TRUE

//Krav Maga Gloves
/obj/item/clothing/gloves/krav_maga/
	name = "krav maga gloves"
	desc = "These gloves can teach you to perform Krav Maga using nanochips. This variety has a commanding red design"
	icon_state = "fightgloves"
	item_state = "fightgloves"
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
	item_state = "combatgloves"
	worn_icon_state = "combatgloves"
	siemens_coefficient = 0
	strip_delay = 80
	armor_type = /datum/armor/krav_maga_combatglovesplus

/datum/armor/krav_maga_combatglovesplus
	bio = 90
	fire = 80
	acid = 50
