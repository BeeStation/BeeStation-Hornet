/mob/living
	///Used for tracking poking data
	var/time_of_last_poke = 0
	///Used for tracking accidental attacks
	var/time_of_last_attack_dealt = 0
	///Used for tracking accidental attacks
	var/time_of_last_attack_recieved = 0

/mob/living/Initialize(mapload)
	. = ..()
	register_init_signals()
	if(unique_name)
		name = "[name] ([rand(1, 1000)])"
		real_name = name
	var/datum/atom_hud/data/human/medical/advanced/medhud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medhud.add_to_hud(src)
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	faction += "[REF(src)]"
	GLOB.mob_living_list += src
	initialize_footstep()
	if (playable)
		set_playable()	//announce to ghosts

/mob/living/proc/initialize_footstep()
	AddComponent(/datum/component/footstep)

/mob/living/prepare_huds()
	..()
	prepare_data_huds()

/mob/living/proc/prepare_data_huds()
	med_hud_set_health()
	med_hud_set_status()

/mob/living/Destroy()
	if(LAZYLEN(status_effects))
		for(var/s in status_effects)
			var/datum/status_effect/S = s
			if(S.on_remove_on_mob_delete) //the status effect calls on_remove when its mob is deleted
				qdel(S)
			else
				S.be_replaced()
	if(ranged_ability)
		ranged_ability.remove_ranged_ability(src)
	if(buckled)
		buckled.unbuckle_mob(src,force=1)

	remove_from_all_data_huds()
	GLOB.mob_living_list -= src
	QDEL_LIST(diseases)
	return ..()

/mob/living/onZImpact(turf/T, levels)
	if(!isgroundlessturf(T))
		ZImpactDamage(T, levels)
		if(pulling)
			stop_pulling()
		if(buckled)
			buckled.unbuckle_mob(src)
	return ..()

// The goal here:
// 1 level: Your legs are mildly injured. Probably a bit slow
// 2 levels: Your legs are broken, but you are still conscious
// 3+ levels: You ded/near ded
/mob/living/proc/get_distributed_zimpact_damage(levels)
	return (levels * 15) ** 1.4

/mob/living/proc/ZImpactDamage(turf/T, levels)
	apply_general_zimpact_damage(T, levels)

/mob/living/proc/apply_general_zimpact_damage(turf/T, levels)
	visible_message("<span class='danger'>[src] falls [levels] level\s into [T] with a sickening noise!</span>")
	var/amount_total = get_distributed_zimpact_damage(levels)
	var/total_damage_percent_left = 1
	var/obj/item/bodypart/left_leg = get_bodypart(BODY_ZONE_L_LEG)
	var/obj/item/bodypart/right_leg = get_bodypart(BODY_ZONE_R_LEG)
	if(left_leg && !left_leg.bodypart_disabled)
		total_damage_percent_left -= 0.45
		apply_damage(amount_total * 0.45, BRUTE, BODY_ZONE_L_LEG)
	if(right_leg && !right_leg.bodypart_disabled)
		total_damage_percent_left -= 0.45
		apply_damage(amount_total * 0.45, BRUTE, BODY_ZONE_R_LEG)
	adjustBruteLoss(amount_total * total_damage_percent_left)
	Knockdown(levels * 50)

/mob/living/proc/can_bumpslam()
	REMOVE_MOB_PROPERTY(src, PROP_CANTBUMPSLAM, src.type)

//Generic Bump(). Override MobBump() and ObjBump() instead of this.
/mob/living/Bump(atom/A)
	if(..()) //we are thrown onto something
		return
	if(buckled || now_pushing)
		return
	if((confused || is_blind()) && stat == CONSCIOUS && (mobility_flags & MOBILITY_STAND) && m_intent == "run" && !ismovable(A) && !HAS_MOB_PROPERTY(src, PROP_CANTBUMPSLAM))  // ported from VORE, sue me
		APPLY_MOB_PROPERTY(src, PROP_CANTBUMPSLAM, src.type) //Bump() is called continuously so ratelimit the check to 20 seconds if it passes or 5 if it doesn't
		if(prob(10))
			playsound(get_turf(src), "punch", 25, 1, -1)
			visible_message("<span class='warning'>[src] [pick("ran", "slammed")] into \the [A]!</span>")
			apply_damage(5, BRUTE)
			Paralyze(40)
			addtimer(CALLBACK(src, PROC_REF(can_bumpslam)), 200)
		else
			addtimer(CALLBACK(src, PROC_REF(can_bumpslam)), 50)


	if(ismob(A))
		var/mob/M = A
		if(MobBump(M))
			return
	if(isobj(A))
		var/obj/O = A
		if(ObjBump(O))
			return
	if(ismovable(A))
		var/atom/movable/AM = A
		if(PushAM(AM, move_force))
			return

/mob/living/Bumped(atom/movable/AM)
	..()
	last_bumped = world.time

//Called when we bump onto a mob
/mob/living/proc/MobBump(mob/M)
	//Even if we don't push/swap places, we "touched" them, so spread fire
	spreadFire(M)

	if(now_pushing)
		return TRUE

	var/they_can_move = TRUE
	if(isliving(M))
		var/mob/living/L = M
		they_can_move = L.mobility_flags & MOBILITY_MOVE
		//Also spread diseases
		for(var/thing in diseases)
			var/datum/disease/D = thing
			if(D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
				L.ContactContractDisease(D)

		for(var/thing in L.diseases)
			var/datum/disease/D = thing
			if(D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
				ContactContractDisease(D)

		//Should stop you pushing a restrained person out of the way
		if(L.pulledby && L.pulledby != src && HAS_TRAIT(L, TRAIT_RESTRAINED))
			if(!(world.time % 5))
				to_chat(src, "<span class='warning'>[L] is restrained, you cannot push past.</span>")
			return TRUE

		if(L.pulling)
			if(ismob(L.pulling))
				var/mob/P = L.pulling
				if(HAS_TRAIT(P, TRAIT_RESTRAINED))
					if(!(world.time % 5))
						to_chat(src, "<span class='warning'>[L] is restraining [P], you cannot push past.</span>")
					return TRUE

	if(moving_diagonally)//no mob swap during diagonal moves.
		return TRUE

	if(!M.buckled && !M.has_buckled_mobs())
		var/mob_swap = FALSE
		var/too_strong = (M.move_resist > move_force) //can't swap with immovable objects unless they help us
		if(!they_can_move) //we have to physically move them
			if(!too_strong)
				mob_swap = TRUE
		else
			//You can swap with the person you are dragging on grab intent, and restrained people in most cases
			if(M.pulledby == src && a_intent == INTENT_GRAB && !too_strong)
				mob_swap = TRUE
			else if(
				!(HAS_TRAIT(M, TRAIT_NOMOBSWAP) || HAS_TRAIT(src, TRAIT_NOMOBSWAP))&&\
				((HAS_TRAIT(M, TRAIT_RESTRAINED) && !too_strong) || M.a_intent == INTENT_HELP) &&\
				(HAS_TRAIT(src, TRAIT_RESTRAINED) || a_intent == INTENT_HELP)
			)
				mob_swap = TRUE
		if(mob_swap)
			//switch our position with M
			if(loc && !loc.Adjacent(M.loc))
				return TRUE
			now_pushing = 1
			var/oldloc = loc
			var/oldMloc = M.loc


			var/M_passmob = (M.pass_flags & PASSMOB) // we give PASSMOB to both mobs to avoid bumping other mobs during swap.
			var/src_passmob = (pass_flags & PASSMOB)
			M.pass_flags |= PASSMOB
			pass_flags |= PASSMOB

			var/move_failed = FALSE
			if(!M.Move(oldloc) || !Move(oldMloc))
				M.forceMove(oldMloc)
				forceMove(oldloc)
				move_failed = TRUE
			if(!src_passmob)
				pass_flags &= ~PASSMOB
			if(!M_passmob)
				M.pass_flags &= ~PASSMOB

			now_pushing = 0

			if(!move_failed)
				return TRUE

	//okay, so we didn't switch. but should we push?
	//not if he's not CANPUSH of course
	if(!(M.status_flags & CANPUSH))
		return TRUE
	if(isliving(M))
		var/mob/living/L = M
		if(HAS_TRAIT(L, TRAIT_PUSHIMMUNE))
			return TRUE
	//If they're a human, and they're not in help intent, block pushing
	if(ishuman(M) && (M.a_intent != INTENT_HELP))
		return TRUE
	//anti-riot equipment is also anti-push
	for(var/obj/item/I in M.held_items)
		if(!isclothing(M))
			if(I.block_power >= 50)
				return

/mob/living/get_photo_description(obj/item/camera/camera)
	var/list/holding = list()
	var/len = length(held_items)
	if(len)
		for(var/obj/item/I in held_items)
			if(!length(holding))
				holding += "[p_they(TRUE)] [p_are()] holding \a [I]"
			else if(held_items.Find(I) == len)
				holding += ", and \a [I]."
			else
				holding += ", \a [I]"
	return "You can also see [src] on the photo[health < (maxHealth * 0.75) ? ", looking a bit hurt":""].[length(holding) ? " [holding.Join("")].":""]"

//Called when we bump onto an obj
/mob/living/proc/ObjBump(obj/O)
	return

//Called when we want to push an atom/movable
/mob/living/proc/PushAM(atom/movable/AM, force = move_force)
	if(now_pushing)
		return TRUE
	if(moving_diagonally)// no pushing during diagonal moves.
		return TRUE
	if(!client && (mob_size < MOB_SIZE_SMALL))
		return
	now_pushing = TRUE
	var/dir_to_target = get_dir(src, AM)

	// If there's no dir_to_target then the player is on the same turf as the atom they're trying to push.
	// This can happen when a player is stood on the same turf as a directional window. All attempts to push
	// the window will fail as get_dir will return 0 and the player will be unable to move the window when
	// it should be pushable.
	// In this scenario, we will use the facing direction of the /mob/living attempting to push the atom as
	// a fallback.
	if(!dir_to_target)
		dir_to_target = dir

	var/push_anchored = FALSE
	if((AM.move_resist * MOVE_FORCE_CRUSH_RATIO) <= force)
		if(move_crush(AM, move_force, dir_to_target))
			push_anchored = TRUE
	if((AM.move_resist * MOVE_FORCE_FORCEPUSH_RATIO) <= force)			//trigger move_crush and/or force_push regardless of if we can push it normally
		if(force_push(AM, move_force, dir_to_target, push_anchored))
			push_anchored = TRUE
	if((AM.anchored && !push_anchored) || (force < (AM.move_resist * MOVE_FORCE_PUSH_RATIO)))
		now_pushing = FALSE
		return
	if (istype(AM, /obj/structure/window))
		var/obj/structure/window/W = AM
		if(W.fulltile)
			for(var/obj/structure/window/win in get_step(W, dir_to_target))
				now_pushing = FALSE
				return
	if(pulling == AM)
		stop_pulling()
	var/current_dir
	if(isliving(AM))
		current_dir = AM.dir
	if(step(AM, dir_to_target))
		step(src, dir_to_target)
	if(current_dir)
		AM.setDir(current_dir)
	now_pushing = FALSE

/mob/living/start_pulling(atom/movable/AM, state, force = pull_force, supress_message = FALSE)
	if(!AM || !src)
		return FALSE
	if(!(AM.can_be_pulled(src, state, force)))
		return FALSE
	if(throwing || !(mobility_flags & MOBILITY_PULL))
		return FALSE

	AM.add_fingerprint(src)

	// If we're pulling something then drop what we're currently pulling and pull this instead.
	if(pulling)
		// Are we trying to pull something we are already pulling? Then just stop here, no need to continue.
		if(AM == pulling)
			return
		stop_pulling()

	changeNext_move(CLICK_CD_GRABBING)

	if(AM.pulledby)
		if(!supress_message)
			visible_message("<span class='danger'>[src] has pulled [AM] from [AM.pulledby]'s grip.</span>")
		log_combat(AM, AM.pulledby, "pulled from", src)
		AM.pulledby.stop_pulling() //an object can't be pulled by two mobs at once.

	pulling = AM
	AM.set_pulledby(src)

	SEND_SIGNAL(src, COMSIG_LIVING_START_PULL, AM, state, force)

	if(!supress_message)
		var/sound_to_play = 'sound/weapons/thudswoosh.ogg'
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			if(H.dna.species.grab_sound)
				sound_to_play = H.dna.species.grab_sound
			if(HAS_TRAIT(H, TRAIT_STRONG_GRABBER))
				sound_to_play = null
		playsound(src.loc, sound_to_play, 50, 1, -1)
	update_pull_hud_icon()

	if(ismob(AM))
		var/mob/M = AM

		log_combat(src, M, "grabbed", addition="passive grab")
		if(!supress_message && !(iscarbon(AM) && HAS_TRAIT(src, TRAIT_STRONG_GRABBER))) //Everything in this if statement handles chat messages for grabbing
			var/mob/living/L = M
			if (L.getorgan(/obj/item/organ/tail) && zone_selected == BODY_ZONE_PRECISE_GROIN) //Does the target have a tail?
				M.visible_message("<span class ='warning'>[src] grabs [L] by [L.p_their()] tail!</span>",\
								"<span class='warning'> [src] grabs you by the tail!</span>", null, null, src) //Message sent to area, Message sent to grabbee
				to_chat(src, "<span class='notice'>You grab [L] by [L.p_their()] tail!</span>")  //Message sent to grabber
			else
				M.visible_message("<span class='warning'>[src] grabs [M] [(zone_selected == BODY_ZONE_L_ARM || zone_selected == BODY_ZONE_R_ARM)? "by their hands":"passively"]!</span>", \
								"<span class='warning'>[src] grabs you [(zone_selected == BODY_ZONE_L_ARM || zone_selected == BODY_ZONE_R_ARM)? "by your hands":"passively"]!</span>", null, null, src) //Message sent to area, Message sent to grabbee
				to_chat(src, "<span class='notice'>You grab [M] [(zone_selected == BODY_ZONE_L_ARM|| zone_selected == BODY_ZONE_R_ARM)? "by their hands":"passively"]!</span>") //Message sent to grabber
		if(!iscarbon(src))
			M.LAssailant = null
		else
			M.LAssailant = WEAKREF(usr)
		if(isliving(M))
			var/mob/living/L = M
			//Share diseases that are spread by touch
			for(var/thing in diseases)
				var/datum/disease/D = thing
				if(D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
					L.ContactContractDisease(D)

			for(var/thing in L.diseases)
				var/datum/disease/D = thing
				if(D.spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
					ContactContractDisease(D)

			if(iscarbon(L))
				var/mob/living/carbon/C = L
				if(HAS_TRAIT(src, TRAIT_STRONG_GRABBER))
					C.grippedby(src)

			update_pull_movespeed()

		set_pull_offsets(M, state)

/mob/living/proc/set_pull_offsets(mob/living/M, grab_state = GRAB_PASSIVE)
	if(M.buckled)
		return //don't make them change direction or offset them if they're buckled into something.
	var/offset = 0
	switch(grab_state)
		if(GRAB_PASSIVE)
			offset = GRAB_PIXEL_SHIFT_PASSIVE
		if(GRAB_AGGRESSIVE)
			offset = GRAB_PIXEL_SHIFT_AGGRESSIVE
		if(GRAB_NECK)
			offset = GRAB_PIXEL_SHIFT_NECK
		if(GRAB_KILL)
			offset = GRAB_PIXEL_SHIFT_NECK
	M.setDir(get_dir(M, src))
	switch(M.dir)
		if(NORTH)
			animate(M, pixel_x = 0, pixel_y = offset, 3)
		if(SOUTH)
			animate(M, pixel_x = 0, pixel_y = -offset, 3)
		if(EAST)
			if(M.lying_angle == 270) //update the dragged dude's direction if we've turned
				M.set_lying_angle(90)
			animate(M, pixel_x = offset, pixel_y = 0, 3)
		if(WEST)
			if(M.lying_angle == 90)
				M.set_lying_angle(270)
			animate(M, pixel_x = -offset, pixel_y = 0, 3)

/mob/living/proc/reset_pull_offsets(mob/living/M, override)
	if(!override && M.buckled)
		return
	animate(M, pixel_x = 0, pixel_y = 0, 1)

//mob verbs are a lot faster than object verbs
//for more info on why this is not atom/pull, see examinate() in mob.dm
/mob/living/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = "Object"

	if(istype(AM) && Adjacent(AM))
		start_pulling(AM)
	else
		stop_pulling()

/mob/living/stop_pulling()
	if(ismob(pulling))
		reset_pull_offsets(pulling)
	..()
	update_pull_movespeed()
	update_pull_hud_icon()

/mob/living/verb/stop_pulling1()
	set name = "Stop Pulling"
	set category = "IC"
	stop_pulling()

//same as above
/mob/living/pointed(atom/A as mob|obj|turf in view())
	if(incapacitated())
		return FALSE
	if(!..())
		return FALSE
	visible_message("<b>[src]</b> points at [A].", "<span class='notice'>You point at [A].</span>")
	return TRUE

/mob/living/verb/succumb(whispered as null)
	set hidden = TRUE
	if (!CAN_SUCCUMB(src))
		return
	log_message("Has [whispered ? "whispered his final words" : "succumbed to death"] with [round(health, 0.1)] points of health!", LOG_ATTACK)
	adjustOxyLoss(health - HEALTH_THRESHOLD_DEAD)
	updatehealth()
	if(!whispered)
		to_chat(src, "<span class='notice'>You have given up life and succumbed to death.</span>")

	if (src.client)
		client.give_award(/datum/award/achievement/misc/succumb, client.mob)

	death()

/mob/living/incapacitated(ignore_restraints = FALSE, ignore_grab = FALSE, ignore_stasis = FALSE)
	if(HAS_TRAIT(src, TRAIT_INCAPACITATED) || (!ignore_restraints && (HAS_TRAIT(src, TRAIT_RESTRAINED) || (!ignore_grab && pulledby && pulledby.grab_state >= GRAB_AGGRESSIVE))) || (!ignore_stasis && IS_IN_STASIS(src)))
		return TRUE

/mob/living/canUseStorage()
	if (usable_hands <= 0)
		return FALSE
	return TRUE

//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(pressure)
	return pressure

/mob/living/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
	return temperature

/mob/living/proc/getMaxHealth()
	return maxHealth

/mob/living/proc/setMaxHealth(newMaxHealth)
	maxHealth = newMaxHealth

// MOB PROCS //END

/mob/living/proc/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(IsSleeping())
		to_chat(src, "<span class='notice'>You are already sleeping.</span>")
		return
	else
		if(alert(src, "You sure you want to sleep for a while?", "Sleep", "Yes", "No") == "Yes")
			SetSleeping(400) //Short nap
	update_mobility()

/mob/proc/get_contents()

/mob/living/proc/lay_down()
	set name = "Rest"
	set category = "IC"

	set_resting(!resting, FALSE)

///Proc to hook behavior to the change of value in the resting variable.
/mob/living/proc/set_resting(new_resting, silent = TRUE)
	if(new_resting == resting)
		return
	. = resting
	resting = new_resting
	if(new_resting)
		if(lying_angle == 90 || lying_angle == 270)
			if(!silent)
				to_chat(src, "<span class='notice'>You will now try to stay lying down on the floor.</span>")
		else if(buckled && buckled.buckle_lying != NO_BUCKLE_LYING)
			if(!silent)
				to_chat(src, "<span class='notice'>You will now lay down as soon as you are able to.</span>")
		else
			if(!silent)
				to_chat(src, "<span class='notice'>You lay down.</span>")
			set_lying_down()
	else
		if(lying_angle == 0)
			if(!silent)
				to_chat(src, "<span class='notice'>You will now try to remain standing up.</span>")
		else if(HAS_TRAIT(src, TRAIT_FLOORED) || (buckled && buckled.buckle_lying != NO_BUCKLE_LYING))
			if(!silent)
				to_chat(src, "<span class='notice'>You will now stand up as soon as you are able to.</span>")
		else
			if(!silent)
				to_chat(src, "<span class='notice'>You stand up.</span>")
			get_up()

	update_resting()

/mob/living/proc/update_resting()
	update_rest_hud_icon()
	update_mobility()

/mob/living/proc/get_up()
	set waitfor = FALSE
	var/static/datum/callback/rest_checks = CALLBACK(src, .proc/rest_checks_callback)
	if(!do_mob(src, src, 2 SECONDS, uninterruptible = TRUE, extra_checks = rest_checks))
		return
	if(resting || lying_angle == 0 || HAS_TRAIT(src, TRAIT_FLOORED))
		return
	set_lying_angle(0)


/mob/living/proc/rest_checks_callback()
	if(resting || lying_angle == 0 || HAS_TRAIT(src, TRAIT_FLOORED))
		return FALSE
	return TRUE


/mob/living/proc/set_lying_down(new_lying_angle)
	if(buckled && buckled.buckle_lying == 0)
		return
	if(!new_lying_angle)
		set_lying_angle(pick(90, 270))
	else
		set_lying_angle(new_lying_angle)

//Recursive function to find everything a mob is holding. Really shitty proc tbh.
/mob/living/get_contents()
	var/list/ret = list()
	ret |= contents						//add our contents
	for(var/i in ret.Copy())			//iterate storage objects
		var/atom/A = i
		SEND_SIGNAL(A, COMSIG_TRY_STORAGE_RETURN_INVENTORY, ret)
	for(var/obj/item/folder/F in ret.Copy())		//very snowflakey-ly iterate folders
		ret |= F.contents
	return ret

/mob/living/proc/check_contents_for(A)
	var/list/L = get_contents()

	for(var/obj/B in L)
		if(B.type == A)
			return TRUE
	return FALSE

// Living mobs use can_inject() to make sure that the mob is not syringe-proof in general.
/mob/living/proc/can_inject()
	return TRUE

/mob/living/is_injectable(mob/user, allowmobs = TRUE)
	return (allowmobs && reagents && can_inject(user))

/mob/living/is_drawable(mob/user, allowmobs = TRUE)
	return (allowmobs && reagents && can_inject(user))

///Sets the current mob's health value. Do not call directly if you don't know what you are doing, use the damage procs, instead.
/mob/living/proc/set_health(new_value)
	. = health
	health = new_value

/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		return
	set_health(maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss())
	staminaloss = getStaminaLoss()
	update_stat()
	med_hud_set_health()
	med_hud_set_status()

//proc used to ressuscitate a mob
/mob/living/proc/revive(full_heal = 0, admin_revive = 0)
	SEND_SIGNAL(src, COMSIG_LIVING_REVIVE, src, full_heal, admin_revive)
	if(full_heal)
		fully_heal(admin_revive)
	if(stat == DEAD && can_be_revived()) //in some cases you can't revive (e.g. no brain)
		remove_from_dead_mob_list()
		add_to_alive_mob_list()
		set_suicide(FALSE)
		set_stat(UNCONSCIOUS) //the mob starts unconscious,
		blind_eyes(1)
		updatehealth() //then we check if the mob should wake up.
		update_mobility()
		update_sight()
		clear_alert("not_enough_oxy")
		reload_fullscreen()
		. = 1
		if(mind)
			for(var/S in mind.spell_list)
				var/obj/effect/proc_holder/spell/spell = S
				spell.updateButtonIcon()

/mob/living/proc/remove_CC(should_update_mobility = TRUE)
	SetStun(0, FALSE)
	SetKnockdown(0, FALSE)
	SetImmobilized(0, FALSE)
	SetParalyzed(0, FALSE)
	SetSleeping(0, FALSE)
	setStaminaLoss(0)
	SetUnconscious(0, FALSE)
	if(should_update_mobility)
		update_mobility()

//proc used to completely heal a mob.
/mob/living/proc/fully_heal(admin_revive = 0)
	restore_blood()
	setToxLoss(0, 0) //zero as second argument not automatically call updatehealth().
	setOxyLoss(0, 0)
	setCloneLoss(0, 0)
	setStaminaLoss(0, 0)
	SetUnconscious(0, FALSE)
	set_disgust(0)
	SetStun(0, FALSE)
	SetKnockdown(0, FALSE)
	SetImmobilized(0, FALSE)
	SetParalyzed(0, FALSE)
	SetSleeping(0, FALSE)
	radiation = 0
	set_nutrition(NUTRITION_LEVEL_FED + 50)
	bodytemperature = BODYTEMP_NORMAL
	set_blindness(0)
	set_blurriness(0)
	set_dizziness(0)

	cure_nearsighted()
	cure_blind()
	cure_husk()
	hallucination = 0
	heal_overall_damage(INFINITY, INFINITY, INFINITY, null, TRUE) //heal brute and burn dmg on both organic and robotic limbs, and update health right away.
	ExtinguishMob()
	fire_stacks = 0
	confused = 0
	dizziness = 0
	drowsyness = 0
	stuttering = 0
	slurring = 0
	jitteriness = 0
	var/datum/component/mood/mood = GetComponent(/datum/component/mood)
	if (mood)
		mood.remove_temp_moods(admin_revive)
	update_mobility()
	stop_sound_channel(CHANNEL_HEARTBEAT)

//proc called by revive(), to check if we can actually ressuscitate the mob (we don't want to revive him and have him instantly die again)
/mob/living/proc/can_be_revived()
	. = 1
	if(health <= HEALTH_THRESHOLD_DEAD)
		return 0

/mob/living/proc/update_damage_overlays()
	return

/mob/living/Move(atom/newloc, direct)
	if(lying_angle != 0)
		lying_angle_on_movement(direct)
	if (buckled && buckled.loc != newloc) //not updating position
		if (!buckled.anchored)
			return buckled.Move(newloc, direct)
		else
			return 0

	var/old_direction = dir
	var/turf/T = loc

	if(pulling)
		update_pull_movespeed()

	. = ..()

	if(pulledby && moving_diagonally != FIRST_DIAG_STEP && get_dist(src, pulledby) > 1 && (pulledby != moving_from_pull))//separated from our puller and not in the middle of a diagonal move.
		pulledby.stop_pulling()
	else
		if(isliving(pulledby))
			var/mob/living/L = pulledby
			L.set_pull_offsets(src, pulledby.grab_state)

	if(active_storage && !(CanReach(active_storage.parent,view_only = TRUE)))
		active_storage.close(src)

	if(!(mobility_flags & MOBILITY_STAND) && !buckled && prob(getBruteLoss()*200/maxHealth))
		makeTrail(newloc, T, old_direction)

///Called by mob Move() when the lying_angle is different than zero, to better visually simulate crawling.
/mob/living/proc/lying_angle_on_movement(direct)
	if(direct & EAST)
		set_lying_angle(90)
	else if(direct & WEST)
		set_lying_angle(270)

/mob/living/carbon/alien/humanoid/lying_angle_on_movement(direct)
	return

/mob/living/proc/makeTrail(turf/target_turf, turf/start, direction, spec_color)
	if(!has_gravity() || (movement_type & THROWN))
		return
	var/blood_exists = FALSE

	for(var/obj/effect/decal/cleanable/trail_holder/C in start) //checks for blood splatter already on the floor
		blood_exists = TRUE
	if(isturf(start))
		var/trail_type = getTrail()
		if(trail_type)
			var/brute_ratio = round(getBruteLoss() / maxHealth, 0.1)
			if(blood_volume && blood_volume > max(BLOOD_VOLUME_NORMAL*(1 - brute_ratio * 0.25), 0))//don't leave trail if blood volume below a threshold
				blood_volume = max(blood_volume - max(1, brute_ratio * 2), 0) 					//that depends on our brute damage.
				var/newdir = get_dir(target_turf, start)
				if(newdir != direction)
					newdir = newdir | direction
					if(newdir == 3) //N + S
						newdir = NORTH
					else if(newdir == 12) //E + W
						newdir = EAST
				if((newdir in GLOB.cardinals) && (prob(50)))
					newdir = turn(get_dir(target_turf, start), 180)
				if(!blood_exists)
					new /obj/effect/decal/cleanable/trail_holder(start, get_static_viruses())

				for(var/obj/effect/decal/cleanable/trail_holder/TH in start)
					if((!(newdir in TH.existing_dirs) || trail_type == "trails_1" || trail_type == "trails_2") && TH.existing_dirs.len <= 16) //maximum amount of overlays is 16 (all light & heavy directions filled)
						TH.existing_dirs += newdir
						TH.add_overlay(image('icons/effects/blood.dmi', trail_type, dir = newdir))
						TH.transfer_mob_blood_dna(src)

						if(spec_color)
							TH.color = spec_color

/mob/living/carbon/human/makeTrail(turf/T, turf/start, direction, spec_color)
	if((NOBLOOD in dna.species.species_traits) || !bleed_rate || bleedsuppress)
		return
	spec_color = dna.species.blood_color
	..()

/mob/living/proc/getTrail()
	if(getBruteLoss() < 300)
		return pick("ltrails_1", "ltrails_2")
	else
		return pick("trails_1", "trails_2")

/mob/living/experience_pressure_difference(pressure_difference, direction, pressure_resistance_prob_delta = 0)
	if(buckled)
		return
	if(client && client.move_delay >= world.time + world.tick_lag*2)
		pressure_resistance_prob_delta -= 30

	var/list/turfs_to_check = list()

	if(has_limbs)
		var/turf/T = get_step(src, angle2dir(dir2angle(direction)+90))
		if(T)
			turfs_to_check += T

		T = get_step(src, angle2dir(dir2angle(direction)-90))
		if(T)
			turfs_to_check += T

		for(var/t in turfs_to_check)
			T = t
			if(T.density)
				pressure_resistance_prob_delta -= 20
				continue
			for(var/atom/movable/AM in T)
				if(AM.density && AM.anchored)
					pressure_resistance_prob_delta -= 20
					break
	. = ..(pressure_difference, direction, pressure_resistance_prob_delta)

/mob/living/can_resist()
	return !((next_move > world.time) || incapacitated(ignore_restraints = TRUE, ignore_stasis = TRUE))

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!can_resist())
		return
	changeNext_move(CLICK_CD_RESIST)

	SEND_SIGNAL(src, COMSIG_LIVING_RESIST, src)
	//resisting grabs (as if it helps anyone...)
	if(!HAS_TRAIT(src, TRAIT_RESTRAINED) && pulledby)
		log_combat(src, pulledby, "resisted grab")
		resist_grab()
		return

	//unbuckling yourself
	if(buckled && last_special <= world.time)
		resist_buckle()

	//Breaking out of a container (Locker, sleeper, cryo...)
	else if(istype(loc, /atom/movable))
		var/atom/movable/M = loc
		M.container_resist(src)

	else if(mobility_flags & MOBILITY_MOVE)
		if(on_fire)
			resist_fire() //stop, drop, and roll
		else if(last_special <= world.time)
			resist_restraints() //trying to remove cuffs.


/mob/proc/resist_grab(moving_resist)
	return 1 //returning 0 means we successfully broke free

/mob/living/resist_grab(moving_resist)
	. = TRUE
	if(pulledby.grab_state || resting || HAS_TRAIT(src, TRAIT_GRABWEAKNESS))
		var/altered_grab_state = pulledby.grab_state
		if((resting || HAS_TRAIT(src, TRAIT_GRABWEAKNESS)) && pulledby.grab_state < GRAB_KILL) //If resting, resisting out of a grab is equivalent to 1 grab state higher. wont make the grab state exceed the normal max, however
			altered_grab_state++

		var/resist_chance = BASE_GRAB_RESIST_CHANCE // see defines/combat.dm
		resist_chance = max(resist_chance/altered_grab_state-sqrt((getStaminaLoss()+getBruteLoss()/2)*(3-altered_grab_state)), 0) // https://i.imgur.com/6yAT90T.png for sample output values
		if(prob(resist_chance))
			visible_message("<span class='danger'>[src] has broken free of [pulledby]'s grip!</span>")
			log_combat(pulledby, src, "broke grab")
			pulledby.stop_pulling()
			return FALSE
		else
			visible_message("<span class='danger'>[src] struggles as they fail to break free of [pulledby]'s grip!</span>")
		if(moving_resist && client) //we resisted by trying to move
			client.move_delay = world.time + 2 SECONDS
	else
		pulledby.stop_pulling()
		return FALSE

/mob/living/proc/resist_buckle()
	buckled.user_unbuckle_mob(src,src)

/mob/living/proc/resist_fire()
	return

/mob/living/proc/resist_restraints()
	return

/mob/living/proc/get_visible_name()
	return name

/mob/living/update_gravity(has_gravity,override = 0)
	if(!SSticker.HasRoundStarted())
		return
	if(has_gravity)
		if(has_gravity == 1)
			clear_alert("gravity")
		else
			if(has_gravity >= GRAVITY_DAMAGE_TRESHOLD)
				throw_alert("gravity", /atom/movable/screen/alert/veryhighgravity)
			else
				throw_alert("gravity", /atom/movable/screen/alert/highgravity)
	else
		throw_alert("gravity", /atom/movable/screen/alert/weightless)
	if(!override && !is_flying())
		float(!has_gravity)

/mob/living/float(on)
	if(throwing)
		return
	var/fixed = 0
	if(anchored || (buckled && buckled.anchored))
		fixed = 1
	if(on && !(movement_type & FLOATING) && !fixed)
		animate(src, pixel_y = 2, time = 10, loop = -1, flags = ANIMATION_RELATIVE)
		animate(pixel_y = -2, time = 10, loop = -1, flags = ANIMATION_RELATIVE)
		setMovetype(movement_type | FLOATING)
	else if(((!on || fixed) && (movement_type & FLOATING)))
		animate(src, pixel_y = get_standard_pixel_y_offset(lying_angle), time = 10)
		setMovetype(movement_type & ~FLOATING)

// The src mob is trying to strip an item from someone
// Override if a certain type of mob should be behave differently when stripping items (can't, for example)
/mob/living/stripPanelUnequip(obj/item/what, mob/who, where)
	if(!what.canStrip(who))
		to_chat(src, "<span class='warning'>You can't remove [what.name], it appears to be stuck!</span>")
		return
	who.visible_message("<span class='danger'>[src] tries to remove [who]'s [what.name].</span>", \
					"<span class='userdanger'>[src] tries to remove your [what.name].</span>")
	what.add_fingerprint(src)
	if(do_after(src, what.strip_delay, who))
		if(what && Adjacent(who))
			if(islist(where))
				var/list/L = where
				if(what == who.get_item_for_held_index(L[2]))
					if(what.doStrip(src, who))
						log_combat(src, who, "stripped [what] off")
			if(what == who.get_item_by_slot(where))
				if(what.doStrip(src, who))
					log_combat(src, who, "stripped [what] off")

// The src mob is trying to place an item on someone
// Override if a certain mob should be behave differently when placing items (can't, for example)
/mob/living/stripPanelEquip(obj/item/what, mob/who, where)
	what = src.get_active_held_item()
	if(what && (HAS_TRAIT(what, TRAIT_NODROP)))
		to_chat(src, "<span class='warning'>You can't put \the [what.name] on [who], it's stuck to your hand!</span>")
		return
	if(what)
		var/list/where_list
		var/final_where

		if(islist(where))
			where_list = where
			final_where = where[1]
		else
			final_where = where

		if(!what.mob_can_equip(who, src, final_where, TRUE, TRUE))
			to_chat(src, "<span class='warning'>\The [what.name] doesn't fit in that place!</span>")
			return

		who.visible_message("<span class='notice'>[src] tries to put [what] on [who].</span>", \
					"<span class='notice'>[src] tries to put [what] on you.</span>")
		if(do_after(src, what.equip_delay_other, who))
			if(what && Adjacent(who) && what.mob_can_equip(who, src, final_where, TRUE, TRUE))
				if(temporarilyRemoveItemFromInventory(what))
					if(where_list)
						if(!who.put_in_hand(what, where_list[2]))
							what.forceMove(get_turf(who))
					else
						who.equip_to_slot(what, where, TRUE)

/mob/living/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_SIX) //your puny magboots/wings/whatever will not save you against supermatter singularity
		throw_at(S, 14, 3, src, TRUE)
	else if(!src.mob_negates_gravity())
		step_towards(src,S)

/mob/living/proc/do_jitter_animation(jitteriness)
	var/amplitude = min(4, (jitteriness/100) + 1)
	var/pixel_x_diff = rand(-amplitude, amplitude)
	var/pixel_y_diff = rand(-amplitude / 3, amplitude / 3)
	var/final_pixel_x = get_standard_pixel_x_offset(lying_angle)
	var/final_pixel_y = get_standard_pixel_y_offset(lying_angle)
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 2, loop = 6)
	animate(pixel_x = final_pixel_x , pixel_y = final_pixel_y , time = 2)
	setMovetype(movement_type & ~FLOATING) // If we were without gravity, the bouncing animation got stopped, so we make sure to restart it in next life().

/mob/living/proc/get_temperature(datum/gas_mixture/environment)
	var/loc_temp = environment ? environment.return_temperature() : T0C
	if(isobj(loc))
		var/obj/oloc = loc
		var/obj_temp = oloc.return_temperature()
		if(obj_temp != null)
			loc_temp = obj_temp
	else if(isspaceturf(get_turf(src)))
		var/turf/heat_turf = get_turf(src)
		loc_temp = heat_turf.return_temperature()
	return loc_temp

/mob/living/proc/get_standard_pixel_x_offset(lying = 0)
	return initial(pixel_x)

/mob/living/proc/get_standard_pixel_y_offset(lying = 0)
	return initial(pixel_y)


/mob/living/proc/can_track(mob/living/user)
	//basic fast checks go first. When overriding this proc, I recommend calling ..() at the end.
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	if(is_centcom_level(T.z)) //dont detect mobs on centcom
		return FALSE
	if(is_away_level(T.z))
		return FALSE
	if(user != null && src == user)
		return FALSE
	if(invisibility || alpha == 0)//cloaked
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_LIVING_CAN_TRACK, args) & COMPONENT_CANT_TRACK)
		return FALSE

	// Now, are they viewable by a camera? (This is last because it's the most intensive check)
	if(!near_camera(src))
		return FALSE

	return TRUE

//used in datum/reagents/reaction() proc
/mob/living/proc/get_permeability_protection()
	return 0

/mob/living/proc/harvest(mob/living/user) //used for extra objects etc. in butchering
	return

/mob/living/canUseTopic(atom/movable/M, be_close=FALSE, no_dexterity=FALSE, no_tk=FALSE)
	if(incapacitated())
		to_chat(src, "<span class='warning'>You can't do that right now!</span>")
		return FALSE
	if(be_close && !in_range(M, src))
		to_chat(src, "<span class='warning'>You are too far away!</span>")
		return FALSE
	if(!no_dexterity)
		to_chat(src, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	return TRUE

/mob/living/proc/can_use_guns(obj/item/G)//actually used for more than guns!
	if(G.trigger_guard != TRIGGER_GUARD_ALLOW_ALL && !IsAdvancedToolUser())
		to_chat(src, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	return TRUE

/mob/living/proc/update_stamina()
	return

/mob/living/carbon/alien/update_stamina()
	return

/mob/living/proc/owns_soul()
	if(mind)
		return mind.soulOwner == mind
	return TRUE

/mob/living/proc/return_soul()
	if(mind)
		mind.hellbound = FALSE
		var/datum/antagonist/devil/devilInfo = mind.soulOwner.has_antag_datum(/datum/antagonist/devil)
		if(devilInfo)//Not sure how this could be null, but let's just try anyway.
			devilInfo.remove_soul(mind)
		mind.soulOwner = mind

/mob/living/proc/has_bane(banetype)
	var/datum/antagonist/devil/devilInfo = is_devil(src)
	return devilInfo && banetype == devilInfo.bane

/mob/living/proc/check_weakness(obj/item/weapon, mob/living/attacker)
	if(mind && mind.has_antag_datum(/datum/antagonist/devil))
		return check_devil_bane_multiplier(weapon, attacker)
	return 1 //This is not a boolean, it's the multiplier for the damage the weapon does.

/mob/living/proc/check_acedia()
	if(mind && mind.has_objective(/datum/objective/sintouched/acedia))
		return TRUE
	return FALSE

/mob/living/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force = MOVE_FORCE_STRONG, quickstart = TRUE)
	stop_pulling()
	. = ..()

// Called when we are hit by a bolt of polymorph and changed
// Generally the mob we are currently in is about to be deleted
/mob/living/proc/wabbajack_act(mob/living/new_mob)
	new_mob.name = real_name
	new_mob.real_name = real_name

	if(mind)
		mind.transfer_to(new_mob)
	else
		new_mob.key = key

	for(var/para in hasparasites())
		var/mob/living/simple_animal/hostile/guardian/G = para
		G.summoner = new_mob
		G.Recall()
		to_chat(G, "<span class='holoparasite'>Your summoner has changed form!</span>")

/mob/living/rad_act(amount)
	. = ..()

	if(!amount || (amount < RAD_MOB_SKIN_PROTECTION) || HAS_TRAIT(src, TRAIT_RADIMMUNE))
		return

	amount -= RAD_BACKGROUND_RADIATION // This will always be at least 1 because of how skin protection is calculated

	var/blocked = getarmor(null, RAD)

	if(amount > RAD_BURN_THRESHOLD)
		apply_damage((amount-RAD_BURN_THRESHOLD)/RAD_BURN_THRESHOLD, BURN, null, blocked)

	apply_effect((amount*RAD_MOB_COEFFICIENT)/max(1, (radiation**2)*RAD_OVERDOSE_REDUCTION), EFFECT_IRRADIATE, blocked)

/mob/living/anti_magic_check(magic = TRUE, holy = FALSE, major = TRUE, self = FALSE)
	. = ..()
	if(.)
		return
	if((magic && HAS_TRAIT(src, TRAIT_ANTIMAGIC)) || (holy && HAS_TRAIT(src, TRAIT_HOLY)))
		return src

/mob/living/proc/fakefireextinguish()
	return

/mob/living/proc/fakefire()
	return



//Mobs on Fire
/mob/living/proc/IgniteMob()
	if(fire_stacks > 0 && !on_fire)
		on_fire = 1
		src.visible_message("<span class='warning'>[src] catches fire!</span>", \
						"<span class='userdanger'>You're set on fire!</span>")
		new/obj/effect/dummy/lighting_obj/moblight/fire(src)
		throw_alert("fire", /atom/movable/screen/alert/fire)
		update_fire()
		SEND_SIGNAL(src, COMSIG_LIVING_IGNITED,src)
		return TRUE
	return FALSE

/mob/living/proc/ExtinguishMob()
	if(on_fire)
		on_fire = 0
		fire_stacks = 0
		for(var/obj/effect/dummy/lighting_obj/moblight/fire/F in src)
			qdel(F)
		clear_alert("fire")
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "on_fire")
		SEND_SIGNAL(src, COMSIG_LIVING_EXTINGUISHED, src)
		update_fire()

/mob/living/proc/adjust_fire_stacks(add_fire_stacks) //Adjusting the amount of fire_stacks we have on person
	fire_stacks = CLAMP(fire_stacks + add_fire_stacks, -20, 20)
	if(on_fire && fire_stacks <= 0)
		ExtinguishMob()

//Share fire evenly between the two mobs
//Called in MobBump() and Crossed()
/mob/living/proc/spreadFire(mob/living/L)
	if(!istype(L))
		return

	if(on_fire)
		if(L.on_fire) // If they were also on fire
			var/firesplit = (fire_stacks + L.fire_stacks)/2
			fire_stacks = firesplit
			L.fire_stacks = firesplit
		else // If they were not
			fire_stacks /= 2
			L.fire_stacks += fire_stacks
			if(L.IgniteMob()) // Ignite them
				log_game("[key_name(src)] bumped into [key_name(L)] and set them on fire")

	else if(L.on_fire) // If they were on fire and we were not
		L.fire_stacks /= 2
		fire_stacks += L.fire_stacks
		IgniteMob() // Ignite us

//Mobs on Fire end

// used by secbot and monkeys Crossed
/mob/living/proc/knockOver(var/mob/living/carbon/C)
	if(C.key) //save us from monkey hordes
		C.visible_message("<span class='warning'>[pick( \
						"[C] dives out of [src]'s way!", \
						"[C] stumbles over [src]!", \
						"[C] jumps out of [src]'s path!", \
						"[C] trips over [src] and falls!", \
						"[C] topples over [src]!", \
						"[C] leaps out of [src]'s way!")]</span>")
	C.Paralyze(40)

/mob/living/can_be_pulled()
	return ..() && !(buckled && buckled.buckle_prevents_pull)

//Updates lying and icons on robots, animals and brains. Needs to be refactored to use traits and update based on events.
/mob/living/proc/update_mobility()
	return

///Called when mob changes from a standing position into a prone while lacking the ability to stand up at the moment, through update_mobility()
/mob/living/proc/on_fall()
	return

/mob/living/proc/AddAbility(obj/effect/proc_holder/A)
	abilities.Add(A)
	A.on_gain(src)
	if(A.has_action)
		A.action.Grant(src)

/mob/living/proc/RemoveAbility(obj/effect/proc_holder/A)
	abilities.Remove(A)
	A.on_lose(src)
	if(A.action)
		A.action.Remove(src)

/mob/living/proc/add_abilities_to_panel()
	for(var/obj/effect/proc_holder/A in abilities)
		statpanel("[A.panel]",A.get_panel_text(),A)

/mob/living/lingcheck()
	if(mind)
		var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			if(changeling.changeling_speak)
				return LINGHIVE_LING
			return LINGHIVE_OUTSIDER
	if(mind?.linglink)
		return LINGHIVE_LINK
	return LINGHIVE_NONE

/mob/living/forceMove(atom/destination)
	stop_pulling()
	if(buckled)
		buckled.unbuckle_mob(src, force = TRUE)
	if(has_buckled_mobs())
		unbuckle_all_mobs(force = TRUE)
	. = ..()
	if(.)
		if(client)
			reset_perspective()
		update_mobility() //if the mob was asleep inside a container and then got forceMoved out we need to make them fall.

/mob/living/proc/update_z(new_z) // 1+ to register, null to unregister
	if (registered_z != new_z)
		if (registered_z)
			SSmobs.clients_by_zlevel[registered_z] -= src
		if (client)
			if (new_z)
				SSmobs.clients_by_zlevel[new_z] += src
				for (var/I in length(SSidlenpcpool.idle_mobs_by_zlevel[new_z]) to 1 step -1) //Backwards loop because we're removing (guarantees optimal rather than worst-case performance), it's fine to use .len here but doesn't compile on 511
					var/mob/living/simple_animal/SA = SSidlenpcpool.idle_mobs_by_zlevel[new_z][I]
					if (SA)
						SA.toggle_ai(AI_ON) // Guarantees responsiveness for when appearing right next to mobs
					else
						SSidlenpcpool.idle_mobs_by_zlevel[new_z] -= SA

			registered_z = new_z
		else
			registered_z = null

/mob/living/onTransitZ(old_z,new_z)
	..()
	update_z(new_z)

/mob/living/MouseDrop_T(atom/dropping, atom/user)
	var/mob/living/U = user
	if(isliving(dropping))
		var/mob/living/M = dropping
		if(M.can_be_held && U.pulling == M)
			M.mob_try_pickup(U)//blame kevinz
			return//dont open the mobs inventory if you are picking them up
	. = ..()

/mob/living/proc/mob_pickup(mob/living/L)
	if(resting)
		resting = FALSE
		update_resting()
	var/obj/item/clothing/head/mob_holder/holder = new(get_turf(src), src, held_state, head_icon, held_lh, held_rh, worn_slot_flags)
	L.visible_message("<span class='warning'>[L] scoops up [src]!</span>")
	L.put_in_hands(holder)

/mob/living/proc/mob_try_pickup(mob/living/user)
	if(!ishuman(user))
		return
	if(user.get_active_held_item())
		to_chat(user, "<span class='warning'>Your hands are full!</span>")
		return FALSE
	if(buckled)
		to_chat(user, "<span class='warning'>[src] is buckled to something!</span>")
		return FALSE
	user.visible_message("<span class='notice'>[user] starts trying to scoop up [src]!</span>")
	if(!do_after(user, 20, target = src))
		return FALSE
	mob_pickup(user)
	return TRUE

/mob/living/proc/get_static_viruses() //used when creating blood and other infective objects
	if(!LAZYLEN(diseases))
		return
	var/list/datum/disease/result = list()
	for(var/datum/disease/D in diseases)
		var/static_virus = D.Copy()
		result += static_virus
	return result

/mob/living/reset_perspective(atom/A)
	if(..())
		update_sight()
		if(client.eye && client.eye != src)
			var/atom/AT = client.eye
			AT.get_remote_view_fullscreens(src)
		else
			clear_fullscreen("remote_view", 0)
		update_pipe_vision()

/mob/living/update_mouse_pointer()
	..()
	if (client && ranged_ability && ranged_ability.ranged_mousepointer)
		client.mouse_pointer_icon = ranged_ability.ranged_mousepointer

/mob/living/vv_edit_var(var_name, var_value)
	switch(var_name)
		if (NAMEOF(src, maxHealth))
			if (!isnum_safe(var_value) || var_value <= 0)
				return FALSE
		if(NAMEOF(src, stat))
			if((stat == DEAD) && (var_value < DEAD))//Bringing the dead back to life
				remove_from_dead_mob_list()
				add_to_alive_mob_list()
			if((stat < DEAD) && (var_value == DEAD))//Kill he
				remove_from_alive_mob_list()
				add_to_dead_mob_list()
		if(NAMEOF(src, health)) //this doesn't work. gotta use procs instead.
			return FALSE
	. = ..()
	switch(var_name)
		if(NAMEOF(src, eye_blind))
			set_blindness(var_value)
		if(NAMEOF(src, eye_blurry))
			set_blurriness(var_value)
		if(NAMEOF(src, maxHealth))
			updatehealth()
		if(NAMEOF(src, resize))
			update_transform()
		if(NAMEOF(src, lighting_alpha))
			sync_lighting_plane_alpha()

/mob/living/vv_get_header()
	. = ..()
	var/refid = REF(src)
	. += {"
		<br><font size='1'>[VV_HREF_TARGETREF(refid, VV_HK_GIVE_DIRECT_CONTROL, "[ckey || "no ckey"]")] / [VV_HREF_TARGETREF_1V(refid, VV_HK_BASIC_EDIT, "[real_name || "no real name"]", NAMEOF(src, real_name))]</font>
		<br><font size='1'>
			BRUTE:<font size='1'><a href='?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=brute' id='brute'>[getBruteLoss()]</a>
			FIRE:<font size='1'><a href='?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=fire' id='fire'>[getFireLoss()]</a>
			TOXIN:<font size='1'><a href='?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=toxin' id='toxin'>[getToxLoss()]</a>
			OXY:<font size='1'><a href='?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=oxygen' id='oxygen'>[getOxyLoss()]</a>
			CLONE:<font size='1'><a href='?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=clone' id='clone'>[getCloneLoss()]</a>
			BRAIN:<font size='1'><a href='?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=brain' id='brain'>[getOrganLoss(ORGAN_SLOT_BRAIN)]</a>
			STAMINA:<font size='1'><a href='?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=stamina' id='stamina'>[getStaminaLoss()]</a>
		</font>
	"}

/mob/living/eminence_act(mob/living/simple_animal/eminence/eminence)
	if(is_servant_of_ratvar(src) && !iseminence(src))
		eminence.selected_mob = src
		to_chat(eminence, "<span class='brass'>You select [src].</span>")

/mob/living/proc/set_gender(ngender = NEUTER, silent = FALSE, update_icon = TRUE, forced = FALSE)
	if(forced)
		gender = ngender
		return TRUE
	return FALSE

/mob/living/set_stat(new_stat)
	. = ..()
	if(isnull(.))
		return
	switch(.) //Previous stat.
		if(CONSCIOUS)
			if(stat >= UNCONSCIOUS)
				ADD_TRAIT(src, TRAIT_INCAPACITATED, TRAIT_KNOCKEDOUT)
				ADD_TRAIT(src, TRAIT_IMMOBILIZED, TRAIT_KNOCKEDOUT)
				ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, TRAIT_KNOCKEDOUT)
			ADD_TRAIT(src, TRAIT_FLOORED, UNCONSCIOUS_TRAIT)
		if(SOFT_CRIT)
			if(stat >= UNCONSCIOUS)
				ADD_TRAIT(src, TRAIT_IMMOBILIZED, TRAIT_KNOCKEDOUT) //adding trait sources should come before removing to avoid unnecessary updates
				ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, TRAIT_KNOCKEDOUT)
			if(pulledby)
				REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, PULLED_WHILE_SOFTCRIT_TRAIT)
		if(UNCONSCIOUS)
			if(stat != HARD_CRIT)
				adjust_blindness(-1)
		if(HARD_CRIT)
			if(stat != UNCONSCIOUS)
				adjust_blindness(-1)
	switch(stat) //Current stat.
		if(CONSCIOUS)
			if(. >= UNCONSCIOUS)
				REMOVE_TRAIT(src, TRAIT_INCAPACITATED, TRAIT_KNOCKEDOUT)
				REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, TRAIT_KNOCKEDOUT)
				REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, TRAIT_KNOCKEDOUT)
			REMOVE_TRAIT(src, TRAIT_FLOORED, UNCONSCIOUS_TRAIT)
			REMOVE_TRAIT(src, TRAIT_CRITICAL_CONDITION, STAT_TRAIT)
		if(SOFT_CRIT)
			if(pulledby)
				ADD_TRAIT(src, TRAIT_IMMOBILIZED, PULLED_WHILE_SOFTCRIT_TRAIT) //adding trait sources should come before removing to avoid unnecessary updates
			if(. >= UNCONSCIOUS)
				REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, TRAIT_KNOCKEDOUT)
				REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, TRAIT_KNOCKEDOUT)
			ADD_TRAIT(src, TRAIT_CRITICAL_CONDITION, STAT_TRAIT)
		if(UNCONSCIOUS)
			if(. != HARD_CRIT)
				become_blind(UNCONSCIOUS_TRAIT)
			if(health <= crit_threshold && !HAS_TRAIT(src, TRAIT_NOSOFTCRIT))
				ADD_TRAIT(src, TRAIT_CRITICAL_CONDITION, STAT_TRAIT)
			else
				REMOVE_TRAIT(src, TRAIT_CRITICAL_CONDITION, STAT_TRAIT)
		if(HARD_CRIT)
			if(. != UNCONSCIOUS)
				become_blind(UNCONSCIOUS_TRAIT)
			ADD_TRAIT(src, TRAIT_CRITICAL_CONDITION, STAT_TRAIT)
		if(DEAD)
			REMOVE_TRAIT(src, TRAIT_CRITICAL_CONDITION, STAT_TRAIT)

///Reports the event of the change in value of the buckled variable.
/mob/living/proc/set_buckled(new_buckled)
	if(new_buckled == buckled)
		return
	SEND_SIGNAL(src, COMSIG_LIVING_SET_BUCKLED, new_buckled)
	. = buckled
	buckled = new_buckled
	if(buckled)
		if(!.)
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, BUCKLED_TRAIT)
			switch(buckled.buckle_lying)
				if(NO_BUCKLE_LYING) // The buckle doesn't force a lying angle.
					REMOVE_TRAIT(src, TRAIT_FLOORED, BUCKLED_TRAIT)
					return
				if(0) // Forcing to a standing position.
					REMOVE_TRAIT(src, TRAIT_FLOORED, BUCKLED_TRAIT)
				else // Forcing to a lying position.
					ADD_TRAIT(src, TRAIT_FLOORED, BUCKLED_TRAIT)
			set_lying_angle(buckled.buckle_lying)
	else if(.) // We unbuckled from something.
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, BUCKLED_TRAIT)
		REMOVE_TRAIT(src, TRAIT_FLOORED, BUCKLED_TRAIT)
		var/atom/movable/old_buckled = .
		if(old_buckled.buckle_lying == 0 && resting) // The buckle forced us to stay up (like a chair) and our preference is set to resting...
			set_lying_down() // ...so let's drop on the ground.


/mob/living/set_pulledby(new_pulledby)
	. = ..()
	if(. == FALSE) //null is a valid value here, we only want to return if FALSE is explicitly passed.
		return
	if(pulledby)
		if(!. && stat == SOFT_CRIT)
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, PULLED_WHILE_SOFTCRIT_TRAIT)
	else if(. && stat == SOFT_CRIT)
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, PULLED_WHILE_SOFTCRIT_TRAIT)

///Proc to modify the value of num_legs and hook behavior associated to this event.
/mob/living/proc/set_num_legs(new_value)
	if(num_legs == new_value)
		return
	. = num_legs
	num_legs = new_value


///Proc to modify the value of usable_legs and hook behavior associated to this event.
/mob/living/proc/set_usable_legs(new_value)
	if(usable_legs == new_value)
		return
	. = usable_legs
	usable_legs = new_value

	if(new_value > .) // Gained leg usage.
		REMOVE_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	else if(!(movement_type & (FLYING | FLOATING))) //Lost leg usage, not flying.
		if(!usable_legs)
			ADD_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
			if(!usable_hands)
				ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)

	if(usable_legs < default_num_legs)
		var/limbless_slowdown = (default_num_legs - usable_legs) * 3
		if(!usable_legs && usable_hands < default_num_hands)
			limbless_slowdown += (default_num_hands - usable_hands) * 3
		add_movespeed_modifier(MOVESPEED_ID_LIVING_LIMBLESS, update=TRUE, priority=100, override=TRUE, multiplicative_slowdown=limbless_slowdown, movetypes=GROUND)
	else
		remove_movespeed_modifier(MOVESPEED_ID_LIVING_LIMBLESS, update=TRUE)

///Proc to modify the value of num_hands and hook behavior associated to this event.
/mob/living/proc/set_num_hands(new_value)
	if(num_hands == new_value)
		return
	. = num_hands
	num_hands = new_value


///Proc to modify the value of usable_hands and hook behavior associated to this event.
/mob/living/proc/set_usable_hands(new_value)
	if(usable_hands == new_value)
		return
	. = usable_hands
	usable_hands = new_value

	if(new_value > .) // Gained hand usage.
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	else if(!(movement_type & (FLYING | FLOATING)) && !usable_hands && !usable_legs) //Lost a hand, not flying, no hands left, no legs.
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)

/// Updates the grab state of the mob and updates movespeed
/mob/living/setGrabState(newstate)
	. = ..()
	switch(grab_state)
		if(GRAB_PASSIVE)
			remove_movespeed_modifier(MOVESPEED_ID_MOB_GRAB_STATE)
		if(GRAB_AGGRESSIVE)
			add_movespeed_modifier(MOVESPEED_ID_MOB_GRAB_STATE, TRUE, 100, override=TRUE, multiplicative_slowdown = 3, blacklisted_movetypes=FLOATING)
		if(GRAB_NECK)
			add_movespeed_modifier(MOVESPEED_ID_MOB_GRAB_STATE, TRUE, 100, override=TRUE, multiplicative_slowdown = 6, blacklisted_movetypes=FLOATING)
		if(GRAB_KILL)
			add_movespeed_modifier(MOVESPEED_ID_MOB_GRAB_STATE, TRUE, 100, override=TRUE, multiplicative_slowdown = 9, blacklisted_movetypes=FLOATING)

/**
  * Changes the inclination angle of a mob, used by humans and others to differentiate between standing up and prone positions.
  *
  * In BYOND-angles 0 is NORTH, 90 is EAST, 180 is SOUTH and 270 is WEST.
  * This usually means that 0 is standing up, 90 and 270 are horizontal positions to right and left respectively, and 180 is upside-down.
  * Mobs that do now follow these conventions due to unusual sprites should require a special handling or redefinition of this proc, due to the density and layer changes.
  * The return of this proc is the previous value of the modified lying_angle if a change was successful (might include zero), or null if no change was made.
  */
/mob/living/proc/set_lying_angle(new_lying)
	if(new_lying == lying_angle)
		return
	. = lying_angle
	lying_angle = new_lying
	if(lying_angle != lying_prev)
		update_transform()
		lying_prev = lying_angle
	if(lying_angle != 0) //We are not standing up.
		if(layer == initial(layer)) //to avoid things like hiding larvas.
			layer = LYING_MOB_LAYER //so mob lying always appear behind standing mobs
		if(. == 0) // We became prone and were not before.
			ADD_TRAIT(src, TRAIT_UI_BLOCKED, LYING_DOWN_TRAIT)
			ADD_TRAIT(src, TRAIT_PULL_BLOCKED, LYING_DOWN_TRAIT)
			density = FALSE // We lose density and stop bumping passable dense things.
			if(HAS_TRAIT(src, TRAIT_FLOORED) && !(dir & (NORTH|SOUTH)))
				setDir(pick(NORTH, SOUTH)) // We are and look helpless.
	else //We are prone.
		if(layer == LYING_MOB_LAYER)
			layer = initial(layer)
		if(.) //We weren't pone before, so we become dense and things can bump into us again.
			density = initial(density)
			REMOVE_TRAIT(src, TRAIT_UI_BLOCKED, LYING_DOWN_TRAIT)
			REMOVE_TRAIT(src, TRAIT_PULL_BLOCKED, LYING_DOWN_TRAIT)

#define LOOKING_DIRECTION_UP 1
#define LOOKING_DIRECTION_NONE 0
#define LOOKING_DIRECTION_DOWN -1

/// The current direction the player is ACTUALLY looking, regardless of intent.
/mob/living/var/looking_direction = LOOKING_DIRECTION_NONE
/// The current direction the player is trying to look.
/mob/living/var/attempt_looking_direction = LOOKING_DIRECTION_NONE

///Checks if the user is incapacitated and cannot look up/down
/mob/living/proc/can_look_direction()
	return !(incapacitated(ignore_restraints = TRUE))

/// Tell the mob to attempt to look this direction until it's set back to NONE
/mob/living/proc/set_attempted_looking_direction(direction)
	if(attempt_looking_direction == direction && direction != LOOKING_DIRECTION_NONE) // we are already trying to look this way, reset
		set_attempted_looking_direction(LOOKING_DIRECTION_NONE)
		return
	attempt_looking_direction = direction
	set_look_direction(attempt_looking_direction)

/// Actually sets the looking direction, but it won't try to stay that way if we move out of range
/mob/living/proc/set_look_direction(direction, automatic = FALSE)
	// Handle none/failure
	if(direction == LOOKING_DIRECTION_NONE || !can_look_direction(direction))
		looking_direction = LOOKING_DIRECTION_NONE
		reset_perspective()
		return
	// Automatic attempts should not trigger the cooldown
	if(!automatic)
		changeNext_move(CLICK_CD_LOOK_DIRECTION)
	looking_direction = direction
	var/look_str = direction == LOOKING_DIRECTION_UP ? "up" : "down"
	if(update_looking_move(automatic))
		visible_message("<span class='notice'>[src] looks [look_str].</span>", "<span class='notice'>You look [look_str].</span>")

/// Called by /mob/living/Move()
/mob/living/proc/update_looking_move(automatic = FALSE)
	// Try looking the attempted direction now that we've moved
	if(attempt_looking_direction != LOOKING_DIRECTION_NONE && looking_direction == LOOKING_DIRECTION_NONE)
		set_look_direction(attempt_looking_direction, automatic = TRUE) // this won't loop recursively because looking_direction cannot be NONE above
	// We can't try looking nowhere!
	if(looking_direction == LOOKING_DIRECTION_NONE)
		return FALSE
	// Something changed, stop looking
	if(!can_look_direction(looking_direction))
		set_look_direction(LOOKING_DIRECTION_NONE)
	// Update perspective
	var/turf/base = find_visible_hole_in_direction(looking_direction)
	if(!isturf(base))
		if(!automatic)
			to_chat(src, "<span class='warning'>You can't see through the [looking_direction == LOOKING_DIRECTION_UP ? "ceiling above" : "floor below"] you.</span>")
		set_look_direction(LOOKING_DIRECTION_NONE)
		return FALSE
	reset_perspective(base)
	return TRUE

/mob/living/verb/look_up_short()
	set name = "Look Up"
	set category = "IC"
	// you pressed the verb while holding a keybind, unlock!
	attempt_looking_direction = LOOKING_DIRECTION_NONE
	if(looking_direction == LOOKING_DIRECTION_UP)
		set_look_direction(LOOKING_DIRECTION_NONE)
		return
	look_up()

/**
 * look_up Changes the perspective of the mob to any openspace turf above the mob
 * lock: If it should continue to try looking even if there is no seethrough turf
 */
/mob/living/proc/look_up(lock = FALSE)
	if(lock)
		set_attempted_looking_direction(LOOKING_DIRECTION_UP)
	else
		set_look_direction(LOOKING_DIRECTION_UP)

/mob/living/verb/look_down_short()
	set name = "Look Down"
	set category = "IC"
	// you pressed the verb while holding a keybind, unlock!
	attempt_looking_direction = LOOKING_DIRECTION_NONE
	if(looking_direction == LOOKING_DIRECTION_DOWN)
		set_look_direction(LOOKING_DIRECTION_NONE)
		return
	look_down()

/**
 * look_down Changes the perspective of the mob to any openspace turf below the mob
 * lock: If it should continue to try looking even if there is no seethrough turf
 */
/mob/living/proc/look_down(lock = FALSE)
	if(lock)
		set_attempted_looking_direction(LOOKING_DIRECTION_DOWN)
	else
		set_look_direction(LOOKING_DIRECTION_DOWN)

/// Helper, resets from looking up or down, and unlocks the view.
/mob/living/proc/look_reset()
	set_attempted_looking_direction(LOOKING_DIRECTION_NONE)

/mob/living/proc/find_visible_hole_in_direction(direction)
	// Our current z-level turf
	var/turf/turf_base = get_turf(src)
	// The target z-level turf
	var/turf/turf_other = get_step_multiz(turf_base, direction == LOOKING_DIRECTION_UP ? UP : DOWN)
	if(!turf_other) // There is nothing above/below
		return FALSE
	// This turf is the one we are looking through
	var/turf/seethrough_turf = direction == LOOKING_DIRECTION_UP ? turf_other : turf_base
	// The turf we should end up looking at.
	var/turf/end_turf = turf_other
	if(istransparentturf(seethrough_turf)) //There is no turf we can look through directly above/below us, look for nearby turfs
		return end_turf
	// Turf in front of you to try to look through before anything else
	var/turf/seethrough_turf_front = get_step(seethrough_turf, dir)
	if(istransparentturf(seethrough_turf_front))
		return direction == LOOKING_DIRECTION_UP ? seethrough_turf_front : get_step_multiz(seethrough_turf_front, DOWN)
	var/target_z = direction == LOOKING_DIRECTION_UP ? turf_other.z : z
	var/list/checkturfs = block(locate(x-1,y-1,target_z),locate(x+1,y+1,target_z))-turf_base-turf_other
	for(var/turf/checkhole in checkturfs)
		if(istransparentturf(checkhole))
			seethrough_turf = checkhole
			end_turf = direction == LOOKING_DIRECTION_UP ? checkhole : get_step_multiz(checkhole, DOWN)
			break
	if(!istransparentturf(seethrough_turf))
		return FALSE
	return end_turf

#undef LOOKING_DIRECTION_UP
#undef LOOKING_DIRECTION_NONE
#undef LOOKING_DIRECTION_DOWN
