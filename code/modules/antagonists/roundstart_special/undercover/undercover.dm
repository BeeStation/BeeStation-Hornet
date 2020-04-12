////////////////////////////////
////// Special Role Datum///////
////////////////////////////////

/datum/special_role/undercover
	probability = 100//65			//The probability of any spawning at all
	proportion = 1//0.05			//The prbability per person of rolling it (5% is (5 in 100) (1 in 20))
	max_amount = 4				//The maximum amount
	role_name = "Undercover Agent"
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Head of Personnel", "Chief Medical Officer", "Chief Engineer", "Research Director", "Captain", "Brig Physician", "Clown")
	attached_antag_datum = /datum/antagonist/special/undercover

////////////////////////////////
//////  Antagonist Datum ///////
////////////////////////////////

/datum/antagonist/special/undercover
	name = "Ex-security agent"
	roundend_category = "Special Roles"
	antag_moodlet = /datum/mood_event/determined

/datum/antagonist/special/undercover/greet()
	to_chat(owner, "<span class='userdanger'>You are an ex-security agent.</span>")
	to_chat(owner, "<b>Due to your loyality to nanotrasen in the past, you have been granted with a weapon permit.</b>")
	to_chat(owner, "<b>Additionally nanotrasen has authorised you to have a disabler for personal defense.</b>")
	to_chat(owner, "<b>You are not a member of security, and shouldn't hunt criminals, but may use your weapon for self defense.</b>")
	to_chat(owner, "<span class='boldannounce'>Do NOT commit traitorous acts in persuit of your objectives.</span>")

/datum/antagonist/special/undercover/admin_add(datum/mind/new_owner, mob/admin)
	. = ..()
	var/mob/living/carbon/C = new_owner.current
	if(!istype(C))
		to_chat(admin, "You can only turn carbons into an ex-security agent.")
		return
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into an ex-security agent.")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")

/datum/antagonist/special/undercover/forge_objectives()
	var/datum/objective/saveshuttle/chosen_objective = new
	chosen_objective.generate_people_goal()
	objectives += chosen_objective
	owner.announce_objectives()

/datum/antagonist/special/undercover/equip()
	if(!owner)
		return

	var/mob/living/carbon/H = owner.current
	if(!ishuman(H) && !ismonkey(H))
		return

	var/obj/item/gun/energy/disabler/T = new(H)
	var/obj/item/restraints/handcuffs/cable/zipties/T2 = new(H)
	var/list/slots = list (
		"backpack" = SLOT_IN_BACKPACK,
		"left pocket" = SLOT_L_STORE,
		"right pocket" = SLOT_R_STORE
	)
	var/where = H.equip_in_one_of_slots(T, slots)
	H.equip_in_one_of_slots(T2, slots)
	if (!where)
		to_chat(owner, "<span class='warning'>You lost your weapon on the way here! You should be more careful next time.</span>")

	//Update ID
	var/obj/item/card/id/ID = H.get_idcard()
	ID.access += ACCESS_WEAPONS

////////////////////////////////
//////     Objectives    ///////
////////////////////////////////

/datum/objective/saveshuttle
	name = "protect shuttle"

/datum/objective/saveshuttle/check_completion()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return FALSE
	var/count = 0
	for(var/place in SSshuttle.emergency.shuttle_areas)
		for(var/mob/living/carbon/human/person in place)
			if(!person.mind)
				continue
			if(!considered_alive(person.mind))
				continue
			count ++
	return count >= target_amount

/datum/objective/saveshuttle/update_explanation_text()
	. = ..()
	explanation_text = "Protect the emergency shuttle from harm, ensuring that at least [target_amount] people make it on the shuttle alive."

/datum/objective/saveshuttle/proc/generate_people_goal()
	var/potential_escapees = 0
	for(var/mob/M in GLOB.mob_list)
		if(M.mind)
			potential_escapees ++
	if(potential_escapees == 0)
		explanation_text = "Free Objective"
		return 0
	target_amount = rand(1, round(potential_escapees * 0.2))			//This should really be made to scale with the population
	update_explanation_text()
	return target_amount
