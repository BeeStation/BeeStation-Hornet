/datum/antagonist/vampire
	name = "\improper Vampire"
	roundend_category = "vampires"
	antagpanel_category = "Vampire"
	banning_key = ROLE_VAMPIRE
	required_living_playtime = 4
	ui_name = "AntagInfoVampire"
	hijack_speed = 0.5

	/// How much blood we have, starting off at default blood levels.
	/// We don't use our actual body's temperature because some species don't have blood and we don't want to exclude them
	var/vampire_blood_volume = BLOOD_VOLUME_NORMAL
	/// How much blood we can have at once, increases per level.
	var/max_blood_volume = 600

	/// The vampire team, used for vassals
	var/datum/team/vampire/vampire_team
	/// The vampire's clan
	var/datum/vampire_clan/my_clan

	/// Timer between alerts for Burn messages
	COOLDOWN_DECLARE(vampire_spam_sol_burn)
	/// Timer between alerts for Healing messages
	COOLDOWN_DECLARE(vampire_spam_healing)

	/// Flavor only
	var/vampire_name
	var/vampire_title
	var/vampire_reputation

	/// Have we been broken the Masquerade?
	var/broke_masquerade = FALSE
	/// How many Masquerade Infractions do we have?
	var/masquerade_infractions = 0

	/// Blood required to enter Frenzy
	var/frenzy_threshold = FRENZY_THRESHOLD_ENTER
	/// If we are currently in a Frenzy
	var/frenzied = FALSE

	/// Powers currently owned
	var/list/datum/action/vampire/powers = list()
	/// Frenzy Grab Martial art given to Vampires in a Frenzy
	var/datum/martial_art/frenzygrab/frenzygrab = new

	/// Vassals under my control. Periodically remove the dead ones.
	var/list/datum/antagonist/vassal/vassals = list()
	/// Special vassals I own, to not have double of the same type.
	var/list/datum/antagonist/vassal/special_vassals = list()

	/// The rank this vampire is at, used to level abilities and strength up
	var/vampire_level = 0
	var/vampire_level_unspent = 0

	/// Additional regeneration when the vampire has a lot of blood
	var/additional_regen
	/// How much damage the vampire heals each life tick. Increases per rank up
	var/vampire_regen_rate = 0.3

	/// Lair
	var/area/vampire_lair_area
	var/obj/structure/closet/crate/coffin

	/// To keep track of objectives
	var/total_blood_drank = 0

	/// Blood display HUD
	var/atom/movable/screen/vampire/blood_counter/blood_display
	/// Vampire level display HUD
	var/atom/movable/screen/vampire/rank_counter/vamprank_display
	/// Sunlight timer HUD
	var/atom/movable/screen/vampire/sunlight_counter/sunlight_display

	/// Tracker so that vassals know where their master is
	var/obj/effect/abstract/vampire_tracker_holder/tracker

	/// Static typecache of all vampire powers.
	var/static/list/all_vampire_powers = typecacheof(/datum/action/vampire, ignore_root_path = TRUE)
	/// Antagonists that cannot be Vassalized no matter what
	var/static/list/vassal_banned_antags = list(
		/datum/antagonist/vampire,
		/datum/antagonist/changeling,
		/datum/antagonist/cult,
		/datum/antagonist/servant_of_ratvar,
	)

	/// List of traits applied inherently
	var/static/list/vampire_traits = list(
		TRAIT_NOBREATH,
		TRAIT_SLEEPIMMUNE,
		TRAIT_NOCRITDAMAGE,
		TRAIT_RESISTCOLD,
		TRAIT_RADIMMUNE,
		TRAIT_GENELESS,
		TRAIT_STABLEHEART,
		TRAIT_NOSOFTCRIT,
		TRAIT_NOHARDCRIT,
		TRAIT_AGEUSIA,
		TRAIT_COLDBLOODED,
		TRAIT_VIRUSIMMUNE,
		TRAIT_TOXIMMUNE,
		TRAIT_STABLELIVER,
		TRAIT_OOZELING_NO_CANNIBALIZE,
	)

	/// List of traits applied while in torpor
	var/static/list/torpor_traits = list(
		TRAIT_NODEATH,
		TRAIT_FAKEDEATH,
		TRAIT_DEATHCOMA,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTHIGHPRESSURE,
	)

/datum/antagonist/vampire/proc/create_vampire_team()
	vampire_team = new(owner)
	vampire_team.name = "[ADMIN_LOOKUP(owner.current)]'s vampire team" // only displayed to admins
	vampire_team.master_vampire = src

/datum/team/vampire
	name = "vampire team"
	var/datum/antagonist/vampire/master_vampire

/datum/team/vampire/roundend_report()
	return
/**
 * Apply innate effects is everything given to the mob
 * When a body is tranferred, this is called on the new mob
 * while on_gain is called ONCE per ANTAG, this is called ONCE per BODY.
 */
/datum/antagonist/vampire/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	RegisterSignal(current_mob, COMSIG_LIVING_LIFE, PROC_REF(LifeTick))
	RegisterSignal(current_mob, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(current_mob, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(current_mob, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	handle_clown_mutation(current_mob, "Your clownish nature has been subdued by your thirst for blood.")

	create_vampire_team()

	add_antag_hud(ANTAG_HUD_VAMPIRE, "vampire", current_mob)

	current_mob.faction |= FACTION_VAMPIRE

	if(current_mob.hud_used)
		on_hud_created()
	else
		RegisterSignal(current_mob, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))

	setup_tracker(current_mob)

#ifdef VAMPIRE_TESTING
	var/turf/user_loc = get_turf(current_mob)
	new /obj/structure/closet/crate/coffin(user_loc)
	new /obj/structure/vampire/vassalrack(user_loc)
#endif

/**
 * Remove innate effects is everything given to the mob
 * When a body is tranferred, this is called on the old mob.
 * while on_removal is called ONCE per ANTAG, this is called ONCE per BODY.
**/
/datum/antagonist/vampire/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	UnregisterSignal(current_mob, list(COMSIG_LIVING_LIFE, COMSIG_ATOM_EXAMINE, COMSIG_LIVING_DEATH, COMSIG_MOVABLE_MOVED))

	handle_clown_mutation(current_mob, removing = FALSE)

	cleanup_tracker()

	if(current_mob.hud_used)
		var/datum/hud/hud_used = current_mob.hud_used
		hud_used.infodisplay -= blood_display
		hud_used.infodisplay -= vamprank_display
		hud_used.infodisplay -= sunlight_display
		QDEL_NULL(blood_display)
		QDEL_NULL(vamprank_display)
		QDEL_NULL(sunlight_display)

	remove_antag_hud(ANTAG_HUD_VAMPIRE, current_mob)

	current_mob.faction -= FACTION_VAMPIRE

/datum/antagonist/vampire/proc/on_hud_created(datum/source)
	SIGNAL_HANDLER
	var/datum/hud/vampire_hud = owner.current.hud_used

	blood_display = new /atom/movable/screen/vampire/blood_counter(null, vampire_hud)
	vampire_hud.infodisplay += blood_display

	vamprank_display = new /atom/movable/screen/vampire/rank_counter(null, vampire_hud)
	vampire_hud.infodisplay += vamprank_display

	sunlight_display = new /atom/movable/screen/vampire/sunlight_counter(null, vampire_hud)
	vampire_hud.infodisplay += sunlight_display

	vampire_hud.show_hud(vampire_hud.hud_version)
	UnregisterSignal(owner.current, COMSIG_MOB_HUD_CREATED)

/datum/antagonist/vampire/get_admin_commands()
	. = ..()
	.["Give Level"] = CALLBACK(src, PROC_REF(rank_up))
	if(vampire_level_unspent > 0)
		.["Remove Level"] = CALLBACK(src, PROC_REF(rank_down))

	if(broke_masquerade)
		.["Fix Masquerade"] = CALLBACK(src, PROC_REF(fix_masquerade))
	else
		.["Break Masquerade"] = CALLBACK(src, PROC_REF(break_masquerade))

	if(my_clan)
		.["Remove Clan"] = CALLBACK(src, PROC_REF(remove_clan))
	else
		.["Add Clan"] = CALLBACK(src, PROC_REF(admin_set_clan))

/datum/antagonist/vampire/on_gain()
	. = ..()
	RegisterSignal(SSsunlight, COMSIG_SOL_NEAR_START, PROC_REF(sol_near_start))
	RegisterSignal(SSsunlight, COMSIG_SOL_END, PROC_REF(on_sol_end))
	RegisterSignal(SSsunlight, COMSIG_SOL_NEAR_END, PROC_REF(sol_near_end))
	RegisterSignal(SSsunlight, COMSIG_SOL_RISE_TICK, PROC_REF(handle_sol))
	RegisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN, PROC_REF(give_warning))

	// Start Sol if we're the first vampire
	check_start_sunlight()

	// Set name and reputation
	select_first_name()
	select_reputation(am_fledgling = TRUE)

	// Objectives
	forge_objectives()

	// Assign Powers
	check_blacklisted_species()
	give_starting_powers()
	assign_starting_stats()
	owner.special_role = ROLE_VAMPIRE

/datum/antagonist/vampire/on_removal()
	UnregisterSignal(SSsunlight, list(COMSIG_SOL_NEAR_END, COMSIG_SOL_NEAR_START, COMSIG_SOL_END, COMSIG_SOL_RISE_TICK, COMSIG_SOL_WARNING_GIVEN))
	clear_powers_and_stats()
	check_cancel_sunlight()
	owner.special_role = null
	return ..()

/datum/antagonist/vampire/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()

	// Transfer powers
	for(var/datum/action/vampire/all_powers in powers)
		if(old_body)
			all_powers.Remove(old_body)
		all_powers.Grant(new_body)

	// Update punch damage
	var/mob/living/carbon/human/human_new_body = new_body
	var/mob/living/carbon/human/human_old_body = old_body

	if(ishuman(human_new_body) && ishuman(human_old_body))
		var/datum/species/new_species = human_new_body.dna.species
		var/datum/species/old_species = human_old_body.dna.species

		new_species.species_traits += TRAIT_DRINKSBLOOD
		old_species.species_traits -= TRAIT_DRINKSBLOOD

		new_species.punchdamage = old_species.punchdamage
		old_species.punchdamage = initial(old_species.punchdamage)
	else if(ishuman(human_new_body))
		var/datum/species/new_species = human_new_body.dna.species
		new_species.punchdamage += 2

	// Vampire Traits
	old_body?.remove_traits(vampire_traits, TRAIT_VAMPIRE)
	new_body.add_traits(vampire_traits, TRAIT_VAMPIRE)

/datum/antagonist/vampire/greet()
	. = ..()
	var/fullname = return_full_name()
	var/list/msg = list()

	msg += span_cultlarge("You are [fullname], a Vampire!")
	msg += span_cult("Open the Vampire Information panel for information about your Powers, Clan, and more.")
	if(vampire_level_unspent >= 1)
		msg += span_cult("As a latejoin, you have [vampire_level_unspent] bonus Ranks, entering your claimed coffin allows you to spend a Rank.")

	to_chat(owner, examine_block(msg.Join("\n")))

	owner.announce_objectives()

	owner.current.playsound_local(null, 'sound/vampires/VampireAlert.ogg', 100, FALSE, pressure_affected = FALSE)
	antag_memory += "Although you were born a mortal, in undeath you earned the name <b>[fullname]</b>."

/datum/antagonist/vampire/farewell()
	to_chat(owner.current, span_userdanger("With a snap, your curse has ended. You are no longer a Vampire. You live once more!"))
	// Refill with Blood so they don't instantly die.
	if(!HAS_TRAIT(owner.current, TRAIT_NO_BLOOD))
		owner.current.blood_volume = max(owner.current.blood_volume, BLOOD_VOLUME_NORMAL)

// Called when using admin tools to give antag status
/datum/antagonist/vampire/admin_add(datum/mind/new_owner, mob/admin)
	var/levels = input("How many unspent Ranks would you like [new_owner] to have?","Vampire Rank", vampire_level_unspent) as null | num
	var/msg = "made [key_name_admin(new_owner)] into \a [name]"
	if(levels > 0)
		vampire_level_unspent = levels
		msg += " with [levels] extra unspent Ranks."
	message_admins("[key_name_admin(usr)] [msg]")
	log_admin("[key_name(usr)] [msg]")
	new_owner.add_antag_datum(src)

/datum/antagonist/vampire/ui_static_data(mob/user)
	var/list/data = list()
	//we don't need to update this that much.
	data["in_clan"] = !!my_clan
	var/list/clan_data = list()
	if(my_clan)
		clan_data["name"] = my_clan.name
		clan_data["description"] = my_clan.description
		clan_data["icon"] = my_clan.join_icon
		clan_data["icon_state"] = my_clan.join_icon_state

	data["clan"] += list(clan_data)

	for(var/datum/action/vampire/power as anything in powers)
		var/list/power_data = list()

		power_data["name"] = power.name
		power_data["explanation"] = power.power_explanation
		power_data["icon"] = power.background_icon
		power_data["icon_state"] = power.button_icon_state

		power_data["cost"] = power.bloodcost ? power.bloodcost : "0"
		power_data["constant_cost"] = power.constant_bloodcost ? power.constant_bloodcost : "0"
		power_data["cooldown"] = power.cooldown_time / 10

		data["powers"] += list(power_data)

	return data + ..()

/datum/antagonist/vampire/roundend_report()
	var/list/report = list()

	// Vamp name
	report += "<br>[span_header(return_full_name())]"
	report += printplayer(owner)
	if(my_clan)
		report += "They were part of the <b>[my_clan.name]</b>!"

	// Default Report
	var/objectives_complete = TRUE
	if(length(objectives))
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	// Now list their vassals
	if(length(vassals))
		report += span_header("<br>Their Vassals were...")
		for(var/datum/antagonist/vassal/vassal in vassals)
			if(!vassal.owner)
				continue

			var/list/vassal_report = list()
			vassal_report += "<b>[vassal.owner.name]</b>"

			if(vassal.owner.assigned_role)
				vassal_report += " the [vassal.owner.assigned_role]"
			if(IS_FAVORITE_VASSAL(vassal.owner.current))
				vassal_report += " and was the <b>Favorite Vassal</b>"
			report += vassal_report.Join()

	if(objectives_complete)
		report += span_greentextbig("<br>The [name] was successful!")
	else
		report += span_redtextbig("<br>The [name] has failed!")

	return report.Join("<br>")

/datum/antagonist/vampire/proc/give_starting_powers()
	for(var/datum/action/vampire/all_powers as anything in all_vampire_powers)
		if(!(initial(all_powers.purchase_flags) & VAMPIRE_DEFAULT_POWER))
			continue
		grant_power(new all_powers)

/datum/antagonist/vampire/proc/assign_starting_stats()
	var/mob/living/carbon/human/user = owner.current

	// Species traits
	if(ishuman(user) && user.dna)
		var/datum/species/user_species = user.dna.species
		user_species.species_traits += TRAIT_DRINKSBLOOD
		user_species.punchdamage += 2
		user.dna.remove_all_mutations()

	// Give Vampire Traits
	user.add_traits(vampire_traits, TRAIT_VAMPIRE)

	// Clear Addictions
	user.fully_heal(HEAL_TRAUMAS)
	owner.remove_quirk(/datum/quirk/junkie)
	owner.remove_quirk(/datum/quirk/junkie/smoker)

	// No Skittish "People" allowed
	if(HAS_TRAIT(user, TRAIT_SKITTISH))
		REMOVE_TRAIT(user, TRAIT_SKITTISH, ROUNDSTART_TRAIT)

	// Tongue & Language
	user.grant_all_languages(ALL, TRUE, LANGUAGE_VAMPIRE)
	user.grant_language(/datum/language/vampiric)

	/// Clear Disabilities & Organs
	heal_vampire_organs()

/**
 * ##clear_power_and_stats()
 *
 * Removes all Vampire related Powers/Stats changes, setting them back to pre-Vampire
 * Order of steps and reason why:
 * Remove clan - Clans like Nosferatu give Powers on removal, we have to make sure this is given before removing Powers.
 * Powers - Remove all Powers, so things like Masquerade are off.
 * Species traits, Traits, MaxHealth, Language - Misc stuff, has no priority.
 * Organs - At the bottom to ensure everything that changes them has reverted themselves already.
 * Update Sight - Done after Eyes are regenerated.
 */
/datum/antagonist/vampire/proc/clear_powers_and_stats()
	var/mob/living/carbon/user = owner.current

	// Remove clan first
	if(my_clan)
		QDEL_NULL(my_clan)

	// Powers
	for(var/datum/action/vampire/all_powers as anything in powers)
		remove_power(all_powers)

	/// Stats
	if(ishuman(owner.current))
		var/datum/species/user_species = user.dna.species
		user_species.species_traits -= TRAIT_DRINKSBLOOD

	// Remove all vampire traits
	user.remove_traits(vampire_traits, TRAIT_VAMPIRE)

	// Update Health
	user.setMaxHealth(initial(user.maxHealth))

	// Language
	user.remove_all_languages(LANGUAGE_VAMPIRE, TRUE)
	user.remove_language(/datum/language/vampiric)

	// Heart
	var/obj/item/organ/heart/newheart = user.get_organ_slot(ORGAN_SLOT_HEART)
	newheart?.beating = initial(newheart.beating)

	// Eyes
	var/obj/item/organ/eyes/user_eyes = user.get_organ_slot(ORGAN_SLOT_EYES)
	user_eyes?.flash_protect = initial(user_eyes.flash_protect)
	user_eyes?.sight_flags = initial(user_eyes.sight_flags)
	user_eyes?.see_in_dark = NIGHTVISION_FOV_RANGE
	user_eyes?.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	user.update_sight()

/datum/antagonist/vampire/proc/claim_coffin(obj/structure/closet/crate/claimed)
	// ALREADY CLAIMED
	if(claimed.resident)
		if(claimed.resident == owner.current)
			to_chat(owner, "This is your [src].")
		else
			to_chat(owner, "This [src] has already been claimed by another.")
		return FALSE
	var/area/coffin_area = get_area(claimed)
	if(!GLOB.the_station_areas.Find(coffin_area.type))
		claimed.balloon_alert(owner.current, "not part of station!")
		return
	// This is my Lair
	coffin = claimed
	vampire_lair_area = coffin_area
	to_chat(owner, span_userdanger("You have claimed the [claimed] as your place of immortal rest! Your lair is now [vampire_lair_area]."))
	return TRUE

/// Name shown on antag list
/datum/antagonist/vampire/antag_listing_name()
	return ..() + return_full_name()

/datum/action/antag_info/vampire
	name = "Vampire Guide"
	background_icon = 'icons/vampires/actions_vampire.dmi'
	background_icon_state = "vamp_power_off"

/datum/antagonist/vampire/make_info_button()
	if(!ui_name)
		return
	var/datum/action/antag_info/vampire/info_button = new(src)
	info_button.Grant(owner.current)
	info_button_ref = WEAKREF(info_button)
	return info_button

/datum/antagonist/vampire/forge_objectives()
	// Claim a Lair Objective
	var/datum/objective/vampire/lair/lair_objective = new
	lair_objective.owner = owner
	objectives += lair_objective

	// Survive Objective
	var/datum/objective/survive/survive_objective = new
	survive_objective.owner = owner
	objectives += survive_objective

	// Objective 1: Vassalize a Head/Command, or a specific target
	switch(rand(1, 3))
		if(1) // Conversion Objective
			var/datum/objective/vampire/conversion/chosen_subtype = pick(subtypesof(/datum/objective/vampire/conversion))
			var/datum/objective/vampire/conversion/conversion_objective = new chosen_subtype
			conversion_objective.owner = owner
			objectives += conversion_objective
		if(2) // Heart Thief Objective
			var/datum/objective/vampire/heartthief/heartthief_objective = new
			heartthief_objective.owner = owner
			objectives += heartthief_objective
		if(3) // Drink Blood Objective
			var/datum/objective/vampire/gourmand/gourmand_objective = new
			gourmand_objective.owner = owner
			objectives += gourmand_objective

// Taken directly from changeling.dm
/datum/antagonist/vampire/proc/check_blacklisted_species()
	var/mob/living/carbon/carbon_owner = owner.current	//only carbons have dna now, so we have to typecaste
	if(HAS_TRAIT(carbon_owner, TRAIT_NOT_TRANSMORPHIC))
		carbon_owner.set_species(/datum/species/human)
		carbon_owner.fully_replace_character_name(carbon_owner.real_name, carbon_owner.client.prefs.read_character_preference(/datum/preference/name/backup_human))

		for(var/datum/record/crew/record in GLOB.manifest.general)
			if(record.name == carbon_owner.real_name)
				record.species = carbon_owner.dna.species.name
				record.gender = carbon_owner.gender

				//Not using carbon_owner.appearance because it might not update in time at roundstart
				record.character_appearance = get_flat_existing_human_icon(carbon_owner, list(SOUTH, WEST))

/datum/antagonist/vampire/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	var/text = icon2html('icons/vampires/vampiric.dmi', world, "vampire")
	if(IS_VASSAL(examiner) in vassals)
		text += span_cult("<EM>This is, [return_full_name()] your Master!</EM>")
		examine_text += text
	else if(IS_VAMPIRE(examiner) || my_clan?.name == CLAN_NOSFERATU)
		text += span_cult("<EM>[return_full_name()]</EM>")
		examine_text += text

/datum/antagonist/vampire/proc/on_moved(datum/source)
	SIGNAL_HANDLER

	var/mob/living/current = owner?.current
	if(QDELETED(current))
		return

	tracker?.tracking_beacon?.update_position()
