/obj/item/clothing/head/utility
	icon = 'icons/obj/clothing/head/utility.dmi'
	worn_icon = 'icons/mob/clothing/head/utility.dmi'

/obj/item/clothing/head/utility/hardhat
	name = "hard hat"
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight."
	icon_state = "hardhat0_yellow"
	item_state = null
	armor = list(MELEE = 15,  BULLET = 5, LASER = 20, ENERGY = 10, BOMB = 20, BIO = 10, RAD = 20, FIRE = 100, ACID = 50, STAMINA = 20, BLEED = 60)
	flags_inv = NONE
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	resistance_flags = FIRE_PROOF
	clothing_flags = SNUG_FIT

	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 4
	light_power = 0.8
	light_on = FALSE
	dog_fashion = /datum/dog_fashion/head

	///Determines used sprites: hardhat[on]_[hat_type] and hardhat[on]_[hat_type]2 (lying down sprite). This is basically a knockoff item_color, great.
	var/hat_type = "yellow"
	///Whether the headlamp is on or off.
	var/on = FALSE

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
	icon_state = item_state = "hardhat[on]_[hat_type]"
	return ..()

/obj/item/clothing/head/utility/hardhat/proc/turn_on(mob/user)
	set_light_on(TRUE)

/obj/item/clothing/head/utility/hardhat/proc/turn_off(mob/user)
	set_light_on(FALSE)

/obj/item/clothing/head/utility/hardhat/orange
	icon_state = "hardhat0_orange"
	item_state = null
	hat_type = "orange"
	dog_fashion = null

/obj/item/clothing/head/utility/hardhat/red
	name = "firefighter helmet"
	desc = "A helmet designed to be used in very hot, high pressure areas."
	icon_state = "hardhat0_red"
	item_state = null
	hat_type = "red"
	dog_fashion = null
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT
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
	item_state = null
	hat_type = "white"
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	cold_protection = HEAD
	heat_protection = HEAD
	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/head/utility/hardhat/dblue
	icon_state = "hardhat0_dblue"
	item_state = null
	hat_type = "dblue"
	dog_fashion = null

/obj/item/clothing/head/utility/hardhat/atmos
	name = "atmospheric technician's firefighting helmet"
	desc = "A firefighter's helmet, able to keep the user cool in any situation."
	icon_state = "hardhat0_atmos"
	item_state = "hardhat0_atmos"
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
	flash_protect = 2
	tint = 2
	flags_inv = HIDEEYES | HIDEFACE | HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	visor_flags_inv = HIDEEYES | HIDEFACE | HIDESNOUT
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	///Icon state of the welding visor.
	var/visor_state = "weldvisor"

/obj/item/clothing/head/utility/hardhat/welding/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/clothing/head/utility/hardhat/welding/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE))
		toggle_welding_screen(user)

/obj/item/clothing/head/utility/hardhat/welding/proc/toggle_welding_screen(mob/living/user)
	if(weldingvisortoggle(user))
		playsound(src, 'sound/mecha/mechmove03.ogg', 50, TRUE) //Visors don't just come from nothing
	update_appearance()

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
	item_state = null
	hat_type = "orange"

/obj/item/clothing/head/utility/hardhat/welding/white
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight AND welding shield!" //This bulb is not smaller
	icon_state = "hardhat0_white"
	item_state = "hardhat0_white"
	light_range = 4 //Boss always takes the best stuff
	hat_type = "white"
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT
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
	item_state = null
	hat_type = "pumpkin"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	clothing_flags = SNUG_FIT
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 10)
	light_range = 2 //luminosity when on
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/utility/hardhat/reindeer
	name = "novelty reindeer hat"
	desc = "Some fake antlers and a very fake red nose."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	clothing_flags = SNUG_FIT
	icon_state = "hardhat0_reindeer"
	item_state = null
	hat_type = "reindeer"
	flags_inv = 0
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 0)
	light_range = 1 //luminosity when on
	dynamic_hair_suffix = ""

	dog_fashion = /datum/dog_fashion/head/reindeer
