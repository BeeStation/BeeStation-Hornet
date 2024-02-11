#define JOB_MODIFICATION_MAP_NAME "Echo Station" //sorry but i'm bring back the pubby config file

//do not spawn
MAP_REMOVE_JOB(atmospheric_technician)
MAP_REMOVE_JOB(bartender)
MAP_REMOVE_JOB(brig_physician)
MAP_REMOVE_JOB(exploration_crew)
MAP_REMOVE_JOB(geneticist)
MAP_REMOVE_JOB(paramedic)
MAP_REMOVE_JOB(virologist)

//only one position
/datum/job/cook/New()
	..()
	MAP_JOB_CHECK
	spawn_positions = 1
	total_positions = 1
/datum/job/chemist/New()
	..()
	MAP_JOB_CHECK
	spawn_positions = 1
	total_positions = 1
/datum/job/janitor/New()
	..()
	MAP_JOB_CHECK
	spawn_positions = 1
	total_positions = 1
/datum/job/lawyer/New()
	..()
	MAP_JOB_CHECK
	spawn_positions = 1
	total_positions = 1
/datum/job/botanist/New()
	..()
	MAP_JOB_CHECK
	spawn_positions = 1
	total_positions = 1

#undef JOB_MODIFICATION_MAP_NAME
