/*
 * Contents:
 *		Welding mask
 *		Cakehat
 *		Ushanka
 *		Pumpkin head
 *		Kitty ears
 *		Cardborg disguise
 *		Wig
 *		Bronze hat
 */

/obj/item/clothing/head/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	item_state = "welding"
	clothing_flags = SNUG_FIT
	materials = list(/datum/material/iron = 1750, /datum/material/glass = 400)
	flash_protect = 2
	tint = 2
	armor = list(MELEE = 10,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 60, STAMINA = 5)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	actions_types = list(/datum/action/item_action/toggle)
	visor_flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/welding/attack_self(mob/user)
	weldingvisortoggle(user)

/*
 * Cakehat
 */
/obj/item/clothing/head/hardhat/cakehat
	name = "cakehat"
	desc = "You put the cake on your head. Brilliant."
	icon_state = "hardhat0_cakehat"
	item_state = "hardhat0_cakehat"
	hat_type = "cakehat"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	hitsound = 'sound/weapons/tap.ogg'
	flags_inv = HIDEEARS|HIDEHAIR
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 0)
	light_range = 2 //luminosity when on
	flags_cover = HEADCOVERSEYES
	heat = 1000 //use round numbers, guh

	dog_fashion = /datum/dog_fashion/head

	var/force_on = 12
	var/throwforce_on = 12
	var/damtype_on = BURN
	var/hitsound_on = 'sound/weapons/sear.ogg' //so we can differentiate between cakehat and energyhat

/obj/item/clothing/head/hardhat/cakehat/process()
	var/turf/location = loc
	if(ishuman(location))
		var/mob/living/carbon/human/M = location
		if(M.is_holding(src) || M.head == src)
			location = M.loc

	if(isturf(location))
		location.hotspot_expose(700, 1)

/obj/item/clothing/head/hardhat/cakehat/turn_on(mob/living/user)
	force = force_on
	throwforce = throwforce_on
	damtype = damtype_on
	hitsound = hitsound_on
	START_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/head/hardhat/cakehat/turn_off(mob/living/user)
	force = initial(force)
	throwforce = initial(throwforce)
	damtype = initial(damtype)
	hitsound = initial(hitsound)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/head/hardhat/cakehat/is_hot()
	return on * heat

/obj/item/clothing/head/hardhat/cakehat/energycake
	name = "energy cake"
	desc = "You put the energy sword on your cake. Brilliant."
	icon_state = "hardhat0_energycake"
	item_state = "hardhat0_energycake"
	hat_type = "energycake"
	hitsound = 'sound/weapons/tap.ogg'
	hitsound_on = 'sound/weapons/blade1.ogg'
	damtype_on = BRUTE
	force_on = 18 //same as epen (but much more obvious)
	light_range = 3 //ditto
	heat = 0

/obj/item/clothing/head/hardhat/cakehat/energycake/turn_on(mob/living/user)
	playsound(user, 'sound/weapons/saberon.ogg', 5, TRUE)
	to_chat(user, "<span class='warning'>You turn on \the [src].</span>")
	return ..()

/obj/item/clothing/head/hardhat/cakehat/energycake/turn_off(mob/living/user)
	playsound(user, 'sound/weapons/saberoff.ogg', 5, TRUE)
	to_chat(user, "<span class='warning'>You turn off \the [src].</span>")
	return ..()
/*
 * Ushanka
 */
/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon_state = "ushankadown"
	item_state = "ushankadown"
	flags_inv = HIDEEARS|HIDEHAIR
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	dog_fashion = /datum/dog_fashion/head/ushanka
	//Are the flaps down?
	var/earflaps_down = TRUE

/obj/item/clothing/head/ushanka/attack_self(mob/user)
	if(earflaps_down)
		icon_state = "ushankaup"
		item_state = "ushankaup"
		earflaps_down = FALSE
		to_chat(user, "<span class='notice'>You raise the ear flaps on the ushanka.</span>")
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		earflaps_down = TRUE
		to_chat(user, "<span class='notice'>You lower the ear flaps on the ushanka.</span>")

/*
 * Pumpkin head
 */
/obj/item/clothing/head/hardhat/pumpkinhead
	name = "carved pumpkin"
	desc = "A jack o' lantern! Believed to ward off evil spirits."
	icon_state = "hardhat0_pumpkin"
	item_state = "hardhat0_pumpkin"
	hat_type = "pumpkin"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	clothing_flags = SNUG_FIT
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 10)
	light_range = 2 //luminosity when on
	flags_cover = HEADCOVERSEYES

/*
 * Kitty ears
 */
/obj/item/clothing/head/kitty
	name = "kitty ears"
	desc = "A pair of kitty ears. Meow!"
	icon_state = "kitty"
	clothing_flags = SNUG_FIT
	color = "#999999"
	dynamic_hair_suffix = ""

	dog_fashion = /datum/dog_fashion/head/kitty

/obj/item/clothing/head/kitty/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/haircolor_clothing)

/obj/item/clothing/head/kitty/genuine
	desc = "A pair of kitty ears. A tag on the inside says \"Hand made from real cats.\""

/obj/item/clothing/head/hardhat/reindeer
	name = "novelty reindeer hat"
	desc = "Some fake antlers and a very fake red nose."
	clothing_flags = SNUG_FIT
	icon_state = "hardhat0_reindeer"
	item_state = "hardhat0_reindeer"
	hat_type = "reindeer"
	flags_inv = 0
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 0)
	light_range = 1 //luminosity when on
	dynamic_hair_suffix = ""

	dog_fashion = /datum/dog_fashion/head/reindeer

/*
	Rabbit ears
*/

/obj/item/clothing/head/rabbitears
	name = "rabbit ears"
	desc = "Wearing these makes you look useless, and only good for your sex appeal."
	icon_state = "bunny"
	clothing_flags = SNUG_FIT
	dynamic_hair_suffix = ""

	dog_fashion = /datum/dog_fashion/head/rabbit

/obj/item/clothing/head/rabbitears/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/haircolor_clothing)

/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	item_state = "cardborg_h"
	clothing_flags = SNUG_FIT
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

	dog_fashion = /datum/dog_fashion/head/cardborg

/obj/item/clothing/head/cardborg/equipped(mob/living/user, slot)
	..()
	if(ishuman(user) && slot == ITEM_SLOT_HEAD)
		var/mob/living/carbon/human/H = user
		if(istype(H.wear_suit, /obj/item/clothing/suit/cardborg))
			var/obj/item/clothing/suit/cardborg/CB = H.wear_suit
			CB.disguise(user, src)

/obj/item/clothing/head/cardborg/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("standard_borg_disguise")

/obj/item/clothing/head/wig
	name = "wig"
	desc = "A bunch of hair without a head attached."
	icon = 'icons/mob/human_face.dmi'	  // default icon for all hairs
	icon_state = "hair_vlong"
	item_state = "pwig"
	flags_inv = HIDEHAIR	//Instead of being handled as a clothing item, it overrides the hair values in /datum/species/proc/handle_hair
	slot_flags = ITEM_SLOT_HEAD
	worn_icon = 'icons/mob/human_face.dmi'
	worn_icon_state = "bald"
	var/hair_style = "Very Long Hair"
	var/hair_color = "#000"
	var/gradient_style = "None"
	var/gradient_color = "000"
	var/adjustablecolor = TRUE //can color be changed manually?
	strip_delay = 10 //It's fake hair, can't be too hard to just grab and pull it off
	var/obj/item/clothing/head/hat_attached_to = null

/obj/item/clothing/head/wig/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/clothing/head/wig/Destroy()
	. = ..()
	if(hat_attached_to)
		hat_attached_to.attached_wig = null

/obj/item/clothing/head/wig/dropped(mob/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.head == src)
			H.update_inv_head()

/obj/item/clothing/head/wig/update_icon()
	cut_overlays()
	var/datum/sprite_accessory/S = GLOB.hair_styles_list[hair_style]
	if(!S)
		icon_state = "pwig"
	else
		var/mutable_appearance/M = mutable_appearance(S.icon,S.icon_state)
		M.appearance_flags |= RESET_COLOR
		M.color = hair_color
		add_overlay(M)

/obj/item/clothing/head/wig/attack_self(mob/user)
	var/new_style = input(user, "Select a hair style", "Wig Styling")  as null|anything in (GLOB.hair_styles_list - "Bald")
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(new_style && new_style != hair_style)
		hair_style = new_style
		user.visible_message("<span class='notice'>[user] changes \the [src]'s hairstyle to [new_style].</span>", "<span class='notice'>You change \the [src]'s hairstyle to [new_style].</span>")
	if(adjustablecolor)
		hair_color = input(usr,"","Choose Color",hair_color) as color|null
		var/picked_gradient_style
		picked_gradient_style = input(usr, "", "Choose Gradient")  as null|anything in GLOB.hair_gradients_list
		if(picked_gradient_style)
			gradient_style = picked_gradient_style
			if(gradient_style != "None")
				var/picked_hair_gradient = input(user, "", "Choose Gradient Color", "#" + gradient_color) as color|null
				if(picked_hair_gradient)
					gradient_color = sanitize_hexcolor(picked_hair_gradient)
				else
					gradient_color = "000"
			else
				gradient_color = "000"
		else
			gradient_style = "None"
			gradient_color = "000"

	update_icon()

/obj/item/clothing/head/wig/random/Initialize(mapload)
	. = ..()

	hair_style = pick(GLOB.hair_styles_list - "Bald") //Don't want invisible wig
	hair_color = "#[random_short_color()]"

/obj/item/clothing/head/wig/natural
	name = "natural wig"
	desc = "A bunch of hair without a head attached. This one changes color to match the hair of the wearer. Nothing natural about that."
	hair_color = "#FFF"
	adjustablecolor = FALSE
	custom_price = 25

/obj/item/clothing/head/wig/natural/Initialize(mapload)
	hair_style = pick(GLOB.hair_styles_list - "Bald")
	. = ..()

/obj/item/clothing/head/wig/natural/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(ishuman(user) && (slot == ITEM_SLOT_HEAD || slot == ITEM_SLOT_NECK))
		hair_color = "#[user.hair_color]"
		gradient_style = user.gradient_style
		gradient_color = "#[user.gradient_color]"
		update_icon()

/obj/item/clothing/head/bronze
	name = "bronze hat"
	desc = "A crude helmet made out of bronze plates. It offers very little in the way of protection."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_helmet_old"
	flags_inv = HIDEEARS|HIDEHAIR
	armor = list(MELEE = 5,  BULLET = 0, LASER = -5, ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 20, ACID = 20, STAMINA = 30)

/obj/item/clothing/head/foilhat
	name = "tinfoil hat"
	desc = "Thought control rays, psychotronic scanning. Don't mind that, I'm protected cause I made this hat."
	icon_state = "foilhat"
	item_state = "foilhat"
	clothing_flags = EFFECT_HAT | SNUG_FIT
	armor = list(MELEE = 0,  BULLET = 0, LASER = -5, ENERGY = 0, BOMB = 0, BIO = 0, RAD = -5, FIRE = 0, ACID = 0, STAMINA = 50)
	equip_delay_other = 140
	var/datum/brain_trauma/mild/phobia/conspiracies/paranoia

/obj/item/clothing/head/foilhat/equipped(mob/living/carbon/human/user, slot)
	..()
	user.sec_hud_set_implants()
	if(slot == ITEM_SLOT_HEAD)
		if(paranoia)
			QDEL_NULL(paranoia)
		paranoia = new()
		DISABLE_BITFIELD(paranoia.trauma_flags, TRAUMA_CLONEABLE)

		user.gain_trauma(paranoia, TRAUMA_RESILIENCE_MAGIC)
		to_chat(user, "<span class='warning'>As you don the foiled hat, an entire world of conspiracy theories and seemingly insane ideas suddenly rush into your mind. What you once thought unbelievable suddenly seems.. undeniable. Everything is connected and nothing happens just by accident. You know too much and now they're out to get you. </span>")

/obj/item/clothing/head/foilhat/MouseDrop(atom/over_object)
	//God Im sorry
	if(usr)
		var/mob/living/carbon/C = usr
		if(src == C.head)
			to_chat(C, "<span class='userdanger'>Why would you want to take this off? Do you want them to get into your mind?!</span>")
			return
	return ..()

/obj/item/clothing/head/foilhat/dropped(mob/user)
	..()
	if(paranoia)
		QDEL_NULL(paranoia)
	if(isliving(user))
		var/mob/living/L = user
		L.sec_hud_set_implants()

/obj/item/clothing/head/foilhat/attack_hand(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.head)
			to_chat(user, "<span class='userdanger'>Why would you want to take this off? Do you want them to get into your mind?!</span>")
			return
	return ..()

/obj/item/clothing/head/foilhat/plasmaman
	name = "tinfoil envirosuit helmet"
	desc = "The Syndicate is a hoax! Dogs are fake! Space Station 13 is just a money laundering operation! See the truth!"
	icon_state = "tinfoil_envirohelm"
	item_state = "tinfoil_envirohelm"
	strip_delay = 150
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | EFFECT_HAT | SNUG_FIT
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 0, FIRE = 50, ACID = 50, STAMINA = 50)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	light_system = MOVABLE_LIGHT
	light_range = 4
	light_power = 1
	light_on = TRUE
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	dynamic_hair_suffix = ""
	dynamic_fhair_suffix = ""
	flash_protect = 2
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	bang_protect = 1 //make this consistent with other plasmaman helmets
	resistance_flags = NONE
	dog_fashion = null
	///Is the light on?
	var/on = FALSE

/obj/item/clothing/head/foilhat/plasmaman/attack_self(mob/user)
	on = !on
	icon_state = "[initial(icon_state)][on ? "-light":""]"
	item_state = icon_state
	user.update_inv_head() //So the mob overlay updates

	if(on)
		set_light(TRUE)
	else
		set_light(FALSE)

	for(var/X in actions)
		var/datum/action/A=X
		A.UpdateButtonIcon()

/obj/item/clothing/head/speedwagon
	name = "hat of ultimate masculinity"
	desc = "Even the mere act of wearing this makes you want to pose menacingly."
	worn_icon = 'icons/mob/large-worn-icons/64x64/head.dmi'
	icon_state = "speedwagon"
	item_state = "speedwagon"
	worn_x_dimension = 64
	worn_y_dimension = 64

/obj/item/clothing/head/speedwagon/cursed
	name = "ULTIMATE HAT"
	desc = "You feel weak and pathetic in comparison to this exceptionally beautiful hat."
	icon_state = "speedwagon_cursed"
	item_state = "speedwagon_cursed"

/obj/item/clothing/head/franks_hat
	name = "Frank's Hat"
	desc = "You feel ashamed about what you had to do to get this hat"
	icon_state = "cowboy"
	item_state = "cowboy"
