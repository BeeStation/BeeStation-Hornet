/obj/effect/abstract/open_area_marker
	name = "open area marker"
	icon = 'icons/obj/device.dmi'
	icon_state = "pincomp_arrow_far"

/obj/effect/abstract/open_area_marker/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	return INITIALIZE_HINT_QDEL

/obj/effect/abstract/doorway_marker
	name = "doorway marker"
	icon = 'icons/obj/device.dmi'
	icon_state = "pincomp_arrow_medium"

/obj/effect/abstract/doorway_marker/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	return INITIALIZE_HINT_QDEL

//Basic loot, utility and maybe some weapons
//Shouldnt contain illegal tech
/obj/effect/spawner/lootdrop/ruinloot/basic
	loot = list(
		"" = 12,
		/obj/item/melee/classic_baton/police = 3,
		/obj/item/melee/classic_baton/police/telescopic = 2,
		/obj/item/storage/firstaid/regular = 1,
		/obj/item/storage/firstaid/toxin = 1,
		/obj/item/storage/firstaid/brute = 1,
		/obj/item/storage/firstaid/fire = 1,
		/obj/item/grenade/smokebomb = 1,
		/obj/item/storage/belt/utility/full = 1,
		/obj/item/shield/riot/tele = 1,
		/obj/item/melee/baton/loaded = 1,
		/obj/item/gun/energy/e_gun/mini = 1,
		/obj/item/seeds/random = 1,
		/obj/item/gun/energy/floragun = 1,
		/obj/item/stack/spacecash/c1000 = 2,
		/obj/item/grenade/exploration = 1,
	)

//Medical stuff
/obj/effect/spawner/lootdrop/ruinloot/medical
	loot = list(
		"" = 13,
		/obj/item/storage/firstaid/regular = 1,
		/obj/item/storage/firstaid/toxin = 1,
		/obj/item/storage/firstaid/brute = 1,
		/obj/item/storage/firstaid/fire = 1,
		/obj/item/storage/backpack/duffelbag/med/surgery = 1,
		/obj/item/hemostat = 1,
		/obj/item/retractor = 1,
		/obj/item/scalpel = 1,
		/obj/item/blood_filter = 1,
		/obj/item/reagent_containers/medspray/sterilizine = 1,
		/obj/item/reagent_containers/medspray/silver_sulf = 1,
		/obj/item/reagent_containers/medspray/styptic = 1,
		/obj/item/reagent_containers/cup/glass/bottle/synthflesh = 1,
		/obj/item/clothing/glasses/hud/health/sunglasses = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/stack/medical/bruise_pack = 1,
		/obj/item/stack/medical/ointment = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/reagent_containers/cup/bottle/epinephrine = 1,
		/obj/item/reagent_containers/cup/bottle/charcoal = 1,
		/obj/item/storage/pill_bottle/floorpill/full = 1,
		/obj/item/storage/pill_bottle/antirad = 1,
		/obj/item/clothing/neck/stethoscope = 1,
		/obj/item/reagent_containers/spray/cleaner = 1,
		/obj/item/storage/belt/medical = 1,
		/obj/item/defibrillator/compact/loaded = 1,
		/obj/item/pinpointer/crew = 1,
	)

//Science stuff
/obj/effect/spawner/lootdrop/ruinloot/science
	loot = list(
		"" = 18,
		/obj/item/laser_pointer = 3,
		/obj/item/storage/toolbox/mechanical = 2,
		/obj/item/paicard = 5,
		/obj/item/nanite_remote = 3,
		/obj/item/nanite_scanner = 3,
		/obj/item/disk/tech_disk = 5,
		/obj/item/assembly/prox_sensor = 6,
		/obj/item/bodypart/arm/right/robot = 4,
		/obj/item/gun/energy/wormhole_projector = 1,
		/obj/item/assembly/flash/handheld/weak = 2,
		/obj/item/stock_parts/cell/high = 1,
		/obj/item/stock_parts/manipulator/nano = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/capacitor/super = 1,
		/obj/item/stock_parts/matter_bin/super = 1,
		/obj/item/stock_parts/scanning_module/adv = 1,
		/obj/item/screwdriver = 6,
		/obj/item/storage/box/monkeycubes = 3,
		/obj/item/stack/sheet/mineral/plasma = 3,
		/obj/item/pipe_dispenser = 4,
		/obj/item/wrench = 6,
		/obj/item/assembly/signaler = 5,
		/obj/item/transfer_valve = 6,
		/obj/item/computer_hardware/hard_drive/role/rd = 3,
		/obj/item/radio = 5,
		/obj/item/camera = 4,
		/obj/item/encryptionkey/headset_sci = 3,
		/obj/item/aicard = 2,
		/obj/item/flamethrower = 2,
		/obj/item/tank/internals/plasma/full = 2,
		/obj/item/gps/science = 3,
		/obj/item/inducer/sci = 3,
		/obj/item/megaphone = 1,
		/obj/item/modular_computer/tablet/pda/preset/roboticist = 3,
		/obj/item/modular_computer/tablet/pda/preset/science = 3,
		/obj/item/pinpointer/crew = 4,
		/obj/item/reactive_armour_shell = 1,
		/obj/item/anomaly_neutralizer = 1,
		/obj/item/shuttle_creator = 1,
		/obj/item/soap = 1,
		/obj/item/borg/upgrade/selfrepair = 1,
		/obj/item/borg/upgrade/speciality/botany = 1,
		/obj/item/borg/upgrade/defib = 1,
		/obj/item/taperecorder = 5,
		/obj/item/clothing/mask/facehugger/lamarr = 1
	)

//Security stuff
/obj/effect/spawner/lootdrop/ruinloot/security
	loot = list(
		"" = 18,
		/obj/item/assembly/flash/handheld = 4,
		/obj/item/melee/baton/loaded = 3,
		/obj/item/restraints/handcuffs = 4,
		/obj/item/storage/lockbox/loyalty = 1,
		/obj/item/storage/box/handcuffs = 2,
		/obj/item/flashlight/seclite = 4,
		/obj/item/flashbulb = 3,
		/obj/item/flashbulb/bomb = 1,
		/obj/item/restraints/legcuffs/bola/energy = 1,
		/obj/item/clothing/glasses/hud/security/sunglasses = 2,
		/obj/item/clothing/under/rank/security = 1,
		/obj/item/clothing/suit/armor/vest = 2,
		/obj/item/clothing/suit/armor/bulletproof = 1,
		/obj/item/storage/secure/briefcase = 1,
		/obj/item/reagent_containers/cup/rag = 1,
		/obj/item/reagent_containers/cup/bottle/chloralhydrate = 1,
		/obj/item/grenade/flashbang = 2,
		/obj/item/grenade/chem_grenade/teargas = 1,
		/obj/item/reagent_containers/peppercloud_deployer = 1,
		/obj/item/clothing/mask/gas/sechailer = 1,
		/obj/item/grenade/exploration = 1,
	)

//Armory stuff
/obj/effect/spawner/lootdrop/ruinloot/armory
	loot = list(
		"" = 30,
		/obj/item/gun/energy/disabler = 5,
		/obj/item/gun/energy/e_gun = 2,
		/obj/item/gun/energy/laser = 3,
		/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag = 4,
		/obj/item/gun/ballistic/automatic/wt550 = 1,
		/obj/item/gun/grenadelauncher/security = 1,
		/obj/item/key/security = 5,
		/obj/effect/spawner/lootdrop/armory_contraband = 1,
		/obj/item/clothing/suit/armor/laserproof = 1,
		/obj/item/gun/energy/ionrifle = 2,
		/obj/item/gun/energy/temperature = 2,
		/obj/item/gun/energy/e_gun/dragnet = 1,
		/obj/item/clothing/suit/armor/bulletproof = 4,
		/obj/item/clothing/head/helmet/alt = 4,
		/obj/item/clothing/suit/armor/riot = 1,
		/obj/item/clothing/head/helmet/toggleable/riot = 1,
		/obj/item/storage/lockbox/loyalty = 1,
		/obj/item/storage/fancy/donut_box = 6,
		/obj/item/storage/box/teargas = 2,
		/obj/item/storage/box/flashbangs = 2,
		/obj/item/shield/riot = 1,
		/obj/item/gun/ballistic/shotgun/riot = 1,
		/obj/item/ammo_box/magazine/wt550m9 = 3,
		/obj/item/ammo_box/magazine/wt550m9/wtap = 1,
		/obj/item/ammo_box/magazine/wt550m9/wtic = 1,
		/obj/item/ammo_box/magazine/pistolm9mm = 4,
		/obj/item/grenade/exploration = 2,
	)

//Important stuff like research disks
/obj/effect/spawner/lootdrop/ruinloot/important
	loot = list(
		"" = 4,
		/obj/item/disk/tech_disk/research/random = 24,
		/obj/item/xenoartifact/pre_labeled = 6,
		/obj/item/gun/energy/vortex = 3,
		/obj/item/gun/energy/alien = 1
	)
