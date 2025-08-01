/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/effect/light_emitter
	name = "Light emitter"
	anchored = TRUE
	invisibility = 101
	var/set_luminosity = 8
	var/set_cap = 0

/obj/effect/light_emitter/Initialize(mapload)
	. = ..()
	set_light(set_luminosity, set_cap)

/obj/effect/light_emitter/singularity_pull()
	return

/obj/effect/light_emitter/singularity_act()
	return

/**********************Miner Lockers**************************/

/obj/structure/closet/wardrobe/miner
	name = "mining wardrobe"
	icon_door = "mixed"

/obj/structure/closet/wardrobe/miner/PopulateContents()
	new /obj/item/storage/backpack/duffelbag(src)
	new /obj/item/storage/backpack/explorer(src)
	new /obj/item/storage/backpack/satchel/explorer(src)
	new /obj/item/clothing/under/plasmaman/mining(src)
	new /obj/item/clothing/under/plasmaman/mining(src)
	new /obj/item/clothing/under/plasmaman/mining(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/mining(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/mining(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/mining(src)
	new /obj/item/clothing/under/rank/cargo/miner/lavaland(src)
	new /obj/item/clothing/under/rank/cargo/miner/lavaland(src)
	new /obj/item/clothing/under/rank/cargo/miner/lavaland(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)

/obj/structure/closet/secure_closet/miner
	name = "miner's equipment"
	icon_state = "mining"
	req_access = list(ACCESS_MINING)

/obj/structure/closet/secure_closet/miner/unlocked
	locked = FALSE

/obj/structure/closet/secure_closet/miner/PopulateContents()
	..()
	new /obj/item/stack/sheet/sandbags(src, 5)
	new /obj/item/storage/box/emptysandbags(src)
	new /obj/item/shovel(src)
	new /obj/item/pickaxe/mini(src)
	new /obj/item/radio/headset/headset_cargo/shaft_miner(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/storage/bag/plants(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/gun/energy/recharge/kinetic_accelerator(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/survivalcapsule(src)
	new /obj/item/assault_pod/mining(src)
	new /obj/item/clothing/suit/hooded/wintercoat/miner(src)


/**********************Shuttle Computer**************************/

/obj/machinery/computer/shuttle_flight/mining
	name = "mining shuttle console"
	desc = "Used to call and send the mining shuttle."
	circuit = /obj/item/circuitboard/computer/shuttle/mining_shuttle
	shuttleId = "mining"
	possible_destinations = "mining_home;mining_away;landing_zone_dock;mining_public"
	req_access = list(ACCESS_MINING)
	var/static/list/dumb_rev_heads = list()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/machinery/computer/shuttle_flight/mining/attack_hand(mob/user, list/modifiers)
	if(is_station_level(user.z) && user.mind && IS_HEAD_REVOLUTIONARY(user) && !(user.mind in dumb_rev_heads))
		to_chat(user, span_warning("You get a feeling that leaving the station might be a REALLY dumb idea..."))
		dumb_rev_heads += user.mind
		return
	. = ..()

//It is on lavaland, soooo....
/obj/machinery/computer/shuttle_flight/science
	name = "science outpost shuttle console"
	desc = "Used to call and send the science shuttle."
	circuit = /obj/item/circuitboard/computer/shuttle/science_shuttle
	shuttleId = "science"
	possible_destinations = "science_station;science_outpost"

/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/structure/closet/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "Mining car (not for rails)"
	icon_state = "miningcar"
