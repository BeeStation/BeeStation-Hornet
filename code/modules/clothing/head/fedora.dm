/obj/item/clothing/head/fedora
	name = "fedora"
	icon_state = "fedora"
	icon = 'icons/obj/clothing/head/hats.dmi'
	worn_icon = 'icons/mob/clothing/head/hats.dmi'
	inhand_icon_state = "fedora"
	desc = "A really cool hat if you're a mobster. A really lame hat if you're not."

/obj/item/clothing/head/fedora/Initialize(mapload)
	. = ..()
	if(!istype(atom_storage))
		create_storage(storage_type = /datum/storage/pockets/small/fedora)

/obj/item/clothing/head/fedora/suicide_act(mob/living/user)
	if(user.gender == FEMALE)
		return
	var/mob/living/carbon/human/H = user
	user.visible_message(span_suicide("[user] is donning [src]! It looks like [user.p_theyre()] trying to be nice to girls."))
	user.say("M'lady.", forced = "fedora suicide")
	sleep(10)
	H.facial_hair_style = "Neckbeard"
	return BRUTELOSS
