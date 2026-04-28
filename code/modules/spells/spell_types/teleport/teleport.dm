/// The wizard's teleport SPELL
/datum/action/spell/teleport/area_teleport/wizard
	name = "Teleport"
	desc = "This spell teleports you to an area of your selection."
	button_icon_state = "teleport"
	sound = 'sound/magic/teleport_diss.ogg'

	school = SCHOOL_TRANSLOCATION
	cooldown_time = 30 SECONDS
	spell_requirements = NONE
	invocation = "SCYAR NILA"
	invocation_type = INVOCATION_SHOUT
	teleport_mode = TELEPORT_ALLOW_WIZARD

	smoke_type = /obj/effect/particle_effect/smoke
	smoke_amt = 2

	post_teleport_sound = 'sound/magic/teleport_app.ogg'

// Santa's teleport, themed as such
/datum/action/spell/teleport/area_teleport/wizard/santa
	name = "Santa Teleport"

	invocation = "HO HO HO!"
	antimagic_flags = NONE

	invocation_says_area = FALSE // Santa moves in mysterious ways

/datum/action/spell/teleport/area_teleport/wizard/apprentice
	name = "Lesser Teleport"
	desc = "This spell teleports you to an area of your selection, but you aren't as good as your master yet so it takes longer to gather your magic for each cast."
	cooldown_time = 60 SECONDS
