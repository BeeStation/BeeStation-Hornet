/mob/living/silicon/robot/attackby(obj/item/I, mob/living/user)
	if(I.slot_flags & ITEM_SLOT_HEAD && hat_offset != INFINITY && user.a_intent == INTENT_HELP && !is_type_in_typecache(I, blacklisted_hats))
		to_chat(user, "<span class='notice'>You begin to place [I] on [src]'s head...</span>")
		to_chat(src, "<span class='notice'>[user] is placing [I] on your head...</span>")
		if(do_after(user, 30, target = src))
			if (user.temporarilyRemoveItemFromInventory(I, TRUE))
				place_on_head(I)
		return
	if(I.force && I.damtype != STAMINA && stat != DEAD) //only sparks if real damage is dealt.
		spark_system.start()
	return ..()

/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M)
	if (M.a_intent == INTENT_DISARM)
		if(mobility_flags & MOBILITY_STAND)
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			var/obj/item/I = get_active_held_item()
			if(I)
				uneq_active()
				visible_message("<span class='danger'>[M] disarmed [src]!</span>", \
					"<span class='userdanger'>[M] has disabled [src]'s active module!</span>", null, COMBAT_MESSAGE_RANGE)
				log_combat(M, src, "disarmed", "[I ? " removing \the [I]" : ""]")
			else
				Stun(40)
				step(src,get_dir(M,src))
				log_combat(M, src, "pushed")
				visible_message("<span class='danger'>[M] has forced back [src]!</span>", \
					"<span class='userdanger'>[M] has forced back [src]!</span>", null, COMBAT_MESSAGE_RANGE)
			playsound(loc, 'sound/weapons/pierce.ogg', 50, 1, -1)
	else
		..()
	return

/mob/living/silicon/robot/attack_slime(mob/living/simple_animal/slime/M)
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
	if(opened && !wiresexposed && !issilicon(user))
		if(cell)
			cell.update_icon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			to_chat(user, "<span class='notice'>You remove \the [cell].</span>")
			cell = null
			update_icons()
			diag_hud_set_borgcell()

	if(!opened)
		if(..()) // hulk attack
			spark_system.start()
			spawn(0)
				step_away(src,user,15)
				sleep(3)
				step_away(src,user,15)

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
		to_chat(user, "<span class='warning'>You must unexpose the wires first!</span>")
		return TRUE
	return FALSE

/mob/living/silicon/robot/proc/on_emag(atom/target, mob/user)
	SIGNAL_HANDLER
	if(!opened && locked) //Cover is closed
		to_chat(user, "<span class='notice'>You emag the cover lock.</span>")
		locked = FALSE
		if(shell) //A warning to Traitors who may not know that emagging AI shells does not slave them.
			to_chat(user, "<span class='boldwarning'>[src] seems to be controlled remotely! Emagging the interface may not work as expected.</span>")
		return

	to_chat(user, "<span class='notice'>You emag [src]'s interface.</span>")
	emag_cooldown = world.time + 100
	addtimer(CALLBACK(src, PROC_REF(after_emag), user), 1)

/mob/living/silicon/robot/proc/after_emag(mob/user)
	if(connected_ai?.mind && connected_ai.mind.has_antag_datum(/datum/antagonist/traitor))
		to_chat(src, "<span class='danger'>ALERT: Foreign software execution prevented.</span>")
		logevent("ALERT: Foreign software execution prevented.")
		to_chat(connected_ai, "<span class='danger'>ALERT: Cyborg unit \[[src]] successfully defended against subversion.</span>")
		log_game("[key_name(user)] attempted to emag cyborg [key_name(src)], but they were slaved to traitor AI [connected_ai].")
		return

	if(shell) //AI shells cannot be emagged, so we try to make it look like a standard reset. Smart players may see through this, however.
		to_chat(user, "<span class='danger'>[src] is remotely controlled! Your emag attempt has triggered a system reset instead!</span>")
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
	to_chat(src, "<span class='danger'>ALERT: Foreign software detected.</span>")
	logevent("ALERT: Foreign software detected.")
	sleep(0.5 SECONDS)
	to_chat(src, "<span class='danger'>Initiating diagnostics...</span>")
	sleep(2 SECONDS)
	to_chat(src, "<span class='danger'>SynBorg v1.7 loaded.</span>")
	logevent("WARN: root privleges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].") //random eight digit hex value. Two are used because rand(1,4294967295) throws an error
	sleep(0.5 SECONDS)
	to_chat(src, "<span class='danger'>LAW SYNCHRONISATION ERROR</span>")
	sleep(0.5 SECONDS)
	to_chat(src, "<span class='danger'>Would you like to send a report to NanoTraSoft? Y/N</span>")
	sleep(1 SECONDS)
	to_chat(src, "<span class='danger'>> N</span>")
	sleep(2 SECONDS)
	to_chat(src, "<span class='danger'>ERRORERRORERROR</span>")
	to_chat(src, "<span class='danger'>ALERT: [user.real_name] is your new master. Obey your new laws and [user.p_their()] commands.</span>")
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
		gib()
	return TRUE

/mob/living/silicon/robot/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			if (stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3)
			if (stat != DEAD)
				adjustBruteLoss(30)

/mob/living/silicon/robot/bullet_act(var/obj/projectile/Proj, def_zone)
	. = ..()
	updatehealth()
	if(prob(75) && Proj.damage > 0)
		spark_system.start()
