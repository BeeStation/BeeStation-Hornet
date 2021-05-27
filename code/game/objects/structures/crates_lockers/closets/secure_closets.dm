/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's a card-locked storage unit."
	locked = TRUE
	icon_state = "secure"
	max_integrity = 250
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80, "stamina" = 0)
	secure = TRUE

/obj/structure/closet/secure_closet/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee" && damage_amount < 20)
		return 0
	. = ..()

//SERVICE

/obj/structure/closet/secure_closet/bar
	name = "booze storage"
	req_access = list(ACCESS_BAR)
	icon_state = "cabinet"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	door_anim_time = 0 // no animation
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50

/obj/structure/closet/secure_closet/bar/PopulateContents()
	..()
	for(var/i in 1 to 10)
		new /obj/item/reagent_containers/food/drinks/beer( src )
	new /obj/item/etherealballdeployer(src)

/obj/structure/closet/secure_closet/animal
	name = "animal control"
	req_access = list(ACCESS_SURGERY)

/obj/structure/closet/secure_closet/animal/PopulateContents()
	..()
	new /obj/item/assembly/signaler(src)
	for(var/i in 1 to 3)
		new /obj/item/electropack(src)

/obj/structure/closet/secure_closet/hydroponics
	name = "botanist's locker"
	req_access = list(ACCESS_HYDROPONICS)
	icon_state = "hydro"

/obj/structure/closet/secure_closet/hydroponics/PopulateContents()
	..()
	new /obj/item/storage/bag/plants/portaseeder(src)
	new /obj/item/plant_analyzer(src)
	new /obj/item/radio/headset/headset_srv(src)
	new /obj/item/cultivator(src)
	new /obj/item/hatchet(src)
	new /obj/item/storage/box/disks_plantgene(src)

//QM

/obj/structure/closet/secure_closet/quartermaster
	name = "\proper quartermaster's locker"
	req_access = list(ACCESS_QM)
	icon_state = "qm"

/obj/structure/closet/secure_closet/quartermaster/PopulateContents()
	..()
	new /obj/item/clothing/neck/cloak/qm(src)
	new /obj/item/storage/lockbox/medal/cargo(src)
	new /obj/item/clothing/under/rank/cargo/qm(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/radio/headset/headset_cargo(src)
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/megaphone/cargo(src)
	new /obj/item/tank/internals/emergency_oxygen(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/head/soft(src)
	new /obj/item/export_scanner(src)
	new /obj/item/door_remote/quartermaster(src)
	new /obj/item/circuitboard/machine/techfab/department/cargo(src)
	new /obj/item/storage/photo_album/QM(src)
	new /obj/item/circuitboard/machine/ore_silo(src)
	new /obj/item/card/id/departmental_budget/car(src)

/obj/structure/closet/secure_closet/engineering_chief
	name = "\proper chief engineer's locker"
	req_access = list(ACCESS_CE)
	icon_state = "ce"

//ENGINEERING

/obj/structure/closet/secure_closet/engineering_chief/PopulateContents()
	..()
	new /obj/item/clothing/head/beret/ce(src)
	new /obj/item/clothing/neck/cloak/ce(src)
	new /obj/item/clothing/under/rank/engineering/chief_engineer(src)
	new /obj/item/clothing/head/hardhat/white(src)
	new /obj/item/clothing/head/hardhat/weldhat/white(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/clothing/gloves/color/yellow(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/tank/jetpack/suit(src)
	new /obj/item/cartridge/ce(src)
	new /obj/item/radio/headset/heads/ce(src)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/clothing/suit/hazardvest(src)
	new /obj/item/megaphone/command(src)
	new /obj/item/areaeditor/blueprints(src)
	new /obj/item/airlock_painter(src)
	new /obj/item/holosign_creator/engineering(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/multitool(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/clothing/glasses/meson/engine(src)
	new /obj/item/door_remote/chief_engineer(src)
	new /obj/item/pipe_dispenser(src)
	new /obj/item/inducer(src)
	new /obj/item/circuitboard/machine/techfab/department/engineering(src)
	new /obj/item/extinguisher/advanced(src)
	new /obj/item/storage/photo_album/CE(src)
	new /obj/item/card/id/departmental_budget/eng(src)
	
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
		new /obj/item/clothing/head/welding(src)
	for(var/i in 1 to 3)
		new /obj/item/weldingtool(src)

/obj/structure/closet/secure_closet/engineering_personal
	name = "engineer's locker"
	req_access = list(ACCESS_ENGINE_EQUIP)
	icon_state = "eng_secure"

/obj/structure/closet/secure_closet/engineering_personal/PopulateContents()
	..()
	new /obj/item/clothing/head/beret/eng(src)
	new /obj/item/radio/headset/headset_eng(src)
	new /obj/item/storage/toolbox/mechanical(src)
	new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/holosign_creator/engineering(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/glasses/meson/engine(src)
	new /obj/item/storage/box/emptysandbags(src)


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
	new /obj/item/clothing/suit/fire/atmos(src)
	new /obj/item/clothing/head/hardhat/atmos(src)
	new /obj/item/clothing/glasses/meson/engine/tray(src)
	new /obj/item/extinguisher/advanced(src)

//MEDICAL

/obj/structure/closet/secure_closet/medical1
	name = "medicine closet"
	desc = "Filled to the brim with medical junk."
	icon_state = "med"
	req_access = list(ACCESS_MEDICAL)

/obj/structure/closet/secure_closet/medical1/PopulateContents()
	..()
	var/static/items_inside = list(
		/obj/item/reagent_containers/glass/beaker = 2,
		/obj/item/reagent_containers/dropper = 2,
		/obj/item/storage/belt/medical = 1,
		/obj/item/storage/box/syringes = 1,
		/obj/item/reagent_containers/glass/bottle/toxin = 1,
		/obj/item/reagent_containers/glass/bottle/morphine = 2,
		/obj/item/reagent_containers/glass/bottle/epinephrine= 3,
		/obj/item/reagent_containers/glass/bottle/charcoal = 3,
		/obj/item/storage/box/rxglasses = 1,
		/obj/item/stack/ducts/fifty = 4,
		/obj/item/construction/plumbing = 2,
		/obj/item/plunger = 2)
	generate_items_inside(items_inside,src)

/obj/structure/closet/secure_closet/medical2
	name = "anesthetic closet"
	desc = "Used to knock people out."
	req_access = list(ACCESS_SURGERY)

/obj/structure/closet/secure_closet/medical2/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/tank/internals/anesthetic(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/mask/breath/medical(src)

/obj/structure/closet/secure_closet/medical3
	name = "medical doctor's locker"
	req_access = list(ACCESS_SURGERY)
	icon_state = "med_secure"

/obj/structure/closet/secure_closet/medical3/PopulateContents()
	..()
	new /obj/item/clothing/head/beret/med(src)
	new /obj/item/radio/headset/headset_med(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/glasses/hud/health(src)
	return

/obj/structure/closet/secure_closet/medicaldanger
	name = "group T medical closet"
	desc = "Filled to the brim with potentially dangerous drugs. Keep away from assistants."
	req_access = list(ACCESS_MEDICAL)
	icon_state = "med_secure"

/obj/structure/closet/secure_closet/medicaldanger/PopulateContents()
	..()
	new /obj/item/reagent_containers/glass/bottle/formaldehyde(src)
	new /obj/item/reagent_containers/glass/bottle/formaldehyde(src)
	new /obj/item/reagent_containers/glass/bottle/charcoal(src)
	new /obj/item/reagent_containers/glass/bottle/chloralhydrate(src)
	new /obj/item/reagent_containers/glass/bottle/morphine(src)
	new /obj/item/reagent_containers/glass/bottle/sodium_thiopental(src)
	new /obj/item/storage/pill_bottle/epinephrine(src)
	new /obj/item/storage/pill_bottle/charcoal(src)
	new /obj/item/reagent_containers/syringe/calomel(src)
	new /obj/item/reagent_containers/syringe/diphenhydramine(src)
	new /obj/item/reagent_containers/hypospray/medipen/atropine(src) //just one
	new /obj/item/storage/box/syringes(src)
	return

/obj/structure/closet/secure_closet/CMO
	name = "\proper chief medical officer's locker"
	req_access = list(ACCESS_CMO)
	icon_state = "cmo"

/obj/structure/closet/secure_closet/CMO/PopulateContents()
	..()
	new /obj/item/clothing/head/beret/cmo(src)
	new /obj/item/clothing/neck/cloak/cmo(src)
	new /obj/item/storage/backpack/duffelbag/med(src)
	new /obj/item/clothing/suit/bio_suit/cmo(src)
	new /obj/item/clothing/head/bio_hood/cmo(src)
	new /obj/item/clothing/suit/toggle/labcoat/cmo(src)
	new /obj/item/clothing/under/rank/medical/chief_medical_officer(src)
	new /obj/item/clothing/shoes/sneakers/brown	(src)
	new /obj/item/cartridge/cmo(src)
	new /obj/item/radio/headset/heads/cmo(src)
	new /obj/item/megaphone/command(src)
	new /obj/item/defibrillator/compact/loaded(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/healthanalyzer/advanced(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/reagent_containers/hypospray/CMO(src)
	new /obj/item/autosurgeon/cmo(src)
	new /obj/item/door_remote/chief_medical_officer(src)
	new /obj/item/clothing/neck/petcollar(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/wallframe/defib_mount(src)
	new /obj/item/circuitboard/machine/techfab/department/medical(src)
	new /obj/item/storage/photo_album/CMO(src)
	new /obj/item/reagent_containers/food/drinks/bottle/synthflesh(src)
	new /obj/item/card/id/departmental_budget/med(src)
	new /obj/item/extrapolator(src)

/obj/structure/closet/secure_closet/chemical
	name = "chemical closet"
	desc = "Store dangerous chemicals in here."
	req_access = list(ACCESS_CHEMISTRY)
	icon_door = "chemical"

/obj/structure/closet/secure_closet/chemical/PopulateContents()
	..()
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/medsprays(src)
	new /obj/item/storage/box/medsprays(src)
	new /obj/item/stack/ducts/fifty(src)
	new /obj/item/stack/ducts/fifty(src)
	new /obj/item/stack/ducts/fifty(src)
	new /obj/item/stack/ducts/fifty(src)
	new /obj/item/construction/plumbing(src)
	new /obj/item/construction/plumbing(src)
	new	/obj/item/plunger(src)
	new	/obj/item/plunger(src)

/obj/structure/closet/secure_closet/chemical/heisenberg //contains one of each beaker, syringe etc.
	name = "advanced chemical closet"

/obj/structure/closet/secure_closet/chemical/heisenberg/PopulateContents()
	..()
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/storage/box/syringes/variety(src)
	new /obj/item/storage/box/beakers/variety(src)
	new /obj/item/clothing/glasses/science(src)
	new /obj/item/stack/ducts/fifty(src)
	new /obj/item/stack/ducts/fifty(src)
	new /obj/item/stack/ducts/fifty(src)
	new /obj/item/stack/ducts/fifty(src)
	new /obj/item/construction/plumbing(src)
	new /obj/item/construction/plumbing(src)
	new	/obj/item/plunger(src)
	new	/obj/item/plunger(src)

//CentCom

/obj/structure/closet/secure_closet/ertCom
	name = "emergency response team commander's locker"
	desc = "A storage unit containing equipment for an Emergency Response Team Commander."
	req_access = list(ACCESS_CENT_CAPTAIN)
	icon_state = "cap"

/obj/structure/closet/secure_closet/ertCom/PopulateContents()
	..()
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/storage/box/handcuffs(src)
	new /obj/item/aicard(src)
	new /obj/item/assembly/flash/handheld(src)
	if(prob(50))
		new /obj/item/ammo_box/magazine/m50(src)
		new /obj/item/ammo_box/magazine/m50(src)
		new /obj/item/gun/ballistic/automatic/pistol/deagle(src)
	else
		new /obj/item/ammo_box/a357(src)
		new /obj/item/ammo_box/a357(src)
		new /obj/item/gun/ballistic/revolver/mateba(src)

/obj/structure/closet/secure_closet/ertSec
	name = "emergency response team security locker"
	desc = "A storage unit containing equipment for an Emergency Response Team Security Officer."
	req_access = list(ACCESS_CENT_SPECOPS)
	icon_state = "hos"

/obj/structure/closet/secure_closet/ertSec/PopulateContents()
	..()
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/box/teargas(src)
	new /obj/item/storage/box/flashes(src)
	new /obj/item/storage/box/handcuffs(src)
	new /obj/item/shield/riot/tele(src)

/obj/structure/closet/secure_closet/ertMed
	name = "emergency response team medical locker"
	desc = "A storage unit containing equipment for an Emergency Response Team Medical Officer."
	req_access = list(ACCESS_CENT_MEDICAL)
	icon_state = "cmo"

/obj/structure/closet/secure_closet/ertMed/PopulateContents()
	..()
	new /obj/item/storage/firstaid/o2(src)
	new /obj/item/storage/firstaid/toxin(src)
	new /obj/item/storage/firstaid/fire(src)
	new /obj/item/storage/firstaid/brute(src)
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/defibrillator/compact/combat/loaded(src)
	new /mob/living/simple_animal/bot/medbot(src)

/obj/structure/closet/secure_closet/ertEngi
	name = "emergency response team engineer locker"
	desc = "A storage unit containing equipment for an Emergency Response Team Engineer."
	req_access = list(ACCESS_CENT_STORAGE)
	icon_state = "ce"

/obj/structure/closet/secure_closet/ertEngi/PopulateContents()
	..()
	new /obj/item/stack/sheet/plasteel(src, 50)
	new /obj/item/stack/sheet/iron(src, 50)
	new /obj/item/stack/sheet/glass(src, 50)
	new /obj/item/stack/sheet/mineral/sandbags(src, 30)
	new /obj/item/clothing/shoes/magboots(src)
	new /obj/item/storage/box/smart_metal_foam(src)
	for(var/i in 1 to 3)
		new /obj/item/rcd_ammo/large(src)

//PERSONAL

/obj/structure/closet/secure_closet/personal
	desc = "It's a secure locker for personnel. The first card swiped gains control."
	name = "personal closet"
	req_access = list(ACCESS_ALL_PERSONAL_LOCKERS)
	var/registered_name = null

/obj/structure/closet/secure_closet/personal/PopulateContents()
	..()
	if(prob(50))
		new /obj/item/storage/backpack/duffelbag(src)
	if(prob(50))
		new /obj/item/storage/backpack(src)
	else
		new /obj/item/storage/backpack/satchel(src)
	new /obj/item/radio/headset( src )

/obj/structure/closet/secure_closet/personal/patient
	name = "patient's closet"

/obj/structure/closet/secure_closet/personal/patient/PopulateContents()
	new /obj/item/clothing/under/color/white( src )
	new /obj/item/clothing/shoes/sneakers/white( src )

/obj/structure/closet/secure_closet/personal/cabinet
	icon_state = "cabinet"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	door_anim_time = 0 // no animation
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50

/obj/structure/closet/secure_closet/personal/cabinet/PopulateContents()
	new /obj/item/storage/backpack/satchel/leather/withwallet( src )
	new /obj/item/instrument/piano_synth(src)
	new /obj/item/radio/headset( src )

/obj/structure/closet/secure_closet/personal/attackby(obj/item/W, mob/user, params)
	var/obj/item/card/id/I = W.GetID()
	if(istype(I))
		if(broken)
			to_chat(user, "<span class='danger'>It appears to be broken.</span>")
			return
		if(!I || !I.registered_name)
			return
		if(allowed(user) || !registered_name || (istype(I) && (registered_name == I.registered_name)))
			//they can open all lockers, or nobody owns this, or they own this locker
			locked = !locked
			update_icon()

			if(!registered_name)
				registered_name = I.registered_name
				desc = "Owned by [I.registered_name]."
		else
			to_chat(user, "<span class='danger'>Access Denied.</span>")
	else
		return ..()

//SCIENCE

/obj/structure/closet/secure_closet/RD
	name = "\proper research director's locker"
	req_access = list(ACCESS_RD)
	icon_state = "rd"

/obj/structure/closet/secure_closet/RD/PopulateContents()
	..()
	new /obj/item/clothing/head/beret/sci(src)
	new /obj/item/clothing/neck/cloak/rd(src)
	new /obj/item/clothing/suit/bio_suit/scientist(src)
	new /obj/item/clothing/head/bio_hood/scientist(src)
	new /obj/item/clothing/suit/toggle/labcoat/rd(src)
	new /obj/item/clothing/under/rank/rnd/research_director(src)
	new /obj/item/clothing/under/rank/rnd/research_director/alt(src)
	new /obj/item/clothing/under/rank/rnd/research_director/hazard(src)
	new /obj/item/clothing/under/rank/rnd/research_director/turtleneck(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/cartridge/rd(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/radio/headset/heads/rd(src)
	new /obj/item/tank/internals/air(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/megaphone/command(src)
	new /obj/item/storage/lockbox/medal/sci(src)
	new /obj/item/clothing/suit/armor/reactive/teleport(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/laser_pointer(src)
	new /obj/item/door_remote/research_director(src)
	new /obj/item/circuitboard/machine/techfab/department/science(src)
	new /obj/item/storage/photo_album/RD(src)
	new /obj/item/card/id/departmental_budget/sci(src)
	if(CONFIG_GET(number/roundstart_bluespace_miners))
		for(var/i in 1 to CONFIG_GET(number/roundstart_bluespace_miners))
			new /obj/item/circuitboard/machine/bluespace_miner(src)

//SECURITY & ARMORY

/obj/structure/closet/secure_closet/captains
	name = "\proper captain's locker"
	req_access = list(ACCESS_CAPTAIN)
	icon_state = "cap"

/obj/structure/closet/secure_closet/captains/PopulateContents()
	..()
	new /obj/item/clothing/head/beret/captain(src)
	new /obj/item/clothing/suit/hooded/wintercoat/captain(src)
	new /obj/item/storage/backpack/captain(src)
	new /obj/item/storage/backpack/satchel/cap(src)
	new /obj/item/storage/backpack/duffelbag/captain(src)
	new /obj/item/clothing/neck/cloak/cap(src)
	new /obj/item/clothing/neck/petcollar(src)
	new	/obj/item/clothing/suit/armor/vest/capcarapace/jacket(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace(src)
	new /obj/item/clothing/head/caphat(src)
	new /obj/item/clothing/under/rank/captain/parade(src)
	new /obj/item/clothing/suit/armor/vest/capcarapace/alt(src)
	new /obj/item/clothing/head/caphat/parade(src)
	new /obj/item/clothing/suit/captunic(src)
	new /obj/item/clothing/head/crown/fancy(src)
	new /obj/item/cartridge/captain(src)
	new /obj/item/storage/box/silver_ids(src)
	new /obj/item/radio/headset/heads/captain/alt(src)
	new /obj/item/radio/headset/heads/captain(src)
	new /obj/item/clothing/glasses/sunglasses/advanced/gar/supergar(src)
	new /obj/item/clothing/gloves/color/captain(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/storage/belt/sabre(src)
	new /obj/item/gun/energy/e_gun(src)
	new /obj/item/door_remote/captain(src)
	new /obj/item/storage/photo_album/Captain(src)
	new /obj/item/card/id/departmental_budget/civ(src)

/obj/structure/closet/secure_closet/hop
	name = "\proper head of personnel's locker"
	req_access = list(ACCESS_HOP)
	icon_state = "hop"

/obj/structure/closet/secure_closet/hop/PopulateContents()
	..()
	new /obj/item/clothing/neck/cloak/hop(src)
	new /obj/item/storage/lockbox/medal/service(src)
	new /obj/item/clothing/under/rank/civilian/head_of_personnel(src)
	new /obj/item/clothing/head/hopcap(src)
	new /obj/item/cartridge/hop(src)
	new /obj/item/radio/headset/heads/hop(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/storage/box/ids(src)
	new /obj/item/storage/box/ids(src)
	new /obj/item/megaphone/command(src)
	new /obj/item/clothing/suit/armor/vest/alt(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/clothing/glasses/sunglasses/advanced(src)
	new /obj/item/restraints/handcuffs/cable/zipties(src)
	new /obj/item/gun/energy/e_gun/mini(src)
	new /obj/item/clothing/neck/petcollar(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/door_remote/civillian(src)
	new /obj/item/circuitboard/machine/techfab/department/service(src)
	new /obj/item/storage/photo_album/HoP(src)
	new /obj/item/card/id/departmental_budget/srv(src)

/obj/structure/closet/secure_closet/brig_phys
	name = "\proper brig physician's locker"
	req_access = list(ACCESS_BRIGPHYS)
	icon_state = "brig_phys"

/obj/structure/closet/secure_closet/brig_phys/PopulateContents()
	..()
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/blood_filter(src)
	new /obj/item/radio/headset/headset_medsec(src)
	new	/obj/item/storage/firstaid/regular(src)
	new	/obj/item/storage/firstaid/fire(src)
	new	/obj/item/storage/firstaid/toxin(src)
	new	/obj/item/storage/firstaid/o2(src)
	new	/obj/item/storage/firstaid/brute(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)

/obj/structure/closet/secure_closet/hos
	name = "\proper head of security's locker"
	req_access = list(ACCESS_HOS)
	icon_state = "hos"

/obj/structure/closet/secure_closet/hos/PopulateContents()
	..()
	new /obj/item/clothing/neck/cloak/hos(src)
	new /obj/item/storage/box/deputy(src)
	new /obj/item/cartridge/hos(src)
	new /obj/item/radio/headset/heads/hos/alt(src)
	new /obj/item/radio/headset/heads/hos(src)
	new /obj/item/clothing/under/rank/security/head_of_security/parade/female(src)
	new /obj/item/clothing/under/rank/security/head_of_security/parade(src)
	new /obj/item/clothing/suit/armor/vest/leather(src)
	new /obj/item/clothing/suit/armor/hos/trenchcoat(src)
	new /obj/item/clothing/suit/armor/hos(src)
	new /obj/item/clothing/under/rank/security/head_of_security/alt(src)
	new /obj/item/clothing/head/HoS(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses/gars/supergars(src)
	new /obj/item/clothing/under/rank/security/head_of_security/white(src)
	new /obj/item/storage/lockbox/medal/sec(src)
	new /obj/item/megaphone/sec(src)
	new /obj/item/storage/lockbox/loyalty(src)
	new /obj/item/clothing/mask/gas/sechailer/swat(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/shield/riot/tele(src)
	new /obj/item/storage/belt/security/full(src)
	new /obj/item/gun/energy/e_gun/hos(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/pinpointer/nuke(src)
	new /obj/item/circuitboard/machine/techfab/department/security(src)
	new /obj/item/storage/photo_album/HoS(src)
	new /obj/item/card/id/departmental_budget/sec(src)

/obj/structure/closet/secure_closet/warden
	name = "\proper warden's locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "warden"

/obj/structure/closet/secure_closet/warden/PopulateContents()
	..()
	new /obj/item/radio/headset/headset_sec(src)
	new /obj/item/clothing/suit/armor/vest/warden(src)
	new /obj/item/clothing/head/warden(src)
	new /obj/item/clothing/head/warden/drill(src)
	new /obj/item/clothing/head/beret/sec/navywarden(src)
	new /obj/item/clothing/head/beret/corpwarden(src)
	new /obj/item/clothing/suit/armor/vest/warden/alt(src)
	new /obj/item/clothing/under/rank/security/warden/formal(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/storage/box/zipties(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/belt/security/full(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/megaphone/sec(src)
	new /obj/item/clothing/gloves/krav_maga/sec(src)
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

/obj/structure/closet/secure_closet/detective/PopulateContents()
	..()
	new /obj/item/storage/box/evidence(src)
	new /obj/item/radio/headset/headset_sec(src)
	new /obj/item/detective_scanner(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/clothing/suit/armor/vest/det_suit(src)
	new /obj/item/clothing/accessory/holster/detective(src)
	new /obj/item/pinpointer/crew(src)
	new /obj/item/twohanded/binoculars(src)
	new /obj/item/clothing/neck/tie/red(src)
	new	/obj/item/clothing/neck/tie/black(src)
	new /obj/item/clothing/neck/tie/detective(src)
	new /obj/item/storage/box/rxglasses/spyglasskit(src)

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
	new /obj/item/clothing/suit/judgerobe (src)
	new /obj/item/clothing/head/powdered_wig (src)
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

/obj/structure/closet/secure_closet/armory1/PopulateContents()
	..()
	new /obj/item/clothing/suit/armor/laserproof(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/suit/armor/riot(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/head/helmet/riot(src)
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

//FREEZER

/obj/structure/closet/secure_closet/freezer
	icon_state = "freezer"
	var/jones = FALSE
	door_anim_squish = 0.22
	door_anim_angle = 123
	door_anim_time = 2.50

/obj/structure/closet/secure_closet/freezer/Destroy()
	recursive_organ_check(src)
	..()

/obj/structure/closet/secure_closet/freezer/Initialize()
	..()
	recursive_organ_check(src)

/obj/structure/closet/secure_closet/freezer/open(mob/living/user)
	if(opened || !can_open(user))	//dupe check just so we don't let the organs decay when someone fails to open the locker
		return FALSE
	recursive_organ_check(src)
	return ..()

/obj/structure/closet/secure_closet/freezer/close(mob/living/user)
	if(..())	//if we actually closed the locker
		recursive_organ_check(src)

/obj/structure/closet/secure_closet/freezer/ex_act()
	if(!jones)
		jones = TRUE
	else
		..()

/obj/structure/closet/secure_closet/freezer/kitchen
	name = "kitchen cabinet"
	req_access = list(ACCESS_KITCHEN)

/obj/structure/closet/secure_closet/freezer/kitchen/PopulateContents()
	..()
	for(var/i = 0, i < 3, i++)
		new /obj/item/reagent_containers/food/condiment/flour(src)
	new /obj/item/reagent_containers/food/condiment/rice(src)
	new /obj/item/reagent_containers/food/condiment/sugar(src)

/obj/structure/closet/secure_closet/freezer/kitchen/maintenance
	name = "maintenance refrigerator"
	desc = "This refrigerator looks quite dusty, is there anything edible still inside?"
	req_access = list()

/obj/structure/closet/secure_closet/freezer/kitchen/maintenance/PopulateContents()
	..()
	for(var/i = 0, i < 5, i++)
		new /obj/item/reagent_containers/food/condiment/milk(src)
	for(var/i = 0, i < 5, i++)
		new /obj/item/reagent_containers/food/condiment/soymilk(src)
	for(var/i = 0, i < 2, i++)
		new /obj/item/storage/fancy/egg_box(src)

/obj/structure/closet/secure_closet/freezer/kitchen/mining
	req_access = list()

/obj/structure/closet/secure_closet/freezer/meat
	name = "meat fridge"
	req_access = list(ACCESS_KITCHEN)

/obj/structure/closet/secure_closet/freezer/meat/PopulateContents()
	..()
	for(var/i = 0, i < 4, i++)
		new /obj/item/reagent_containers/food/snacks/meat/slab/monkey(src)

/obj/structure/closet/secure_closet/freezer/meat/open
	req_access = null
	locked = FALSE


/obj/structure/closet/secure_closet/freezer/fridge
	name = "refrigerator"
	req_access = list(ACCESS_KITCHEN)

/obj/structure/closet/secure_closet/freezer/fridge/PopulateContents()
	..()
	for(var/i = 0, i < 5, i++)
		new /obj/item/reagent_containers/food/condiment/milk(src)
	for(var/i = 0, i < 5, i++)
		new /obj/item/reagent_containers/food/condiment/soymilk(src)
	for(var/i = 0, i < 2, i++)
		new /obj/item/storage/fancy/egg_box(src)

/obj/structure/closet/secure_closet/freezer/fridge/open
	req_access = null
	locked = FALSE

/obj/structure/closet/secure_closet/freezer/money
	name = "freezer"
	desc = "This contains cold hard cash."
	req_access = list(ACCESS_VAULT)

/obj/structure/closet/secure_closet/freezer/money/PopulateContents()
	..()
	for(var/i = 0, i < 3, i++)
		new /obj/item/stack/spacecash/c1000(src)
	for(var/i = 0, i < 5, i++)
		new /obj/item/stack/spacecash/c500(src)
	for(var/i = 0, i < 6, i++)
		new /obj/item/stack/spacecash/c200(src)

/obj/structure/closet/secure_closet/freezer/cream_pie
	name = "cream pie closet"
	desc = "Contains pies filled with cream and/or custard, you sickos."
	req_access = list(ACCESS_THEATRE)

/obj/structure/closet/secure_closet/freezer/cream_pie/PopulateContents()
	..()
	new /obj/item/reagent_containers/food/snacks/pie/cream(src)
