/datum/surgery/advanced/bioware
	name = "enhancement surgery"
	var/bioware_target = BIOWARE_GENERIC

/datum/surgery/advanced/bioware/can_start(mob/user, mob/living/carbon/human/target)
	if(!..())
		return FALSE
	if(!istype(target))
		return FALSE
	for(var/datum/bioware/bioware as anything in target.biowares)
		if(bioware.mod_type == bioware_target)
			return FALSE
	return TRUE
