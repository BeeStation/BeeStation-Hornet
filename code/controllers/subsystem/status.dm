SUBSYSTEM_DEF(status)
	name = "Atom Status"

	var/list/atom_list = list()
	var/list/status_datum

/datum/controller/subsystem/status/Initialize(timeofday)
	if(!status_datum)
		status_datum = subtypesof(/datum/status_datum)


/datum/controller/subsystem/status/fire(timeofday)



#define STATUS_TARGET_MOB (1<<0)
#define STATUS_TARGET_OBJ (1<<1)
#define STATUS_TARGET_ATOM (STATUS_TARGET_MOB + STATUS_TARGET_OBJ)
/datum/status_datum
	var/name = "default datum"
	var/key = "default datum"
	var/target = NONE
	var/time_maximum = 0 // 0 = maximum

	var/apply_text = "You feel something."
	var/removal_text = "You feel no longer something."

/datum/status_datum/proc/
