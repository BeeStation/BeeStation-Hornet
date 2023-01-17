/datum/antagonist/morph
	name = "Morph"
	show_name_in_check_antagonists = TRUE
	show_in_antagpanel = FALSE
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
	var/mob/living/carbon/C = new_owner.current
	if(alert(admin,"Transform the player into a morph?","Species Change","Yes","No") == "Yes")
		C.set_species(/mob/living/simple_animal/hostile/morph)
	message_admins("[key_name_admin(admin)] has made [key_name_admin(C)] into a Morph.")
	log_admin("[key_name(admin)] has made [key_name(C)] into a Morph.")
