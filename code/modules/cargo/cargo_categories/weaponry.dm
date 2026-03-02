/**
 * # Weaponry Cargo Items
 *
 * Weapons, ammunition, and combat-related items.
 * Split into Melee, Ranged, Ammunition, and Grenades & Explosives.
 */

// =============================================================================
// MELEE WEAPONS
// =============================================================================

/datum/cargo_item/weaponry_melee
	access_budget = ACCESS_SECURITY

/datum/cargo_item/weaponry_melee/baton
	name = "Stun Baton"
	item_path = /obj/item/melee/baton/security/loaded
	cost = 750
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/weaponry_melee/combat_knife
	name = "Combat Knife"
	item_path = /obj/item/knife/combat
	cost = 700
	max_supply = 4
	small_item = TRUE
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/weaponry_melee/scythe
	name = "Scythe"
	item_path = /obj/item/scythe
	cost = 300
	max_supply = 3
	small_item = TRUE
	access_budget = FALSE

// =============================================================================
// RANGED WEAPONS
// =============================================================================

/datum/cargo_item/weaponry_ranged
	access_budget = ACCESS_SECURITY

/datum/cargo_item/weaponry_ranged/taser
	name = "Taser"
	item_path = /obj/item/gun/ballistic/taser
	cost = 900
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/weaponry_ranged/sec_pistol
	name = "Security Pistol"
	item_path = /obj/item/gun/ballistic/automatic/pistol/security
	cost = 1200
	max_supply = 4
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	small_item = TRUE

/datum/cargo_item/weaponry_ranged/dragnet
	name = "DRAGnet Gun"
	item_path = /obj/item/gun/energy/e_gun/dragnet
	cost = 2000
	max_supply = 3
	small_item = TRUE
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/weaponry_ranged/energy_gun
	name = "Energy Gun"
	item_path = /obj/item/gun/energy/e_gun
	cost = 3500
	max_supply = 3
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/weaponry_ranged/laser_gun
	name = "Laser Gun"
	item_path = /obj/item/gun/energy/laser
	cost = 2500
	max_supply = 4
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/weaponry_ranged/riot_shotgun
	name = "Riot Shotgun"
	item_path = /obj/item/gun/ballistic/shotgun/riot
	cost = 2500
	max_supply = 4
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/weaponry_ranged/combat_shotgun
	name = "Combat Shotgun"
	item_path = /obj/item/gun/ballistic/shotgun/automatic/combat
	cost = 3000
	max_supply = 3
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/weaponry_ranged/wt550
	name = "WT-550 Auto Rifle"
	item_path = /obj/item/gun/ballistic/automatic/wt550
	cost = 3000
	max_supply = 3
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/weaponry_ranged/flamethrower
	name = "Flamethrower"
	item_path = /obj/item/flamethrower/full
	cost = 2000
	max_supply = 2
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	dangerous = TRUE

// =============================================================================
// AMMUNITION
// =============================================================================

/datum/cargo_item/weaponry_ammo
	access_budget = ACCESS_SECURITY

/datum/cargo_item/weaponry_ammo/taser_cartridge_box
	name = "Taser Cartridge Box"
	item_path = /obj/item/ammo_box/taser
	cost = 500
	max_supply = 4
	small_item = TRUE

/datum/cargo_item/weaponry_ammo/taser_cell
	name = "Taser Cell"
	item_path = /obj/item/ammo_casing/taser
	cost = 200
	max_supply = 6
	small_item = TRUE

/datum/cargo_item/weaponry_ammo/sec_pistol_ammo
	name = ".200 Law Ammo Box"
	item_path = /obj/item/ammo_box/x200law
	cost = 1200
	max_supply = 3
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	small_item = TRUE

/datum/cargo_item/weaponry_ammo/sec_pistol_mag
	name = ".200 Law Magazine"
	item_path = /obj/item/ammo_box/magazine/x200law/empty
	cost = 400
	max_supply = 5
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	small_item = TRUE

/datum/cargo_item/weaponry_ammo/dumdum_ammo
	name = ".38 Dum-Dum Ammo"
	item_path = /obj/item/ammo_box/c38/dumdum
	cost = 1000
	max_supply = 2
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	small_item = TRUE

/datum/cargo_item/weaponry_ammo/match_ammo
	name = ".38 Match Ammo"
	item_path = /obj/item/ammo_box/c38/match
	cost = 700
	max_supply = 2
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	small_item = TRUE

/datum/cargo_item/weaponry_ammo/wt550_mag
	name = "WT-550 9mm Magazine"
	item_path = /obj/item/ammo_box/magazine/wt550m9
	cost = 800
	max_supply = 6
	small_item = TRUE
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/weaponry_ammo/firing_pin_box
	name = "Firing Pin Box"
	item_path = /obj/item/storage/box/firingpins
	cost = 800
	max_supply = 4
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	small_item = TRUE

/datum/cargo_item/weaponry_ammo/firing_pin_paywall
	name = "Paywall Firing Pin Box"
	item_path = /obj/item/storage/box/firingpins/paywall
	cost = 1000
	max_supply = 3
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	small_item = TRUE

/datum/cargo_item/weaponry_ammo/bandolier
	name = "Bandolier"
	item_path = /obj/item/storage/belt/bandolier
	cost = 500
	max_supply = 4
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

// =============================================================================
// GRENADES & EXPLOSIVES
// =============================================================================

/datum/cargo_item/weaponry_grenades
	access_budget = ACCESS_SECURITY

/datum/cargo_item/weaponry_grenades/stingbang
	name = "Stingbang Grenade"
	item_path = /obj/item/grenade/stingbang
	cost = 600
	max_supply = 4
	access = ACCESS_ARMORY
	small_item = TRUE

/datum/cargo_item/weaponry_grenades/stingbang_box
	name = "Stingbang Grenade Box"
	item_path = /obj/item/storage/box/stingbangs
	cost = 2000
	max_supply = 2
	access = ACCESS_ARMORY
	small_item = TRUE

/datum/cargo_item/weaponry_grenades/smart_mine
	name = "Smart Stun Mine"
	item_path = /obj/item/deployablemine/smartstun
	cost = 1200
	max_supply = 4
	small_item = TRUE
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

/datum/cargo_item/weaponry_grenades/stun_mine
	name = "Stun Mine"
	item_path = /obj/item/deployablemine/stun
	cost = 700
	max_supply = 6
	small_item = TRUE
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY

// =============================================================================
// WEAPONRY CRATES
// =============================================================================

/datum/cargo_crate/weaponry
	access = ACCESS_ARMORY
	access_budget = ACCESS_ARMORY
	crate_type = /obj/structure/closet/crate/secure/weapon

/datum/cargo_crate/weaponry/ammo
	name = "Ammunition Crate"
	cost = 4000
	max_supply = 2
	contains = list(
		/obj/item/ammo_box/magazine/wt550m9,
		/obj/item/ammo_box/magazine/wt550m9,
		/obj/item/storage/box/lethalshot,
		/obj/item/storage/box/lethalshot,
		/obj/item/storage/box/lethalshot,
		/obj/item/storage/box/rubbershot,
		/obj/item/storage/box/rubbershot,
		/obj/item/storage/box/rubbershot,
		/obj/item/ammo_box/c38/trac,
		/obj/item/ammo_box/c38/hotshot,
		/obj/item/ammo_box/c38/iceblox,
	)

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

/datum/cargo_crate/weaponry/trackingimp
	name = "Tracking Implant Crate"
	cost = 3000
	max_supply = 2
	contains = list(
		/obj/item/storage/box/trackimp,
		/obj/item/ammo_box/c38/trac,
		/obj/item/ammo_box/c38/trac,
		/obj/item/ammo_box/c38/trac,
	)

/datum/cargo_crate/weaponry/russian
	name = "Russian Surplus Crate"
	cost = 7500
	max_supply = 1
	contains = list(
		/obj/item/food/rationpack,
		/obj/item/ammo_box/a762,
		/obj/item/storage/toolbox/ammo,
		/obj/item/clothing/suit/armor/vest/russian,
		/obj/item/clothing/head/helmet/rus_helmet,
		/obj/item/clothing/shoes/russian,
		/obj/item/clothing/gloves/tackler/combat,
		/obj/item/clothing/under/syndicate/rus_army,
		/obj/item/clothing/under/costume/soviet,
		/obj/item/clothing/mask/russian_balaclava,
		/obj/item/clothing/head/helmet/rus_ushanka,
		/obj/item/clothing/suit/armor/vest/russian_coat,
		/obj/item/gun/ballistic/rifle/boltaction,
		/obj/item/gun/ballistic/rifle/boltaction,
	)

/datum/cargo_crate/weaponry/russian/fill(obj/structure/closet/crate/C)

/datum/cargo_crate/weaponry/western
	name = "Western Arms Crate"
	cost = 7500
	max_supply = 1
	contains = list(
		/obj/item/ammo_box/c38/box,
		/obj/item/storage/toolbox/ammo/c38,
		/obj/item/mob_lasso,
		/obj/item/clothing/shoes/workboots/mining,
		/obj/item/clothing/gloves/botanic_leather,
		/obj/item/clothing/gloves/color/black,
		/obj/item/clothing/head/cowboy,
		/obj/item/clothing/head/costume/sombrero,
		/obj/item/clothing/head/costume/sombrero/green,
		/obj/item/storage/belt/bandolier/western,
		/obj/item/gun/ballistic/rifle/leveraction,
		/obj/item/gun/ballistic/rifle/leveraction,
	)

/datum/cargo_crate/weaponry/western/fill(obj/structure/closet/crate/C)

/datum/cargo_crate/weaponry/supplies
	name = "Security Supplies Crate"
	cost = 3000
	max_supply = 2
	access_budget = ACCESS_SECURITY
	contains = list(
		/obj/item/storage/box/flashbangs,
		/obj/item/storage/box/teargas,
		/obj/item/storage/box/flashes,
		/obj/item/storage/box/handcuffs,
	)
	crate_type = /obj/structure/closet/crate/secure/gear
