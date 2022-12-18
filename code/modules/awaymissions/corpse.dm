/// Usage: AddComponent(/datum/component/mob_spawner, list(mob_type = /mob/..., mob_name = "..."))
/datum/component/mob_spawner
	var/name = ""
	/// Typepath of the mob to be spawned
	var/mob_type = null
	/// Name of the mob to be spawned
	var/mob_name = ""
	/// Gender of the mob to be spawned
	var/mob_gender = null
	/// If the mob should be dead
	var/death = TRUE
	/// If the spawner should trigger when Initialize() is called
	var/roundstart = TRUE
	/// If the spawner should trigger when New() is called
	var/instant = FALSE
	/// A short description shown to whoever takes this mob spawn, in large text. See flavour_text for longer text.
	var/short_desc = "The mapper forgot to set this!"
	/// A longer portion of text shown to whoever takes the spawn, similar to short_desc
	var/flavour_text = ""
	/// A large red text shown to the whoever takes the spawn.
	var/important_info = ""
	/// The faction to set on the spaned mob
	var/faction = null
	/// If the parent object should be deleted after running out of uses
	var/permanent = FALSE
	/// If it should randomly generate a name, gender, etc.
	var/random = FALSE
	/// The typepath of any antag datum to add to the mob
	var/antagonist_type
	/// A list of objective datums to add to the mob.
	var/objectives = null
	/// How many times a mob can spawned from this. -1 is infinite.
	var/uses = 1
	/// Starting brute damage of the mob.
	var/brute_damage = 0
	/// Starting oxygen damage of the mob.
	var/oxy_damage = 0
	/// Starting burn damage of the mob.
	var/burn_damage = 0
	/// Any disease datum that should be spawned with the mob.
	var/datum/disease/disease = null
	/// The color value applied to the mob on spawn.
	var/mob_color
	/// What the mind.assigned_role will be on spawn.
	var/assignedrole
	/// If we should show the short_desc/flavortext
	var/show_flavour = TRUE
	/// The role used for determining if the player is banned from taking this spawn.
	var/ban_type = ROLE_LAVALAND
	/// If ghosts can click on this object to take a spawn.
	var/ghost_usable = TRUE
	/// If this should use the player's ghost role cooldown.
	var/use_cooldown = FALSE
	/// If you can click on this to delete your mob and re-enter "cryo"
	var/can_re_enter = FALSE
	/// Amount of living playtime in hours required to take this spawn
	var/byond_account_age_required = null

	/// Typepath for the species, if the mob is human
	var/mob_species = null
	/// Instance of typepath of /datum/outfit, if the mob is human. If this is a path, it will be instanced in Initialize()
	var/datum/outfit/outfit = /datum/outfit
	/// If their PDA should be hidden from the list of PDAs, if the mob's outfit has one.
	var/disable_pda = TRUE
	/// If their suit sensors should be off by default, if the mob has one.
	var/disable_sensors = TRUE
	/// Use JOB_NAME defines or put a custom job name. Only affects the ID that the outfit has placed in the ID slot.
	var/id_job = null
	/// Access on their ID, using JOB_NAME defines. Only affects the ID that the outfit has placed in the ID slot.
	var/id_access = null
	/// Manual access list on their ID, as opposed to JOB_NAME based. Only affects the ID that the outfit has placed in the ID slot.
	var/id_access_list = null
	/// If the mob should start husked.
	var/husk = FALSE
	/// Implant typepath to implant in the mob
	var/implant_type

	/// Hair to set on the mob, if human.
	var/hair_style
	/// Facial hair to set on the mob, if human.
	var/facial_hair_style
	/// Skin tone to set on the mob, if human.
	var/skin_tone
	/// If we should delete any radio or PDA in the mob's contents on spawn, if they are human.
	var/delete_pda_and_radio = FALSE

	//These vars are for lazy mappers to override parts of the outfit
	//These cannot be null by default, or mappers cannot set them to null if they want nothing in that slot
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

/// Pass all the variables wanted above in as arguments to the component rather than creating subtypes
/datum/component/mob_spawner/Initialize(list/arguments)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/A = parent
	// This is used for the spawner menu's "Groups". Actually terrible but I'm leaving it for now
	name = A.name
	// Replace vars
	for(var/index in arguments)
		if(index in vars)
			vars[index] = arguments[index]
	if(ispath(mob_type, /mob/living/carbon/human))
		if(ispath(outfit))
			outfit = new outfit()
		if(!outfit)
			outfit = new /datum/outfit
	// SSatoms.initialized == INITIALIZATION_INNEW_MAPLOAD is equivalent to the "mapload" arg on Intialize()
	if(instant || (roundstart && ((SSatoms.initialized == INITIALIZATION_INNEW_MAPLOAD) || (SSticker && SSticker.current_state > GAME_STATE_SETTING_UP))))
		create()
	else if(ghost_usable)
		GLOB.poi_list |= parent
		LAZYADD(GLOB.mob_spawners[name], src)
		SSmobs.update_spawners()
		RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, .proc/attack_ghost)
	if(can_re_enter)
		RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/attack_hand)
	RegisterSignal(parent, COMSIG_MOB_SPAWNER_CREATE, .proc/create_signalled)

/datum/component/mob_spawner/proc/attack_hand(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!isliving(user))
		return
	var/despawn = alert(user, "Return to cryosleep? (Warning, Your mob will be deleted!)", "", "Yes", "No")
	var/atom/A = parent
	if(despawn != "Yes" || !A.loc || !A.Adjacent(user))
		return
	user.visible_message("<span class='notice'>[user.name] climbs back into cryosleep...</span>")
	qdel(user)

/datum/component/mob_spawner/proc/attack_ghost(datum/source, mob/user)
	SIGNAL_HANDLER
	var/atom/A = parent
	if(!SSticker.HasRoundStarted() || !A.loc || !ghost_usable)
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER) && !(A.flags_1 & ADMIN_SPAWNED_1))
		to_chat(user, "<span class='warning'>An admin has temporarily disabled non-admin ghost roles!</span>")
		return
	if(!uses)
		to_chat(user, "<span class='warning'>This spawner is out of charges!</span>")
		return
	if(is_banned_from(user.key, ban_type))
		to_chat(user, "<span class='warning'>You are jobanned!</span>")
		return
	if(byond_account_age_required && CONFIG_GET(flag/use_age_restriction_for_jobs))
		//apparently what happens when there's no DB connected. just don't let anybody be a drone without admin intervention
		if(!isnum_safe(user.client.player_age))
			return
		if(user.client.player_age < byond_account_age_required)
			to_chat(user, "<span class='danger'>You're too new to play as a drone! Please try again in [byond_account_age_required - user.client.player_age] days.</span>")
			return
	if(QDELETED(src) || QDELETED(parent) || QDELETED(user))
		return
	if(use_cooldown && user.client.next_ghost_role_tick > world.time)
		to_chat(user, "<span class='warning'>You have died recently, you must wait [(user.client.next_ghost_role_tick - world.time)/10] seconds until you can use a ghost spawner.</span>")
		return
	var/ghost_role = alert("Become [mob_name]? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(ghost_role == "No" || !A.loc)
		return
	log_game("[key_name(user)] became [mob_name]")
	create(ckey = user.ckey)

/datum/component/mob_spawner/Destroy()
	UnregisterSignal(parent, COMSIG_MOB_SPAWNER_CREATE)
	if(ghost_usable)
		UnregisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST)
		GLOB.poi_list -= parent
		var/list/spawners = GLOB.mob_spawners[name]
		LAZYREMOVE(spawners, src)
		if(!LAZYLEN(spawners))
			GLOB.mob_spawners -= name
		SSmobs.update_spawners()
	if(can_re_enter)
		UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)
	return ..()

/datum/component/mob_spawner/proc/special(mob/M, name)
	SEND_SIGNAL(parent, COMSIG_MOB_SPAWNER_DOSPECIAL, M, name)

/datum/component/mob_spawner/proc/equip(mob/M)
	if(implant_type)
		if(!ispath(implant_type, /obj/item/implant))
			CRASH("Implant type \"[implant_type]\" on [src] of [parent] is invalid. It must be a subtype of /obj/item/implant!")
		var/obj/item/implant/implant = new implant_type(M)
		implant.implant(M)
	if(!iscarbon(M))
		return
	var/mob/living/carbon/C = M
	if(husk)
		C.Drain()
	else //Because for some reason I can't track down, things are getting turned into husks even if husk = false. It's in some damage proc somewhere.
		C.cure_husk()
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	if(mob_species)
		H.set_species(mob_species)
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
			var/obj/item/clothing/under/cloth = H.w_uniform
			if(istype(cloth))
				cloth.update_sensors(NO_SENSORS)

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
	if(delete_pda_and_radio)
		// Remove radio and PDA so they wouldn't annoy station crew.
		var/list/del_types = list(/obj/item/modular_computer/tablet/pda, /obj/item/radio/headset)
		for(var/del_type in del_types)
			var/obj/item/I = locate(del_type) in H
			qdel(I)
	return

/datum/component/mob_spawner/proc/create_signalled(datum/source, ckey, name)
	SIGNAL_HANDLER
	create(ckey, name)

/datum/component/mob_spawner/proc/create(ckey, name)
	var/mob/living/M = new mob_type(get_turf(parent)) //living mobs only
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
	var/atom/parent_atom = parent
	// Copy admin spawned from parent
	M.flags_1 |= (parent_atom.flags_1 & ADMIN_SPAWNED_1)
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
		qdel(parent)

/datum/component/mob_spawner/human
	mob_type = /mob/living/carbon/human
	assignedrole = "Ghost Role"

/// Shitty mapping placeholder. Use the component instead if you actually want to do something that isn't for mappers.
/obj/effect/mob_spawn
	// Copypasta from component, it all gets passed into the component anyway

	/// Typepath of the mob to be spawned
	var/mob_type = null
	/// Name of the mob to be spawned
	var/mob_name = ""
	/// Gender of the mob to be spawned
	var/mob_gender = null
	/// If the mob should be dead
	var/death = TRUE
	/// If the spawner should trigger when Initialize() is called
	var/roundstart = TRUE
	/// If the spawner should trigger when New() is called
	var/instant = FALSE
	/// A short description shown to whoever takes this mob spawn, in large text. See flavour_text for longer text.
	var/short_desc = "The mapper forgot to set this!"
	/// A longer portion of text shown to whoever takes the spawn, similar to short_desc
	var/flavour_text = ""
	/// A large red text shown to the whoever takes the spawn.
	var/important_info = ""
	/// The faction to set on the spaned mob
	var/faction = null
	/// If the parent object should be deleted after running out of uses
	var/permanent = FALSE
	/// If it should randomly generate a name, gender, etc.
	var/random = FALSE
	/// The typepath of any antag datum to add to the mob
	var/antagonist_type
	/// A list of objective datums to add to the mob.
	var/objectives = null
	/// How many times a mob can spawned from this. -1 is infinite.
	var/uses = 1
	/// Starting brute damage of the mob.
	var/brute_damage = 0
	/// Starting oxygen damage of the mob.
	var/oxy_damage = 0
	/// Starting burn damage of the mob.
	var/burn_damage = 0
	/// Any disease datum that should be spawned with the mob.
	var/datum/disease/disease = null
	/// The color value applied to the mob on spawn.
	var/mob_color
	/// What the mind.assigned_role will be on spawn.
	var/assignedrole
	/// If we should show the short_desc/flavortext
	var/show_flavour = TRUE
	/// The role used for determining if the player is banned from taking this spawn.
	var/ban_type = ROLE_LAVALAND
	/// If ghosts can click on this object to take a spawn.
	var/ghost_usable = TRUE
	/// If this should use the player's ghost role cooldown.
	var/use_cooldown = FALSE
	/// If you can click on this to delete your mob and re-enter "cryo"
	var/can_re_enter = FALSE
	/// Amount of living playtime in hours required to take this spawn
	var/byond_account_age_required = null

	/// Typepath for the species, if the mob is human
	var/mob_species = null
	/// Instance of typepath of /datum/outfit, if the mob is human. If this is a path, it will be instanced in Initialize()
	var/datum/outfit/outfit = /datum/outfit
	/// If their PDA should be hidden from the list of PDAs, if the mob's outfit has one.
	var/disable_pda = TRUE
	/// If their suit sensors should be off by default, if the mob has one.
	var/disable_sensors = TRUE
	/// Use JOB_NAME defines or put a custom job name. Only affects the ID that the outfit has placed in the ID slot.
	var/id_job = null
	/// Access on their ID, using JOB_NAME defines. Only affects the ID that the outfit has placed in the ID slot.
	var/id_access = null
	/// Manual access list on their ID, as opposed to JOB_NAME based. Only affects the ID that the outfit has placed in the ID slot.
	var/id_access_list = null
	/// If the mob should start husked.
	var/husk = FALSE
	/// Implant typepath to implant in the mob
	var/implant_type

	/// Hair to set on the mob, if human.
	var/hair_style
	/// Facial hair to set on the mob, if human.
	var/facial_hair_style
	/// Skin tone to set on the mob, if human.
	var/skin_tone
	/// If we should delete any radio or PDA in the mob's contents on spawn, if they are human.
	var/delete_pda_and_radio = FALSE

	//These vars are for lazy mappers to override parts of the outfit
	//These cannot be null by default, or mappers cannot set them to null if they want nothing in that slot
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

/// Allow subtypes to configure args before adding component
/obj/effect/mob_spawn/proc/pre_configure()
	return

/obj/effect/mob_spawn/ComponentInitialize()
	pre_configure()
	// So cursed
	AddComponent(/datum/component/mob_spawner, list(
	mob_type = mob_type,
	mob_name = mob_name,
	mob_gender = mob_gender,
	death = death,
	roundstart = roundstart,
	instant = instant,
	short_desc = short_desc,
	flavour_text = flavour_text,
	important_info = important_info,
	faction = faction,
	permanent = permanent,
	random = random,
	antagonist_type = antagonist_type,
	objectives = objectives,
	uses = uses,
	brute_damage = brute_damage,
	oxy_damage = oxy_damage,
	burn_damage = burn_damage,
	disease = disease,
	mob_color = mob_color,
	assignedrole = assignedrole,
	show_flavour = show_flavour,
	ban_type = ban_type,
	ghost_usable = ghost_usable,
	use_cooldown = use_cooldown,
	can_re_enter = can_re_enter,
	byond_account_age_required = byond_account_age_required,
	mob_species = mob_species,
	outfit = outfit,
	disable_pda = disable_pda,
	disable_sensors = disable_sensors,
	id_job = id_job,
	id_access = id_access,
	id_access_list = id_access_list,
	husk = husk,
	implant_type = implant_type,
	hair_style = hair_style,
	facial_hair_style = facial_hair_style,
	skin_tone = skin_tone,
	delete_pda_and_radio = delete_pda_and_radio,
	uniform = uniform,
	r_hand = r_hand,
	l_hand = l_hand,
	suit = suit,
	shoes = shoes,
	gloves = gloves,
	ears = ears,
	glasses = glasses,
	mask = mask,
	head = head,
	belt = belt,
	r_pocket = r_pocket,
	l_pocket = l_pocket,
	back = back,
	id = id,
	neck = neck,
	backpack_contents = backpack_contents,
	suit_store = suit_store,
	))

/// Shorthand for sending COMSIG_MOB_SPAWNER_CREATE to the inner component
/obj/effect/mob_spawn/proc/create(ckey, name)
	SEND_SIGNAL(src, COMSIG_MOB_SPAWNER_CREATE, ckey, name)

/obj/effect/mob_spawn/human
	mob_type = /mob/living/carbon/human
	assignedrole = "Ghost Role"

//Instant version - use when spawning corpses during runtime
/obj/effect/mob_spawn/human/corpse
	roundstart = FALSE
	instant = TRUE

/obj/effect/mob_spawn/human/corpse/damaged
	brute_damage = 1000

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
	delete_pda_and_radio = TRUE

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
	mob_species = /datum/species/skeleton
	use_cooldown = TRUE
	implant_type = /obj/item/implant/exile

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
