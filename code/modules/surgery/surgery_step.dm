/datum/surgery_step
	var/name
	var/list/implements = list()	//format is path = probability of success. alternatively
	var/implement_type = null		//the current type of implement used. This has to be stored, as the actual typepath of the tool may not match the list type.
	var/accept_hand = FALSE				//does the surgery step require an open hand? If true, ignores implements. Compatible with accept_any_item.
	var/accept_any_item = FALSE			//does the surgery step accept any item? If true, ignores implements. Compatible with require_hand.
	var/time = 10					//how long does the step take?
	var/repeatable = FALSE				//can this step be repeated? Make shure it isn't last step, or it used in surgery with `can_cancel = 1`. Or surgion will be stuck in the loop
	var/list/chems_needed = list()  //list of chems needed to complete the step. Even on success, the step will have no effect if there aren't the chems required in the mob.
	var/require_all_chems = TRUE    //any on the list or all on the list?
	var/preop_sound //Sound played when the step is started
	var/success_sound //Sound played if the step succeeded
	var/failure_sound //Sound played if the step fails

/datum/surgery_step/proc/try_op(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	var/success = FALSE
	if(accept_hand)
		if(!tool)
			success = TRUE
		if(iscyborg(user))
			success = TRUE

	if(accept_any_item)
		if(tool && tool_check(user, tool))
			success = TRUE

	else if(tool)
		for(var/key in implements)
			var/match = FALSE

			if(ispath(key) && istype(tool, key))
				match = TRUE
			else if(tool.tool_behaviour == key)
				match = TRUE

			if(match)
				implement_type = key
				if(tool_check(user, tool))
					success = TRUE
					break

	if(success)
		if(target_zone == surgery.location)
			if(get_location_accessible(target, target_zone) || surgery.ignore_clothes)
				return initiate(user, target, target_zone, tool, surgery, try_to_fail)
			else
				to_chat(user, "<span class='warning'>You need to expose [target]'s [parse_zone(target_zone)] to perform surgery on it!</span>")
				return TRUE	//returns TRUE so we don't stab the guy in the dick or wherever.

	if(repeatable)
		var/datum/surgery_step/next_step = surgery.get_surgery_next_step()
		if(next_step)
			surgery.status++
			if(next_step.try_op(user, target, user.zone_selected, user.get_active_held_item(), surgery))
				return TRUE
			else
				surgery.status--

	return FALSE

/datum/surgery_step/proc/get_speed_modifier(mob/user, mob/target)
	var/propability = 0.3
	var/turf/T = get_turf(target)
	var/selfpenalty = 0
	var/sleepbonus = 0
	var/perfect = HAS_TRAIT(user, TRAIT_PERFECT_SURGEON)
	if(target == user && !perfect)
		if(HAS_TRAIT(user, TRAIT_SELF_AWARE) || user.get_inactive_held_item() == /obj/item/handmirror || locate(/obj/structure/mirror) in view(1, user))
			selfpenalty = 0.4
		else
			selfpenalty = 0.6
	if(target.stat)//are they not conscious
		sleepbonus = 0.5
	if(perfect || locate(/obj/structure/table/optable/abductor, T))
		propability = 1.2
	else if(locate(/obj/structure/table/optable, T))
		propability = 1
	else if(locate(/obj/machinery/stasis, T))
		propability = 0.8
	else if(locate(/obj/structure/table, T))
		propability = 0.6
	else if(locate(/obj/structure/bed, T))
		propability = 0.5

	return max(propability + sleepbonus - selfpenalty, 0.1)

/datum/surgery_step/proc/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	surgery.step_in_progress = TRUE
	var/speed_mod = 1
	var/fail_prob = 0//100 - fail_prob = success_prob
	var/advance = FALSE

	if(preop(user, target, target_zone, tool, surgery) == -1)
		surgery.step_in_progress = FALSE
		return FALSE

	play_preop_sound(user, target, target_zone, tool, surgery) // Here because most steps overwrite preop

	if(tool)
		speed_mod = tool.toolspeed

	var/implement_speed_mod = 1
	if(implement_type)//this means it isn't a require hand or any item step.
		implement_speed_mod = implements[implement_type] / 100.0
	speed_mod /= (get_speed_modifier(user, target) * (1 + surgery.speed_modifier) * implement_speed_mod)

	var/modded_time = time * speed_mod
	fail_prob = min(max(0, modded_time - (time * 2)), 99)//if modded_time > time * 2, then fail_prob = modded_time - time*2. starts at 0, caps at 99
	modded_time = min(modded_time, time * 2)//also if that, then cap modded_time at time*2

	if(iscyborg(user))//any immunities to surgery slowdown should go in this check.
		modded_time = time

	if(do_after(user, modded_time, target = target))

		if(((prob(100 - fail_prob) || HAS_TRAIT(user, TRAIT_PERFECT_SURGEON) || iscyborg(user)) && chem_check(target)) && !try_to_fail)
			if(success(user, target, target_zone, tool, surgery))
				play_success_sound(user, target, target_zone, tool, surgery)
				advance = TRUE
		else if(failure(user, target, target_zone, tool, surgery, fail_prob))
			advance = TRUE

		if(advance && !repeatable)
			surgery.status++
			if(surgery.status > surgery.steps.len)
				surgery.complete()

	surgery.step_in_progress = FALSE
	return advance

/datum/surgery_step/proc/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to perform surgery on [target]...</span>",
		"<span class='notice'>[user] begins to perform surgery on [target].</span>",
		"<span class='notice'>[user] begins to perform surgery on [target].</span>")

/datum/surgery_step/proc/play_preop_sound(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!preop_sound)
		return
	var/sound_file_use
	if(islist(preop_sound))
		for(var/typepath in preop_sound)//iterate and assign subtype to a list, works best if list is arranged from subtype first and parent last
			if(istype(tool, typepath))
				sound_file_use = preop_sound[typepath]
				break
	else
		sound_file_use = preop_sound
	playsound(get_turf(target), sound_file_use, 75, TRUE, falloff_exponent = 12, falloff_distance = 1)

/datum/surgery_step/proc/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = TRUE)
	display_results(user, target, "<span class='notice'>You succeed.</span>",
		"<span class='notice'>[user] succeeds.</span>",
		"<span class='notice'>[user] finishes.</span>")
	return TRUE

/datum/surgery_step/proc/play_success_sound(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!success_sound)
		return
	playsound(get_turf(target), success_sound, 75, TRUE, falloff_exponent = 12, falloff_distance = 1)

/datum/surgery_step/proc/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, fail_prob = 0)
	var/screwedmessage = ""
	switch(fail_prob)
		if(0 to 24)
			screwedmessage = " You almost had it, though."
		if(50 to 74)//25 to 49 = no extra text
			screwedmessage = " This is hard to get right in these conditions..."
		if(75 to 99)
			screwedmessage = " This is practically impossible in these conditions..."

	display_results(user, target, "<span class='warning'>You screw up![screwedmessage]</span>",
		"<span class='warning'>[user] screws up!</span>",
		"<span class='notice'>[user] finishes.</span>", TRUE) //By default the patient will notice if the wrong thing has been cut
	return FALSE

/datum/surgery_step/proc/play_failure_sound(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!failure_sound)
		return
	playsound(get_turf(target), failure_sound, 75, TRUE, falloff_exponent = 12, falloff_distance = 1)

/datum/surgery_step/proc/tool_check(mob/user, obj/item/tool)
	return TRUE

/datum/surgery_step/proc/chem_check(mob/living/carbon/target)
	if(!LAZYLEN(chems_needed))
		return TRUE

	if(require_all_chems)
		. = TRUE
		for(var/R in chems_needed)
			if(!target.reagents.has_reagent(R))
				return FALSE
	else
		. = FALSE
		for(var/R in chems_needed)
			if(target.reagents.has_reagent(R))
				return TRUE

/datum/surgery_step/proc/get_chem_list()
	if(!LAZYLEN(chems_needed))
		return
	var/list/chems = list()
	for(var/R in chems_needed)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[R]
		if(temp)
			var/chemname = temp.name
			chems += chemname
	return english_list(chems, and_text = require_all_chems ? " and " : " or ")

//Replaces visible_message during operations so only people looking over the surgeon can see them.
/datum/surgery_step/proc/display_results(mob/user, mob/living/carbon/target, self_message, detailed_message, vague_message, target_detailed = FALSE)
	user.visible_message(detailed_message, self_message, vision_distance = 1, ignored_mobs = target_detailed ? null : target)
	if(!target_detailed)
		to_chat(target, vague_message)
