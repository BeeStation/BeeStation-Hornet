//If someone can do this in a neater way, be my guest-Kor

//To do: Allow corpses to appear mangled, bloody, etc. Allow customizing the bodies appearance (they're all bald and white right now).

/obj/effect/mob_spawn
	name = "Unknown"
	density = TRUE
	anchored = TRUE
	var/mob_type = null
	var/mob_name = ""
	var/mob_gender = null
	var/death = TRUE //Kill the mob
	var/roundstart = TRUE //fires on initialize
	var/instant = FALSE	//fires on New
	var/short_desc = "The mapper forgot to set this!"
	var/flavour_text = ""
	var/important_info = ""
	var/faction = null
	var/permanent = FALSE	//If true, the spawner will not disappear upon running out of uses.
	var/random = FALSE		//Don't set a name or gender, just go random
	var/antagonist_type
	var/objectives = null
	var/uses = 1			//how many times can we spawn from it. set to -1 for infinite.
	var/brute_damage = 0
	var/oxy_damage = 0
	var/burn_damage = 0
	var/datum/disease/disease = null //Do they start with a pre-spawned disease?
	var/mob_color //Change the mob's color
	var/assignedrole
	var/show_flavour = TRUE
	var/banType = ROLE_LAVALAND
	var/ghost_usable = TRUE
	var/use_cooldown = FALSE

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/effect/mob_spawn/attack_ghost(mob/user)
	if(!SSticker.HasRoundStarted() || !loc || !ghost_usable)
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER) && !(flags_1 & ADMIN_SPAWNED_1))
		to_chat(user, "<span class='warning'>An admin has temporarily disabled non-admin ghost roles!</span>")
		return
	if(!uses)
		to_chat(user, "<span class='warning'>This spawner is out of charges!</span>")
		return
	if(is_banned_from(user.key, banType))
		to_chat(user, "<span class='warning'>You are jobanned!</span>")
		return
	if(QDELETED(src) || QDELETED(user))
		return
	if(use_cooldown && user.client.next_ghost_role_tick > world.time)
		to_chat(user, "<span class='warning'>You have died recently, you must wait [(user.client.next_ghost_role_tick - world.time)/10] seconds until you can use a ghost spawner.</span>")
		return
	var/ghost_role = alert("Become [mob_name]? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(ghost_role != "Yes" || !loc)
		return
	log_game("[key_name(user)] became [mob_name]")
	create(ckey = user.ckey)

/obj/effect/mob_spawn/Initialize(mapload)
	. = ..()
	if(instant || (roundstart && (mapload || (SSticker && SSticker.current_state > GAME_STATE_SETTING_UP))))
		create()
	else if(ghost_usable)
		GLOB.poi_list |= src
		LAZYADD(GLOB.mob_spawners[name], src)
		SSmobs.update_spawners()

/obj/effect/mob_spawn/Destroy()
	GLOB.poi_list -= src
	var/list/spawners = GLOB.mob_spawners[name]
	LAZYREMOVE(spawners, src)
	if(!LAZYLEN(spawners))
		GLOB.mob_spawners -= name
	SSmobs.update_spawners()
	return ..()

/obj/effect/mob_spawn/proc/special(mob/M)
	return

/obj/effect/mob_spawn/proc/equip(mob/M)
	return

/obj/effect/mob_spawn/proc/create(ckey, name)
	var/mob/living/M = new mob_type(get_turf(src)) //living mobs only
	if(!random)
		M.real_name = mob_name ? mob_name : M.name
		if(!mob_gender)
			mob_gender = pick(MALE, FEMALE)
		M.gender = mob_gender
	if(faction)
		M.faction = list(faction)
	if(disease)
		M.ForceContractDisease(new disease)
	if(death)
		M.death(1) //Kills the new mob

	M.adjustOxyLoss(oxy_damage)
	M.adjustBruteLoss(brute_damage)
	M.adjustFireLoss(burn_damage)
	M.color = mob_color
	equip(M)

	if(ckey)
		M.ckey = ckey
		if(show_flavour)
			var/output_message = "<span class='big bold'>[short_desc]</span>"
			if(flavour_text != "")
				output_message += "\n<span class='bold'>[flavour_text]</span>"
			if(important_info != "")
				output_message += "\n<span class='userdanger'>[important_info]</span>"
			to_chat(M, output_message)
		var/datum/mind/MM = M.mind
		var/datum/antagonist/A
		if(antagonist_type)
			A = MM.add_antag_datum(antagonist_type)
		if(objectives)
			if(!A)
				A = MM.add_antag_datum(/datum/antagonist/custom)
				//Don't delay roundend with ghost role created antags
				A.delay_roundend = FALSE
				A.prevent_roundtype_conversion = FALSE
			for(var/objective in objectives)
				var/datum/objective/O = new/datum/objective(objective)
				O.owner = MM
				A.objectives += O
				log_objective(O.owner, O.explanation_text)
		if(assignedrole)
			M.mind.assigned_role = assignedrole
		special(M, name)
		MM.name = M.real_name
	if(uses > 0)
		uses--
	if(!permanent && !uses)
		qdel(src)

// Base version - place these on maps/templates.
/obj/effect/mob_spawn/human
	mob_type = /mob/living/carbon/human
	//Human specific stuff.
	var/mob_species = null		//Set to make them a mutant race such as lizard or skeleton. Uses the datum typepath instead of the ID.
	var/datum/outfit/outfit = /datum/outfit	//If this is a path, it will be instanced in Initialize()
	var/disable_pda = TRUE
	var/disable_sensors = TRUE
	//All of these only affect the ID that the outfit has placed in the ID slot
	var/id_job = null			//Such as JOB_NAME_CLOWN or "Chef." This just determines what the ID reads as, not their access
	var/id_access = null		//This is for access. See access.dm for which jobs give what access. Use JOB_NAME_CAPTAIN if you want it to be all access.
	var/id_access_list = null	//Allows you to manually add access to an ID card.
	assignedrole = "Ghost Role"

	var/husk = null
	//these vars are for lazy mappers to override parts of the outfit
	//these cannot be null by default, or mappers cannot set them to null if they want nothing in that slot
	var/uniform = -1
	var/r_hand = -1
	var/l_hand = -1
	var/suit = -1
	var/shoes = -1
	var/gloves = -1
	var/ears = -1
	var/glasses = -1
	var/mask = -1
	var/head = -1
	var/belt = -1
	var/r_pocket = -1
	var/l_pocket = -1
	var/back = -1
	var/id = -1
	var/neck = -1
	var/backpack_contents = -1
	var/suit_store = -1

	var/hair_style
	var/facial_hair_style
	var/skin_tone

/obj/effect/mob_spawn/human/Initialize(mapload)
	if(ispath(outfit))
		outfit = new outfit()
	if(!outfit)
		outfit = new /datum/outfit
	return ..()

/obj/effect/mob_spawn/human/equip(mob/living/carbon/human/H)
	if(mob_species)
		H.set_species(mob_species)
	if(husk)
		H.Drain()
	else //Because for some reason I can't track down, things are getting turned into husks even if husk = false. It's in some damage proc somewhere.
		H.cure_husk()
	H.underwear = "Nude"
	H.undershirt = "Nude"
	H.socks = "Nude"
	if(hair_style)
		H.hair_style = hair_style
	else
		H.hair_style = random_hair_style(H.gender)
	if(facial_hair_style)
		H.facial_hair_style = facial_hair_style
	else
		H.facial_hair_style = random_facial_hair_style(H.gender)
	if(skin_tone)
		H.skin_tone = skin_tone
	else
		H.skin_tone = random_skin_tone()
	H.update_hair()
	H.update_body()
	if(outfit)
		var/static/list/slots = list("uniform", "r_hand", "l_hand", "suit", "shoes", "gloves", "ears", "glasses", "mask", "head", "belt", "r_pocket", "l_pocket", "back", "id", "neck", "backpack_contents", "suit_store")
		for(var/slot in slots)
			var/T = vars[slot]
			if(!isnum_safe(T))
				outfit.vars[slot] = T
		H.equipOutfit(outfit)
		if(disable_pda)
			// We don't want corpse PDAs to show up in the messenger list.
			var/obj/item/modular_computer/tablet/pda/PDA = locate(/obj/item/modular_computer/tablet/pda) in H
			if(PDA)
				PDA.messenger_invisible = TRUE
		if(disable_sensors)
			// Using crew monitors to find corpses while creative makes finding certain ruins too easy.
			var/obj/item/clothing/under/C = H.w_uniform
			if(istype(C))
				C.update_sensors(NO_SENSORS)

	var/obj/item/card/id/W = H.wear_id
	if(W)
		if(id_access)
			for(var/jobtype in typesof(/datum/job))
				var/datum/job/J = new jobtype
				if(J.title == id_access)
					W.access = J.get_access()
					break
		if(id_access_list)
			if(!islist(W.access))
				W.access = list()
			W.access |= id_access_list
		if(id_job)
			W.assignment = id_job
		W.registered_name = H.real_name
		W.update_label()

//Instant version - use when spawning corpses during runtime
/obj/effect/mob_spawn/human/corpse
	roundstart = FALSE
	instant = TRUE

/obj/effect/mob_spawn/human/corpse/damaged
	brute_damage = 1000

/obj/effect/mob_spawn/human/alive
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	death = FALSE
	roundstart = FALSE //you could use these for alive fake humans on roundstart but this is more common scenario

/obj/effect/mob_spawn/human/corpse/delayed
	ghost_usable = FALSE //These are just not-yet-set corpses.
	instant = FALSE

//Non-human spawners

/obj/effect/mob_spawn/AICorpse/create(ckey) //Creates a corrupted AI
	var/A = locate(/mob/living/silicon/ai) in loc
	if(A)
		return
	var/mob/living/silicon/ai/spawned/M = new(loc) //spawn new AI at landmark as var M
	M.name = src.name
	M.real_name = src.name
	M.modularInterface.messenger_invisible = TRUE //turns the AI's PDA messenger off, stopping it showing up on player PDAs
	M.death() //call the AI's death proc
	qdel(src)

/obj/effect/mob_spawn/slime
	mob_type = 	/mob/living/simple_animal/slime
	var/mobcolour = "grey"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime" //sets the icon in the map editor

/obj/effect/mob_spawn/slime/equip(mob/living/simple_animal/slime/S)
	S.colour = mobcolour

/obj/effect/mob_spawn/facehugger/create(ckey) //Creates a squashed facehugger
	var/obj/item/clothing/mask/facehugger/O = new(src.loc) //variable O is a new facehugger at the location of the landmark
	O.name = src.name
	O.Die() //call the facehugger's death proc
	qdel(src)

/obj/effect/mob_spawn/mouse
	name = "sleeper"
	mob_type = 	/mob/living/simple_animal/mouse
	death = FALSE
	roundstart = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/cow
	name = "sleeper"
	mob_type = 	/mob/living/simple_animal/cow
	death = FALSE
	roundstart = FALSE
	mob_gender = FEMALE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

// I'll work on making a list of corpses people request for maps, or that I think will be commonly used. Syndicate operatives for example.

///////////Civilians//////////////////////

/obj/effect/mob_spawn/human/corpse/assistant
	name = JOB_NAME_ASSISTANT
	outfit = /datum/outfit/job/assistant

/obj/effect/mob_spawn/human/corpse/assistant/beesease_infection
	disease = /datum/disease/beesease

/obj/effect/mob_spawn/human/corpse/assistant/brainrot_infection
	disease = /datum/disease/brainrot

/obj/effect/mob_spawn/human/corpse/assistant/spanishflu_infection
	disease = /datum/disease/fluspanish

/obj/effect/mob_spawn/human/corpse/cargo_tech
	name = "Cargo Tech"
	outfit = /datum/outfit/job/cargo_technician

/obj/effect/mob_spawn/human/cook
	name = JOB_NAME_COOK
	outfit = /datum/outfit/job/cook


/obj/effect/mob_spawn/human/doctor
	name = "Doctor"
	outfit = /datum/outfit/job/medical_doctor


/obj/effect/mob_spawn/human/doctor/alive
	death = FALSE
	roundstart = FALSE
	random = TRUE
	name = "sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	short_desc = "You are a space doctor!"
	assignedrole = "Space Doctor"
	use_cooldown = TRUE // Use cooldown

/obj/effect/mob_spawn/human/doctor/alive/equip(mob/living/carbon/human/H)
	..()
	// Remove radio and PDA so they wouldn't annoy station crew.
	var/list/del_types = list(/obj/item/modular_computer/tablet/pda, /obj/item/radio/headset)
	for(var/del_type in del_types)
		var/obj/item/I = locate(del_type) in H
		qdel(I)

/obj/effect/mob_spawn/human/engineer
	name = "Engineer"
	outfit = /datum/outfit/job/engineer/gloved

/obj/effect/mob_spawn/human/engineer/rig
	outfit = /datum/outfit/job/engineer/gloved/rig

/obj/effect/mob_spawn/human/clown
	name = JOB_NAME_CLOWN
	outfit = /datum/outfit/job/clown

/obj/effect/mob_spawn/human/scientist
	name = JOB_NAME_SCIENTIST
	outfit = /datum/outfit/job/scientist

/obj/effect/mob_spawn/human/miner
	name = JOB_NAME_SHAFTMINER
	outfit = /datum/outfit/job/miner

/obj/effect/mob_spawn/human/miner/rig
	outfit = /datum/outfit/job/miner/equipped/hardsuit

/obj/effect/mob_spawn/human/miner/explorer
	outfit = /datum/outfit/job/miner/equipped


/obj/effect/mob_spawn/human/plasmaman
	mob_species = /datum/species/plasmaman
	outfit = /datum/outfit/plasmaman


/obj/effect/mob_spawn/human/bartender
	name = "Space Bartender"
	id_job = JOB_NAME_BARTENDER
	id_access_list = list(ACCESS_BAR)
	outfit = /datum/outfit/spacebartender

/obj/effect/mob_spawn/human/bartender/alive
	death = FALSE
	roundstart = FALSE
	random = TRUE
	name = "bartender sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	short_desc = "You are a space bartender!"
	flavour_text = "Time to mix drinks and change lives. Smoking space drugs makes it easier to understand your patrons' odd dialect."
	assignedrole = "Space Bartender"
	id_job = JOB_NAME_BARTENDER
	use_cooldown = TRUE

/datum/outfit/spacebartender
	name = "Space Bartender"
	uniform = /obj/item/clothing/under/rank/civilian/bartender
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/armor/vest
	glasses = /obj/item/clothing/glasses/sunglasses/advanced/reagent
	id = /obj/item/card/id

/datum/outfit/spacebartender/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	ADD_TRAIT(H, TRAIT_SOMMELIER, ROUNDSTART_TRAIT)

/obj/effect/mob_spawn/human/beach
	outfit = /datum/outfit/beachbum

/obj/effect/mob_spawn/human/beach/alive
	death = FALSE
	roundstart = FALSE
	random = TRUE
	mob_name = "Beach Bum"
	name = "beach bum sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	short_desc = "You're, like, totally a dudebro, bruh."
	flavour_text = "Ch'yea. You came here, like, on spring break, hopin' to pick up some bangin' hot chicks, y'knaw?"
	assignedrole = "Beach Bum"
	use_cooldown = TRUE

/obj/effect/mob_spawn/human/beach/alive/lifeguard
	short_desc = "You're a spunky lifeguard!"
	flavour_text = "It's up to you to make sure nobody drowns or gets eaten by sharks and stuff."
	mob_gender = "female"
	name = "lifeguard sleeper"
	id_job = "Lifeguard"
	uniform = /obj/item/clothing/under/shorts/red

/datum/outfit/beachbum
	name = "Beach Bum"
	glasses = /obj/item/clothing/glasses/sunglasses
	r_pocket = /obj/item/storage/wallet/random
	l_pocket = /obj/item/reagent_containers/food/snacks/pizzaslice/dank;
	uniform = /obj/item/clothing/under/pants/youngfolksjeans
	id = /obj/item/card/id

/datum/outfit/beachbum/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	H.dna.add_mutation(STONER)

/////////////////Officers+Nanotrasen Security//////////////////////

/obj/effect/mob_spawn/human/bridgeofficer
	name = "Bridge Officer"
	id_job = "Bridge Officer"
	id_access_list = list(ACCESS_CENT_CAPTAIN)
	outfit = /datum/outfit/nanotrasenbridgeofficercorpse

/datum/outfit/nanotrasenbridgeofficercorpse
	name = "Bridge Officer Corpse"
	ears = /obj/item/radio/headset/heads/head_of_personnel
	uniform = /obj/item/clothing/under/rank/centcom/officer
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/sneakers/black
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	id = /obj/item/card/id/gold


/obj/effect/mob_spawn/human/commander
	name = "Commander"
	id_job = "Commander"
	id_access_list = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_STORAGE)
	outfit = /datum/outfit/nanotrasencommandercorpse

/datum/outfit/nanotrasencommandercorpse
	name = "\improper Nanotrasen Private Security Commander"
	uniform = /obj/item/clothing/under/rank/centcom/commander
	suit = /obj/item/clothing/suit/armor/bulletproof
	ears = /obj/item/radio/headset/heads/captain
	glasses = /obj/item/clothing/glasses/eyepatch
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	head = /obj/item/clothing/head/centhat
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat/swat
	r_pocket = /obj/item/lighter
	id = /obj/item/card/id/job/head_of_security


/obj/effect/mob_spawn/human/nanotrasensoldier
	name = "\improper Nanotrasen Private Security Officer"
	id_job = "Private Security Force"
	id_access_list = list(ACCESS_CENT_CAPTAIN, ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_STORAGE, ACCESS_SECURITY, ACCESS_MECH_SECURITY)
	outfit = /datum/outfit/nanotrasensoldiercorpse

/datum/outfit/nanotrasensoldiercorpse
	name = "NT Private Security Officer Corpse"
	uniform = /obj/item/clothing/under/rank/security/officer
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	head = /obj/item/clothing/head/helmet/swat/nanotrasen
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/job/security_officer


/obj/effect/mob_spawn/human/commander/alive
	death = FALSE
	roundstart = FALSE
	mob_name = "\improper Nanotrasen Commander"
	name = "sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	short_desc = "You are a Nanotrasen Commander!"
	use_cooldown = TRUE

/obj/effect/mob_spawn/human/nanotrasensoldier/alive
	death = FALSE
	roundstart = FALSE
	mob_name = "Private Security Officer"
	name = "sleeper"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	faction = "nanotrasenprivate"
	short_desc = "You are a Nanotrasen Private Security Officer!"
	use_cooldown = TRUE


/////////////////Spooky Undead//////////////////////

/obj/effect/mob_spawn/human/skeleton
	name = "skeletal remains"
	mob_name = "skeleton"
	mob_species = /datum/species/skeleton
	mob_gender = NEUTER

/obj/effect/mob_spawn/human/skeleton/alive
	death = FALSE
	roundstart = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	short_desc = "By unknown powers, your skeletal remains have been reanimated!"
	flavour_text = "Walk this mortal plain and terrorize all living adventurers who dare cross your path."
	assignedrole = "Skeleton"
	use_cooldown = TRUE

/obj/effect/mob_spawn/human/skeleton/alive/equip(mob/living/carbon/human/H)
	var/obj/item/implant/exile/implant = new/obj/item/implant/exile(H)
	implant.implant(H)
	H.set_species(/datum/species/skeleton)

/obj/effect/mob_spawn/human/zombie
	name = "rotting corpse"
	mob_name = "zombie"
	mob_species = /datum/species/zombie
	assignedrole = "Zombie"

/obj/effect/mob_spawn/human/zombie/alive
	death = FALSE
	roundstart = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	short_desc = "By unknown powers, your rotting remains have been resurrected!"
	flavour_text = "Walk this mortal plain and terrorize all living adventurers who dare cross your path."
	use_cooldown = TRUE

/obj/effect/mob_spawn/human/abductor
	name = "abductor"
	mob_name = "alien"
	mob_species = /datum/species/abductor
	outfit = /datum/outfit/abductorcorpse

/datum/outfit/abductorcorpse
	name = "Abductor Corpse"
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/combat


//For ghost bar.
/obj/effect/mob_spawn/human/alive/space_bar_patron
	name = "Bar cryogenics"
	mob_name = "Bar patron"
	random = TRUE
	permanent = TRUE
	uses = -1
	outfit = /datum/outfit/spacebartender
	assignedrole = "Space Bar Patron"

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/effect/mob_spawn/human/alive/space_bar_patron/attack_hand(mob/user)
	var/despawn = alert("Return to cryosleep? (Warning, Your mob will be deleted!)",,"Yes","No")
	if(despawn != "Yes" || !loc || !Adjacent(user))
		return
	user.visible_message("<span class='notice'>[user.name] climbs back into cryosleep...</span>")
	qdel(user)

/datum/outfit/cryobartender
	name = "Cryogenic Bartender"
	uniform = /obj/item/clothing/under/rank/civilian/bartender
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/armor/vest
	glasses = /obj/item/clothing/glasses/sunglasses/advanced/reagent

/obj/effect/mob_spawn/human/corpse/syndicatesoldier
	name = "Syndicate Operative"
	id_job = "Operative"
	hair_style = "Bald"
	facial_hair_style = "Shaved"
	outfit = /datum/outfit/syndicatesoldiercorpse

/datum/outfit/syndicatesoldiercorpse
	name = "Syndicate Operative Corpse"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/old
	head = /obj/item/clothing/head/helmet/swat
	back = /obj/item/storage/backpack
	id = /obj/item/card/id/syndicate

/obj/effect/mob_spawn/human/corpse/syndicatecommando
	name = "Syndicate Commando"
	id_job = "Operative"
	hair_style = "Bald"
	facial_hair_style = "Shaved"
	outfit = /datum/outfit/syndicatecommandocorpse

/datum/outfit/syndicatecommandocorpse
	name = "Syndicate Commando Corpse"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/syndicate
	back = /obj/item/tank/jetpack/oxygen
	r_pocket = /obj/item/tank/internals/emergency_oxygen
	id = /obj/item/card/id/syndicate


/obj/effect/mob_spawn/human/corpse/syndicatestormtrooper
	name = "Syndicate Stormtrooper"
	id_job = "Operative"
	hair_style = "Bald"
	facial_hair_style = "Shaved"
	outfit = /datum/outfit/syndicatestormtroopercorpse

/datum/outfit/syndicatestormtroopercorpse
	name = "Syndicate Stormtrooper Corpse"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/elite
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/syndicate
	back = /obj/item/tank/jetpack/oxygen/harness
	id = /obj/item/card/id/syndicate


/obj/effect/mob_spawn/human/clown/corpse
	roundstart = FALSE
	instant = TRUE
	skin_tone = "caucasian1"
	hair_style = "Bald"
	facial_hair_style = "Shaved"

/obj/effect/mob_spawn/human/corpse/pirate
	name = "Pirate"
	skin_tone = "caucasian1" //all pirates are white because it's easier that way
	outfit = /datum/outfit/piratecorpse
	hair_style = "Bald"
	facial_hair_style = "Shaved"

/datum/outfit/piratecorpse
	name = "Pirate Corpse"
	uniform = /obj/item/clothing/under/costume/pirate
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/bandana


/obj/effect/mob_spawn/human/corpse/pirate/ranged
	name = "Pirate Gunner"
	outfit = /datum/outfit/piratecorpse/ranged

/datum/outfit/piratecorpse/ranged
	name = "Pirate Gunner Corpse"
	suit = /obj/item/clothing/suit/pirate
	head = /obj/item/clothing/head/pirate


/obj/effect/mob_spawn/human/corpse/russian
	name = "Russian"
	outfit = /datum/outfit/russiancorpse
	hair_style = "Bald"
	facial_hair_style = "Shaved"

/datum/outfit/russiancorpse
	name = "Russian Corpse"
	uniform = /obj/item/clothing/under/costume/soviet
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/bearpelt
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/gas/old



/obj/effect/mob_spawn/human/corpse/russian/ranged
	outfit = /datum/outfit/russiancorpse/ranged

/datum/outfit/russiancorpse/ranged
	name = "Ranged Russian Corpse"
	head = /obj/item/clothing/head/ushanka


/obj/effect/mob_spawn/human/corpse/russian/ranged/trooper
	outfit = /datum/outfit/russiancorpse/ranged/trooper

/datum/outfit/russiancorpse/ranged/trooper
	name = "Ranged Russian Trooper Corpse"
	uniform = /obj/item/clothing/under/syndicate/camo
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	head = /obj/item/clothing/head/helmet/alt
	mask = /obj/item/clothing/mask/balaclava


/obj/effect/mob_spawn/human/corpse/russian/ranged/officer
	name = "Russian Officer"
	outfit = /datum/outfit/russiancorpse/officer

/datum/outfit/russiancorpse/officer
	name = "Russian Officer Corpse"
	uniform = /obj/item/clothing/under/costume/russian_officer
	suit = /obj/item/clothing/suit/security/officer/russian
	shoes = /obj/item/clothing/shoes/combat
	ears = /obj/item/radio/headset
	head = /obj/item/clothing/head/ushanka


/obj/effect/mob_spawn/human/corpse/wizard
	name = "Space Wizard Corpse"
	outfit = /datum/outfit/wizardcorpse
	hair_style = "Bald"
	facial_hair_style = "Long Beard"
	skin_tone = "caucasian1"

/datum/outfit/wizardcorpse
	name = "Space Wizard Corpse"
	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/wizrobe
	shoes = /obj/item/clothing/shoes/sandal/magic
	head = /obj/item/clothing/head/wizard


/obj/effect/mob_spawn/human/corpse/nanotrasensoldier
	name = "\improper Nanotrasen Private Security Officer"
	id_job = "Private Security Force"
	id_access = JOB_NAME_SECURITYOFFICER
	outfit = /datum/outfit/nanotrasensoldiercorpse2
	hair_style = "Bald"
	facial_hair_style = "Shaved"

/datum/outfit/nanotrasensoldiercorpse2
	name = "NT Private Security Officer Corpse"
	uniform = /obj/item/clothing/under/rank/security/officer
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	head = /obj/item/clothing/head/helmet/swat/nanotrasen
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/job/security_officer

/obj/effect/mob_spawn/human/corpse/cat_butcher
	name = "The Cat Surgeon"
	id_job = "Cat Surgeon"
	hair_style = "Cut Hair"
	facial_hair_style = "Watson Mustache"
	skin_tone = "caucasian1"
	outfit = /datum/outfit/cat_butcher

/datum/outfit/cat_butcher
	name = "Cat Butcher Uniform"
	uniform = /obj/item/clothing/under/rank/medical/doctor/green
	suit = /obj/item/clothing/suit/apron/surgical
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	ears = /obj/item/radio/headset
	back = /obj/item/storage/backpack/satchel/med
	id = /obj/item/card/id
	glasses = /obj/item/clothing/glasses/hud/health

/obj/effect/mob_spawn/human/corpse/bee_terrorist
	name = "BLF Operative"
	outfit = /datum/outfit/bee_terrorist

/datum/outfit/bee_terrorist
	name = "BLF Operative"
	uniform = /obj/item/clothing/under/color/yellow
	suit = /obj/item/clothing/suit/hooded/bee_costume
	shoes = /obj/item/clothing/shoes/sneakers/yellow
	gloves = /obj/item/clothing/gloves/color/yellow
	ears = /obj/item/radio/headset
	belt = /obj/item/storage/belt/fannypack/yellow/bee_terrorist
	id = /obj/item/card/id
	l_pocket = /obj/item/paper/fluff/bee_objectives
	mask = /obj/item/clothing/mask/rat/bee

/obj/effect/mob_spawn/human/corpse/sniper
	name = "Sniper"
	outfit = /datum/outfit/sniper
	skin_tone = "caucasian1"
	hair_style = "Bald"
	facial_hair_style = "Full beard"
	id_job = JOB_NAME_WARDEN
	mob_gender = MALE

/datum/outfit/sniper
	name = "Sniper"
	uniform = /obj/item/clothing/under/syndicate/camo
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	belt = /obj/item/storage/belt/military/assault
	mask = /obj/item/clothing/mask/cigarette/cigar
	head = /obj/item/clothing/head/beret/corpwarden
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch
	back = /obj/item/storage/backpack/satchel/sec
	id = /obj/item/card/id/job/warden

/obj/effect/mob_spawn/human/corpse/psychost
	name = "Psycho"
	hair_style = "Bald"
	facial_hair_style = "Shaved"
	skin_tone = "caucasian1"
	brute_damage = 100
	outfit = /datum/outfit/straightjacket

/datum/outfit/straightjacket
	name = "Straight jacket"
	suit = /obj/item/clothing/suit/straight_jacket

/obj/effect/mob_spawn/human/corpse/psychost/muzzle
	name = "Muzzled psycho"
	outfit = /datum/outfit/straightmuz

/datum/outfit/straightmuz
	name = "Straight jacket and a muzzle"
	suit = /obj/item/clothing/suit/straight_jacket
	mask = /obj/item/clothing/mask/muzzle

/obj/effect/mob_spawn/human/corpse/psychost/trap
	name = "Trapped psycho"
	outfit = /datum/outfit/straighttrap

/datum/outfit/straighttrap
	name = "Straight jacket and a reverse bear trap"
	suit = /obj/item/clothing/suit/straight_jacket
	head = /obj/item/reverse_bear_trap

/obj/effect/mob_spawn/human/corpse/zombie
	name = "zombie"
	mob_species = /datum/species/zombie
	brute_damage = 100

/obj/effect/mob_spawn/human/corpse/suicidezombie
	mob_species = /datum/species/zombie
	brute_damage = 100
	outfit = /datum/outfit/suicidezombie

/datum/outfit/suicidezombie
	name = "Guy with a grenade"
	mask = /obj/item/clothing/mask/gas/cyborg
	uniform = /obj/item/clothing/under/pants/camo
	belt = /obj/item/storage/belt/bandolier
	shoes = /obj/item/clothing/shoes/combat
