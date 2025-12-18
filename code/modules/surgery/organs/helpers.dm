/**
  * Get the organ object from the mob matching the passed in typepath
  *
  * Arguments:
  * * typepath The typepath of the organ to get
  */
/mob/proc/get_organ_by_type(typepath)
	return
/**
  * Get organ objects by zone
  *
  * This will return a list of all the organs that are relevant to the zone that is passedin
  *
  * Arguments:
  * * zone [a BODY_ZONE_X define](https://github.com/tgstation/tgstation/blob/master/code/__DEFINES/combat.dm#L187-L200)
  */
/mob/proc/get_organs_for_zone(zone)
	return

/**
  * Get an organ relating to a specific slot
  *
  * Arguments:
  * * slot Slot to get the organ from
  */
/mob/proc/get_organ_slot(slot)
	return

/mob/living/carbon/get_organ_by_type(typepath)
	return (locate(typepath) in internal_organs/* + external_organs*/)

/mob/living/carbon/get_organs_for_zone(zone, include_children = FALSE)
	var/valid_organs = list()

	for(var/obj/item/organ/organ as anything in internal_organs/* + external_organs*/)
		if(zone == organ.zone)
			valid_organs += organ
		else if(include_children && zone == deprecise_zone(organ.zone))
			valid_organs += organ
	return valid_organs

/mob/living/carbon/get_organ_slot(slot)
	return internal_organs_slot[slot]
