//Scanner item for the prisoners to redeem sentence time for their work in the workshop

/obj/item/prison_scanner
	name = "prison export scanner"
	desc = "A device used to check objects made in the workshop, to have them cashed out for sentence reductions."
	icon = 'icons/obj/device.dmi'
	icon_state = "export_scanner"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	siemens_coefficient = 1
	var/obj/item/prison_scanner/linked_id = null //Which prisoner ID is linked to this scanner
	var/list/redeemable = list() //Items ready to be redeemed

/obj/item/prison_scanner/examine(mob/user)
	. = ..()
	if(linked_id)
		. += "<span class='notice'>[src] is currently linked with [linked_id]'s ID card</span>."
	if(!linked_id)
		. += "<span class='notice'>[src] is currently unlinked</span>."

/obj/item/prison_scanner/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/card/id/prisoner))
		var/obj/item/card/id/prisoner/C = I
		if(!linked_id)
			linked_id = C.registered_name
			to_chat(user, "<span class='notice'>Scanner linked to [C.registered_name] succesfully!</span>")
		if(linked_id != C.registered_name)
			to_chat(user, "<span class='warning'>The scanner is already linked to [linked_id]'s ID!</span>")
		else if(redeemable.len>=1)
			C.served_time += (15 * redeemable.len)
			redeemable.Cut()
			to_chat(user, "<span class='notice'>Items redeemed! You now have [(C.sentence - C.served_time)/60] minutes left to serve!</span>")
			linked_id = null
		else
			to_chat(user, "<span class='warning'> No items to redeem!</span>")
	else
		. = ..()

/obj/item/prison_scanner/afterattack(obj/O, mob/user, proximity)
	. = ..()
	if(!linked_id)
		to_chat(user, "<span class='warning'>No linked account!</span>")
	else if(!istype(O, /obj/item/food/donut) && !istype(O, /mob/living/simple_animal/bot))
		to_chat(user, "<span class='warning'>Invalid item! Only scan donuts or bots made in the workshop!</span>")
	else
		if(istype(O, /mob/living/simple_animal/bot))
			var/mob/living/simple_animal/bot/B = O
			if(B.scanned == TRUE)
				to_chat(user, "<span class='warning'>[B.name] has been scanned already!</span>")
			else
				B.scanned = TRUE
				redeemable += B
				to_chat(user, "<span class='notice'>[B.name] has been scanned succesfully!</span>")
		else if(O.obj_flags & SCANNED)
			to_chat(user, "<span class='warning'>The [O.name] has been scanned already!</span>")
		else
			redeemable += O
			O.obj_flags |= SCANNED
			to_chat(user, "<span class='notice'>The [O.name] has been scanned succesfully!</span>")
