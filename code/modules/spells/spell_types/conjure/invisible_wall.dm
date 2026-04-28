/datum/action/spell/conjure/invisible_wall
	name = "Invisible Wall"
	desc = "The mime's performance transmutates a wall into physical reality."
	background_icon_state = "bg_mime"
	button_icon = 'icons/hud/actions/actions_mime.dmi'
	button_icon_state = "invisible_wall"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED
	sound = null

	school = SCHOOL_MIME
	cooldown_time = 30 SECONDS
	invocation = "Someone does a weird gesture." // Overriden in before cast
	invocation_self_message = ("<span class='notice'>You form a wall in front of yourself.</span>")
	invocation_type = INVOCATION_EMOTE

	spell_requirements = SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_MIME_VOW
	antimagic_flags = NONE
	spell_max_level = 1

	summon_radius = 0
	summon_type = list(/obj/effect/forcefield/mime)
	summon_lifespan = 30 SECONDS

/datum/action/spell/conjure/invisible_wall/pre_cast(mob/user, atom/target)
	. = ..()
	invocation = "<span class='notice'><b>[user]</b> looks as if a wall is in front of [user.p_them()].</span>"
