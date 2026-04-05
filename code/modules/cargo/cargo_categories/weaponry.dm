/**
 * # Weaponry Cargo Items
 *
 * Weapons, ammunition, and combat-related items.
 * Split into Melee, Ranged, Ammunition, and Grenades & Explosives.
 */

// =============================================================================
// MELEE WEAPONS
// =============================================================================

/datum/cargo_list/weaponry_melee
	access_budget = ACCESS_SECURITY
	crate_type = /obj/structure/closet/crate
	small_item = TRUE
	entries = list(
		// -- Standard-issue security melee (SecTech, security belts) --
		list("path" = /obj/item/melee/baton/security/loaded, "cost" = 750, "max_supply" = 4),
		list("path" = /obj/item/melee/tonfa, "cost" = 200, "max_supply" = 6),
		list("path" = /obj/item/club, "cost" = 200, "max_supply" = 6),
		list("path" = /obj/item/melee/baton/telescopic, "cost" = 400, "max_supply" = 4),
		// -- Non-lethal restraint / control devices --
		list("path" = /obj/item/restraints/handcuffs, "cost" = 50, "max_supply" = 10),
		list("path" = /obj/item/restraints/handcuffs/cable/zipties, "cost" = 30, "max_supply" = 12),
		list("path" = /obj/item/restraints/legcuffs/bola/energy, "cost" = 200, "max_supply" = 8),
		list("path" = /obj/item/assembly/flash/handheld, "cost" = 150, "max_supply" = 6),
		list("path" = /obj/item/reagent_containers/peppercloud_deployer, "cost" = 100, "max_supply" = 6),
		// -- Security utility items --
		list("path" = /obj/item/holosign_creator/security, "cost" = 400, "max_supply" = 4),
		list("path" = /obj/item/clothing/accessory/security_pager, "cost" = 50, "max_supply" = 6),
		// -- General-access melee --
		list("path" = /obj/item/scythe, "cost" = 300, "max_supply" = 3, "access_budget" = FALSE),
	)

/datum/cargo_list/weaponry_melee_armory
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon
	small_item = TRUE
	entries = list(
		// -- Armory-grade melee --
		list("path" = /obj/item/knife/combat, "cost" = 700, "max_supply" = 4),
	)

// =============================================================================
// RANGED WEAPONS
// =============================================================================

/datum/cargo_list/weaponry_ranged
	access_budget = ACCESS_SECURITY
	crate_type = /obj/structure/closet/crate
	entries = list(
		// -- Standard-issue sidearms --
		list("path" = /obj/item/gun/ballistic/taser, "cost" = 900, "max_supply" = 4, "small_item" = TRUE),
	)

/datum/cargo_list/weaponry_ranged_armory
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon
	entries = list(
		// -- Armory sidearms --
		list("path" = /obj/item/gun/ballistic/automatic/pistol/security, "cost" = 1200, "max_supply" = 4, "small_item" = TRUE),
		// -- Armory energy weapons --
		list("path" = /obj/item/gun/energy/e_gun/dragnet, "cost" = 2000, "max_supply" = 3, "small_item" = TRUE),
		list("path" = /obj/item/gun/energy/e_gun, "cost" = 3500, "max_supply" = 3),
		list("path" = /obj/item/gun/energy/laser, "cost" = 2500, "max_supply" = 4),
		list("path" = /obj/item/gun/energy/ionrifle, "cost" = 3000, "max_supply" = 2),
		// -- Armory ballistic weapons --
		list("path" = /obj/item/gun/ballistic/shotgun/riot, "cost" = 2500, "max_supply" = 4),
		list("path" = /obj/item/gun/ballistic/shotgun/automatic/combat, "cost" = 3000, "max_supply" = 3),
		list("path" = /obj/item/gun/ballistic/shotgun/automatic/combat/compact, "cost" = 3500, "max_supply" = 2),
		list("path" = /obj/item/gun/ballistic/automatic/wt550, "cost" = 3000, "max_supply" = 3),
		// -- Dangerous / special weapons --
		list("path" = /obj/item/flamethrower/full, "cost" = 2000, "max_supply" = 2, "dangerous" = TRUE),
	)

// =============================================================================
// AMMUNITION
// =============================================================================

/datum/cargo_list/weaponry_ammo
	access_budget = ACCESS_SECURITY
	crate_type = /obj/structure/closet/crate
	small_item = TRUE
	entries = list(
		// -- Taser ammunition (standard security issue) --
		list("path" = /obj/item/ammo_box/taser, "cost" = 500, "max_supply" = 4),
		list("path" = /obj/item/ammo_casing/taser, "cost" = 200, "max_supply" = 6),
		// -- Beanbag (general access) --
		list("path" = /obj/item/storage/box/beanbag, "cost" = 300, "max_supply" = 6, "access_budget" = FALSE),
		// -- Service pistol rechargeable magazine --
		list("path" = /obj/item/ammo_box/magazine/recharge/service, "cost" = 300, "max_supply" = 6),
	)

/datum/cargo_list/weaponry_ammo_armory
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon
	small_item = TRUE
	entries = list(
		// -- Shotgun ammo boxes --
		list("path" = /obj/item/storage/box/rubbershot, "cost" = 400, "max_supply" = 6),
		list("path" = /obj/item/storage/box/lethalshot, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/storage/box/breacherslug, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/storage/box/incapacitateshot, "cost" = 500, "max_supply" = 4),
		// -- NPS-10 / x200 LAW ammo --
		list("path" = /obj/item/ammo_box/x200law, "cost" = 1200, "max_supply" = 3),
		list("path" = /obj/item/ammo_box/magazine/x200law/empty, "cost" = 400, "max_supply" = 5),
		// -- .38 revolver ammo (detective / heads) --
		list("path" = /obj/item/ammo_box/c38, "cost" = 400, "max_supply" = 6),
		list("path" = /obj/item/ammo_box/c38/box, "cost" = 500, "max_supply" = 4),
		list("path" = /obj/item/ammo_box/c38/trac, "cost" = 700, "max_supply" = 4),
		list("path" = /obj/item/ammo_box/c38/match, "cost" = 700, "max_supply" = 2),
		list("path" = /obj/item/ammo_box/c38/dumdum, "cost" = 1000, "max_supply" = 2),
		list("path" = /obj/item/ammo_box/c38/hotshot, "cost" = 800, "max_supply" = 3),
		list("path" = /obj/item/ammo_box/c38/iceblox, "cost" = 800, "max_supply" = 3),
		list("path" = /obj/item/ammo_box/c38/dart, "cost" = 800, "max_supply" = 3),
		// -- WT550 SMG magazines --
		list("path" = /obj/item/ammo_box/magazine/wt550m9, "cost" = 800, "max_supply" = 6),
		// -- 7.62mm rifle ammo (bolt-action) --
		list("path" = /obj/item/ammo_box/a762, "cost" = 500, "max_supply" = 4),
		// -- Firing pins --
		list("path" = /obj/item/storage/box/firingpins, "cost" = 800, "max_supply" = 4),
		list("path" = /obj/item/storage/box/firingpins/paywall, "cost" = 1000, "max_supply" = 3),
		// -- Storage --
		list("path" = /obj/item/storage/belt/bandolier, "cost" = 500, "max_supply" = 4, "small_item" = FALSE),
	)

// =============================================================================
// GRENADES & EXPLOSIVES
// =============================================================================

/datum/cargo_list/weaponry_grenades
	access_budget = ACCESS_SECURITY
	crate_type = /obj/structure/closet/crate
	small_item = TRUE
	entries = list(
		// -- Standard grenades (SecTech, security belts, warden locker) --
		list("path" = /obj/item/grenade/flashbang, "cost" = 200, "max_supply" = 6),
		list("path" = /obj/item/grenade/empgrenade, "cost" = 500, "max_supply" = 4),
		list("path" = /obj/item/grenade/smokebomb, "cost" = 200, "max_supply" = 4),
		// -- Grenade boxes --
		list("path" = /obj/item/storage/box/flashbangs, "cost" = 800, "max_supply" = 3),
		list("path" = /obj/item/storage/box/flashes, "cost" = 600, "max_supply" = 3),
	)

/datum/cargo_list/weaponry_grenades_armory
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon
	small_item = TRUE
	entries = list(
		// -- Armory grenades --
		list("path" = /obj/item/grenade/chem_grenade/teargas, "cost" = 600, "max_supply" = 4),
		list("path" = /obj/item/grenade/stingbang, "cost" = 600, "max_supply" = 4),
		// -- Armory grenade boxes --
		list("path" = /obj/item/storage/box/teargas, "cost" = 1800, "max_supply" = 2),
		list("path" = /obj/item/storage/box/stingbangs, "cost" = 2000, "max_supply" = 2),
		// -- Deployable mines --
		list("path" = /obj/item/deployablemine/smartstun, "cost" = 1200, "max_supply" = 4),
		list("path" = /obj/item/deployablemine/stun, "cost" = 700, "max_supply" = 6),
		// -- Implant kits --
		list("path" = /obj/item/storage/box/trackimp, "cost" = 1500, "max_supply" = 3),
	)

// =============================================================================
// WEAPONRY CRATES
// Only for dangerous kits or themed bundles requiring special handling.
// Standard ammunition and individual items should be purchased from lists above.
// =============================================================================

/datum/cargo_crate/weaponry
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/cargo_crate/weaponry/fire
	name = "Incendiary Weapons Crate"
	cost = 6000
	max_supply = 1
	dangerous = TRUE
	contains = list(
		/obj/item/flamethrower/full,
		/obj/item/tank/internals/plasma,
		/obj/item/tank/internals/plasma,
		/obj/item/tank/internals/plasma,
		/obj/item/grenade/chem_grenade/incendiary,
		/obj/item/grenade/chem_grenade/incendiary,
		/obj/item/grenade/chem_grenade/incendiary,
	)
	crate_type = /obj/structure/closet/crate/secure/plasma
