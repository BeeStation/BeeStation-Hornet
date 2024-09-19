/datum/action/cooldown/spell/conjure/invisible_wall
	name = "Invisible Wall"
	desc = "The mime's performance transmutates a wall into physical reality."
	background_icon_state = "bg_mime"
	icon_icon = 'icons/mob/actions/actions_mime.dmi'
	button_icon_state = "invisible_wall"
	panel = "Mime"
	sound = null

	school = SCHOOL_MIME
	cooldown_time = 30 SECONDS
	invocation = "Someone does a weird gesture." // Overriden in before cast
	invocation_self_message = span_notice("You form a wall in front of yourself.")
	invocation_type = INVOCATION_EMOTE

	spell_requirements = SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_MIME_VOW
	antimagic_flags = NONE
	spell_max_level = 1

	summon_radius = 0
	summon_type = list(/obj/effect/forcefield/mime)
	summon_lifespan = 30 SECONDS

/datum/action/cooldown/spell/conjure/invisible_wall/before_cast(atom/cast_on)
	. = ..()
	invocation = span_notice("<b>[cast_on]</b> looks as if a wall is in front of [cast_on.p_them()].")
