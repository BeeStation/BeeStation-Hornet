/*				COMMAND OBJECTIVES				*/

/datum/objective/crew/caphat //Ported from Goon
	explanation_text = "Don't lose your hat."
	jobs = JOB_NAME_CAPTAIN

/datum/objective/crew/caphat/check_completion()
	return ..() || owner?.current?.check_contents_for(/obj/item/clothing/head/hats/caphat)

/datum/objective/crew/datfukkendisk //Ported from old Hippie
	explanation_text = "Defend the nuclear authentication disk at all costs, and be the one to personally deliver it to CentCom."
	jobs = JOB_NAME_CAPTAIN //give this to other heads at your own risk.

/datum/objective/crew/datfukkendisk/check_completion()
	return ..() || (owner.current.check_contents_for(/obj/item/disk/nuclear) && SSshuttle.emergency.shuttle_areas[get_area(owner.current)])

/datum/objective/crew/downwiththestation
	explanation_text = "Go down with your station. Do not leave on the shuttle or an escape pod. Instead, stay on the bridge."
	jobs = JOB_NAME_CAPTAIN

/datum/objective/crew/downwiththestation/check_completion()
	return ..() || (owner?.current && istype(get_area(owner.current), /area/bridge))

/datum/objective/crew/ian //Ported from old Hippie
	explanation_text = "Defend Ian at all costs, and ensure he gets delivered to CentCom at the end of the shift."
	jobs = JOB_NAME_HEADOFPERSONNEL

/datum/objective/crew/ian/check_completion()
	if(..())
		return TRUE
	if(!owner?.current)
		return FALSE
	for(var/mob/living/basic/pet/dog/corgi/ian/goodboy in GLOB.mob_list)
		if(goodboy.stat != DEAD && SSshuttle.emergency.shuttle_areas[get_area(goodboy)])
			return TRUE
	return FALSE
