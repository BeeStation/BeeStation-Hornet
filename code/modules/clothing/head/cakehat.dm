/obj/item/clothing/head/utility/hardhat/cakehat
	name = "cakehat"
	desc = "You put the cake on your head. Brilliant."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "hardhat0_cakehat"
	inhand_icon_state = "hardhat0_cakehat"
	hat_type = "cakehat"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	hitsound = 'sound/weapons/tap.ogg'
	flags_inv = HIDEEARS|HIDEHAIR
	armor_type = /datum/armor/none
	light_range = 2 //luminosity when on
	flags_cover = HEADCOVERSEYES
	heat = 1000 //use round numbers, guh

	dog_fashion = /datum/dog_fashion/head

	var/force_on = 12
	var/throwforce_on = 12
	var/damtype_on = BURN
	var/hitsound_on = 'sound/weapons/sear.ogg' //so we can differentiate between cakehat and energyhat

/obj/item/clothing/head/utility/hardhat/cakehat/process()
	var/turf/location = loc
	if(ishuman(location))
		var/mob/living/carbon/human/M = location
		if(M.is_holding(src) || M.head == src)
			location = M.loc

	if(isturf(location))
		location.hotspot_expose(700, 1)

/obj/item/clothing/head/utility/hardhat/cakehat/turn_on(mob/living/user)
	force = force_on
	throwforce = throwforce_on
	damtype = damtype_on
	hitsound = hitsound_on
	START_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/head/utility/hardhat/cakehat/turn_off(mob/living/user)
	force = initial(force)
	throwforce = initial(throwforce)
	damtype = initial(damtype)
	hitsound = initial(hitsound)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/head/utility/hardhat/cakehat/get_temperature()
	return on * heat

/obj/item/clothing/head/utility/hardhat/cakehat/energycake
	name = "energy cake"
	desc = "You put the energy sword on your cake. Brilliant."
	icon_state = "hardhat0_energycake"
	inhand_icon_state = "hardhat0_energycake"
	hat_type = "energycake"
	hitsound = 'sound/weapons/tap.ogg'
	hitsound_on = 'sound/weapons/blade1.ogg'
	damtype_on = BRUTE
	force_on = 18 //same as epen (but much more obvious)
	light_range = 3 //ditto
	heat = 0

/obj/item/clothing/head/utility/hardhat/cakehat/energycake/turn_on(mob/living/user)
	playsound(user, 'sound/weapons/saberon.ogg', 5, TRUE)
	to_chat(user, span_warning("You turn on \the [src]."))
	return ..()

/obj/item/clothing/head/utility/hardhat/cakehat/energycake/turn_off(mob/living/user)
	playsound(user, 'sound/weapons/saberoff.ogg', 5, TRUE)
	to_chat(user, span_warning("You turn off \the [src]."))
	return ..()
