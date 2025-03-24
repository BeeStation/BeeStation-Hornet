/obj/item/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	w_class = WEIGHT_CLASS_BULKY
	icon_state = "utilitybelt"
	item_state = "utility"
	worn_icon_state = "utility"
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("whips", "lashes", "disciplines")
	attack_verb_simple = list("whip", "lash", "discipline")
	max_integrity = 300
	var/content_overlays = FALSE //If this is true, the belt will gain overlays based on what it's holding

/obj/item/storage/belt/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins belting [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/storage/belt/update_overlays()
	. = ..()
	if(content_overlays)
		for(var/obj/item/I in contents)
			. += I.get_belt_overlay()

/obj/item/storage/belt/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/storage/belt/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_LARGE
	atom_storage.max_slots = 7
	atom_storage.max_total_storage = 56

/obj/item/storage/belt/utility
	name = "toolbelt" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "Holds tools."
	icon_state = "utilitybelt"
	item_state = "utility"
	worn_icon_state = "utility"
	content_overlays = TRUE
	custom_price = 50
	drop_sound = 'sound/items/handling/toolbelt_drop.ogg'
	pickup_sound =  'sound/items/handling/toolbelt_pickup.ogg'

/obj/item/storage/belt/utility/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(
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
		/obj/item/shuttle_creator
		))

/obj/item/storage/belt/botanical
	name = "botanical belt"
	desc = "Can hold various botanical equipment."
	icon_state = "botanical"
	item_state = "botanical"
	worn_icon_state = "botanical"
	content_overlays = TRUE

/obj/item/storage/belt/botanical/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(
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
		/obj/item/clothing/mask/cigarette/pipe/cobpipe,
		/obj/item/clothing/mask/cigarette/rollie,//dudeweedlmao
		/obj/item/gun/energy/floragun
		))

/obj/item/storage/belt/utility/chief
	name = "\improper Chief Engineer's toolbelt" //"the Chief Engineer's toolbelt", because "Chief Engineer's toolbelt" is not a proper noun
	desc = "Holds tools, looks snazzy."
	icon_state = "utilitybelt_ce"
	item_state = "utility_ce"
	worn_icon_state = "utility_ce"

/obj/item/storage/belt/utility/chief/full
	preload = TRUE

/obj/item/storage/belt/utility/chief/full/PopulateContents()
	SSwardrobe.provide_type(/obj/item/powertool/hand_drill, src)
	SSwardrobe.provide_type(/obj/item/powertool/jaws_of_life, src)
	SSwardrobe.provide_type(/obj/item/weldingtool/experimental, src)//This can be changed if this is too much
	SSwardrobe.provide_type(/obj/item/multitool, src)
	SSwardrobe.provide_type(/obj/item/stack/cable_coil, src, MAXCOIL,pick("red","yellow","orange"))
	SSwardrobe.provide_type(/obj/item/extinguisher/mini, src)
	SSwardrobe.provide_type(/obj/item/analyzer/ranged, src)
	//much roomier now that we've managed to remove two tools

/obj/item/storage/belt/utility/chief/full/get_types_to_preload()
	var/list/to_preload = list() //Yes this is a pain. Yes this is the point
	to_preload += /obj/item/powertool/hand_drill
	to_preload += /obj/item/powertool/jaws_of_life
	to_preload += /obj/item/weldingtool/experimental
	to_preload += /obj/item/multitool
	to_preload += /obj/item/stack/cable_coil
	to_preload += /obj/item/extinguisher/mini
	to_preload += /obj/item/analyzer/ranged
	return to_preload

/obj/item/storage/belt/utility/full/PopulateContents()
	SSwardrobe.provide_type(/obj/item/screwdriver, src)
	SSwardrobe.provide_type(/obj/item/wrench, src)
	SSwardrobe.provide_type(/obj/item/weldingtool, src)
	SSwardrobe.provide_type(/obj/item/crowbar, src)
	SSwardrobe.provide_type(/obj/item/wirecutters, src)
	SSwardrobe.provide_type(/obj/item/multitool, src)
	SSwardrobe.provide_type(/obj/item/stack/cable_coil, src,MAXCOIL,pick("red","yellow","orange"))

/obj/item/storage/belt/utility/full/get_types_to_preload()
	var/list/to_preload = list() //Yes this is a pain. Yes this is the point
	to_preload += /obj/item/screwdriver
	to_preload += /obj/item/wrench
	to_preload += /obj/item/weldingtool
	to_preload += /obj/item/crowbar
	to_preload += /obj/item/wirecutters
	to_preload += /obj/item/multitool
	to_preload += /obj/item/stack/cable_coil
	return to_preload

/obj/item/storage/belt/utility/full/engi/PopulateContents()
	SSwardrobe.provide_type(/obj/item/screwdriver, src)
	SSwardrobe.provide_type(/obj/item/wrench, src)
	SSwardrobe.provide_type(/obj/item/weldingtool/largetank, src)
	SSwardrobe.provide_type(/obj/item/crowbar, src)
	SSwardrobe.provide_type(/obj/item/wirecutters, src)
	SSwardrobe.provide_type(/obj/item/multitool, src)
	SSwardrobe.provide_type(/obj/item/stack/cable_coil, src, MAXCOIL, pick("red","yellow","orange"))

/obj/item/storage/belt/utility/full/engi/get_types_to_preload()
	var/list/to_preload = list() //Yes this is a pain. Yes this is the point
	to_preload += /obj/item/screwdriver
	to_preload += /obj/item/wrench
	to_preload += /obj/item/weldingtool/largetank
	to_preload += /obj/item/crowbar
	to_preload += /obj/item/wirecutters
	to_preload += /obj/item/multitool
	to_preload += /obj/item/stack/cable_coil
	return to_preload

/obj/item/storage/belt/utility/atmostech/PopulateContents()
	SSwardrobe.provide_type(/obj/item/screwdriver, src)
	SSwardrobe.provide_type(/obj/item/wrench, src)
	SSwardrobe.provide_type(/obj/item/weldingtool, src)
	SSwardrobe.provide_type(/obj/item/crowbar, src)
	SSwardrobe.provide_type(/obj/item/wirecutters, src)
	SSwardrobe.provide_type(/obj/item/t_scanner, src)
	SSwardrobe.provide_type(/obj/item/extinguisher/mini, src)

/obj/item/storage/belt/utility/atmostech/get_types_to_preload()
	var/list/to_preload = list() //Yes this is a pain. Yes this is the point
	to_preload += /obj/item/screwdriver
	to_preload += /obj/item/wrench
	to_preload += /obj/item/weldingtool
	to_preload += /obj/item/crowbar
	to_preload += /obj/item/wirecutters
	to_preload += /obj/item/t_scanner
	to_preload += /obj/item/extinguisher/mini
	return to_preload

/obj/item/storage/belt/utility/servant
	var/slab = null
	var/replicator = null

/obj/item/storage/belt/utility/servant/drone
	slab = /obj/item/clockwork/clockwork_slab
	replicator = /obj/item/clockwork/replica_fabricator

/obj/item/storage/belt/utility/servant/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(
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
		/obj/item/clockwork/replica_fabricator
		))

/obj/item/storage/belt/utility/servant/PopulateContents()
	if(slab)
		new slab(src)
	else
		new/obj/item/multitool(src)
	if(replicator)
		new replicator(src)
	else
		new /obj/item/stack/cable_coil/orange(src)
	new /obj/item/screwdriver/brass(src)
	new /obj/item/wirecutters/brass(src)
	new /obj/item/wrench/brass(src)
	new /obj/item/crowbar/brass(src)
	new /obj/item/weldingtool/experimental/brass(src)

/obj/item/storage/belt/medical
	name = "medical belt"
	desc = "Can hold various medical equipment."
	icon_state = "medicalbelt"
	item_state = "medical"
	worn_icon_state = "medical"
	content_overlays = TRUE

/obj/item/storage/belt/medical/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(
		/obj/item/healthanalyzer,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/pill,
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
		/obj/item/extrapolator
		))

/obj/item/storage/belt/medical/ert
	name = "emergency response medical belt"
	desc = "A belt containing field surgical supplies for use by medical response teams."

/obj/item/storage/belt/medical/ert/Initialize(mapload)
	. = ..()
	atom_storage.can_hold[/obj/item/gun/medbeam] = TRUE

/obj/item/storage/belt/medical/ert/PopulateContents()
	new /obj/item/healthanalyzer/advanced(src)
	new /obj/item/surgical_drapes(src)
	new /obj/item/scalpel/advanced(src)
	new /obj/item/retractor/advanced(src)
	new /obj/item/surgicaldrill/advanced(src)
	new /obj/item/reagent_containers/medspray/sterilizine(src)
	new /obj/item/gun/medbeam(src)

/obj/item/storage/belt/security
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	worn_icon_state = "security"
	content_overlays = TRUE

/obj/item/storage/belt/security/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(
		/obj/item/melee/baton,
		/obj/item/melee/tonfa,
		/obj/item/melee/classic_baton/police,
		/obj/item/grenade,
		/obj/item/reagent_containers/peppercloud_deployer,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash/handheld,
		/obj/item/clothing/glasses,
		/obj/item/ammo_casing/shotgun,
		/obj/item/food/donut,
		/obj/item/knife/combat,
		/obj/item/flashlight/seclite,
		/obj/item/melee/classic_baton/police/telescopic,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/holosign_creator/security,
		/obj/item/club,
		/obj/item/shield/riot/tele
		))

/obj/item/storage/belt/security/full/PopulateContents()
	new /obj/item/reagent_containers/peppercloud_deployer(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/melee/baton/loaded(src)
	update_appearance()

/obj/item/storage/belt/security/deputy
	name = "deputy security belt"

/obj/item/storage/belt/security/deputy/PopulateContents()
	new /obj/item/melee/classic_baton/police/deputy(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/restraints/handcuffs/cable(src)
	new /obj/item/reagent_containers/peppercloud_deployer(src)
	new /obj/item/flashlight/seclite(src)
	update_appearance()

/obj/item/storage/belt/security/webbing
	name = "security webbing"
	desc = "Unique and versatile chest rig, can hold security gear."
	icon_state = "securitywebbing"
	item_state = "securitywebbing"
	worn_icon_state = "securitywebbing"
	content_overlays = FALSE
	custom_premium_price = 800

/obj/item/storage/belt/mining
	name = "explorer's webbing"
	desc = "A versatile chest rig, cherished by miners and hunters alike."
	icon_state = "explorer1"
	item_state = "explorer1"
	worn_icon_state = "explorer1"

/obj/item/storage/belt/mining/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(
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
		/obj/item/reagent_containers/pill,
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
		/obj/item/research_disk_pinpointer
		))


/obj/item/storage/belt/mining/vendor
	contents = newlist(/obj/item/survivalcapsule)

/obj/item/storage/belt/mining/alt
	icon_state = "explorer2"
	item_state = "explorer2"
	worn_icon_state = "explorer2"

/obj/item/storage/belt/mining/primitive
	name = "hunter's belt"
	desc = "A versatile belt, woven from sinew."
	icon_state = "ebelt"
	item_state = "ebelt"
	worn_icon_state = "ebelt"

/obj/item/storage/belt/mining/primitive/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 5

/obj/item/storage/belt/soulstone
	name = "soul stone belt"
	desc = "Designed for ease of access to the shards during a fight, as to not let a single enemy spirit slip away."
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	worn_icon_state = "soulstonebelt"

/obj/item/storage/belt/soulstone/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 6
	atom_storage.set_holdable(list(
		/obj/item/soulstone
		))

/obj/item/storage/belt/soulstone/full/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/soulstone/mystic(src)

/obj/item/storage/belt/soulstone/full/chappy/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/soulstone/anybody/chaplain(src)

/obj/item/storage/belt/soulstone/full/purified/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/soulstone/anybody/purified(src)

/obj/item/storage/belt/champion
	name = "championship belt"
	desc = "Proves to the world that you are the strongest!"
	icon_state = "championbelt"
	item_state = "champion"
	worn_icon_state = "champion"
	custom_materials = list(/datum/material/gold=400)

/obj/item/storage/belt/champion/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 1
	atom_storage.set_holdable(list(
		/obj/item/clothing/mask/luchador
		))

/obj/item/storage/belt/military
	name = "chest rig"
	desc = "A set of tactical webbing worn by Syndicate boarding parties."
	icon_state = "militarywebbing"
	item_state = "militarywebbing"
	worn_icon_state = "militarywebbing"
	resistance_flags = FIRE_PROOF

/obj/item/storage/belt/military/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL

/obj/item/storage/belt/military/snack
	name = "tactical snack rig"

/obj/item/storage/belt/military/snack/Initialize(mapload)
	. = ..()
	var/sponsor = pick("DonkCo", "Waffle Co.", "Roffle Co.", "Gorlax Marauders", "Tiger Cooperative")
	desc = "A set of snack-tical webbing worn by athletes of the [sponsor] VR sports division."

/obj/item/storage/belt/military/snack/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 6
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	atom_storage.set_holdable(list(
		/obj/item/food,
		/obj/item/reagent_containers/cup/glass
		))
	var/amount = 5
	var/rig_snacks
	while(contents.len <= amount)
		rig_snacks = pick(list(
		/obj/item/food/candy,
		/obj/item/food/cheesiehonkers,
		/obj/item/food/cheesynachos,
		/obj/item/food/cubannachos,
		/obj/item/food/chips,
		/obj/item/food/donkpocket,
		/obj/item/food/sosjerky,
		/obj/item/food/syndicake,
		/obj/item/food/spacetwinkie,
		/obj/item/food/nachos,
		/obj/item/food/nugget,
		/obj/item/food/spaghetti/pastatomato,
		/obj/item/food/rofflewaffles,
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/nuka_cola,
		/obj/item/reagent_containers/cup/glass/dry_ramen,
		/obj/item/reagent_containers/cup/soda_cans/cola,
		/obj/item/reagent_containers/cup/soda_cans/dr_gibb,
		/obj/item/reagent_containers/cup/soda_cans/lemon_lime,
		/obj/item/reagent_containers/cup/soda_cans/pwr_game,
		/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind,
		/obj/item/reagent_containers/cup/soda_cans/space_up,
		/obj/item/reagent_containers/cup/soda_cans/starkist,
		))
		new rig_snacks(src)

/obj/item/storage/belt/military/abductor
	name = "agent belt"
	desc = "A belt used by abductor agents."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "belt"
	item_state = "security"
	worn_icon_state = "security"

/obj/item/storage/belt/military/abductor/full/PopulateContents()
	new /obj/item/screwdriver/abductor(src)
	new /obj/item/wrench/abductor(src)
	new /obj/item/weldingtool/abductor(src)
	new /obj/item/crowbar/abductor(src)
	new /obj/item/wirecutters/abductor(src)
	new /obj/item/multitool/abductor(src)
	new /obj/item/stack/cable_coil/white(src)

//Im pissed off at the amount of times I have to do this. So its a belt now
/obj/item/storage/belt/military/abductor/med
	name = "agent belt"
	desc = "A belt used by abductor agents."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "belt"
	item_state = "security"
	worn_icon_state = "security"

/obj/item/storage/belt/military/abductor/med/PopulateContents()
	new /obj/item/scalpel/alien(src)
	new /obj/item/hemostat/alien(src)
	new /obj/item/retractor/alien(src)
	new /obj/item/circular_saw/alien(src)
	new /obj/item/surgicaldrill/alien(src)
	new /obj/item/cautery/alien(src)
	new /obj/item/surgical_drapes(src)
	new /obj/item/blood_filter(src)

/obj/item/storage/belt/military/army
	name = "army belt"
	desc = "A belt used by military forces."
	icon_state = "grenadebeltold"
	item_state = "security"
	worn_icon_state = "security"

/obj/item/storage/belt/military/assault
	name = "assault belt"
	desc = "A tactical assault belt."
	icon_state = "assaultbelt"
	item_state = "security"
	worn_icon_state = "security"

/obj/item/storage/belt/grenade
	name = "grenadier belt"
	desc = "A belt for holding grenades."
	icon_state = "grenadebeltnew"
	item_state = "security"
	worn_icon_state = "security"

/obj/item/storage/belt/grenade/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 30
	atom_storage.numerical_stacking = TRUE
	atom_storage.max_total_storage = 60
	atom_storage.set_holdable(list(
		/obj/item/grenade,
		/obj/item/screwdriver,
		/obj/item/lighter,
		/obj/item/multitool,
		/obj/item/reagent_containers/cup/glass/bottle/molotov,
		/obj/item/grenade/plastic/c4,
		/obj/item/food/grown/cherry_bomb,
		/obj/item/food/grown/firelemon
		))

/obj/item/storage/belt/grenade/full/PopulateContents()
	var/static/items_inside = list(
		/obj/item/grenade/flashbang = 1,
		/obj/item/grenade/smokebomb = 4,
		/obj/item/grenade/empgrenade = 1,
		/obj/item/grenade/empgrenade = 1,
		/obj/item/grenade/frag = 10,
		/obj/item/grenade/gluon = 4,
		/obj/item/grenade/chem_grenade/incendiary = 2,
		/obj/item/grenade/chem_grenade/facid = 1,
		/obj/item/grenade/syndieminibomb = 2,
		/obj/item/screwdriver = 1,
		/obj/item/multitool = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/belt/grenade/full/webbing
	name = "grenadier chest rig"
	desc = "A set of tactical webbing stocked full of grenades."
	icon_state = "militarywebbing"
	item_state = "militarywebbing"
	worn_icon_state = "militarywebbing"

/obj/item/storage/belt/wands
	name = "wand belt"
	desc = "A belt designed to hold various rods of power. A veritable fanny pack of exotic magic."
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	worn_icon_state = "soulstonebelt"

/obj/item/storage/belt/wands/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 6
	atom_storage.set_holdable(list(
		/obj/item/gun/magic/wand
		))

/obj/item/storage/belt/wands/full/PopulateContents()
	new /obj/item/gun/magic/wand/death(src)
	new /obj/item/gun/magic/wand/resurrection(src)
	new /obj/item/gun/magic/wand/polymorph(src)
	new /obj/item/gun/magic/wand/teleport(src)
	new /obj/item/gun/magic/wand/door(src)
	new /obj/item/gun/magic/wand/fireball(src)

	for(var/obj/item/gun/magic/wand/W in contents) //All wands in this pack come in the best possible condition
		W.max_charges = initial(W.max_charges)
		W.charges = W.max_charges

/obj/item/storage/belt/janitor
	name = "janibelt"
	desc = "A belt used to hold most janitorial supplies."
	icon_state = "janibelt"
	item_state = "janibelt"
	worn_icon_state = "janibelt"

/obj/item/storage/belt/janitor/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(
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
		/obj/item/pushbroom
		))

/obj/item/storage/belt/janitor/full/PopulateContents()
	new /obj/item/lightreplacer(src)
	new /obj/item/reagent_containers/spray/cleaner(src)
	new /obj/item/soap/nanotrasen(src)
	new /obj/item/holosign_creator/janibarrier(src)
	new /obj/item/melee/flyswatter(src)
	new /obj/item/reagent_containers/cup/bucket(src)

/obj/item/storage/belt/bandolier
	name = "bandolier"
	desc = "A bandolier for holding shotgun ammunition."
	icon_state = "bandolier"
	item_state = "bandolier"
	worn_icon_state = "bandolier"

/obj/item/storage/belt/bandolier/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 18
	atom_storage.max_total_storage = 18
	atom_storage.numerical_stacking = TRUE
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/shotgun
		))

/obj/item/storage/belt/bandolier/western
	name = "sheriff's bandolier"
	desc = "A bandolier that has been retrofitted for .38 cartridges"

/obj/item/storage/belt/bandolier/western/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 21
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/c38
		))

/obj/item/storage/belt/bandolier/western/filled/PopulateContents()
	for(var/i in 1 to 21)
		new /obj/item/ammo_casing/c38(src)


/obj/item/storage/belt/quiver
	name = "leather quiver"
	desc = "A quiver made from the hide of some animal. Used to hold arrows."
	icon_state = "quiver"
	item_state = "quiver"
	worn_icon_state = "quiver"

/obj/item/storage/belt/quiver/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 15
	atom_storage.numerical_stacking = TRUE
	atom_storage.set_holdable(list(
		/obj/item/ammo_casing/caseless/arrow/wood,
		/obj/item/ammo_casing/caseless/arrow/ash,
		/obj/item/ammo_casing/caseless/arrow/bone,
		/obj/item/ammo_casing/caseless/arrow/bronze
		))

/obj/item/storage/belt/fannypack
	name = "fannypack"
	desc = "A dorky fannypack for keeping small items in."
	icon_state = "fannypack_leather"
	item_state = null
	worn_icon_state = "fannypack_leather"
	dying_key = DYE_REGISTRY_FANNYPACK
	custom_price = 15

/obj/item/storage/belt/fannypack/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 5
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL

/obj/item/storage/belt/fannypack/detective //Starting contents defined in detective.dm where the rest of their loadout is handled.
	name = "Worn belt"
	desc = "A weathered belt that is used for storing various gadgets"
	icon_state = "utilitybelt" //Placeholder for now.
	item_state = "utility"
	worn_icon_state = "utility"

/obj/item/storage/belt/fannypack/black
	name = "black fannypack"
	icon_state = "fannypack_black"
	worn_icon_state = "fannypack_black"

/obj/item/storage/belt/fannypack/red
	name = "red fannypack"
	icon_state = "fannypack_red"
	worn_icon_state = "fannypack_red"

/obj/item/storage/belt/fannypack/purple
	name = "purple fannypack"
	icon_state = "fannypack_purple"
	worn_icon_state = "fannypack_purple"

/obj/item/storage/belt/fannypack/blue
	name = "blue fannypack"
	icon_state = "fannypack_blue"
	worn_icon_state = "fannypack_blue"

/obj/item/storage/belt/fannypack/orange
	name = "orange fannypack"
	icon_state = "fannypack_orange"
	worn_icon_state = "fannypack_orange"

/obj/item/storage/belt/fannypack/white
	name = "white fannypack"
	icon_state = "fannypack_white"
	worn_icon_state = "fannypack_white"

/obj/item/storage/belt/fannypack/green
	name = "green fannypack"
	icon_state = "fannypack_green"
	worn_icon_state = "fannypack_green"

/obj/item/storage/belt/fannypack/pink
	name = "pink fannypack"
	icon_state = "fannypack_pink"
	worn_icon_state = "fannypack_pink"

/obj/item/storage/belt/fannypack/cyan
	name = "cyan fannypack"
	icon_state = "fannypack_cyan"
	worn_icon_state = "fannypack_cyan"

/obj/item/storage/belt/fannypack/yellow
	name = "yellow fannypack"
	icon_state = "fannypack_yellow"
	worn_icon_state = "fannypack_yellow"

/obj/item/storage/belt/fannypack/bustin
	name = "exterminator's belt"
	desc = " "
	icon_state = "bustinbelt"
	worn_icon_state = "fannypack_white"

/obj/item/storage/belt/sabre
	name = "sabre sheath"
	desc = "An ornate sheath designed to hold an officer's blade."
	icon_state = "sheath"
	item_state = "sheath"
	worn_icon_state = "sheath"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/belt/sabre/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

	atom_storage.max_slots = 1
	atom_storage.rustle_sound = FALSE
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.set_holdable(list(
		/obj/item/melee/sabre
		))

/obj/item/storage/belt/sabre/examine(mob/user)
	. = ..()
	if(length(contents))
		. += span_notice("Alt-click it to quickly draw the blade.")

/obj/item/storage/belt/sabre/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return
	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message("[user] takes [I] out of [src].", span_notice("You take [I] out of [src]."))
		user.put_in_hands(I)
		update_appearance()
	else
		to_chat(user, "[src] is empty.")

/obj/item/storage/belt/sabre/update_icon_state()
	icon_state = initial(icon_state)
	item_state = initial(item_state)
	worn_icon_state = initial(worn_icon_state)
	if(contents.len)
		icon_state += "-sabre"
		item_state += "-sabre"
		worn_icon_state += "-sabre"
	return ..()

/obj/item/storage/belt/sabre/PopulateContents()
	new /obj/item/melee/sabre(src)
	update_appearance()

/obj/item/storage/belt/sabre/mime
	name = "Baguette"
	desc = "Bon appetit!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "baguette"
	item_state = "baguette"
	worn_icon_state = "baguette"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT

/obj/item/storage/belt/sabre/mime/update_icon()
	icon_state = "baguette"
	item_state = "baguette"

/obj/item/storage/belt/sabre/mime/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 1
	atom_storage.rustle_sound = FALSE
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.set_holdable(list(
		/obj/item/melee/sabre/mime
		))

/obj/item/storage/belt/sabre/mime/PopulateContents()
	new /obj/item/melee/sabre/mime(src)
	update_icon()
