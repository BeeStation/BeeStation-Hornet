/datum/job
	///The name of the job , used for preferences, bans and more. Make sure you know what you're doing before changing this.
	var/title = "NOPE"

	/// The description of the job, used for preferences menu.
	/// Keep it short and useful. Avoid in-jokes, these are for new players.
	var/description

	///Job access. The use of minimal_access or access is determined by a config setting: config.jobs_have_minimal_access
	var/list/minimal_access = list()		//Useful for servers which prefer to only have access given to the places a job absolutely needs (Larger server population)
	var/list/access = list()				//Useful for servers which either have fewer players, so each person needs to fill more than one role, or servers which like to give more access, so players can't hide forever in their super secure departments (I'm looking at you, chemistry!)

	///Determines who can demote this position
	var/department_head = list()

	///Tells the given channels that the given mob is the new department head. See communications.dm for valid channels.
	var/list/head_announce = null

	///Bitflags for the job
	var/flag = NONE //Deprecated //Except not really, still used throughout the codebase
	var/auto_deadmin_role_flags = NONE

	/// If this job should show in the preferences menu
	var/show_in_prefs = TRUE

	/// The head of the department to show in the preferences menu
	var/department_head_for_prefs

	///Mostly deprecated, but only used in pref job savefiles
	var/department_flag = NONE

	///Players will be allowed to spawn in as jobs that are set to "Station"
	var/faction = "None"

	///How many players can be this job
	var/total_positions = 0

	///How many players can spawn in as this job
	var/spawn_positions = 0

	///How many players have this job
	var/current_positions = 0

	///Supervisors, who this person answers to directly
	var/supervisors = ""

	///Selection screen color
	var/selection_color = "#ffffff"

	///Overhead chat message colour
	var/chat_color = "#ffffff"

	///If this is set to 1, a text is printed to the player when jobs are assigned, telling him that he should let admins know that he has to disconnect.
	var/req_admin_notify

	///If you have the use_age_restriction_for_jobs config option enabled and the database set up, this option will add a requirement for players to be at least minimal_player_age days old. (meaning they first signed in at least that many days before.)
	var/minimal_player_age = 0

	var/outfit = null

	var/exp_requirements = 0

	var/exp_type = ""
	var/exp_type_department = ""

	///The amount of good boy points playing this role will earn you towards a higher chance to roll antagonist next round can be overridden by antag_rep.txt config
	var/antag_rep = 10

	///vender will not ask you for credits when you buy a stuff from it as long as department matches
	var/bank_account_department = ACCOUNT_CIV_BITFLAG
	///your payment per department. geneticist will be a good example for this.
	var/payment_per_department = list(ACCOUNT_CIV_ID = 0)

	var/list/mind_traits // Traits added to the mind of the mob assigned this job

	var/display_order = JOB_DISPLAY_ORDER_DEFAULT

	// Goodies that can be received via the mail system.
	// this is a weighted list.
	// Keep the _job definition for this empty and use /obj/item/mail to define general gifts.
	var/list/mail_goodies = list()

	// If this job's mail goodies compete with generic goodies.
	var/exclusive_mail_goodies = FALSE

	var/gimmick = FALSE //least hacky way i could think of for this

	///Bitfield of departments this job belongs with
	var/departments = NONE
	/// Same as the departments bitflag, but only one is allowed. Used in the preferences menu.
	var/department_for_prefs = null
	///Is this job affected by weird spawns like the ones from station traits
	var/random_spawns_possible = TRUE
	/// Should this job be allowed to be picked for the bureaucratic error event?
	var/allow_bureaucratic_error = TRUE
	///how at risk is this occupation at for being a carrier of a dormant disease
	var/biohazard = 20

	///A dictionary of species IDs and a path to the outfit.
	var/list/species_outfits = null

	///RPG job names, for the memes
	var/rpg_title

	/**
	 * A list of job-specific areas to enable lights for if this job is present at roundstart, whenever minimal access is not in effect.
	 * This will be combined with minimal_lightup_areas, so no need to duplicate entries.
	 * Areas within their department will have their lights turned on automatically, so you should really only use this for areas outside of their department.
	 */
	var/list/lightup_areas = list()
	/**
	 * A list of job-specific areas to enable lights for if this job is present at roundstart.
	 * Areas within their department will have their lights turned on automatically, so you should really only use this for areas outside of their department.
	 */
	var/list/minimal_lightup_areas = list()


/datum/job/New()
	. = ..()
	lightup_areas = typecacheof(lightup_areas)
	minimal_lightup_areas = typecacheof(minimal_lightup_areas)

/// Only override this proc, unless altering loadout code. Loadouts act on H but get info from M
/// H is usually a human unless an /equip override transformed it
/// do actions on H but send messages to M as the key may not have been transferred_yet
/// preference_source allows preferences to be retrieved if the original mob (M) is null - for use on preference dummies.
/// Don't do non-visual changes if M.client is null, since that means it's just a dummy and doesn't need them.
/datum/job/proc/after_spawn(mob/living/H, mob/M, latejoin = FALSE, client/preference_source, on_dummy = FALSE)
	if(!on_dummy) // Bad dummy
		//do actions on H but send messages to M as the key may not have been transferred_yet
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_JOB_AFTER_SPAWN, src, H, M, latejoin)
		if(mind_traits && H?.mind)
			for(var/t in mind_traits)
				ADD_TRAIT(H.mind, t, JOB_TRAIT)

	if(!ishuman(H))
		return
	apply_loadout_to_mob(H, M, preference_source, on_dummy)

/proc/apply_loadout_to_mob(mob/living/carbon/human/H, mob/M, client/preference_source, on_dummy = FALSE)
	var/mob/living/carbon/human/human = H
	var/list/gear_leftovers = list()
	var/jumpsuit_style = preference_source.prefs.read_character_preference(/datum/preference/choiced/jumpsuit_style)
	if(preference_source && LAZYLEN(preference_source.prefs.equipped_gear))
		for(var/gear in preference_source.prefs.equipped_gear)
			var/datum/gear/G = GLOB.gear_datums[gear]
			if(G)
				if(!G.is_equippable)
					continue
				var/permitted = FALSE

				if(G.allowed_roles && H.mind && (H.mind.assigned_role in G.allowed_roles))
					permitted = TRUE
				else if(!G.allowed_roles)
					permitted = TRUE
				else
					permitted = FALSE

				if(G.species_blacklist && (human.dna.species.id in G.species_blacklist))
					permitted = FALSE

				if(G.species_whitelist && !(human.dna.species.id in G.species_whitelist))
					permitted = FALSE

				if(!permitted)
					if(M.client)
						to_chat(M, "<span class='warning'>Your current species or role does not permit you to spawn with [G.display_name]!</span>")
					continue

				if(G.slot)
					var/obj/o
					if(on_dummy) // remove the old item
						o = H.get_item_by_slot(G.slot)
						H.doUnEquip(H.get_item_by_slot(G.slot), newloc = H.drop_location(), invdrop = FALSE, silent = TRUE)
					if(H.equip_to_slot_or_del(G.spawn_item(H, skirt_pref = jumpsuit_style), G.slot))
						if(M.client)
							to_chat(M, "<span class='notice'>Equipping you with [G.display_name]!</span>")
						if(on_dummy && o)
							qdel(o)
					else
						gear_leftovers += G
				else
					gear_leftovers += G

			else
				preference_source.prefs.equipped_gear -= gear
				preference_source.prefs.mark_undatumized_dirty_character()

	if(gear_leftovers.len)
		for(var/datum/gear/G in gear_leftovers)
			var/metadata = preference_source.prefs.equipped_gear[G.id]
			var/item = G.spawn_item(null, metadata, jumpsuit_style)
			var/atom/placed_in = human.equip_or_collect(item)

			if(istype(placed_in))
				if(isturf(placed_in))
					if(M.client)
						to_chat(M, "<span class='notice'>Placing [G.display_name] on [placed_in]!</span>")
				else
					if(M.client)
						to_chat(M, "<span class='noticed'>Placing [G.display_name] in [placed_in.name]]")
				continue

			if(H.equip_to_appropriate_slot(item))
				if(M.client)
					to_chat(M, "<span class='notice'>Placing [G.display_name] in your inventory!</span>")
				continue
			if(H.put_in_hands(item))
				if(M.client)
					to_chat(M, "<span class='notice'>Placing [G.display_name] in your hands!</span>")
				continue

			var/obj/item/storage/B = (locate() in H)
			if(B)
				G.spawn_item(B, metadata, jumpsuit_style)
				if(M.client)
					to_chat(M, "<span class='notice'>Placing [G.display_name] in [B.name]!</span>")
				continue
			if(M.client)
				to_chat(M, "<span class='danger'>Failed to locate a storage object on your mob, either you spawned with no hands free and no backpack or this is a bug.</span>")
			qdel(item)

/datum/job/proc/announce(mob/living/carbon/human/H)
	if(head_announce)
		announce_head(H, head_announce)

/datum/job/proc/override_latejoin_spawn(mob/living/carbon/human/H)		//Return TRUE to force latejoining to not automatically place the person in latejoin shuttle/whatever.
	return FALSE

//Used for a special check of whether to allow a client to latejoin as this job.
/datum/job/proc/special_check_latejoin(client/C)
	return TRUE

/datum/job/proc/GetAntagRep()
	if(CONFIG_GET(flag/equal_job_weight))
		var/rep_value = CONFIG_GET(number/default_rep_value)
		if(!rep_value)
			rep_value = 0
		return rep_value
	. = CONFIG_GET(keyed_list/antag_rep)[lowertext(title)]
	if(. == null)
		return antag_rep

//Don't override this unless the job transforms into a non-human (Silicons do this for example)
/datum/job/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE, announce = TRUE, latejoin = FALSE, datum/outfit/outfit_override = null, client/preference_source)
	if(!H)
		return FALSE
	if(CONFIG_GET(flag/enforce_human_authority) && (title in GLOB.command_positions))
		if(H.dna.species.id != SPECIES_HUMAN)
			H.set_species(/datum/species/human)
			H.apply_pref_name(/datum/preference/name/backup_human, preference_source)
	if(!visualsOnly)
		var/datum/bank_account/bank_account = new(H.real_name, src)
		bank_account.payday(STARTING_PAYCHECKS, TRUE)
		H.mind?.account_id = bank_account.account_id

	//Equip the rest of the gear
	H.dna.species.before_equip_job(src, H, visualsOnly)

	if(src.species_outfits)
		if(H.dna.species.id in src.species_outfits)
			var/datum/outfit/O = species_outfits[H.dna.species.id]
			H.equipOutfit(O, visualsOnly)

	if(outfit_override || outfit)
		H.equipOutfit(outfit_override ? outfit_override : outfit, visualsOnly)

	H.dna.species.after_equip_job(src, H, visualsOnly, preference_source)

	if(!visualsOnly && announce)
		announce(H)
	H.give_random_dormant_disease(biohazard, (title == JOB_NAME_CLOWN || title == JOB_NAME_MIME) ? 0 : 4)

/datum/job/proc/get_access()
	if(!config)	//Needed for robots.
		return src.minimal_access.Copy()

	. = list()

	if(CONFIG_GET(flag/jobs_have_minimal_access))
		. = src.minimal_access.Copy()
	else
		. = src.access.Copy()

	if(CONFIG_GET(flag/everyone_has_maint_access)) //Config has global maint access set
		. |= list(ACCESS_MAINT_TUNNELS)

/datum/job/proc/announce_head(var/mob/living/carbon/human/H, var/channels) //tells the given channel that the given mob is the new department head. See communications.dm for valid channels.
	if(H && GLOB.announcement_systems.len)
		//timer because these should come after the captain announcement
		SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_addtimer), CALLBACK(pick(GLOB.announcement_systems), /obj/machinery/announcement_system/proc/announce, "NEWHEAD", H.real_name, H.job, channels), 1))

//If the configuration option is set to require players to be logged as old enough to play certain jobs, then this proc checks that they are, otherwise it just returns 1
/datum/job/proc/player_old_enough(client/C)
	if(available_in_days(C) == 0)
		return TRUE	//Available in 0 days = available right now = player is old enough to play.
	return FALSE

/datum/job/proc/areas_to_light_up(minimal_access = TRUE)
	. = minimal_lightup_areas.Copy()
	if(!minimal_access)
		. |= lightup_areas
	if(CHECK_BITFIELD(departments, DEPT_BITFLAG_COM))
		. |= GLOB.command_lightup_areas
	if(CHECK_BITFIELD(departments, DEPT_BITFLAG_ENG))
		. |= GLOB.engineering_lightup_areas
	if(CHECK_BITFIELD(departments, DEPT_BITFLAG_MED))
		. |= GLOB.medical_lightup_areas
	if(CHECK_BITFIELD(departments, DEPT_BITFLAG_SCI))
		. |= GLOB.science_lightup_areas
	if(CHECK_BITFIELD(departments, DEPT_BITFLAG_CAR))
		. |= GLOB.supply_lightup_areas
	if(CHECK_BITFIELD(departments, DEPT_BITFLAG_SEC))
		. |= GLOB.security_lightup_areas

/datum/job/proc/available_in_days(client/C)
	if(!C)
		return 0
	if(!CONFIG_GET(flag/use_age_restriction_for_jobs))
		return 0
	if(!SSdbcore.Connect())
		return 0 //Without a database connection we can't get a player's age so we'll assume they're old enough for all jobs
	if(!isnum_safe(minimal_player_age))
		return 0

	return max(0, minimal_player_age - C.player_age)

/datum/job/proc/config_check()
	return TRUE

/datum/job/proc/map_check()
	return TRUE

/datum/job/proc/radio_help_message(mob/M)
	to_chat(M, "<b>Prefix your message with :h to speak on your department's radio. To see other prefixes, look closely at your headset.</b>")

/datum/outfit/job
	name = "Standard Gear"

	var/jobtype

	uniform = /obj/item/clothing/under/color/grey
	id = /obj/item/card/id
	ears = /obj/item/radio/headset
	belt = /obj/item/modular_computer/tablet/pda
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/sneakers/black
	box = /obj/item/storage/box/survival/normal

	var/backpack = /obj/item/storage/backpack
	var/satchel  = /obj/item/storage/backpack/satchel
	var/duffelbag = /obj/item/storage/backpack/duffelbag

	var/pda_slot = ITEM_SLOT_BELT

/datum/outfit/job/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	switch(H.backbag)
		if(GBACKPACK)
			back = /obj/item/storage/backpack //Grey backpack
		if(GSATCHEL)
			back = /obj/item/storage/backpack/satchel //Grey satchel
		if(GDUFFELBAG)
			back = /obj/item/storage/backpack/duffelbag //Grey Duffel bag
		if(LSATCHEL)
			back = /obj/item/storage/backpack/satchel/leather //Leather Satchel
		if(DSATCHEL)
			back = satchel //Department satchel
		if(DDUFFELBAG)
			back = duffelbag //Department duffel bag
		else
			back = backpack //Department backpack

	//converts the uniform string into the path we'll wear, whether it's the skirt or regular variant
	var/holder
	if(H.jumpsuit_style == PREF_SKIRT)
		holder = "[uniform]/skirt"
		if(!text2path(holder))
			holder = "[uniform]"
	else
		holder = "[uniform]"
	uniform = text2path(holder)


/datum/outfit/job/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/datum/job/J = SSjob.GetJobType(jobtype)
	if(!J)
		J = SSjob.GetJob(H.job)

	var/obj/item/card/id/C = H.wear_id
	if(istype(C))
		C.access = J.get_access()
		shuffle_inplace(C.access) // Shuffle access list to make NTNet passkeys less predictable
		C.registered_name = H.real_name
		C.assignment = J.title
		C.set_hud_icon_on_spawn(J.title)
		C.update_label()
		for(var/datum/bank_account/B in SSeconomy.bank_accounts)
			if(!H.mind)
				continue
			if(B.account_id == H.mind.account_id)
				C.registered_account = B
				B.bank_cards += C
				break
		H.sec_hud_set_ID()

	var/obj/item/modular_computer/tablet/pda/PDA = H.get_item_by_slot(pda_slot)
	if(istype(PDA))
		PDA.saved_identification = C.registered_name
		PDA.saved_job = C.assignment
		PDA.update_id_display()

/datum/outfit/job/get_chameleon_disguise_info()
	var/list/types = ..()
	types -= /obj/item/storage/backpack //otherwise this will override the actual backpacks
	types += backpack
	types += satchel
	types += duffelbag
	return types

//Warden and regular officers add this result to their get_access()
/datum/job/proc/check_config_for_sec_maint()
	if(CONFIG_GET(flag/security_has_maint_access))
		return list(ACCESS_MAINT_TUNNELS)
	return list()

/// Applies the preference options to the spawning mob, taking the job into account. Assumes the client has the proper mind.
/mob/living/proc/apply_prefs_job(client/player_client, datum/job/job)

/mob/living/carbon/human/apply_prefs_job(client/player_client, datum/job/job)
	var/fully_randomize = is_banned_from(player_client.ckey, "Appearance")
	if(!player_client)
		return // Disconnected while checking for the appearance ban.

	var/require_human = CONFIG_GET(flag/enforce_human_authority) && (job.departments & DEPT_BITFLAG_COM)

	if(fully_randomize)
		if(require_human)
			player_client.prefs.randomize_appearance_prefs(~RANDOMIZE_SPECIES)
		else
			player_client.prefs.randomize_appearance_prefs()

		player_client.prefs.apply_prefs_to(src)

		if (require_human)
			set_species(/datum/species/human)
	else
		var/is_antag = (player_client.mob.mind in GLOB.pre_setup_antags)
		if(require_human)
			player_client.prefs.randomize["species"] = FALSE
		player_client.prefs.safe_transfer_prefs_to(src, TRUE, is_antag)
		if (require_human)
			set_species(/datum/species/human)
			apply_pref_name(/datum/preference/name/backup_human, player_client)
		if(CONFIG_GET(flag/force_random_names))
			var/species_type = player_client.prefs.read_character_preference(/datum/preference/choiced/species)
			var/datum/species/species = new species_type

			var/gender = player_client.prefs.read_character_preference(/datum/preference/choiced/gender)
			real_name = species.random_name(gender, TRUE)
	dna.update_dna_identity()

/mob/living/silicon/ai/apply_prefs_job(client/player_client, datum/job/job)
	apply_pref_name(/datum/preference/name/ai, player_client) // This proc already checks if the player is appearance banned.
	set_core_display_icon(null, player_client)

/mob/living/silicon/robot/apply_prefs_job(client/player_client, datum/job/job)
	if(mmi)
		var/organic_name
		if(player_client.prefs.read_character_preference(/datum/preference/choiced/random_name) == RANDOM_ENABLED || CONFIG_GET(flag/force_random_names) || is_banned_from(player_client.ckey, "Appearance"))
			if(!player_client)
				return // Disconnected while checking the appearance ban.

			var/species_type = player_client.prefs.read_character_preference(/datum/preference/choiced/species)
			var/datum/species/species = new species_type
			organic_name = species.random_name(player_client.prefs.read_character_preference(/datum/preference/choiced/gender), TRUE)
		else
			if(!player_client)
				return // Disconnected while checking the appearance ban.
			organic_name = player_client.prefs.read_character_preference(/datum/preference/name/real_name)

		mmi.name = "[initial(mmi.name)]: [organic_name]"
		if(mmi.brain)
			mmi.brain.name = "[organic_name]'s brain"
		if(mmi.brainmob)
			mmi.brainmob.real_name = organic_name //the name of the brain inside the cyborg is the robotized human's name.
			mmi.brainmob.name = organic_name
	// If this checks fails, then the name will have been handled during initialization.
	if(player_client.prefs.read_character_preference(/datum/preference/name/cyborg) != DEFAULT_CYBORG_NAME)
		apply_pref_name(/datum/preference/name/cyborg, player_client)
