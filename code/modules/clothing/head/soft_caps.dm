/obj/item/clothing/head/soft
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white colour."
	icon = 'icons/obj/clothing/head/hats.dmi'
	worn_icon = 'icons/mob/clothing/head/hats.dmi'
	icon_state = "mimesoft"
	dying_key = DYE_REGISTRY_CAP

	///Is the hat flipped?
	var/flipped = FALSE
	///Is the hat flippable?
	var/flippable = TRUE
	///The color of the hat. Another knockoff item_color. Nice. Make this into GAGS sprites at some point, please.
	var/soft_color = "mime"

/obj/item/clothing/head/soft/AltClick(mob/user)
	..()
	if(user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		flip(user)

/obj/item/clothing/head/soft/proc/flip(mob/user)
	if(!user.incapacitated() && flippable == TRUE)
		flipped = !flipped
		if(flipped)
			icon_state = "[soft_color]soft_flipped"
			to_chat(user, span_notice("You flip the hat backwards."))
		else
			icon_state = "[soft_color]soft"
			to_chat(user, span_notice("You flip the hat back in normal position."))
		user.update_worn_head()	//so our mob-overlays update

/obj/item/clothing/head/soft/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD && HAS_TRAIT(user, TRAIT_PROSKATER) && !flipped)
		flip(user)

/obj/item/clothing/head/soft/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click the cap to flip it [flipped ? "forwards" : "backwards"].")

/obj/item/clothing/head/soft/red
	name = "red cap"
	desc = "It's a baseball hat in a tasteless red colour."
	icon_state = "redsoft"
	soft_color = "red"

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	desc = "It's a baseball hat in a tasteless blue colour."
	icon_state = "bluesoft"
	soft_color = "blue"

/obj/item/clothing/head/soft/green
	name = "green cap"
	desc = "It's a baseball hat in a tasteless green colour."
	icon_state = "greensoft"
	soft_color = "green"

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "yellowsoft"
	soft_color = "yellow"

/obj/item/clothing/head/soft/grey
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon_state = "greysoft"
	soft_color = "grey"

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	desc = "It's a baseball hat in a tasteless orange colour."
	icon_state = "orangesoft"
	soft_color = "orange"

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	desc = "It's a baseball hat in a tasteless purple colour."
	icon_state = "purplesoft"
	soft_color = "purple"

/obj/item/clothing/head/soft/black
	name = "black cap"
	desc = "It's a baseball hat in a tasteless black colour."
	icon_state = "blacksoft"
	soft_color = "black"

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	desc = "It's a baseball hat in a bright rainbow of colors."
	icon_state = "rainbowsoft"
	soft_color = "rainbow"

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's a robust baseball hat in tasteful red colour."
	icon_state = "secsoft"
	soft_color = "sec"
	armor_type = /datum/armor/soft_sec
	strip_delay = 60
	custom_price = 30


/datum/armor/soft_sec
	melee = 30
	bullet = 25
	laser = 25
	energy = 10
	bomb = 25
	fire = 20
	acid = 50
	stamina = 30
	bleed = 10

/obj/item/clothing/head/soft/sec/brig_physician
	name = "security medic cap"
	icon_state = "secmedsoft"
	soft_color = "secmed"

/obj/item/clothing/head/soft/paramedic
	name = "paramedic cap"
	desc = "It's a baseball hat with a dark turquoise color and a reflective cross on the top."
	icon_state = "paramedicsoft"
	soft_color = "paramedic"
	dog_fashion = null

/obj/item/clothing/head/soft/cargo
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "cargosoft"
	soft_color = "cargo"

	dog_fashion = /datum/dog_fashion/head/cargo_tech

/obj/item/clothing/head/soft/denied
	name = "ERROR cap"
	desc = "It's a baseball hat in a tasteless ERROR ERROR ERROR ERROR ERROR ERROR!!!!"
	icon_state = "deniedsoft"
