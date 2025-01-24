/obj/item/implantcase
	name = "implant case"
	desc = "A glass case containing an implant."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "implantcase-0"
	item_state = "implantcase"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/glass=500)
	var/obj/item/implant/imp = null
	var/imp_type


/obj/item/implantcase/update_icon_state()
	icon_state = "implantcase-[imp ? imp.implant_color : 0]"
	return ..()

/obj/item/implantcase/attackby(obj/item/used_item, mob/living/user, params)
	if(istype(used_item, /obj/item/pen))
		if(!user.is_literate())
			to_chat(user, "<span class='notice'>You scribble illegibly on the side of [src]!</span>")
			return
		var/new_name = stripped_input(user, "What would you like the label to be?", name, null)
		if(user.get_active_held_item() != used_item)
			return
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(new_name)
			name = "implant case - '[new_name]'"
		else
			name = "implant case"
	else if(istype(used_item, /obj/item/implanter))
		var/obj/item/implanter/used_implanter = used_item
		if(used_implanter.imp && !imp)
			used_implanter.imp.forceMove(src)
			imp = used_implanter.imp
			used_implanter.imp = null
			update_appearance()
			reagents = imp.reagents
			used_implanter.update_appearance()
		else if(!used_implanter.imp && imp)
			imp.forceMove(used_implanter)
			used_implanter.imp = imp
			imp = null
			reagents = null
			update_appearance()
			used_implanter.update_appearance()
	else
		return ..()

/obj/item/implantcase/Initialize(mapload)
	. = ..()
	if(imp_type)
		imp = new imp_type(src)
	update_appearance()
	if(imp)
		reagents = imp.reagents


/obj/item/implantcase/tracking
	name = "implant case - 'Tracking'"
	desc = "A glass case containing a tracking implant."
	imp_type = /obj/item/implant/tracking

/obj/item/implantcase/weapons_auth
	name = "implant case - 'Firearms Authentication'"
	desc = "A glass case containing a firearms authentication implant."
	imp_type = /obj/item/implant/weapons_auth

/obj/item/implantcase/adrenaline
	name = "implant case - 'Adrenaline'"
	desc = "A glass case containing an adrenaline implant."
	imp_type = /obj/item/implant/adrenalin
