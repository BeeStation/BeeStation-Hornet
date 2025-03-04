/datum/outfit/ninja
	name = "Space Ninja"
	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/space/space_ninja
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/space_ninja
	head = /obj/item/clothing/head/helmet/space/space_ninja
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/space_ninja
	gloves = /obj/item/clothing/gloves/space_ninja
	back = /obj/item/tank/jetpack/carbondioxide
	l_pocket = /obj/item/grenade/plastic/x4
	r_pocket = /obj/item/tank/internals/emergency_oxygen
	internals_slot = ITEM_SLOT_RPOCKET
	belt = /obj/item/energy_katana
	implants = list(/obj/item/implant/explosive)


/datum/outfit/ninja/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return FALSE
	if(istype(H.wear_suit, suit))
		var/obj/item/clothing/suit/space/space_ninja/S = H.wear_suit
		if(istype(H.belt, belt))
			S.energyKatana = H.belt
		S.randomize_param()

/datum/outfit/ninja_modsuit
	name = "Space Ninja (modsuit)"
	uniform = /obj/item/clothing/under/syndicate/ninja
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/space_ninja
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/grenade/plastic/x4
	r_pocket = /obj/item/tank/internals/emergency_oxygen
	internals_slot = ITEM_SLOT_RPOCKET
	belt = /obj/item/energy_katana
	back = /obj/item/mod/control/pre_equipped/ninja
	implants = list(/obj/item/implant/explosive)

/datum/outfit/ninja_modsuit/post_equip(mob/living/carbon/human/ninja)
	var/obj/item/mod/control/mod = ninja.back
	if(!istype(mod))
		return
	var/obj/item/mod/module/dna_lock/reinforced/lock = locate(/obj/item/mod/module/dna_lock/reinforced) in mod.modules
	lock.dna = ninja.dna.unique_enzymes
	var/obj/item/mod/module/weapon_recall/recall = locate(/obj/item/mod/module/weapon_recall) in mod.modules
	var/obj/item/weapon = ninja.belt
	if(!istype(weapon, recall.accepted_type))
		return
	recall.set_weapon(weapon)
