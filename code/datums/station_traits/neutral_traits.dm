/datum/station_trait/bananium_shipment
	name = "Bananium Shipment"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	cost = STATION_TRAIT_COST_LOW
	report_message = "Rumors has it that the clown planet has been sending support packages to clowns in this system"
	trait_to_give = STATION_TRAIT_BANANIUM_SHIPMENTS

/datum/station_trait/ian_adventure
	name = "Ian's Adventure"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	cost = STATION_TRAIT_COST_LOW
	show_in_report = FALSE
	report_message = "Ian has gone exploring somewhere in the station."

/datum/station_trait/ian_adventure/on_round_start()
	for(var/mob/living/basic/pet/dog/corgi/dog in GLOB.mob_list)
		if(!(istype(dog, /mob/living/basic/pet/dog/corgi/ian) || istype(dog, /mob/living/basic/pet/dog/corgi/puppy/ian)))
			continue

		// The extended safety checks at time of writing are about chasms and lava
		// if there are any chasms and lava on stations in the future, woah
		var/turf/current_turf = get_turf(dog)
		var/turf/adventure_turf = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)

		// Poof!
		do_smoke(location=current_turf)
		dog.forceMove(adventure_turf)
		do_smoke(location=adventure_turf)


/datum/station_trait/glitched_pdas
	name = "PDA glitch"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 8
	cost = STATION_TRAIT_COST_MINIMAL
	show_in_report = TRUE
	report_message = "Something seems to be wrong with the PDAs issued to you all this shift. Nothing too bad though."
	trait_to_give = STATION_TRAIT_PDA_GLITCHED

/datum/station_trait/announcement_medbot
	name = "Announcement \"System\""
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "Our announcement system is under scheduled maintanance at the moment. Thankfully, we have a backup."
	blacklist = list(/datum/station_trait/announcement_intern, /datum/station_trait/announcement_baystation, /datum/station_trait/birthday)

/datum/station_trait/announcement_medbot/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/medbot

/datum/station_trait/announcement_baystation
	name = "Announcer: Archival Tape"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "We lost the primary datatape that holds the announcement system's voice responses. We did however find an older backup."
	blacklist = list(/datum/station_trait/announcement_intern, /datum/station_trait/announcement_medbot)

/datum/station_trait/announcement_baystation/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/baystation

/datum/station_trait/birthday
	name = "Employee Birthday"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	report_message = "We here at Nanotrasen would all like to wish Employee Name a very happy birthday"
	trait_to_give = STATION_TRAIT_BIRTHDAY
	blacklist = list(/datum/station_trait/announcement_intern, /datum/station_trait/announcement_medbot) //Overiding the annoucer hides the birthday person in the annoucement message.

	/// Variable that stores a reference to the person selected to have their birthday celebrated.
	var/mob/living/carbon/human/birthday_person
	///Variable that holds the real name of the birthday person once selected, just incase the birthday person's real_name changes.
	var/birthday_person_name = ""
	/// Variable that admins can override with a player's ckey in order to set them as the birthday person when the round starts.
	var/birthday_override_ckey
	/// All spawned party spots
	var/list/obj/effect/spawner/hangover_spawn/spawns = list()

/datum/station_trait/birthday/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))
	RegisterSignal(SSmapping, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(create_spawners))

/datum/station_trait/birthday/revert()
	for(var/obj/effect/spawner/hangover_spawn/party_spot in spawns)
		QDEL_LIST(party_spot.party_debris)
	return ..()

/datum/station_trait/birthday/on_round_start()
	. = ..()
	if(birthday_override_ckey)
		if(!check_valid_override())
			message_admins("Attempted to make [birthday_override_ckey] the birthday person but they are not a valid station role. A random birthday person has be selected instead.")

	if(!birthday_person)
		var/list/birthday_options = list()
		for(var/mob/living/carbon/human/human in GLOB.human_list)
			if(human.mind?.assigned_role in get_all_jobs())
				birthday_options += human
		if(length(birthday_options))
			birthday_person = pick(birthday_options)
			birthday_person_name = birthday_person.real_name

	addtimer(CALLBACK(src, PROC_REF(announce_birthday)), 10 SECONDS)

/datum/station_trait/birthday/proc/create_spawners()
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(pick_turfs_and_spawn))
	UnregisterSignal(SSmapping, COMSIG_SUBSYSTEM_POST_INITIALIZE)

/datum/station_trait/birthday/proc/pick_turfs_and_spawn()
	var/list/turf/turfs = get_safe_random_station_turfs(typesof(/area/hallway) | typesof(/area/crew_quarters/bar) | typesof(/area/crew_quarters/dorms), rand(200, 300))
	if(!turfs)
		return
	for(var/turf/turf as() in turfs)
		spawns += new /obj/effect/spawner/hangover_spawn(turf)

/datum/station_trait/birthday/proc/check_valid_override()
	var/mob/living/carbon/human/birthday_override_mob = get_mob_by_ckey(birthday_override_ckey)
	if(isnull(birthday_override_mob))
		return FALSE

	if(birthday_override_mob.mind?.assigned_role in get_all_jobs())
		birthday_person = birthday_override_mob
		birthday_person_name = birthday_person.real_name
		return TRUE
	else
		return FALSE

/datum/station_trait/birthday/proc/announce_birthday()
	report_message = "We here at Nanotrasen would all like to wish [birthday_person ? birthday_person_name : "Employee Name"] a very happy birthday"
	priority_announce("Happy birthday to [birthday_person ? birthday_person_name : "Employee Name"]! Nanotrasen wishes you a very happy [birthday_person ? thtotext(birthday_person.age + 1) : "255th"] birthday.")
	if(birthday_person)
		playsound(birthday_person, 'sound/items/party_horn.ogg', 50)
		SEND_SIGNAL(birthday_person, COMSIG_ADD_MOOD_EVENT, "birthday", /datum/mood_event/birthday)
		birthday_person = null

/datum/station_trait/birthday/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/living_mob, mob/spawned_mob, joined_late)
	SIGNAL_HANDLER

	var/obj/item/hat = pick_weight(list(
		/obj/item/clothing/head/costume/party/festive = 12,
		/obj/item/clothing/head/costume/party = 12,
		/obj/item/clothing/head/costume/festive = 2,
		/obj/item/clothing/head/utility/hardhat/cakehat = 1,
	))
	hat = new hat(living_mob)
	if(!living_mob.equip_to_slot_if_possible(hat, ITEM_SLOT_HEAD, disable_warning = TRUE))
		living_mob.equip_to_slot_or_del(hat, ITEM_SLOT_BACKPACK)
	var/obj/item/toy = pick_weight(list(
		/obj/item/reagent_containers/spray/chemsprayer/party = 4,
		/obj/item/toy/balloon = 2,
		/obj/item/sparkler = 2,
		/obj/item/clothing/mask/party_horn = 2,
	))
	toy = new toy(living_mob)
	if(istype(toy, /obj/item/toy/balloon))
		living_mob.equip_to_slot_or_del(toy, ITEM_SLOT_HANDS) //Balloons do not fit inside of backpacks.
	else
		living_mob.equip_to_slot_or_del(toy, ITEM_SLOT_BACKPACK)

	if(ishuman(spawned_mob))
		var/mob/living/carbon/human/spawned_human = spawned_mob
		if(birthday_person_name) //Anyone who joins after the annoucement gets one of these.
			var/obj/item/birthday_invite/birthday_invite = new(spawned_human)
			birthday_invite.setup_card(birthday_person_name)

			INVOKE_ASYNC(spawned_human, TYPE_PROC_REF(/mob/living/carbon/human, equip_or_collect), birthday_invite, ITEM_SLOT_HANDS)

/datum/station_trait/unique_ai
	name = "Unique AI"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "For experimental purposes, this station AI might show divergence from default lawset. Do not meddle with this experiment, we've removed \
		access to your set of alternative upload modules because we know you're already thinking about meddling with this experiment."
	trait_to_give = STATION_TRAIT_UNIQUE_AI
