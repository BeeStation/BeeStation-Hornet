/datum/ruin_decorator
	var/decorator_weight = 0

/datum/ruin_decorator/proc/decorate(datum/map_generator/space_ruin/thing_to_decorate)
	CRASH("Attempting to run a ruin decorator that has not been implemented of type [type].")

/datum/ruin_decorator/nothing
	decorator_weight = 100

/datum/ruin_decorator/nothing/decorate(datum/map_generator/space_ruin/thing_to_decorate)
	return
