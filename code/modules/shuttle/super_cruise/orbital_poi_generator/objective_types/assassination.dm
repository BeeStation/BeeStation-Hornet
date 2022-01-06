/datum/orbital_objective/assassination
	name = "Assassination"
	var/generated = FALSE
	var/mob/mob_to_kill
	min_payout = 15000
	max_payout = 40000

/datum/orbital_objective/assassination/get_text()
	return "We have located a hostile agent currently stranded at [station_name]. We need you to send in a team and eliminate the \
		target. Our intelligence suggests that the target will be armed and dangerous, thus a security team is recommended in this mission. \
		Please keep in mind that the Nanotrasen approved exploration handheld laser gun is not adept at handling human based targets."

//If nobody takes up the ghost role, then we dont care if they died.
//I know, its a bit sad.
/datum/orbital_objective/assassination/check_failed()
	if(generated)
		//Deleted
		if(QDELETED(mob_to_kill))
			complete_objective()
			return FALSE
		//Left behind
		if(mob_to_kill in SSzclear.nullspaced_mobs)
			complete_objective()
			return FALSE
		//Recovered and alive
		if(mob_to_kill.stat == DEAD)
			complete_objective()
			return FALSE
	return FALSE

/datum/orbital_objective/assassination/generate_objective_stuff(turf/chosen_turf)
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
	switch(pickweight(list("dictator" = 1, "operative" = 1, "greytide" = 3)))
		if("dictator")
			created_human.flavor_text = "It has been months since your regime fell. Once a hero, you're now just someone wishing that they will see the next sunrise. You know those \
				Nanotrasen pigs are after you, and will stop at nothing to capture you. All you want at this point is to get out and survive, however it is likely you will never leave \
				without being captured."
			created_human.equipOutfit(/datum/outfit/vip_dictator)
		if("greytide")
			created_human.flavor_text = "You are just an assistant on a lonely derelict station. You dream of going home, \
				but a powerful corporation wants you dead. Stay alive."
			created_human.equipOutfit(/datum/outfit/greytide)
		if("operative")
			created_human.flavor_text = "You are a syndicate operative standed by your team aboard an ancient ruin. You know it won't take long for Nanotrasen \
				to catch up and eliminate you, stay on your guard."
			created_human.equipOutfit(/datum/outfit/vip_operative)
	created_human.mind.store_memory("Someone is out to assassinate you... Stay alive.")
	created_human.mind.add_antag_datum(/datum/antagonist/survivalist)
	mob_to_kill = created_human
	generated = TRUE

//=====================
// Operative
//=====================

/datum/outfit/vip_operative
	name = "Operative VIP"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/armor/bulletproof
	suit_store = /obj/item/gun/ballistic/automatic/pistol
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	belt = /obj/item/storage/belt/military
	l_pocket = /obj/item/ammo_box/magazine/m10mm
	r_pocket = /obj/item/grenade/smokebomb
	id = /obj/item/card/id/away/old

//=====================
// Matryr Dictator
//=====================

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
