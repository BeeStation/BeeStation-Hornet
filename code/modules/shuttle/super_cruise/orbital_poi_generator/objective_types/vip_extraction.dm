/datum/orbital_objective/vip_recovery
	name = "VIP Recovery"
	var/generated = FALSE
	var/mob/mob_to_recover
	var/suit_type = /obj/item/clothing/suit/space/hardsuit/ancient
	var/tank_type = /obj/item/tank/internals/oxygen
	var/mask_type = /obj/item/clothing/mask/gas
	var/belt_type = /obj/item/storage/belt/utility/full
	min_payout = 10000
	max_payout = 20000

/datum/orbital_objective/vip_recovery/get_text()
	return "Someone of particular interest to us is located at [station_name]. We require them to be extracted immediately. \
		We have good intel to suggest that the VIP is still alive, however if not their personal diary-disk should have enough infomation \
		about what we are looking for. An additional point to note is that it is recommended a security team assists in this mission due \
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
		//Dead and no ckey
		if(mob_to_recover.stat == DEAD && mob_to_recover.ckey == null)
			return TRUE
	return FALSE

/datum/orbital_objective/vip_recovery/generate_objective_stuff(turf/chosen_turf)
	var/mob/living/carbon/human/created_human = new(chosen_turf)
	//Maybe polling ghosts would be better than the shintience code
	created_human.set_playable()
	created_human.mind_initialize()
	//Remove nearby dangers
	for(var/mob/living/simple_animal/hostile/SA in range(10, created_human))
		qdel(SA)
	var/antag_elligable = FALSE
	switch(pick_weight(list("centcom_official" = 4, "greytide" = 3)))
		if("centcom_official")
			created_human.flavor_text = "You are a CentCom official onboard a badly damaged station. Making your way back to Space Station 13 to uncover the secrets you hold is \
				your top priority as far as Nanotrasen is concerned, but surviving just one more day is all you can ask for."
			created_human.equipOutfit(/datum/outfit/vip_target/centcom_official_vip)
			suit_type = /obj/item/clothing/suit/space/fragile //Riches To Rags
			antag_elligable = TRUE
		if("greytide")
			created_human.flavor_text = "You are just an assistant on a lonely derelict station. You dream of going home, \
				but it would take another one of the miracles that kept you alive to get you home."
			created_human.equipOutfit(/datum/outfit/vip_target/greytide)
			antag_elligable = TRUE
	created_human.mind.store_memory(created_human.flavor_text)
	if(antag_elligable)
		if(prob(7))
			created_human.mind.make_Traitor()
			created_human.flavor_text += " - That was, until you made a deal with your newfound Benefactors. You know Nanotrasen is sending a recovery team - \
			And, hopefully, how to exploit your newfound position..." //Makes their special status a little more obvious upon entering the mob
		else if(prob(8))
			created_human.mind.make_Changeling()
			created_human.flavor_text += " - Or so's the cover story we've curated to sway the hearts of the hapless souls who, one day, may stumble upon \
			our miserable, eeked out existence here... And inadvertently begin the hunt anew." //Ditto
	mob_to_recover = created_human
	//Give them space-worthy suit and other equipment
	var/turf/open/T = locate() in shuffle(view(1, created_human))
	if(T)
		new suit_type(T)
		new tank_type(T)
		new mask_type(T)
		new belt_type(T)
	generated = TRUE

//=====================
// BASE VIP Outfit
//=====================
//Here to pre-emptively allow for post_equip in future expansions

/datum/outfit/vip_target
	name = "Base VIP Target"

	uniform = /obj/item/clothing/under/color/random
	shoes = /obj/item/clothing/shoes/sneakers/black
	back = /obj/item/storage/backpack
	r_hand = /obj/item/gps

/datum/outfit/vip_target/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	if(H.wear_id?.GetID())
		var/obj/item/card/id/I = H.wear_id.GetID()
		if(I)
			I.registered_name = H.real_name
			I.update_label()


//=====================
// Centcom Official (VIP)
//=====================

/datum/outfit/vip_target/centcom_official_vip
	name = "Centcom (VIP Target)"

	uniform = /obj/item/clothing/under/rank/centcom/officer
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/radio/headset/headset_cent/empty
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	belt = /obj/item/gun/energy/e_gun
	l_pocket = /obj/item/pen
	back = /obj/item/storage/backpack/satchel
	r_pocket = /obj/item/modular_computer/tablet/pda/heads
	l_hand = /obj/item/clothing/head/helmet/space/fragile
	id = /obj/item/card/id/away/old

//=====================
// Greytide (VIP And Assassination)
//=====================

/datum/outfit/vip_target/greytide
	name = "Greytide (VIP Target)"

	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/yellow
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	belt = /obj/item/storage/belt/utility/full/engi
	id = /obj/item/card/id
	head = /obj/item/clothing/head/helmet
	l_hand = /obj/item/melee/baton/loaded
