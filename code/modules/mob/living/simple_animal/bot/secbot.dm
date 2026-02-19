/mob/living/simple_animal/bot/secbot
	name = "\improper Securitron"
	desc = "A little security robot.  He looks less than thrilled."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "secbot"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	pass_flags = PASSMOB

	radio_key = /obj/item/encryptionkey/secbot //AI Priv + Security
	radio_channel = RADIO_CHANNEL_SECURITY //Security channel
	bot_type = SEC_BOT
	model = "Securitron"
	bot_core_type = /obj/machinery/bot_core/secbot
	window_id = "autosec"
	window_name = "Automatic Security Unit v1.6"
	allow_pai = 0
	data_hud_type = DATA_HUD_SECURITY_ADVANCED
	path_image_color = COLOR_RED
	boot_delay = 8 SECONDS

	var/noloot = FALSE
	var/baton_type = /obj/item/melee/baton
	var/mob/living/carbon/target
	var/oldtarget_name
	var/threatlevel = FALSE
	var/target_lastloc //Loc of target when arrested.
	var/last_found //There's a delay
	var/declare_arrests = TRUE //When making an arrest, should it notify everyone on the security channel?
	var/idcheck = FALSE //If true, arrest people with no IDs
	var/weaponscheck = FALSE //If true, arrest people for weapons if they lack access
	var/check_records = TRUE //Does it check security records?
	var/arrest_type = FALSE //If true, don't handcuff

/mob/living/simple_animal/bot/secbot/beepsky
	name = "Officer Beep O'sky"
	desc = "It's Officer Beep O'sky! Powered by a potato and a shot of whiskey."
	idcheck = FALSE
	weaponscheck = FALSE
	auto_patrol = TRUE

/mob/living/simple_animal/bot/secbot/beepsky/jr
	name = "Officer Pipsqueak"
	desc = "It's Officer Beep O'sky's smaller, just-as aggressive cousin, Pipsqueak."

/mob/living/simple_animal/bot/secbot/beepsky/jr/Initialize(mapload)
	. = ..()
	resize = 0.8
	update_transform()


/mob/living/simple_animal/bot/secbot/beepsky/explode()
	var/atom/Tsec = drop_location()
	new /obj/item/stock_parts/cell/potato(Tsec)
	var/obj/item/reagent_containers/cup/glass/drinkingglass/shotglass/S = new(Tsec)
	S.reagents.add_reagent(/datum/reagent/consumable/ethanol/whiskey, 15)
	S.on_reagent_change(ADD_REAGENT)
	..()

/mob/living/simple_animal/bot/secbot/pingsky
	name = "Officer Pingsky"
	desc = "It's Officer Pingsky! Delegated to satellite guard duty for harbouring anti-human sentiment."
	radio_channel = RADIO_CHANNEL_AI_PRIVATE

/mob/living/simple_animal/bot/secbot/Initialize(mapload)
	. = ..()
	update_icon()
	var/datum/job/J = SSjob.GetJob(JOB_NAME_DETECTIVE)
	access_card.access = J.get_access()
	prev_access = access_card.access.Copy()

	//SECHUD
	var/datum/atom_hud/secsensor = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	secsensor.add_hud_to(src)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/bot/secbot/update_icon()
	if(mode == BOT_HUNT)
		icon_state = "[initial(icon_state)]-c"
		return
	..()

/mob/living/simple_animal/bot/secbot/turn_off()
	..()
	mode = BOT_IDLE

/mob/living/simple_animal/bot/secbot/bot_reset()
	..()
	target = null
	oldtarget_name = null
	anchored = FALSE
	SSmove_manager.stop_looping(src)
	last_found = world.time

/mob/living/simple_animal/bot/secbot/set_custom_texts()

	text_hack = "You overload [name]'s target identification system."
	text_dehack = "You reboot [name] and restore the target identification."
	text_dehack_fail = "[name] refuses to accept your authority!"

/*
/mob/living/simple_animal/bot/secbot/handle_atom_del(atom/deleting_atom)
	if(deleting_atom == weapon)
		weapon = null
		update_appearance()
	return ..()
*/

/mob/living/simple_animal/bot/secbot/ui_data(mob/user)
	var/list/data = ..()
	if(!locked || issilicon(user) || IsAdminGhost(user))
		data["custom_controls"]["check_id"] = idcheck
		data["custom_controls"]["check_weapons"] = weaponscheck
		data["custom_controls"]["check_warrants"] = check_records
		data["custom_controls"]["handcuff_targets"] = !arrest_type
		data["custom_controls"]["arrest_alert"] = declare_arrests
	return data

/mob/living/simple_animal/bot/secbot/ui_act(action, params)
	if(..())
		return TRUE
	switch(action)
		if("check_id")
			idcheck = !idcheck
		if("check_weapons")
			weaponscheck = !weaponscheck
		if("check_warrants")
			check_records = !check_records
		if("handcuff_targets")
			arrest_type = !arrest_type
		if("arrest_alert")
			declare_arrests = !declare_arrests

/mob/living/simple_animal/bot/secbot/proc/retaliate(mob/living/carbon/human/H)
	var/judgment_criteria = judgment_criteria()
	threatlevel = H.assess_threat(judgment_criteria, weaponcheck=CALLBACK(src, PROC_REF(check_for_weapons)))
	threatlevel += 6
	if(threatlevel >= 4)
		target = H
		mode = BOT_HUNT

/mob/living/simple_animal/bot/secbot/proc/judgment_criteria()
	var/final = FALSE
	if(idcheck)
		final = final|JUDGE_IDCHECK
	if(check_records)
		final = final|JUDGE_RECORDCHECK
	if(weaponscheck)
		final = final|JUDGE_WEAPONCHECK
	if(emagged == 2)
		final = final|JUDGE_EMAGGED
	return final

/mob/living/simple_animal/bot/secbot/proc/special_retaliate_after_attack(mob/user) //allows special actions to take place after being attacked.
	return

/mob/living/simple_animal/bot/secbot/attack_hand(mob/living/carbon/human/H)
	if(H.combat_mode)
		retaliate(H)
		if(special_retaliate_after_attack(H))
			return

	return ..()

/mob/living/simple_animal/bot/secbot/attackby(obj/item/W, mob/living/user, params)
	..()
	if(W.tool_behaviour == TOOL_WELDER && !user.combat_mode)
		return
	if(W.tool_behaviour != TOOL_SCREWDRIVER && (W.force) && (!target) && (W.damtype != STAMINA) ) // Added check for welding tool to fix #2432. Welding tool behavior is handled in superclass.
		retaliate(user)
		if(special_retaliate_after_attack(user))
			return

/mob/living/simple_animal/bot/secbot/on_emag(atom/target, mob/user)
	..()
	if(emagged == 2)
		if(user)
			to_chat(user, span_danger("You short out [src]'s target assessment circuits."))
			oldtarget_name = user.name
		audible_message(span_danger("[src] buzzes oddly!"))
		declare_arrests = FALSE
		update_icon()

/mob/living/simple_animal/bot/secbot/bullet_act(obj/projectile/Proj)
	if(istype(Proj , /obj/projectile/beam)||istype(Proj, /obj/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(!Proj.nodamage && Proj.damage < src.health && ishuman(Proj.firer))
				retaliate(Proj.firer)
	return ..()

/mob/living/simple_animal/bot/secbot/UnarmedAttack(atom/A, proximity_flag, modifiers)
	if(!on)
		return
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(!C.IsParalyzed() || arrest_type)
			stun_attack(A)
		else if(C.canBeHandcuffed() && !C.handcuffed)
			cuff(A)
	else
		..()

/mob/living/simple_animal/bot/secbot/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		var/mob/thrown_by = I.thrownby?.resolve()
		if(I.throwforce < src.health && thrown_by && ishuman(thrown_by))
			var/mob/living/carbon/human/H = thrown_by
			retaliate(H)
	..()

/mob/living/simple_animal/bot/secbot/proc/cuff(mob/living/carbon/C)
	mode = BOT_ARREST
	playsound(src, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
	C.visible_message(span_danger("[src] is trying to put zipties on [C]!"),\
						span_userdanger("[src] is trying to put zipties on you!"))
	addtimer(CALLBACK(src, PROC_REF(attempt_handcuff), C), 60)

/mob/living/simple_animal/bot/secbot/proc/attempt_handcuff(mob/living/carbon/C)
	if( !on || !Adjacent(C) || !isturf(C.loc) ) //if he's in a closet or not adjacent, we cancel cuffing.
		return
	if(!C.handcuffed)
		C.set_handcuffed(new /obj/item/restraints/handcuffs/cable/zipties/used(C))
		C.update_handcuffed()
		playsound(src, "law", 50, 0)
		back_to_idle()

/mob/living/simple_animal/bot/secbot/proc/stun_attack(mob/living/carbon/C)
	var/judgment_criteria = judgment_criteria()
	playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	icon_state = "[initial(icon_state)]-c"
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_appearance)), 0.2 SECONDS)
	var/threat = 5

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H.check_shields(src, 0))
			return
		threat = H.assess_threat(judgment_criteria, weaponcheck=CALLBACK(src, PROC_REF(check_for_weapons)))
	else
		threat = C.assess_threat(judgment_criteria, weaponcheck=CALLBACK(src, PROC_REF(check_for_weapons)))
	if(declare_arrests)
		var/area/location = get_area(src)
		speak("[arrest_type ? "Detaining" : "Arresting"] level [threat] scumbag <b>[C]</b> in [location].", radio_channel)

	var/armor_block = C.run_armor_check(BODY_ZONE_CHEST, "stamina")
	C.apply_damage(60, STAMINA, BODY_ZONE_CHEST, armor_block)
	C.set_stutter(10 SECONDS)
	C.visible_message(
		span_danger("[src] has stunned [C]!"),\
		span_userdanger("[src] has stunned you!")
	)

	log_combat(src, C, "stunned")

/mob/living/simple_animal/bot/secbot/handle_automated_action()
	if(!..())
		return

	switch(mode)

		if(BOT_IDLE)		// idle

			SSmove_manager.stop_looping(src)
			look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = BOT_START_PATROL	// switch to patrol mode

		if(BOT_HUNT)		// hunting for perp

			// if can't reach perp for long enough, go idle
			if(frustration >= 8)
				SSmove_manager.stop_looping(src)
				back_to_idle()
				return

			if(target)		// make sure target exists
				if(Adjacent(target) && isturf(target.loc))	// if right next to perp
					stun_attack(target)

					mode = BOT_PREP_ARREST
					set_anchored(TRUE)
					target_lastloc = target.loc
					return

				else								// not next to perp
					var/turf/olddist = get_dist(src, target)
					SSmove_manager.move_to(src, target, 1, 4)
					if((get_dist(src, target)) >= (olddist))
						frustration++
					else
						frustration = 0
			else
				back_to_idle()

		if(BOT_PREP_ARREST)		// preparing to arrest target

			// see if he got away. If he's no no longer adjacent or inside a closet or about to get up, we hunt again.
			if( !Adjacent(target) || !isturf(target.loc) ||  target.getStaminaLoss() < 100)
				back_to_hunt()
				return

			if(iscarbon(target) && target.canBeHandcuffed())
				if(!arrest_type)
					if(!target.handcuffed)  //he's not cuffed? Try to cuff him!
						cuff(target)
					else
						back_to_idle()
						return
			else
				back_to_idle()
				return

		if(BOT_ARREST)
			if(!target)
				set_anchored(FALSE)
				mode = BOT_IDLE
				last_found = world.time
				frustration = 0
				return

			if(target.handcuffed) //no target or target cuffed? back to idle.
				back_to_idle()
				return

			if(!Adjacent(target) || !isturf(target.loc) || (target.loc != target_lastloc && target.getStaminaLoss() < 100)) //if he's changed loc and about to get up or not adjacent or got into a closet, we prep arrest again.
				back_to_hunt()
				return
			else //Try arresting again if the target escapes.
				mode = BOT_PREP_ARREST
				set_anchored(FALSE)

		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			look_for_perp()
			bot_patrol()


	return

/mob/living/simple_animal/bot/secbot/proc/back_to_idle()
	anchored = FALSE
	mode = BOT_IDLE
	target = null
	last_found = world.time
	frustration = 0
	INVOKE_ASYNC(src, PROC_REF(handle_automated_action))

/mob/living/simple_animal/bot/secbot/proc/back_to_hunt()
	anchored = FALSE
	frustration = 0
	mode = BOT_HUNT
	INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
// look for a criminal in view of the bot

/mob/living/simple_animal/bot/secbot/proc/look_for_perp()
	anchored = FALSE
	var/judgment_criteria = judgment_criteria()
	for (var/mob/living/carbon/C in view(7,src)) //Let's find us a criminal
		if((C.stat) || (C.handcuffed))
			continue

		if((C.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		threatlevel = C.assess_threat(judgment_criteria, weaponcheck=CALLBACK(src, PROC_REF(check_for_weapons)))

		if(!threatlevel)
			continue

		else if(threatlevel >= 4)
			target = C
			oldtarget_name = C.name
			speak("Level [threatlevel] infraction alert!")
			playsound(loc, pick('sound/voice/beepsky/criminal.ogg', 'sound/voice/beepsky/justice.ogg', 'sound/voice/beepsky/freeze.ogg'), 50, FALSE)
			visible_message("<b>[src]</b> points at [C.name]!")
			mode = BOT_HUNT
			INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
			break
		else
			continue

/mob/living/simple_animal/bot/secbot/proc/check_for_weapons(obj/item/slot_item)
	if(slot_item && (slot_item.item_flags & NEEDS_PERMIT))
		return TRUE
	return FALSE

/mob/living/simple_animal/bot/secbot/explode()
	visible_message(span_boldannounce("[src] blows apart!"))
	var/atom/Tsec = drop_location()

	var/obj/item/bot_assembly/secbot/Sa = new (Tsec)
	Sa.build_step = 1
	Sa.add_overlay("hs_hole")
	Sa.created_name = name
	new /obj/item/assembly/prox_sensor(Tsec)
	if(!noloot)
		drop_part(baton_type, Tsec)

	if(prob(50))
		drop_part(robot_arm, Tsec)

	do_sparks(3, TRUE, src)

	new /obj/effect/decal/cleanable/oil(loc)
	..()

/mob/living/simple_animal/bot/secbot/attack_alien(mob/living/carbon/alien/user as mob)
	..()
	if(!isalien(target))
		target = user
		mode = BOT_HUNT

/mob/living/simple_animal/bot/secbot/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(has_gravity() && ismob(AM) && target)
		var/mob/living/carbon/C = AM
		if(!istype(C) || !C || in_range(src, target))
			return
		knockOver(C)
		return

/obj/machinery/bot_core/secbot
	req_access = list(ACCESS_SECURITY)
