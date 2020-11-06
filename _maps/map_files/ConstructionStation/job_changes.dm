#define JOB_MODIFICATION_MAP_NAME "Construction Station"

/datum/job/engineer/New()
	..()
	MAP_JOB_CHECK
	total_positions = -1
	spawn_positions = -1

/datum/job/officer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2

//Command
MAP_REMOVE_JOB(hos)
MAP_REMOVE_JOB(hop)
MAP_REMOVE_JOB(chief_engineer)
MAP_REMOVE_JOB(rd)
MAP_REMOVE_JOB(cmo)
//Engineering
MAP_REMOVE_JOB(atmos)
//Science
MAP_REMOVE_JOB(scientist)
MAP_REMOVE_JOB(roboticist)
MAP_REMOVE_JOB(geneticist)//that's right, science job :sunglasses:
//Medical
MAP_REMOVE_JOB(doctor)
MAP_REMOVE_JOB(virologist)
MAP_REMOVE_JOB(chemist)
MAP_REMOVE_JOB(emt)
MAP_REMOVE_JOB(brig_phys)
//Cargo
MAP_REMOVE_JOB(qm)
MAP_REMOVE_JOB(cargo_tech)
MAP_REMOVE_JOB(mining)
//Service
MAP_REMOVE_JOB(bartender)
MAP_REMOVE_JOB(hydro)
MAP_REMOVE_JOB(cook)
MAP_REMOVE_JOB(janitor)
MAP_REMOVE_JOB(curator)
MAP_REMOVE_JOB(lawyer)
MAP_REMOVE_JOB(chaplain)
MAP_REMOVE_JOB(clown)
MAP_REMOVE_JOB(mime)
MAP_REMOVE_JOB(assistant)
MAP_REMOVE_JOB(gimmick)
//Security
MAP_REMOVE_JOB(warden)
MAP_REMOVE_JOB(detective)
MAP_REMOVE_JOB(deputy)
//Silicon
MAP_REMOVE_JOB(ai)
MAP_REMOVE_JOB(cyborg)

#undef JOB_MODIFICATION_MAP_NAME
