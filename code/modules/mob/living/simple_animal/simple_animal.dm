/mob/living/simple_animal
	name = "animal"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20
	gender = PLURAL //placeholder
	living_flags = MOVES_ON_ITS_OWN
	status_flags = CANPUSH

	var/icon_living = ""
	var/icon_dead = "" //icon when the animal is dead. Don't use animated icons for this.
	var/icon_gib = null	//We only try to show a gibbing animation if this exists.
	var/flip_on_death = FALSE //Flip the sprite upside down on death. Mostly here for things lacking custom dead sprites.

	var/list/speak = list()
	var/list/speak_emote = list()//	Emotes while speaking IE: Ian [emote], [text] -- Ian barks, "WOOF!". Spoken text is generated from the speak variable.
	var/speak_language = /datum/language/common // set this to a desired language path when list/speak should be spoken in a specific language. Dog barking / cat meowing / rat squeak would need to be metalanguage.
	var/speak_chance = 0
	var/list/emote_hear = list()	//Hearable emotes
	var/list/emote_see = list()		//Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps

	var/turns_per_move = 1
	var/turns_since_move = 0
	var/stop_automated_movement = 0 //Use this to temporarely stop random movement or to if you write special movement code for animals.
	var/wander = TRUE	// Does the mob wander around when idle?
	/// Makes Goto() return FALSE and not start a move loop
	var/prevent_goto_movement = FALSE
	var/stop_automated_movement_when_pulled = 1 //When set to 1 this stops the animal from moving when someone is pulling it.

	///When someone interacts with the simple animal.
	///Help-intent verb in present continuous tense.
	var/response_help_continuous = "pokes"
	///Help-intent verb in present simple tense.
	var/response_help_simple = "poke"
	///Disarm-intent verb in present continuous tense.
	var/response_disarm_continuous = "shoves"
	///Disarm-intent verb in present simple tense.
	var/response_disarm_simple = "shove"
	///Harm-intent verb in present continuous tense.
	var/response_harm_continuous = "hits"
	///Harm-intent verb in present simple tense.
	var/response_harm_simple = "hit"
	var/force_threshold = 0 //Minimum force required to deal any damage
	///Maximum amount of stamina damage the mob can be inflicted with total
	var/max_staminaloss = 200
	///How much stamina the mob recovers per second
	var/stamina_recovery = 5

	//Temperature effect
	var/minbodytemp = 250
	var/maxbodytemp = 350

	//Healable by medical stacks? Defaults to yes.
	var/healable = 1

	/// List of weather immunity traits that are then added on Initialize(), see traits.dm.
	var/list/weather_immunities

	//Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	var/list/atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0) //Leaving something at 0 means it's off - has no maximum
	///This damage is taken when atmos doesn't fit all the requirements above.
	var/unsuitable_atmos_damage = 1

	///how much damage this simple animal does to objects, if any.
	var/obj_damage = 0
	///How much armour they ignore, as a flat reduction from the targets armour value.
	var/armour_penetration = 0
	///Damage type of a simple mob's melee attack, should it do damage.
	var/melee_damage_type = BRUTE
	/// 1 for full damage , 0 for none , -1 for 1:1 heal from that source.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	///Attacking verb in present continuous tense.
	var/attack_verb_continuous = "attacks"
	///Attacking verb in present simple tense.
	var/attack_verb_simple = "attack"
	var/attack_sound = null
	///Attacking, but without damage, verb in present continuous tense.
	var/friendly_verb_continuous = "nuzzles"
	///Attacking, but without damage, verb in present simple tense.
	var/friendly_verb_simple = "nuzzle"
	///Set to 1 to allow breaking of crates,lockers,racks,tables; 2 for walls; 3 for Rwalls.
	var/environment_smash = ENVIRONMENT_SMASH_NONE
	///If true, simplemob gets an extreme bonus against blocking players
	var/hardattacks = FALSE

	var/speed = 1 //LETS SEE IF I CAN SET SPEEDS FOR SIMPLE MOBS WITHOUT DESTROYING EVERYTHING. Higher speed is slower, negative speed is faster

	//Hot simple_animal baby making vars
	var/list/childtype = null
	var/next_scan_time = 0
	var/animal_species //Sorry, no spider+corgi buttbabies.

	//simple_animal access
	var/obj/item/card/id/access_card = null	//innate access uses an internal ID card
	var/buffed = 0 //In the event that you want to have a buffing effect on the mob, but don't want it to stack with other effects, any outside force that applies a buff to a simple mob should at least set this to 1, so we have something to check against
	var/gold_core_spawnable = NO_SPAWN //If the mob can be spawned with a gold slime core. HOSTILE_SPAWN are spawned with plasma, FRIENDLY_SPAWN are spawned with blood

	var/datum/component/spawner/nest

	var/sentience_type = SENTIENCE_ORGANIC // Sentience type, for slime potions

	var/list/loot = list() //list of things spawned at mob's loc when it dies
	var/del_on_death = FALSE //causes mob to be deleted on death, useful for mobs that spawn lootable corpses

	var/allow_movement_on_non_turfs = FALSE

	var/attacked_sound = "punch" //Played when someone punches the creature

	var/dextrous = FALSE //If the creature has, and can use, hands
	var/dextrous_hud_type = /datum/hud/dextrous

	///If the creature should have an innate TRAIT_MOVE_FLYING trait added on init that is also toggled off/on on death/revival.
	var/is_flying_animal = FALSE
	//If the creature should play its bobbing up and down animation.
	var/no_flying_animation

	///The Status of our AI, can be set to AI_ON (On, usual processing), AI_IDLE (Will not process, but will return to AI_ON if an enemy comes near), AI_OFF (Off, Not processing ever), AI_Z_OFF (Temporarily off due to nonpresence of players).
	var/AIStatus = AI_ON
	///once we have become sentient, we can never go back.
	var/can_have_ai = TRUE

	///convenience var for forcibly waking up an idling AI on next check.
	var/shouldwakeup = FALSE

	var/my_z // I don't want to confuse this with client registered_z

	///What kind of footstep this mob should have. Null if it shouldn't have any.
	var/footstep_type

	///Generic flags
	var/simple_mob_flags = NONE

	///Is this animal horrible at hunting?
	var/inept_hunter = FALSE

	///Limits how often mobs can hunt other mobs
	COOLDOWN_DECLARE(emote_cooldown)
	var/turns_since_scan = 0

	var/special_process = FALSE

	///set it TRUE if "health" is not relable to this simple mob.
	var/do_not_show_health_on_stat_panel

	//Discovery
	var/discovery_points = 200

/mob/living/simple_animal/Initialize(mapload)
	. = ..()
	GLOB.simple_animals[AIStatus] += src
	if(gender == PLURAL)
		gender = pick(MALE,FEMALE)
	if(!real_name)
		real_name = name
	if(!loc)
		stack_trace("Simple animal being instantiated in nullspace")
	update_simplemob_varspeed()
	ADD_TRAIT(src, TRAIT_NOFIRE_SPREAD, ROUNDSTART_TRAIT)
	if(length(weather_immunities))
		add_traits(weather_immunities, ROUNDSTART_TRAIT)
	if(footstep_type)
		AddElement(/datum/element/footstep, footstep_type)
	if(no_flying_animation)
		ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, ROUNDSTART_TRAIT)
	if(dextrous)
		AddComponent(/datum/component/personal_crafting)
		add_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_CAN_STRIP), ROUNDSTART_TRAIT)
	if(is_flying_animal)
		ADD_TRAIT(src, TRAIT_MOVE_FLYING, ROUNDSTART_TRAIT)
	if(discovery_points)
		AddComponent(/datum/component/discoverable, discovery_points, get_discover_id = CALLBACK(src, PROC_REF(get_discovery_id)))

/*
/mob/living/simple_animal/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(staminaloss > 0)
		adjustStaminaLoss(-stamina_recovery * delta_time, FALSE, TRUE)
*/

/mob/living/simple_animal/Destroy()
	GLOB.simple_animals[AIStatus] -= src
	SSnpcpool.currentrun -= src

	var/turf/T = get_turf(src)
	if (T && AIStatus == AI_Z_OFF)
		SSidlenpcpool.idle_mobs_by_zlevel[T.z] -= src

	if(nest)
		nest.spawned_mobs -= src
		nest = null

	return ..()

/mob/living/simple_animal/vv_edit_var(var_name, var_value)
	. = ..()
	switch(var_name)
		if(NAMEOF(src, is_flying_animal))
			if(stat != DEAD)
				if(!is_flying_animal)
					REMOVE_TRAIT(src, TRAIT_MOVE_FLYING, ROUNDSTART_TRAIT)
				else
					ADD_TRAIT(src, TRAIT_MOVE_FLYING, ROUNDSTART_TRAIT)
		if(NAMEOF(src, no_flying_animation))
			if(!no_flying_animation)
				REMOVE_TRAIT(src, TRAIT_NO_FLOATING_ANIM, ROUNDSTART_TRAIT)
			else
				ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, ROUNDSTART_TRAIT)

/mob/living/simple_animal/examine(mob/user)
	. = ..()
	if(stat == DEAD)
		. += span_deadsay("Upon closer examination, [p_they()] appear[p_s()] to be dead.")

/mob/living/simple_animal/updatehealth()
	. = ..()
	health = clamp(health, 0, maxHealth)

/mob/living/simple_animal/update_stat()
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	if(stat != DEAD)
		if(health <= 0)
			death()
		else
			set_stat(CONSCIOUS)
	med_hud_set_status()

/mob/living/simple_animal/proc/handle_automated_action()
	set waitfor = FALSE
	return

/mob/living/simple_animal/proc/handle_automated_movement()
	set waitfor = FALSE
	if(stop_automated_movement || !wander)
		return
	if(!isturf(loc) && !allow_movement_on_non_turfs)
		return
	if(!(mobility_flags & MOBILITY_MOVE)) //This is so it only moves if it's not inside a closet, gentics machine, etc.
		return TRUE

	turns_since_move++
	if(turns_since_move < turns_per_move)
		return TRUE
	if(stop_automated_movement_when_pulled && pulledby) //Some animals don't move when pulled
		return TRUE
	var/anydir = pick(GLOB.cardinals)
	if(Process_Spacemove(anydir))
		Move(get_step(src, anydir), anydir)
		turns_since_move = 0
	return TRUE

/mob/living/simple_animal/proc/handle_automated_speech(override)
	set waitfor = FALSE
	if(!speak_chance || (!prob(speak_chance) && !override))
		return

	if(length(speak))
		if(length(emote_hear) || length(emote_see))
			var/length = length(speak)
			if(length(emote_hear))
				length += length(emote_hear)
			if(length(emote_see))
				length += length(emote_see)
			var/randomValue = rand(1, length)
			if(randomValue <= length(speak))
				say(pick(speak), language = speak_language, forced = "automated speech")
			else
				randomValue -= length(speak)
				if(emote_see && randomValue <= length(emote_see))
					manual_emote(pick(emote_see))
				else
					manual_emote(pick(emote_hear))
		else
			say(pick(speak), language = speak_language, forced = "automated speech")
	else
		if(!length(emote_hear) && length(emote_see))
			manual_emote(pick(emote_see))
		if(length(emote_hear) && !length(emote_see))
			manual_emote(pick(emote_hear))
		if(length(emote_hear) && length(emote_see))
			var/length = length(emote_hear) + length(emote_see)
			var/pick = rand(1,length)
			if(pick <= length(emote_see))
				manual_emote(pick(emote_see))
			else
				manual_emote(pick(emote_hear))

/mob/living/simple_animal/proc/environment_air_is_safe()
	. = TRUE

	if(pulledby && pulledby.grab_state >= GRAB_KILL && atmos_requirements["min_oxy"])
		. = FALSE //getting choked

	if(isturf(loc) && isopenturf(loc))
		var/turf/open/ST = loc
		if(ST.air)
			var/tox = GET_MOLES(/datum/gas/plasma, ST.air)
			var/oxy = GET_MOLES(/datum/gas/oxygen, ST.air)
			var/n2  = GET_MOLES(/datum/gas/nitrogen, ST.air)
			var/co2 = GET_MOLES(/datum/gas/carbon_dioxide, ST.air)

			if(atmos_requirements["min_oxy"] && oxy < atmos_requirements["min_oxy"])
				. = FALSE
			else if(atmos_requirements["max_oxy"] && oxy > atmos_requirements["max_oxy"])
				. = FALSE
			else if(atmos_requirements["min_tox"] && tox < atmos_requirements["min_tox"])
				. = FALSE
			else if(atmos_requirements["max_tox"] && tox > atmos_requirements["max_tox"])
				. = FALSE
			else if(atmos_requirements["min_n2"] && n2 < atmos_requirements["min_n2"])
				. = FALSE
			else if(atmos_requirements["max_n2"] && n2 > atmos_requirements["max_n2"])
				. = FALSE
			else if(atmos_requirements["min_co2"] && co2 < atmos_requirements["min_co2"])
				. = FALSE
			else if(atmos_requirements["max_co2"] && co2 > atmos_requirements["max_co2"])
				. = FALSE
		else
			if(atmos_requirements["min_oxy"] || atmos_requirements["min_tox"] || atmos_requirements["min_n2"] || atmos_requirements["min_co2"])
				. = FALSE

/mob/living/simple_animal/proc/environment_temperature_is_safe(datum/gas_mixture/environment)
	. = TRUE
	var/areatemp = get_temperature(environment)
	if((areatemp < minbodytemp) || (areatemp > maxbodytemp))
		. = FALSE

/mob/living/simple_animal/handle_environment(datum/gas_mixture/environment, delta_time, times_fired)
	var/atom/A = loc
	if(isturf(A))
		var/areatemp = get_temperature(environment)
		var/temp_delta = areatemp - bodytemperature
		if(abs(temp_delta) > 5)
			if(temp_delta < 0)
				if(!on_fire)
					adjust_bodytemperature(clamp(temp_delta * delta_time / 10, temp_delta, 0))
			else
				adjust_bodytemperature(clamp(temp_delta * delta_time / 10, 0, temp_delta))

	if(!environment_air_is_safe() && unsuitable_atmos_damage)
		adjustHealth(unsuitable_atmos_damage * delta_time)
		if(unsuitable_atmos_damage > 0)
			throw_alert("not_enough_oxy", /atom/movable/screen/alert/not_enough_oxy)
	else
		clear_alert("not_enough_oxy")

	handle_temperature_damage(delta_time, times_fired)

/mob/living/simple_animal/proc/handle_temperature_damage(delta_time, times_fired)
	. = FALSE
	if((bodytemperature < minbodytemp) && unsuitable_atmos_damage)
		adjustHealth(unsuitable_atmos_damage * delta_time)
		switch(unsuitable_atmos_damage)
			if(1 to 5)
				throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 1)
			if(5 to 10)
				throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 2)
			if(10 to INFINITY)
				throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, 3)
		. = TRUE

	if((bodytemperature > maxbodytemp) && unsuitable_atmos_damage)
		adjustHealth(unsuitable_atmos_damage * delta_time)
		switch(unsuitable_atmos_damage)
			if(1 to 5)
				throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 1)
			if(5 to 10)
				throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 2)
			if(10 to INFINITY)
				throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, 3)
		. = TRUE

	if(!.)
		clear_alert(ALERT_TEMPERATURE)

/mob/living/simple_animal/gib()
	if(butcher_results || guaranteed_butcher_results)
		var/list/butcher = list()
		if(butcher_results)
			butcher += butcher_results
		if(guaranteed_butcher_results)
			butcher += guaranteed_butcher_results
		var/atom/Tsec = drop_location()
		for(var/path in butcher)
			for(var/i in 1 to butcher[path])
				new path(Tsec)
	..()

/mob/living/simple_animal/gib_animation()
	if(icon_gib)
		new /obj/effect/temp_visual/gib_animation/animal(loc, icon_gib)

/mob/living/simple_animal/say_mod(input, list/message_mods = list())
	if(speak_emote && speak_emote.len)
		verb_say = pick(speak_emote)
	. = ..()

/mob/living/simple_animal/proc/set_varspeed(var_value)
	speed = var_value
	update_simplemob_varspeed()

/mob/living/simple_animal/proc/update_simplemob_varspeed()
	if(speed == 0)
		remove_movespeed_modifier(/datum/movespeed_modifier/simplemob_varspeed)
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/simplemob_varspeed, multiplicative_slowdown = speed)

/mob/living/simple_animal/get_stat_tab_status()
	if(do_not_show_health_on_stat_panel)
		return ..()

	var/list/tab_data = ..()
	tab_data["Health"] = GENERATE_STAT_TEXT("[round((health / maxHealth) * 100)]%")
	return tab_data

/mob/living/simple_animal/proc/drop_loot()
	if(flags_1 & HOLOGRAM_1)
		do_sparks(3, TRUE, src)
		return
	if(length(loot))
		for(var/i in loot)
			new i(loc)

/mob/living/simple_animal/death(gibbed)
	if(nest)
		nest.spawned_mobs -= src
		nest = null
	drop_loot()
	if(dextrous)
		drop_all_held_items()
	if(del_on_death)
		..()
		//Prevent infinite loops if the mob Destroy() is overridden in such
		//a manner as to cause a call to death() again
		del_on_death = FALSE
		qdel(src)
	else
		if(is_flying_animal)
			REMOVE_TRAIT(src, TRAIT_MOVE_FLYING, ROUNDSTART_TRAIT)
		if(no_flying_animation)
			REMOVE_TRAIT(src, TRAIT_NO_FLOATING_ANIM, ROUNDSTART_TRAIT)
		health = 0
		icon_state = icon_dead
		if(flip_on_death)
			transform = transform.Turn(180)
		set_density(FALSE)
		..()

/mob/living/simple_animal/proc/CanAttack(atom/the_target)
	if(see_invisible < the_target.invisibility)
		return FALSE
	if(ismob(the_target))
		var/mob/M = the_target
		if(HAS_TRAIT(M, TRAIT_GODMODE))
			return FALSE
	if (isliving(the_target))
		var/mob/living/L = the_target
		if(L.stat != CONSCIOUS)
			return FALSE
	if (ismecha(the_target))
		var/obj/vehicle/sealed/mecha/M = the_target
		if(LAZYLEN(M.occupants))
			return FALSE
	return TRUE

/mob/living/simple_animal/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(!.)
		return
	icon = initial(icon)
	icon_state = icon_living
	density = initial(density)
	if(is_flying_animal)
		ADD_TRAIT(src, TRAIT_MOVE_FLYING, ROUNDSTART_TRAIT)
	if(no_flying_animation)
		ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, ROUNDSTART_TRAIT)

/mob/living/simple_animal/proc/make_babies() // <3 <3 <3
	set waitfor = 0
	if(gender != FEMALE || stat || next_scan_time > world.time || !childtype || !animal_species || !SSticker.IsRoundInProgress())
		return
	next_scan_time = world.time + (5 MINUTES)
	var/mob/living/simple_animal/partner
	var/children = 0
	for(var/mob/living/M in ohearers(7, src))
		if(M.stat) //Check if it's conscious FIRST.
			continue
		else if(is_type_in_list(M, childtype)) //Check for children SECOND.
			children++
		else if(istype(M, animal_species))
			if(M.ckey || M.gender == FEMALE) //Better safe than sorry ;_;
				continue
			partner = M
		else if(!faction_check_mob(M)) //shyness check. we're not shy in front of things that share a faction with us.
			return //we never mate when not alone, so just abort early
		CHECK_TICK

	if(partner && children < 3)
		var/childspawn = pick_weight(childtype)
		var/turf/target = get_turf(loc)
		if(target)
			return new childspawn(target)

/mob/living/simple_animal/update_resting()
	if(resting)
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, RESTING_TRAIT)
	else
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, RESTING_TRAIT)
	return ..()

/mob/living/simple_animal/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/changed = FALSE

	if(resize != RESIZE_DEFAULT_SIZE)
		changed = TRUE
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2, easing = EASE_IN|EASE_OUT)
	UPDATE_OO_IF_PRESENT

/mob/living/simple_animal/proc/sentience_act(mob/user) //Called when a simple animal gains sentience via gold slime potion
	toggle_ai(AI_OFF) // To prevent any weirdness.
	can_have_ai = FALSE

/mob/living/simple_animal/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		sight = (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = NIGHTVISION_FOV_RANGE
		see_invisible = SEE_INVISIBLE_OBSERVER
		return

	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)

	if(HAS_TRAIT(src, TRAIT_THERMAL_VISION))
		sight |= (SEE_MOBS)
		lighting_alpha = min(lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)

	if(HAS_TRAIT(src, TRAIT_XRAY_VISION))
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = max(see_in_dark, 8)

	if(HAS_TRAIT(src, TRAIT_NIGHT_VISION))
		lighting_alpha = min(lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
		see_in_dark = max(see_in_dark, 8)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return
	sync_lighting_plane_alpha()

/mob/living/simple_animal/get_idcard(hand_first)
	return access_card

/mob/living/simple_animal/can_hold_items(obj/item/I)
	return dextrous && ..()

/mob/living/simple_animal/activate_hand(selhand)
	if(!dextrous)
		return ..()
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
		mode()

/mob/living/simple_animal/swap_hand(hand_index)
	. = ..()
	if(!.)
		return
	if(!dextrous)
		return
	if(!hand_index)
		hand_index = (active_hand_index % held_items.len)+1
	var/oindex = active_hand_index
	active_hand_index = hand_index
	if(hud_used)
		var/atom/movable/screen/inventory/hand/H
		H = hud_used.hand_slots["[hand_index]"]
		if(H)
			H.update_icon()
		H = hud_used.hand_slots["[oindex]"]
		if(H)
			H.update_icon()
	refresh_self_screentips()

/mob/living/simple_animal/put_in_hands(obj/item/I, del_on_fail = FALSE, merge_stacks = TRUE)
	. = ..(I, del_on_fail, merge_stacks)
	update_held_items()

/mob/living/simple_animal/update_held_items()
	if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
		var/obj/item/l_hand = get_item_for_held_index(1)
		var/obj/item/r_hand = get_item_for_held_index(2)
		if(r_hand)
			r_hand.plane = ABOVE_HUD_PLANE
			r_hand.screen_loc = ui_hand_position(get_held_index_of_item(r_hand))
			client.screen |= r_hand
		if(l_hand)
			l_hand.plane = ABOVE_HUD_PLANE
			l_hand.screen_loc = ui_hand_position(get_held_index_of_item(l_hand))
			client.screen |= l_hand

//ANIMAL RIDING

/mob/living/simple_animal/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	if(user.incapacitated)
		return
	for(var/atom/movable/A in get_turf(src))
		if(A != src && A != M && A.density)
			return

	return ..()

/mob/living/simple_animal/proc/toggle_ai(togglestatus)
	if(QDELETED(src))
		return
	if(!can_have_ai && (togglestatus != AI_OFF))
		return
	if (AIStatus == togglestatus)
		return

	if (togglestatus > 0 && togglestatus < 5)
		if (togglestatus == AI_Z_OFF || AIStatus == AI_Z_OFF)
			var/turf/T = get_turf(src)
			if (T)
				if (AIStatus == AI_Z_OFF)
					SSidlenpcpool.idle_mobs_by_zlevel[T.z] -= src
				else
					SSidlenpcpool.idle_mobs_by_zlevel[T.z] += src
		GLOB.simple_animals[AIStatus] -= src
		GLOB.simple_animals[togglestatus] += src
		AIStatus = togglestatus
	else
		stack_trace("Something attempted to set simple animals AI to an invalid state: [togglestatus]")

/mob/living/simple_animal/proc/get_discovery_id()
	return type

/mob/living/simple_animal/proc/consider_wakeup()
	if (pulledby || shouldwakeup)
		toggle_ai(AI_ON)

/mob/living/simple_animal/onTransitZ(old_z, new_z)
	..()
	if (AIStatus == AI_Z_OFF)
		SSidlenpcpool.idle_mobs_by_zlevel[old_z] -= src
		toggle_ai(initial(AIStatus))

/mob/living/simple_animal/give_mind(mob/user)
	. = ..()
	if(.)
		sentience_act(user)

/mob/living/simple_animal/proc/Goto(target, delay, minimum_distance)
	if(prevent_goto_movement)
		return FALSE
	SSmove_manager.move_to(src, target, minimum_distance, delay)
	return TRUE

//Makes this mob hunt the prey, be it living or an object. Will kill living creatures, and delete objects.
/mob/living/simple_animal/proc/hunt(hunted)
	if(src == hunted) //Make sure it doesn't eat itself. While not likely to ever happen, might as well check just in case.
		return
	stop_automated_movement = FALSE
	if(!isturf(src.loc)) // Are we on a proper turf?
		return
	if(stat || resting || buckled) // Are we concious, upright, and not buckled?
		return
	if(!COOLDOWN_FINISHED(src, emote_cooldown)) // Has the cooldown on this ended?
		return
	if(!Adjacent(hunted) && Goto(hunted, 3, 0))
		stop_automated_movement = TRUE
		if(Adjacent(hunted))
			hunt(hunted) // In case it gets next to the target immediately, skip the scan timer and kill it.
		return
	if(isliving(hunted)) // Are we hunting a living mob?
		var/mob/living/prey = hunted
		if(inept_hunter) // Make your hunter inept to have them unable to catch their prey.
			visible_message("<span class='warning'>[src] chases [prey] around, to no avail!</span>")
			step(prey, pick(GLOB.cardinals))
			COOLDOWN_START(src, emote_cooldown, 1 MINUTES)
			return
		if(!(prey.stat))
			manual_emote("chomps [prey]!")
			prey.death()
			prey = null
			COOLDOWN_START(src, emote_cooldown, 1 MINUTES)
			return
	else // We're hunting an object, and should delete it instead of killing it. Mostly useful for decal bugs like ants or spider webs.
		manual_emote("chomps [hunted]!")
		qdel(hunted)
		hunted = null
		COOLDOWN_START(src, emote_cooldown, 1 MINUTES)
		return

/mob/living/simple_animal/relaymove(mob/living/user, direction)
	if(user.incapacitated)
		return
	return relaydrive(user, direction)

/mob/living/simple_animal/compare_sentience_type(compare_type)
	return sentience_type == compare_type
