/datum/action/spell/pointed/blood_siphon
	name = "Blood Siphon"
	desc = "A touch spell that heals your wounds while damaging the enemy. \
		It has a chance to transfer wounds between you and your enemy."
	background_icon_state = "bg_heretic"
	button_icon = 'icons/hud/actions/actions_ecult.dmi'
	button_icon_state = "blood_siphon"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation = "FL'MS O'ET'RN'ITY."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 9

/datum/action/spell/pointed/blood_siphon/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)

/datum/action/spell/pointed/blood_siphon/is_valid_spell(mob/user, atom/target)
	return ..() && isliving(target)

/datum/action/spell/pointed/blood_siphon/on_cast(mob/living/user, mob/living/target)
	. = ..()
	playsound(owner, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	if(target.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY))
		owner.balloon_alert(owner, "spell blocked!")
		target.visible_message(
			span_danger("The spell bounces off of [target]!"),
			span_danger("The spell bounces off of you!"),
		)
		return FALSE

	target.visible_message(
		span_danger("[target] turns pale as a red glow envelops [target.p_them()]!"),
		span_danger("You turn pale as a red glow enevelops you!"),
	)

	var/mob/living/living_owner = owner
	target.adjustBruteLoss(20)
	living_owner.adjustBruteLoss(-20)

	if(!target.blood_volume || !living_owner.blood_volume)
		return TRUE

	target.blood_volume -= 20
	if(living_owner.blood_volume < BLOOD_VOLUME_MAXIMUM) // we dont want to explode from casting
		living_owner.blood_volume += 20

	if(!iscarbon(target) || !iscarbon(owner))
		return TRUE
/* Missing wounds for this bit of code to work
	var/mob/living/carbon/carbon_target = cast_on
	var/mob/living/carbon/carbon_user = owner
	for(var/obj/item/bodypart/bodypart as anything in carbon_user.bodyparts)
		for(var/datum/wound/iter_wound as anything in bodypart.wounds)
			if(prob(50))
				continue
			var/obj/item/bodypart/target_bodypart = locate(bodypart.type) in carbon_target.bodyparts
			if(!target_bodypart)
				continue
			iter_wound.remove_wound()
			iter_wound.apply_wound(target_bodypart)
*/
	return TRUE
