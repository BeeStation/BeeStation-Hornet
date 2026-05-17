/mob/living/simple_animal/bot/turtle
	name = "\improper turtle"
	desc = "A hydroponics helper."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "turtle"
	density = FALSE
	anchored = FALSE
	health = 50
	maxHealth = 50
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE //Service
	bot_type = TURTLE_BOT
	model = "Turtle"
	pass_flags = PASSMOB
	path_image_color = "#6c9932"
	player_access = list(ACCESS_SERVICE)
	wander = TRUE

	var/atom/target
	///Plant offset to properly line things up
	var/list/plant_offset = list(0, 26)
	///mask for burried visuals
	var/icon/mask
	///Reference to our 'on' overlay, for when a pai uses us
	var/icon/on_overlay
	///What reagent we water trays with
	var/dispensed_reagent = /datum/reagent/water
	///Do we auto water?
	var/water = TRUE

/mob/living/simple_animal/bot/turtle/Initialize(mapload)
	. = ..()
	if(prob(5))
		name = "Louie"
		icon_state = "louie"
	on_overlay = icon('icons/mob/aibots.dmi', "turtle on")
//Tray stuff
	var/datum/component/planter/tray_component = AddComponent(/datum/component/planter, plant_offset, 1.2, FALSE)
	tray_component.set_substrate(/datum/plant_subtrate/fairy)
	tray_component.allow_substrate_change = FALSE
//Build pot appearance
	//Add a random pot to our top
	var/mutable_appearance/pot = mutable_appearance('icons/obj/hydroponics/features/pots.dmi', "pot_[rand(1, 6)]")
	pot.pixel_y += 14
	add_overlay(pot)
	//Build a pot mask
	mask = icon('icons/obj/hydroponics/features/pots.dmi', "pot_mask")

/mob/living/simple_animal/bot/turtle/Destroy(force)
	. = ..()
	QDEL_NULL(mask)

/mob/living/simple_animal/bot/turtle/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()
	var/datum/component/planter/tray_component = attack_target.GetComponent(/datum/component/planter)
	if(!tray_component)
		return
	visible_message(span_notice("[src] waters [attack_target]."))
	playsound(attack_target, 'sound/effects/footstep/water1.ogg', 60, TRUE)
	attack_target.reagents?.add_reagent(dispensed_reagent, 15)

/mob/living/simple_animal/bot/turtle/on_emag(atom/target, mob/user)
	..()
	if(emagged == 2 && user)
		to_chat(user, span_danger("[src] buzzes and beeps."))
		dispensed_reagent = /datum/reagent/toxin/plantbgone

/mob/living/simple_animal/bot/turtle/handle_automated_action()
	. = ..()
	if(!. || !water)
		return
	//Get a target
	target = scan(list(/obj/item/plant_tray))
//Wander off if no target
	if(!target && auto_patrol)
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()
		if(mode == BOT_PATROL)
			bot_patrol()
//If we have a target
	//Flight checks
	else if(target)
		if(QDELETED(target) || !isturf(target.loc))
			target = null
			mode = BOT_IDLE
			return
	//Water target if we're close enough
	if(get_dist(src, target) <= 1)
		UnarmedAttack(target, proximity_flag = TRUE) //Rather than check at every step of the way, let's check before we do an action, so we can rescan before the other bot.
		if(QDELETED(target)) //We done here.
			target = null
			mode = BOT_IDLE
			return
	//Path find to target if they're too far away
	if(target && path.len == 0 && (get_dist(src,target) > 1))
		path = get_path_to(src, target, max_distance=30, mintargetdist=1, access=access_card.GetAccess())
		mode = BOT_MOVING
		if(!path.len)
			add_to_ignore(target)
			target = null
	//if we cannae move
	if(path.len > 0 && target)
		if(!bot_move(path[path.len]))
			target = null
			mode = BOT_IDLE

/mob/living/simple_animal/bot/turtle/process_scan(atom/scan_target)
	. = ..()
	//Only water stuff to half way, then move onto the next
	if(scan_target.reagents?.total_volume >= scan_target.reagents?.maximum_volume/2)
		return null

/mob/living/simple_animal/bot/turtle/ui_data(mob/user)
	var/list/data = ..()
	if(!locked || issilicon(user)|| IsAdminGhost(user))
		data["custom_controls"]["water"] = water
	return data

/mob/living/simple_animal/bot/turtle/ui_act(action, params)
	if (..())
		return TRUE
	switch(action)
		if("water")
			water = !water

/mob/living/simple_animal/bot/turtle/insertpai(mob/user, obj/item/pai_card/card)
	. = ..()
	add_overlay(on_overlay)

/mob/living/simple_animal/bot/turtle/insertpai(mob/user, obj/item/pai_card/card)
	. = ..()
	cut_overlay(on_overlay)

/mob/living/simple_animal/bot/turtle/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	//Masking
	var/datum/component/plant/plant_component = arrived.GetComponent(/datum/component/plant)
	if(plant_component?.draw_below_water)
		arrived.add_filter("plant_tray_mask", 1, alpha_mask_filter(y = -12, icon = mask, flags = MASK_INVERSE))

/mob/living/simple_animal/bot/turtle/Exited(atom/movable/gone, direction)
	. = ..()
	gone.remove_filter("plant_tray_mask")
	vis_contents -= gone

//Bot core
/obj/machinery/bot_core/turtle
	req_one_access = list(ACCESS_JANITOR, ACCESS_ROBOTICS)
