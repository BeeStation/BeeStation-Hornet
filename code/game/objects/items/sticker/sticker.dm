/obj/item/sticker
	name = "sticker" //Don't bother changing the name or desc for subtypes
	desc = "An adhesive graphic."
	icon = 'icons/obj/sticker.dmi'
	icon_state = "happy"
	w_class = WEIGHT_CLASS_TINY
	appearance_flags = TILE_BOUND | PIXEL_SCALE | KEEP_APART
	///Our current state for being stuck or unstuck
	var/sticker_state = STICKER_STATE_ITEM
	///Built appearance for item state
	var/mutable_appearance/item_appearance
	///Build appearance for stuck state
	var/mutable_appearance/stuck_appearance
	///Sticker icon
	var/sticker_icon
	var/sticker_icon_state = "happy_sticker"
	///Do we add an outline?
	var/do_outline = TRUE
	///Sticker flags
	var/sticker_flags
	///Drop rate weight, keep this seperate from rarity for joke
	var/drop_rate = STICKER_WEIGHT_COMMON
	///Do we roll for unusual effects
	var/roll_unusual = TRUE

/obj/item/sticker/Initialize(mapload)
	. = ..()
	item_appearance = build_item_appearance()
	stuck_appearance = build_stuck_appearance()
	//Sticker outline
	if(do_outline)
		add_filter("sticker_outline", 1, outline_filter(1.3, "#fff", flags = OUTLINE_SHARP))
	//Unusual stuff
	if(roll_unusual)
		generate_unusual()

/obj/item/sticker/afterattack(atom/movable/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!can_stick(target) || !proximity_flag)
		return
	//Move to our target
	forceMove(target)
	layer = target.layer+0.01
	target.vis_contents += src
	//Update state
	sticker_state = STICKER_STATE_STUCK
	update_appearance()
	//Build click offset
	var/list/modifiers = params2list(click_parameters)
	if(!LAZYACCESS(modifiers, ICON_X) || !LAZYACCESS(modifiers, ICON_Y))
		return
	pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(world.icon_size/2), world.icon_size/2)
	pixel_y = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(world.icon_size/2), world.icon_size/2)

/obj/item/sticker/attack_hand(mob/user)
	unstick()
	return ..()

/obj/item/sticker/attackby(obj/item/I, mob/living/user, params)
	//If we're stuck to something, pass the attack to our loc
	if(sticker_state == STICKER_STATE_STUCK)
		var/atom/A = loc
		A.attackby(I, user, params)
		return
	return ..()

/obj/item/sticker/Moved(atom/OldLoc, Dir)
	if(sticker_state == STICKER_STATE_STUCK)
		unstick(OldLoc)
	return ..()

/obj/item/sticker/examine(mob/user)
	. = ..()
	//Throw sticker stats here, like series, rarity, etc.
	. += get_stats()

/obj/item/sticker/update_appearance(updates)
	. = ..()
	switch(sticker_state)
		if(STICKER_STATE_ITEM)
			appearance = item_appearance
			vis_flags = null
		if(STICKER_STATE_STUCK)
			appearance = stuck_appearance
			vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_DIR
		else
			return

/obj/item/sticker/proc/build_item_appearance()
	return setup_appearance(mutable_appearance(src.icon, src.icon_state, plane = src.plane))

/obj/item/sticker/proc/build_stuck_appearance()
	return setup_appearance(mutable_appearance(sticker_icon || src.icon, sticker_icon_state || src.icon_state))

//used to set appearance stuff that gets reset by appearance assigns
/obj/item/sticker/proc/setup_appearance(_appearance)
	var/mutable_appearance/MA = _appearance
	MA.name = name
	MA.appearance_flags = appearance_flags
	MA.desc = desc
	return MA

/obj/item/sticker/proc/can_stick(atom/target)
	return ismovable(target) || iswallturf(target) ? TRUE : FALSE

/obj/item/sticker/proc/unstick(atom/override)
	if(sticker_state != STICKER_STATE_STUCK)
		return
	var/atom/movable/AM = override || loc
	AM.vis_contents -= src
	layer = initial(layer)
	//Set this here so ``update_appearance`` works correctly
	sticker_state = STICKER_STATE_ITEM
	update_appearance()
	//Reset click offset
	pixel_x = 0
	pixel_y = 0

/obj/item/sticker/proc/generate_unusual()
	return

/obj/item/sticker/proc/get_stats()
	//TODO: Add case for appending rarity - Racc
	return
