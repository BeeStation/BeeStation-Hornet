
/datum/gang_territory
	var/area/territory
	var/gang_tags = 0

/datum/gang_territory/Destroy()
	area = null
	return ..()

/datum/gang_territory/proc/register_area(var/area/A)
	territory = A
	RegisterSignal(A, COMSIG_PARENT_QDELETING, PROC_REF(handle_area_deleted))

/datum/gang_territory/proc/handle_area_deleted()
	SIGNAL_HANDLER
	territory = null
	CRASH("Area belonging to a gang territory got deleted")

/datum/team/gang/proc/add_territory(var/area/A)
	var/datum/gang_territory/T = new
	T.register_area(A)
	territories += T
