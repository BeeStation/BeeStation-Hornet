//TODO: Moves these to a define file - Racc
#define STICKER_STATE_STUCK "STICKER_STATE_STUCK"
#define STICKER_STATE_ITEM "STICKER_STATE_ITEM"

/obj/item/sticker
	name = "sticker"
	desc = "An adhesive graphic."
	icon_state = "madeyoulook"
	vis_flags = VIS_INHERIT_ID
	w_class = WEIGHT_CLASS_TINY
	appearance_flags = TILE_BOUND | PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
	///Our current state for being stuck or unstuck
	var/sticker_state = STICKER_STATE_ITEM
	///Built appearance for item state
	var/mutable_appearance/item_appearance
	///Build appearance for stuck state
	var/mutable_appearance/stuck_appearance
	///Sticker icon
	var/sticker_icon
	var/sticker_icon_state = "skub"
	///Do we add an outline?
	var/do_outline = TRUE

/obj/item/sticker/Initialize(mapload)
	. = ..()
	item_appearance = build_item_appearance()
	stuck_appearance = build_stuck_appearance()
	//Sticker outline
	if(do_outline)
		add_filter("sticker_outline", 1, outline_filter(1.5, "#fff"))

/obj/item/sticker/afterattack(atom/movable/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!can_stick(target) || !proximity_flag)
		return
	//Update state
	sticker_state = STICKER_STATE_STUCK
	update_appearance()
	//Move to our target
	forceMove(target)
	layer = target.layer+0.01
	target.vis_contents += src
	//Build click offset
	var/list/modifiers = params2list(click_parameters)
	if(!LAZYACCESS(modifiers, ICON_X) || !LAZYACCESS(modifiers, ICON_Y))
		return
	pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(world.icon_size/2), world.icon_size/2)
	pixel_y = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(world.icon_size/2), world.icon_size/2)

/obj/item/sticker/attack_hand(mob/user)
	//Remove sticker from vis contents
	if(sticker_state == STICKER_STATE_STUCK)
		var/atom/movable/AM = loc
		AM.vis_contents -= src
		layer = initial(layer)
		//Set this here so ``update_appearance`` works correctly
		sticker_state = STICKER_STATE_ITEM
		update_appearance()
	. = ..()
	//Reset click offset
	pixel_x = 0
	pixel_y = 0

/obj/item/sticker/attackby(obj/item/I, mob/living/user, params)
	//If we're stuck to something, pass the attack to our loc
	if(sticker_state == STICKER_STATE_STUCK)
		var/atom/A = loc
		A.attackby(I, user, params)
		return
	return ..()

/obj/item/sticker/update_appearance(updates)
	. = ..()
	switch(sticker_state)
		if(STICKER_STATE_ITEM)
			appearance = item_appearance
		if(STICKER_STATE_STUCK)
			appearance = stuck_appearance
		else
			return
	//We have to update the name everytime, due to how setting appearance works
	name = initial(name)

/obj/item/sticker/proc/build_item_appearance()
	return mutable_appearance(src.icon, src.icon_state)

/obj/item/sticker/proc/build_stuck_appearance()
	return mutable_appearance(sticker_icon || src.icon, sticker_icon_state || src.icon_state)

/obj/item/sticker/proc/can_stick(atom/target)
	return ismovable(target) ? TRUE : FALSE
