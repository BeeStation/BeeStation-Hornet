/obj/structure/closet/secure_closet/engineering_chief
	name = "\proper chief engineer's locker"
	req_access = list(ACCESS_CE)
	icon_state = "ce"

/obj/structure/closet/secure_closet/engineering_chief/populate_contents_immediate()
	..()
	new /obj/item/card/id/departmental_budget/eng(src)
	new /obj/item/areaeditor/blueprints(src)

/obj/structure/closet/secure_closet/engineering_chief/PopulateContents()
	..()
	new /obj/item/storage/box/suitbox/ce(src)
	new /obj/item/clothing/suit/hazardvest(src)
	new /obj/item/clothing/gloves/color/yellow(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/radio/headset/heads/chief_engineer(src)

	new /obj/item/clothing/neck/petcollar(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/storage/photo_album/CE(src)

	new /obj/item/storage/box/radiokey/eng(src)
	new /obj/item/storage/box/command_keys(src)
	new /obj/item/megaphone/command(src)
	new /obj/item/computer_hardware/hard_drive/role/ce(src)
	new /obj/item/storage/bag/construction(src)

	new /obj/item/circuitboard/machine/techfab/department/engineering(src)

	new /obj/item/paper_reader(src)

	// prioritized items
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/clothing/neck/cloak/ce(src)
	new /obj/item/door_remote/chief_engineer(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/storage/box/suitbox/ce_tools(src)
	new /obj/item/clothing/glasses/meson/engine(src)
	new /obj/item/gun/ballistic/automatic/pistol/service/ce(src)
	new /obj/item/ammo_box/magazine/recharge/service(src)

/obj/item/storage/box/suitbox/ce_tools
	name = "compression box of chief engineer tools"

/obj/item/storage/box/suitbox/ce_tools/PopulateContents()
	new /obj/item/pipe_dispenser(src)
	new /obj/item/multitool(src)
	new /obj/item/inducer(src)
	new /obj/item/airlock_painter(src)
	new /obj/item/extinguisher/advanced(src)
	new /obj/item/construction/rcd/loaded(src)
	new /obj/item/rcd_ammo/large(src)
	new /obj/item/holosign_creator/engineering(src)
	new /obj/item/holosign_creator/atmos(src)

/obj/item/storage/box/suitbox/ce
	name = "compression box of chief engineer outfits"

/obj/item/storage/box/suitbox/ce/PopulateContents()
	new /obj/item/clothing/under/rank/engineering/chief_engineer(src)
	new /obj/item/clothing/under/rank/engineering/chief_engineer/skirt(src)
	new /obj/item/clothing/head/beret/ce(src)
	new /obj/item/clothing/head/utility/hardhat/white(src)
	new /obj/item/clothing/head/utility/hardhat/welding/white(src)
	new /obj/item/clothing/head/utility/welding(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)

/obj/structure/closet/secure_closet/engineering_electrical
	name = "electrical supplies locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "eng"
	icon_door = "eng_elec"

/obj/structure/closet/secure_closet/engineering_electrical/PopulateContents()
	..()
	var/static/items_inside = list(
		/obj/item/clothing/gloves/color/yellow = 2,
		/obj/item/inducer = 2,
		/obj/item/storage/toolbox/electrical = 3,
		/obj/item/electronics/apc = 3,
		/obj/item/multitool = 3)
	generate_items_inside(items_inside,src)

/obj/structure/closet/secure_closet/engineering_welding
	name = "welding supplies locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "eng"
	icon_door = "eng_weld"

/obj/structure/closet/secure_closet/engineering_welding/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/clothing/head/utility/welding(src)
	for(var/i in 1 to 3)
		new /obj/item/weldingtool(src)

/obj/structure/closet/secure_closet/engineering_personal
	name = "engineer's locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "eng_secure"

/obj/structure/closet/secure_closet/engineering_personal/PopulateContents()
	..()
	new /obj/item/clothing/head/beret/engi(src)
	new /obj/item/radio/headset/headset_eng(src)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/holosign_creator/engineering(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/glasses/meson/engine(src)
	new /obj/item/storage/box/emptysandbags(src)
	new /obj/item/clothing/gloves/color/yellow(src)

/obj/structure/closet/secure_closet/atmospherics
	name = "\proper atmospheric technician's locker"
	req_access = list(ACCESS_ATMOSPHERICS)
	icon_state = "atmos"

/obj/structure/closet/secure_closet/atmospherics/PopulateContents()
	..()
	new /obj/item/radio/headset/headset_eng(src)
	new /obj/item/pipe_dispenser(src)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/analyzer(src)
	new /obj/item/holosign_creator/atmos(src)
	new /obj/item/watertank/atmos(src)
	new /obj/item/clothing/suit/utility/fire/atmos(src)
	new /obj/item/clothing/head/utility/hardhat/atmos(src)
	new /obj/item/clothing/glasses/meson/engine/tray(src)
	new /obj/item/extinguisher/advanced(src)
