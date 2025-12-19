//miscellaneous spacesuits
/*
Contains:
	- Captain's spacesuit
	- Death squad's hardsuit
	- SWAT suit
	- Officer's beret/spacesuit
	- NASA Voidsuit
	- Father Christmas' magical clothes
	- Pirate's spacesuit
	- ERT hardsuit: command, sec, engi, med, janitor
	- EVA spacesuit
	- Freedom's spacesuit (freedom from vacuum's oppression)
	- Carp hardsuit
	- Bounty hunter hardsuit
	- Emergency skinsuit
*/

	//Death squad armored space suits, not hardsuits!
/obj/item/clothing/head/helmet/space/hardsuit/deathsquad
	name = "MK.III SWAT Helmet"
	desc = "An advanced tactical space helmet."
	icon_state = "deathsquad"
	inhand_icon_state = "deathsquad"
	armor_type = /datum/armor/hardsuit_deathsquad
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	actions_types = list()


/datum/armor/hardsuit_deathsquad
	melee = 80
	bullet = 80
	laser = 50
	energy = 50
	bomb = 100
	bio = 100
	fire = 100
	acid = 100
	stamina = 100
	bleed = 100

/obj/item/clothing/head/helmet/space/hardsuit/deathsquad/attack_self(mob/user)
	return

/obj/item/clothing/suit/space/hardsuit/deathsquad
	name = "MK.III SWAT Suit"
	desc = "A prototype designed to replace the ageing MK.II SWAT suit. Based on the streamlined MK.II model, the traditional ceramic and graphene plate construction was replaced with plasteel, allowing superior armor against most threats. There's room for some kind of energy projection device on the back."
	icon_state = "deathsquad"
	inhand_icon_state = "swat_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/knife/combat)
	armor_type = /datum/armor/hardsuit_deathsquad
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/deathsquad
	dog_fashion = /datum/dog_fashion/back/deathsquad
	cell = /obj/item/stock_parts/cell/bluespace
	move_sound = list('sound/effects/suitstep1.ogg', 'sound/effects/suitstep2.ogg')


/datum/armor/hardsuit_deathsquad
	melee = 80
	bullet = 80
	laser = 50
	energy = 50
	bomb = 100
	bio = 100
	fire = 100
	acid = 100
	stamina = 100
	bleed = 100

/obj/item/clothing/head/helmet/space/beret
	name = "CentCom officer's beret"
	desc = "An armored beret commonly used by special operations officers. Uses advanced force field technology to protect the head from space."
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	icon = 'icons/obj/clothing/head/beret.dmi'
	icon_state = "beret_badge"
	inhand_icon_state = null
	greyscale_colors = "#397F3F#FFCE5B"
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT
	flags_inv = 0
	armor_type = /datum/armor/space_beret
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF


/datum/armor/space_beret
	melee = 80
	bullet = 80
	laser = 50
	energy = 50
	bomb = 100
	bio = 100
	fire = 100
	acid = 100
	stamina = 100
	bleed = 100

/obj/item/clothing/suit/space/officer
	name = "CentCom officer's coat"
	desc = "An armored, space-proof coat used in special operations."
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/jacket.dmi'
	icon_state = "centcom_coat"
	icon = 'icons/obj/clothing/suits/jacket.dmi'
	worn_icon = 'icons/mob/clothing/suits/jacket.dmi'
	inhand_icon_state = "centcom"
	blood_overlay_type = "coat"
	slowdown = 0
	flags_inv = 0
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor_type = /datum/armor/space_officer
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

	//NASA Voidsuit

/datum/armor/space_officer
	melee = 80
	bullet = 80
	laser = 50
	energy = 50
	bomb = 100
	bio = 100
	fire = 100
	acid = 100
	stamina = 100
	bleed = 100

/obj/item/clothing/head/helmet/space/nasavoid
	name = "NASA Void Helmet"
	desc = "An old, NASA CentCom branch designed, dark red space suit helmet."
	icon_state = "void"
	inhand_icon_state = "void"

/obj/item/clothing/suit/space/nasavoid
	name = "NASA Voidsuit"
	icon_state = "void"
	inhand_icon_state = "void"
	desc = "An old, NASA CentCom branch designed, dark red space suit."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)

/obj/item/clothing/head/helmet/space/nasavoid/old
	name = "Engineering Void Helmet"
	desc = "A CentCom engineering dark red space suit helmet. While old and dusty, it still gets the job done."
	icon_state = "void"
	inhand_icon_state = "void"

/obj/item/clothing/suit/space/nasavoid/old
	name = "Engineering Voidsuit"
	icon_state = "void"
	inhand_icon_state = "void"
	desc = "A CentCom engineering dark red space suit. Age has degraded the suit making is difficult to move around in."
	slowdown = 4
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)

	//Space pirate outfit
/obj/item/clothing/head/helmet/space/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "pirate"
	inhand_icon_state = "pirate"
	armor_type = /datum/armor/space_pirate
	flags_inv = HIDEHAIR
	strip_delay = 40
	equip_delay_other = 20
	flags_cover = HEADCOVERSEYES


/datum/armor/space_pirate
	melee = 30
	bullet = 50
	laser = 30
	energy = 15
	bomb = 30
	bio = 30
	fire = 60
	acid = 75
	stamina = 20
	bleed = 20

/obj/item/clothing/head/helmet/space/pirate/bandana
	name = "pirate bandana"
	icon_state = "bandana"
	inhand_icon_state = "bandana"

/obj/item/clothing/suit/space/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon = 'icons/obj/clothing/suits/costume.dmi'
	worn_icon = 'icons/mob/clothing/suits/costume.dmi'
	icon_state = "pirate"
	inhand_icon_state = "pirate"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(
		/obj/item/gun,
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/melee/baton,
		/obj/item/restraints/handcuffs,
		/obj/item/tank/internals,
		/obj/item/melee/energy/sword/pirate,
		/obj/item/clothing/glasses/eyepatch,
		/obj/item/reagent_containers/cup/glass/bottle/rum
		)
	slowdown = 0
	armor_type = /datum/armor/space_pirate
	strip_delay = 40
	equip_delay_other = 20

	//Emergency Response Team suits

/datum/armor/space_pirate
	melee = 30
	bullet = 50
	laser = 30
	energy = 15
	bomb = 30
	bio = 30
	fire = 60
	acid = 75
	stamina = 20
	bleed = 20

/obj/item/clothing/head/helmet/space/hardsuit/ert
	name = "emergency response team commander helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has blue highlights."
	icon_state = "hardsuit0-ert_commander"
	inhand_icon_state = "hardsuit0-ert_commander"
	hardsuit_type = "ert_commander"
	armor_type = /datum/armor/hardsuit_ert
	strip_delay = 130
	light_range = 7
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list(
		/datum/action/item_action/toggle_helmet_light,
		/datum/action/item_action/toggle_beacon_hud
	)
	var/beacon_colour = "#4b48ec"
	var/beacon_zdiff_colour = "#0b0a47"


/datum/armor/hardsuit_ert
	melee = 65
	bullet = 50
	laser = 50
	energy = 50
	bomb = 50
	bio = 100
	fire = 80
	acid = 80
	stamina = 70
	bleed = 70

/obj/item/clothing/head/helmet/space/hardsuit/ert/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, LOCKED_HELMET_TRAIT)
	//Link
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit/ert))
		var/obj/linkedsuit = loc
		//NOTE FOR COPY AND PASTING: BEACON MUST BE MADE FIRST
		//Add the monitor (Default to null - No tracking)
		var/datum/component/tracking_beacon/component_beacon = linkedsuit.AddComponent(/datum/component/tracking_beacon, "cent", null, null, TRUE, beacon_colour, FALSE, FALSE, beacon_zdiff_colour)
		//Add the monitor (Default to null - No tracking)
		component_beacon.attached_monitor = AddComponent(/datum/component/team_monitor/worn, "cent", null, component_beacon)
	else
		AddComponent(/datum/component/team_monitor, "cent", -1)

/obj/item/clothing/suit/space/hardsuit/ert
	name = "emergency response team commander hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has blue highlights. Offers superb protection against environmental hazards."
	icon_state = "ert_command"
	inhand_icon_state = "ert_command"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor_type = /datum/armor/hardsuit_ert
	slowdown = 0
	strip_delay = 130
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	jetpack = /obj/item/tank/jetpack/suit
	actions_types = list(
		/datum/action/item_action/toggle_helmet,
		/datum/action/item_action/toggle_beacon,
		/datum/action/item_action/toggle_beacon_frequency
	)

// ERT suit's gets EMP Protection

/datum/armor/hardsuit_ert
	melee = 65
	bullet = 50
	laser = 50
	energy = 50
	bomb = 50
	bio = 100
	fire = 80
	acid = 80
	stamina = 70
	bleed = 70

/obj/item/clothing/suit/space/hardsuit/ert/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_CONTENTS)

	//ERT Security
/obj/item/clothing/head/helmet/space/hardsuit/ert/sec
	name = "emergency response team security helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has red highlights."
	icon_state = "hardsuit0-ert_security"
	inhand_icon_state = "hardsuit0-ert_security"
	hardsuit_type = "ert_security"
	beacon_colour = "#ec4848"
	beacon_zdiff_colour = "#ca7878"

/obj/item/clothing/suit/space/hardsuit/ert/sec
	name = "emergency response team security hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has red highlights. Offers superb protection against environmental hazards."
	icon_state = "ert_security"
	inhand_icon_state = "ert_security"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/sec
	jetpack = /obj/item/tank/jetpack/suit

	//ERT Engineering
/obj/item/clothing/head/helmet/space/hardsuit/ert/engi
	name = "emergency response team engineering helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has orange highlights."
	icon_state = "hardsuit0-ert_engineer"
	inhand_icon_state = "hardsuit0-ert_engineer"
	hardsuit_type = "ert_engineer"
	beacon_colour = "#ecaa48"
	beacon_zdiff_colour = "#daa960"

/obj/item/clothing/suit/space/hardsuit/ert/engi
	name = "emergency response team engineering hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has orange highlights. Offers superb protection against environmental hazards."
	icon_state = "ert_engineer"
	inhand_icon_state = "ert_engineer"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/engi
	jetpack = /obj/item/tank/jetpack/suit

	//ERT Medical
/obj/item/clothing/head/helmet/space/hardsuit/ert/med
	name = "emergency response team medical helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has white highlights."
	icon_state = "hardsuit0-ert_medical"
	inhand_icon_state = "hardsuit0-ert_medical"
	hardsuit_type = "ert_medical"
	beacon_colour = "#88ecec"
	beacon_zdiff_colour = "#4f8888"

/obj/item/clothing/suit/space/hardsuit/ert/med
	name = "emergency response team medical hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has white highlights. Offers superb protection against environmental hazards."
	icon_state = "ert_medical"
	inhand_icon_state = "ert_medical"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/med
	jetpack = /obj/item/tank/jetpack/suit

	//ERT Janitor
/obj/item/clothing/head/helmet/space/hardsuit/ert/jani
	name = "emergency response team janitorial helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has purple highlights."
	icon_state = "hardsuit0-ert_janitor"
	inhand_icon_state = "hardsuit0-ert_janitor"
	hardsuit_type = "ert_janitor"
	beacon_colour = "#be43ce"
	beacon_zdiff_colour = "#895d8f"

/obj/item/clothing/suit/space/hardsuit/ert/jani
	name = "emergency response team janitorial hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has purple highlights. Offers superb protection against environmental hazards. This one has extra clips for holding various janitorial tools."
	icon_state = "ert_janitor"
	inhand_icon_state = "ert_janitor"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/jani
	allowed = list(/obj/item/storage/bag/trash, /obj/item/melee/flyswatter, /obj/item/mop, /obj/item/holosign_creator/janibarrier, /obj/item/reagent_containers/cup/bucket, /obj/item/reagent_containers/spray/chemsprayer/janitor)

/obj/item/clothing/suit/space/eva
	name = "EVA suit"
	icon_state = "space"
	inhand_icon_state = "eva_suit"
	desc = "A lightweight space suit with the basic ability to protect the wearer from the vacuum of space during emergencies."
	armor_type = /datum/armor/space_eva


/datum/armor/space_eva
	bio = 100
	fire = 50
	acid = 65
	bleed = 30

/obj/item/clothing/head/helmet/space/eva
	name = "EVA helmet"
	icon_state = "space"
	inhand_icon_state = "eva_helmet"
	desc = "A lightweight space helmet with the basic ability to protect the wearer from the vacuum of space during emergencies."
	flash_protect = FLASH_PROTECTION_NONE
	armor_type = /datum/armor/space_eva


/datum/armor/space_eva
	bio = 100
	fire = 50
	acid = 65
	bleed = 30

/obj/item/clothing/head/helmet/space/freedom
	name = "eagle helmet"
	desc = "An advanced, space-proof helmet. It appears to be modeled after an old-world eagle."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "griffinhat"
	inhand_icon_state = null
	armor_type = /datum/armor/space_freedom
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = ACID_PROOF | FIRE_PROOF


/datum/armor/space_freedom
	melee = 20
	bullet = 40
	laser = 30
	energy = 25
	bomb = 100
	bio = 100
	fire = 80
	acid = 80
	stamina = 10
	bleed = 30

/obj/item/clothing/suit/space/freedom
	name = "eagle suit"
	desc = "An advanced, light suit, fabricated from a mixture of synthetic feathers and space-resistant material. A gun holster appears to be integrated into the suit and the wings appear to be stuck in 'freedom' mode."
	icon_state = "freedom"
	inhand_icon_state = "freedom"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor_type = /datum/armor/space_freedom
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = ACID_PROOF | FIRE_PROOF
	slowdown = 0


/datum/armor/space_freedom
	melee = 20
	bullet = 40
	laser = 30
	energy = 25
	bomb = 100
	bio = 100
	fire = 80
	acid = 80
	stamina = 10
	bleed = 30

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	name = "paranormal response team helmet"
	desc = "A helmet worn by those who deal with paranormal threats for a living."
	icon_state = "hardsuit0-prt"
	inhand_icon_state = "hardsuit0-prt"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()
	resistance_flags = FIRE_PROOF
	beacon_colour = "#9ddb56"
	beacon_zdiff_colour = "#6a9e2f"

/obj/item/clothing/suit/space/hardsuit/ert/paranormal
	name = "paranormal response team hardsuit"
	desc = "Powerful wards are built into this hardsuit, protecting the user from all manner of paranormal threats."
	icon_state = "knight_grey"
	inhand_icon_state = "knight_grey"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	custom_price = 20000
	max_demand = 5

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, INNATE_TRAIT, (MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY))

//Lavaland suits

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/lavaland
	desc = "Powerful wards are built into this hardsuit, protecting the user from all manner of paranormal threats with armor designed specifically for low pressures."
	high_pressure_multiplier = 0.4

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/lavaland
	high_pressure_multiplier = 0.4

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/lavaland/beserker
	name = "champion's hardsuit"
	desc = "Voices echo from the hardsuit, driving the user insane."
	icon_state = "hardsuit-beserker"
	inhand_icon_state = "hardsuit-beserker"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/lavaland/beserker

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/lavaland/beserker
	name = "champion's helmet"
	desc = "Peering into the eyes of the helmet is enough to seal damnation."
	icon_state = "hardsuit0-beserker"
	inhand_icon_state = "hardsuit0-beserker"

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/lavaland/inquisitor
	name = "inquisitor's hardsuit"
	icon_state = "hardsuit-inq"
	inhand_icon_state = "hardsuit-inq"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/lavaland/inquisitor

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/lavaland/inquisitor
	name = "inquisitor's helmet"
	icon_state = "hardsuit0-inq"
	inhand_icon_state = "hardsuit0-inq"

//End lavaland suits

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	name = "inquisitor's hardsuit"
	icon_state = "hardsuit-inq"
	inhand_icon_state = "hardsuit-inq"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/inquisitor

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/inquisitor
	name = "inquisitor's helmet"
	icon_state = "hardsuit0-inq"
	inhand_icon_state = "hardsuit0-inq"

/obj/item/clothing/head/helmet/space/fragile
	name = "emergency space helmet"
	desc = "A bulky, air-tight helmet meant to protect the user during emergency situations. It doesn't look very durable."
	icon_state = "syndicate-helm-orange"
	inhand_icon_state = "syndicate-helm-orange"
	armor_type = /datum/armor/space_fragile
	strip_delay = 65
	flash_protect = FLASH_PROTECTION_NONE


/datum/armor/space_fragile
	melee = 5
	bio = 10
	bleed = 5

/obj/item/clothing/suit/space/fragile
	name = "emergency space suit"
	desc = "A bulky, air-tight suit meant to protect the user during emergency situations. It doesn't look very durable."
	var/torn = FALSE
	icon_state = "syndicate-orange"
	inhand_icon_state = "syndicate-orange"
	slowdown = 2
	armor_type = /datum/armor/space_fragile
	strip_delay = 65
	w_class = WEIGHT_CLASS_NORMAL


/datum/armor/space_fragile
	melee = 5
	bio = 10
	bleed = 5

/obj/item/clothing/suit/space/fragile/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(!torn && prob(50))
		to_chat(owner, span_warning("\The [src] tears from the damage, breaking the air-tight seal!"))
		clothing_flags &= ~STOPSPRESSUREDAMAGE
		name = "torn [src]"
		desc = "A bulky suit meant to protect the user during emergency situations, at least until someone tore a hole in the suit."
		torn = TRUE
		playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1)
		playsound(loc, 'sound/effects/refill.ogg', 50, 1)

/obj/item/clothing/suit/space/hunter
	name = "bounty hunting suit"
	desc = "A custom version of the MK.II SWAT suit, modified to look rugged and tough. Works as a space suit, if you can find a helmet."
	icon_state = "hunter"
	inhand_icon_state = "swat_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/knife/combat)
	armor_type = /datum/armor/space_hunter
	strip_delay = 130
	resistance_flags = FIRE_PROOF | ACID_PROOF
	cell = /obj/item/stock_parts/cell/hyper


/datum/armor/space_hunter
	melee = 60
	bullet = 40
	laser = 40
	energy = 50
	bomb = 100
	bio = 100
	fire = 100
	acid = 100
	stamina = 70
	bleed = 70

/obj/item/clothing/head/helmet/space/hardsuit/skinsuit
	name = "skinsuit helmet"
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	worn_icon = 'icons/mob/clothing/head/spacehelm.dmi'
	icon_state = "skinsuit_helmet"
	inhand_icon_state = "skinsuit_helmet"
	max_integrity = 200
	desc = "An airtight helmet meant to protect the wearer during emergency situations."
	armor_type = /datum/armor/hardsuit_skinsuit
	min_cold_protection_temperature = EMERGENCY_HELM_MIN_TEMP_PROTECT
	heat_protection = NONE
	flash_protect = FLASH_PROTECTION_NONE
	bang_protect = 0
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS
	max_heat_protection_temperature = 100
	actions_types = null


/datum/armor/hardsuit_skinsuit
	bio = 100
	bleed = 10

/obj/item/clothing/head/helmet/space/hardsuit/skinsuit/attack_self(mob/user)
	return

/obj/item/clothing/head/helmet/space/hardsuit/skinsuit/emp_act(severity)
	return

/obj/item/clothing/suit/space/hardsuit/skinsuit
	name = "skinsuit"
	desc = "A slim, compression-based spacesuit meant to protect the user during emergency situations. It's only a little warmer than your uniform."
	icon = 'icons/obj/clothing/suits/spacesuit.dmi'
	worn_icon = 'icons/mob/clothing/suits/spacesuit.dmi'
	icon_state = "skinsuit"
	inhand_icon_state = "s_suit"
	max_integrity = 200
	slowdown = 3 //Higher is slower
	clothing_flags = STOPSPRESSUREDAMAGE
	gas_transfer_coefficient = 0.5
	armor_type = /datum/armor/hardsuit_skinsuit
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	min_cold_protection_temperature = EMERGENCY_SUIT_MIN_TEMP_PROTECT
	heat_protection = NONE
	max_heat_protection_temperature = 100
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/skinsuit


/datum/armor/hardsuit_skinsuit
	bio = 50
	bleed = 10

/obj/item/clothing/suit/space/hardsuit/skinsuit/attackby(obj/item/I, mob/user, params)
	return

/obj/item/clothing/head/helmet/space/hunter
	name = "bounty hunting helmet"
	desc = "A custom tactical space helmet with decals added."
	icon_state = "hunter"
	inhand_icon_state = "hunter"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor_type = /datum/armor/space_hunter


/datum/armor/space_hunter
	melee = 5
	bullet = 5
	laser = 5
	stamina = 20
	bleed = 40
