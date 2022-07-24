/obj/item/gun/energy/vortex
	name = "vortex rifle"
	desc = "A powerful rifle of alien origin that fires powerful energy darts."
	icon_state = "vortex"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/vortex)

/obj/item/gun/energy/vortex/examine(mob/user)
	. = ..()
	if(isabductor(user))
		. += "<span class='abductor'>This shouldn't be here... It's not from this era...</span>"
