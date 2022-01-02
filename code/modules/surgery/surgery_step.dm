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
	var/multiplier = 0.3
	var/turf/T = get_turf(target)
	var/selfpenalty = 0
	var/sleepbonus = 0
	if(target == user)
		if(HAS_TRAIT(user, TRAIT_SELF_AWARE) || user.get_inactive_held_item() == /obj/item/handmirror || locate(/obj/structure/mirror) in view(1, user))
			selfpenalty = 0.4
		else
			selfpenalty = 0.6
	if(target.stat)//are they not conscious
		sleepbonus = 0.5
	if(locate(/obj/structure/table/optable/abductor, T))
		multiplier = 1.2
	else if(locate(/obj/structure/table/optable, T))
		multiplier = 1
	else if(locate(/obj/machinery/stasis, T))
		multiplier = 0.8
	else if(locate(/obj/structure/table, T))
		multiplier = 0.6
	else if(locate(/obj/structure/bed, T))
		multiplier = 0.5

	return max(multiplier + sleepbonus - selfpenalty, 0.1)

/datum/surgery_step/proc/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	surgery.step_in_progress = TRUE
	var/speed_mod = 1
	var/success_prob = 0
	var/advance = FALSE

	if(preop(user, target, target_zone, tool, surgery) == -1)
		surgery.step_in_progress = FALSE
		return FALSE

	if(tool)
		speed_mod = tool.toolspeed
		if(!speed_mod)
			speed_mod = 1

	speed_mod /= get_speed_modifier(user, target) * (1 + surgery.speed_modifier)

	var/modded_time = time * speed_mod * (1 - sterilization_check(target)) * clothing_check(user)
	//Speed = Base time * Tool Speed * Between 1 to 0.60 sterilization * Between 1 to 0.40 clothing
	success_prob = (implements[implement_type] * ( 1 +sterilization_check(target)))
	//Success Chance = implement chance per surgery * 1 to 1.6 sterilization
	//Full sterilization odds of success: 63% = 100%, 47% = 75%, 32% = 50%, 16% = 25%

	if(iscyborg(user))//any immunities to surgery slowdown should go in this check.
		modded_time = time

	if(do_after(user, modded_time, target = target))

		if((prob(0 + success_prob) || iscyborg(user) || HAS_TRAIT(user, TRAIT_SURGEON)) && chem_check(target) && !try_to_fail)

			if(success(user, target, target_zone, tool, surgery))
				advance = TRUE
		else if(failure(user, target, target_zone, tool, surgery, success_prob))
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

/datum/surgery_step/proc/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You succeed.</span>",
		"<span class='notice'>[user] succeeds!</span>",
		"<span class='notice'>[user] finishes.</span>")
	return TRUE

/datum/surgery_step/proc/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, success_prob = 0)
	var/screwedmessage = ""
	switch(success_prob)
		if(75 to 99)
			screwedmessage = pick(" You almost had it, though.", " Just got to keep trying...", " So close...")
		if(50 to 74)
			screwedmessage = pick(" This is hard to get right in these conditions...", " Maybe I need more sterilizer...")
		if(25 to 49)
			screwedmessage = pick(" This is practically impossible in these conditions...", " I'm going to need better tools...", " Did I sterilize the patient?")
		if(0 to 24)
			screwedmessage = pick(" This probably isn't going to work...", " Am I qualified for this?", " I'd better check my tools...", " Did I sterilize the patient?")

	display_results(user, target, "<span class='warning'>You screw up![screwedmessage]</span>",
		"<span class='warning'>[user] screws up!</span>",
		"<span class='notice'>[user] finishes.</span>", TRUE) //By default the patient will notice if the wrong thing has been cut
	return FALSE

/datum/surgery_step/proc/tool_check(mob/user, obj/item/tool)
	return TRUE

/datum/surgery_step/proc/clothing_check(mob/living/user) 		//Checks if the SURGEON is wearing proper attire
	if(!ishuman(user))
		return 1 //I'm gonna just catch any weird cases of non-humans doing surgery right here

	var/mob/living/carbon/human/surgeon = user
	var/clothing_multiplier = 1
	var/list/surgery_clothes = list(	/obj/item/clothing/suit/apron,
										/obj/item/clothing/gloves/color/latex,
										/obj/item/clothing/mask/surgical,
										/obj/item/clothing/head/nursehat,
										/obj/item/clothing/head/beret/cmo,
										/obj/item/clothing/head/beret/med,
										/obj/item/clothing/neck/stethoscope,
										/obj/item/clothing/head/helmet/space/plasmaman/medical,
										/obj/item/clothing/head/helmet/space/plasmaman/cmo,
										/obj/item/clothing/suit/toggle/labcoat,
										/obj/item/clothing/mask/breath,
										/obj/item/clothing/suit/hooded/techpriest,
										/obj/item/clothing/suit/bio_suit/plaguedoctorsuit,
										/obj/item/clothing/mask/gas/plaguedoctor,
										/obj/item/clothing/head/plaguedoctorhat,
										/obj/item/clothing/under/suit/sl,
										/obj/item/clothing/glasses/hud/health
										)

	for(var/obj/item/I in surgeon.get_equipped_items(FALSE))
		if(locate(I) in surgery_clothes)
			clothing_multiplier -= 0.15
	if(clothing_multiplier < 0.40) //Max of 60% bonus from clothing.
		clothing_multiplier = 0.40
	return clothing_multiplier


/datum/surgery_step/proc/sterilization_check(mob/living/target) //Checks if the victim/patient has any reagents in them that will increase surgery speed
	var/list/sterilization_chems = list(	/datum/reagent/space_cleaner/sterilizine,
											/datum/reagent/consumable/honey,
											/datum/reagent/medicine/mine_salve,
											/datum/reagent/consumable/laughter,
											/datum/reagent/consumable/ethanol
										)
	var/sterile_multiplier = 0

	for(var/i = 1, i < sterilization_chems.len, i++)
		if(target.reagents.has_reagent(sterilization_chems[i]))
			switch(sterilization_chems[i])
				if(/datum/reagent/space_cleaner/sterilizine)
					sterile_multiplier += 0.5
				if(/datum/reagent/consumable/honey)
					sterile_multiplier += 0.6
				if(/datum/reagent/medicine/mine_salve)
					sterile_multiplier += 0.3
				if(/datum/reagent/consumable/laughter) //Truly the best medicine.
					sterile_multiplier += 0.3
				if(/datum/reagent/consumable/ethanol)
					sterile_multiplier += 0.3
	if(sterile_multiplier >= 0.6)
		sterile_multiplier = 0.6
	return sterile_multiplier //Max of 60% bonus from this for success, max 40% for speed

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
