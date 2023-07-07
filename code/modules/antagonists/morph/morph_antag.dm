/datum/antagonist/morph
	name = "Morph"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	job_rank = ROLE_MORPH
	antagpanel_category = "Morph"
	show_name_in_check_antagonists = TRUE
	ui_name = "AntagInfoMorph"

//It does nothing! (Besides tracking)//Scratch that, it does something now at least

/datum/antagonist/morph/on_gain()
	forge_objectives()
	return ..()

/datum/antagonist/morph/greet()
	owner.announce_objectives()

/datum/antagonist/morph/apply_innate_effects(mob/living/mob_override)
	. = ..()
	//Give morph appearance on hud (If they are not an antag already)
	var/datum/atom_hud/antag/morphhud = GLOB.huds[ANTAG_HUD_MORPH]
	morphhud.join_hud(owner.current)
	if(!owner.antag_hud_icon_state)
		set_antag_hud(owner.current, "morph")

/datum/antagonist/morph/remove_innate_effects(mob/living/mob_override)
	. = ..()
	//Clear the hud if they haven't become something else and had the hud overwritten
	var/datum/atom_hud/antag/morphhud = GLOB.huds[ANTAG_HUD_MORPH]
	morphhud.leave_hud(owner.current)
	if(owner.antag_hud_icon_state == "morph")
		set_antag_hud(owner.current, null)

/datum/antagonist/morph/proc/forge_objectives()
	var/datum/objective/eat_everything/consume = new
	consume.owner = owner
	objectives += consume

/datum/objective/eat_everything
	explanation_text = "Eat everything and anything to sate your never-ending hunger."
	completed = TRUE

/datum/antagonist/morph/admin_add(datum/mind/new_owner,mob/admin)
	if(alert(admin,"Transform the player into a morph?","Species Change","Yes","No") != "Yes")
		return ..()
	var/mob/living/M = new_owner.current
	if(!QDELETED(M) && !M.notransform)
		M.notransform = 1
		M.unequip_everything()
		var/mob/living/new_mob = new /mob/living/simple_animal/hostile/morph(M.loc)
		if(istype(new_mob))
			new_mob.a_intent = INTENT_HARM
			M.mind.transfer_to(new_mob)
			new_owner.assigned_role = ROLE_MORPH
			new_owner.special_role = ROLE_MORPH
			new_mob.name = "morph"
			new_mob.real_name = "morph"
		qdel(M)
	return ..()
