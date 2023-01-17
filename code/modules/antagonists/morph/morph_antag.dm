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
				if(M.mind)
					M.mind.transfer_to(new_mob)
				else
					new_mob.key = M.key
			qdel(M)
	. = ..()

/*/datum/disease/transformation/proc/do_disease_transformation(mob/living/affected_mob)
	if(istype(affected_mob, /mob/living/carbon) && affected_mob.stat != DEAD)
		if(length(stage5))
			to_chat(affected_mob, pick(stage5))
		if(QDELETED(affected_mob))
			return
		if(affected_mob.notransform)
			return
		affected_mob.notransform = 1
		affected_mob.unequip_everything()
		var/mob/living/new_mob = new new_form(affected_mob.loc)
		if(istype(new_mob))
			if(bantype && is_banned_from(affected_mob.ckey, bantype))
				replace_banned_player(new_mob)
			new_mob.a_intent = INTENT_HARM
			if(affected_mob.mind)
				affected_mob.mind.transfer_to(new_mob)
			else
				new_mob.key = affected_mob.key

		new_mob.name = affected_mob.real_name
		new_mob.real_name = new_mob.name
		qdel(affected_mob)*/
