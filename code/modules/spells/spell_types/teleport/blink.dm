/datum/action/spell/teleport/radius_turf/blink
	name = "Blink"
	desc = "This spell randomly teleports you a short distance."
	button_icon_state = "blink"
	sound = 'sound/magic/blink.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 2 SECONDS
	cooldown_reduction_per_rank = 0.4 SECONDS

	invocation_type = INVOCATION_NONE

	smoke_type = /obj/effect/particle_effect/smoke
	smoke_amt = 0

	inner_tele_radius = 0
	outer_tele_radius = 6

	post_teleport_sound = 'sound/magic/blink.ogg'
