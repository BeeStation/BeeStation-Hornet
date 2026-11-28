/datum/storage/belt
	max_specific_storage = WEIGHT_CLASS_LARGE
	max_total_storage = 56

/// Standard utility belt
/datum/storage/belt/utility

/datum/storage/belt/utility/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(list(
		/obj/item/crowbar,
		/obj/item/powertool,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/multitool,
		/obj/item/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/geiger_counter,
		/obj/item/extinguisher/mini,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/holosign_creator/atmos,
		/obj/item/holosign_creator/engineering,
		/obj/item/forcefield_projector,
		/obj/item/assembly/signaler,
		/obj/item/lightreplacer,
		/obj/item/construction/rcd,
		/obj/item/pipe_dispenser,
		/obj/item/inducer,
		/obj/item/plunger,
		/obj/item/airlock_painter,
		/obj/item/shuttle_creator,
	))

/// Botanist belt
/datum/storage/belt/hydroponics

/datum/storage/belt/hydroponics/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(list(
		/obj/item/reagent_containers/spray,
		/obj/item/reagent_containers/cup/beaker,//those will usually be used for fertilizer
		/obj/item/reagent_containers/cup/bottle,//fertilizer bottles
		/obj/item/reagent_containers/syringe,//blood samples for pod cloning
		/obj/item/reagent_containers/dropper,//on request by forums users
		/obj/item/plant_analyzer,
		/obj/item/cultivator,
		/obj/item/hatchet,
		/obj/item/shovel/spade,
		/obj/item/disk/plantgene,
		/obj/item/wrench,//because botanists move around trays with those
		/obj/item/seeds,
		/obj/item/clothing/gloves/botanic_leather,
		/obj/item/rollingpaper,//dudeweed
		/obj/item/lighter,
		/obj/item/cigarette/pipe/cobpipe,
		/obj/item/cigarette/rollie,//dudeweedlmao
		/obj/item/gun/energy/floragun,
	))

/// Belt for clock cultists
/datum/storage/belt/clockwork

/datum/storage/belt/clockwork/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(list(
		/obj/item/crowbar,
		/obj/item/powertool,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/multitool,
		/obj/item/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/geiger_counter,
		/obj/item/extinguisher/mini,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/holosign_creator/atmos,
		/obj/item/holosign_creator/engineering,
		/obj/item/forcefield_projector,
		/obj/item/assembly/signaler,
		/obj/item/lightreplacer,
		/obj/item/construction/rcd,
		/obj/item/pipe_dispenser,
		/obj/item/inducer,
		/obj/item/plunger,
		/obj/item/clockwork/clockwork_slab,
		/obj/item/clockwork/replica_fabricator,
	))

/// Medical doctors
/datum/storage/belt/medical

/datum/storage/belt/medical/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(list(
		/obj/item/healthanalyzer,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/applicator,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/medspray,
		/obj/item/lighter,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/flashlight/pen,
		/obj/item/extinguisher/mini,
		/obj/item/reagent_containers/hypospray,
		/obj/item/sensor_device,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/lazarus_injector,
		/obj/item/bikehorn/rubberducky,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath/medical,
		/obj/item/surgical_drapes, //for true paramedics
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/surgicaldrill,
		/obj/item/retractor,
		/obj/item/cautery,
		/obj/item/hemostat,
		/obj/item/blood_filter,
		/obj/item/geiger_counter,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/stamp,
		/obj/item/clothing/glasses,
		/obj/item/wrench/medical,
		/obj/item/clothing/mask/muzzle,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/bag/bio,
		/obj/item/reagent_containers/blood,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/gun/syringe/syndicate,
		/obj/item/implantcase,
		/obj/item/implant,
		/obj/item/implanter,
		/obj/item/pinpointer/crew,
		/obj/item/holosign_creator/medical,
		/obj/item/construction/plumbing,
		/obj/item/plunger,
		/obj/item/flesh_shears,
	))

/// Medical ERT belt
/datum/storage/belt/medical/ert

/datum/storage/belt/medical/ert/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	can_hold[/obj/item/gun/medbeam] = TRUE

/// Security belt
/datum/storage/belt/security
	open_sound = 'sound/items/handling/holster_open.ogg'
	rustle_sound = null

/datum/storage/belt/security/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(list(
		/obj/item/melee/baton,
		/obj/item/melee/tonfa,
		/obj/item/melee/baton,
		/obj/item/grenade,
		/obj/item/reagent_containers/peppercloud_deployer,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash/handheld,
		/obj/item/clothing/glasses,
		/obj/item/ammo_casing/shotgun,
		/obj/item/food/donut,
		/obj/item/knife/combat,
		/obj/item/flashlight/seclite,
		/obj/item/melee/baton/telescopic,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/holosign_creator/security,
		/obj/item/club,
		/obj/item/shield/riot/tele,
		/obj/item/gun/ballistic/taser,
		/obj/item/ammo_casing/taser,
	))

/// Explorer webbing
/datum/storage/belt/mining

/datum/storage/belt/mining/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(list(
		/obj/item/crowbar,
		/obj/item/powertool,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/multitool,
		/obj/item/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/analyzer,
		/obj/item/extinguisher/mini,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/resonator,
		/obj/item/mining_scanner,
		/obj/item/pickaxe,
		/obj/item/shovel,
		/obj/item/stack/sheet/animalhide,
		/obj/item/stack/sheet/sinew,
		/obj/item/stack/sheet/bone,
		/obj/item/lighter,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/reagent_containers/cup/glass/bottle,
		/obj/item/stack/medical,
		/obj/item/knife/combat/survival,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/reagent_containers/hypospray,
		/obj/item/gps,
		/obj/item/storage/bag/ore,
		/obj/item/survivalcapsule,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/reagent_containers/applicator,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/ore,
		/obj/item/reagent_containers/cup/glass,
		/obj/item/reagent_containers/cup/glass/bottle,
		/obj/item/organ/regenerative_core,
		/obj/item/wormhole_jaunter,
		/obj/item/storage/bag/plants,
		/obj/item/stack/marker_beacon,
		/obj/item/restraints/legcuffs/bola/watcher,
		/obj/item/claymore/bone,
		/obj/item/skeleton_key,
		/obj/item/discovery_scanner,
		/obj/item/gun/energy/e_gun/mini/exploration,
		/obj/item/gun/energy/recharge/kinetic_accelerator,
		/obj/item/gun/energy/plasmacutter,
		/obj/item/grenade/exploration,
		/obj/item/exploration_detonator,
		/obj/item/research_disk_pinpointer,
		/obj/item/key,
	))

/// Ashwalker belt
/datum/storage/belt/mining/primitive
	max_slots = 5

/// Wizard's soulstone belt
/datum/storage/belt/soulstone
	max_slots = 6

/datum/storage/belt/soulstone/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(/obj/item/soulstone)

/// Wrestling champion belt
/datum/storage/belt/champion
	max_slots = 1

/datum/storage/belt/champion/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(/obj/item/clothing/mask/luchador)

/// Chest rig
/datum/storage/belt/military
	max_specific_storage = WEIGHT_CLASS_SMALL

/// Snack rig
/datum/storage/belt/military/snacks
	max_slots = 6

/datum/storage/belt/military/snacks/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(list(
		/obj/item/food,
		/obj/item/reagent_containers/cup/glass,
		/obj/item/reagent_containers/cup/soda_cans,
	))

/// Grenadier belt
/datum/storage/belt/grenade
	max_slots = 30
	numerical_stacking = TRUE
	max_total_storage = 60

/datum/storage/belt/grenade/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(list(
		/obj/item/grenade,
		/obj/item/screwdriver,
		/obj/item/lighter,
		/obj/item/multitool,
		/obj/item/reagent_containers/cup/glass/bottle/molotov,
		/obj/item/grenade/plastic/c4,
		/obj/item/food/grown/cherry_bomb,
		/obj/item/food/grown/firelemon,
	))

/// Wizard's wand belt
/datum/storage/belt/wand
	max_slots = 6

/datum/storage/belt/wand/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(/obj/item/gun/magic/wand)

/// Janitor belt
/datum/storage/belt/janitor

/datum/storage/belt/janitor/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(list(
		/obj/item/grenade/chem_grenade,
		/obj/item/lightreplacer,
		/obj/item/flashlight,
		/obj/item/reagent_containers/spray,
		/obj/item/reagent_containers/cup/bucket,
		/obj/item/soap,
		/obj/item/holosign_creator/janibarrier,
		/obj/item/forcefield_projector,
		/obj/item/key/janitor,
		/obj/item/clothing/gloves,
		/obj/item/melee/flyswatter,
		/obj/item/assembly/mousetrap,
		/obj/item/paint/paint_remover,
		/obj/item/pushbroom,
	))

/// ERT Janitor belt
/datum/storage/belt/ert_janitor

/datum/storage/belt/ert_janitor/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(list(
		/obj/item/grenade/chem_grenade,
		/obj/item/lightreplacer,
		/obj/item/flashlight,
		/obj/item/reagent_containers/spray,
		/obj/item/reagent_containers/cup/bucket,
		/obj/item/soap,
		/obj/item/holosign_creator/janibarrier,
		/obj/item/forcefield_projector,
		/obj/item/key/janitor,
		/obj/item/clothing/gloves,
		/obj/item/melee/flyswatter,
		/obj/item/assembly/mousetrap,
		/obj/item/paint/paint_remover,
		/obj/item/pushbroom,
		/obj/item/storage/bag/trash/bluespace,
		/obj/item/storage/bag/trash,
	))

/// Bandolier
/datum/storage/belt/bandolier
	max_slots = 18
	max_total_storage = 18
	numerical_stacking = TRUE

/datum/storage/belt/bandolier/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(/obj/item/ammo_casing/shotgun)

/// Bandolier except it holds .38
/datum/storage/belt/bandolier_western
	max_slots = 21
	max_total_storage = 18
	numerical_stacking = TRUE

/datum/storage/belt/bandolier_western/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(/obj/item/ammo_casing/c38)

/// Arrow quiver
/datum/storage/belt/quiver
	max_slots = 15
	numerical_stacking = TRUE

/datum/storage/belt/quiver/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(/obj/item/ammo_casing/caseless/arrow)

/// Fannypack
/datum/storage/belt/fannypack
	max_slots = 5
	max_specific_storage = WEIGHT_CLASS_SMALL

/datum/storage/belt/captain_sabre
	max_slots = 1
	do_rustle = FALSE
	max_specific_storage = WEIGHT_CLASS_BULKY

/datum/storage/belt/captain_sabre/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(/obj/item/melee/sabre, /obj/item/melee/sabre/mime)

/datum/storage/belt/mime_sabre
	max_slots = 1
	do_rustle = FALSE
	max_specific_storage = WEIGHT_CLASS_BULKY

/datum/storage/belt/mime_sabre/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(/obj/item/melee/sabre/mime)
