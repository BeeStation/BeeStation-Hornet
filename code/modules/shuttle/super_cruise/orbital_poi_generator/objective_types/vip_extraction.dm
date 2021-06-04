/datum/orbital_objective/vip_recovery
	name = "VIP Recovery"
	var/generated = FALSE
	var/death_caring = TRUE
	var/mob/mob_to_recover
	//Relatively easy mission.
	min_payout = 100000
	max_payout = 400000

/datum/orbital_objective/vip_recovery/get_text()
	return "Someone of particular interest to use is located at [station_name]. We require them to be extracted immediately. \
		We have good intel to suggest that the VIP is still alive, however if not their personal diary-disk should have enough infomation \
		about what we are looking for. An additional point to note is that it is recommended a security team assists in this mission due \
		to the potentially hostile nature of the individual. Return the individual to the station alive to complete the objective."

//If nobody takes up the ghost role, then we dont care if they died.
//I know, its a bit sad.
/datum/orbital_objective/vip_recovery/check_failed()
	if(generated)
		if(QDELETED(mob_to_recover))
			return TRUE
		if(mob_to_recover.stat == DEAD)
			if(mob_to_recover.key && death_caring)
				return TRUE
			if(!mob_to_recover.key)
				if(death_caring)
					//Spawn in a diary
					var/obj/item/disk/record/diary = new(get_turf(mob_to_recover))
					diary.setup_recover(src)
					priority_announce("Sensors indicate that the VIP you were required to extract has perished from the \
						events that took place in the outpost. Recover their personal logbook and bring it to the station bridge \
						for recovery.")
				death_caring = FALSE
		else if(is_station_level(mob_to_recover.z))
			complete_objective()
	return FALSE

/datum/orbital_objective/vip_recovery/generate_objective_stuff(turf/chosen_turf)
	var/mob/living/carbon/human/created_human = new(chosen_turf)
	//Maybe polling ghosts would be better than the shintience code
	created_human.set_playable()
	created_human.mind_initialize()
	//Remove nearby dangers
	for(var/mob/living/simple_animal/hostile/SA in view(10, created_human))
		qdel(SA)
	//Give them a space worthy suit
	var/turf/open/T = locate() in shuffle(view(1, created_human))
	if(T)
		new /obj/item/clothing/suit/space/hardsuit/ancient(T)
		new /obj/item/tank/internals/oxygen(T)
		new /obj/item/clothing/mask/gas(T)
		new /obj/item/storage/belt/utility/full(T)
	var/antag_elligable = FALSE
	switch(pickweight(list("centcom_official" = 4, "dictator" = 1, "greytide" = 3)))
		if("centcom_official")
			created_human.flavor_text = "You are centcom official on board a badly damaged station. Making your way back to the station to uncover the secrets you hold is \
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
	if(antag_elligable)
		if(prob(7))
			created_human.mind.make_Traitor()
		else if(prob(8))
			created_human.mind.make_Changeling()
	mob_to_recover = created_human
	generated = TRUE

/obj/item/disk/record
	name = "Record Disk"
	desc = "A disk containing the logs for whatever happened."

/obj/item/disk/record/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/gps, "LOG[rand(1000, 9999)]", TRUE)

/obj/item/disk/record/proc/setup_recover(linked_mission)
	AddComponent(/datum/component/recoverable, linked_mission)

/obj/item/disk/record/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Use in hand on the <b>bridge</b> of the station to send it to Nanotrasen and complete the objective.</span>"


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
