/datum/job
	///The name of the job , used for preferences, bans and more. Make sure you know what you're doing before changing this.
	var/title = "NOPE"

	/// The description of the job, used for preferences menu.
	/// Keep it short and useful. Avoid in-jokes, these are for new players.
	var/description

	///Job access. The use of minimal_access or access is determined by a config setting: config.jobs_have_minimal_access
	var/list/base_access = list()  // access list that's basically given to jobs.
	var/list/extra_access = list() // EXTRA access list that's given in lowpop.

	///Determines who can demote this position
	var/department_head = list()

	///Tells the given channels that the given mob is the new department head. See communications.dm for valid channels.
	var/list/head_announce = null

	///Bitflags for the job
	var/flag = NONE //Deprecated //Except not really, still used throughout the codebase
	var/auto_deadmin_role_flags = NONE

	/// Determines whether or not late-joining as this role is allowed
	var/latejoin_allowed = TRUE

	/// flags with the job lock reasons. If this flag exists, it's not available anyway.
	var/lock_flags = NONE

	/// If this job should show in the preferences menu
	var/show_in_prefs = TRUE

	/// The head of the department to show in the preferences menu
	var/department_head_for_prefs

	///Players will be allowed to spawn in as jobs that are set to "Station"
	var/faction = "None"

	///How many players can be this job
	var/total_positions = 0

	///How many players have this job
	var/current_positions = 0

	///Supervisors, who this person answers to directly
	var/supervisors = ""

	///Selection screen color
	var/selection_color = COLOR_WHITE

	///Overhead chat message colour
	var/chat_color = COLOR_WHITE

	///If this is set to 1, a text is printed to the player when jobs are assigned, telling him that he should let admins know that he has to disconnect.
	var/req_admin_notify

	///If you have the use_age_restriction_for_jobs config option enabled and the database set up, this option will add a requirement for players to be at least minimal_player_age days old. (meaning they first signed in at least that many days before.)
	var/minimal_player_age = 0

	var/outfit = null

	/// Minutes of experience-time required to play in this job.
	var/exp_requirements = 0
	/// What experience type is required to play this role
	/// This does not determine the type of EXP that is granted, that is based
	/// on department. You do not need to set this if exp_requirements is set
	/// to 0, because this role has no exp requirement.
	var/exp_type = ""

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

	/// If the minimum pop is not met, then we will be assigned as if we were actually
	/// this job instead; this means that the geneticist can still appear on low-pop, but
	/// we will be assigned the access of a medical doctor and will count as if a medical
	/// doctor spawned instead.
	var/datum/job/min_pop_redirect = null
	/// The minimum population required at roundstart for this job to appear
	var/min_pop = 0
	/// The maximum population required at roundstart for this job to appear
	var/max_pop = INFINITY

	/// If set, then roles job positions are infinite but the most popular job cannot exceed the
	/// amount of people in the least popular job.
	var/dynamic_spawn_group = null
	/// The maximum allowed variance to other job roles in this group.
	/// Should be the same as everything else in the dynamic spawn group
	var/dynamic_spawn_variance_limit = 2
	/// How many times should this role count towards the spawn group size?
	var/dynamic_spawn_group_multiplier = 1

	/// The HOP can manually add or decrease the amount of players
	/// that can apply for a job, which adjusts the delta value.
	var/total_position_delta = 0

	/// The list of jobs that you can write a manuscript as. This exists letting command roles write more.
	var/list/manuscript_jobs

/datum/job/New()
	. = ..()
	lightup_areas = typecacheof(lightup_areas)
	minimal_lightup_areas = typecacheof(minimal_lightup_areas)

	if(!config_check())
		lock_flags |= JOB_LOCK_REASON_CONFIG
	if(SSmapping.map_adjustment && (title in SSmapping.map_adjustment.blacklisted_jobs))
		lock_flags |= JOB_LOCK_REASON_MAP
	if(lock_flags || gimmick)
		SSjob.job_manager_blacklisted |= title

/// Returns true if there are available slots
/datum/job/proc/has_space()
	// How many slots does our group have?
	var/group_slots = get_spawn_position_count(TRUE)
	// Always available
	if (group_slots == -1)
		return TRUE
	// If the department itself is saturated, return false
	if (dynamic_spawn_group_multiplier && count_players_in_group() >= group_slots)
		return FALSE
	// If the role itself does not care about saturation, return true
	if (total_positions == -1 || dynamic_spawn_group)
		return TRUE
	// If the role itself is saturated, return false
	if (current_positions >= total_positions  + total_position_delta)
		return FALSE
	// Return true otherwise
	return TRUE

/// Calculates the number of positions currently present in a group
/// Returns the number of players who are inside a role if the job hasn't reached
/// its population limit, otherwise groups together roles by checking for their
/// min_pop_redirect proxy role.
/datum/job/proc/count_players_in_group()
	var/spawn_group_size = current_positions * dynamic_spawn_group_multiplier
	// Find all jobs that proxy to the target's spawn group
	// This will mean that medical will count all of the players in medical
	for (var/datum/job/group_job in SSjob.occupations)
		// We already counted ourselves
		if (group_job == src)
			continue
		// If this job proxies to us, then their proxy needs to be active
		if (group_job.min_pop_redirect == type && SSjob.initial_players_to_assign < group_job.min_pop)
			// If the HOP adds a geneticist slot, and that slot gets taken then it counts as if
			// there is no geneticist at all.
			// If the HOP adds a geneticist slot and it doesn't get taken, then it has no effect.
			spawn_group_size += max(0, group_job.current_positions * group_job.dynamic_spawn_group_multiplier - group_job.total_position_delta)
		// If we proxy to this job, then our proxy needs to be active
		if (min_pop_redirect == group_job.type && SSjob.initial_players_to_assign < min_pop)
			spawn_group_size += max(0, group_job.current_positions * group_job.dynamic_spawn_group_multiplier - group_job.total_position_delta)
		// If we are sharing a proxy, both proxies need to be active
		if (min_pop_redirect != null && min_pop_redirect == group_job.min_pop_redirect && SSjob.initial_players_to_assign < group_job.min_pop && SSjob.initial_players_to_assign < min_pop)
			spawn_group_size += max(0, group_job.current_positions * group_job.dynamic_spawn_group_multiplier - group_job.total_position_delta)
	return spawn_group_size - total_position_delta

/// Get the number of positions that are available for this job.
/// Will typically return the total_positions value with the delta set by the HOP added on.
/// If the min/max pop is not met returns 0.
/// If the total positions is -1, returns -1 representing an unlimited position count
/// If a dynamic spawn group is set, or the min pop is not met and the dynamic spawn group of the min_pop_redirect
/// role is set, then it will compute the number of positions available based off of how populated the other jobs
/// in the group are.
/// Certain roles such as geneticist will return the smallest the smaller value between the number of jobs remaining
/// in the medical department, and the max limit of geneticist slots available, if the lowpop limit has not been met.
/// = Params =
/// ignore_self_limit: bool => If set, then the max limit of the job will be ignored when using the dynamic group
/// scaling calculations.
/datum/job/proc/get_spawn_position_count(ignore_self_limit = FALSE)
	var/player_count = SSjob.initial_players_to_assign
	// SSjob has not been allocated yet
	if (!player_count)
		player_count = length(GLOB.clients)
	// Out of range, and no proxy
	if (player_count < min_pop && !min_pop_redirect)
		return 0
	if (player_count > max_pop)
		return 0
	// Unlimited, though we are limited if we use a dynamic spawn group
	// We must be:
	// - Unlimited ourselves
	// - Not present in a dynamic spawn group
	// - Not using a proxy due to lowpop, or the proxy has no dynamic spawn group
	if (total_positions == -1 && !dynamic_spawn_group && (player_count >= min_pop || !min_pop_redirect || !min_pop_redirect::dynamic_spawn_group))
		return -1
	// If the population is lower than our min pop spawn amount
	// then we will instead treat ourselves
	var/datum/job/proxy = src
	if (min_pop_redirect && player_count < min_pop)
		proxy = SSjob.GetJob(min_pop_redirect::title)
	// Does not have a spawn group
	if (!proxy.dynamic_spawn_group)
		// The proxy role allows for infinite joining, so we do too
		if (proxy.total_positions == -1)
			return -1
		return max(proxy.total_positions + total_position_delta, 0)
	// Calculate spawn group size
	var/spawn_group_total = 0
	// Amount of jobs in the same job group as us
	var/spawn_group_sizes = 0
	for (var/datum/job/other in SSjob.occupations)
		// Find everything in the same group, doesn't matter if its us
		if (other.dynamic_spawn_group != proxy.dynamic_spawn_group)
			continue
		// Find the least filled job in the group
		// If the HOP removes a position from another job, then that removed position.
		// If the HOP adds a position to a job group, then it has to be filled before the spawn
		// group bumps.
		spawn_group_total += other.count_players_in_group()
		spawn_group_sizes ++
	// The amount of positions we have is the least filled job + our allowed variance
	// variance is calculated per job, not based on the proxy
	// If we are using a proxy, then the number of spawn positions is limited to the total
	// positions available in that role, regardless of whether or not the department as a whole
	// has extra space.
	// If the proxying target has a dynamic spawn group, then that implictly means that there is
	// no limit to the total positions; this behaviour only exists so that we can limit the number
	// of players joining as a sub-role of a department, not as the primary role.
	var/position_limit = total_positions
	// If we don't care about how many positions this job has itself, then treat the job as having infinite space
	// being only limited by its spawn variance limit
	if (proxy == src || ignore_self_limit || proxy.dynamic_spawn_group)
		position_limit = INFINITY
	return min(position_limit, max(ceil(spawn_group_total / max(spawn_group_sizes, 1)) + proxy.dynamic_spawn_variance_limit + total_position_delta, 0))

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
	var/list/gear_list = list()
	var/obj/item/storage/spawned_box
	var/jumpsuit_style = preference_source.prefs.read_character_preference(/datum/preference/choiced/jumpsuit_style)

	if(preference_source && LAZYLEN(preference_source.prefs.equipped_gear))
		for(var/gear in preference_source.prefs.equipped_gear)
			var/datum/gear/to_sort = GLOB.gear_datums[gear]
			if(to_sort)
				gear_list += to_sort
			// Sort by slot priority
			gear_list = sort_list(gear_list, /proc/gear_priority_cmp)

		// Process gear in priority order
		for(var/datum/gear/G in gear_list)
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
						to_chat(M, span_warning("Your current species or role does not permit you to spawn with [G.display_name]!"))
					continue
				if(G.slot)
					if(G.slot == ITEM_SLOT_BACK)
						var/obj/item/storage/new_bag = G.spawn_item(H, skirt_pref = jumpsuit_style)
						var/obj/item/storage/old_bag = H.get_item_by_slot(ITEM_SLOT_BACK)
						if(old_bag)
							for(var/obj/item/item in old_bag.contents)
								item.forceMove(new_bag)
							H.doUnEquip(old_bag, newloc = null, invdrop = FALSE, silent = TRUE)
							qdel(old_bag)
							if(H.equip_to_slot_or_del(new_bag, G.slot))
								if(M.client)
									to_chat(M, span_notice("Equipping you with [G.display_name]!"))
					else
						var/obj/item/storage/current_bag = H.get_item_by_slot(ITEM_SLOT_BACK)
						var/obj/item/new_item = G.spawn_item(H, skirt_pref = jumpsuit_style)
						// Unequip only if we're about to equip something in that slot
						var/obj/o = H.get_item_by_slot(G.slot)
						if(o)
							if(!spawned_box && !on_dummy)	//Spawn the box only if theres something being unequiped.

								spawned_box = new /obj/item/storage/box
								spawned_box.name = "compression box of standard gear"
								spawned_box.forceMove(current_bag)	// Gets put in the backpack
								if(M.client)
									to_chat(M, span_notice("A box with your standard equipment was placed in your [current_bag.name]!"))
							if(isplasmaman(H) && (G.slot == ITEM_SLOT_HEAD || G.slot == ITEM_SLOT_ICLOTHING))
								new_item.forceMove(spawned_box)	// iF THEY'RE PLASMAMAN PUT IT IN THE BOX INSTEAD
								if(M.client)
									to_chat(M, span_notice("Storing your [G.display_name] inside a box in your [current_bag.name]!"))
								continue
							H.doUnEquip(o, newloc = spawned_box ? spawned_box : H.drop_location(), invdrop = FALSE, silent = TRUE)
						if(H.equip_to_slot_or_del(new_item, G.slot))
							if(M.client)
								to_chat(M, span_notice("Equipping you with [G.display_name]!"))

						else
							// If slot was blocked, or item couldn't be equipped, push to leftovers
							gear_leftovers += G
							qdel(new_item) // prevent duplicate spawns
				else
					gear_leftovers += G

			else
				preference_source.prefs.equipped_gear -= G
				preference_source.prefs.mark_undatumized_dirty_character()

	if(gear_leftovers.len)
		for(var/datum/gear/G in gear_leftovers)
			var/metadata = preference_source.prefs.equipped_gear[G.id]
			var/item = G.spawn_item(null, metadata, jumpsuit_style)
			var/atom/placed_in = human.equip_or_collect(item)

			if(istype(placed_in))
				if(isturf(placed_in))
					if(M.client)
						to_chat(M, span_notice("Placing [G.display_name] on [placed_in]!"))
				else
					if(M.client)
						to_chat(M, span_notice("Placing [G.display_name] in [placed_in.name]]"))
				continue

			if(H.equip_to_appropriate_slot(item))
				if(M.client)
					to_chat(M, span_notice("Placing [G.display_name] in your inventory!"))
				continue
			if(H.put_in_hands(item))
				if(M.client)
					to_chat(M, span_notice("Placing [G.display_name] in your hands!"))
				continue

			var/obj/item/storage/B = (locate() in H)
			if(B)
				G.spawn_item(B, metadata, jumpsuit_style)
				if(M.client)
					to_chat(M, span_notice("Placing [G.display_name] in [B.name]!"))
				continue
			if(M.client)
				to_chat(M, span_danger("Failed to locate a storage object on your mob, either you spawned with no hands free and no backpack or this is a bug."))
			qdel(item)


/proc/get_slot_priority(datum/gear/G)
	var/list/priority_order = list(ITEM_SLOT_BACK, ITEM_SLOT_HEAD, ITEM_SLOT_ICLOTHING)
	var/slot = G.slot
	var/idx = priority_order.Find(slot)
	if(idx == -1)
		return 999 // Very low priority if not in list
	return idx

/proc/gear_priority_cmp(a, b)
	return get_slot_priority(a) < get_slot_priority(b)

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
	. = CONFIG_GET(keyed_list/antag_rep)[LOWER_TEXT(title)]
	if(. == null)
		return antag_rep

//Don't override this unless the job transforms into a non-human (Silicons do this for example)
//Returning FALSE is considered a failure. A null or mob return is a successful equip.
/datum/job/proc/equip(mob/living/carbon/human/H, visuals_only = FALSE, announce = TRUE, latejoin = FALSE, datum/outfit/outfit_override = null, client/preference_source)
	if(!H)
		return FALSE
	if(CONFIG_GET(flag/enforce_human_authority) && (title in SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND)))
		if(H.dna.species.id != SPECIES_HUMAN)
			H.set_species(/datum/species/human)
			H.apply_pref_name(/datum/preference/name/backup_human, preference_source)
	if(!visuals_only)
		var/datum/bank_account/bank_account = new(H.real_name, src)
		bank_account.payday(STARTING_PAYCHECKS, TRUE)
		H.mind?.account_id = bank_account.account_id

	//Equip the rest of the gear
	H.dna.species.before_equip_job(src, H, visuals_only)

	if(src.species_outfits)
		if(H.dna.species.id in src.species_outfits)
			var/datum/outfit/O = species_outfits[H.dna.species.id]
			H.equipOutfit(O, visuals_only)

	if(outfit_override || outfit)
		H.equipOutfit(outfit_override ? outfit_override : outfit, visuals_only)

	H.dna.species.after_equip_job(src, H, visuals_only, preference_source)

	if(!visuals_only && announce)
		announce(H)
	H.give_random_dormant_disease(biohazard, (title == JOB_NAME_CLOWN || title == JOB_NAME_MIME) ? 0 : 4)

/datum/job/proc/get_access()
	if(!config)	//Needed for robots.
		return base_access.Copy()

	. = base_access.Copy()

	if(CONFIG_GET(flag/everyone_has_maint_access)) //Config has global maint access set
		. |= ACCESS_MAINT_TUNNELS
	if (SSjob.initial_players_to_assign < LOWPOP_JOB_LIMIT && SSjob.is_job_empty(JOB_NAME_COOK))
		. |= ACCESS_KITCHEN
	// Claim all the access from the redirected role too
	if (SSjob.initial_players_to_assign < min_pop && min_pop_redirect)
		var/datum/job/redirected_role = SSjob.GetJob(min_pop_redirect::title)
		. |= redirected_role.get_access()
	// Gain massive access in super lowpop mode
	if (SSjob.initial_players_to_assign < STATION_UNLOCK_POPULATION)
		// Base increased access
		. |= list(
			ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_EVA,
			ACCESS_CHAPEL_OFFICE, ACCESS_TECH_STORAGE, ACCESS_BAR,
			ACCESS_JANITOR, ACCESS_CREMATORIUM, ACCESS_KITCHEN,
			ACCESS_CONSTRUCTION, ACCESS_HYDROPONICS, ACCESS_LIBRARY,
			ACCESS_THEATRE, ACCESS_MAILSORTING, ACCESS_MINING_STATION,
			ACCESS_GATEWAY, ACCESS_MINERAL_STOREROOM, ACCESS_MINING
		)
		// Access to cargo
		if (SSjob.is_job_empty(JOB_NAME_CARGOTECHNICIAN))
			. |= list(
				ACCESS_CARGO
			)
		// Access to the bridge to request spare ID
		if (SSjob.is_job_empty(JOB_NAME_CAPTAIN))
			. |= ACCESS_HEADS
			. |= ACCESS_KEYCARD_AUTH
		// Access to science
		if (SSjob.is_job_empty(JOB_NAME_SCIENTIST))
			. |= list(
				ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_ROBOTICS,
				ACCESS_RESEARCH, ACCESS_EXPLORATION, ACCESS_XENOBIOLOGY
			)
		// Access to engineering to setup the engine
		if (SSjob.is_job_empty(JOB_NAME_STATIONENGINEER))
			. |= list(
				ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_ATMOSPHERICS
			)
		// Access to medical. Jobs like geneticist don't count
		if (SSjob.is_job_empty(JOB_NAME_MEDICALDOCTOR))
			. |= list(
				ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS,
				ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_SURGERY,
				ACCESS_CLONING
			)

/datum/job/proc/announce_head(mob/living/carbon/human/H, channels) //tells the given channel that the given mob is the new department head. See communications.dm for valid channels.
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

/datum/job/proc/get_lock_reason()
	if(lock_flags & JOB_LOCK_REASON_ABSTRACT)
		return "Not a real job"
	else if(lock_flags & JOB_LOCK_REASON_CONFIG)
		return "Disabled by server configuration"
	else if(lock_flags & JOB_LOCK_REASON_MAP)
		return "Not available on this map"
	else if(lock_flags) // somehow flag exists
		return "Unknown: [lock_flags]"

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
	box = /obj/item/storage/box/survival

	preload = TRUE // These are used by the prefs ui, and also just kinda could use the extra help at roundstart

	var/backpack = /obj/item/storage/backpack
	var/satchel  = /obj/item/storage/backpack/satchel
	var/duffelbag = /obj/item/storage/backpack/duffelbag

	var/pda_slot = ITEM_SLOT_BELT

/datum/outfit/job/pre_equip(mob/living/carbon/human/H, visuals_only = FALSE)
	if(ispath(back, /obj/item/storage/backpack))
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


/datum/outfit/job/post_equip(mob/living/carbon/human/user, visuals_only = FALSE)
	if(visuals_only)
		return

	var/datum/job/equipped_job = SSjob.GetJobType(jobtype)
	if(!equipped_job)
		equipped_job = SSjob.GetJob(user.job)

	var/obj/item/card/id/card = user.wear_id
	if(istype(card))
		card.access = equipped_job.get_access()
		shuffle_inplace(card.access) // Shuffle access list to make NTNet passkeys less predictable
		card.registered_name = user.real_name
		card.assignment = equipped_job.title
		card.set_hud_icon_on_spawn(equipped_job.title)

		if(user.age)
			card.registered_age = user.age

		card.update_label()
		card.update_icon()

		for(var/datum/bank_account/account in SSeconomy.bank_accounts)
			if(!user.mind)
				continue
			if(account.account_id == user.mind.account_id)
				card.registered_account = account
				account.bank_cards += card
				break
		user.sec_hud_set_ID()

	var/obj/item/modular_computer/tablet/pda/PDA = user.get_item_by_slot(pda_slot)
	if(istype(PDA))
		PDA.saved_identification = card.registered_name
		PDA.saved_job = card.assignment
		PDA.update_id_display()

/datum/outfit/job/get_chameleon_disguise_info()
	var/list/types = ..()
	types -= /obj/item/storage/backpack //otherwise this will override the actual backpacks
	types += backpack
	types += satchel
	types += duffelbag
	return types

/datum/outfit/job/get_types_to_preload()
	var/list/preload = ..()
	preload += backpack
	preload += satchel
	preload += duffelbag
	preload += /obj/item/storage/backpack/satchel/leather
	var/skirtpath = "[uniform]/skirt"
	preload += text2path(skirtpath)
	return preload

//Warden and regular officers add this result to their get_access()
/datum/job/proc/check_config_for_sec_maint()
	return CONFIG_GET(flag/security_has_maint_access)

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
			real_name = generate_random_name_species_based(
				player_client.prefs.read_character_preference(/datum/preference/choiced/gender),
				TRUE,
				player_client.prefs.read_character_preference(/datum/preference/choiced/species),
			)
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

			organic_name = generate_random_name_species_based(
				player_client.prefs.read_character_preference(/datum/preference/choiced/gender),
				TRUE,
				player_client.prefs.read_character_preference(/datum/preference/choiced/species),
			)
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
	if(player_client.prefs.read_character_preference(/datum/preference/name/cyborg) != DEFAULT_CYBORG_NAME && check_cyborg_name(player_client, mmi))
		apply_pref_name(/datum/preference/name/cyborg, player_client)
