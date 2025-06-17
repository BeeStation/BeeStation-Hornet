/obj/structure/closet/secure_closet/medical1
	name = "medicine closet"
	desc = "Filled to the brim with medical junk."
	icon_state = "med"
	req_access = list(ACCESS_MEDICAL)

/obj/structure/closet/secure_closet/medical1/PopulateContents()
	..()
	var/static/items_inside = list(
		/obj/item/reagent_containers/cup/beaker = 2,
		/obj/item/reagent_containers/dropper = 2,
		/obj/item/storage/belt/medical = 1,
		/obj/item/storage/box/syringes = 1,
		/obj/item/reagent_containers/cup/bottle/toxin = 1,
		/obj/item/reagent_containers/cup/bottle/morphine = 2,
		/obj/item/reagent_containers/cup/bottle/epinephrine= 3,
		/obj/item/reagent_containers/cup/bottle/charcoal = 3,
		/obj/item/storage/box/rxglasses = 1,
		/obj/item/stack/ducts/fifty = 4,
		/obj/item/construction/plumbing = 2,
		/obj/item/plunger = 2,
		/obj/item/rcd_ammo = 4)
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
	new /obj/item/clothing/head/beret/medical(src)
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
	new /obj/item/reagent_containers/cup/bottle/formaldehyde(src)
	new /obj/item/reagent_containers/cup/bottle/formaldehyde(src)
	new /obj/item/reagent_containers/cup/bottle/charcoal(src)
	new /obj/item/reagent_containers/cup/bottle/chloralhydrate(src)
	new /obj/item/reagent_containers/cup/bottle/morphine(src)
	new /obj/item/reagent_containers/cup/bottle/sodium_thiopental(src)
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

/obj/structure/closet/secure_closet/CMO/populate_contents_immediate()
	..()
	new /obj/item/card/id/departmental_budget/med(src)
	new /obj/item/reagent_containers/hypospray/CMO(src)

/obj/structure/closet/secure_closet/CMO/PopulateContents()
	..()
	new /obj/item/storage/box/suitbox/cmo(src)
	new /obj/item/storage/backpack/duffelbag/med(src)
	new /obj/item/clothing/suit/toggle/labcoat/cmo(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/radio/headset/heads/cmo(src)

	new /obj/item/clothing/suit/bio_suit/cmo(src)
	new /obj/item/clothing/head/bio_hood/cmo(src)
	new /obj/item/clothing/neck/petcollar(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/storage/photo_album/CMO(src)

	new /obj/item/storage/box/radiokey/med(src)
	new /obj/item/storage/box/command_keys(src)
	new /obj/item/megaphone/command(src)
	new /obj/item/computer_hardware/hard_drive/role/cmo(src)
	new /obj/item/storage/lockbox/medal/med(src)

	new /obj/item/circuitboard/machine/techfab/department/medical(src)
	new /obj/item/reagent_containers/cup/glass/bottle/synthflesh(src)

	// prioritized items
	new /obj/item/door_remote/chief_medical_officer(src)
	new /obj/item/autosurgeon/cmo(src)
	new /obj/item/extrapolator(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/clothing/neck/cloak/cmo(src)
	new /obj/item/defibrillator/compact/loaded(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/healthanalyzer/advanced(src)
	new /obj/item/wallframe/defib_mount(src)
	new /obj/item/gun/ballistic/automatic/pistol/service/cmo(src)
	new /obj/item/ammo_box/magazine/recharge/service(src)

/obj/item/storage/box/suitbox/cmo
	name = "compression box of chief medical officer outfits"

/obj/item/storage/box/suitbox/cmo/PopulateContents()
	new /obj/item/clothing/under/rank/medical/chief_medical_officer(src)
	new /obj/item/clothing/under/rank/medical/chief_medical_officer/skirt(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/head/beret/medical/cmo(src)

/obj/structure/closet/secure_closet/animal
	name = "animal control"
	req_access = list(ACCESS_SURGERY)

/obj/structure/closet/secure_closet/animal/PopulateContents()
	..()
	new /obj/item/assembly/signaler(src)
	for(var/i in 1 to 3)
		new /obj/item/electropack(src)

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
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd_ammo(src)

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
