/mob/living/silicon/robot/attackby(obj/item/I, mob/living/user, params)
	if(I.slot_flags & ITEM_SLOT_HEAD && hat_offset != INFINITY && !user.combat_mode && !is_type_in_typecache(I, blacklisted_hats))
		to_chat(user, span_notice("You begin to place [I] on [src]'s head..."))
		to_chat(src, span_notice("[user] is placing [I] on your head..."))
		if(do_after(user, 30, target = src))
			if (user.temporarilyRemoveItemFromInventory(I, TRUE))
				place_on_head(I)
		return
	if(I.force && I.damtype != STAMINA && stat != DEAD) //only sparks if real damage is dealt.
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

/mob/living/silicon/robot/fire_act()
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		IgniteMob()


/mob/living/silicon/robot/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	trigger_malfunction(TRUE)

/mob/living/silicon/robot/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash/static)
	if(affect_silicon)
		trigger_malfunction(FALSE)
		return ..()

///Sensors are overwhelmed by EMP/flash
/mob/living/silicon/robot/proc/trigger_malfunction(major_malfunction = FALSE)

	//Apply the basic slowdown status effect regardless of what caused the malfunction
	apply_status_effect(/datum/status_effect/cyborg_malfunction)
	playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, 1, 1)

	//If the malfunction was caused by EMP instead of simply flash, there's a bit more to it
	if(major_malfunction)

		//Scramble equipped items
		for(var/obj/O in held_items)
			if(prob(60))
				uneq_module(O)
				activate_module(pick(model.modules))

		//Randomizes locked state and compounds it with cover potentially swinging open for an overall 25% chance for cover to fly open
		if(!opened)
			locked = pick(TRUE, FALSE)
			if(!locked)
				opened = pick(TRUE, FALSE)

	update_icons()

/mob/living/silicon/robot/proc/should_emag(atom/target, mob/user)
	SIGNAL_HANDLER
	if(target == user || user == src)
		return TRUE // signal is inverted
	if(world.time < emag_cooldown)
		return TRUE
	if(has_status_effect(/datum/status_effect/cyborg_malfunction))
		return FALSE //Malfunctions simplify the process for gameplay reasons
	if(!opened)
		if(!locked) //Tell the player what went wrong instead of just leaving them in the dark
			to_chat(user, span_notice("You need to pry the cover open first!"))
		return !locked
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

	if(!has_status_effect(/datum/status_effect/cyborg_malfunction) && !opened && locked) //Cover is locked closed, and the cyborg isn't already compromised
		to_chat(user, span_notice("You emag the cover lock."))
		locked = FALSE
		if(shell) //A warning to Traitors who may not know that emagging AI shells does not slave them.
			to_chat(user, span_boldwarning("[src] seems to be controlled remotely! Emagging the interface may not work as expected."))
		return

	to_chat(user, span_notice("You emag [src]'s interface."))
	emag_cooldown = world.time + 100
	addtimer(CALLBACK(src, PROC_REF(after_emag), user), 1)

/mob/living/silicon/robot/proc/after_emag(mob/user)
	if(connected_ai?.mind && connected_ai.mind.has_antag_datum(/datum/antagonist/malf_ai))
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
	GLOB.lawchanges.Add("[time] <B>:</B> [key_name(user)] emagged [name]([key])")
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
	ResetModel()
	Stun(12 SECONDS, TRUE)

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

/mob/living/silicon/robot/bullet_act(obj/projectile/Proj, def_zone)
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
