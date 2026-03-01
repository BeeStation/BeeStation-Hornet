/obj/item/clothing/head/helmet
	name = "helmet"
	desc = "Standard Security gear. Protects the head from impacts."
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "helmet"
	inhand_icon_state = "helmet"
	armor_type = /datum/armor/head_helmet
	flags_inv = HIDEEARS
	cold_protection = HEAD
	heat_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 60
	clothing_flags = SNUG_FIT
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEHAIR
	bang_protect = 1
	custom_price = 100

/datum/armor/head_helmet
	melee = 35
	bullet = 30
	laser = 30
	energy = 40
	bomb = 25
	fire = 50
	acid = 50
	stamina = 30
	bleed = 50

/obj/item/clothing/head/helmet/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/clothing/head/helmet/sec

/obj/item/clothing/head/helmet/sec/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seclite_attachable, light_icon_state = "flight")

/obj/item/clothing/head/helmet/sec/attackby(obj/item/attacking_item, mob/user, params)
	if(issignaler(attacking_item))
		var/obj/item/assembly/signaler/attached_signaler = attacking_item
		// There's a flashlight in us. Remove it first, or it'll be lost forever!
		var/obj/item/flashlight/seclite/blocking_us = locate() in src
		if(blocking_us)
			to_chat(user, span_warning("[blocking_us] is in the way, remove it first!"))
			return TRUE

		if(!attached_signaler.secured)
			to_chat(user, span_warning("Secure [attached_signaler] first!"))
			return TRUE

		to_chat(user, span_notice("You add [attached_signaler] to [src]."))

		qdel(attached_signaler)
		var/obj/item/bot_assembly/secbot/secbot_frame = new(loc)
		user.put_in_hands(secbot_frame)

		qdel(src)
		return TRUE

	return ..()

/obj/item/clothing/head/helmet/alt
	name = "bulletproof helmet"
	desc = "A bulletproof combat helmet that excels in protecting the wearer against traditional projectile weaponry and explosives to a minor extent."
	icon_state = "helmetalt"
	inhand_icon_state = "helmetalt"
	armor_type = /datum/armor/helmet_alt


/datum/armor/helmet_alt
	melee = 15
	bullet = 60
	laser = 10
	energy = 15
	bomb = 40
	fire = 50
	acid = 50
	stamina = 30
	bleed = 50

/obj/item/clothing/head/helmet/alt/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seclite_attachable, light_icon_state = "flight")

/obj/item/clothing/head/helmet/old
	name = "degrading helmet"
	desc = "Standard issue security helmet. Due to degradation the helmet's visor obstructs the users ability to see long distances."
	tint = 2

/obj/item/clothing/head/helmet/blueshirt
	name = "blue helmet"
	desc = "A reliable, blue tinted helmet reminding you that you <i>still</i> owe that engineer a beer."
	icon_state = "blueshift"
	inhand_icon_state = "blueshift"
	max_demand = 10
	custom_premium_price = 150


/obj/item/clothing/head/helmet/toggleable
	///chat message when the visor is toggled down.
	var/toggle_message
	///chat message when the visor is toggled up.
	var/alt_toggle_message

/obj/item/clothing/head/helmet/toggleable/attack_self(mob/user)
	. = ..()
	if(.)
		return
	//Fails if user incapacitated or try_toggle doesnt complete
	if(user.incapacitated || !try_toggle())
		return
	up = !up
	flags_1 ^= visor_flags
	flags_inv ^= visor_flags_inv
	flags_cover ^= visor_flags_cover
	icon_state = "[initial(icon_state)][up ? "up" : ""]"
	to_chat(user, span_notice("[up ? alt_toggle_message : toggle_message] \the [src]."))

	user.update_worn_head()
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		carbon_user.head_update(src, forced = TRUE)

///Attempt to toggle the visor. Returns true if it does the thing.
/obj/item/clothing/head/helmet/toggleable/proc/try_toggle()
	//Fails if attached seclite, as it blocks the visor from opening
	var/obj/item/flashlight/seclite/blocking_us = locate() in src
	if(blocking_us)
		to_chat(usr, span_warning("[blocking_us] is in the way, remove it first!"))
		return FALSE
	return TRUE

/obj/item/clothing/head/helmet/toggleable/riot
	name = "riot helmet"
	desc = "It's a helmet specifically designed to protect against close range attacks."
	icon_state = "riot"
	inhand_icon_state = "helmet"
	toggle_message = "You pull the visor down on"
	alt_toggle_message = "You push the visor up on"
	armor_type = /datum/armor/toggleable_riot
	flags_inv = HIDEEARS|HIDEFACE|HIDESNOUT
	strip_delay = 80
	actions_types = list(/datum/action/item_action/toggle)
	visor_flags_inv = HIDEFACE|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH


/datum/armor/toggleable_riot
	melee = 50
	bullet = 10
	laser = 10
	energy = 15
	fire = 80
	acid = 80
	stamina = 50
	bleed = 70

/obj/item/clothing/head/helmet/toggleable/riot/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seclite_attachable, light_icon_state = "flight")

/obj/item/clothing/head/helmet/toggleable/justice
	name = "helmet of justice"
	desc = "WEEEEOOO. WEEEEEOOO. WEEEEOOOO."
	icon_state = "justice"
	inhand_icon_state = "justice_helmet"
	toggle_message = "You turn off the lights on"
	alt_toggle_message = "You turn on the lights on"
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	///Cooldown for toggling the visor.
	COOLDOWN_DECLARE(visor_toggle_cooldown)
	///Looping sound datum for the siren helmet
	var/datum/looping_sound/siren/weewooloop

/obj/item/clothing/head/helmet/toggleable/justice/try_toggle()
	if(!COOLDOWN_FINISHED(src, visor_toggle_cooldown))
		return FALSE
	COOLDOWN_START(src, visor_toggle_cooldown, 2 SECONDS)
	return TRUE

/obj/item/clothing/head/helmet/toggleable/justice/Initialize(mapload)
	. = ..()
	weewooloop = new(src, FALSE, FALSE)

/obj/item/clothing/head/helmet/toggleable/justice/Destroy()
	QDEL_NULL(weewooloop)
	return ..()

/obj/item/clothing/head/helmet/toggleable/justice/attack_self(mob/user)
	. = ..()
	if(up)
		weewooloop.start()
	else
		weewooloop.stop()

/obj/item/clothing/head/helmet/toggleable/justice/escape
	name = "alarm helmet"
	desc = "WEEEEOOO. WEEEEEOOO. STOP THAT MONKEY. WEEEOOOO."
	icon_state = "justice2"

/obj/item/clothing/head/helmet/swat
	name = "\improper SWAT helmet"
	desc = "An extremely robust, space-worthy helmet in a nefarious red and black stripe pattern."
	icon_state = "swatsyndie"
	inhand_icon_state = "swatsyndie"
	armor_type = /datum/armor/helmet_swat
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT
	strip_delay = 80


/datum/armor/helmet_swat
	melee = 40
	bullet = 30
	laser = 30
	energy = 40
	bomb = 50
	bio = 90
	fire = 50
	acid = 50
	stamina = 50
	bleed = 70

/obj/item/clothing/head/helmet/police
	name = "police officer's hat"
	desc = "A police officer's Hat. This hat emphasizes that you are THE LAW."
	icon_state = "policehelm"
	dynamic_hair_suffix = ""

/obj/item/clothing/head/helmet/swat/nanotrasen
	name = "\improper SWAT helmet"
	desc = "An extremely robust, space-worthy helmet with the Nanotrasen logo emblazoned on the top."
	icon_state = "swat"
	inhand_icon_state = "swat"

/obj/item/clothing/head/helmet/thunderdome
	name = "\improper Thunderdome helmet"
	desc = "<i>'Let the battle commence!'</i>"
	flags_inv = HIDEEARS|HIDEHAIR
	icon_state = "thunderdome"
	inhand_icon_state = "thunderdome"
	armor_type = /datum/armor/helmet_thunderdome
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	strip_delay = 80


/datum/armor/helmet_thunderdome
	melee = 80
	bullet = 80
	laser = 50
	energy = 50
	bomb = 100
	bio = 100
	fire = 90
	acid = 90

/obj/item/clothing/head/helmet/thunderdome/holosuit
	cold_protection = null
	heat_protection = null
	armor_type = /datum/armor/thunderdome_holosuit


/datum/armor/thunderdome_holosuit
	melee = 10
	bullet = 10

/obj/item/clothing/head/helmet/roman
	name = "\improper Roman helmet"
	desc = "An ancient helmet made of bronze and leather."
	flags_inv = HIDEEARS|HIDEHAIR
	flags_cover = HEADCOVERSEYES
	armor_type = /datum/armor/helmet_roman
	resistance_flags = FIRE_PROOF
	icon_state = "roman"
	inhand_icon_state = "roman"
	strip_delay = 100


/datum/armor/helmet_roman
	melee = 25
	laser = 25
	energy = 30
	bomb = 10
	fire = 100
	acid = 50
	stamina = 40
	bleed = 50

/obj/item/clothing/head/helmet/roman/fake
	desc = "An ancient helmet made of plastic and leather."
	armor_type = /datum/armor/roman_fake


/datum/armor/roman_fake
	bleed = 10

/obj/item/clothing/head/helmet/roman/legionnaire
	name = "\improper Roman legionnaire helmet"
	desc = "An ancient helmet made of bronze and leather. Has a red crest on top of it."
	icon_state = "roman_c"
	inhand_icon_state = "roman_c"

/obj/item/clothing/head/helmet/roman/legionnaire/fake
	desc = "An ancient helmet made of plastic and leather. Has a red crest on top of it."
	armor_type = /datum/armor/legionnaire_fake


/datum/armor/legionnaire_fake
	bleed = 10

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	inhand_icon_state = "gladiator"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/helmet/redtaghelm
	name = "red laser tag helmet"
	desc = "They have chosen their own end."
	icon_state = "redtaghelm"
	flags_cover = HEADCOVERSEYES
	inhand_icon_state = "redtaghelm"
	armor_type = /datum/armor/helmet_redtaghelm


/datum/armor/helmet_redtaghelm
	melee = 15
	bullet = 10
	laser = 20
	energy = 30
	bomb = 20
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/head/helmet/bluetaghelm
	name = "blue laser tag helmet"
	desc = "They'll need more men."
	icon_state = "bluetaghelm"
	flags_cover = HEADCOVERSEYES
	inhand_icon_state = "bluetaghelm"
	armor_type = /datum/armor/helmet_bluetaghelm


/datum/armor/helmet_bluetaghelm
	melee = 15
	bullet = 10
	laser = 20
	energy = 30
	bomb = 20
	acid = 50
	stamina = 10
	bleed = 10

/obj/item/clothing/head/helmet/knight
	name = "medieval helmet"
	desc = "A classic metal helmet."
	icon_state = "knight_green"
	inhand_icon_state = "knight_green"
	armor_type = /datum/armor/helmet_knight
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	strip_delay = 80
	bang_protect = 1


/datum/armor/helmet_knight
	melee = 50
	bullet = 10
	laser = 10
	energy = 10
	fire = 80
	acid = 80
	stamina = 50
	bleed = 10

/obj/item/clothing/head/helmet/knight/blue
	icon_state = "knight_blue"
	inhand_icon_state = "knight_blue"

/obj/item/clothing/head/helmet/knight/yellow
	icon_state = "knight_yellow"
	inhand_icon_state = "knight_yellow"

/obj/item/clothing/head/helmet/knight/red
	icon_state = "knight_red"
	inhand_icon_state = "knight_red"

/obj/item/clothing/head/helmet/skull
	name = "skull helmet"
	desc = "An intimidating tribal helmet, it doesn't look very comfortable."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	flags_cover = HEADCOVERSEYES
	armor_type = /datum/armor/helmet_skull
	icon_state = "skull"
	inhand_icon_state = "skull"
	strip_delay = 100


/datum/armor/helmet_skull
	melee = 35
	bullet = 25
	laser = 25
	energy = 10
	bomb = 25
	fire = 50
	acid = 50
	stamina = 20
	bleed = 40

/obj/item/clothing/head/helmet/durathread
	name = "durathread helmet"
	desc = "A helmet made from durathread, a strong material commonly used for ballistic protection."
	icon_state = "durathread"
	inhand_icon_state = "durathread"
	resistance_flags = FLAMMABLE
	armor_type = /datum/armor/helmet_durathread
	strip_delay = 60


/datum/armor/helmet_durathread
	melee = 20
	bullet = 40
	laser = 30
	energy = 5
	bomb = 15
	fire = 40
	acid = 50
	stamina = 30
	bleed = 60

/obj/item/clothing/head/helmet/rus_helmet
	name = "russian helmet"
	desc = "It can hold a bottle of vodka."
	icon_state = "rus_helmet"
	inhand_icon_state = "rus_helmet"
	armor_type = /datum/armor/helmet_rus_helmet

/datum/armor/helmet_rus_helmet
	melee = 25
	bullet = 30
	energy = 15
	bomb = 10
	fire = 20
	acid = 50
	stamina = 20
	bleed = 15

/obj/item/clothing/head/helmet/rus_helmet/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/helmet)

/obj/item/clothing/head/helmet/rus_ushanka
	name = "battle ushanka"
	desc = "100% bear."
	icon_state = "rus_ushanka"
	inhand_icon_state = "rus_ushanka"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	armor_type = /datum/armor/helmet_rus_ushanka


/datum/armor/helmet_rus_ushanka
	melee = 25
	bullet = 20
	laser = 20
	energy = 10
	bomb = 20
	bio = 50
	fire = -10
	acid = 50
	stamina = 20
	bleed = 15

/obj/item/clothing/head/helmet/outlaw
	name = "outlaw's hat"
	desc = "Keeps the sun out of your eyes while on the run from Johnny Law."
	icon = 'icons/obj/clothing/head/cowboy.dmi'
	worn_icon = 'icons/mob/clothing/head/cowboy.dmi'
	icon_state = "cowboy"
	inhand_icon_state = "cowboy"
	worn_icon_state = "cowboy_outlaw"
	body_parts_covered = HEAD
	armor_type = /datum/armor/helmet_outlaw


/datum/armor/helmet_outlaw
	melee = 25
	bullet = 25
	laser = 20
	energy = 10
	bomb = 30
	bio = 30
	acid = 40
	stamina = 25
	bleed = 15
