/*				SECURITY OBJECTIVES				*/

/datum/objective/crew/enjoyyourstay
	explanation_text = "Welcome aboard. Enjoy your stay."
	jobs = "headofsecurity,securityofficer,warden,detective"
	var/list/edglines = list("Welcome aboard. Enjoy your stay.", "You signed up for this.", "Abandon hope.", "The tide's gonna stop eventually.", "Hey, someone's gotta do it.", "No, you can't resign.", "Security is a mission, not an intermission.")

/datum/objective/crew/enjoyyourstay/New()
	. = ..()
	update_explanation_text()

/datum/objective/crew/enjoyyourstay/update_explanation_text()
	. = ..()
	explanation_text = "Enforce Space Law to the best of your ability, and survive. [pick(edglines)]"

/datum/objective/crew/enjoyyourstay/check_completion()
	if(owner?.current)
		if(owner.current.stat != DEAD)
			return TRUE
	return FALSE

/datum/objective/crew/nomanleftbehind
	explanation_text = "Ensure no prisoners are left in the brig when the shift ends."
	jobs = "warden,securityofficer"

/datum/objective/crew/nomanleftbehind/check_completion()
	for(var/mob/living/carbon/M in GLOB.alive_mob_list)
		if(!M.mind)
			continue
		if(!(M.mind.assigned_role in GLOB.security_positions) && istype(get_area(M), /area/security/prison)) //there's no list of incarcerated players, so we just assume any non-security people in prison are prisoners, and assume that any security people aren't prisoners
			return FALSE
	return TRUE

/datum/objective/crew/justicemed
	explanation_text = "Ensure there are no dead bodies in the security wing when the shift ends."
	jobs = "brigphysician"

/datum/objective/crew/justicemed/check_completion()
	var/list/security_areas = typecacheof(list(/area/security, /area/security/brig, /area/security/main, /area/security/prison, /area/security/processing))
	for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
		var/area/A = get_area(H)
		if(H.stat == DEAD && is_station_level(H.z) && is_type_in_typecache(A, security_areas)) // If person is dead and corpse is in one of these areas
			return FALSE
	return TRUE
