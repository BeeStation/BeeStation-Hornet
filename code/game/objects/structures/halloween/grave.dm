/obj/structure/grave
	name = "grave"
	desc = "Resting place for the dead, it would be rude to disturb them."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "grave"
	anchored = TRUE
	resistance_flags = NONE
	max_integrity = 250
	integrity_failure = 25
	move_resist = MOVE_FORCE_WEAK
	layer = OBJ_LAYER
	var/effigy = FALSE

/obj/structure/grave/effigy
	effigy = TRUE

/obj/structure/grave/Initialize()
	..()
	if(effigy)
		icon_state = "grave_effigy"
		desc += " There is a small effigy attached to the cross."
		update_icon()

/obj/structure/grave/attack_hand(mob/living/user)
	if(effigy)
		effigy = FALSE
		desc = initial(desc)
		icon_state = initial(icon_state)
		var/obj/item/toy/plush/effigy/doll = new(loc)
		user.put_in_hands(doll)
		to_chat(user, "<span class='notice'>You remove the effigy from [src].</span>")
		update_icon()
		return
	..()

/obj/item/toy/plush/effigy
	name = "wooden effigy"
	desc = "A small wooden doll taken from a grave. Holding it makes you feel safer for some reason."  //PROBABLY DOES NOTHING
	icon = 'icons/obj/fluff.dmi'
	icon_state = "effigy"
	divine = TRUE
	squeak_override = list('sound/misc/null.ogg'=1)
