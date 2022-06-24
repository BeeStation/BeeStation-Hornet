/datum/round_event_control/new_space_law
	name = "New Space Law"
	typepath = /datum/round_event/new_space_law
	max_occurrences = 1
	weight = 15

/datum/round_event/new_space_law
	announceWhen = 1
	fakeable = FALSE

var/list/new_space_laws = world.file2list("monkestation/strings/new_space_laws.txt")

/datum/round_event/new_space_law/announce(fake)
	priority_announce("Due to recent events in space politics [pick(new_space_laws)] now 1xx illegal under space law.")
