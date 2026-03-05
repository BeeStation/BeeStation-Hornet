CREATION_TEST_IGNORE_SELF(/mob/living/carbon)

/mob/living/carbon
	blood_volume = BLOOD_VOLUME_NORMAL

/mob/living/carbon/Initialize(mapload)
	. = ..()
	create_reagents(1000)
	update_body_parts() //to update the carbon's new bodyparts appearance

	GLOB.carbon_list += src
	RegisterSignal(src, COMSIG_MOB_LOGOUT, PROC_REF(med_hud_set_status))
	RegisterSignal(src, COMSIG_MOB_LOGIN, PROC_REF(med_hud_set_status))
	RegisterSignal(src, SIGNAL_UPDATETRAIT(TRAIT_OVERRIDE_SKIN_COLOUR), PROC_REF(_signal_body_part_update))

/mob/living/carbon/Destroy()
	//This must be done first, so the mob ghosts correctly before DNA etc is nulled
	. =  ..()

	QDEL_LIST(hand_bodyparts)
	QDEL_LIST(internal_organs)
	QDEL_LIST(bodyparts)
	QDEL_LIST(implants)
	remove_from_all_data_huds()
	QDEL_NULL(dna)
	GLOB.carbon_list -= src

/mob/living/carbon/swap_hand(held_index)
	. = ..()
	if(!.)
		var/obj/item/held_item = get_active_held_item()
		to_chat(usr, span_warning("Your other hand is too busy holding [held_item]."))
		return

	if(!held_index)
		held_index = (active_hand_index % held_items.len)+1

	var/oindex = active_hand_index
	active_hand_index = held_index
	if(hud_used)
		var/atom/movable/screen/inventory/hand/H
		H = hud_used.hand_slots["[oindex]"]
		if(H)
			H.update_icon()
		H = hud_used.hand_slots["[held_index]"]
		if(H)
			H.update_icon()
	refresh_self_screentips()

/mob/living/carbon/activate_hand(selhand) //l/r OR 1-held_items.len
	if(!selhand)
		selhand = (active_hand_index % held_items.len)+1

	if(istext(selhand))
		selhand = LOWER_TEXT(selhand)
		if(selhand == "right" || selhand == "r")
			selhand = 2
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != active_hand_index)
		swap_hand(selhand)
	else
		mode() // Activate held item

/mob/living/carbon/attackby(obj/item/I, mob/living/user, params)
	for(var/datum/surgery/operations as anything in surgeries)
		if(user.combat_mode)
			break
		if(body_position == LYING_DOWN || !operations.lying_required)
			var/list/modifiers = params2list(params)
			if((operations.self_operable || user != src))
				if(operations.next_step(user, modifiers))
					return TRUE
	return ..()

/mob/living/carbon/CtrlShiftClick(mob/user)
	..()
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		carbon_user.give(src)

/mob/living/carbon/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/hurt = TRUE
	if(!throwingdatum || throwingdatum.force <= MOVE_FORCE_WEAK)
		hurt = FALSE
	var/obj/item/modular_computer/comp
	var/obj/item/computer_hardware/processor_unit/cpu
	for(var/obj/item/modular_computer/M in contents)
		cpu = M.all_components[MC_CPU]
		if(cpu?.hacked)
			comp = M
	for(var/obj/item/S in contents)	// We're looking for storages inside the mobs storage (wow)
		for(var/obj/item/modular_computer/M in S.contents)
			cpu = M.all_components[MC_CPU]
			if(cpu?.hacked)
				comp = M
	if(comp)
		if(!cpu)
			return
		var/turf/target = comp.get_blink_destination(get_turf(src), dir, (cpu.max_idle_programs * 2))
		var/turf/start = get_turf(src)
		if(!comp.enabled)
			new /obj/effect/particle_effect/sparks(start)
			playsound(start, "sparks", 50, 1)
			return
		if(!target)
			return
		// The better the CPU the farther it goes, and the more battery it needs
		playsound(target, 'sound/effects/phasein.ogg', 25, 1)
		playsound(start, "sparks", 50, 1)
		playsound(target, "sparks", 50, 1)
		do_dash(src, start, target, 0, TRUE)
		comp.use_power((250 * cpu.max_idle_programs))
	if(iscarbon(hit_atom) && hit_atom != src)
		var/mob/living/carbon/victim = hit_atom
		if(!(victim.movement_type & FLYING))
			if(victim.can_catch_item())
				visible_message(span_danger("[victim] catches [src]!"),\
					span_userdanger("[victim] catches you!"))
				grabbedby(victim, TRUE)
				victim.throw_mode_off(THROW_MODE_TOGGLE)
				log_combat(victim, src, "caught [src]")
				return
			if(hurt)
				victim.take_bodypart_damage(10,check_armor = TRUE)
				take_bodypart_damage(10,check_armor = TRUE)
				victim.Paralyze(20)
				Paralyze(20)
				visible_message(span_danger("[src] crashes into [victim], knocking them both over!"),\
					span_userdanger("You violently crash into [victim]!"))
			playsound(src,'sound/weapons/punch1.ogg',50,1)

	. = ..()

	if(istype(throwingdatum, /datum/thrownthing))
		var/datum/thrownthing/D = throwingdatum
		if(iscyborg(D.thrower))
			var/mob/living/silicon/robot/R = D.thrower
			if(!R.emagged)
				hurt = FALSE
	if(hit_atom.density && isturf(hit_atom))
		if(hurt)
			Paralyze(20)
			take_bodypart_damage(10,check_armor = TRUE)

//Throwing stuff
/mob/living/carbon/proc/toggle_throw_mode()
	if(stat)
		return
	if(throw_mode)
		throw_mode_off(THROW_MODE_TOGGLE)
	else
		throw_mode_on(THROW_MODE_TOGGLE)


/mob/living/carbon/proc/throw_mode_off(method)
	if(throw_mode > method) //A toggle doesnt affect a hold
		return
	throw_mode = THROW_MODE_DISABLED
	if(client && hud_used)
		hud_used.throw_icon.icon_state = "act_throw_off"


/mob/living/carbon/proc/throw_mode_on(mode = THROW_MODE_TOGGLE)
	throw_mode = mode
	if(client && hud_used)
		hud_used.throw_icon.icon_state = "act_throw_on"

/mob/proc/throw_item(atom/target)
	SEND_SIGNAL(src, COMSIG_MOB_THROW, target)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CARBON_THROW_THING, src, target)
	return TRUE

/mob/living/carbon/throw_item(atom/target)
	. = ..()
	throw_mode_off(THROW_MODE_TOGGLE)
	if(!target || !isturf(loc))
		return FALSE
	if(istype(target, /atom/movable/screen))
		var/atom/movable/screen/S = target
		if(!S.can_throw_target)
			return FALSE

	var/atom/movable/thrown_thing
	var/obj/item/held_item = get_active_held_item()
	var/verb_text = pick("throw", "toss", "hurl", "chuck", "fling")
	if(!held_item)
		if(pulling && isliving(pulling) && grab_state >= GRAB_AGGRESSIVE)
			var/mob/living/throwable_mob = pulling
			if(!throwable_mob.buckled)
				thrown_thing = throwable_mob
				stop_pulling()
				if(HAS_TRAIT(src, TRAIT_PACIFISM))
					to_chat(src, span_notice("You gently let go of [throwable_mob]."))
					return FALSE
	else
		thrown_thing = held_item.on_thrown(src, target)
	if(!thrown_thing)
		return FALSE
	if(isliving(thrown_thing))
		var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
		var/turf/end_T = get_turf(target)
		if(start_T && end_T)
			log_combat(src, thrown_thing, "thrown", addition="grab from tile in [AREACOORD(start_T)] towards tile at [AREACOORD(end_T)]")

	do_attack_animation(target, no_effect = 1)
	var/sound/throwsound = 'sound/weapons/throw.ogg'
	playsound(src, throwsound, min(8*min(get_dist(loc,target),thrown_thing.throw_range), 50), vary = TRUE, extrarange = -1)
	log_message("has thrown [thrown_thing].", LOG_ATTACK)

	if (!held_item)
		visible_message(span_danger("[src] [verb_text][plural_s(verb_text)] [thrown_thing]."), \
							span_danger("You [verb_text] [thrown_thing]."))
	else
		visible_message(span_danger("[src] [held_item.throw_verb ? held_item.throw_verb : verb_text][plural_s(verb_text)] [thrown_thing]."), \
							span_danger("You [held_item.throw_verb ? held_item.throw_verb : verb_text] [thrown_thing]."))
	log_message("has thrown [thrown_thing]", LOG_ATTACK)

	newtonian_move(get_dir(target, src))
	thrown_thing.safe_throw_at(target, thrown_thing.throw_range, thrown_thing.throw_speed, src, null, null, null, move_force)
	return TRUE

/mob/living/carbon/proc/canBeHandcuffed()
	return FALSE

/mob/living/carbon/Topic(href, href_list)
	..()
	if(href_list["embedded_object"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		var/obj/item/bodypart/L = locate(href_list["embedded_limb"]) in bodyparts
		if(!L)
			return
		var/obj/item/I = locate(href_list["embedded_object"]) in L.embedded_objects
		if(!I || I.loc != src) //no item, no limb, or item is not in limb or in the person anymore
			return
		SEND_SIGNAL(src, COMSIG_CARBON_EMBED_RIP, I, L)
		return

	if(href_list["show_paper_note"])
		var/obj/item/paper/paper_note = locate(href_list["show_paper_note"])
		if(!paper_note)
			return

		paper_note.show_through_camera(usr)

/mob/living/carbon/on_fall()
	. = ..()
	loc?.handle_fall(src)//it's loc so it doesn't call the mob's handle_fall which does nothing

/mob/living/carbon/is_muzzled()
	return(istype(src.wear_mask, /obj/item/clothing/mask/muzzle))

/mob/living/carbon/resist_buckle()
	if(!HAS_TRAIT(src, TRAIT_RESTRAINED))
		buckled.user_unbuckle_mob(src, src)
		return

	changeNext_move(CLICK_CD_BREAKOUT)
	last_special = world.time + CLICK_CD_BREAKOUT
	var/buckle_cd = 1 MINUTES

	if(handcuffed)
		resist_restraints()
		return

	visible_message(span_warning("[src] attempts to unbuckle [p_them()]self!"), span_notice("You attempt to unbuckle yourself... (This will take around [DisplayTimeText(buckle_cd)] and you need to stay still.)"))

	if(!do_after(src, buckle_cd, target = src, timed_action_flags = IGNORE_HELD_ITEM, hidden = TRUE))
		if(buckled)
			to_chat(src, span_warning("You fail to unbuckle yourself!"))
		return

	if(QDELETED(src) || isnull(buckled))
		return

	buckled.user_unbuckle_mob(src,src)

/mob/living/carbon/resist_fire()
	return !!apply_status_effect(/datum/status_effect/stop_drop_roll)

/mob/living/carbon/resist_restraints()
	var/obj/item/I = null
	var/type = 0
	if(handcuffed)
		I = handcuffed
		type = 1
	else if(legcuffed)
		I = legcuffed
		type = 2
	if(I)
		if(type == 1)
			changeNext_move(CLICK_CD_BREAKOUT)
			last_special = world.time + CLICK_CD_BREAKOUT
		if(type == 2)
			changeNext_move(CLICK_CD_RANGE)
			last_special = world.time + CLICK_CD_RANGE
		cuff_resist(I)


/**
 * Helper to break the cuffs from hands
 * @param {obj/item} cuffs - The cuffs to break
 * @param {number} breakouttime - The time it takes to break the cuffs. Use SECONDS/MINUTES defines
 * @param {number} cuff_break - Speed multiplier, 0 is default, see _DEFINES\combat.dm
 */
/mob/living/carbon/proc/cuff_resist(obj/item/cuffs, breakouttime = 1 MINUTES, cuff_break = 0)
	if(cuffs.item_flags & BEING_REMOVED)
		to_chat(src, span_warning("You're already attempting to remove [cuffs]!"))
		return
	cuffs.item_flags |= BEING_REMOVED
	breakouttime = cuffs.breakouttime
	if(!cuff_break)
		visible_message(span_warning("[src] attempts to remove [cuffs]!"))
		to_chat(src, span_notice("You attempt to remove [cuffs]... (This will take around [DisplayTimeText(breakouttime)] and you need to stand still.)"))
		if(do_after(src, breakouttime, target = src, timed_action_flags = IGNORE_HELD_ITEM, hidden = TRUE))
			. = clear_cuffs(cuffs, cuff_break)
		else
			to_chat(src, span_warning("You fail to remove [cuffs]!"))

	else if(cuff_break == FAST_CUFFBREAK)
		breakouttime = 5 SECONDS
		visible_message(span_warning("[src] is trying to break [cuffs]!"))
		to_chat(src, span_notice("You attempt to break [cuffs]... (This will take around 5 seconds and you need to stand still.)"))
		if(do_after(src, breakouttime, target = src, timed_action_flags = IGNORE_HELD_ITEM))
			. = clear_cuffs(cuffs, cuff_break)
		else
			to_chat(src, span_warning("You fail to break [cuffs]!"))

	else if(cuff_break == INSTANT_CUFFBREAK)
		. = clear_cuffs(cuffs, cuff_break)
	cuffs.item_flags &= ~BEING_REMOVED

/mob/living/carbon/proc/uncuff()
	if (handcuffed)
		var/obj/item/W = handcuffed
		set_handcuffed(null)
		if (buckled && buckled.buckle_requires_restraints)
			buckled.unbuckle_mob(src)
		update_handcuffed()
		if (client)
			client.screen -= W
		if (W)
			W.forceMove(drop_location())
			W.dropped(src)
			if (W)
				W.layer = initial(W.layer)
				W.plane = initial(W.plane)
		changeNext_move(0)
	if (legcuffed)
		var/obj/item/W = legcuffed
		legcuffed = null
		update_worn_legcuffs()
		if (client)
			client.screen -= W
		if (W)
			W.forceMove(drop_location())
			W.dropped(src)
			if (W)
				W.layer = initial(W.layer)
				W.plane = initial(W.plane)
		changeNext_move(0)
	update_equipment_speed_mods() // In case cuffs ever change speed

/mob/living/carbon/proc/clear_cuffs(obj/item/I, cuff_break)
	if(!I.loc)
		return FALSE
	if(I != handcuffed && I != legcuffed)
		return FALSE
	visible_message(span_danger("[src] manages to [cuff_break ? "break" : "remove"] [I]!"))
	to_chat(src, span_notice("You successfully [cuff_break ? "break" : "remove"] [I]."))

	if(cuff_break)
		. = !((I == handcuffed) || (I == legcuffed))
		qdel(I)
		return TRUE

	else
		if(I == handcuffed)
			handcuffed.forceMove(drop_location())
			set_handcuffed(null)
			I.dropped(src)
			if(buckled?.buckle_requires_restraints)
				buckled.unbuckle_mob(src)
			update_handcuffed()
			return
		if(I == legcuffed)
			legcuffed.forceMove(drop_location())
			legcuffed = null
			I.dropped(src)
			update_worn_legcuffs()
			return TRUE

/mob/living/carbon/proc/accident(obj/item/I)
	if(!I || (I.item_flags & ABSTRACT) || HAS_TRAIT(I, TRAIT_NODROP))
		return

	dropItemToGround(I)

	var/modifier = 0
	if(HAS_TRAIT(src, TRAIT_CLUMSY))
		modifier -= 40 //Clumsy people are more likely to hit themselves -Honk!

	switch(rand(1,100)+modifier) //91-100=Nothing special happens
		if(-INFINITY to 0) //attack yourself
			I.attack(src,src)
		if(1 to 30) //throw it at yourself
			I.throw_impact(src)
		if(31 to 60) //Throw object in facing direction
			var/turf/target = get_turf(loc)
			var/range = rand(2,I.throw_range)
			for(var/i in 1 to range-1)
				var/turf/new_turf = get_step(target, dir)
				target = new_turf
				if(new_turf.density)
					break
			I.throw_at(target,I.throw_range,I.throw_speed,src)
		if(61 to 90) //throw it down to the floor
			var/turf/target = get_turf(loc)
			I.safe_throw_at(target,I.throw_range,I.throw_speed,src, force = move_force)

/mob/living/carbon/get_stat_tab_status()
	var/list/tab_data = ..()
	var/obj/item/organ/alien/plasmavessel/vessel = get_organ_by_type(/obj/item/organ/alien/plasmavessel)
	if(vessel)
		tab_data["Plasma Stored"] = GENERATE_STAT_TEXT("[vessel.stored_plasma]/[vessel.max_plasma]")
	if(locate(/obj/item/assembly/health) in src)
		tab_data["Health"] = GENERATE_STAT_TEXT("[health]")
	return tab_data

/mob/living/carbon/attack_ui(slot)
	if(!has_hand_for_held_index(active_hand_index))
		return 0
	return ..()

/mob/living/carbon/proc/vomit(lost_nutrition = 10, blood = FALSE, stun = TRUE, distance = 1, message = TRUE, toxic = VOMIT_TOXIC, purge = FALSE)
	if((HAS_TRAIT(src, TRAIT_NOHUNGER) || HAS_TRAIT(src, TRAIT_TOXINLOVER) || HAS_TRAIT(src, TRAIT_NOVOMIT)))
		return TRUE

	if(!has_mouth())
		return 1

	if(!blood && (nutrition < 100))
		if(message)
			visible_message(
				span_warning("[src] dry heaves!"),
				span_userdanger("You try to throw up, but there's nothing in your stomach!"),
			)
		if(stun)
			Paralyze(30)
			Knockdown(180)
		return 1

	if(is_mouth_covered()) //make this add a blood/vomit overlay later it'll be hilarious
		if(message)
			visible_message(
				span_danger("[src] throws up all over [p_them()]self!"),
				span_userdanger("You throw up all over yourself!"),
			)
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "vomit", /datum/mood_event/vomitself)
		distance = 0
	else
		if(message)
			visible_message(
				span_danger("[src] throws up!"),
				span_userdanger("You throw up!"),
			)
			if(!isflyperson(src))
				SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "vomit", /datum/mood_event/vomit)

	if(stun)
		Paralyze(15)
		Knockdown(90)

	playsound(get_turf(src), 'sound/effects/splat.ogg', 50, TRUE)

	var/need_mob_update = FALSE
	var/turf/location = get_turf(src)
	if(!blood)
		adjust_nutrition(-lost_nutrition)
		need_mob_update += adjustToxLoss(-3, updating_health = FALSE)

	for(var/i=0 to distance)
		if(blood)
			if(location)
				add_splatter_floor(location)
			if(stun)
				need_mob_update += adjustBruteLoss(3, updating_health = FALSE)
		else if(src.reagents.has_reagent(/datum/reagent/consumable/ethanol/blazaam, needs_metabolizing = TRUE))
			if(location)
				location.add_vomit_floor(src, toxic || VOMIT_PURPLE, purge)
		else
			if(location)
				location.add_vomit_floor(src, toxic, purge)//toxic barf looks different

		location = get_step(location, dir)
		if (location?.is_blocked_turf())
			break
	if(need_mob_update) // so we only have to call updatehealth() once as opposed to n times
		updatehealth()

	return TRUE

/mob/living/carbon/proc/spew_organ(power = 5, amt = 1)
	for(var/i in 1 to amt)
		if(!internal_organs.len)
			break //Guess we're out of organs!
		var/obj/item/organ/guts = pick(internal_organs)
		var/turf/T = get_turf(src)
		guts.Remove(src)
		guts.forceMove(T)
		var/atom/throw_target = get_edge_target_turf(guts, dir)
		guts.throw_at(throw_target, power, 4, src)


/mob/living/carbon/fully_replace_character_name(oldname,newname)
	..()
	if(dna)
		dna.real_name = real_name

/mob/living/carbon/set_body_position(new_value)
	. = ..()
	if(isnull(.))
		return
	if(new_value == LYING_DOWN)
		add_movespeed_modifier(/datum/movespeed_modifier/carbon_crawling)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/carbon_crawling)

//Updates the mob's health from bodyparts and mob damage variables
/mob/living/carbon/updatehealth()
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	var/total_burn	= 0
	var/total_brute	= 0
	var/total_stamina = 0
	for(var/obj/item/bodypart/BP as() in bodyparts)
		total_brute	+= (BP.brute_dam * BP.body_damage_coeff)
		total_burn	+= (BP.burn_dam * BP.body_damage_coeff)
		total_stamina += (BP.stamina_dam * BP.stam_damage_coeff)
	set_health(round(maxHealth - getOxyLoss() - getToxLoss() - getCloneLoss() - total_burn - total_brute, DAMAGE_PRECISION))
	staminaloss = round(total_stamina, DAMAGE_PRECISION)
	update_stat()
	if(((maxHealth - total_burn) < HEALTH_THRESHOLD_DEAD*2) && stat == DEAD )
		become_husk(BURN)
	med_hud_set_health()
	if(stat == SOFT_CRIT)
		add_movespeed_modifier(/datum/movespeed_modifier/carbon_softcrit)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/carbon_softcrit)
	SEND_SIGNAL(src, COMSIG_LIVING_HEALTH_UPDATE)


/mob/living/carbon/update_stamina(extend_stam_crit = FALSE)
	var/stam = getStaminaLoss()
	if(stam >= DAMAGE_PRECISION && (maxHealth - stam) <= crit_threshold && !HAS_TRAIT(src, TRAIT_NOSTAMCRIT))
		if(!stat)
			if(extend_stam_crit || !HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA))
				enter_stamcrit()
	else if(HAS_TRAIT_FROM(src, TRAIT_INCAPACITATED, STAMINA))
		REMOVE_TRAIT(src, TRAIT_INCAPACITATED, STAMINA)
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, STAMINA)
		REMOVE_TRAIT(src, TRAIT_FLOORED, STAMINA)
	else
		return
	update_stamina_hud()

/mob/living/carbon/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		sight = (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = NIGHTVISION_FOV_RANGE
		see_invisible = SEE_INVISIBLE_OBSERVER
		return

	sight = initial(sight)
	lighting_alpha = initial(lighting_alpha)
	var/obj/item/organ/eyes/E = get_organ_slot(ORGAN_SLOT_EYES)
	if(!E)
		update_tint()
	else
		see_invisible = E.see_invisible
		see_in_dark = E.see_in_dark
		sight |= E.sight_flags
		if(!isnull(E.lighting_alpha))
			lighting_alpha = E.lighting_alpha

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	if(glasses)
		var/obj/item/clothing/glasses/G = glasses
		sight |= G.vision_flags
		see_in_dark = max(G.darkness_view, see_in_dark)
		if(G.invis_override)
			see_invisible = G.invis_override
		else
			see_invisible = max(G.invis_view, see_invisible)
		if(!isnull(G.lighting_alpha))
			lighting_alpha = min(lighting_alpha, G.lighting_alpha)

	if(HAS_TRAIT(src, TRAIT_TRUE_NIGHT_VISION))
		lighting_alpha = min(lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
		see_in_dark = max(see_in_dark, 8)

	if(HAS_TRAIT(src, TRAIT_MESON_VISION))
		sight |= SEE_TURFS
		lighting_alpha = min(lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)

	if(HAS_TRAIT(src, TRAIT_THERMAL_VISION))
		sight |= SEE_MOBS
		lighting_alpha = min(lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)

	if(HAS_TRAIT(src, TRAIT_XRAY_VISION))
		sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
		see_in_dark = max(see_in_dark, 8)

	if(HAS_TRAIT(src, TRAIT_NIGHT_VISION))
		lighting_alpha = min(lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
		see_in_dark = max(see_in_dark, 8)

	if(see_override)
		see_invisible = see_override
	. = ..()


//to recalculate and update the mob's total tint from tinted equipment it's wearing.
/mob/living/carbon/proc/update_tint()
	if(!GLOB.tinted_weldhelh)
		return
	tinttotal = get_total_tint()
	if(tinttotal >= TINT_BLIND)
		become_blind(EYES_COVERED)
	else if(tinttotal >= TINT_DARKENED)
		cure_blind(EYES_COVERED)
		overlay_fullscreen("tint", /atom/movable/screen/fullscreen/impaired, 2)
	else
		cure_blind(EYES_COVERED)
		clear_fullscreen("tint", 0)

/mob/living/carbon/proc/get_total_tint()
	. = 0
	if(isclothing(head))
		. += head.tint
	if(isclothing(wear_mask))
		. += wear_mask.tint

	var/obj/item/organ/eyes/E = get_organ_slot(ORGAN_SLOT_EYES)
	if(E)
		. += E.tint
	else
		. += INFINITY

//this handles hud updates
/mob/living/carbon/update_damage_hud()

	if(!client)
		return

	if(health <= crit_threshold && !HAS_TRAIT(src,TRAIT_NOSOFTCRIT))
		var/severity = 0
		switch(health)
			if(-20 to -10)
				severity = 1
			if(-30 to -20)
				severity = 2
			if(-40 to -30)
				severity = 3
			if(-50 to -40)
				severity = 4
			if(-50 to -40)
				severity = 5
			if(-60 to -50)
				severity = 6
			if(-70 to -60)
				severity = 7
			if(-90 to -70)
				severity = 8
			if(-95 to -90)
				severity = 9
			if(-INFINITY to -95)
				severity = 10
		if(stat != HARD_CRIT && !HAS_TRAIT(src,TRAIT_NOHARDCRIT))
			var/visionseverity = 4
			switch(health)
				if(-8 to -4)
					visionseverity = 5
				if(-12 to -8)
					visionseverity = 6
				if(-16 to -12)
					visionseverity = 7
				if(-20 to -16)
					visionseverity = 8
				if(-24 to -20)
					visionseverity = 9
				if(-INFINITY to -24)
					visionseverity = 10
			overlay_fullscreen("critvision", /atom/movable/screen/fullscreen/crit/vision, visionseverity)
		else
			clear_fullscreen("critvision")
		overlay_fullscreen("crit", /atom/movable/screen/fullscreen/crit, severity)
	else
		clear_fullscreen("crit")
		clear_fullscreen("critvision")

	//Oxygen damage overlay
	if(oxyloss)
		var/severity = 0
		switch(oxyloss)
			if(10 to 20)
				severity = 1
			if(20 to 25)
				severity = 2
			if(25 to 30)
				severity = 3
			if(30 to 35)
				severity = 4
			if(35 to 40)
				severity = 5
			if(40 to 45)
				severity = 6
			if(45 to INFINITY)
				severity = 7
		overlay_fullscreen("oxy", /atom/movable/screen/fullscreen/oxy, severity)
	else
		clear_fullscreen("oxy")

	//Fire and Brute damage overlay (BSSR)
	var/hurtdamage = getBruteLoss() + getFireLoss() + damageoverlaytemp
	if(hurtdamage)
		var/severity = 0
		switch(hurtdamage)
			if(5 to 15)
				severity = 1
			if(15 to 30)
				severity = 2
			if(30 to 45)
				severity = 3
			if(45 to 70)
				severity = 4
			if(70 to 85)
				severity = 5
			if(85 to INFINITY)
				severity = 6
		overlay_fullscreen("brute", /atom/movable/screen/fullscreen/brute, severity)
	else
		clear_fullscreen("brute")

/mob/living/carbon/update_health_hud(shown_health_amount)
	if(!client || !hud_used?.healths)
		return

	if(stat == DEAD)
		hud_used.healths.icon_state = "health7"
		return

	if(SEND_SIGNAL(src, COMSIG_CARBON_UPDATING_HEALTH_HUD, shown_health_amount) & COMPONENT_OVERRIDE_HEALTH_HUD)
		return

	if(shown_health_amount == null)
		shown_health_amount = health

	if(shown_health_amount >= maxHealth)
		hud_used.healths.icon_state = "health0"

	else if(shown_health_amount > maxHealth * 0.8)
		hud_used.healths.icon_state = "health1"

	else if(shown_health_amount > maxHealth * 0.6)
		hud_used.healths.icon_state = "health2"

	else if(shown_health_amount > maxHealth * 0.4)
		hud_used.healths.icon_state = "health3"

	else if(shown_health_amount > maxHealth*0.2)
		hud_used.healths.icon_state = "health4"

	else if(shown_health_amount > 0)
		hud_used.healths.icon_state = "health5"

	else
		hud_used.healths.icon_state = "health6"

/mob/living/carbon/update_stamina_hud(shown_stamina_loss)
	if(!client || !hud_used?.stamina)
		return

	var/stam_crit_threshold = maxHealth - crit_threshold

	if(stat == DEAD)
		hud_used.stamina.icon_state = "stamina_dead"
	else

		if(shown_stamina_loss == null)
			shown_stamina_loss = getStaminaLoss()

		if(shown_stamina_loss >= stam_crit_threshold)
			hud_used.stamina.icon_state = "stamina_crit"
		else if(shown_stamina_loss > maxHealth*0.8)
			hud_used.stamina.icon_state = "stamina_5"
		else if(shown_stamina_loss > maxHealth*0.6)
			hud_used.stamina.icon_state = "stamina_4"
		else if(shown_stamina_loss > maxHealth*0.4)
			hud_used.stamina.icon_state = "stamina_3"
		else if(shown_stamina_loss > maxHealth*0.2)
			hud_used.stamina.icon_state = "stamina_2"
		else if(shown_stamina_loss > 0)
			hud_used.stamina.icon_state = "stamina_1"
		else
			hud_used.stamina.icon_state = "stamina_full"

/mob/living/carbon/proc/update_spacesuit_hud_icon(cell_state = "empty")
	if(hud_used?.spacesuit)
		hud_used.spacesuit.icon_state = "spacesuit_[cell_state]"


/mob/living/carbon/set_health(new_value)
	. = ..()
	if(. > hardcrit_threshold)
		if(health <= hardcrit_threshold && !HAS_TRAIT(src, TRAIT_NOHARDCRIT))
			ADD_TRAIT(src, TRAIT_KNOCKEDOUT, CRIT_HEALTH_TRAIT)
	else if(health > hardcrit_threshold)
		REMOVE_TRAIT(src, TRAIT_KNOCKEDOUT, CRIT_HEALTH_TRAIT)
	if(CONFIG_GET(flag/near_death_experience))
		if(. > HEALTH_THRESHOLD_NEARDEATH)
			if(health <= HEALTH_THRESHOLD_NEARDEATH && !HAS_TRAIT(src, TRAIT_NODEATH))
				ADD_TRAIT(src, TRAIT_SIXTHSENSE, "near-death")
		else if(health > HEALTH_THRESHOLD_NEARDEATH)
			REMOVE_TRAIT(src, TRAIT_SIXTHSENSE, "near-death")

/mob/living/carbon/update_stat()
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	if(stat != DEAD)
		if(health <= HEALTH_THRESHOLD_DEAD && !HAS_TRAIT(src, TRAIT_NODEATH))
			death()
			return
		if(health <= hardcrit_threshold && !HAS_TRAIT(src, TRAIT_NOHARDCRIT))
			set_stat(HARD_CRIT)
		else if(HAS_TRAIT(src, TRAIT_KNOCKEDOUT))
			set_stat(UNCONSCIOUS)
		else if(health <= crit_threshold && !HAS_TRAIT(src, TRAIT_NOSOFTCRIT))
			set_stat(SOFT_CRIT)
		else
			set_stat(CONSCIOUS)
			if(!is_blind())
				var/datum/component/blind_sense/B = GetComponent(/datum/component/blind_sense)
				B?.ClearFromParent()
	update_damage_hud()
	update_health_hud()
	update_stamina_hud()
	med_hud_set_status()

//called when we get cuffed/uncuffed
/mob/living/carbon/proc/update_handcuffed()
	if(handcuffed)
		drop_all_held_items()
		stop_pulling()
		throw_alert("handcuffed", /atom/movable/screen/alert/restrained/handcuffed, new_master = src.handcuffed)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "handcuffed", /datum/mood_event/handcuffed)
	else
		clear_alert("handcuffed")
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "handcuffed")
	update_action_buttons_icon() //some of our action buttons might be unusable when we're handcuffed.
	update_worn_handcuffs()
	update_hud_handcuffed()

/mob/living/carbon/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	if(excess_healing)
		if(dna && !HAS_TRAIT(src, TRAIT_NOBLOOD))
			blood_volume += (excess_healing * 2) //1 excess = 10 blood

		for(var/obj/item/organ/target_organ as anything in internal_organs)
			if(!target_organ.damage)
				continue

			target_organ.apply_organ_damage(excess_healing * -1, required_organ_flag = ORGAN_ORGANIC) //1 excess = 5 organ damage healed

	return ..()

/mob/living/carbon/heal_and_revive(heal_to = 75, revive_message)
	// We can't heal them if they're missing a heart
	if(needs_heart() && !get_organ_slot(ORGAN_SLOT_HEART))
		return FALSE

	// We can't heal them if they're missing their lungs
	if(!HAS_TRAIT(src, TRAIT_NOBREATH) && !isnull(dna?.species.mutantlungs) && !get_organ_slot(ORGAN_SLOT_LUNGS))
		return FALSE

	// And we can't heal them if they're missing their liver
	if(!HAS_TRAIT(src, TRAIT_NOMETABOLISM) && !isnull(dna?.species.mutantliver) && !get_organ_slot(ORGAN_SLOT_LIVER))
		return FALSE

	// We don't want walking husks god no
	if(HAS_TRAIT(src, TRAIT_HUSK))
		src.cure_husk()
	return ..()

/mob/living/carbon/fully_heal(heal_flags = HEAL_ALL)
	// Should be handled via signal on embedded, or via heal on bodypart
	// Otherwise I don't care to give it a separate flag
	remove_all_embedded_objects()

	if(heal_flags & HEAL_NEGATIVE_DISEASES)
		for(var/datum/disease/disease as anything in diseases)
			if(disease.danger != DISEASE_BENEFICIAL && disease.danger != DISEASE_POSITIVE)
				disease.cure(FALSE)

	if(heal_flags & HEAL_LIMBS)
		regenerate_limbs()

	if(heal_flags & (HEAL_REFRESH_ORGANS|HEAL_ORGANS))
		regenerate_organs()
		if(ismoth(src))
			REMOVE_TRAIT(src, TRAIT_MOTH_BURNT, "fire")

	if(heal_flags & HEAL_TRAUMAS)
		cure_all_traumas(TRAUMA_RESILIENCE_MAGIC)
		// Addictions are like traumas
		if(mind)
			for(var/addiction_type in subtypesof(/datum/addiction))
				mind.remove_addiction_points(addiction_type, MAX_ADDICTION_POINTS) //Remove the addiction!

	if(heal_flags & HEAL_RESTRAINTS)
		QDEL_NULL(handcuffed)
		QDEL_NULL(legcuffed)
		set_handcuffed(null)
		update_handcuffed()

	// clear bodypart stamina since stam_damage_coeff causes setStaminaLoss(0) to insufficient heal (coefficient-adjusted total < raw total)
	if(heal_flags & HEAL_STAM)
		for(var/obj/item/bodypart/BP as anything in bodyparts)
			if(BP.stamina_dam)
				BP.heal_damage(0, 0, BP.stamina_dam, forced = TRUE)
		update_stamina()

	return ..()

/mob/living/carbon/can_be_revived()
	if(!get_organ_by_type(/obj/item/organ/brain) && (!mind || !mind.has_antag_datum(/datum/antagonist/changeling)))
		return FALSE
	return ..()

/mob/living/carbon/harvest(mob/living/user)
	if(QDELETED(src))
		return
	var/organs_amt = 0
	for(var/X in internal_organs)
		var/obj/item/organ/O = X
		if(prob(50))
			organs_amt++
			O.Remove(src)
			O.forceMove(drop_location())
	if(organs_amt)
		to_chat(user, span_notice("You retrieve some of [src]\'s internal organs!"))

/mob/living/carbon/proc/create_bodyparts()
	var/list/bodyparts_paths = bodyparts.Copy()
	bodyparts = list()
	for(var/bodypart_path in bodyparts_paths)
		var/obj/item/bodypart/bodypart_instance = new bodypart_path()
		bodypart_instance.set_owner(src)
		add_bodypart(bodypart_instance)

/// Called when a new hand is added
/mob/living/carbon/proc/on_added_hand(obj/item/bodypart/arm/new_hand, hand_index)
	if(hand_index > hand_bodyparts.len)
		hand_bodyparts.len = hand_index
	hand_bodyparts[hand_index] = new_hand

/// Cleans up references to a hand when it is dismembered or deleted
/mob/living/carbon/proc/on_lost_hand(obj/item/bodypart/arm/lost_hand)
	hand_bodyparts[lost_hand.held_index] = null

///Proc to hook behavior on bodypart additions. Do not directly call. You're looking for [/obj/item/bodypart/proc/attach_limb()].
/mob/living/carbon/proc/add_bodypart(obj/item/bodypart/new_bodypart)
	SHOULD_NOT_OVERRIDE(TRUE)

	bodyparts += new_bodypart
	new_bodypart.set_owner(src)

	switch(new_bodypart.body_part)
		if(LEG_LEFT, LEG_RIGHT)
			set_num_legs(num_legs + 1)
			if(!new_bodypart.bodypart_disabled)
				set_usable_legs(usable_legs + 1)
		if(ARM_LEFT, ARM_RIGHT)
			set_num_hands(num_hands + 1)
			if(!new_bodypart.bodypart_disabled)
				set_usable_hands(usable_hands + 1)

	synchronize_bodytypes()

///Proc to hook behavior on bodypart removals.  Do not directly call. You're looking for [/obj/item/bodypart/proc/drop_limb()].
/mob/living/carbon/proc/remove_bodypart(obj/item/bodypart/old_bodypart)
	SHOULD_NOT_OVERRIDE(TRUE)

	bodyparts -= old_bodypart

	switch(old_bodypart.body_part)
		if(LEG_LEFT, LEG_RIGHT)
			set_num_legs(num_legs - 1)
			if(!old_bodypart.bodypart_disabled)
				set_usable_legs(usable_legs - 1)
		if(ARM_LEFT, ARM_RIGHT)
			set_num_hands(num_hands - 1)
			if(!old_bodypart.bodypart_disabled)
				set_usable_hands(usable_hands - 1)

	synchronize_bodytypes()

/mob/living/carbon/proc/create_internal_organs()
	for(var/X in internal_organs)
		var/obj/item/organ/I = X
		I.Insert(src)

/mob/living/carbon/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_MAKE_AI, "Make AI")
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_BODYPART, "Modify bodypart")
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_ORGANS, "Modify organs")
	VV_DROPDOWN_OPTION(VV_HK_MARTIAL_ART, "Give Martial Arts")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_TRAUMA, "Give Brain Trauma")
	VV_DROPDOWN_OPTION(VV_HK_CURE_TRAUMA, "Cure Brain Traumas")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_MUTATION, "Give Mutation")
	VV_DROPDOWN_OPTION(VV_HK_REMOVE_MUTATION, "Remove Mutation")

/mob/living/carbon/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_MODIFY_BODYPART])
		if(!check_rights(R_SPAWN))
			return
		var/edit_action = input(usr, "What would you like to do?","Modify Body Part") as null|anything in list("replace","remove")
		if(!edit_action)
			return
		var/list/limb_list = list()
		if(edit_action == "remove")
			for(var/obj/item/bodypart/B as anything in bodyparts)
				limb_list += B.body_zone
				limb_list -= BODY_ZONE_CHEST
		else
			limb_list = list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_CHEST)
		var/result = input(usr, "Please choose which bodypart to [edit_action]","[capitalize(edit_action)] Bodypart") as null|anything in sort_list(limb_list)
		if(result)
			var/obj/item/bodypart/BP = get_bodypart(result)
			var/list/limbtypes = list()
			switch(result)
				if(BODY_ZONE_CHEST)
					limbtypes = typesof(/obj/item/bodypart/chest)
				if(BODY_ZONE_R_ARM)
					limbtypes = typesof(/obj/item/bodypart/arm/right)
				if(BODY_ZONE_L_ARM)
					limbtypes = typesof(/obj/item/bodypart/arm/left)
				if(BODY_ZONE_HEAD)
					limbtypes = typesof(/obj/item/bodypart/head)
				if(BODY_ZONE_L_LEG)
					limbtypes = typesof(/obj/item/bodypart/leg/left)
				if(BODY_ZONE_R_LEG)
					limbtypes = typesof(/obj/item/bodypart/leg/right)
			switch(edit_action)
				if("remove")
					if(BP)
						BP.drop_limb()
						admin_ticket_log("[key_name_admin(usr)] has removed [src]'s [parse_zone(BP.body_zone)]")
					else
						to_chat(usr, span_boldwarning("[src] doesn't have such bodypart."))
						admin_ticket_log("[key_name_admin(usr)] has attempted to modify the bodyparts of [src]")
				if("replace")
					var/limb2add = input(usr, "Select a bodypart type to add", "Add/Replace Bodypart") as null|anything in sort_list(limbtypes)
					var/obj/item/bodypart/new_bp = new limb2add()

					if(new_bp.replace_limb(src, special = TRUE))
						admin_ticket_log("[key_name_admin(usr)] has replaced [src]'s [BP.type] with [new_bp.type]")
						qdel(BP)
					else
						to_chat(usr, "Failed to replace bodypart! They might be incompatible.")
						admin_ticket_log("[key_name_admin(usr)] has attempted to modify the bodyparts of [src]")

	if(href_list[VV_HK_MAKE_AI])
		if(!check_rights(R_SPAWN))
			return
		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		usr.client.holder.Topic("vv_override", list("makeai"=href_list[VV_HK_TARGET]))

	if(href_list[VV_HK_MODIFY_ORGANS] && check_rights(R_FUN|R_DEBUG))
		usr.client.manipulate_organs(src)

	if(href_list[VV_HK_MARTIAL_ART] && check_rights(R_FUN))
		var/list/artpaths = subtypesof(/datum/martial_art)
		var/list/artnames = list()
		for(var/i in artpaths)
			var/datum/martial_art/M = i
			artnames[initial(M.name)] = M
		var/result = input(usr, "Choose the martial art to teach","JUDO CHOP") as null|anything in artnames
		if(!usr)
			return
		if(QDELETED(src))
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(result)
			var/chosenart = artnames[result]
			var/datum/martial_art/MA = new chosenart
			MA.teach(src)
			log_admin("[key_name(usr)] has taught [MA] to [key_name(src)].")
			message_admins(span_notice("[key_name_admin(usr)] has taught [MA] to [key_name_admin(src)]."))

	if(href_list[VV_HK_GIVE_TRAUMA] && check_rights(R_FUN|R_DEBUG))
		var/list/traumas = subtypesof(/datum/brain_trauma)
		var/result = input(usr, "Choose the brain trauma to apply","Traumatize") as null|anything in traumas
		if(!usr)
			return
		if(QDELETED(src))
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(!result)
			return
		var/datum/brain_trauma/BT = gain_trauma(result)
		if(BT)
			log_admin("[key_name(usr)] has traumatized [key_name(src)] with [BT.name]")
			message_admins(span_notice("[key_name_admin(usr)] has traumatized [key_name_admin(src)] with [BT.name]."))

	if(href_list[VV_HK_CURE_TRAUMA] && check_rights(R_FUN|R_DEBUG))
		cure_all_traumas(TRAUMA_RESILIENCE_ABSOLUTE)
		log_admin("[key_name(usr)] has cured all traumas from [key_name(src)].")
		message_admins(span_notice("[key_name_admin(usr)] has cured all traumas from [key_name_admin(src)]."))

	if(href_list[VV_HK_GIVE_MUTATION] && check_rights(R_FUN|R_DEBUG))
		if(!dna)
			to_chat(usr, "Mob doesn't have DNA")
			return
		if(HAS_TRAIT(src, TRAIT_RADIMMUNE) || HAS_TRAIT(src, TRAIT_BADDNA))
			to_chat(usr, "Mob cannot mutate")
			return
		var/list/mutations = subtypesof(/datum/mutation)
		var/result = input(usr, "Choose the mutation to give", "Mutate") as null|anything in mutations
		if(!usr)
			return
		if(!result)
			return
		if(QDELETED(src))
			to_chat(usr, "Mob doesn't exist anymore")
			return
		var/datum/mutation/MT = result
		if(dna.mutation_in_sequence(MT))
			dna.activate_mutation(MT)
			log_admin("[key_name(usr)] has activated the mutation [initial(MT.name)] in [key_name(src)]")
			message_admins(span_notice("[key_name_admin(usr)] has activated the mutation [initial(MT.name)] in [key_name_admin(src)]."))
		else
			dna.add_mutation(MT, MUT_EXTRA)
			log_admin("[key_name(usr)] has mutated [key_name(src)] with [initial(MT.name)]")
			message_admins(span_notice("[key_name_admin(usr)] has mutated [key_name_admin(src)] with [initial(MT.name)]."))

	if(href_list[VV_HK_REMOVE_MUTATION] && check_rights(R_FUN|R_DEBUG))
		if(length(dna.mutations) <= 0)
			to_chat(usr, "Mob does not have any mutations!")
			return
		if(!dna)
			to_chat(usr, "Mob doesn't have DNA")
			return
		var/result = input(usr, "Choose the mutation to remove", "Un-mutate") as null|anything in dna.mutations
		if(!usr)
			return
		if(QDELETED(src))
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(!result)
			return
		var/datum/mutation/MT = result
		dna.remove_mutation(MT.type)
		log_admin("[key_name(usr)] has removed [MT.name] from [key_name(src)]")
		message_admins(span_notice("[key_name_admin(usr)] has removed [MT.name] from [key_name_admin(src)]."))

/mob/living/carbon/has_mouth()
	var/obj/item/bodypart/head/head = get_bodypart(BODY_ZONE_HEAD)
	if(head && head.mouth)
		return TRUE

/mob/living/carbon/can_resist()
	return bodyparts.len > 2 && ..()

/mob/living/carbon/proc/hypnosis_vulnerable()
	if(HAS_TRAIT(src, TRAIT_MINDSHIELD))
		return FALSE
	if(has_status_effect(/datum/status_effect/hallucination))
		return TRUE

	if(IsSleeping())
		return TRUE
	if(HAS_TRAIT(src, TRAIT_DUMB))
		return TRUE
	var/datum/component/mood/mood = src.GetComponent(/datum/component/mood)
	if(mood)
		if(mood.sanity < SANITY_UNSTABLE)
			return TRUE

/mob/living/carbon/wash(clean_types)
	. = ..()

	// Wash equipped stuff that cannot be covered
	for(var/obj/item/held_thing in held_items)
		if(held_thing.wash(clean_types))
			. = TRUE

	if(back?.wash(clean_types))
		update_worn_back(0)
		. = TRUE

	if(head?.wash(clean_types))
		update_worn_head()
		. = TRUE

	// Check and wash stuff that can be covered
	var/list/obscured = check_obscured_slots()

	// If the eyes are covered by anything but glasses, that thing will be covering any potential glasses as well.
	if(glasses && is_eyes_covered(FALSE, TRUE, TRUE) && glasses.wash(clean_types))
		update_worn_glasses()
		. = TRUE

	if(wear_mask && !(ITEM_SLOT_MASK in obscured) && wear_mask.wash(clean_types))
		update_worn_mask()
		. = TRUE

	if(ears && !(ITEM_SLOT_EARS in obscured) && ears.wash(clean_types))
		update_worn_ears()
		. = TRUE

	if(wear_neck && !(ITEM_SLOT_NECK in obscured) && wear_neck.wash(clean_types))
		update_worn_neck()
		. = TRUE

	if(shoes && !(ITEM_SLOT_FEET in obscured) && shoes.wash(clean_types))
		update_worn_shoes()
		. = TRUE

	if(gloves && !(ITEM_SLOT_GLOVES in obscured) && gloves.wash(clean_types))
		update_worn_gloves()
		. = TRUE

/mob/living/carbon/set_gender(ngender = NEUTER, silent = FALSE, update_icon = TRUE, forced = FALSE)
	var/opposite_gender = gender != ngender
	. = ..()
	if(!.)
		return
	if(dna && opposite_gender)
		if(ngender == MALE || ngender == FEMALE)
			dna.features["body_model"] = ngender
			if(!silent)
				var/adj = ngender == MALE ? "masculine" : "feminine"
				visible_message(span_boldnotice("[src] suddenly looks more [adj]!"), span_boldwarning("You suddenly feel more [adj]!"))
		else if(ngender == NEUTER)
			dna.features["body_model"] = MALE
	if(update_icon)
		update_body()
		update_body_parts(TRUE)

/// Modifies the handcuffed value if a different value is passed, returning FALSE otherwise. The variable should only be changed through this proc.
/mob/living/carbon/proc/set_handcuffed(new_value)
	if(handcuffed == new_value)
		return FALSE
	. = handcuffed
	handcuffed = new_value
	if(.)
		if(!handcuffed)
			REMOVE_TRAIT(src, TRAIT_RESTRAINED, HANDCUFFED_TRAIT)
	else if(handcuffed)
		ADD_TRAIT(src, TRAIT_RESTRAINED, HANDCUFFED_TRAIT)


/mob/living/carbon/on_lying_down(new_lying_angle)
	. = ..()
	if(!buckled || buckled.buckle_lying != 0)
		lying_angle_on_lying_down(new_lying_angle)


/// Special carbon interaction on lying down, to transform its sprite by a rotation.
/mob/living/carbon/proc/lying_angle_on_lying_down(new_lying_angle)
	if(!new_lying_angle)
		set_lying_angle(pick(90, 270))
	else
		set_lying_angle(new_lying_angle)

/mob/living/carbon/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, disgust))
			set_disgust(var_value)
			. = TRUE
		if(NAMEOF(src, handcuffed))
			set_handcuffed(var_value)
			. = TRUE

	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return

	return ..()

/mob/living/carbon/get_attack_type()
	var/datum/species/species = dna?.species
	if (species)
		return species.attack_type
	return ..()

/mob/living/carbon/proc/_signal_body_part_update(datum/source)
	SIGNAL_HANDLER
	update_body_parts()

/// Returns whether or not the carbon should be able to be shocked
/mob/living/carbon/proc/should_electrocute(power_source)
	if (ismecha(loc))
		return FALSE

	if (wearing_shock_proof_gloves())
		return FALSE

	if(!get_powernet_info_from_source(power_source))
		return FALSE

	if (HAS_TRAIT(src, TRAIT_SHOCKIMMUNE))
		return FALSE

	return TRUE

/// Returns if the carbon is wearing shock proof gloves
/mob/living/carbon/proc/wearing_shock_proof_gloves()
	return gloves?.siemens_coefficient == 0
