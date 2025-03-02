/**
  * Get the organ object from the mob matching the passed in typepath
  *
  * Arguments:
  * * typepath The typepath of the organ to get
  */
/mob/proc/getorgan(typepath)
	return
/**
  * Get organ objects by zone
  *
  * This will return a list of all the organs that are relevant to the zone that is passedin
  *
  * Arguments:
  * * zone [a BODY_ZONE_X define](https://github.com/tgstation/tgstation/blob/master/code/__DEFINES/combat.dm#L187-L200)
  */
/mob/proc/getorganszone(zone)
	return
/**
  * Get an organ relating to a specific slot
  *
  * Arguments:
  * * slot Slot to get the organ from
  */
/mob/proc/getorganslot(slot)
	return

/mob/living/carbon/getorgan(typepath)
	return (locate(typepath) in internal_organs)

/mob/living/carbon/getorganszone(zone)
	var/list/returnorg = list()
	var/obj/item/bodypart/bodypart = get_bodypart(check_zone(zone))
	if (!bodypart)
		return returnorg
	for(var/slot in bodypart.organ_slots)
		var/obj/item/organ/O = getorganslot(slot)
		if(O)
			returnorg += O
	return returnorg

/mob/living/carbon/getorganslot(slot)
	return internal_organs_slot[slot]
