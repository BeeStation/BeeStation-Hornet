/datum/action/vampire/awe
	name = "Awe"
	desc = "Subtly influence those around you to see you more favorably."
	button_icon_state = "power_awe"
	power_explanation = "Project an aura around yourself that periodically injects thoughts into everyone around you. This is not a subtle power, expect people to question why they feel this way.\n\
						- Level 1: Aura reaching 4 tiles with nearly neutral attraction. People must be able to see you.\n\
						- Level 2: Range boosted to 5 tiles.\n\
						- Level 3: Further range, now at 6 tiles. The thoughts people receive are much more intense.\n\
						- Level 4: Range now reaches 7 tiles.\n\
						<b>IMPORTANT:</b> People with mindshields are resistant. Even at level 4, they only get mild effects."
	power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN
	check_flags =  BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_IN_FRENZY
	vitaecost = 30
	constant_vitaecost = 1
	cooldown_time = 10 SECONDS
	var/high_intensity = FALSE
	var/aura = 4
	var/visible = FALSE
	var/mutable_appearance/effect

/datum/action/vampire/awe/two
	vitaecost = 45
	constant_vitaecost = 2
	aura = 5

/datum/action/vampire/awe/three
	vitaecost = 60
	constant_vitaecost = 3
	aura = 6

/datum/action/vampire/awe/four
	vitaecost = 75
	constant_vitaecost = 4
	high_intensity = TRUE
	aura = 7
	visible = TRUE

/datum/action/vampire/awe/activate_power()
	. = ..()
	to_chat(owner, span_hypnophrase("You activate your supernatural charm."), type = MESSAGE_TYPE_WARNING)

	if(visible)
		effect = mutable_appearance('icons/vampires/actions_vampire.dmi', "awe_aura", -MUTATIONS_LAYER)
		owner.add_overlay(effect)

/datum/action/vampire/awe/deactivate_power()
	. = ..()
	to_chat(owner, span_hypnophrase("You deactivate your supernatural charm."), type = MESSAGE_TYPE_WARNING)
	owner.cut_overlay(effect)

/datum/action/vampire/awe/UsePower()
	. = ..()
	for(var/mob/living/viewer in oviewers(aura, owner))
		if(check_watchy(viewer))
			if(high_intensity)
				if(HAS_TRAIT(viewer, TRAIT_MINDSHIELD))
					viewer.apply_status_effect(/datum/status_effect/awed, owner)
					return
				viewer.apply_status_effect(/datum/status_effect/awed/strong, owner)
			else
				if(HAS_TRAIT(viewer, TRAIT_MINDSHIELD))
					return
				viewer.apply_status_effect(/datum/status_effect/awed, owner)

/datum/action/vampire/awe/proc/check_watchy(mob/living/watcher)
	if(!watcher.client)
		return FALSE
	if(watcher.has_unlimited_silicon_privilege)
		return FALSE
	if(watcher.stat != CONSCIOUS)
		return FALSE
	if(watcher.is_blind() || HAS_TRAIT(watcher, TRAIT_NEARSIGHT))
		return FALSE
	if(IS_VAMPIRE(watcher) || IS_VASSAL(watcher) || IS_CURATOR(watcher))
		return FALSE
	if(watcher.has_status_effect(/datum/status_effect/awed/strong) || watcher.has_status_effect(/datum/status_effect/awed))
		return FALSE
	return TRUE

/datum/status_effect/awed
	id = "awed"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 19.7 SECONDS
	tick_interval = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/awed
	var/mob/living/object_of_desire
	var/strong = FALSE

/datum/status_effect/awed/strong
	id = "awed-strong"
	tick_interval = 5 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/awed/strong
	strong = TRUE

/atom/movable/screen/alert/status_effect/awed
	name = "Awed"
	desc = "If you see this yell at a coder."
	icon_state = "in_love"

/atom/movable/screen/alert/status_effect/awed/strong
	name = "Marvelled"
	desc = "If you see this yell at a coder."
	icon_state = "hypnosis"

/datum/status_effect/awed/tick()
	// expand the random pool for more varied behaviors; 0 is a nop as before
	switch(rand(1, 10))
		if(1)
			owner.Stun(20, TRUE)
			to_chat(owner, "What was I doing again...", type = MESSAGE_TYPE_INFO)
		if(2)
			if(!owner.incapacitated(IGNORE_RESTRAINTS))
				owner.face_atom(object_of_desire)
				to_chat(owner, span_awe("God, [object_of_desire.p_they()] [object_of_desire.p_are()] so pretty..."), type = MESSAGE_TYPE_INFO)
		if(3)
			if(!owner.incapacitated(IGNORE_RESTRAINTS))
				owner.face_atom(object_of_desire)
				to_chat(owner, span_awe("I need to listen. [object_of_desire.p_they()] [object_of_desire.p_are()] so wise..."), type = MESSAGE_TYPE_INFO)
		if(4)
			to_chat(owner, span_awe("My mind keeps drifting back to [object_of_desire]..."), type = MESSAGE_TYPE_INFO)
		if(5)	// Knees weak
			if(!owner.incapacitated(IGNORE_RESTRAINTS))
				owner.face_atom(object_of_desire)
				to_chat(owner, span_awe("[object_of_desire] is so amazing... God my knees are wobbly..."), type = MESSAGE_TYPE_INFO)

				owner.apply_damage(rand(10,30), STAMINA, owner.get_bodypart(BODY_ZONE_L_LEG), FALSE, TRUE)	// left
				owner.apply_damage(rand(10,30), STAMINA, owner.get_bodypart(BODY_ZONE_R_LEG), FALSE, TRUE)	// right
		if(6)
			if(!owner.incapacitated(IGNORE_RESTRAINTS))
				owner.face_atom(object_of_desire)
				to_chat(owner, "I should move closer...", type = MESSAGE_TYPE_INFO)
				if(owner.body_position == STANDING_UP)
					owner.visible_message(span_warning("[owner] stumbles dumbly towards [object_of_desire]."), span_awe("[object_of_desire]..."))
					owner.Move(get_step(owner.loc, get_dir(owner.loc, object_of_desire.loc)))
		if(7)
			if(!owner.incapacitated(IGNORE_RESTRAINTS))
				owner.face_atom(object_of_desire)
				to_chat(owner, span_awe("I should be kind to [object_of_desire]..."), type = MESSAGE_TYPE_INFO)
				owner.emote("smiles")
		if(8 to 10)
			return

/datum/status_effect/awed/on_apply()
	if(!iscarbon(owner))
		return FALSE
	if(!owner.has_quirk(/datum/quirk/monochromatic) && strong)
		owner.add_client_colour(/datum/client_colour/glass_colour/pink)
	RegisterSignals(owner, list(COMSIG_MOVABLE_PULLED, COMSIG_ATOM_NO_LONGER_PULLED), PROC_REF(update_puller))
	return TRUE

/datum/status_effect/awed/on_creation(mob/living/new_owner, target)
	. = ..()
	object_of_desire = target
	if(strong)
		linked_alert.desc = "Everything else blurs; <b>[object_of_desire]</b> holds my focus and makes [object_of_desire.p_their()] opinion feel 'right'. <b>Though I could ignore it, should there be danger to myself or others...</b>"
	else
		linked_alert.desc = "A warm insistence draws me to <b>[object_of_desire]</b>, making [object_of_desire.p_their()] words and presence feel unusually important. <b>Though I could ignore it, should there be danger to myself or others...</b>"
	return

/datum/status_effect/awed/on_remove()
	if(!owner.has_quirk(/datum/quirk/monochromatic))
		owner.remove_client_colour(/datum/client_colour/glass_colour/pink)
	UnregisterSignal(owner, list(COMSIG_MOVABLE_PULLED, COMSIG_ATOM_NO_LONGER_PULLED))

/datum/status_effect/awed/get_examine_text()
	return span_warning("[owner.p_They()] look[owner.p_s()] awestruck, staring at [object_of_desire].")

/datum/status_effect/awed/proc/update_puller()
    SIGNAL_HANDLER
    if(owner.pulledby == object_of_desire)
        ADD_TRAIT(owner, TRAIT_GRABWEAKNESS, TRAIT_STATUS_EFFECT(id))
    else
        REMOVE_TRAIT(owner, TRAIT_GRABWEAKNESS, TRAIT_STATUS_EFFECT(id))
