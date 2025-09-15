/obj/structure/closet/secure_closet/captains
	name = "\proper captain's locker"
	req_access = list(ACCESS_CAPTAIN)
	icon_state = "cap"

/obj/structure/closet/secure_closet/captains/populate_contents_immediate()
	..()
	new /obj/item/card/id/departmental_budget/civ(src)

/obj/structure/closet/secure_closet/captains/PopulateContents()
	..()
	new /obj/item/storage/box/suitbox/cap(src)
	new /obj/item/storage/backpack/captain(src)
	new /obj/item/storage/backpack/satchel/cap(src)
	new /obj/item/storage/backpack/duffelbag/captain(src)
	new	/obj/item/clothing/suit/armor/vest/capcarapace/jacket(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/captains_formal(src)
	new /obj/item/clothing/suit/hooded/wintercoat/captain(src)
	new /obj/item/clothing/suit/captunic(src)
	new /obj/item/clothing/gloves/color/captain(src)
	new /obj/item/clothing/glasses/sunglasses/advanced/gar/supergar(src)
	new /obj/item/radio/headset/heads/captain/alt(src)
	new /obj/item/radio/headset/heads/captain(src)

	new /obj/item/clothing/neck/petcollar(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/storage/photo_album/Captain(src)

	new /obj/item/storage/box/radiokey/com(src)
	new /obj/item/storage/box/command_keys(src)
	new /obj/item/megaphone/command(src)
	new /obj/item/computer_hardware/hard_drive/role/captain(src)
	new /obj/item/storage/box/silver_ids(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)

	new /obj/item/paper_reader(src)

	// prioritized items
	new /obj/item/clothing/neck/cloak/cap(src)
	new /obj/item/door_remote/captain(src)
	new /obj/item/storage/belt/sabre(src)
	new /obj/item/gun/ballistic/automatic/pistol/service/captain(src)
	new /obj/item/ammo_box/magazine/recharge/service(src)

/obj/item/storage/box/suitbox/cap
	name = "compression box of captain outfits"

/obj/item/storage/box/suitbox/cap/PopulateContents()
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/under/rank/captain/skirt(src)
	new /obj/item/clothing/under/rank/captain/parade(src)
	new /obj/item/clothing/head/hats/caphat(src)
	new /obj/item/clothing/head/caphat/beret(src)
	new /obj/item/clothing/head/hats/caphat/parade(src)
	new /obj/item/clothing/head/costume/crown/fancy(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)

/obj/structure/closet/secure_closet/hop
	name = "\proper head of personnel's locker"
	req_access = list(ACCESS_HOP)
	icon_state = "hop"

/obj/structure/closet/secure_closet/hop/populate_contents_immediate()
	..()
	new /obj/item/card/id/departmental_budget/srv(src)

/obj/structure/closet/secure_closet/hop/PopulateContents()
	..()
	new /obj/item/dog_bone(src)
	new /obj/item/storage/box/suitbox/hop(src)
	new /obj/item/radio/headset/heads/head_of_personnel(src)

	new /obj/item/clothing/neck/petcollar(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/storage/photo_album/HoP(src)

	new /obj/item/storage/box/radiokey/srv(src)
	new /obj/item/storage/box/command_keys(src)
	new /obj/item/computer_hardware/hard_drive/role/hop(src)
	new /obj/item/storage/box/ids(src)
	new /obj/item/storage/box/ids(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/circuitboard/machine/techfab/department/service(src)

	new /obj/item/paper_reader(src)

	// prioritized items
	new /obj/item/clothing/neck/cloak/hop(src)
	new /obj/item/door_remote/civillian(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/clothing/glasses/sunglasses/advanced(src)
	new /obj/item/clothing/suit/armor/vest/alt(src)
	new /obj/item/megaphone/command(src)
	new /obj/item/gun/ballistic/automatic/pistol/service/hop(src)
	new /obj/item/ammo_box/magazine/recharge/service(src)

/obj/item/storage/box/suitbox/hop
	name = "compression box of head of personnel outfits"

/obj/item/storage/box/suitbox/hop/PopulateContents()
	new /obj/item/clothing/under/rank/civilian/head_of_personnel(src)
	new /obj/item/clothing/under/rank/civilian/head_of_personnel/skirt(src)
	new /obj/item/clothing/under/rank/civilian/head_of_personnel/alt(src)
	new /obj/item/clothing/under/rank/civilian/head_of_personnel/alt/skirt(src)
	new /obj/item/clothing/head/hats/hopcap(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)

/obj/structure/closet/secure_closet/brig_physician
	name = "\proper brig physician's locker"
	req_access = list(ACCESS_BRIGPHYS)
	icon_state = "brig_phys"

/obj/structure/closet/secure_closet/brig_physician/PopulateContents()
	..()
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/radio/headset/headset_medsec(src)
	new	/obj/item/storage/firstaid/regular(src)
	new /obj/item/storage/firstaid/toxin(src)
	new /obj/item/storage/firstaid/o2(src)
	new /obj/item/storage/firstaid/brute(src)
	new /obj/item/storage/firstaid/fire(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/clothing/under/rank/brig_physician(src)
	new /obj/item/clothing/under/rank/brig_physician/skirt(src)
	new /obj/item/clothing/suit/hooded/wintercoat/brigphys(src)
	new /obj/item/wallframe/defib_mount(src)

/obj/structure/closet/secure_closet/hos
	name = "\proper head of security's locker"
	req_access = list(ACCESS_HOS)
	icon_state = "hos"

/obj/structure/closet/secure_closet/hos/populate_contents_immediate()
	..()
	new /obj/item/card/id/departmental_budget/sec(src)
	new /obj/item/gun/energy/e_gun/hos(src)
	new /obj/item/pinpointer/nuke(src)

/obj/structure/closet/secure_closet/hos/PopulateContents()
	..()
	new /obj/item/storage/box/suitbox/hos(src)
	new /obj/item/clothing/suit/armor/vest/leather(src)
	new /obj/item/clothing/mask/gas/sechailer/swat(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/gars/supergars(src)
	new /obj/item/radio/headset/heads/hos/alt(src)
	new /obj/item/radio/headset/heads/hos(src)

	new /obj/item/clothing/neck/petcollar(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/storage/photo_album/HoS(src)

	new /obj/item/storage/box/radiokey/sec(src)
	new /obj/item/storage/box/command_keys(src)
	new /obj/item/megaphone/sec(src)
	new /obj/item/computer_hardware/hard_drive/role/hos(src)
	new /obj/item/storage/box/deputy(src)
	new /obj/item/storage/lockbox/medal/sec(src)
	new /obj/item/storage/lockbox/loyalty(src)
	new /obj/item/circuitboard/machine/techfab/department/security(src)

	new /obj/item/paper_reader(src)

	new /obj/item/clothing/gloves/tackler/combat(src)

	// prioritized items
	new /obj/item/clothing/neck/cloak/hos(src)
	new /obj/item/clothing/suit/armor/hos(src)
	new /obj/item/clothing/suit/armor/hos/trenchcoat(src)
	new /obj/item/shield/riot/tele(src)
	new /obj/item/storage/belt/security/full(src)
	new /obj/item/gun/ballistic/automatic/pistol/service/hos(src)
	new /obj/item/ammo_box/magazine/recharge/service(src)

/obj/item/storage/box/suitbox/hos
	name = "compression box of head of security outfits"

/obj/item/storage/box/suitbox/hos/PopulateContents()
	new /obj/item/clothing/under/rank/security/head_of_security(src)
	new /obj/item/clothing/under/rank/security/head_of_security/skirt(src)
	new /obj/item/clothing/under/rank/security/head_of_security/alt(src)
	new /obj/item/clothing/under/rank/security/head_of_security/alt/skirt(src)
	new /obj/item/clothing/under/rank/security/head_of_security/white(src)
	new /obj/item/clothing/under/rank/security/head_of_security/grey(src)
	new /obj/item/clothing/under/rank/security/head_of_security/parade/female(src)
	new /obj/item/clothing/under/rank/security/head_of_security/parade(src)
	new /obj/item/clothing/head/hats/hos(src)

/obj/structure/closet/secure_closet/warden
	name = "\proper warden's locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "warden"

/obj/structure/closet/secure_closet/warden/PopulateContents()
	..()
	new /obj/item/dog_bone(src)
	new /obj/item/radio/headset/headset_sec(src)
	new /obj/item/clothing/suit/armor/vest/warden(src)
	new /obj/item/clothing/head/hats/warden(src)
	new /obj/item/clothing/head/hats/warden/red(src)
	new /obj/item/clothing/head/hats/warden/drill(src)
	new /obj/item/clothing/head/beret/sec/navywarden(src)
	new /obj/item/clothing/head/beret/corpwarden(src)
	new /obj/item/clothing/suit/armor/vest/warden/alt(src)
	new /obj/item/clothing/under/rank/security/warden/formal(src)
	new /obj/item/clothing/under/rank/security/warden(src)
	new /obj/item/clothing/under/rank/security/warden/white(src)
	new /obj/item/clothing/under/rank/security/warden/grey(src)
	new /obj/item/clothing/under/rank/security/warden/skirt(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/storage/box/zipties(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/belt/security/full(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/megaphone/sec(src)
	new /obj/item/clothing/gloves/krav_maga(src)
	new /obj/item/door_remote/head_of_security(src)
	new /obj/item/gun/ballistic/shotgun/automatic/combat/compact(src)
	new /obj/item/storage/box/deputy(src)

/obj/structure/closet/secure_closet/security
	name = "security officer's locker"
	req_access = list(ACCESS_SECURITY)
	icon_state = "sec"

/obj/structure/closet/secure_closet/security/PopulateContents()
	..()
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/head/helmet/sec(src)
	new /obj/item/radio/headset/headset_sec(src)
	new /obj/item/radio/headset/headset_sec/alt(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/storage/belt/sabre/carbon_fiber(src)

/obj/structure/closet/secure_closet/security/sec

/obj/structure/closet/secure_closet/security/sec/PopulateContents()
	..()
	new /obj/item/storage/belt/security/full(src)

/obj/structure/closet/secure_closet/security/cargo

/obj/structure/closet/secure_closet/security/cargo/PopulateContents()
	..()
	new /obj/item/clothing/accessory/armband/cargo(src)
	new /obj/item/encryptionkey/headset_cargo(src)

/obj/structure/closet/secure_closet/security/engine

/obj/structure/closet/secure_closet/security/engine/PopulateContents()
	..()
	new /obj/item/clothing/accessory/armband/engine(src)
	new /obj/item/encryptionkey/headset_eng(src)

/obj/structure/closet/secure_closet/security/science

/obj/structure/closet/secure_closet/security/science/PopulateContents()
	..()
	new /obj/item/clothing/accessory/armband/science(src)
	new /obj/item/encryptionkey/headset_sci(src)

/obj/structure/closet/secure_closet/security/med

/obj/structure/closet/secure_closet/security/med/PopulateContents()
	..()
	new /obj/item/clothing/accessory/armband/medblue(src)
	new /obj/item/encryptionkey/headset_med(src)

/obj/structure/closet/secure_closet/detective
	name = "\improper detective's cabinet"
	req_access = list(ACCESS_FORENSICS_LOCKERS)
	icon_state = "cabinet"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	door_anim_time = 0 // no animation
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	can_weld_shut = FALSE

/obj/structure/closet/secure_closet/detective/PopulateContents()
	..()
	new /obj/item/storage/backpack/duffelbag/sec/detective(src)
	new /obj/item/clothing/suit/armor/vest/det_suit(src)
	new /obj/item/clothing/accessory/holster/detective(src)
	new /obj/item/radio/headset/headset_sec(src)
	new /obj/item/clothing/glasses/hud/security(src)

/obj/structure/closet/secure_closet/deputy
	name = "deputy's locker"
	req_access = list(ACCESS_BRIG)

/obj/structure/closet/secure_closet/deputy/PopulateContents()
	..()
	for(var/i in 1 to 4)
		new /obj/item/storage/backpack/duffelbag/sec/deputy(src)

/obj/structure/closet/secure_closet/injection
	name = "lethal injections"
	req_access = list(ACCESS_HOS)

/obj/structure/closet/secure_closet/injection/PopulateContents()
	..()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/syringe/lethal/execution(src)

/obj/structure/closet/secure_closet/brig
	name = "brig locker"
	req_access = list(ACCESS_BRIG)
	anchored = TRUE
	var/id = null

/obj/structure/closet/secure_closet/evidence
	anchored = TRUE
	name = "Secure Evidence Closet"
	req_access_txt = "0"
	req_one_access_txt = list(ACCESS_ARMORY, ACCESS_FORENSICS_LOCKERS)

/obj/structure/closet/secure_closet/brig/PopulateContents()
	..()
	new /obj/item/clothing/under/rank/prisoner( src )
	new /obj/item/clothing/shoes/sneakers/orange( src )

/obj/structure/closet/secure_closet/courtroom
	name = "courtroom locker"
	req_access = list(ACCESS_COURT)

/obj/structure/closet/secure_closet/courtroom/PopulateContents()
	..()
	new /obj/item/clothing/shoes/sneakers/brown(src)
	for(var/i in 1 to 3)
		new /obj/item/paper/fluff/jobs/security/court_judgment (src)
	new /obj/item/pen (src)
	new /obj/item/clothing/suit/costume/judgerobe (src)
	new /obj/item/clothing/head/costume/powdered_wig (src)
	new /obj/item/storage/briefcase(src)

/obj/structure/closet/secure_closet/contraband/armory
	anchored = TRUE
	name = "Contraband Locker"
	req_access = list(ACCESS_ARMORY)

/obj/structure/closet/secure_closet/contraband/heads
	anchored = TRUE
	name = "Contraband Locker"
	req_access = list(ACCESS_HEADS)

/obj/structure/closet/secure_closet/armory1
	name = "armory armor locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "armory"

/obj/structure/closet/secure_closet/armory1/populate_contents_immediate()
	..()
	new /obj/item/clothing/suit/armor/laserproof(src)

/obj/structure/closet/secure_closet/armory1/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/clothing/suit/armor/riot(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/head/helmet/toggleable/riot(src)
	for(var/i in 1 to 3)
		new /obj/item/shield/riot(src)

/obj/structure/closet/secure_closet/armory2
	name = "armory ballistics locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "armory"

/obj/structure/closet/secure_closet/armory2/PopulateContents()
	..()
	new /obj/item/storage/box/firingpins(src)
	for(var/i in 1 to 3)
		new /obj/item/storage/box/rubbershot(src)
	for(var/i in 1 to 3)
		new /obj/item/gun/ballistic/shotgun/riot(src)

/obj/structure/closet/secure_closet/armory3
	name = "armory energy gun locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "armory"

/obj/structure/closet/secure_closet/armory3/PopulateContents()
	..()
	new /obj/item/storage/box/firingpins(src)
	new /obj/item/gun/energy/ionrifle(src)
	for(var/i in 1 to 3)
		new /obj/item/gun/energy/e_gun(src)
	for(var/i in 1 to 3)
		new /obj/item/gun/energy/laser(src)

/obj/structure/closet/secure_closet/tac
	name = "armory tac locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "tac"

/obj/structure/closet/secure_closet/tac/PopulateContents()
	..()
	new /obj/item/gun/ballistic/automatic/wt550(src)
	new /obj/item/clothing/head/helmet/alt(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/clothing/suit/armor/bulletproof(src)

/obj/structure/closet/secure_closet/lethalshots
	name = "shotgun lethal rounds"
	req_access = list(ACCESS_ARMORY)
	icon_state = "tac"

/obj/structure/closet/secure_closet/lethalshots/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/storage/box/lethalshot(src)
