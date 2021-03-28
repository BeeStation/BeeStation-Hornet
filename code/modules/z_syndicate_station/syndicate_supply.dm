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
