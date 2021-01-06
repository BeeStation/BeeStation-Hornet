/datum/surgery/advanced/bioware
	name = "enhancement surgery"
	var/bioware_target = BIOWARE_GENERIC

/datum/surgery/advanced/bioware/can_start(mob/user, mob/living/carbon/human/target)
	if(!..())
		return EF_FALSE
	if(!istype(target))
		return EF_FALSE
	for(var/X in target.bioware)
		var/datum/bioware/B = X
		if(B.mod_type == bioware_target)
			return EF_FALSE
	return EF_TRUE
