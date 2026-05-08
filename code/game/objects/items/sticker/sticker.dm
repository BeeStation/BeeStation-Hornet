/obj/item/sticker
	name = "sticker" //Don't bother changing the name or desc for subtypes
	desc = "An adhesive graphic."
	icon = 'icons/obj/sticker.dmi'
	icon_state = "happy"
	flags_1 = IS_ONTOP_1
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
	///What kind of tint we rocking?
	var/tint = "#fff"
	///Sticker flags
	var/sticker_flags
	///Drop rate weight, keep this seperate from rarity for joke
	var/drop_rate = STICKER_WEIGHT_COMMON
	///Do we roll for unusual effects
	var/roll_unusual = TRUE
	var/is_unusual = FALSE

/obj/item/sticker/Initialize(mapload)
	. = ..()
	item_appearance = build_item_appearance()
	stuck_appearance = build_stuck_appearance()
	color = tint
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
	layer = target.layer+0.001
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

/obj/item/sticker/attack_hand(mob/living/user)
	if(user.combat_mode && sticker_state == STICKER_STATE_STUCK)
		var/atom/A = loc
		A.attack_hand(user)
		if(prob(33)) //We have a 1/3 chance of falling off
			unstick()
			forceMove(get_turf(user))
		return
	unstick()
	return ..()

/obj/item/sticker/attack_alien(mob/living/user)
	if(user.combat_mode && sticker_state == STICKER_STATE_STUCK)
		var/atom/A = loc
		A.attack_alien(user)
	return attack_hand(user) //can be picked up by aliens

/obj/item/sticker/attack_animal(mob/living/simple_animal/M)
	if(M.combat_mode && sticker_state == STICKER_STATE_STUCK)
		var/atom/A = loc
		A.attack_animal(M)
	return attack_hand(M)

/obj/item/sticker/CtrlClick(mob/living/user)
	. = ..()
	if(user.combat_mode && sticker_state == STICKER_STATE_STUCK)
		var/atom/A = loc
		A.CtrlClick(user)
		return
	return ..()

/obj/item/sticker/attackby(obj/item/I, mob/living/user, params)
	//If we're stuck to something, pass the attack to our loc
	if(sticker_state == STICKER_STATE_STUCK)
		var/atom/A = loc
		A.attackby(I, user, params)
		if(prob(33)) //We have a 1/3 chance of falling off
			unstick()
			forceMove(get_turf(user))
		return
	return ..()

/obj/item/sticker/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	if(sticker_state == STICKER_STATE_STUCK)
		unstick(old_loc)
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
	return setup_appearance(mutable_appearance(src.icon, src.icon_state, plane = src.plane, color = tint))

/obj/item/sticker/proc/build_stuck_appearance()
	return setup_appearance(mutable_appearance(sticker_icon || src.icon, sticker_icon_state || src.icon_state, color = tint))

//used to set appearance stuff that gets reset by appearance assigns
/obj/item/sticker/proc/setup_appearance(_appearance)
	var/mutable_appearance/MA = _appearance
	MA.name = name
	MA.appearance_flags = appearance_flags
	MA.desc = desc
	return MA

/obj/item/sticker/proc/can_stick(atom/target)
	if(istype(target, /obj/item/sticker))
		return FALSE
	if(istype(target, /atom/movable/screen))
		return FALSE
	//If you want to add MORE stuff to the denial list, swap it to a type list
	if(ismovable(target))
		return TRUE
	if(iswallturf(target))
		return TRUE
	return FALSE

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

///Add an unusual effect to the sticker, potentially
/obj/item/sticker/proc/generate_unusual()
	//You'll want to go through and add a list of particle effects / logic for your series, this is just a generic placeholder
	if(prob(1))
		add_emitter(/obj/emitter/electrified, "unusual", 10)

/obj/item/sticker/proc/get_stats()
	. = ""
	//Append rarity
	var/rarities = STICKER_RARITY_COMMON | STICKER_RARITY_UNCOMMON | STICKER_RARITY_RARE | STICKER_RARITY_EXOTIC | STICKER_RARITY_MYTHIC
	var/rarity = rarities & sticker_flags
	if(!rarity)
		return
	//use this switch to give the rarity name, color, and any other effects you want to add
	switch(rarity)
		if(STICKER_RARITY_COMMON)
			. += "<span class='notice'>Common</span>\n"
		if(STICKER_RARITY_UNCOMMON)
			. += "<span class='green'>Uncommon</span>\n"
		if(STICKER_RARITY_RARE)
			. += "<span class='cult'>Rare</span>\n"
		if(STICKER_RARITY_EXOTIC)
			. += "<span class='revennotice'>Exotic</span>\n"
		if(STICKER_RARITY_MYTHIC)
			. += "<span class='alien'>Mythic</span>\n"
		else
			. += "<span class='warning'>GARBAGE</span>\n"
	//Append unusual status
	if(is_unusual)
		. += "<span class='purple'>Unusual</span>\n"
