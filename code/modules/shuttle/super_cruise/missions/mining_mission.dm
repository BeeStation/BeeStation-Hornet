
/datum/mission/mining
	name = "Mining Expedition (Crilium)"
	description = "A deposit of the extremely rare and valuable Crilium has been detected. Recover a sample of the Crilium in order to verify its existance."
	payment = 3000

/datum/mission/mining/generate()
	return new /datum/orbital_object/z_linked/beacon/asteroid/crilium

/datum/mission/mining/is_possible()
	return TRUE
