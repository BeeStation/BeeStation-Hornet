/datum/action/spell/timestop
	name = "Stop Time"
	desc = "This spell stops time for everyone except for you, \
		allowing you to move freely while your enemies and even projectiles are frozen."
	button_icon_state = "time"

	school = SCHOOL_FORBIDDEN // Fucking with time is not appreciated by anyone
	cooldown_time = 50 SECONDS
	cooldown_reduction_per_rank = 10 SECONDS

	invocation = "TOKI YO TOMARE!"
	invocation_type = INVOCATION_SHOUT

	/// The radius / range of the time stop.
	var/timestop_range = 2
	/// The duration of the time stop.
	var/timestop_duration = 10 SECONDS

/datum/action/spell/timestop/Grant(mob/grant_to)
	. = ..()
	if(owner)
		ADD_TRAIT(owner, TRAIT_TIME_STOP_IMMUNE, REF(src))

/datum/action/spell/timestop/Remove(mob/remove_from)
	REMOVE_TRAIT(remove_from, TRAIT_TIME_STOP_IMMUNE, REF(src))
	return ..()

/datum/action/spell/timestop/on_cast(mob/user, atom/target)
	. = ..()
	new /obj/effect/timestop(get_turf(user), timestop_range, timestop_duration, list(user))
