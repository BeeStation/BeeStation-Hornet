/// Solar Assembly - For construction of solar arrays.
/obj/item/solar_assembly
	name = "solar panel assembly"
	desc = "A solar panel assembly kit, allows constructions of a solar panel, or with a tracking circuit board, a solar tracker."
	icon = 'monkestation/icons/obj/power/solar.dmi'
	icon_state = "sp_base"
	item_state = "electropack"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY // Pretty big!
	anchored = FALSE
	var/tracker = 0
	var/glass_type = null
	var/random_offset = 6 //amount in pixels an unanchored assembly may be offset by


/obj/item/solar_assembly/Initialize(mapload)
	. = ..()
	if(!anchored && !pixel_x && !pixel_y)
		randomise_offset(random_offset)

/obj/item/solar_assembly/update_icon_state()
	. = ..()
	icon_state = tracker ? "tracker_base" : "sp_base"

/obj/item/solar_assembly/proc/randomise_offset(amount)
	pixel_x = base_pixel_x + rand(-amount, amount)
	pixel_y = base_pixel_y + rand(-amount, amount)

// Give back the glass type we were supplied with
/obj/item/solar_assembly/proc/give_glass(device_broken)
	var/atom/Tsec = drop_location()
	if(device_broken)
		new /obj/item/shard(Tsec)
		new /obj/item/shard(Tsec)
	else if(glass_type)
		new glass_type(Tsec, 2)
	glass_type = null

/obj/item/solar_assembly/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH && isturf(loc))
		if(isinspace())
			to_chat(user, "<span class='warning'>You can't secure [src] here.</span>")
			return
		anchored = !anchored
		if(anchored)
			user.visible_message("[user] wrenches the solar assembly into place.", "<span class='notice'>You wrench the solar assembly into place.</span>")
			W.play_tool_sound(src, 75)
		else
			user.visible_message("[user] unwrenches the solar assembly from its place.", "<span class='notice'>You unwrench the solar assembly from its place.</span>")
			W.play_tool_sound(src, 75)
		return TRUE

	if(istype(W, /obj/item/stack/sheet/glass) || istype(W, /obj/item/stack/sheet/rglass))
		if(!anchored)
			to_chat(user, "<span class='warning'>You need to secure the assembly before you can add glass.</span>")
			return
		var/obj/item/stack/sheet/S = W
		if(S.use(2))
			glass_type = W.type
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			user.visible_message("[user] places the glass on the solar assembly.", "<span class='notice'>You place the glass on the solar assembly.</span>")
			if(tracker)
				new /obj/machinery/power/tracker(get_turf(src), src)
			else
				new /obj/machinery/power/solar(get_turf(src), src)
		else
			to_chat(user, "<span class='warning'>You need two sheets of glass to put them into a solar panel!</span>")
			return
		return TRUE

	if(!tracker)
		if(istype(W, /obj/item/electronics/tracker))
			if(!user.temporarilyRemoveItemFromInventory(W))
				return
			tracker = 1
			qdel(W)
			user.visible_message("[user] inserts the electronics into the solar assembly.", "<span class='notice'>You insert the electronics into the solar assembly.</span>")
			return TRUE
	else
		if(W.tool_behaviour == TOOL_CROWBAR)
			new /obj/item/electronics/tracker(src.loc)
			tracker = 0
			user.visible_message("[user] takes out the electronics from the solar assembly.", "<span class='notice'>You take out the electronics from the solar assembly.</span>")
			return TRUE
	return ..()
