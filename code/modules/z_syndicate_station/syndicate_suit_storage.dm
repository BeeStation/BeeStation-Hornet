//Suits

/obj/item/clothing/head/helmet/space/hardsuit/syndi_basic
	name = "blood-red hardsuit helmet"
	desc = "A single-mode advanced helmet designed for work in special operations. It is in EVA mode. Property of Gorlex Marauders."
	alt_desc = "A dual-mode advanced helmet designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_helm"
	item_color = "syndi"
	armor = list("melee" = 35, "bullet" = 30, "laser" = 20, "energy" = 30, "bomb" = 35, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 90, "stamina" = 30)
	on = TRUE
	actions_types = list()
	visor_flags_inv = HIDEMASK|HIDEEYES|HIDEFACE|HIDEFACIALHAIR
	visor_flags = STOPSPRESSUREDAMAGE

//Engineering hardsuit
//Slightly weaker than the standard syndicate hardsuit but offers environmental protection.
/obj/item/clothing/suit/space/hardsuit/engine/syndicate
	name = "syndicate engineering hardsuit"
	desc =  "A pressurised suit designed for working in hazardous environments. Protects against radioactive hazards."
	icon_state = "hardsuit-syndi-eng"
	item_state = "syndie_hardsuit"
	item_color = "syndi"
	armor = list("melee" = 35, "bullet" = 30, "laser" = 20, "energy" = 30, "bomb" = 35, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 90, "stamina" = 30)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi_basic

/obj/item/clothing/suit/space/hardsuit/engine/atmos/syndicate
	name = "syndicate atmospherics hardsuit"
	desc =  "A pressurised suit designed for working in hazardous environments. Protects against intense thermal hazards."
	icon_state = "hardsuit-syndi-atm"
	item_state = "syndie_hardsuit"
	item_color = "syndi"
	armor = list("melee" = 35, "bullet" = 30, "laser" = 20, "energy" = 30, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 90, "stamina" = 30)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi_basic

/obj/item/clothing/suit/space/hardsuit/security/syndicate
	name = "syndicate peacekeeper's hardsuit"
	desc =  "An armoured combat suit designed to protect against ballistic, energy and pressure based threats."
	icon_state = "hardsuit-syndi-sec"
	item_state = "syndie_hardsuit"
	item_color = "syndi"
	armor = list("melee" = 45, "bullet" = 30, "laser" = 30, "energy" = 40, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 90, "stamina" = 50)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi_basic

/obj/item/clothing/suit/space/hardsuit/security/hos/syndicate
	name = "syndicate elite peacekeeper's hardsuit"
	desc =  "An upgraded version of the standard peacekeeping hardsuit, designed for the elite."
	icon_state = "hardsuit-syndi-hos"
	item_state = "syndie_hardsuit"
	item_color = "syndi"
	armor = list("melee" = 50, "bullet" = 35, "laser" = 35, "energy" = 40, "bomb" = 20, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 90, "stamina" = 50)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi_basic

//=================
// Suit storage replacements
//=================

/obj/machinery/suit_storage_unit/Initialize()
	if(CONFIG_GET(flag/syndicate_station))
		make_syndie()
	. = ..()

/obj/machinery/suit_storage_unit/proc/make_syndie()
	return

/obj/machinery/suit_storage_unit/standard_unit/make_syndie()
	suit_type = /obj/item/clothing/suit/space/syndicate
	helmet_type = /obj/item/clothing/head/helmet/space/syndicate
	mask_type = /obj/item/clothing/mask/gas/syndicate

/obj/machinery/suit_storage_unit/captain/make_syndie()
	mask_type = /obj/item/clothing/mask/gas/syndicate
	storage_type = /obj/item/tank/jetpack/oxygen/captain

/obj/machinery/suit_storage_unit/atmos/make_syndie()
	suit_type = /obj/item/clothing/suit/space/hardsuit/engine/atmos/syndicate
	mask_type = /obj/item/clothing/mask/gas/syndicate

/obj/machinery/suit_storage_unit/engine/make_syndie()
	suit_type = /obj/item/clothing/suit/space/hardsuit/engine/syndicate
	mask_type = /obj/item/clothing/mask/gas/syndicate

/obj/machinery/suit_storage_unit/ce/make_syndie()
	mask_type = /obj/item/clothing/mask/gas/syndicate

/obj/machinery/suit_storage_unit/security/make_syndie()
	suit_type = /obj/item/clothing/suit/space/hardsuit/security/syndicate
	mask_type = /obj/item/clothing/mask/gas/syndicate

/obj/machinery/suit_storage_unit/hos/make_syndie()
	suit_type = /obj/item/clothing/suit/space/hardsuit/security/hos/syndicate
	mask_type = /obj/item/clothing/mask/gas/syndicate

//woah!!! the bad guys are centcom all along?
/obj/machinery/suit_storage_unit/syndicate/make_syndie()
	suit_type = /obj/item/clothing/suit/space/hardsuit/ert/sec
	mask_type = /obj/item/clothing/mask/gas/sechailer
	storage_type = /obj/item/tank/jetpack/oxygen/harness
