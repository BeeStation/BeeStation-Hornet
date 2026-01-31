/obj/item/clothing/head/utility
	icon = 'icons/obj/clothing/head/utility.dmi'
	worn_icon = 'icons/mob/clothing/head/utility.dmi'

/obj/item/clothing/head/utility/hardhat
	name = "hard hat"
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight."
	icon_state = "hardhat0_yellow"
	inhand_icon_state = null
	armor_type = /datum/armor/utility_hardhat
	flags_inv = NONE
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	resistance_flags = FIRE_PROOF
	clothing_flags = SNUG_FIT | STACKABLE_HELMET_EXEMPT

	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 4
	light_power = 0.8
	light_on = FALSE
	dog_fashion = /datum/dog_fashion/head

	///Determines used sprites: hardhat[on]_[hat_type] and hardhat[on]_[hat_type]2 (lying down sprite). This is basically a knockoff item_color, great.
	var/hat_type = "yellow"
	///Whether the headlamp is on or off.
	var/on = FALSE


/datum/armor/utility_hardhat
	melee = 15
	bullet = 5
	laser = 20
	energy = 10
	bomb = 20
	bio = 50
	fire = 100
	acid = 50
	stamina = 20
	bleed = 60

/obj/item/clothing/head/utility/hardhat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/clothing/head/utility/hardhat/attack_self(mob/living/user)
	toggle_helmet_light(user)

/obj/item/clothing/head/utility/hardhat/proc/toggle_helmet_light(mob/living/user)
	on = !on
	if(on)
		turn_on(user)
	else
		turn_off(user)
	update_appearance()

/obj/item/clothing/head/utility/hardhat/update_icon_state()
	icon_state = inhand_icon_state = "hardhat[on]_[hat_type]"
	return ..()

/obj/item/clothing/head/utility/hardhat/proc/turn_on(mob/user)
	set_light_on(TRUE)

/obj/item/clothing/head/utility/hardhat/proc/turn_off(mob/user)
	set_light_on(FALSE)

/obj/item/clothing/head/utility/hardhat/orange
	icon_state = "hardhat0_orange"
	inhand_icon_state = null
	hat_type = "orange"
	dog_fashion = null

/obj/item/clothing/head/utility/hardhat/red
	name = "firefighter helmet"
	desc = "A helmet designed to be used in very hot, high pressure areas."
	icon_state = "hardhat0_red"
	inhand_icon_state = null
	hat_type = "red"
	dog_fashion = null
	clothing_flags = STOPSPRESSUREDAMAGE | STACKABLE_HELMET_EXEMPT
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	cold_protection = HEAD
	heat_protection = HEAD
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT|HIDEMASK
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH


/obj/item/clothing/head/utility/hardhat/white
	name = "white hard hat"
	desc = "It's a hard hat, but painted white. Probably belongs to the Chief Engineer. Looks a little more solid."
	icon_state = "hardhat0_white"
	inhand_icon_state = null
	hat_type = "white"
	clothing_flags = STOPSPRESSUREDAMAGE | STACKABLE_HELMET_EXEMPT
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	cold_protection = HEAD
	heat_protection = HEAD
	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/head/utility/hardhat/dblue
	icon_state = "hardhat0_dblue"
	inhand_icon_state = null
	hat_type = "dblue"
	dog_fashion = null

/obj/item/clothing/head/utility/hardhat/atmos
	name = "atmospheric technician's firefighting helmet"
	desc = "A firefighter's helmet, able to keep the user cool in any situation."
	icon_state = "hardhat0_atmos"
	inhand_icon_state = "hardhat0_atmos"
	hat_type = "atmos"
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | BLOCK_GAS_SMOKE_EFFECT | SNUG_FIT  | HEADINTERNALS
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	cold_protection = HEAD
	heat_protection = HEAD
	dog_fashion = null

/obj/item/clothing/head/utility/hardhat/welding
	name = "welding hard hat"
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight AND welding shield! The bulb seems a little smaller though."
	light_range = 3 //Needs a little bit of tradeoff
	dog_fashion = null
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_welding_screen)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	flags_inv = HIDEEYES | HIDEFACE | HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	visor_flags_inv = HIDEEYES | HIDEFACE | HIDESNOUT
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	///Icon state of the welding visor.
	var/visor_state = "weldvisor"

/obj/item/clothing/head/utility/hardhat/welding/attack_self_secondary(mob/user, modifiers)
	adjust_visor(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/head/utility/hardhat/welding/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_welding_screen))
		adjust_visor(user)
		return
	return ..()

/obj/item/clothing/head/utility/hardhat/welding/adjust_visor(mob/living/user)
	. = ..()
	if(.)
		playsound(src, 'sound/mecha/mechmove03.ogg', 50, TRUE)

/obj/item/clothing/head/utility/hardhat/welding/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, item_layer, atom/origin)
	. = ..()
	if(isinhands)
		return

	if(!up)
		. += mutable_appearance('icons/mob/clothing/head/utility.dmi', visor_state)

/obj/item/clothing/head/utility/hardhat/welding/update_overlays()
	. = ..()
	if(!up)
		. += visor_state

/obj/item/clothing/head/utility/hardhat/welding/orange
	icon_state = "hardhat0_orange"
	inhand_icon_state = null
	hat_type = "orange"

/obj/item/clothing/head/utility/hardhat/welding/white
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight AND welding shield!" //This bulb is not smaller
	icon_state = "hardhat0_white"
	inhand_icon_state = "hardhat0_white"
	light_range = 4 //Boss always takes the best stuff
	hat_type = "white"
	clothing_flags = STOPSPRESSUREDAMAGE | STACKABLE_HELMET_EXEMPT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT

/obj/item/clothing/head/utility/hardhat/pumpkinhead
	name = "carved pumpkin"
	desc = "A jack o' lantern! Believed to ward off evil spirits."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "hardhat0_pumpkin"
	inhand_icon_state = null
	hat_type = "pumpkin"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	clothing_flags = SNUG_FIT
	armor_type = /datum/armor/hardhat_pumpkinhead
	light_range = 2 //luminosity when on
	flags_cover = HEADCOVERSEYES


/datum/armor/hardhat_pumpkinhead
	stamina = 10

/obj/item/clothing/head/utility/hardhat/reindeer
	name = "novelty reindeer hat"
	desc = "Some fake antlers and a very fake red nose."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	clothing_flags = SNUG_FIT
	icon_state = "hardhat0_reindeer"
	inhand_icon_state = null
	hat_type = "reindeer"
	flags_inv = 0
	armor_type = /datum/armor/none
	light_range = 1 //luminosity when on


	dog_fashion = /datum/dog_fashion/head/reindeer
