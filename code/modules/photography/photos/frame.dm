// Picture frames

/obj/item/wallframe/picture
	name = "picture frame"
	desc = "The perfect showcase for your favorite deathtrap memories."
	icon = 'icons/obj/decals.dmi'
	custom_materials = list(/datum/material/wood = 2000)
	flags_1 = 0
	icon_state = "frame-empty"
	result_path = /obj/structure/sign/picture_frame
	pixel_shift = -32
	var/obj/item/photo/displayed
	pixel_shift = 30

/obj/item/wallframe/picture/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/photo))
		if(!displayed)
			if(!user.transferItemToLoc(I, src))
				return
			displayed = I
			update_icon()
		else
			to_chat(user, span_notice("\The [src] already contains a photo."))
	..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/wallframe/picture/attack_hand(mob/user, list/modifiers)
	if(user.get_inactive_held_item() != src)
		..()
		return
	if(contents.len)
		var/obj/item/I = pick(contents)
		user.put_in_hands(I)
		to_chat(user, span_notice("You carefully remove the photo from \the [src]."))
		displayed = null
		update_icon()
	return ..()

/obj/item/wallframe/picture/attack_self(mob/user)
	user.examinate(src)

/obj/item/wallframe/picture/examine(mob/user)
	if(user.is_holding(src) && displayed)
		displayed.show(user)
		return list()
	else
		return ..()

/obj/item/wallframe/picture/update_icon()
	cut_overlays()
	if(displayed)
		add_overlay(image(displayed))

/obj/item/wallframe/picture/after_attach(obj/O)
	..()
	var/obj/structure/sign/picture_frame/PF = O
	PF.copy_overlays(src)
	if(displayed)
		PF.framed = displayed
	if(contents.len)
		var/obj/item/I = pick(contents)
		I.forceMove(PF)

/obj/structure/sign/picture_frame
	name = "picture frame"
	desc = "Every time you look it makes you laugh."
	icon = 'icons/obj/decals.dmi'
	icon_state = "frame-empty"
	custom_materials = list(/datum/material/wood = 2000)
	layer = ABOVE_WINDOW_LAYER
	var/obj/item/photo/framed
	var/persistence_id
	var/can_decon = TRUE

#define FRAME_DEFINE(id) /obj/structure/sign/picture_frame/##id/persistence_id = #id

//Put default persistent frame defines here!

#undef FRAME_DEFINE

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/sign/picture_frame)

/obj/structure/sign/picture_frame/Initialize(mapload, dir, building)
	. = ..()
	AddElement(/datum/element/art, OK_ART)
	LAZYADD(SSpersistence.photo_frames, src)

/obj/structure/sign/picture_frame/Destroy()
	LAZYREMOVE(SSpersistence.photo_frames, src)
	return ..()

/obj/structure/sign/picture_frame/proc/get_photo_id()
	if(istype(framed) && istype(framed.picture))
		return framed.picture.id

//Manual loading, DO NOT USE FOR HARDCODED/MAPPED IN ALBUMS. This is for if an album needs to be loaded mid-round from an ID.
/obj/structure/sign/picture_frame/proc/persistence_load()
	var/list/data = SSpersistence.get_photo_frames()
	if(data[persistence_id])
		load_from_id(data[persistence_id])

/obj/structure/sign/picture_frame/proc/load_from_id(id)
	var/obj/item/photo/P = load_photo_from_disk(id)
	if(istype(P))
		if(istype(framed))
			framed.forceMove(drop_location())
		else
			qdel(framed)
		framed = P
		update_icon()

/obj/structure/sign/picture_frame/examine(mob/user)
	if(in_range(src, user) && framed)
		framed.show(user)
		return list()
	else
		return ..()

/obj/structure/sign/picture_frame/attackby(obj/item/I, mob/user, params)
	if(can_decon && (I.tool_behaviour == TOOL_SCREWDRIVER || I.tool_behaviour == TOOL_WRENCH))
		to_chat(user, span_notice("You start unsecuring [name]..."))
		if(I.use_tool(src, user, 30, volume=50))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
			to_chat(user, span_notice("You unsecure [name]."))
			deconstruct()

	else if(I.tool_behaviour == TOOL_WIRECUTTER && framed)
		framed.forceMove(drop_location())
		framed = null
		user.visible_message(span_warning("[user] cuts away [framed] from [src]!"))
		return

	else if(istype(I, /obj/item/photo))
		if(!framed)
			var/obj/item/photo/P = I
			if(!user.transferItemToLoc(P, src))
				return
			framed = P
			update_icon()
		else
			to_chat(user, "[span_notice("\The [src] already contains a photo.")]")

	..()

/obj/structure/sign/picture_frame/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(framed)
		framed.show(user)

/obj/structure/sign/picture_frame/update_icon()
	cut_overlays()
	if(framed)
		add_overlay(image(framed))

/obj/structure/sign/picture_frame/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/item/wallframe/picture/F = new /obj/item/wallframe/picture(loc)
		if(framed)
			F.displayed = framed
			framed = null
		if(contents.len)
			var/obj/item/I = pick(contents)
			I.forceMove(F)
		F.update_icon()
	qdel(src)
