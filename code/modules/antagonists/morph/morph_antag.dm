/datum/antagonist/morph
	name = "Morph"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	job_rank = ROLE_MORPH
	antagpanel_category = "Morph"
	show_name_in_check_antagonists = TRUE

//It does nothing! (Besides tracking)//Scratch that, it does something now at least

/datum/antagonist/morph/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/morph/greet()
	owner.announce_objectives()

/datum/antagonist/morph/proc/forge_objectives()
	var/datum/objective/eat_everything/consume = new
	consume.owner = owner
	objectives += consume

/datum/objective/eat_everything
	explanation_text = "Eat everything and anything to sate your never-ending hunger."
	completed = TRUE

/datum/antagonist/morph/admin_add(datum/mind/new_owner,mob/admin)
	var/mob/living/M = new_owner.current
	if(alert(admin,"Transform the player into a morph?","Species Change","Yes","No") == "Yes")
		if(!QDELETED(M) && !M.notransform)
			M.notransform = 1
			M.unequip_everything()
			var/mob/living/new_mob = new /mob/living/simple_animal/hostile/morph(M.loc)
			if(istype(new_mob))
				new_mob.a_intent = INTENT_HARM
				M.mind.transfer_to(new_mob)
				new_owner.assigned_role = "Morph"
				new_owner.special_role = "Morph"
				new_mob.name = "morph"
				new_mob.real_name = "morph"
			qdel(M)
	. = ..()
