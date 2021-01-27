/*				COMMAND OBJECTIVES				*/

/datum/objective/crew/caphat //Ported from Goon
	explanation_text = "Don't lose your hat."
	jobs = "captain"

/datum/objective/crew/caphat/check_completion()
	if(owner && owner.current && owner.current.check_contents_for(/obj/item/clothing/head/caphat))
		return TRUE
	else
		return FALSE

/datum/objective/crew/datfukkendisk //Ported from old Hippie
	explanation_text = "Defend the nuclear authentication disk at all costs, and be the one to personally deliver it to CentCom."
	jobs = "captain" //give this to other heads at your own risk.

/datum/objective/crew/datfukkendisk/check_completion()
	if(owner?.current && owner.current.check_contents_for(/obj/item/disk/nuclear) && SSshuttle.emergency.shuttle_areas[get_area(owner.current)])
		return TRUE
	else
		return FALSE

/datum/objective/crew/downwiththestation
	explanation_text = "Go down with your station. Do not leave on the shuttle or an escape pod. Instead, stay on the bridge."
	jobs = "captain"

/datum/objective/crew/downwiththestation/check_completion()
	if(owner?.current)
		if(istype(get_area(owner.current), /area/bridge))
			return TRUE
	return FALSE

/datum/objective/crew/ian //Ported from old Hippie
	explanation_text = "Defend Ian at all costs, and ensure he gets delivered to CentCom at the end of the shift."
	jobs = "headofpersonnel"

/datum/objective/crew/ian/check_completion()
	if(owner?.current)
		for(var/mob/living/simple_animal/pet/dog/corgi/Ian/goodboy in GLOB.mob_list)
			if(goodboy.stat != DEAD && SSshuttle.emergency.shuttle_areas[get_area(goodboy)])
				return TRUE
		return FALSE
	return FALSE
