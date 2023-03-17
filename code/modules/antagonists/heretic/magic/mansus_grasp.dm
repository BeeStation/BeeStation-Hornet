/obj/effect/proc_holder/spell/targeted/touch/mansus_grasp
	name = "Mansus Grasp"
	desc = "A touch spell that lets you channel the power of the Old Gods through your grip."
	hand_path = /obj/item/melee/touch_attack/mansus_fist
	charge_max = 100
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_grasp"
	action_background_icon_state = "bg_ecult"

/obj/item/melee/touch_attack/mansus_fist
	name = "Mansus Grasp"
	desc = "A sinister looking aura that distorts the flow of reality around it. Causes knockdown and major stamina damage in addition to some brute. It gains additional beneficial effects as you expand your knowledge of the Mansus."
	icon_state = "mansus_grasp"
	item_state = "mansus_grasp"
	catchphrase = "R'CH T'H TR'TH!"
	on_use_sound = 'sound/items/welder.ogg'

/obj/item/melee/touch_attack/mansus_fist/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You remove %THEEFFECT.", \
		on_clear_callback = CALLBACK(src, PROC_REF(after_clear_rune)), \
		effects_we_clear = list(/obj/effect/heretic_rune))

/*
 * Callback for effect_remover component.
 */
/obj/item/melee/touch_attack/mansus_fist/proc/after_clear_rune(obj/effect/target, mob/living/user)
	use_charge(user, whisper = TRUE)

/obj/item/melee/touch_attack/mansus_fist/ignition_effect(atom/to_light, mob/user)
	. = "<span class='notice'>[user] effortlessly snaps [user.p_their()] fingers near [to_light], igniting it with eldritch energies. Fucking badass!</span>"
	use_charge(user)

/obj/item/melee/touch_attack/mansus_fist/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag || !IS_HERETIC(user) || target == user)
		return
	if(ishuman(target) && antimagic_check(target, user))
		return ..()

	if(isliving(target))
		if(on_mob_hit(target, user))
			return
	else
		if(SEND_SIGNAL(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, target))
			use_charge(user)
		return

	return ..()

/**
 * Checks if the [target] has some form of anti-magic.
 *
 * Returns TRUE If the attack was blocked. FALSE otherwise.
 */
/obj/item/melee/touch_attack/mansus_fist/proc/antimagic_check(mob/living/carbon/human/target, mob/living/carbon/user)
	if(target.anti_magic_check())
		target.visible_message(
			"<span class='danger'>The spell bounces off of [target]!</span>",
			"<span class='danger'>The spell bounces off of you!</span>",
		)
		return TRUE
	return FALSE

/**
 * Called with [hit] is successfully hit by a mansus grasp by [heretic].
 *
 * Sends signal COMSIG_HERETIC_MANSUS_GRASP_ATTACK.
 * If it returns COMPONENT_BLOCK_CHARGE_USE, the proc returns FALSE.
 * Otherwise, returns TRUE.
 */
/obj/item/melee/touch_attack/mansus_fist/proc/on_mob_hit(mob/living/hit, mob/living/heretic)
	if(SEND_SIGNAL(heretic, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, hit) & COMPONENT_BLOCK_CHARGE_USE)
		return FALSE

	hit.adjustBruteLoss(10)
	if(iscarbon(hit))
		var/mob/living/carbon/carbon_hit = hit
		carbon_hit.AdjustKnockdown(5 SECONDS)
		carbon_hit.adjustStaminaLoss(80)
		carbon_hit.adjustBruteLoss(10)
		carbon_hit.silent = 3 SECONDS

	use_charge(heretic)

	return TRUE

/obj/item/melee/touch_attack/mansus_fist/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] covers [user.p_their()] face with [user.p_their()] sickly-looking hand! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	var/mob/living/carbon/carbon_user = user //iscarbon already used in spell's parent
	if(!IS_HERETIC(user))
		return

	var/escape_our_torment = 0
	while(carbon_user.stat == CONSCIOUS)
		if(QDELETED(src) || QDELETED(user))
			return SHAME
		if(escape_our_torment > 20) //Stops us from infinitely stunning ourselves if we're just not taking the damage
			return FIRELOSS

		if(prob(70))
			carbon_user.adjustFireLoss(20)
			playsound(carbon_user, 'sound/items/welder.ogg', 70, vary = TRUE)
			if(prob(50))
				carbon_user.emote("scream")
				carbon_user.stuttering += 13

		on_mob_hit(user, user)

		escape_our_torment++
		stoplag(0.4 SECONDS)
	return FIRELOSS
