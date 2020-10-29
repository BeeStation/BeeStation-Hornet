/obj/machinery/computer/aifixer
	name = "\improper AI system integrity restorer"
	desc = "Used with intelliCards containing nonfunctional AIs to restore them to working order."
	req_access = list(ACCESS_CAPTAIN, ACCESS_ROBOTICS, ACCESS_HEADS)
	circuit = /obj/item/circuitboard/computer/aifixer
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK
	/// Variable containing transferred AI
	var/mob/living/silicon/ai/occupier
	/// Variable dictating if we are in the process of restoring the occupier AI
	var/restoring = FALSE

/obj/machinery/computer/aifixer/screwdriver_act(mob/living/user, obj/item/I)
	if(occupier)
		if(stat & (NOPOWER|BROKEN))
			to_chat(user, "<span class='warning'>The screws on [name]'s screen won't budge.</span>")
		else
			to_chat(user, "<span class='warning'>The screws on [name]'s screen won't budge and it emits a warning beep.</span>")
	else
		return ..()


/obj/machinery/computer/aifixer/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/aifixer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiRestorer")
		ui.open()

/obj/machinery/computer/aifixer/ui_data(mob/user)
	var/list/data = list()

	data["ejectable"] = FALSE
	data["AI_present"] = FALSE
	data["error"] = null
	if(!occupier)
		data["error"] = "Please transfer an AI unit."
	else
		data["AI_present"] = TRUE
		data["name"] = occupier.name
		data["restoring"] = restoring
		data["health"] = (occupier.health + 100) / 2
		data["isDead"] = occupier.stat == DEAD
		data["laws"] = occupier.laws.get_law_list(include_zeroth = 1)

	return data

/obj/machinery/computer/aifixer/ui_act(action, params)
	if(..())
		return
	if(!occupier)
		restoring = FALSE

	switch(action)
		if("PRG_beginReconstruction")
			if(occupier?.health < 100)
				to_chat(usr, "<span class='notice'>Reconstruction in progress. This will take several minutes.</span>")
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 25, FALSE)
				restoring = TRUE
				occupier.notify_ghost_cloning("Your core files are being restored!", source = src)
				. = TRUE

/obj/machinery/computer/aifixer/proc/Fix()
	use_power(1000)
	occupier.adjustOxyLoss(-5, 0)
	occupier.adjustFireLoss(-5, 0)
	occupier.adjustToxLoss(-5, 0)
	occupier.adjustBruteLoss(-5, 0)
	occupier.updatehealth()
	if(occupier.health >= 0 && occupier.stat == DEAD)
		occupier.revive(full_heal = FALSE, admin_revive = FALSE)
		if(!occupier.radio_enabled)
			occupier.radio_enabled = TRUE
			to_chat(occupier, "<span class='warning'>Your Subspace Transceiver has been enabled!</span>")
	return occupier.health < 100

/obj/machinery/computer/aifixer/process()
	if(..())
		if(restoring)
			var/oldstat = occupier.stat
			restoring = Fix()
			if(oldstat != occupier.stat)
				update_icon()

/obj/machinery/computer/aifixer/update_icon()
	..()
	if(stat & (NOPOWER|BROKEN))
		return
	if(restoring)
		add_overlay("ai-fixer-on")
	if (occupier)
		switch (occupier.stat)
			if (CONSCIOUS)
				add_overlay("ai-fixer-full")
			if (UNCONSCIOUS)
				add_overlay("ai-fixer-404")
	else
		add_overlay("ai-fixer-empty")

/obj/machinery/computer/aifixer/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(!..())
		return
	//Downloading AI from card to terminal.
	if(interaction == AI_TRANS_FROM_CARD)
		if(stat & (NOPOWER|BROKEN))
			to_chat(user, "<span class='alert'>[src] is offline and cannot take an AI at this time.</span>")
			return
		AI.forceMove(src)
		occupier = AI
		AI.control_disabled = TRUE
		AI.radio_enabled = FALSE
		to_chat(AI, "<span class='alert'>You have been uploaded to a stationary terminal. Sadly, there is no remote access from here.</span>")
		to_chat(user, "<span class='notice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
		card.AI = null
		update_icon()

	else //Uploading AI from terminal to card
		if(occupier && !restoring)
			to_chat(occupier, "<span class='notice'>You have been downloaded to a mobile storage device. Still no remote access.</span>")
			to_chat(user, "<span class='notice'>Transfer successful</span>: [occupier.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.")
			occupier.forceMove(card)
			card.AI = occupier
			occupier = null
			update_icon()
		else if (restoring)
			to_chat(user, "<span class='alert'>ERROR: Reconstruction in progress.</span>")
		else if (!occupier)
			to_chat(user, "<span class='alert'>ERROR: Unable to locate artificial intelligence.</span>")

/obj/machinery/computer/aifixer/on_deconstruction()
	if(occupier)
		QDEL_NULL(occupier)
