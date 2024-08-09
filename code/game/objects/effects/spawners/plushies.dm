/obj/effect/spawner/sillycons
	name = "Indecisive Cyborg"
	desc = "This one doesn't seem to have decided what to be yet, please be nice to them."
	icon = 'icons/obj/plushes.dmi'
	icon_state = "borgplush"

/obj/effect/spawner/sillycons/Initialize(mapload)
	..()
	var/random_sillycon = pick(subtypesof(/obj/item/toy/plush/sillycons/))
	new random_sillycon(loc)
	return INITIALIZE_HINT_QDEL
