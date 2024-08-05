/datum/computer_file/program/aidiag
	filename = "aidiag"
	filedesc = "AI Integrity Restorer"
	category = PROGRAM_CATEGORY_ROBO
	program_icon_state = "generic"
	extended_desc = "This program is capable of reconstructing damaged AI systems. Requires direct AI connection via intellicard slot."
	size = 12
	requires_ntnet = FALSE
	usage_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP
	transfer_access = list(ACCESS_HEADS)
	available_on_ntnet = TRUE
	tgui_id = "NtosAiRestorer"
	program_icon = "laptop-code"
	/// Variable dictating if we are in the process of restoring the AI in the inserted intellicard
	var/restoring = FALSE

/datum/computer_file/program/aidiag/proc/get_ai_slot()
	var/obj/item/computer_hardware/goober/ai/ai_slot = computer.all_components[MC_AI]
	if(!istype(ai_slot) || !ai_slot.check_functionality())
		return

	return ai_slot

/datum/computer_file/program/aidiag/proc/get_ai_card()
	var/obj/item/computer_hardware/goober/ai/ai_slot = get_ai_slot()
	return ai_slot?.stored_card

/datum/computer_file/program/aidiag/proc/get_ai_mob()
	var/obj/item/aicard/ai_card = get_ai_card()
	return ai_card?.AI

/datum/computer_file/program/aidiag/ui_act(action, params)
	if(..())
		return

	var/mob/living/silicon/ai/A = get_ai_mob()
	if(!A)
		restoring = FALSE

	switch(action)
		if("PRG_beginReconstruction")
			if(A && A.health < 100)
				restoring = TRUE
				A.notify_ghost_cloning("Your core files are being restored!", source = computer)
			return TRUE

		if("PRG_eject")
			var/obj/item/computer_hardware/goober/ai/ai_slot = get_ai_slot()
			if(!istype(ai_slot))
				return

			return ai_slot.try_eject(usr)

/datum/computer_file/program/aidiag/process_tick()
	. = ..()
	if(!restoring)	//Put the check here so we don't check for an ai all the time
		return
	var/obj/item/computer_hardware/goober/ai/ai_slot = get_ai_slot()
	var/obj/item/aicard/cardhold = get_ai_card()
	var/mob/living/silicon/ai/A = get_ai_mob()

	if(!A || !cardhold)
		restoring = FALSE	// If the AI was removed, stop the restoration sequence.
		if(ai_slot)
			ai_slot.locked = FALSE
		return

	if(cardhold.flush)
		ai_slot.locked = FALSE
		restoring = FALSE
		return
	ai_slot.locked =TRUE
	A.adjustOxyLoss(-1, 0)
	A.adjustFireLoss(-1, 0)
	A.adjustToxLoss(-1, 0)
	A.adjustBruteLoss(-1, 0)
	A.updatehealth()
	if(A.health >= 0 && A.stat == DEAD)
		A.revive()
	// Finished restoring
	if(A.health >= 100)
		ai_slot.locked = FALSE
		restoring = FALSE

	return TRUE


/datum/computer_file/program/aidiag/ui_data(mob/user)
	. = list()
	var/obj/item/aicard/aicard = get_ai_card()

	.["ejectable"] = TRUE
	.["AI_present"] = FALSE
	.["error"] = null
	if(!istype(aicard))
		.["error"] = "Please insert an intelliCard."
		return

	var/mob/living/silicon/ai/AI = get_ai_mob()
	if(!istype(AI))
		.["error"] = "No AI located"

	if(aicard.flush)
		.["error"] = "Flush in progress"
		return

	.["AI_present"] = TRUE
	.["name"] = AI.name
	.["restoring"] = restoring
	.["health"] = (AI.health + 100) / 2
	.["isDead"] = AI.stat == DEAD
	.["laws"] = AI.laws.get_law_list(include_zeroth = 1)


/datum/computer_file/program/aidiag/kill_program(forced)
	restoring = FALSE
	return ..(forced)
