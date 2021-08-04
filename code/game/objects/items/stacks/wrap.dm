

/*
 * Wrapping Paper
 */

/obj/item/stack/wrapping_paper
	name = "wrapping paper"
	desc = "Wrap packages with this festive paper to make gifts."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "wrap_paper"
	greyscale_config = /datum/greyscale_config/wrap_paper
	item_flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	resistance_flags = FLAMMABLE

/obj/item/stack/wrapping_paper/Initialize()
	. = ..()
	if(!greyscale_colors)
		//Generate random valid colors for paper and ribbon
		var/generated_base_color = "#" + random_color()
		var/generated_ribbon_color = "#" + random_color()
		var/temp_base_hsv = RGBtoHSV(generated_base_color)
		var/temp_ribbon_hsv = RGBtoHSV(generated_ribbon_color)

		//If colors are too dark, set to original colors
		if(ReadHSV(temp_base_hsv)[3] < ReadHSV("7F7F7F")[3])
			generated_base_color = "#00FF00"
		if(ReadHSV(temp_ribbon_hsv)[3] < ReadHSV("7F7F7F")[3])
			generated_ribbon_color = "#FF0000"

		//Set layers to these colors, base then ribbon
		set_greyscale(colors = list(generated_base_color, generated_ribbon_color))

/obj/item/stack/wrapping_paper/attack_self(mob/user)
	var/new_base = input(user, "", "Select a base color", color) as color
	var/new_ribbon = input(user, "", "Select a ribbon color", color) as color
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	set_greyscale(colors = list(new_base, new_ribbon))
	return TRUE

//preset wrapping paper meant to fill the original color configuration
/obj/item/stack/wrapping_paper/xmas
	greyscale_colors = "#00FF00#FF0000"

/obj/item/stack/wrapping_paper/use(used, transfer)
	var/turf/T = get_turf(src)
	. = ..()
	if(QDELETED(src) && !transfer)
		new /obj/item/c_tube(T)


/*
 * Package Wrap
 */

/obj/item/stack/packageWrap
	name = "package wrapper"
	singular_name = "wrapping sheet"
	desc = "You can use this to wrap items in."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "deliveryPaper"
	item_flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	resistance_flags = FLAMMABLE

/obj/item/stack/packageWrap/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] begins wrapping [user.p_them()]self in \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if(use(3))
		var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(user.loc))
		P.icon_state = "deliverypackage5"
		user.forceMove(P)
		P.add_fingerprint(user)
		return OXYLOSS
	else
		to_chat(user, "<span class='warning'>You need more paper!</span>")
		return SHAME

/obj/item/proc/can_be_package_wrapped() //can the item be wrapped with package wrapper into a delivery package
	return 1

/obj/item/storage/can_be_package_wrapped()
	return 0

/obj/item/storage/box/can_be_package_wrapped()
	return 1

/obj/item/smallDelivery/can_be_package_wrapped()
	return 0

/obj/item/stack/packageWrap/afterattack(obj/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!istype(target))
		return
	if(target.anchored)
		return

	if(isitem(target))
		var/obj/item/I = target
		if(!I.can_be_package_wrapped())
			return
		if(user.is_holding(I))
			if(!user.dropItemToGround(I))
				return
		else if(!isturf(I.loc))
			return
		if(use(1))
			var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(get_turf(I.loc))
			if(user.Adjacent(I))
				P.add_fingerprint(user)
				I.add_fingerprint(user)
				user.put_in_hands(P)
			I.forceMove(P)
			var/size = round(I.w_class)
			P.name = "[weightclass2text(size)] parcel"
			P.w_class = size
			size = min(size, 5)
			P.icon_state = "deliverypackage[size]"

	else if(istype (target, /obj/structure/closet))
		var/obj/structure/closet/O = target
		if(O.opened)
			return
		if(!O.delivery_icon) //no delivery icon means unwrappable closet (e.g. body bags)
			to_chat(user, "<span class='warning'>You can't wrap this!</span>")
			return
		if(use(3))
			var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(O.loc))
			P.icon_state = O.delivery_icon
			O.forceMove(P)
			P.add_fingerprint(user)
			O.add_fingerprint(user)
		else
			to_chat(user, "<span class='warning'>You need more paper!</span>")
			return
	else
		to_chat(user, "<span class='warning'>The object you are trying to wrap is unsuitable for the sorting machinery!</span>")
		return

	user.visible_message("<span class='notice'>[user] wraps [target].</span>")
	user.log_message("has used [name] on [key_name(target)]", LOG_ATTACK, color="blue")

/obj/item/stack/packageWrap/use(used, transfer = FALSE)
	var/turf/T = get_turf(src)
	. = ..()
	if(QDELETED(src) && !transfer)
		new /obj/item/c_tube(T)

/obj/item/c_tube
	name = "cardboard tube"
	desc = "A tube... of cardboard."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "c_tube"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 5
