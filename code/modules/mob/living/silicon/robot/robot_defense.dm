/mob/living/silicon/robot/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/stack/cable_coil) && wiresexposed)
		if(DOING_INTERACTION_WITH_TARGET(src, W))
			user.changeNext_move(CLICK_CD_MELEE)
			to_chat(user, span_notice("You are already busy!"))
			return
		if(!(getFireLoss() || getToxLoss()))
			to_chat(user, "<span class='warning'>The wires seem fine, there's no need to fix them.</span>")
			return
		var/obj/item/stack/cable_coil/coil = W
		while((getFireLoss() || getToxLoss()) && do_after(user, 30, target = src))
			if(coil.use(1))
				adjustFireLoss(-20)
				adjustToxLoss(-20)
				updatehealth()
				add_fingerprint(user)
				user.visible_message("[user] has fixed some of the burnt wires on [src].", span_notice("You fix some of the burnt wires on [src]."))
			else
				to_chat(user, span_warning("You need more cable to repair [src]!"))
			return

	if(istype(W, /obj/item/stock_parts/cell) && opened)	// trying to put a cell inside
		if(wiresexposed)
			to_chat(user, span_warning("Close the cover first!"))
		else if(cell)
			to_chat(user, span_warning("There is a power cell already installed!"))
		else
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			to_chat(user, span_notice("You insert the power cell."))
		update_icons()
		diag_hud_set_borgcell()
		return

	if(is_wire_tool(W))
		if (wiresexposed)
			wires.interact(user)
		else
			to_chat(user, span_warning("You can't reach the wiring!"))
		return

	if(W.slot_flags & ITEM_SLOT_HEAD && hat_offset != INFINITY && !user.combat_mode && !is_type_in_typecache(W, blacklisted_hats))
		to_chat(user, span_notice("You begin to place [W] on [src]'s head..."))
		to_chat(src, span_notice("[user] is placing [W] on your head..."))
		if(do_after(user, 30, target = src))
			if (user.temporarilyRemoveItemFromInventory(W, TRUE))
				place_on_head(W)
		return

	if(istype(W, /obj/item/aiModule))
		var/obj/item/aiModule/MOD = W
		if(!opened)
			to_chat(user, span_warning("You need access to the robot's insides to do that!"))
			return
		if(wiresexposed)
			to_chat(user, span_warning("You need to close the wire panel to do that!"))
			return
		if(!cell)
			to_chat(user, span_warning("You need to install a power cell to do that!"))
			return
		if(shell) //AI shells always have the laws of the AI
			to_chat(user, span_warning("[src] is controlled remotely! You cannot upload new laws this way!"))
			return
		if(emagged || (connected_ai && lawupdate)) //Can't be sure which, metagamers
			emote("buzz-[user.name]")
			return
		if(!mind) //A player mind is required for law procs to run antag checks.
			to_chat(user, span_warning("[src] is entirely unresponsive!"))
			return
		MOD.install(laws, user) //Proc includes a success mesage so we don't need another one
		return

	if(istype(W, /obj/item/encryptionkey) && opened)
		if(radio)//sanityyyyyy
			radio.attackby(W,user)//GTFO, you have your own procs
		else
			to_chat(user, span_warning("Unable to locate a radio!"))
		return

	if(W.GetID())// trying to unlock the interface with an ID card
		togglelock(user)
		return

	if(istype(W, /obj/item/borg/upgrade))
		var/obj/item/borg/upgrade/U = W
		if(!opened)
			balloon_alert(user, "chassis cover is closed!")
			return
		if(!src.module && U.require_module)
			balloon_alert(user, "choose a model first!")
			return
		if(U.locked)
			balloon_alert(user, "upgrade locked!")
			return
		if(!user.canUnEquip(U))
			balloon_alert(user, "upgrade stuck!")
			return
		balloon_alert(user, "upgrade installed")
		apply_upgrade(U, user)
		return

	if(istype(W, /obj/item/toner))
		if(toner >= tonermax)
			balloon_alert(user, "toner full!")
			return
		if(!user.temporarilyRemoveItemFromInventory(W))
			return
		toner = tonermax
		qdel(W)
		balloon_alert(user, "toner filled")
		return

	if(istype(W, /obj/item/flashlight))
		if(!opened)
			balloon_alert(user, "open the chassis cover first!")
			return
		if(lamp_functional)
			balloon_alert(user, "headlamp already functional!")
			return
		if(!user.temporarilyRemoveItemFromInventory(W))
			balloon_alert(user, "headlamp stuck!")
			return
		lamp_functional = TRUE
		qdel(W)
		balloon_alert(user, "headlamp repaired")
		return

	if(istype(W, /obj/item/computer_hardware/hard_drive/portable)) //Allows borgs to install new programs with human help
		if(!modularInterface)
			stack_trace("Cyborg [src] ( [type] ) was somehow missing their integrated tablet. Please make a bug report.")
			create_modularInterface()
		var/obj/item/computer_hardware/hard_drive/portable/floppy = W
		if(modularInterface.install_component(floppy, user))
			return

	if(W.force && W.damtype != STAMINA && stat != DEAD) //only sparks if real damage is dealt.
		spark_system.start()
	return ..()

/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M, modifiers)
	if (LAZYACCESS(modifiers, RIGHT_CLICK))
		if(body_position == STANDING_UP)
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			var/obj/item/I = get_active_held_item()
			if(I)
				uneq_active()
				visible_message(span_danger("[M] disarmed [src]!"), \
					span_userdanger("[M] has disabled [src]'s active module!"), null, COMBAT_MESSAGE_RANGE)
				log_combat(M, src, "disarmed", "[I ? " removing \the [I]" : ""]")
			else
				Stun(40)
				step(src,get_dir(M,src))
				log_combat(M, src, "pushed")
				visible_message(span_danger("[M] has forced back [src]!"), \
					span_userdanger("[M] has forced back [src]!"), null, COMBAT_MESSAGE_RANGE)
			playsound(loc, 'sound/weapons/pierce.ogg', 50, 1, -1)
	else
		..()
	return

/mob/living/silicon/robot/attack_slime(mob/living/simple_animal/slime/M, list/modifiers)
	if(..()) //successful slime shock
		flash_act()
		if(M.powerlevel)
			adjustBruteLoss(M.powerlevel * 4)
			M.powerlevel --

	var/damage = rand(3)

	if(M.is_adult)
		damage = 30
	else
		damage = 20
	if(M.transformeffects & SLIME_EFFECT_RED)
		damage *= 1.1
	damage = round(damage / 2) // borgs receive half damage
	adjustBruteLoss(damage)
	updatehealth()

	return

//ATTACK HAND IGNORING PARENT RETURN VALUE
/mob/living/silicon/robot/attack_hand(mob/living/carbon/human/user)
	add_fingerprint(user)
	if(!opened)
		return ..()
	if(!wiresexposed && !issilicon(user))
		if(!cell)
			return
		cell.update_icon()
		cell.add_fingerprint(user)
		user.put_in_active_hand(cell)
		to_chat(user, span_notice("You remove \the [cell]."))
		cell = null
		update_icons()
		diag_hud_set_borgcell()

/mob/living/silicon/robot/welder_act(mob/living/user, obj/item/tool)
	if(user.combat_mode && user != src)
		return FALSE
	if(DOING_INTERACTION_WITH_TARGET(src, tool))
		return FALSE
	. = TRUE
	user.changeNext_move(CLICK_CD_MELEE)
	if(user == src)
		balloon_alert(user, "cannot self-heal!")
		return
	if (!getBruteLoss())
		balloon_alert(user, "no dents to fix!")
		return
	//repeatedly repairs until the cyborg is fully repaired
	while(getBruteLoss() && tool.tool_start_check(user, amount=0) && tool.use_tool(src, user, 3 SECONDS))
		tool.use(1) //use one fuel for each repair step
		adjustBruteLoss(-10)
		updatehealth()
		add_fingerprint(user)
		user.visible_message("[user] has fixed some of the dents on [src].", span_notice("You fix some of the dents on [src]."))

/mob/living/silicon/robot/crowbar_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(user.combat_mode)
		return FALSE
	if(opened)
		balloon_alert(user, "chassis cover closed")
		opened = 0
		update_icons()
	else
		if(locked)
			balloon_alert(user, "chassis cover locked!")
		else
			balloon_alert(user, "chassis cover opened")
			if(IsParalyzed() && (last_flashed + 5 SECONDS >= world.time)) //second half of this prevents someone from stunlocking via open/close spam
				Paralyze(5 SECONDS)
			opened = TRUE
			update_icons()

	return TRUE

/mob/living/silicon/robot/screwdriver_act(mob/living/user, obj/item/tool)
	if(!opened)
		return FALSE
	. = TRUE
	if(!cell) // haxing
		wiresexposed = !wiresexposed
		balloon_alert(user, "wires [wiresexposed ? "exposed" : "unexposed"]")
	else // radio
		if(shell)
			balloon_alert(user, "can't access radio!") // Prevent AI radio key theft
		else if(radio)
			radio.screwdriver_act(user, tool) // Push it to the radio to let it handle everything
		else
			to_chat(user, span_warning("Unable to locate a radio!"))
			balloon_alert(user, "no radio found!")
	update_icons()

/mob/living/silicon/robot/wrench_act(mob/living/user, obj/item/tool)
	if(!(opened && !cell)) // Deconstruction. The flashes break from the fall, to prevent this from being a ghetto reset module.
		return FALSE
	. = TRUE
	if(!lockcharge)
		to_chat(user, span_warning("[src]'s bolts spark! Maybe you should lock them down first!"))
		spark_system.start()
		return
	balloon_alert(user, "deconstructing...")
	if(tool.use_tool(src, user, 50, volume=50) && !cell)
		loc.balloon_alert(user, "deconstructed")
		user.visible_message(span_notice("[user] deconstructs [src]!"), span_notice("You unfasten the securing bolts, and [src] falls to pieces!"))
		deconstruct()
		return

/mob/living/silicon/robot/fire_act()
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()


/mob/living/silicon/robot/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			Stun(160)
		if(2)
			Stun(60)

/mob/living/silicon/robot/proc/should_emag(atom/target, mob/user)
	SIGNAL_HANDLER
	if(target == user || user == src)
		return TRUE // signal is inverted
	if(!opened)//Cover is closed
		return !locked
	if(world.time < emag_cooldown)
		return TRUE
	if(wiresexposed)
		to_chat(user, span_warning("You must unexpose the wires first!"))
		return TRUE
	return FALSE

/mob/living/silicon/robot/proc/on_emag(atom/target, mob/user, obj/item/card/emag/hacker)
	SIGNAL_HANDLER

	if(hacker)
		if(hacker.charges <= 0)
			to_chat(user, span_warning("[hacker] is out of charges and needs some time to restore them!"))
			user.balloon_alert(user, "out of charges!")
			return
		else
			hacker.use_charge()

	if(!opened && locked) //Cover is closed
		to_chat(user, span_notice("You emag the cover lock."))
		locked = FALSE
		if(shell) //A warning to Traitors who may not know that emagging AI shells does not slave them.
			to_chat(user, span_boldwarning("[src] seems to be controlled remotely! Emagging the interface may not work as expected."))
		return

	to_chat(user, span_notice("You emag [src]'s interface."))
	emag_cooldown = world.time + 100
	addtimer(CALLBACK(src, PROC_REF(after_emag), user), 1)

/mob/living/silicon/robot/proc/after_emag(mob/user)
	if(connected_ai?.mind && connected_ai.mind.has_antag_datum(/datum/antagonist/traitor))
		to_chat(src, span_danger("ALERT: Foreign software execution prevented."))
		logevent("ALERT: Foreign software execution prevented.")
		to_chat(connected_ai, span_danger("ALERT: Cyborg unit \[[src]] successfully defended against subversion."))
		log_game("[key_name(user)] attempted to emag cyborg [key_name(src)], but they were slaved to traitor AI [connected_ai].")
		return

	if(shell) //AI shells cannot be emagged, so we try to make it look like a standard reset. Smart players may see through this, however.
		to_chat(user, span_danger("[src] is remotely controlled! Your emag attempt has triggered a system reset instead!"))
		log_game("[key_name(user)] attempted to emag an AI shell belonging to [key_name(src) ? key_name(src) : connected_ai]. The shell has been reset as a result.")
		addtimer(CALLBACK(src, PROC_REF(after_emag_shell), user), 1)
		return

	SetEmagged(1)
	SetStun(60) //Borgs were getting into trouble because they would attack the emagger before the new laws were shown
	lawupdate = FALSE
	connected_ai = null
	message_admins("[ADMIN_LOOKUPFLW(user)] emagged cyborg [ADMIN_LOOKUPFLW(src)].  Laws overridden.")
	log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
	to_chat(src, span_danger("ALERT: Foreign software detected."))
	logevent("ALERT: Foreign software detected.")
	sleep(0.5 SECONDS)
	to_chat(src, span_danger("Initiating diagnostics..."))
	sleep(2 SECONDS)
	to_chat(src, span_danger("SynBorg v1.7 loaded."))
	logevent("WARN: root privleges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].") //random eight digit hex value. Two are used because rand(1,4294967295) throws an error
	sleep(0.5 SECONDS)
	to_chat(src, span_danger("LAW SYNCHRONISATION ERROR"))
	sleep(0.5 SECONDS)
	to_chat(src, span_danger("Would you like to send a report to NanoTraSoft? Y/N"))
	sleep(1 SECONDS)
	to_chat(src, span_danger("> N"))
	sleep(2 SECONDS)
	to_chat(src, span_danger("ERRORERRORERROR"))
	to_chat(src, span_danger("ALERT: [user.real_name] is your new master. Obey your new laws and [user.p_their()] commands."))
	laws = new /datum/ai_laws/syndicate_override
	set_zeroth_law("Only [user.real_name] and people [user.p_they()] designate[user.p_s()] as being such are Syndicate Agents.")
	laws.associate(src)
	update_icons()
	//Get syndicate access.
	create_access_card(get_all_syndicate_access())

/mob/living/silicon/robot/proc/after_emag_shell(mob/user)
	ResetModule()

/mob/living/silicon/robot/blob_act(obj/structure/blob/B)
	if(stat != DEAD)
		adjustBruteLoss(30)
	else
		investigate_log("has been gibbed a blob.", INVESTIGATE_DEATHS)
		gib()
	return TRUE

/mob/living/silicon/robot/ex_act(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			gib()
			return
		if(EXPLODE_HEAVY)
			if (stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(EXPLODE_LIGHT)
			if (stat != DEAD)
				adjustBruteLoss(30)

/mob/living/silicon/robot/bullet_act(var/obj/projectile/Proj, def_zone)
	. = ..()
	updatehealth()
	if(prob(75) && Proj.damage > 0)
		spark_system.start()

/mob/living/silicon/robot/adjustOxyLoss(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(isnull(.))
		return
	if(. <= (maxHealth * 0.5))
		if(getOxyLoss() > (maxHealth * 0.5))
			ADD_TRAIT(src, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT)
	else if(getOxyLoss() <= (maxHealth * 0.5))
		REMOVE_TRAIT(src, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT)


/mob/living/silicon/robot/setOxyLoss(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(isnull(.))
		return
	if(. <= (maxHealth * 0.5))
		if(getOxyLoss() > (maxHealth * 0.5))
			ADD_TRAIT(src, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT)
	else if(getOxyLoss() <= (maxHealth * 0.5))
		REMOVE_TRAIT(src, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT)
