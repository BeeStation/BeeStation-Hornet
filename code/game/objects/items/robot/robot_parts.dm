/obj/item/robot_suit
	name = "cyborg endoskeleton"
	desc = "A complex metal backbone with standard limb sockets and pseudomuscle anchors."
	icon = 'icons/mob/augmentation/augments.dmi'
	icon_state = "robo_suit"
	/// Left arm part of the endoskeleton
	var/obj/item/bodypart/arm/left/robot/l_arm = null
	/// Right arm part of the endoskeleton
	var/obj/item/bodypart/arm/right/robot/r_arm = null
	/// Left leg part of this endoskeleton
	var/obj/item/bodypart/leg/left/robot/l_leg = null
	/// Right leg part of this endoskeleton
	var/obj/item/bodypart/leg/right/robot/r_leg = null
	/// Chest part of this endoskeleton
	var/obj/item/bodypart/chest/robot/chest = null
	/// Head part of this endoskeleton
	var/obj/item/bodypart/head/robot/head = null
	/// Forced name of the cyborg
	var/created_name = ""

	/// Forced master AI of the cyborg
	var/mob/living/silicon/ai/forced_ai
	/// The name of the AI being forced, tracked separately to above
	/// so we can reference handle without worrying about making "AI got gibbed" detectors
	var/forced_ai_name

	/// If the cyborg starts movement free and not under lockdown
	var/locomotion = TRUE
	/// If the cyborg synchronizes its laws with its master AI
	var/lawsync = TRUE
	/// If the cyborg starts with a master AI
	var/aisync = TRUE
	/// If the cyborg's cover panel starts locked
	var/panel_locked = TRUE

/obj/item/robot_suit/Destroy()
	QDEL_NULL(l_arm)
	QDEL_NULL(r_arm)
	QDEL_NULL(l_leg)
	QDEL_NULL(r_leg)
	QDEL_NULL(chest)
	QDEL_NULL(head)
	return ..()

/obj/item/robot_suit/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == l_arm)
		l_arm = null
	if(gone == r_arm)
		r_arm = null
	if(gone == l_leg)
		l_leg = null
	if(gone == r_leg)
		r_leg = null
	if(gone == chest)
		chest = null
	if(gone == head)
		head = null

/obj/item/robot_suit/update_overlays()
	. = ..()
	if(l_arm)
		. += "[initial(l_arm.icon_state)]+o"
	if(r_arm)
		. += "[initial(r_arm.icon_state)]+o"
	if(chest)
		. += "[initial(chest.icon_state)]+o"
	if(l_leg)
		. += "[initial(l_leg.icon_state)]+o"
	if(r_leg)
		. += "[initial(r_leg.icon_state)]+o"
	if(head)
		. += "[initial(head.icon_state)]+o"

/obj/item/robot_suit/add_context_self(datum/screentip_context/context, mob/user, obj/item/item)
	if(chest?.cell)
		context.add_left_click_tool_action("Remove cell", TOOL_SCREWDRIVER)
	if(l_leg || r_leg || chest || l_arm || r_arm || head)
		context.add_left_click_tool_action("Disassemble", TOOL_WRENCH)
	if(check_completion())
		context.add_left_click_tool_action("Debug", TOOL_MULTITOOL)

	if(!l_leg)
		context.add_left_click_item_action("Attach", /obj/item/bodypart/leg/left/robot)
	if(!r_leg)
		context.add_left_click_item_action("Attach", /obj/item/bodypart/leg/right/robot)
	if(!chest)
		context.add_left_click_item_action("Attach", /obj/item/bodypart/chest/robot)
	if(!l_arm)
		context.add_left_click_item_action("Attach", /obj/item/bodypart/arm/left/robot)
	if(!r_arm)
		context.add_left_click_item_action("Attach", /obj/item/bodypart/arm/right/robot)
	if(!head)
		context.add_left_click_item_action("Attach", /obj/item/bodypart/head/robot)

/obj/item/robot_suit/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/stack/sheet/iron))
		var/obj/item/stack/sheet/iron/iron_sheet = tool
		if(l_arm || r_arm || l_leg || r_leg || chest || head)
			return ITEM_INTERACT_BLOCKING
		if (!iron_sheet.use(1))
			to_chat(user, span_warning("You need one sheet of iron to start building an ED-209!"))
			return ITEM_INTERACT_BLOCKING
		var/obj/item/bot_assembly/ed209/assembly = new(drop_location())
		to_chat(user, span_notice("You arm the robot frame."))
		var/held_index = user.is_holding(src)
		qdel(src)
		if (held_index)
			user.put_in_hand(assembly, held_index)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/bodypart/leg/left/robot))
		if(l_leg)
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		tool.icon_state = initial(tool.icon_state)
		tool.cut_overlays()
		l_leg = tool
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/bodypart/leg/right/robot))
		if(r_leg)
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		tool.icon_state = initial(tool.icon_state)
		tool.cut_overlays()
		r_leg = tool
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/bodypart/arm/left/robot))
		if(l_arm)
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		tool.icon_state = initial(tool.icon_state)
		tool.cut_overlays()
		l_arm = tool
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/bodypart/arm/right/robot))
		if(r_arm)
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		tool.icon_state = initial(tool.icon_state)//in case it is a dismembered robotic limb
		tool.cut_overlays()
		r_arm = tool
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/bodypart/chest/robot))
		var/obj/item/bodypart/chest/robot/new_chestpiece = tool
		if(chest)
			return ITEM_INTERACT_BLOCKING

		if(!new_chestpiece.wired)
			to_chat(user, span_warning("You need to attach wires to it first!"))
			return ITEM_INTERACT_BLOCKING

		if(!new_chestpiece.cell)
			to_chat(user, span_warning("You need to attach a cell to it first!"))
			return ITEM_INTERACT_BLOCKING

		if(!user.transferItemToLoc(new_chestpiece, src))
			return ITEM_INTERACT_BLOCKING

		new_chestpiece.icon_state = initial(new_chestpiece.icon_state) //in case it is a dismembered robotic limb
		new_chestpiece.cut_overlays()
		chest = new_chestpiece
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/bodypart/head/robot))
		var/obj/item/bodypart/head/robot/new_headpiece = tool
		if(locate(/obj/item/organ) in new_headpiece)
			to_chat(user, span_warning("There are organs inside [new_headpiece]!"))
			return ITEM_INTERACT_BLOCKING
		if(head)
			return ITEM_INTERACT_BLOCKING
		if(!new_headpiece.flash2 || !new_headpiece.flash1)
			to_chat(user, span_warning("You need to attach a flash to it first!"))
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(new_headpiece, src))
			return ITEM_INTERACT_BLOCKING
		new_headpiece.icon_state = initial(new_headpiece.icon_state)//in case it is a dismembered robotic limb
		new_headpiece.cut_overlays()
		head = new_headpiece
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/mmi))
		var/obj/item/mmi/potential_brain = tool
		if(!check_completion())
			to_chat(user, span_warning("The MMI must go in after everything else!"))
			return ITEM_INTERACT_BLOCKING
		if(!chest.cell)
			to_chat(user, span_warning("The endoskeleton still needs a power cell!"))
			return ITEM_INTERACT_BLOCKING
		if(!isturf(loc))
			to_chat(user, span_warning("You can't put [potential_brain] in, the frame has to be standing on the ground to be perfectly precise!"))
			return ITEM_INTERACT_BLOCKING
		if(!potential_brain.brain_check(user))
			return ITEM_INTERACT_BLOCKING

		var/mob/living/brain/brainmob = potential_brain.brainmob
		if(is_banned_from(brainmob.ckey, JOB_NAME_CYBORG) || brainmob.client.get_exp_living(TRUE) <= MINUTES_REQUIRED_BASIC || QDELETED(src) || QDELETED(brainmob) || QDELETED(user) || QDELETED(potential_brain) || !Adjacent(user))
			if(!QDELETED(potential_brain))
				to_chat(user, span_warning("[potential_brain] doesn't seem to fit!"))
			return ITEM_INTERACT_BLOCKING
		if(!user.temporarilyRemoveItemFromInventory(tool))
			return ITEM_INTERACT_BLOCKING

		var/mob/living/silicon/robot/nocell/final_product = new(get_turf(src))
		if(!final_product)
			return ITEM_INTERACT_BLOCKING
		if(potential_brain.laws && potential_brain.laws.id != DEFAULT_AI_LAWID)
			aisync = FALSE
			lawsync = FALSE
			final_product.laws = potential_brain.laws
			potential_brain.laws.associate(final_product)

		final_product.invisibility = 0
		//Transfer debug settings to new mob
		final_product.custom_name = created_name
		final_product.locked = panel_locked

		if(!aisync)
			lawsync = FALSE
			final_product.set_connected_ai(null)
		else if(forced_ai)
			final_product.set_connected_ai(forced_ai)
			final_product.notify_ai(AI_NOTIFICATION_NEW_BORG)

		if(lawsync)
			final_product.lawsync()
		else
			final_product.lawupdate = FALSE
			if(potential_brain.laws.id == DEFAULT_AI_LAWID)
				final_product.make_laws()

		final_product.job = JOB_NAME_CYBORG

		final_product.cell = chest.cell
		chest.cell.forceMove(final_product)

		tool.forceMove(final_product)//Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.
		QDEL_NULL(final_product.mmi) //we delete the mmi created by Initialize()
		final_product.mmi = tool //and give the real mmi to the borg.
		final_product.updatename(brainmob.client)
		// This canonizes that MMI'd cyborgs have memories of their previous life
		//brainmob.add_mob_memory(/datum/memory/was_cyborged, protagonist = brainmob.mind, deuteragonist = user)
		brainmob.mind.transfer_to(final_product)
		playsound(final_product.loc, 'sound/voice/liveagain.ogg', 75, TRUE)

		if(final_product.mind?.special_role)
			to_chat(final_product, span_userdanger("You have been robotized!"))
			to_chat(final_product, span_danger("You must obey your silicon laws and master AI above all else. Your objectives will consider you to be dead."))

		SSblackbox.record_feedback("amount", "cyborg_birth", 1)
		forceMove(final_product)
		final_product.robot_suit = src

		user.log_message("put the MMI/posibrain of [key_name(brainmob)] into a cyborg shell", LOG_GAME)
		brainmob.log_message("was put into a cyborg shell by [key_name(user)]", LOG_GAME, log_globally = FALSE)

		if(!locomotion)
			final_product.set_lockcharge(TRUE)
			to_chat(final_product, span_warning("Error: Servo motors unresponsive."))
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/borg/upgrade/ai))
		var/obj/item/borg/upgrade/ai/boris_module = tool
		if(!check_completion())
			return ITEM_INTERACT_BLOCKING
		if(!isturf(loc))
			to_chat(user, span_warning("You cannot install [boris_module], the frame has to be standing on the ground to be perfectly precise!"))
			return ITEM_INTERACT_BLOCKING
		if(!user.temporarilyRemoveItemFromInventory(boris_module))
			to_chat(user, span_warning("[boris_module] is stuck to your hand!"))
			return ITEM_INTERACT_BLOCKING
		qdel(boris_module)
		var/mob/living/silicon/robot/shell/final_product = new(get_turf(src))

		if(!aisync)
			lawsync = FALSE
			final_product.set_connected_ai(null)
		else if(forced_ai)
			final_product.set_connected_ai(forced_ai)
			final_product.notify_ai(AI_NOTIFICATION_AI_SHELL)

		if(!lawsync)
			final_product.lawupdate = FALSE
			final_product.make_laws()

		final_product.cell = chest.cell
		chest.cell.forceMove(final_product)

		final_product.locked = panel_locked
		final_product.job = JOB_NAME_CYBORG
		forceMove(final_product)
		final_product.robot_suit = src
		if(!locomotion)
			final_product.set_lockcharge(TRUE)
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/pen))
		to_chat(user, span_warning("You need to use a multitool to name [src]!"))
		return ITEM_INTERACT_BLOCKING

	return NONE

/obj/item/robot_suit/screwdriver_act(mob/living/user, obj/item/I) //Swaps the power cell if you're holding a new one in your other hand.
	if(!chest) //can't remove a cell if there's no chest to remove it from.
		to_chat(user, span_notice("[src] has no attached torso."))
		return ITEM_INTERACT_BLOCKING

	var/obj/item/stock_parts/cell/temp_cell = user.is_holding_item_of_type(/obj/item/stock_parts/cell)
	var/swap_failed
	if(!temp_cell) //if we're not holding a cell
		swap_failed = TRUE
	else if(!user.transferItemToLoc(temp_cell, chest))
		swap_failed = TRUE
		to_chat(user, span_warning("[temp_cell] is stuck to your hand, you can't put it in [src]!"))

	if(chest.cell) //drop the chest's current cell no matter what.
		put_in_hand_or_drop(user, chest.cell)

	if(swap_failed) //we didn't transfer any new items.
		if(chest.cell) //old cell ejected, nothing inserted.
			to_chat(user, span_notice("You remove [chest.cell] from [src]."))
			chest.cell = null
		else
			to_chat(user, span_notice("The power cell slot in [src]'s torso is empty."))
		return

	to_chat(user, span_notice("You [chest.cell ? "replace [src]'s [chest.cell.name] with [temp_cell]" : "insert [temp_cell] into [src]"]."))
	chest.cell = temp_cell
	return ITEM_INTERACT_SUCCESS

/obj/item/robot_suit/wrench_act(mob/living/user, obj/item/tool) //Deconstucts empty borg shell. Flashes remain unbroken because they haven't been used yet
	if(l_leg || r_leg || chest || l_arm || r_arm || head)
		if(!tool.use_tool(src, user, 0.5 SECONDS, volume = 50))
			return ITEM_INTERACT_BLOCKING
		drop_all_parts()
		to_chat(user, span_notice("You disassemble the cyborg shell."))
		return ITEM_INTERACT_SUCCESS

	to_chat(user, span_warning("There is nothing to remove from the endoskeleton!"))

/obj/item/robot_suit/multitool_act(mob/living/user, obj/item/tool)
	if(!check_completion())
		to_chat(user, span_warning("The endoskeleton must be assembled before debugging can begin!"))
		return ITEM_INTERACT_BLOCKING
	ui_interact(user)
	return ITEM_INTERACT_SUCCESS

/obj/item/robot_suit/proc/check_completion()
	if(l_arm && r_arm && l_leg && r_leg && head && head.flash1 && head.flash2 && chest && chest.wired && chest.cell)
		SSblackbox.record_feedback("amount", "cyborg_frames_built", 1)
		return TRUE
	return FALSE

/// Drops all included parts to the passed location
/// This will also dissassemble the parts being dropped into components as well
/obj/item/robot_suit/proc/drop_all_parts(atom/drop_to = drop_location())
	l_leg?.forceMove(drop_to)
	r_leg?.forceMove(drop_to)
	l_arm?.forceMove(drop_to)
	r_arm?.forceMove(drop_to)

	var/obj/item/bodypart/chest/robot/removed_chest = chest
	if(removed_chest)
		removed_chest.forceMove(drop_to)
		removed_chest.drop_organs()

	var/obj/item/bodypart/head/robot/removed_head = head
	if(removed_head)
		removed_head.forceMove(drop_to)
		removed_head.drop_organs()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/robot_suit/proc/put_in_hand_or_drop(mob/living/user, obj/item/I) //normal put_in_hands() drops the item ontop of the player, this drops it at the suit's loc
	if(!user.put_in_hands(I))
		I.forceMove(drop_location())
		return FALSE
	return TRUE

/obj/item/robot_suit/ui_status(mob/user, datum/ui_state/state)
	if(isobserver(user))
		return ..()
	var/obj/item/held_item = user.get_active_held_item()
	if(held_item?.tool_behaviour == TOOL_MULTITOOL)
		return ..()
	to_chat(user, span_warning("You need a multitool to access debug settings!"))
	return UI_CLOSE

/obj/item/robot_suit/ui_state(mob/user)
	return GLOB.physical_state

/obj/item/robot_suit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CyborgBootDebug", "Cyborg Boot Debug")
		ui.open()

/obj/item/robot_suit/ui_data(mob/user)
	var/list/data = list()
	data["designation"] = created_name
	data["locomotion"] = locomotion
	data["panel"] = panel_locked
	data["aisync"] = aisync
	data["master"] = forced_ai_name
	data["lawsync"] = lawsync
	return data

/obj/item/robot_suit/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/living/user = ui.user

	switch(action)
		if("rename")
			var/new_name = reject_bad_name(html_encode(params["new_name"]), TRUE)
			if(!new_name)
				created_name = ""
				return FALSE
			created_name = new_name
			log_game("[key_name(user)] has set \"[new_name]\" as a cyborg shell name at [loc_name(user)]")
			return TRUE
		if("locomotion")
			locomotion = !locomotion
			log_game("[key_name(user)] has [locomotion ? "enabled" : "disabled"] movement on a cyborg shell at [loc_name(user)]")
			return TRUE
		if("panel")
			panel_locked = !panel_locked
			log_game("[key_name(user)] has [panel_locked ? "locked" : "unlocked"] the panel on a cyborg shell at [loc_name(user)]")
			return TRUE
		if("aisync")
			aisync = !aisync
			log_game("[key_name(user)] has [aisync ? "enabled" : "disabled"] the AI sync for a cyborg shell at [loc_name(user)]")
			return TRUE
		if("set_ai")
			// clear our AI if it's already configured
			if(forced_ai)
				clear_forced_ai()
				to_chat(user, span_notice("You reset [src]'s AI setting."))
				return TRUE
			if(!length(active_ais(FALSE, get_virtual_z_level())))
				to_chat(user, span_alert("No active AIs detected."))
				return FALSE

			var/selected_ai = select_active_ai(user, get_virtual_z_level()) // this one runs input()
			if(!in_range(src, user) && loc != user)
				return FALSE
			if(!selected_ai) // null = clear
				clear_forced_ai()
				return TRUE

			set_forced_ai(selected_ai, user)
			to_chat(user, span_notice("You set [src]'s AI setting to [forced_ai_name]."))
			log_game("[key_name(user)] set the default AI for a cyborg shell to [key_name(selected_ai)] at [loc_name(user)]")
			return TRUE

		if("lawsync")
			lawsync = !lawsync
			log_game("[key_name(user)] has [lawsync ? "enabled" : "disabled"] the law sync for a cyborg shell at [loc_name(user)]")
			return TRUE

/// Sets [forced_ai] and [forced_ai_name] to the passed AI
/obj/item/robot_suit/proc/set_forced_ai(mob/living/silicon/ai/ai)
	forced_ai = ai
	forced_ai_name = ai.name
	RegisterSignal(ai, COMSIG_QDELETING, PROC_REF(ai_die))

/// Clears [forced_ai] and [forced_ai_name]
/obj/item/robot_suit/proc/clear_forced_ai()
	if(forced_ai)
		UnregisterSignal(forced_ai, COMSIG_QDELETING)
		forced_ai = null
	forced_ai_name = null

/// Clears the forced_ai ref
/obj/item/robot_suit/proc/ai_die(datum/source)
	SIGNAL_HANDLER
	// Does not use [proc/clear_forced_ai] because we'd like to keep the AI name tracked for metagaming purposes
	UnregisterSignal(forced_ai, COMSIG_QDELETING)
	forced_ai = null

/obj/item/robot_suit/prebuilt/Initialize(mapload)
	. = ..()
	l_arm = new(src)
	r_arm = new(src)
	l_leg = new(src)
	r_leg = new(src)
	head = new(src)
	head.flash1 = new(head)
	head.flash2 = new(head)
	chest = new(src)
	chest.wired = TRUE
	chest.cell = new /obj/item/stock_parts/cell/high/plus(chest)
	update_appearance(UPDATE_OVERLAYS)
