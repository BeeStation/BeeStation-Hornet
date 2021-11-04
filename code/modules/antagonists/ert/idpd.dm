////Outfit Datums////
/datum/outfit/ert/idpd
	name = "I.D.P.D Grunt"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/ert/idpd
	suit_store = /obj/item/gun/energy/e_gun
	shoes = /obj/item/clothing/shoes/magboots/commando
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	glasses = /obj/item/clothing/glasses/hud/toggle/thermal
	back = /obj/item/tank/jetpack/oxygen
	belt = /obj/item/storage/belt/security/full
	r_hand = /obj/item/construction/rcd/combat
	id = /obj/item/card/id/ert
	ears = /obj/item/radio/headset/headset_cent/alt
	l_pocket = /obj/item/rcd_ammo/large

/datum/outfit/idpd/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/storage/backpack/B = H.back
	B.icon_state = "brokenpack"
	B.item_state = "brokenpack"

	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

	var/obj/item/implant/mindshield/L = new/obj/item/implant/mindshield(H)
	L.implant(H, null, 1)

	var/obj/item/implant/explosive/E = new/obj/item/implant/mindshield(H)
	E.implant(H, null, 1)

	if(istype(H.s_store, /obj/item/gun/energy/e_gun))
		var/obj/item/gun/energy/e_gun/gun = H.s_store
		gun.selfcharge = TRUE

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_centcom_access("Death Commando")
	W.assignment = "I.D.P.D Officer"
	W.registered_name = H.real_name
	W.update_label(W.registered_name, W.assignment)


/datum/outfit/ert/idpd/captain
	name = "I.D.P.D Captain"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/idpd/captain
	suit_store = /obj/item/gun/energy/pulse/carbine/loyalpin
	l_pocket = /obj/item/gun/energy/pulse/pistol/loyalpin
	r_hand = null
	l_hand = null

/datum/outfit/ert/idpd/observer
	name = "I.D.P.D Observer"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/idpd/observer
	suit_store = /obj/item/gun/energy/laser/scatter
	l_pocket = /obj/item/reagent_containers/hypospray/combat
	l_hand = /obj/item/storage/firstaid/tactical
	r_hand = null

/datum/outfit/ert/idpd/observer/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(!visualsOnly)
		H.dna.add_mutation(TK)
/datum/outfit/ert/idpd/shielder
	name = "I.D.P.D Shielder"

	suit = /obj/item/clothing/suit/space/hardsuit/ert/idpd/shielder
	l_pocket = null
	l_hand = /obj/item/pickaxe/drill/jackhammer //BREACHING
	r_hand = null

/datum/outfit/ert/idpd/shielder/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(visualsOnly)
		return
	var/obj/effect/proc_holder/spell/targeted/forcewall/idpd/wall = new
	H.AddSpell(wall)


////Antag Datums////
/datum/antagonist/ert/idpd
	name = "I.D.P.D Grunt"
	role = "Grunt"
	outfit = /datum/outfit/ert/idpd
	show_in_antagpanel = TRUE

/datum/antagonist/ert/idpd/observer
	name = "I.D.P.D Observer"
	role = "Observer"
	outfit = /datum/outfit/ert/idpd/observer

/datum/antagonist/ert/idpd/shielder
	name = "I.D.P.D Shielder"
	role = "Shielder"
	outfit = /datum/outfit/ert/idpd/shielder

/datum/antagonist/ert/idpd/captain
	name = "I.D.P.D Captain"
	role = "Captain"
	outfit = /datum/outfit/ert/idpd/captain

////Shielder Spell
/obj/effect/proc_holder/spell/targeted/forcewall/idpd
	name = "Barrier Projector"
	desc = "Create an energy barrier to protect your team."
	charge_max = 400
	invocation = ""
	invocation_type = "none"
	wall_type = /obj/effect/forcefield/idpd

/obj/effect/forcefield/idpd

/obj/effect/forcefield/idpd/CanPass(atom/movable/mover, turf/target)
	return FALSE //None shall pass
