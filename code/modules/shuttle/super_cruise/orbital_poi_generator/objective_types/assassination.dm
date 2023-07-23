/datum/orbital_objective/assassination
	name = "Assassination"
	var/generated = FALSE
	var/mob/mob_to_kill
	var/suit_type = /obj/item/clothing/suit/space/hardsuit/ancient
	var/tank_type = /obj/item/tank/internals/oxygen
	var/mask_type = /obj/item/clothing/mask/gas
	var/belt_type = /obj/item/storage/belt/utility/full
	min_payout = 10000
	max_payout = 30000

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
	created_human.set_playable(ROLE_SURVIVALIST)
	created_human.mind_initialize()
	//Remove nearby dangers
	for(var/mob/living/simple_animal/hostile/SA in range(10, created_human))
		qdel(SA)
	switch(pick_weight(list("secretagentman" = 1, "dictator" = 1, "operative" = 1, "greytide" = 3, "funnyman" = 2)))
		if("secretagentman")
			created_human.flavor_text = "On behalf of your Benefactors, you lead a life of danger - To everyone you meet, you stay a stranger. but you moved too much, took too many chances - \
			Considering Nanotrasen's onto you, odds are you won't live to see tomorrow."
			created_human.equipOutfit(/datum/outfit/vip_target/super_spy)
		if("dictator")
			created_human.flavor_text = "It has been months since your regime fell. Once a hero, you're now just someone wishing that they will see the next sunrise. You know those \
				Nanotrasen pigs are after you, and will stop at nothing to capture you. All you want at this point is to get out and survive, however it is likely you will never leave \
				without being captured, or worse..."
			created_human.equipOutfit(/datum/outfit/vip_target/vip_dictator)
		if("greytide")
			created_human.flavor_text = "You are just an assistant on a lonely derelict station. You dream of going home, but you broke the wrong airlock - \
			Now your former employer, Nanotrasen, is after you..."
			created_human.equipOutfit(/datum/outfit/vip_target/greytide)
		if("operative")
			created_human.flavor_text = "You are a Syndicate operative employed by Cybersun Industries, currently scavenging for valuable resources in the wrecks of Nanotrasen Derelicts. \
			However, upon being dropped off for your shift, the shuttle that flew you onboard was shot down by Nanotrasen's forces. You know it's only a matter of time before they find you..."
			created_human.equipOutfit(/datum/outfit/vip_target/vip_operative)
			suit_type = /obj/item/clothing/suit/space/hardsuit/cybersun //On par with the explorer suit, nothing too wacky.
			mask_type = /obj/item/clothing/mask/gas/syndicate
		if("funnyman")
			created_human.flavor_text = "Slip, slip, slip! Your PDA's brought a lot of laughs to this crew, but now that they're - and it's - gone, the Head Of Security's threats are \
			echoing in your mind..."
			created_human.equipOutfit(/datum/outfit/vip_target/clown)
	created_human.mind.store_memory("[created_human.flavor_text] - Someone is out to assassinate you... Stay alive.")
	created_human.mind.add_antag_datum(/datum/antagonist/survivalist)
	mob_to_kill = created_human
	//Give them space-worthy suit and other equipment
	var/turf/open/T = locate() in shuffle(view(1, created_human))
	if(T)
		new suit_type(T)
		new tank_type(T)
		new mask_type(T)
		new belt_type(T)
	generated = TRUE

//=====================
// Operative
//=====================

/datum/outfit/vip_target/vip_operative
	name = "Operative (VIP Target)"

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
	id = /obj/item/card/id/syndicate_command

//=====================
// Martyr Dictator
//=====================

/datum/outfit/vip_target/vip_dictator
	name = "Dictator (VIP Target)"

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

//=====================
// Super Spy
//=====================

/datum/outfit/vip_target/super_spy
	name = "Super Spy (VIP Target)"

	uniform = /obj/item/clothing/under/chameleon
	suit = /obj/item/clothing/suit/chameleon
	shoes = /obj/item/clothing/shoes/chameleon
	gloves = /obj/item/clothing/gloves/chameleon
	ears = /obj/item/radio/headset/chameleon
	glasses = /obj/item/clothing/glasses/chameleon
	belt = /obj/item/storage/belt/chameleon
	l_pocket = /obj/item/stamp/chameleon
	r_pocket = /obj/item/modular_computer/tablet/pda/chameleon
	id = /obj/item/card/id/syndicate/anyone
	neck = /obj/item/clothing/neck/chameleon
	head = /obj/item/clothing/head/chameleon
	back = /obj/item/storage/backpack/chameleon

//=====================
// Clown
//=====================

/datum/outfit/vip_target/clown
	name = "Clown (VIP Target)"

	id = /obj/item/card/id/job/clown
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_pocket = /obj/item/bikehorn
	back = /obj/item/storage/backpack/clown
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		)

	implants = list(/obj/item/implant/sad_trombone)

/datum/outfit/vip_target/clown/post_equip(mob/living/carbon/human/H)
	H.fully_replace_character_name(H.real_name, pick(GLOB.clown_names))
	H.dna.add_mutation(CLOWNMUT)
