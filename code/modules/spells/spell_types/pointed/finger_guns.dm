/datum/action/spell/pointed/projectile/finger_guns
	name = "Finger Guns"
	desc = "Shoot up to three mimed bullets from your fingers that damage and mute their targets. \
		Can't be used if you have something in your hands."
	background_icon_state = "bg_mime"
	button_icon = 'icons/hud/actions/actions_mime.dmi'
	button_icon_state = "finger_guns0"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED
	sound = null

	school = SCHOOL_MIME
	cooldown_time = 30 SECONDS

	invocation = ""
	invocation_type = INVOCATION_EMOTE
	invocation_self_message = ("<span class='danger'>You fire your finger gun!</span>")

	spell_requirements = SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_MIME_VOW
	antimagic_flags = NONE
	spell_max_level = 1

	base_icon_state = "finger_guns"
	active_msg = "You draw your fingers!"
	deactive_msg = "You put your fingers at ease. Another time."
	cast_range = 20
	projectile_type = /obj/projectile/bullet/mime
	projectile_amount = 3

/datum/action/spell/pointed/projectile/finger_guns/try_invoke(feedback = TRUE)
	if(invocation_type == INVOCATION_EMOTE)
		if(!ishuman(owner))
			return FALSE

		var/mob/living/carbon/human/human_owner = owner
		if(human_owner.incapacitated)
			if(feedback)
				to_chat(owner, ("<span class='warning'>You can't properly point your fingers while incapacitated.</span>"))
			return FALSE
		if(human_owner.get_active_held_item())
			if(feedback)
				to_chat(owner, ("<span class='warning'>You can't properly fire your finger guns with something in your hand.</span>"))
			return FALSE

	return ..()

/datum/action/spell/pointed/projectile/finger_guns/pre_cast(mob/user, atom/target)
	. = ..()
	invocation = "<span class='notice'><b>[user]</b> fires [user.p_their()] finger gun!</span>"
