/datum/supply_pack/New()
	. = ..()
	become_syndie()

/datum/supply_pack/proc/become_syndie()
	return

/datum/supply_pack/emergency/bomb/become_syndie()
	name = "Explosive Emergency Starter Pack"
	desc = "Contains all the explosives you need to start an emergency."
	cost = 3000
	contains = list(/obj/item/grenade/syndieminibomb,
					/obj/item/grenade/syndieminibomb,
					/obj/item/grenade/syndieminibomb/concussion,
					/obj/item/grenade/syndieminibomb/concussion,
					/obj/item/bombcore/miniature)

/datum/supply_pack/emergency/internals/become_syndie()
	contains = list(/obj/item/clothing/mask/gas/syndicate,
					/obj/item/clothing/mask/gas/syndicate,
					/obj/item/clothing/mask/gas/syndicate,
					/obj/item/clothing/mask/gas/syndicate,
					/obj/item/clothing/mask/gas/syndicate,
					/obj/item/clothing/mask/gas/syndicate,
					/obj/item/tank/internals/emergency_oxygen/engi,
					/obj/item/tank/internals/emergency_oxygen/engi,
					/obj/item/tank/internals/emergency_oxygen/engi,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air)

/datum/supply_pack/emergency/spacesuit/become_syndie()
	contains = list(/obj/item/clothing/suit/space/syndicate/black/red,
					/obj/item/clothing/head/helmet/space/syndicate/black/red,
					/obj/item/clothing/mask/gas/syndicate)

/datum/supply_pack/emergency/spacesuit/bulk/become_syndie()
	contains = list(/obj/item/clothing/suit/space/syndicate/black/red,
					/obj/item/clothing/head/helmet/space/syndicate/black/red,
					/obj/item/clothing/mask/gas/syndicate,
					/obj/item/clothing/suit/space/syndicate/black/red,
					/obj/item/clothing/head/helmet/space/syndicate/black/red,
					/obj/item/clothing/mask/gas/syndicate,
					/obj/item/clothing/suit/space/syndicate/black/red,
					/obj/item/clothing/head/helmet/space/syndicate/black/red,
					/obj/item/clothing/mask/gas/syndicate)

/datum/supply_pack/security/disabler/become_syndie()
	name = "Syndicate Peacekeeping Crate"
	desc = "Contains 3 firearms for Syndicate peacekeepers."
	contains = list(
		/obj/item/gun/ballistic/automatic/pistol/rubber,
		/obj/item/gun/ballistic/automatic/pistol/rubber,
		/obj/item/gun/ballistic/automatic/pistol/rubber)

/datum/supply_pack/security/laser/become_syndie()
	name = "Heavy Firearms Crate"
	desc = "Contains heavy firearms for Syndicate peacekeepers, for when times get rough."
	contains = list(
		/obj/item/gun/ballistic/automatic/c20r/unrestricted)

/datum/supply_pack/security/securityclothes/become_syndie()
	contains = list(/obj/item/clothing/under/syndicate/combat,
					/obj/item/clothing/under/syndicate/combat,
					/obj/item/clothing/head/HoS/beret/syndicate,
					/obj/item/clothing/head/HoS/beret/syndicate,
					/obj/item/clothing/under/syndicate/combat,
					/obj/item/clothing/suit/security/warden,
					/obj/item/clothing/head/beret/sec/navywarden,
					/obj/item/clothing/under/syndicate/combat,
					/obj/item/clothing/suit/security/hos,
					/obj/item/clothing/head/beret/sec/navyhos)

/datum/supply_pack/security/baton/become_syndie()
	contains = list(/obj/item/melee/classic_baton/contractor_baton/security,
					/obj/item/melee/classic_baton/contractor_baton/security,
					/obj/item/melee/classic_baton/contractor_baton/security)

/datum/supply_pack/security/ammo/become_syndie()
	contains = list(/obj/item/ammo_box/magazine/m10mm/rubber,
					/obj/item/ammo_box/magazine/m10mm/rubber,
					/obj/item/storage/box/lethalshot,
					/obj/item/storage/box/lethalshot,
					/obj/item/storage/box/lethalshot,
					/obj/item/storage/box/rubbershot,
					/obj/item/storage/box/rubbershot,
					/obj/item/storage/box/rubbershot,
					/obj/item/ammo_box/c38/trac,
					/obj/item/ammo_box/c38/hotshot,
					/obj/item/ammo_box/c38/iceblox)

/datum/supply_pack/security/armory/dragnet/become_syndie()
	//Illegal nanotrasen stuff
	hidden = TRUE

/datum/supply_pack/security/armory/energy_single/become_syndie()
	name = "Mateba Single-Pack"
	desc = "Contains one Mateba revolver. Requires armory access to open"
	cost = 2300
	contains = list(/obj/item/gun/ballistic/revolver/mateba)
	crate_name = "single mateba crate"

/datum/supply_pack/security/armory/energy/become_syndie()
	name = "Bulk Mateba Crate"
	desc = "Contains three Mateba revolvers. Requires armory access to open"
	cost = 4800
	contains = list(/obj/item/gun/ballistic/revolver/mateba,
		/obj/item/gun/ballistic/revolver/mateba,
		/obj/item/gun/ballistic/revolver/mateba)
	crate_name = "bulk mateba crate"

/datum/supply_pack/security/armory/laserarmor/become_syndie()
	hidden = TRUE
