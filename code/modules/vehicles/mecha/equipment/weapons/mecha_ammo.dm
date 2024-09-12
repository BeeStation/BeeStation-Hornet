/obj/item/mecha_ammo
	name = "generic ammo box"
	desc = "A box of ammo for an unknown weapon."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'icons/mecha/mecha_ammo.dmi'
	icon_state = "empty"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	var/rounds = 0
	var/round_term = "round"
	var/direct_load //For weapons where we re-load the weapon itself rather than adding to the ammo storage.
	var/load_audio = 'sound/weapons/bulletinsert.ogg'
	var/ammo_type

/obj/item/mecha_ammo/update_name()
	. = ..()
	name = "[rounds ? null : "empty "][initial(name)]"

/obj/item/mecha_ammo/update_desc()
	. = ..()
	desc = rounds ? initial(desc) : "An exosuit ammuniton box that has since been emptied. It can be safely folded for recycling."

/obj/item/mecha_ammo/update_icon_state()
	icon_state = rounds ? initial(icon_state) : "empty"
	return ..()

/obj/item/mecha_ammo/attack_self(mob/user)
	..()
	if(rounds)
		to_chat(user, "<span class='warning'>You cannot flatten the ammo box until it's empty!</span>")
		return

	to_chat(user, "<span class='notice'>You fold [src] flat.</span>")
	var/trash = new /obj/item/stack/sheet/iron(user.loc)
	qdel(src)
	user.put_in_hands(trash)

/obj/item/mecha_ammo/examine(mob/user)
	. = ..()
	if(rounds)
		. += "There [rounds > 1?"are":"is"] [rounds] [round_term][rounds > 1?"s":""] left."
	else
		. += "<span class='notice'>Use in-hand to fold it into a sheet of iron.</span>"

/obj/item/mecha_ammo/incendiary
	name = "incendiary ammo box"
	desc = "A box of incendiary ammunition for use with exosuit weapons."
	icon_state = "incendiary"
	custom_materials = list(/datum/material/iron=6000)
	rounds = 24
	ammo_type = "incendiary"

/obj/item/mecha_ammo/scattershot
	name = "scattershot ammo box"
	desc = "A box of scaled-up buckshot, for use in exosuit shotguns."
	icon_state = "scattershot"
	custom_materials = list(/datum/material/iron=6000)
	rounds = 40
	ammo_type = "scattershot"

/obj/item/mecha_ammo/lmg
	name = "machine gun ammo box"
	desc = "A box of linked ammunition, designed for the Ultra AC 2 exosuit weapon."
	icon_state = "lmg"
	custom_materials = list(/datum/material/iron = 4000)
	rounds = 300
	ammo_type = "lmg"

/obj/item/mecha_ammo/missiles_br
	name = "breaching missiles"
	desc = "A box of large missiles, ready for loading into a BRM-6 exosuit missile rack."
	icon_state = "missile_br"
	custom_materials = list(/datum/material/iron=8000,/datum/material/gold=500)
	rounds = 6
	round_term = "missile"
	direct_load = TRUE
	load_audio = 'sound/weapons/bulletinsert.ogg'
	ammo_type = "missiles_br"

/obj/item/mecha_ammo/missiles_he
	name = "anti-armor missiles"
	desc = "A box of large missiles, ready for loading into an SRM-8 exosuit missile rack."
	icon_state = "missile_he"
	rounds = 8
	round_term = "missile"
	direct_load = TRUE
	load_audio = 'sound/weapons/bulletinsert.ogg'
	ammo_type = "missiles_he"


/obj/item/mecha_ammo/flashbang
	name = "launchable flashbangs"
	desc = "A box of smooth flashbangs, for use with a large exosuit launcher. Cannot be primed by hand."
	icon_state = "flashbang"
	rounds = 6
	round_term = "grenade"
	ammo_type = "flashbang"

/obj/item/mecha_ammo/clusterbang
	name = "launchable flashbang clusters"
	desc = "A box of clustered flashbangs, for use with a specialized exosuit cluster launcher. Cannot be primed by hand."
	icon_state = "clusterbang"
	custom_materials = list(/datum/material/iron=6000,/datum/material/gold=1500,/datum/material/uranium=1500)
	rounds = 3
	round_term = "cluster"
	direct_load = TRUE
	ammo_type = "clusterbang"
