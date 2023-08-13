GLOBAL_LIST_EMPTY(video_bug_list)

//detective spyglasses. meant to be an example for map_popups.dm
/obj/item/clothing/glasses/sunglasses/spy
	desc = "Made by Nerd. Co's infiltration and surveillance department. Upon closer inspection, there's a small screen in each lens."
	actions_types = list(/datum/action/item_action/activate_remote_view)
	var/bug_network_id = null
	var/obj/item/video_bug/viewed_bug
	buggable = FALSE

/obj/item/clothing/glasses/sunglasses/spy/examine(mob/user)
	. = ..()
	if(bug_network_id)
		. += "<span class='notice'>It is connected to \the <b>[bug_network_id]</b> network.</span>"
	else
		. += "<span class='warning'>It is not connected to any network!</span>"

/obj/item/clothing/glasses/sunglasses/spy/proc/show_to_user(mob/user, selected_bug_id)//this is the meat of it. most of the map_popup usage is in this.
	if(!user?.client)
		return
	if(user.client.screen_maps["spypopup_map"] || viewed_bug) //the view window of another bug is open so we'll close it
		for(var/obj/item/video_bug/found_bug in GLOB.video_bug_list)
			user.client.close_popup("spypopup")
			viewed_bug.being_viewed = FALSE
			viewed_bug.viewing_glasses = null
			viewed_bug = null
			break
	for(var/obj/item/video_bug/found_bug in GLOB.video_bug_list)
		if(found_bug.bug_id == selected_bug_id && found_bug.bug_network_id == bug_network_id)
			viewed_bug = found_bug
	user.client.setup_popup("spypopup", 3, 3, 2)
	user.client.register_map_obj(viewed_bug.cam_screen)
	for(var/plane in viewed_bug.cam_plane_masters)
		user.client.register_map_obj(plane)
	viewed_bug.being_viewed = TRUE
	viewed_bug.viewing_glasses = src
	viewed_bug.update_view()

/obj/item/clothing/glasses/sunglasses/spy/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_EYES))
		user.client.close_popup("spypopup")
		if(viewed_bug)
			viewed_bug.being_viewed = FALSE
			viewed_bug.viewing_glasses = null
			viewed_bug = null

/obj/item/clothing/glasses/sunglasses/spy/dropped(mob/user)
	..()
	user.client.close_popup("spypopup")
	if(viewed_bug)
		viewed_bug.being_viewed = FALSE
		viewed_bug.viewing_glasses = null
		viewed_bug = null

/obj/item/clothing/glasses/sunglasses/spy/ui_action_click(mob/user)
	if(!length(GLOB.video_bug_list))
		user.audible_message("<span class='warning'>\The [src] lets off a shrill beep!</span>")
		return
	var/list/bug_list = list()
	for(var/obj/item/video_bug/found_bug in GLOB.video_bug_list)
		if(found_bug.bug_network_id == bug_network_id && !found_bug.disabled)
			bug_list.Add(found_bug.bug_id)
	if(!length(bug_list))
		user.audible_message("<span class='warning'>\The [src] lets off a shrill beep!</span>")
		return
	var/picked_bug_id = tgui_input_list(user, "Select which tracking bug to view", "Spying", bug_list, null)
	if(!isnull(picked_bug_id))
		show_to_user(user, picked_bug_id)

/obj/item/clothing/glasses/sunglasses/spy/item_action_slot_check(slot)
	return slot & ITEM_SLOT_EYES

/obj/item/clothing/glasses/sunglasses/spy/Destroy()
	if(viewed_bug)
		viewed_bug.being_viewed = FALSE
		if(viewed_bug.viewing_glasses == src)
			viewed_bug.viewing_glasses = null
		viewed_bug = null
	return ..()

//it needs to be linked, hence a kit.
/obj/item/storage/box/rxglasses/spyglasskit
	name = "spyglass kit"
	desc = "this box contains <i>cool</i> nerd glasses; with built-in displays to view linked camera bugs."

/obj/item/paper/fluff/nerddocs
	name = "Espionage For Dummies"
	color = "#FFFF00"
	desc = "An eye gougingly yellow pamphlet with a badly designed image of a detective on it. the subtext says \" The Latest Way To Violate Privacy Guidelines!\" "
	default_raw_text = @{"
Thank you for your purchase of the Nerd Co SpySpeks <small>tm</small>, this paper will be your quick-start guide to violating the privacy of your crewmates in three easy steps!<br><br>Step One: Nerd Co SpySpeks <small>tm</small> upon your face. <br>
Step Two: Place the included "ProfitProtektor <small>tm</small>" camera assembly in a place of your choosing - make sure to make heavy use of it's inconspicous design!
Step Three: Press the "Activate Remote View" Button on the side of your SpySpeks <small>tm</small> to open a movable camera display in the corner of your vision, it's just that easy!<br><br><br><center><b>TROUBLESHOOTING</b><br></center>
My SpySpeks <small>tm</small> Make a shrill beep while attempting to use!
A shrill beep coming from your SpySpeks means that they can't connect to the included ProfitProtektor <small>tm</small>, please make sure your ProfitProtektor is still active, and functional!
	"}

/obj/item/storage/box/rxglasses/spyglasskit/PopulateContents()
	var/bug_network_id = "[pick(GLOB.phonetic_alphabet)]-[rand(1,999)]"
	var/obj/item/clothing/glasses/sunglasses/spy/newglasses = new(src)
	newglasses.bug_network_id = bug_network_id
	for(var/i in 1 to 5)
		var/obj/item/video_bug/bug = new(src)
		bug.bug_network_id = bug_network_id
	new /obj/item/paper/fluff/nerddocs(src)

/obj/item/video_bug
	name = "camera bug"
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "camerabug"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	item_flags = ISWEAPON
	var/icon_state_clothing = "camerabug_clothing_overlay"
	var/icon_state_clothing_emissive = "camerabug_clothing_overlay_emissive"
	desc = "An advanced piece of espionage equipment, which can be attached to most pieces of clothing or hidden under the floor. It has a built in 360 degree camera for all your \"admirable\" needs. Microphone not included."
	var/x_coord = 0
	var/y_coord = 0
	var/obj/item/clothing/attached_to = null

	var/bug_id = null
	var/bug_network_id = null

	var/being_viewed = FALSE
	var/obj/item/clothing/glasses/sunglasses/spy/viewing_glasses = null

	var/atom/movable/screen/map_view/cam_screen
	var/list/cam_plane_masters
	// Ranges higher than one can be used to see through walls.
	var/cam_range = 1
	var/datum/movement_detector/tracker

	var/disabled = FALSE

/obj/item/video_bug/Initialize(mapload)
	update_overlays()
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE, INVISIBILITY_OBSERVER, use_anchor = TRUE)
	bug_id = "[pick(GLOB.posibrain_names)]-[rand(1,999)]"
	GLOB.video_bug_list.Add(src)
	create_view()
	. = ..()

/obj/item/video_bug/Destroy()
	QDEL_NULL(cam_screen)
	QDEL_LIST(cam_plane_masters)
	QDEL_NULL(tracker)
	GLOB.video_bug_list.Remove(src)
	if(attached_to)
		attached_to.tracking_bug = null
		attached_to.update_overlays()
		attached_to = null
	if(viewing_glasses)
		viewing_glasses.viewed_bug = null
		viewing_glasses = null
	return ..()

/obj/item/video_bug/examine(mob/user)
	. = ..()
	if(bug_network_id)
		. += "<span class='notice'>It is connected to \the <b>[bug_network_id]</b> network.</span>"
	else
		. += "<span class='warning'>It is not connected to any network!</span>"
	if(bug_id)
		. += "<span class='notice'>It's ID is <b>[bug_id]</b></span>"
	else
		. += "<span class='warning'>It does not have an ID!</span>"


/obj/item/video_bug/update_overlays()
	. = ..()
	if(!disabled)
		. += mutable_appearance(icon, "camerabug_overlay")
		. += emissive_appearance(icon, "camerabug_overlay_emissive", alpha = alpha)

/obj/item/video_bug/proc/attach_to_clothing_item(mob/user, var/obj/item/clothing/target)
	if(!target.buggable || target.item_flags & ABSTRACT)
		to_chat(user, "<span class='warning'>You can't attach \the [src] to \the [target]!</span>")
		return FALSE
	if(target.tracking_bug)
		to_chat(user, "<span class='warning'>\The [target] already has something attached!</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You start to carefully plant [src] to \the [target].</span>")
	if(!do_after(user, 1 SECONDS, get_turf(target)))
		to_chat(user, "<span class='warning'>Your hand slips and you decide not to plant \the [src]!</span>")
		return FALSE
	var/left_border = 1
	var/right_border = 32
	var/bottom_border = 1
	var/top_border = 32
	var/list/temp_list = target.get_bounding_box()
	left_border = temp_list["left"]
	right_border = temp_list["right"]
	bottom_border = temp_list["bottom"]
	top_border = temp_list["top"]
	var/icon/target_icon = getFlatIcon(target)
	var/attempts = 0
	var/selected_x
	var/selected_y
	var/selected_coordinates = FALSE
	while(attempts < 10)
		selected_x = rand(left_border + 2, right_border - 2)
		selected_y = rand(bottom_border + 2, top_border - 2)
		if(isnull(target_icon.GetPixel(selected_x, selected_y)))
			attempts ++
		else
			selected_coordinates = TRUE
			break
	if(!selected_coordinates)
		selected_x = 15
		selected_y = 15
	user.temporarilyRemoveItemFromInventory(src)
	forceMove(null)
	attached_to = target
	tracker = new /datum/movement_detector(target, CALLBACK(src, PROC_REF(update_view)))
	target.tracking_bug = src
	target.tracking_bug.x_coord = selected_x - 15
	target.tracking_bug.y_coord = selected_y - 15
	target.update_appearance(updates = UPDATE_ICON|UPDATE_OVERLAYS)
	update_view()
	return TRUE

/obj/item/video_bug/proc/detach_from_clothing(mob/user, var/obj/item/clothing/target)
	target.tracking_bug.attached_to = null
	tracker = new /datum/movement_detector(src, CALLBACK(src, PROC_REF(update_view)))
	target.tracking_bug.update_view()
	target.tracking_bug = null
	target.update_appearance(updates = UPDATE_ICON|UPDATE_OVERLAYS)

/obj/item/video_bug/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/clothing/glasses/sunglasses/spy))
		var/obj/item/clothing/glasses/sunglasses/spy/spyglasses
		if(spyglasses.bug_network_id)
			bug_network_id = spyglasses.bug_network_id
			to_chat(user,"<span class='notice'>You connect \the [src] to \the [spyglasses]'s network!</span>")
		else if(bug_network_id)
			spyglasses.bug_network_id = bug_network_id
			to_chat(user,"<span class='notice'>You connect \the [spyglasses] to \the [src]'s network!</span>")

/obj/item/video_bug/attack_self(mob/user)
	. = ..()
	if(being_viewed)
		to_chat(user, "<span class='warning'>\The [src] is currently in use and its ID cannot be changed!</span>")
		return
	var/picked_id = tgui_input_text(user, "Please enter an ID for this tracker.", "ID ", bug_id)
	if(picked_id)
		bug_id = picked_id
		to_chat(user, "<span class='notice'>You set \the [src]'s ID to [picked_id].</span>")

/obj/item/video_bug/pre_attack(atom/A, mob/living/user, params)
	if(istype(A, /obj/item/clothing))
		if(attach_to_clothing_item(user, A))
			to_chat(user, "<span class='notice'>You stealthily plant \the [src] on \the [A]!</span>")
	if(iscarbon(A))
		attach_to_carbon(user, A)

/obj/item/video_bug/attack(mob/living/M, mob/living/user)
	return COMPONENT_NO_AFTERATTACK

/obj/item/video_bug/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	return

/obj/item/video_bug/emp_act(severity)
	if(severity > 4)
		Destroy(src)
		return ..()
	disabled = TRUE
	QDEL_NULL(cam_screen)
	QDEL_LIST(cam_plane_masters)
	QDEL_NULL(tracker)
	if(attached_to)
		attached_to.update_appearance(updates = UPDATE_ICON|UPDATE_OVERLAYS)
	addtimer(CALLBACK(src, PROC_REF(recover_from_emp)), 60 SECONDS * severity)
	return ..()

/obj/item/video_bug/proc/recover_from_emp()
	disabled = FALSE
	create_view()
	update_view()
	if(attached_to)
		attached_to.update_appearance(updates = UPDATE_ICON|UPDATE_OVERLAYS)

/obj/item/video_bug/proc/create_view()
	tracker = new /datum/movement_detector(src, CALLBACK(src, PROC_REF(update_view)))
	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = "spypopup_map"
	cam_screen.del_on_map_removal = FALSE
	cam_screen.set_position(1, 1)

	// We need to add planesmasters to the popup, otherwise
	// blending fucks up massively. Any planesmaster on the main screen does
	// NOT apply to map popups. If there's ever a way to make planesmasters
	// omnipresent, then this wouldn't be needed.
	cam_plane_masters = list()
	for(var/plane in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/blackness)
		var/atom/movable/screen/plane_master/instance = new plane()
		if(instance.blend_mode_override)
			instance.blend_mode = instance.blend_mode_override
		instance.assigned_map = "spypopup_map"
		instance.del_on_map_removal = FALSE
		instance.screen_loc = "spypopup_map:CENTER"
		cam_plane_masters += instance

/obj/item/video_bug/proc/update_view()//this doesn't do anything too crazy, just updates the vis_contents of its screen obj
	if(!cam_screen)
		return
	if(!being_viewed || disabled)
		return
	cam_screen.vis_contents.Cut()
	if(attached_to)
		for(var/turf/visible_turf in view(1,get_turf(attached_to)))//fuck you usr
			cam_screen.vis_contents += visible_turf
	else
		for(var/turf/visible_turf in view(1,get_turf(src)))//fuck you usr
			cam_screen.vis_contents += visible_turf

/obj/item/video_bug/proc/attach_to_carbon(mob/user, mob/living/carbon/target)
	var/target_zone = user.zone_selected
	if(!target_zone)
		target_zone = BODY_ZONE_CHEST
	var/obj/item/clothing/head_item = null //Hats and helmets
	var/obj/item/clothing/eyes_item = null //Glasses
	var/obj/item/clothing/mouth_item = null //Mask
	var/obj/item/clothing/chest_item = null // Suit/jumpsuit
	var/obj/item/clothing/arms_item = null //Sleeves
	var/obj/item/clothing/hands_item = null //Gloves
	var/obj/item/clothing/legs_item = null //Pants
	var/obj/item/clothing/feet_item = null //Shoes

	if(target.shoes)
		feet_item = target.shoes
	if(target.gloves)
		hands_item = target.gloves
	if(target.glasses)
		eyes_item = target.glasses
	if(target.wear_mask)
		mouth_item = target.wear_mask
		if(target.wear_mask.body_parts_covered & HEAD)
			head_item = target.wear_mask
		if(target.wear_mask.flags_cover & MASKCOVERSEYES)
			eyes_item = target.wear_mask
	if(target.head)
		head_item = target.head
		if(target.head.flags_cover & HEADCOVERSEYES)
			eyes_item = HEADCOVERSEYES
		if(target.head.flags_cover & HEADCOVERSMOUTH)
			mouth_item = target.head
	if(ismonkey(target))
		var/mob/living/carbon/monkey/target_monkey = target
		if(target_monkey.w_uniform)
			chest_item = target_monkey.w_uniform
			if(target_monkey.w_uniform.body_parts_covered & LEGS)
				legs_item = target_monkey.w_uniform
			if((target_monkey.w_uniform.body_parts_covered & ARMS))
				arms_item = target_monkey.w_uniform
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		if(target_human.w_uniform)
			chest_item = target_human.w_uniform
			if((target_human.w_uniform.body_parts_covered & LEGS) && isnull(legs_item))
				legs_item = target_human.w_uniform
			if((target_human.w_uniform.body_parts_covered & ARMS) && isnull(arms_item))
				arms_item = target_human.w_uniform
		if(target_human.wear_suit)
			chest_item = target_human.wear_suit
			if(target_human.wear_suit.body_parts_covered & ARMS)
				arms_item = target_human.wear_suit
				if((isnull(hands_item) || target_human.wear_suit.flags_inv & HIDEGLOVES))
					hands_item = target_human.wear_suit
			if(target_human.wear_suit.body_parts_covered & LEGS)
				legs_item = target_human.wear_suit
				if(isnull(legs_item) || target_human.wear_suit.flags_inv & HIDESHOES)
					feet_item = target_human.wear_suit
	switch(target_zone)
		if(BODY_ZONE_HEAD)
			if(!isnull(head_item))
				if(attach_to_clothing_item(user, head_item))
					to_chat(user, "<span class='notice'>You stealthily plant \the [src] on [target]'s [head_item.name]!</span>")
					return TRUE
			return FALSE
		if(BODY_ZONE_PRECISE_EYES)
			if(!isnull(eyes_item))
				if(attach_to_clothing_item(user, eyes_item))
					to_chat(user, "<span class='notice'>You stealthily plant \the [src] on [target]'s [eyes_item.name]!</span>")
					return TRUE
			return FALSE
		if(BODY_ZONE_PRECISE_MOUTH)
			if(!isnull(mouth_item))
				if(attach_to_clothing_item(user, mouth_item))
					to_chat(user, "<span class='notice'>You stealthily plant \the [src] on [target]'s [mouth_item.name]!</span>")
					return TRUE
			return FALSE
		if(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN)
			if(!isnull(chest_item))
				if(attach_to_clothing_item(user, chest_item))
					to_chat(user, "<span class='notice'>You stealthily plant \the [src] on [target]'s [chest_item.name]!</span>")
					return TRUE
			return FALSE
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			if(!isnull(hands_item))
				if(attach_to_clothing_item(user, hands_item))
					to_chat(user, "<span class='notice'>You stealthily plant \the [src] on [target]'s [hands_item.name]!</span>")
					return TRUE
			if(!isnull(arms_item))
				if(attach_to_clothing_item(user, arms_item))
					to_chat(user, "<span class='notice'>You stealthily plant \the [src] on [target]'s [arms_item.name]!</span>")
					return TRUE
			return FALSE
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			if(!isnull(feet_item))
				if(attach_to_clothing_item(user, feet_item))
					to_chat(user, "<span class='notice'>You stealthily plant \the [src] on [target]'s [feet_item.name]!</span>")
					return TRUE
			if(!isnull(legs_item))
				if(attach_to_clothing_item(user, legs_item))
					to_chat(user, "<span class='notice'>You stealthily plant \the [src] on [target]'s [legs_item.name]!</span>")
					return TRUE
			return FALSE
