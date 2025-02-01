/// The wizard's teleport SPELL
/datum/action/spell/teleport/area_teleport/wizard
	name = "Teleport"
	desc = "This spell teleports you to an area of your selection."
	button_icon_state = "teleport"
	sound = 'sound/magic/teleport_diss.ogg'

	school = SCHOOL_TRANSLOCATION
	cooldown_time = 1 MINUTES
	cooldown_reduction_per_rank = 10 SECONDS
	spell_requirements = NONE
	invocation = "SCYAR NILA"
	invocation_type = INVOCATION_SHOUT

	smoke_type = /obj/effect/particle_effect/smoke
	smoke_amt = 2

	post_teleport_sound = 'sound/magic/teleport_app.ogg'

// Santa's teleport, themed as such
/datum/action/spell/teleport/area_teleport/wizard/santa
	name = "Santa Teleport"

	invocation = "HO HO HO!"
	antimagic_flags = NONE

	invocation_says_area = FALSE // Santa moves in mysterious ways

/// Used by the wizard's teleport scroll
/datum/action/spell/teleport/area_teleport/wizard/scroll
	name = "Teleport (scroll)"
	cooldown_time = 0 SECONDS

	invocation = null
	invocation_type = INVOCATION_NONE
	teleport_mode = TELEPORT_ALLOW_WIZARD
	invocation_says_area = FALSE

/datum/action/spell/teleport/area_teleport/wizard/scroll/is_available()
	return ..() && owner.is_holding(master)

/datum/action/spell/teleport/area_teleport/wizard/scroll/pre_cast(mob/user, atom/target)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	var/mob/living/carbon/caster = user
	if(caster.incapacitated() || !caster.is_holding(master))
		return . | SPELL_CANCEL_CAST
