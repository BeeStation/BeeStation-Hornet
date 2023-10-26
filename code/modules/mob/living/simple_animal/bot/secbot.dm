/mob/living/simple_animal/bot/secbot
	name = "\improper Securitron"
	desc = "A little security robot. He looks less than thrilled."
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
	allow_pai = FALSE
	data_hud_type = DATA_HUD_SECURITY_ADVANCED
	path_image_color = "#FF0000"
	boot_delay = 8 SECONDS

	///The type of baton this Secbot will use
	var/baton_type = /obj/item/melee/baton
	///The weapon (from baton_type) that will be used to make arrests.
	var/obj/item/weapon
	///Their current target
	var/mob/living/carbon/target
	///Name of their last target to prevent spamming
	var/oldtarget_name
	///The threat level of the BOT, will arrest anyone at threatlevel 4 or above
	var/threatlevel = 0
	///The last location their target was seen at
	var/target_lastloc
	///Time since last seeing their perpetrator
	var/last_found

	///Flags SecBOTs use on what to check on targets when arresting, and whether they should announce it to security/handcuff their target
	var/security_mode_flags = SECBOT_DECLARE_ARRESTS | SECBOT_CHECK_RECORDS | SECBOT_HANDCUFF_TARGET
	//Selections: SECBOT_DECLARE_ARRESTS | SECBOT_CHECK_IDS | SECBOT_CHECK_WEAPONS | SECBOT_CHECK_RECORDS | SECBOT_HANDCUFF_TARGET

	/// Force of the harmbaton used on them
	var/weapon_force = 20
	///The department the secbot will deposit collected money into

/mob/living/simple_animal/bot/secbot/beepsky
	name = "Officer Beep O'sky"
	desc = "It's Officer Beep O'sky! Powered by a potato and a shot of whiskey."
	auto_patrol = TRUE

/mob/living/simple_animal/bot/secbot/beepsky/armsky
	name = "Sergeant-At-Armsky"
	health = 45
	auto_patrol = FALSE
	security_mode_flags = SECBOT_DECLARE_ARRESTS | SECBOT_CHECK_IDS | SECBOT_CHECK_RECORDS

/mob/living/simple_animal/bot/secbot/beepsky/armsky/warden
	name = "Warden Armsky"
	health = 45
	auto_patrol = FALSE
	security_mode_flags = SECBOT_DECLARE_ARRESTS | SECBOT_CHECK_IDS | SECBOT_CHECK_RECORDS

/mob/living/simple_animal/bot/secbot/beepsky/jr
	name = "Officer Pipsqueak"
	desc = "It's Officer Beep O'sky's smaller, just-as aggressive cousin, Pipsqueak."

/mob/living/simple_animal/bot/secbot/beepsky/jr/Initialize(mapload)
	. = ..()
	resize = 0.8
	update_transform()

/mob/living/simple_animal/bot/secbot/pingsky
	name = "Officer Pingsky"
	desc = "It's Officer Pingsky! Delegated to satellite guard duty for harbouring anti-human sentiment."
	radio_channel = RADIO_CHANNEL_AI_PRIVATE

/mob/living/simple_animal/bot/secbot/beepsky/explode()
	var/atom/Tsec = drop_location()
	new /obj/item/stock_parts/cell/potato(Tsec)
	var/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/drinking_oil = new(Tsec)
	drinking_oil.reagents.add_reagent(/datum/reagent/consumable/ethanol/whiskey, 15)
	drinking_oil.on_reagent_change(ADD_REAGENT)
	..()

/mob/living/simple_animal/bot/secbot/Initialize(mapload)
	. = ..()
	weapon = new baton_type()
	update_appearance(UPDATE_ICON)

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

/mob/living/simple_animal/bot/secbot/Destroy()
	QDEL_NULL(weapon)
	return ..()

/mob/living/simple_animal/bot/secbot/update_icon_state()
	if(mode == BOT_HUNT)
		icon_state = "[initial(icon_state)]-c"
		return
	return ..()

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

/mob/living/simple_animal/bot/secbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += "<TT><B>Securitron v1.6 controls</B></TT><BR>"
	dat += "<BR>Status: <A href='?src=[REF(src)];power=1'>[on ? "On" : "Off"]</A>"
	dat += "<BR>Behaviour controls are [locked ? "locked" : "unlocked"]"
	dat += "<BR>Maintenance panel panel is [open ? "opened" : "closed"]"

	if(!locked || issilicon(user) || IsAdminGhost(user))
		dat += "<BR>"
		dat += "<BR>Arrest Unidentifiable Persons: <A href='?src=[REF(src)];operation=idcheck'>[security_mode_flags & SECBOT_CHECK_IDS ? "Yes" : "No"]</A>"
		dat += "<BR>Arrest for Unauthorized Weapons: <A href='?src=[REF(src)];operation=weaponscheck'>[security_mode_flags & SECBOT_CHECK_WEAPONS ? "Yes" : "No"]</A>"
		dat += "<BR>Arrest for Warrant: <A href='?src=[REF(src)];operation=ignorerec'>[security_mode_flags & SECBOT_CHECK_RECORDS ? "Yes" : "No"]</A>"
		dat += "<BR>Operating Mode: <A href='?src=[REF(src)];operation=switchmode'>[security_mode_flags & SECBOT_HANDCUFF_TARGET ? "Arrest" : "Detain"]</A>"
		dat += "<BR>Report Arrests <A href='?src=[REF(src)];operation=declarearrests'>[security_mode_flags & SECBOT_DECLARE_ARRESTS ? "Yes" : "No"]</A>"
		dat += "<BR>Auto Patrol: <A href='?src=[REF(src)];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>"
	return	dat

/mob/living/simple_animal/bot/secbot/Topic(href, href_list)
	. = ..()
	if(.)
		return TRUE

	if(!issilicon(usr) && !IsAdminGhost(usr) && !(bot_core.allowed(usr) || !locked))
		return TRUE

	switch(href_list["operation"])
		if("idcheck")
			security_mode_flags ^= SECBOT_CHECK_IDS
		if("weaponscheck")
			security_mode_flags ^= SECBOT_CHECK_WEAPONS
		if("ignorerec")
			security_mode_flags ^= SECBOT_CHECK_RECORDS
		if("switchmode")
			security_mode_flags ^= SECBOT_HANDCUFF_TARGET
		if("declarearrests")
			security_mode_flags ^= SECBOT_DECLARE_ARRESTS

	update_controls()

/mob/living/simple_animal/bot/secbot/proc/retaliate(mob/living/carbon/human/attacking_human)
	var/judgement_criteria = judgement_criteria()
	threatlevel = attacking_human.assess_threat(judgement_criteria, weaponcheck = CALLBACK(src, PROC_REF(check_for_weapons)))
	threatlevel += 6
	if(threatlevel >= 4)
		target = attacking_human
		mode = BOT_HUNT

/mob/living/simple_animal/bot/secbot/proc/judgement_criteria()
	var/final = FALSE
	if(emagged)
		final |= JUDGE_EMAGGED
	if(bot_type == ADVANCED_SEC_BOT)
		final |= JUDGE_IGNOREMONKEYS
	if(security_mode_flags & SECBOT_CHECK_IDS)
		final |= JUDGE_IDCHECK
	if(security_mode_flags & SECBOT_CHECK_RECORDS)
		final |= JUDGE_RECORDCHECK
	if(security_mode_flags & SECBOT_CHECK_WEAPONS)
		final |= JUDGE_WEAPONCHECK
	return final

/mob/living/simple_animal/bot/secbot/proc/special_retaliate_after_attack(mob/user) //allows special actions to take place after being attacked.
	return

/mob/living/simple_animal/bot/secbot/attack_hand(mob/living/carbon/human/H)
	if((H.a_intent == INTENT_HARM) || (H.a_intent == INTENT_DISARM))
		retaliate(H)
		if(special_retaliate_after_attack(H))
			return

	return ..()

/mob/living/simple_animal/bot/secbot/attackby(obj/item/attacking_item, mob/user, params)
	..()
	if(attacking_item.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM) // Any intent but harm will heal, so we shouldn't get angry.
		return
	if(attacking_item.tool_behaviour != TOOL_SCREWDRIVER && (attacking_item.force) && (!target) && (attacking_item.damtype != STAMINA) ) // Added check for welding tool to fix #2432. Welding tool behavior is handled in superclass.
		retaliate(user)
		special_retaliate_after_attack(user)

/mob/living/simple_animal/bot/secbot/on_emag(atom/target, mob/user)
	..()
	if(!emagged)
		return
	if(user)
		to_chat(user, "<span class='danger'>You short out [src]'s target assessment circuits.</span>")
		oldtarget_name = user.name
	audible_message("<span class='danger'>[src] buzzes oddly!</span>")
	security_mode_flags &= ~SECBOT_DECLARE_ARRESTS
	update_appearance()

/mob/living/simple_animal/bot/secbot/bullet_act(obj/projectile/Proj)
	if(istype(Proj , /obj/projectile/beam)||istype(Proj, /obj/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(!Proj.nodamage && Proj.damage < src.health && ishuman(Proj.firer))
				retaliate(Proj.firer)
	return ..()

/mob/living/simple_animal/bot/secbot/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(!on)
		return
	if(!iscarbon(attack_target))
		return ..()
	var/mob/living/carbon/carbon_target = attack_target
	if(!carbon_target.IsParalyzed() || !(security_mode_flags & SECBOT_HANDCUFF_TARGET))
		stun_attack(attack_target)
	else if(carbon_target.canBeHandcuffed() && !carbon_target.handcuffed)
		start_handcuffing(attack_target)

/mob/living/simple_animal/bot/secbot/hitby(atom/movable/hitting_atom, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(istype(hitting_atom, /obj/item))
		var/obj/item/item_hitby = hitting_atom
		var/mob/thrown_by = item_hitby.thrownby?.resolve()
		if(item_hitby.throwforce < src.health && thrown_by && ishuman(thrown_by))
			var/mob/living/carbon/human/human_throwee = thrown_by
			retaliate(human_throwee)
	..()

/mob/living/simple_animal/bot/secbot/proc/start_handcuffing(mob/living/carbon/current_target)
	mode = BOT_ARREST
	playsound(src, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
	current_target.visible_message("<span class='danger'>[src] is trying to put zipties on [current_target]!</span>",\
						"<span class='userdanger'>[src] is trying to put zipties on you!</span>")
	addtimer(CALLBACK(src, PROC_REF(handcuff_target), target), 60)

/mob/living/simple_animal/bot/secbot/proc/handcuff_target(mob/living/carbon/current_target)
	if( !on || !Adjacent(current_target) || !isturf(current_target.loc) ) //if he's in a closet or not adjacent, we cancel cuffing.
		return
	if(!current_target.handcuffed)
		current_target.handcuffed = new /obj/item/restraints/handcuffs/cable/zipties/used(current_target)
		current_target.update_handcuffed()
		playsound(src, "law", 50, FALSE)
		back_to_idle()

/mob/living/simple_animal/bot/secbot/proc/stun_attack(mob/living/carbon/current_target)
	var/judgement_criteria = judgement_criteria()
	var/threat = 5
	if(ishuman(current_target))
		var/mob/living/carbon/human/human_target = current_target
		if(human_target.check_shields(src, 0))
			return
		threat = human_target.assess_threat(judgement_criteria, weaponcheck=CALLBACK(src, PROC_REF(check_for_weapons)))
	else
		threat = current_target.assess_threat(judgement_criteria, weaponcheck=CALLBACK(src, PROC_REF(check_for_weapons)))
	if(security_mode_flags & SECBOT_DECLARE_ARRESTS)
		var/area/location = get_area(src)
		speak("[security_mode_flags & SECBOT_HANDCUFF_TARGET ? "Arresting" : "Detaining"] level [threat] scumbag <b>[current_target]</b> in [location].", radio_channel)

	var/armor_block = current_target.run_armor_check(BODY_ZONE_CHEST, "stamina")
	current_target.apply_damage(85, STAMINA, BODY_ZONE_CHEST, armor_block)
	current_target.apply_effect(EFFECT_STUTTER, 50)
	current_target.visible_message(
		"<span class='danger'>[src] has stunned [current_target]!</span>",\
		"<span class='userdanger'>[src] has stunned you!</span>"
	)

	log_combat(src, target, "stunned")
	playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	icon_state = "[initial(icon_state)]-c"
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_appearance)), 0.2 SECONDS)

/mob/living/simple_animal/bot/secbot/handle_automated_action()
	. = ..()
	if(!.)
		return

	switch(mode)

		if(BOT_IDLE) // idle
			SSmove_manager.stop_looping(src)
			look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = BOT_START_PATROL	// switch to patrol mode

		if(BOT_HUNT) // hunting for perp
			// if can't reach perp for long enough, go idle
			if(frustration >= 8)
				SSmove_manager.stop_looping(src)
				back_to_idle()
				return

			if(!target) // make sure target exists
				back_to_idle()
				return
			if(Adjacent(target) && isturf(target.loc)) // if right next to perp
				stun_attack(target)

				mode = BOT_PREP_ARREST
				anchored = TRUE
				target_lastloc = target.loc
				return

			// not next to perp
			var/turf/olddist = get_dist(src, target)
			SSmove_manager.move_to(src, target, 1, 4)
			if((get_dist(src, target)) >= (olddist))
				frustration++
			else
				frustration = 0

		if(BOT_PREP_ARREST) // preparing to arrest target
			// see if he got away. If he's no no longer adjacent or inside a closet or about to get up, we hunt again.
			if(!Adjacent(target) || !isturf(target.loc) ||  target.getStaminaLoss() < 100)
				back_to_hunt()
				return

			if(!iscarbon(target) || !target.canBeHandcuffed())
				back_to_idle()
				return
			if(security_mode_flags & SECBOT_HANDCUFF_TARGET)
				if(!target.handcuffed) //he's not cuffed? Try to cuff him!
					start_handcuffing(target)
				else
					back_to_idle()
					return

		if(BOT_ARREST)
			if(!target)
				anchored = FALSE
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
				anchored = FALSE

		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			look_for_perp()
			bot_patrol()

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
	var/judgement_criteria = judgement_criteria()
	for(var/mob/living/carbon/nearby_carbons in view(7,src)) //Let's find us a criminal
		if((nearby_carbons.stat) || (nearby_carbons.handcuffed))
			continue

		if((nearby_carbons.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		threatlevel = nearby_carbons.assess_threat(judgement_criteria, weaponcheck = CALLBACK(src, PROC_REF(check_for_weapons)))

		if(!threatlevel)
			continue

		else if(threatlevel >= 4)
			target = nearby_carbons
			oldtarget_name = nearby_carbons.name
			speak("Level [threatlevel] infraction alert!")
			if(bot_type == ADVANCED_SEC_BOT)
				playsound(src, pick('sound/voice/ed209_20sec.ogg', 'sound/voice/edplaceholder.ogg'), 50, FALSE)
			else
				playsound(src, pick('sound/voice/beepsky/criminal.ogg', 'sound/voice/beepsky/justice.ogg', 'sound/voice/beepsky/freeze.ogg'), 50, FALSE)
			visible_message("<b>[src]</b> points at [nearby_carbons.name]!")
			mode = BOT_HUNT
			INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
			break

/mob/living/simple_animal/bot/secbot/proc/check_for_weapons(var/obj/item/slot_item)
	if(slot_item && (slot_item.item_flags & NEEDS_PERMIT))
		return TRUE
	return FALSE

/mob/living/simple_animal/bot/secbot/explode()

	visible_message("<span class='boldannounce'>[src] blows apart!</span>")
	var/atom/Tsec = drop_location()
	if(bot_type == ADVANCED_SEC_BOT)
		var/obj/item/bot_assembly/ed209/ed_assembly = new(Tsec)
		ed_assembly.build_step = ASSEMBLY_FIRST_STEP
		ed_assembly.add_overlay("hs_hole")
		ed_assembly.created_name = name
		new /obj/item/assembly/prox_sensor(Tsec)
		var/obj/item/gun/energy/disabler/disabler_gun = new(Tsec)
		disabler_gun.cell.charge = 0
		disabler_gun.update_appearance()
		if(prob(50))
			new /obj/item/bodypart/l_leg/robot(Tsec)
			if(prob(25))
				new /obj/item/bodypart/r_leg/robot(Tsec)
		if(prob(25))//50% chance for a helmet OR vest
			if(prob(50))
				new /obj/item/clothing/head/helmet(Tsec)
			else
				new /obj/item/clothing/suit/armor/vest(Tsec)
	else
		var/obj/item/bot_assembly/secbot/secbot_assembly = new(Tsec)
		secbot_assembly.build_step = ASSEMBLY_FIRST_STEP
		secbot_assembly.add_overlay("hs_hole")
		secbot_assembly.created_name = name
		new /obj/item/assembly/prox_sensor(Tsec)
		drop_part(baton_type, Tsec)

	do_sparks(3, TRUE, src)

	new /obj/effect/decal/cleanable/oil(loc)
	..()

/mob/living/simple_animal/bot/secbot/attack_alien(var/mob/living/carbon/alien/user as mob)
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

/obj/machinery/bot_core/secbot
	req_access = list(ACCESS_SECURITY)
