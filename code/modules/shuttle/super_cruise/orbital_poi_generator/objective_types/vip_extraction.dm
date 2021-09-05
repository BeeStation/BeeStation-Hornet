/datum/orbital_objective/vip_recovery
	name = "VIP Recovery"
	var/generated = FALSE
	var/mob/mob_to_recover
	min_payout = 100000
	max_payout = 200000

/datum/orbital_objective/vip_recovery/get_text()
	return "Someone of particular interest to us is located at [station_name]. We require them to be extracted immediately. \
		We have good intel to suggest that the VIP is still alive, however, if not, their personal diary-disk should have enough infomation \
		about what we are looking for. In addition, it is recommended a security team assists in this mission due \
		to the potentially hostile nature of the individual. Return the individual to the station alive to complete the objective."

//If nobody takes up the ghost role, then we dont care if they died.
//I know, its a bit sad.
/datum/orbital_objective/vip_recovery/check_failed()
	if(generated)
		//Deleted
		if(QDELETED(mob_to_recover))
			return TRUE
		//Left behind
		if(mob_to_recover in SSzclear.nullspaced_mobs)
			return TRUE
		//Recovered and alive
		if(is_station_level(mob_to_recover.z) && mob_to_recover.stat == CONSCIOUS)
			complete_objective()
	return FALSE

/datum/orbital_objective/vip_recovery/generate_objective_stuff(turf/chosen_turf)
	var/mob/living/carbon/human/created_human = new(chosen_turf)
	//Maybe polling ghosts would be better than the shintience code
	created_human.set_playable()
	created_human.mind_initialize()
	//Remove nearby dangers
	for(var/mob/living/simple_animal/hostile/SA in range(10, created_human))
		qdel(SA)
	//Give them a space worthy suit
	var/turf/open/T = locate() in shuffle(view(1, created_human))
	if(T)
		new /obj/item/clothing/suit/space/hardsuit/ancient(T)
		new /obj/item/tank/internals/oxygen(T)
		new /obj/item/clothing/mask/gas(T)
		new /obj/item/storage/belt/utility/full(T)
	var/antag_elligable = FALSE
	switch(pickweight(list("centcom_official" = 4, "dictator" = 1, "greytide" = 3, "marooned_syndicate_op" = 0.5, "serial_killer" = 0.5, "soviet_admiral" = 1)))
		if("centcom_official")
			created_human.flavor_text = "You are a Central Command Official on board of a badly damaged station. Making your way back to civilization to uncover the secrets you hold is \
				your top priority as far as Nanotrasen is concerned, but just surviving 1 more day is all you can ask for."
			created_human.equipOutfit(/datum/outfit/centcom_official_vip)
			antag_elligable = TRUE
		if("dictator")
			created_human.flavor_text = "It has been months since your regime fell. Once a hero, now just someone wishing that they will see the next sunrise. You know those \
				Nanotrasen pigs are after you, and will stop at nothing to capture you. All you want at this point is to get out and survive, however it is likely you will never leave \
				without being captured."
			created_human.equipOutfit(/datum/outfit/vip_dictator)
			created_human.mind.add_antag_datum(/datum/antagonist/vip_dictator)
		if("greytide")
			created_human.flavor_text = "You are just a lonely assistant, on a lonely derelict station. You dream of going home, \
				but it would take another one of the miracles that kept you alive to get you home."
			created_human.equipOutfit(/datum/outfit/greytide)
			antag_elligable = TRUE
		if("marooned_syndicate_op")
			created_human.flavor_text = "It was supposed to be just another hit on just another Nanotrasen outpost, but in a moment of panic your squad left you behind and now \
			you're stuck on this abandoned rust-heap, you're certain that Nanotrasen will dispatch a team to investigate what happened here, but you don't intend to let them find out."
			created_human.equipOutfit(/datum/outfit/syndicate_op)
			created_human.mind.add_antag_datum(/datum/antagonist/marooned_syndicate_op)
		if("serial_killer")
			created_human.flavor_text = "<span class='userdanger'>NO NOOO NOOOOOOO!!! IT CAN'T BE!! THEY ARE COMING FOR YOU, DON'T LET THEM GET YOU, KILL THEM ALL!!"
			created_human.mind.add_antag_datum(/datum/antagonist/insane_killer)
			antag_elligable = TRUE
		if("soviet_admiral")
			created_human.flavor_text = "Ivan Ivanov Ivanovich II, your superior, sent you to this Corporate Station in order to negotiate a deal between the Third Soviet Union and Nanotrasen,\
			despite your inability of speaking galactic common, now weeks later, you wish you would've never come to this place, if you somehow manage to survive this, Ivan can be certain to feel your fist in his fat mug."
			created_human.add_quirk(/datum/quirk/foreigner) //Blyat
	if(antag_elligable)
		if(prob(7))
			created_human.mind.make_Traitor()
		else if(prob(8))
			created_human.mind.make_Changeling()
	mob_to_recover = created_human
	generated = TRUE


//=====================
// Centcom Official
//=====================

/datum/outfit/centcom_official_vip
	name = "Centcom VIP"

	uniform = /obj/item/clothing/under/rank/centcom/officer
	shoes = /obj/item/clothing/shoes/sneakers/black
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/radio/headset/headset_cent/empty
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	belt = /obj/item/gun/energy/e_gun
	l_pocket = /obj/item/pen
	back = /obj/item/storage/backpack/satchel
	r_pocket = /obj/item/pda/heads
	l_hand = /obj/item/clipboard
	r_hand = /obj/item/gps
	id = /obj/item/card/id/away/old

//=====================
// Matryr Dictator
//=====================

/datum/antagonist/vip_dictator
	name = "Insane VIP"
	show_in_antagpanel = TRUE
	roundend_category = "Ruin VIPs"
	antagpanel_category = "Other"

/datum/outfit/vip_dictator
	name = "Dictator VIP"

	uniform = /obj/item/clothing/under/rank/security/head_of_security/white
	suit = /obj/item/clothing/suit/armor/hos
	suit_store = /obj/item/gun/ballistic/automatic/pistol/m1911
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch
	belt = /obj/item/storage/belt/sabre
	l_pocket = /obj/item/ammo_box/magazine/m45
	r_pocket = /obj/item/grenade/smokebomb
	id = /obj/item/card/id/away/old
	neck = /obj/item/clothing/neck/crucifix
	head = /obj/item/clothing/head/HoS/beret/syndicate
	r_hand = /obj/item/gps

//=====================
// Greytide
//=====================

/datum/outfit/greytide
	name = "Greytide"

	uniform = /obj/item/clothing/under/color/random
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/yellow
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	belt = /obj/item/storage/belt/utility/full/engi
	id = /obj/item/card/id
	head = /obj/item/clothing/head/helmet
	l_hand = /obj/item/melee/baton/loaded
	r_hand = /obj/item/gps

//=====================
// Marooned Syndicate Operative
//=====================

/datum/antagonist/marooned_syndicate_op
	name = "Marooned Syndicate Operative"
	show_in_antagpanel = TRUE
	roundend_category = "Ruin VIPs"
	antagpanel_category = "Other"
/datum/outfit/syndicate_op
	name = "Marooned Syndicate Operative"

	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/space/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/syndicate/alt
	glasses = /obj/item/clothing/glasses/hud/security/chameleon
	belt = /obj/item/storage/belt/military
	id = /obj/item/card/id/syndicate
	head = /obj/item/clothing/head/helmet/space/syndicate
	r_hand = /obj/item/gun/ballistic/automatic/pistol
	l_hand = /obj/item/melee/transforming/energy/sword
	mask = /obj/item/clothing/mask/gas/syndicate
	suit_store = /obj/item/tank/internals/emergency_oxygen/double
	back = /obj/item/storage/backpack/duffelbag/syndie
	backpack_contents = list(
		/obj/item/grenade/plastic/x4 = 2,
		/obj/item/ammo_box/magazine/m10mm = 3,
		)

//=====================
// Insane Serial Killer
//=====================

/datum/antagonist/insane_killer
	name = "Insane Serial Killer"
	show_in_antagpanel = TRUE
	roundend_category = "Ruin VIPs"
	antagpanel_category = "Other"
/datum/outfit/insane_killer
	name = "Masked Killer"

	uniform = /obj/item/clothing/under/misc/overalls
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/latex
	mask = /obj/item/clothing/mask/surgical
	head = /obj/item/clothing/head/welding
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	suit = /obj/item/clothing/suit/apron
	l_pocket = /obj/item/kitchen/knife
	r_pocket = /obj/item/scalpel
	r_hand = /obj/item/fireaxe

/datum/outfit/insane_killer/post_equip(mob/living/carbon/human/H)
	for(var/obj/item/carried_item in H.get_equipped_items(TRUE))
		carried_item.add_mob_blood(H)//Oh yes, there will be blood...
	for(var/obj/item/I in H.held_items)
		I.add_mob_blood(H)
	H.regenerate_icons()

//=====================
// Soviet Admiral
//=====================
/datum/outfit/soviet
	name = "Soviet Admiral"

	uniform = /obj/item/clothing/under/costume/soviet
	head = /obj/item/clothing/head/pirate/captain
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/headset_cent/empty
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	suit = /obj/item/clothing/suit/pirate/captain
	back = /obj/item/storage/backpack/satchel/leather
	belt = /obj/item/gun/ballistic/revolver/mateba
	id = /obj/item/card/id

/datum/outfit/soviet/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.assignment = "Адмирал" //Admiral
	W.registered_name = H.real_name
	W.update_label()
