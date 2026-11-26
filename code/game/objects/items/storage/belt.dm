/obj/item/storage/belt
	abstract_type = /obj/item/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	w_class = WEIGHT_CLASS_BULKY
	stamina_damage = 10
	stamina_cost = 5
	stamina_critical_chance = 5

	icon_state = "utilitybelt"
	inhand_icon_state = "utility"
	worn_icon_state = "utility"
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("whips", "lashes", "disciplines")
	attack_verb_simple = list("whip", "lash", "discipline")
	max_integrity = 300
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'
	custom_price = 30
	storage_type = /datum/storage/belt
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
	update_appearance(UPDATE_OVERLAYS)

/obj/item/storage/belt/utility
	name = "toolbelt" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "Holds tools."
	icon_state = "utilitybelt"
	inhand_icon_state = "utility"
	worn_icon_state = "utility"
	content_overlays = TRUE
	custom_price = 50
	drop_sound = 'sound/items/handling/toolbelt/toolbelt_drop.ogg'
	pickup_sound =  'sound/items/handling/toolbelt/toolbelt_pickup.ogg'
	storage_type = /datum/storage/belt/utility

/obj/item/storage/belt/botanical
	name = "botanical belt"
	desc = "Can hold various botanical equipment."
	icon_state = "botanical"
	inhand_icon_state = "botanical"
	worn_icon_state = "botanical"
	content_overlays = TRUE
	storage_type = /datum/storage/belt/hydroponics

/obj/item/storage/belt/utility/chief
	name = "\improper Chief Engineer's toolbelt" //"the Chief Engineer's toolbelt", because "Chief Engineer's toolbelt" is not a proper noun
	desc = "Holds tools, looks snazzy."
	icon_state = "utilitybelt_ce"
	inhand_icon_state = "utility_ce"
	worn_icon_state = "utility_ce"

/obj/item/storage/belt/utility/chief/full
	preload = TRUE

/obj/item/storage/belt/utility/chief/full/PopulateContents()
	SSwardrobe.provide_type(/obj/item/powertool/hand_drill, src)
	SSwardrobe.provide_type(/obj/item/powertool/jaws_of_life, src)
	SSwardrobe.provide_type(/obj/item/weldingtool/experimental, src)//This can be changed if this is too much
	SSwardrobe.provide_type(/obj/item/multitool, src)
	SSwardrobe.provide_type(/obj/item/stack/cable_coil, src, MAXCOIL)
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
	SSwardrobe.provide_type(/obj/item/stack/cable_coil, src,MAXCOIL)

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
	SSwardrobe.provide_type(/obj/item/stack/cable_coil, src, MAXCOIL)

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

/obj/item/storage/belt/utility/full/powertools/PopulateContents()
	new /obj/item/powertool/hand_drill(src)
	new /obj/item/powertool/jaws_of_life(src)
	new /obj/item/weldingtool/experimental(src)
	new /obj/item/multitool(src)
	new /obj/item/holosign_creator/atmos(src)
	new /obj/item/extinguisher/mini(src)
	new /obj/item/stack/cable_coil(src)

/obj/item/storage/belt/utility/full/powertools/rcd/PopulateContents()
	new /obj/item/powertool/hand_drill(src)
	new /obj/item/powertool/jaws_of_life(src)
	new /obj/item/weldingtool/experimental(src)
	new /obj/item/multitool(src)
	new /obj/item/construction/rcd/combat/ert(src)
	new /obj/item/pipe_dispenser(src)
	new /obj/item/analyzer/ranged(src)

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
	storage_type = /datum/storage/belt/clockwork
	var/slab = null
	var/replicator = null

/obj/item/storage/belt/utility/servant/drone
	slab = /obj/item/clockwork/clockwork_slab
	replicator = /obj/item/clockwork/replica_fabricator

/obj/item/storage/belt/utility/servant/PopulateContents()
	if(slab)
		new slab(src)
	else
		new/obj/item/multitool(src)
	if(replicator)
		new replicator(src)
	else
		new /obj/item/stack/cable_coil(src)
	new /obj/item/screwdriver/brass(src)
	new /obj/item/wirecutters/brass(src)
	new /obj/item/wrench/brass(src)
	new /obj/item/crowbar/brass(src)
	new /obj/item/weldingtool/experimental/brass(src)

/obj/item/storage/belt/medical
	name = "medical belt"
	desc = "Can hold various medical equipment."
	icon_state = "medicalbelt"
	inhand_icon_state = "medical"
	worn_icon_state = "medical"
	content_overlays = TRUE
	custom_price = 100
	storage_type = /datum/storage/belt/medical

/obj/item/storage/belt/medical/ert
	name = "emergency response medical belt"
	desc = "A belt containing field surgical supplies for use by medical response teams."
	storage_type = /datum/storage/belt/medical/ert

/obj/item/storage/belt/medical/ert/PopulateContents()
	new /obj/item/healthanalyzer/advanced(src)
	new /obj/item/surgical_drapes(src)
	new /obj/item/scalpel/advanced(src)
	new /obj/item/retractor/advanced(src)
	new /obj/item/cautery/advanced(src)
	new /obj/item/reagent_containers/medspray/sterilizine(src)
	new /obj/item/gun/medbeam(src)

/obj/item/storage/belt/security
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes."
	icon_state = "securitybelt"
	inhand_icon_state = "security"//Could likely use a better one.
	worn_icon_state = "security"
	content_overlays = TRUE
	custom_price = 80
	storage_type = /datum/storage/belt/security

/obj/item/storage/belt/security/full/PopulateContents()
	new /obj/item/reagent_containers/peppercloud_deployer(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/melee/baton/security/loaded(src)
	new /obj/item/gun/ballistic/taser(src)
	update_appearance()

/obj/item/storage/belt/security/ert/full/PopulateContents()
	new /obj/item/shield/riot/tele(src)
	new /obj/item/melee/baton/security/loaded(src)
	new /obj/item/club(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/reagent_containers/peppercloud_deployer(src)
	new /obj/item/gun/ballistic/taser(src)
	new /obj/item/holosign_creator/security(src)
	update_appearance()

/obj/item/storage/belt/security/deputy
	name = "deputy security belt"

/obj/item/storage/belt/security/deputy/PopulateContents()
	new /obj/item/melee/tonfa(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/reagent_containers/peppercloud_deployer(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/gun/ballistic/taser(src)
	update_appearance()

/obj/item/storage/belt/security/webbing
	name = "security webbing"
	desc = "Unique and versatile chest rig, can hold security gear."
	icon_state = "securitywebbing"
	inhand_icon_state = "securitywebbing"
	worn_icon_state = "securitywebbing"
	content_overlays = FALSE
	max_demand = 10
	custom_price = 150

/obj/item/storage/belt/mining
	name = "explorer's webbing"
	desc = "A versatile chest rig, cherished by miners and hunters alike."
	icon_state = "explorer1"
	inhand_icon_state = "explorer1"
	worn_icon_state = "explorer1"
	storage_type = /datum/storage/belt/mining

/obj/item/storage/belt/mining/vendor
	contents = newlist(/obj/item/survivalcapsule)

/obj/item/storage/belt/mining/alt
	icon_state = "explorer2"
	inhand_icon_state = "explorer2"
	worn_icon_state = "explorer2"

/obj/item/storage/belt/mining/primitive
	name = "hunter's belt"
	desc = "A versatile belt, woven from sinew."
	icon_state = "ebelt"
	inhand_icon_state = "ebelt"
	worn_icon_state = "ebelt"
	storage_type = /datum/storage/belt/mining/primitive

/obj/item/storage/belt/soulstone
	name = "soul stone belt"
	desc = "Designed for ease of access to the shards during a fight, as to not let a single enemy spirit slip away."
	icon_state = "soulstonebelt"
	inhand_icon_state = "soulstonebelt"
	worn_icon_state = "soulstonebelt"
	storage_type = /datum/storage/belt/soulstone

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
	inhand_icon_state = "champion"
	worn_icon_state = "champion"
	custom_materials = list(/datum/material/gold=400)
	storage_type = /datum/storage/belt/champion

/obj/item/storage/belt/military
	name = "chest rig"
	desc = "A set of tactical webbing worn by Syndicate boarding parties."
	icon_state = "militarywebbing"
	inhand_icon_state = "militarywebbing"
	worn_icon_state = "militarywebbing"
	resistance_flags = FIRE_PROOF
	storage_type = /datum/storage/belt/military

/obj/item/storage/belt/military/snack
	name = "tactical snack rig"
	storage_type = /datum/storage/belt/military/snacks

/obj/item/storage/belt/military/snack/Initialize(mapload)
	. = ..()
	var/sponsor = pick("DonkCo", "Waffle Co.", "Roffle Co.", "Gorlax Marauders", "Tiger Cooperative")
	desc = "A set of snack-tical webbing worn by athletes of the [sponsor] VR sports division."

/obj/item/storage/belt/military/snack/full

/obj/item/storage/belt/military/snack/full/PopulateContents()
	for(var/i = 1 to 5)
		var/chosen_snack = pick(list(
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
		new chosen_snack(src)

/obj/item/storage/belt/military/abductor
	name = "agent belt"
	desc = "A belt used by abductor agents."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "belt"
	inhand_icon_state = "security"
	worn_icon_state = "security"

/obj/item/storage/belt/military/abductor/full/PopulateContents()
	new /obj/item/screwdriver/abductor(src)
	new /obj/item/wrench/abductor(src)
	new /obj/item/weldingtool/abductor(src)
	new /obj/item/crowbar/abductor(src)
	new /obj/item/wirecutters/abductor(src)
	new /obj/item/multitool/abductor(src)
	new /obj/item/stack/cable_coil(src)

//Im pissed off at the amount of times I have to do this. So its a belt now
/obj/item/storage/belt/military/abductor/med
	name = "agent belt"
	desc = "A belt used by abductor agents."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "belt"
	inhand_icon_state = "security"
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
	inhand_icon_state = "security"
	worn_icon_state = "security"

/obj/item/storage/belt/military/assault
	name = "assault belt"
	desc = "A tactical assault belt."
	icon_state = "assaultbelt"
	inhand_icon_state = "security"
	worn_icon_state = "security"

/obj/item/storage/belt/grenade
	name = "grenadier belt"
	desc = "A belt for holding grenades."
	icon_state = "grenadebeltnew"
	inhand_icon_state = "security"
	worn_icon_state = "security"
	storage_type = /datum/storage/belt/grenade

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
		/obj/item/multitool = 1,
	)
	generate_items_inside(items_inside, src)

/obj/item/storage/belt/grenade/full/webbing
	name = "grenadier chest rig"
	desc = "A set of tactical webbing stocked full of grenades."
	icon_state = "militarywebbing"
	inhand_icon_state = "militarywebbing"
	worn_icon_state = "militarywebbing"

/obj/item/storage/belt/wands
	name = "wand belt"
	desc = "A belt designed to hold various rods of power. A veritable fanny pack of exotic magic."
	icon_state = "soulstonebelt"
	inhand_icon_state = "soulstonebelt"
	worn_icon_state = "soulstonebelt"
	storage_type = /datum/storage/belt/wand

/obj/item/storage/belt/wands/random/PopulateContents()
	var/variable_wand_list = list(
		/obj/item/gun/magic/wand/drain,
		/obj/item/gun/magic/wand/firebolt,
		/obj/item/gun/magic/wand/teleport,
		/obj/item/gun/magic/wand/animation,
		/obj/item/gun/magic/wand/nutrition,
		/obj/item/gun/magic/wand/icy_blast
		)

	//Wizard belt always contains a healing wand + three random wands
	new /obj/item/gun/magic/wand/healing(src)
	for(var/i in 1 to 3)
		var/wand_type = pick(variable_wand_list)
		new wand_type(src)
		variable_wand_list -= wand_type

/obj/item/storage/belt/wands/full/PopulateContents()
	new /obj/item/gun/magic/wand/drain(src)
	new /obj/item/gun/magic/wand/healing(src)
	new /obj/item/gun/magic/wand/teleport(src)
	new /obj/item/gun/magic/wand/animation(src)
	new /obj/item/gun/magic/wand/icy_blast(src)
	new /obj/item/gun/magic/wand/firebolt(src)

/obj/item/storage/belt/janitor
	name = "janibelt"
	desc = "A belt used to hold most janitorial supplies."
	icon_state = "janibelt"
	inhand_icon_state = "janibelt"
	worn_icon_state = "janibelt"
	storage_type = /datum/storage/belt/janitor

/obj/item/storage/belt/janitor/ertfull
	storage_type = /datum/storage/belt/ert_janitor

/obj/item/storage/belt/janitor/ertfull/PopulateContents()
	new /obj/item/storage/bag/trash/bluespace(src)
	new /obj/item/reagent_containers/cup/bucket(src)
	new /obj/item/lightreplacer(src)
	new /obj/item/reagent_containers/spray/cleaner(src)
	new /obj/item/soap/nanotrasen(src)
	new /obj/item/holosign_creator/janibarrier(src)
	new /obj/item/melee/flyswatter(src)

/obj/item/storage/belt/bandolier
	name = "bandolier"
	desc = "A bandolier for holding shotgun ammunition."
	icon_state = "bandolier"
	inhand_icon_state = "bandolier"
	worn_icon_state = "bandolier"
	storage_type = /datum/storage/belt/bandolier

/obj/item/storage/belt/bandolier/western
	name = "sheriff's bandolier"
	desc = "A bandolier that has been retrofitted for .38 cartridges"
	storage_type = /datum/storage/belt/bandolier_western

/obj/item/storage/belt/bandolier/western/filled/PopulateContents()
	for(var/i in 1 to 21)
		new /obj/item/ammo_casing/c38(src)

/obj/item/storage/belt/quiver
	name = "leather quiver"
	desc = "A quiver made from the hide of some animal. Used to hold arrows."
	icon_state = "quiver"
	inhand_icon_state = "quiver"
	worn_icon_state = "quiver"
	storage_type = /datum/storage/belt/quiver

/obj/item/storage/belt/fannypack
	name = "fannypack"
	desc = "A dorky fannypack for keeping small items in."
	icon_state = "fannypack_leather"
	inhand_icon_state = null
	worn_icon_state = "fannypack_leather"
	dying_key = DYE_REGISTRY_FANNYPACK
	custom_price = 15
	storage_type = /datum/storage/belt/fannypack

/obj/item/storage/belt/fannypack/worn
	name = "worn belt"
	desc = "A weathered belt"
	icon_state = "utilitybelt" //Placeholder for now.
	inhand_icon_state = "utility"
	worn_icon_state = "utility"

/obj/item/storage/belt/fannypack/worn/detective //Starting contents defined in detective.dm where the rest of their loadout is handled.
	name = "worn belt"
	desc = "A weathered belt that is used for storing various gadgets"

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
	inhand_icon_state = "sheath"
	worn_icon_state = "sheath"
	base_icon_state = "sheath"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_SUITSTORE
	interaction_flags_click = parent_type::interaction_flags_click | NEED_DEXTERITY | NEED_HANDS

	//Sheathes made to hold swords can block too
	force = 8
	canblock = TRUE
	block_flags = BLOCKING_ACTIVE
	block_power = 25
	storage_type = /datum/storage/belt/captain_sabre

	/// If TRUE, the icon_state is modified if there is a saber contained
	var/has_sabre_sprite = TRUE

/obj/item/storage/belt/sabre/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/storage/belt/sabre/examine(mob/user)
	. = ..()
	if(length(contents))
		. += span_notice("Alt-click it to quickly draw the blade.")

/obj/item/storage/belt/sabre/click_alt(mob/user)
	if(length(contents))
		var/obj/item/I = contents[1]
		user.visible_message("[user] takes [I] out of [src].", span_notice("You take [I] out of [src]."))
		user.put_in_hands(I)
		update_appearance()
	else
		balloon_alert(user, "it's empty!")
	return CLICK_ACTION_SUCCESS

/obj/item/storage/belt/sabre/update_icon_state()
	. = ..()
	if(!has_sabre_sprite)
		return
	icon_state = base_icon_state
	inhand_icon_state = base_icon_state
	worn_icon_state = base_icon_state
	if(length(contents))
		icon_state += "_sabre"
		inhand_icon_state += "_sabre"
		worn_icon_state += "_sabre"

/obj/item/storage/belt/sabre/PopulateContents()
	new /obj/item/melee/sabre(src)
	update_appearance()

//While it might be useful in a pinch, this is the real reason I want the sheathes to be able to block
/obj/item/storage/belt/sabre/on_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, damage, attack_type)
	if(!length(contents) && istype(hitby, /obj/item/melee/sabre))
		owner.visible_message(span_danger("[owner] smoothly catches [hitby] with the [src]!"))
		playsound(src, 'sound/items/sheath.ogg', 50, TRUE)
		hitby.forceMove(src)
		return TRUE
	. = ..()

/obj/item/storage/belt/sabre/mime
	name = "Baguette"
	desc = "Bon appetit!"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "baguette"
	inhand_icon_state = "baguette"
	worn_icon_state = "baguette"
	base_icon_state = "baguette"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	storage_type = /datum/storage/belt/mime_sabre
	has_sabre_sprite = FALSE

/obj/item/storage/belt/sabre/mime/PopulateContents()
	new /obj/item/melee/sabre/mime(src)
	update_appearance()
