/obj/structure/doormat
	density = FALSE
	anchored = TRUE
	name = "doormat"
	icon = 'icons/obj/doormat.dmi'
	icon_state = "base"
	desc = "Walked all over."
	max_integrity = 200
	///Overlay we'll throw on-top
	var/welcome_icon = ""

/obj/structure/doormat/Initialize(mapload)
	var/mutable_appearance/overlay = mutable_appearance(icon, welcome_icon)
	overlay.dir = dir
	add_overlay(overlay)

/obj/structure/doormat/clown
	welcome_icon = "clown"

/obj/structure/doormat/cmo
	welcome_icon = "cmo"

/obj/structure/doormat/hos
	welcome_icon = "hos"

/obj/structure/doormat/rd
	welcome_icon = "rd"

/obj/structure/doormat/hop
	welcome_icon = "hop"

/obj/structure/doormat/cap
	welcome_icon = "cap"

/obj/structure/doormat/ce
	welcome_icon = "ce"
