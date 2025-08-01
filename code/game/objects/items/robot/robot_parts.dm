

//The robot bodyparts have been moved to code/module/surgery/bodyparts/robot_bodyparts.dm


/obj/item/robot_suit
	name = "cyborg endoskeleton"
	desc = "A complex metal backbone with standard limb sockets and pseudomuscle anchors."
	icon = 'icons/mob/augmentation/augments.dmi'
	icon_state = "robo_suit"
	var/obj/item/bodypart/l_arm/robot/l_arm = null
	var/obj/item/bodypart/r_arm/robot/r_arm = null
	var/obj/item/bodypart/l_leg/robot/l_leg = null
	var/obj/item/bodypart/r_leg/robot/r_leg = null
	var/obj/item/bodypart/chest/robot/chest = null
	var/obj/item/bodypart/head/robot/head = null

	var/created_name = ""
	var/mob/living/silicon/ai/forced_ai
	var/locomotion = 1
	var/lawsync = 1
	var/aisync = 1
	var/panel_locked = TRUE

/obj/item/robot_suit/Initialize(mapload)
	. = ..()
	update_icon()

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
	update_icon()

/obj/item/robot_suit/update_overlays()
	. = ..()
	if(l_arm)
		. += "[l_arm.icon_state]+o"
	if(r_arm)
		. += "[r_arm.icon_state]+o"
	if(chest)
		. += "[chest.icon_state]+o"
	if(l_leg)
		. += "[l_leg.icon_state]+o"
	if(r_leg)
		. += "[r_leg.icon_state]+o"
	if(head)
		. += "[head.icon_state]+o"

/obj/item/robot_suit/proc/check_completion()
	if(src.l_arm && src.r_arm)
		if(src.l_leg && src.r_leg)
			if(src.chest && src.head)
				SSblackbox.record_feedback("amount", "cyborg_frames_built", 1)
				return 1
	return 0

/obj/item/robot_suit/wrench_act(mob/living/user, obj/item/I) //Deconstucts empty borg shell. Flashes remain unbroken because they haven't been used yet
	var/turf/T = get_turf(src)
	if(l_leg || r_leg || chest || l_arm || r_arm || head)
		if(I.use_tool(src, user, 5, volume=50))
			if(l_leg)
				l_leg.forceMove(T)
				l_leg = null
			if(r_leg)
				r_leg.forceMove(T)
				r_leg = null
			if(chest)
				if (chest.cell) //Sanity check.
					chest.cell.forceMove(T)
					chest.cell = null
				chest.forceMove(T)
				new /obj/item/stack/cable_coil(T, 1)
				chest.wired = FALSE
				chest = null
			if(l_arm)
				l_arm.forceMove(T)
				l_arm = null
			if(r_arm)
				r_arm.forceMove(T)
				r_arm = null
			if(head)
				head.forceMove(T)
				head.flash1.forceMove(T)
				head.flash1 = null
				head.flash2.forceMove(T)
				head.flash2 = null
				head = null
			to_chat(user, span_notice("You disassemble the cyborg shell."))
	else
		to_chat(user, span_notice("There is nothing to remove from the endoskeleton."))
	update_icon()

/obj/item/robot_suit/proc/put_in_hand_or_drop(mob/living/user, obj/item/I) //normal put_in_hands() drops the item ontop of the player, this drops it at the suit's loc
	if(!user.put_in_hands(I))
		I.forceMove(drop_location())
		return FALSE
	return TRUE

/obj/item/robot_suit/screwdriver_act(mob/living/user, obj/item/I) //Swaps the power cell if you're holding a new one in your other hand.
	. = ..()
	if(.)
		return TRUE

	if(!chest) //can't remove a cell if there's no chest to remove it from.
		to_chat(user, span_notice("[src] has no attached torso."))
		return

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
	return TRUE

/obj/item/robot_suit/attackby(obj/item/W, mob/user, params)

	if(istype(W, /obj/item/stack/sheet/iron))
		var/obj/item/stack/sheet/iron/M = W
		if(!l_arm && !r_arm && !l_leg && !r_leg && !chest && !head)
			if (M.use(1))
				var/obj/item/bot_assembly/ed209/B = new
				B.forceMove(drop_location())
				to_chat(user, span_notice("You arm the robot frame."))
				var/holding_this = user.get_inactive_held_item()==src
				qdel(src)
				if (holding_this)
					user.put_in_inactive_hand(B)
			else
				to_chat(user, span_warning("You need one sheet of iron to start building ED-209!"))
				return
	else if(istype(W, /obj/item/bodypart/l_leg/robot))
		if(l_leg)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)
		W.cut_overlays()
		l_leg = W
		update_icon()

	else if(istype(W, /obj/item/bodypart/r_leg/robot))
		if(src.r_leg)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)
		W.cut_overlays()
		r_leg = W
		update_icon()

	else if(istype(W, /obj/item/bodypart/l_arm/robot))
		if(l_arm)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)
		W.cut_overlays()
		l_arm = W
		update_icon()

	else if(istype(W, /obj/item/bodypart/r_arm/robot))
		if(r_arm)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)//in case it is a dismembered robotic limb
		W.cut_overlays()
		r_arm = W
		update_icon()

	else if(istype(W, /obj/item/bodypart/chest/robot))
		var/obj/item/bodypart/chest/robot/CH = W
		if(chest)
			return
		if(CH.wired && CH.cell)
			if(!user.transferItemToLoc(CH, src))
				return
			CH.icon_state = initial(CH.icon_state) //in case it is a dismembered robotic limb
			CH.cut_overlays()
			chest = CH
			update_icon()
		else if(!CH.wired)
			to_chat(user, span_warning("You need to attach wires to it first!"))
		else
			to_chat(user, span_warning("You need to attach a cell to it first!"))

	else if(istype(W, /obj/item/bodypart/head/robot))
		var/obj/item/bodypart/head/robot/HD = W
		for(var/X in HD.contents)
			if(istype(X, /obj/item/organ))
				to_chat(user, span_warning("There are organs inside [HD]!"))
				return
		if(head)
			return
		if(HD.flash2 && HD.flash1)
			if(!user.transferItemToLoc(HD, src))
				return
			HD.icon_state = initial(HD.icon_state)//in case it is a dismembered robotic limb
			HD.cut_overlays()
			head = HD
			update_icon()
		else
			to_chat(user, span_warning("You need to attach a flash to it first!"))

	else if (W.tool_behaviour == TOOL_MULTITOOL)
		if(check_completion())
			Interact(user)
		else
			to_chat(user, span_warning("The endoskeleton must be assembled before debugging can begin!"))

	else if(istype(W, /obj/item/mmi))
		var/obj/item/mmi/M = W
		if(check_completion())
			if(!chest.cell)
				to_chat(user, span_warning("The endoskeleton still needs a power cell!"))
				return
			if(!isturf(loc))
				to_chat(user, span_warning("You can't put [M] in, the frame has to be standing on the ground to be perfectly precise!"))
				return
			if(!M.brainmob)
				to_chat(user, span_warning("Sticking an empty [M.name] into the frame would sort of defeat the purpose!"))
				return

			var/mob/living/brain/BM = M.brainmob
			if(!BM.key || !BM.mind)
				to_chat(user, span_warning("The MMI indicates that their mind is completely unresponsive; there's no point!"))
				return

			if(!BM.client) //braindead
				to_chat(user, span_warning("The MMI indicates that their mind is currently inactive; it might change!"))
				return

			if(BM.stat == DEAD || BM.suiciding || (M.brain && (M.brain.brain_death || M.brain.suicided)))
				to_chat(user, span_warning("Sticking a dead brain into the frame would sort of defeat the purpose!"))
				return

			if(M.brain?.organ_flags & ORGAN_FAILING)
				to_chat(user, span_warning("The MMI indicates that the brain is damaged!"))
				return

			if(is_banned_from(BM.ckey, JOB_NAME_CYBORG) || BM.client.get_exp_living(TRUE) <= MINUTES_REQUIRED_BASIC)
				to_chat(user, span_warning("This [M.name] is not compatible, try a different one!"))
				return

			if(QDELETED(src) || QDELETED(BM) || QDELETED(user) || !Adjacent(user))
				if(!QDELETED(M))
					to_chat(user, span_warning("This [M.name] does not seem to fit!"))
				return

			if(!user.temporarilyRemoveItemFromInventory(W))
				return

			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot/nocell(get_turf(loc), user)
			if(!O)
				return

			if(M.laws && M.laws.id != DEFAULT_AI_LAWID)
				aisync = 0
				lawsync = 0
				O.laws = M.laws
				M.laws.associate(O)

			O.invisibility = 0
			//Transfer debug settings to new mob
			O.custom_name = created_name
			O.locked = panel_locked
			if(!aisync)
				lawsync = 0
				O.connected_ai = null
			else
				O.notify_ai(NEW_BORG)
				if(forced_ai)
					O.connected_ai = forced_ai
			if(!lawsync)
				O.lawupdate = FALSE
				if(M.laws.id == DEFAULT_AI_LAWID)
					O.make_laws()

			O.job = JOB_NAME_CYBORG

			O.cell = chest.cell
			chest.cell.forceMove(O)
			chest.cell = null
			W.forceMove(O)//Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.
			if(O.mmi) //we delete the mmi created by robot/New()
				qdel(O.mmi)
			O.mmi = W //and give the real mmi to the borg.

			O.updatename(BM.client)

			BM.mind.transfer_to(O)

			if(O.mind?.special_role)
				O.mind.store_memory("As a cyborg, you must obey your silicon laws and master AI above all else. Your objectives will consider you to be dead.")
				to_chat(O, span_userdanger("You have been robotized!"))
				to_chat(O, span_danger("You must obey your silicon laws and master AI above all else. Your objectives will consider you to be dead."))

			SSblackbox.record_feedback("amount", "cyborg_birth", 1)
			forceMove(O)
			O.robot_suit = src

			if(!locomotion)
				O.set_lockcharge(TRUE)
				to_chat(O, span_warning("Error: Servo motors unresponsive."))

		else
			to_chat(user, span_warning("The MMI must go in after everything else!"))

	else if(istype(W, /obj/item/borg/upgrade/ai))
		var/obj/item/borg/upgrade/ai/M = W
		if(check_completion())
			if(!chest.cell)
				to_chat(user, span_warning("The endoskeleton still needs a power cell!"))
				return
			if(!isturf(loc))
				to_chat(user, span_warning("You cannot install[M], the frame has to be standing on the ground to be perfectly precise!"))
				return
			if(!user.temporarilyRemoveItemFromInventory(M))
				to_chat(user, span_warning("[M] is stuck to your hand!"))
				return
			qdel(M)
			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot/shell(get_turf(src))

			if(!aisync)
				lawsync = FALSE
				O.connected_ai = null
			else
				if(forced_ai)
					O.connected_ai = forced_ai
				O.notify_ai(AI_SHELL)
			if(!lawsync)
				O.lawupdate = FALSE
				O.make_laws()


			O.cell = chest.cell
			chest.cell.forceMove(O)
			chest.cell = null
			O.locked = panel_locked
			O.job = JOB_NAME_CYBORG
			forceMove(O)
			O.robot_suit = src
			if(!locomotion)
				O.set_lockcharge(TRUE)

	else if(istype(W, /obj/item/pen))
		to_chat(user, span_warning("You need to use a multitool to name [src]!"))
	else
		return ..()

/obj/item/robot_suit/proc/Interact(mob/user)
			var/t1 = "Designation: <A href='byond://?src=[REF(src)];Name=1'>[(created_name ? "[created_name]" : "Default Cyborg")]</a><br>\n"
			t1 += "Master AI: <A href='byond://?src=[REF(src)];Master=1'>[(forced_ai ? "[forced_ai.name]" : "Automatic")]</a><br><br>\n"

			t1 += "LawSync Port: <A href='byond://?src=[REF(src)];Law=1'>[(lawsync ? "Open" : "Closed")]</a><br>\n"
			t1 += "AI Connection Port: <A href='byond://?src=[REF(src)];AI=1'>[(aisync ? "Open" : "Closed")]</a><br>\n"
			t1 += "Servo Motor Functions: <A href='byond://?src=[REF(src)];Loco=1'>[(locomotion ? "Unlocked" : "Locked")]</a><br>\n"
			t1 += "Panel Lock: <A href='byond://?src=[REF(src)];Panel=1'>[(panel_locked ? "Engaged" : "Disengaged")]</a><br>\n"
			var/datum/browser/popup = new(user, "robotdebug", "Cyborg Boot Debug", 310, 220)
			popup.set_content(t1)
			popup.open()

/obj/item/robot_suit/Topic(href, href_list)
	if(usr.incapacitated() || !Adjacent(usr))
		return

	var/mob/living/living_user = usr
	var/obj/item/item_in_hand = living_user.get_active_held_item()
	if(!item_in_hand || item_in_hand.tool_behaviour != TOOL_MULTITOOL)
		to_chat(living_user, span_warning("You need a multitool!"))
		return

	if(href_list["Name"])
		var/new_name = reject_bad_name(input(usr, "Enter new designation. Set to blank to reset to default.", "Cyborg Debug", src.created_name),1)
		if(!in_range(src, usr) && src.loc != usr)
			return
		if(new_name)
			created_name = new_name
			log_game("[key_name(usr)] have set \"[new_name]\" as a cyborg shell name at [loc_name(usr)]")
		else
			created_name = ""

	else if(href_list["Master"])
		forced_ai = select_active_ai(usr)
		if(!forced_ai)
			to_chat(usr, span_error("No active AIs detected."))

	else if(href_list["Law"])
		lawsync = !lawsync
	else if(href_list["AI"])
		aisync = !aisync
	else if(href_list["Loco"])
		locomotion = !locomotion
	else if(href_list["Panel"])
		panel_locked = !panel_locked

	add_fingerprint(usr)
	Interact(usr)
