#define MODE_TRAY 1 //Normal mode, shows objects under floors
#define MODE_BLUEPRINT 2 //Blueprint mode, shows how wires and pipes are by default

/obj/item/t_scanner
	name = "\improper T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon = 'icons/obj/device.dmi'
	icon_state = "t-ray0"
	var/on = FALSE
	var/mode = MODE_TRAY
	var/list/image/showing = list()
	var/client/viewing
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	custom_materials = list(/datum/material/iron=150)

/obj/item/t_scanner/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to emit terahertz-rays into [user.p_their()] brain with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS

/obj/item/t_scanner/proc/toggle_on()
	on = !on
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	update_appearance()

/obj/item/t_scanner/proc/toggle_mode(mob/user)
	if(mode == MODE_TRAY)
		mode = MODE_BLUEPRINT
		to_chat(user, span_notice("You switch the [src] to work in the 'blueprint' mode."))
		if(on)
			set_viewer(user)
	else
		to_chat(user, span_notice("You switch the [src] to work in the 'scanner' mode."))
		mode = MODE_TRAY
		clear_viewer(user)
	update_appearance()

/obj/item/t_scanner/update_icon_state()
	if(on)
		icon_state = copytext_char(icon_state, 1, -1) + "[mode]"
	else
		icon_state = copytext_char(icon_state, 1, -1) + "[on]"
	return ..()

/obj/item/t_scanner/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE))
		toggle_mode(user)

/obj/item/t_scanner/attack_self(mob/user)
	toggle_on()

/obj/item/t_scanner/cyborg_unequip(mob/user)
	if(!on)
		return
	toggle_on()

/obj/item/t_scanner/dropped(mob/user)
	..()
	clear_viewer(user)

/obj/item/t_scanner/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return null
	if(mode == MODE_TRAY)
		scan()
	else
		clear_viewer(loc)
		set_viewer(loc)


/obj/item/t_scanner/proc/scan()
	t_ray_scan(loc)

/proc/t_ray_scan(mob/viewer, flick_time = 16, distance = 3)
	if(!ismob(viewer) || !viewer.client)
		return
	var/list/t_ray_images = list()
	for(var/obj/O in orange(distance, viewer) )
		if(HAS_TRAIT(O, TRAIT_T_RAY_VISIBLE))
			var/image/I = new(loc = get_turf(O))
			var/mutable_appearance/MA = new(O)
			MA.alpha = 128
			MA.dir = O.dir
			I.appearance = MA
			t_ray_images += I
	if(t_ray_images.len)
		flick_overlay_global(t_ray_images, list(viewer.client), flick_time)

/obj/item/t_scanner/proc/get_images(turf/T, viewsize)
	. = list()
	for(var/turf/TT in range(viewsize, T))
		if(TT.blueprint_data)
			. += TT.blueprint_data

/obj/item/t_scanner/proc/set_viewer(mob/user)
	if(!ismob(user) || !user.client)
		return
	if(user?.client)
		if(viewing)
			clear_viewer()
		viewing = user.client
		showing = get_images(get_turf(user), viewing.view)
		viewing.images |= showing

/obj/item/t_scanner/proc/clear_viewer(mob/user)
	if(!ismob(user) || !user.client)
		return
	if(viewing)
		viewing.images -= showing
		viewing = null
	showing.Cut()

#undef MODE_TRAY //Normal mode, shows objects under floors
#undef MODE_BLUEPRINT //Blueprint mode, shows how wires and pipes are by default
