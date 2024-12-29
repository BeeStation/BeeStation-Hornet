/datum/antagonist/bloodsucker
	name = "\improper Bloodsucker"
	roundend_category = "bloodsuckers"
	antagpanel_category = "Bloodsucker"
	banning_key = ROLE_BLOODSUCKER
	required_living_playtime = 4
	ui_name = "AntagInfoBloodsucker"
	hijack_speed = 0.5
	var/antag_hud_name = "bloodsucker"
	/// How much blood we have, starting off at default blood levels.
	var/bloodsucker_blood_volume = BLOOD_VOLUME_NORMAL
	/// How much blood we can have at once, increases per level.
	var/max_blood_volume = 600

	// Only created if bloodsucker makes vassals
	var/datum/team/bloodsucker/bloodsucker_team

	var/datum/bloodsucker_clan/my_clan

	// TIMERS //
	///Timer between alerts for Burn messages
	COOLDOWN_DECLARE(bloodsucker_spam_sol_burn)
	///Timer between alerts for Healing messages
	COOLDOWN_DECLARE(bloodsucker_spam_healing)

	///Used for assigning your name
	var/bloodsucker_name
	///Used for assigning your title
	var/bloodsucker_title
	///Used for assigning your reputation
	var/bloodsucker_reputation

	///Amount of Humanity lost
	var/humanity_lost = 0
	///Have we been broken the Masquerade?
	var/broke_masquerade = FALSE
	///How many Masquerade Infractions do we have?
	var/masquerade_infractions = 0
	///Blood required to enter Frenzy
	var/frenzy_threshold = FRENZY_THRESHOLD_ENTER
	///If we are currently in a Frenzy
	var/frenzied = FALSE

	///ALL Powers currently owned
	var/list/datum/action/cooldown/bloodsucker/powers = list()
	///Frenzy Grab Martial art given to Bloodsuckers in a Frenzy
	var/datum/martial_art/frenzygrab/frenzygrab = new

	///Vassals under my control. Periodically remove the dead ones.
	var/list/datum/antagonist/vassal/vassals = list()
	///Special vassals I own, to not have double of the same type.
	var/list/datum/antagonist/vassal/special_vassals = list()

	var/bloodsucker_level = 0
	var/bloodsucker_level_unspent = 0
	var/additional_regen
	var/bloodsucker_regen_rate = 0.3

	// Used for Bloodsucker Objectives
	var/area/bloodsucker_lair_area
	var/obj/structure/closet/crate/coffin
	var/total_blood_drank = 0

	///Blood display HUD
	var/atom/movable/screen/bloodsucker/blood_counter/blood_display
	///Vampire level display HUD
	var/atom/movable/screen/bloodsucker/rank_counter/vamprank_display
	///Sunlight timer HUD
	var/atom/movable/screen/bloodsucker/sunlight_counter/sunlight_display

	/// Static typecache of all bloodsucker powers.
	var/static/list/all_bloodsucker_powers = typecacheof(/datum/action/cooldown/bloodsucker, ignore_root_path = TRUE)
	/// Antagonists that cannot be Vassalized no matter what
	var/static/list/vassal_banned_antags = list(
		/datum/antagonist/bloodsucker,
		/datum/antagonist/changeling,
		/datum/antagonist/cult,
		/datum/antagonist/servant_of_ratvar,
	)
	///Default Bloodsucker traits
	var/static/list/bloodsucker_traits = list(
		TRAIT_NOBREATH,
		TRAIT_SLEEPIMMUNE,
		TRAIT_NOCRITDAMAGE,
		TRAIT_RESISTCOLD,
		TRAIT_RADIMMUNE,
		TRAIT_STABLEHEART,
		TRAIT_NOSOFTCRIT,
		TRAIT_NOHARDCRIT,
		TRAIT_AGEUSIA,
		TRAIT_COLDBLOODED,
		TRAIT_VIRUSIMMUNE,
		TRAIT_TOXIMMUNE,
	)

	var/static/list/torpor_traits = list(
		TRAIT_NODEATH,
		TRAIT_FAKEDEATH,
		TRAIT_DEATHCOMA,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTHIGHPRESSURE,
	)


// Taken from wizard.dm
/datum/antagonist/bloodsucker/proc/create_bloodsucker_team()
	var/static/count = 0
	bloodsucker_team = new(owner)
	bloodsucker_team.name = "Bloodsucker team No.[++count]" // only displayed to admins
	bloodsucker_team.master_bloodsucker = src
	add_antag_hud(ANTAG_HUD_BLOODSUCKER, antag_hud_name, owner.current)

/datum/team/bloodsucker
	name = "bloodsucker team"
	var/datum/antagonist/bloodsucker/master_bloodsucker
/**
 * Apply innate effects is everything given to the mob
 * When a body is tranferred, this is called on the new mob
 * while on_gain is called ONCE per ANTAG, this is called ONCE per BODY.
 */
/datum/antagonist/bloodsucker/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	RegisterSignal(current_mob, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(current_mob, COMSIG_LIVING_LIFE, PROC_REF(LifeTick))
	RegisterSignal(current_mob, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	handle_clown_mutation(current_mob, mob_override ? null : "As a vampiric clown, you are no longer a danger to yourself. Your clownish nature has been subdued by your thirst for blood.")

	add_antag_hud(ANTAG_HUD_BLOODSUCKER, antag_hud_name, current_mob)
	current_mob.faction |= FACTION_BLOODSUCKER

	if(current_mob.hud_used)
		on_hud_created()
	else
		RegisterSignal(current_mob, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))
#ifdef BLOODSUCKER_TESTING
	var/turf/user_loc = get_turf(current_mob)
	new /obj/structure/closet/crate/coffin(user_loc)
	new /obj/structure/bloodsucker/vassalrack(user_loc)
#endif

/**
 * Remove innate effects is everything given to the mob
 * When a body is tranferred, this is called on the old mob.
 * while on_removal is called ONCE per ANTAG, this is called ONCE per BODY.
 */
/datum/antagonist/bloodsucker/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	UnregisterSignal(current_mob, list(COMSIG_LIVING_LIFE, COMSIG_PARENT_EXAMINE, COMSIG_LIVING_DEATH))
	handle_clown_mutation(current_mob, removing = FALSE)

	if(current_mob.hud_used)
		var/datum/hud/hud_used = current_mob.hud_used
		hud_used.infodisplay -= blood_display
		hud_used.infodisplay -= vamprank_display
		hud_used.infodisplay -= sunlight_display
		QDEL_NULL(blood_display)
		QDEL_NULL(vamprank_display)
		QDEL_NULL(sunlight_display)

	remove_antag_hud(ANTAG_HUD_BLOODSUCKER, current_mob)
	current_mob.faction -= FACTION_BLOODSUCKER

/datum/antagonist/bloodsucker/proc/on_hud_created(datum/source)
	SIGNAL_HANDLER
	var/datum/hud/bloodsucker_hud = owner.current.hud_used

	blood_display = new /atom/movable/screen/bloodsucker/blood_counter()
	blood_display.hud = bloodsucker_hud
	bloodsucker_hud.infodisplay += blood_display

	vamprank_display = new /atom/movable/screen/bloodsucker/rank_counter()
	vamprank_display.hud = bloodsucker_hud
	bloodsucker_hud.infodisplay += vamprank_display

	sunlight_display = new /atom/movable/screen/bloodsucker/sunlight_counter()
	sunlight_display.hud = bloodsucker_hud
	bloodsucker_hud.infodisplay += sunlight_display

	bloodsucker_hud.show_hud(bloodsucker_hud.hud_version)
	UnregisterSignal(owner.current, COMSIG_MOB_HUD_CREATED)

/datum/antagonist/bloodsucker/get_admin_commands()
	. = ..()
	.["Give Level"] = CALLBACK(src, PROC_REF(RankUp))
	if(bloodsucker_level_unspent > 0)
		.["Remove Level"] = CALLBACK(src, PROC_REF(RankDown))

	if(broke_masquerade)
		.["Fix Masquerade"] = CALLBACK(src, PROC_REF(fix_masquerade))
	else
		.["Break Masquerade"] = CALLBACK(src, PROC_REF(break_masquerade))

	if(my_clan)
		.["Remove Clan"] = CALLBACK(src, PROC_REF(remove_clan))
	else
		.["Add Clan"] = CALLBACK(src, PROC_REF(admin_set_clan))

///Called when you get the antag datum, called only ONCE per antagonist.
/datum/antagonist/bloodsucker/on_gain()
	RegisterSignal(SSsunlight, COMSIG_SOL_RANKUP_BLOODSUCKERS, PROC_REF(sol_rank_up))
	RegisterSignal(SSsunlight, COMSIG_SOL_NEAR_START, PROC_REF(sol_near_start))
	RegisterSignal(SSsunlight, COMSIG_SOL_END, PROC_REF(on_sol_end))
	RegisterSignal(SSsunlight, COMSIG_SOL_RISE_TICK, PROC_REF(handle_sol))
	RegisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN, PROC_REF(give_warning))

	if(IS_FAVORITE_VASSAL(owner.current)) // Vassals shouldnt be getting the same benefits as Bloodsuckers.
		bloodsucker_level_unspent = 0
		show_in_roundend = FALSE
	else
		// Start Sunlight if first Bloodsucker
		check_start_sunlight()
		// Name and Titles
		SelectFirstName()
		SelectTitle(am_fledgling = TRUE)
		SelectReputation(am_fledgling = TRUE)
		// Objectives
		forge_bloodsucker_objectives()

	. = ..()
	// Assign Powers
	give_starting_powers()
	assign_starting_stats()

/// Called by the remove_antag_datum() and remove_all_antag_datums() mind procs for the antag datum to handle its own removal and deletion.
/datum/antagonist/bloodsucker/on_removal()
	UnregisterSignal(SSsunlight, list(COMSIG_SOL_RANKUP_BLOODSUCKERS, COMSIG_SOL_NEAR_START, COMSIG_SOL_END, COMSIG_SOL_RISE_TICK, COMSIG_SOL_WARNING_GIVEN))
	clear_powers_and_stats()
	check_cancel_sunlight() //check if sunlight should end
	//Remove Language
	owner.current.remove_language(/datum/language/vampiric)
	return ..()

/datum/antagonist/bloodsucker/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	for(var/datum/action/cooldown/bloodsucker/all_powers as anything in powers)
		if(old_body)
			all_powers.Remove(old_body)
		all_powers.Grant(new_body)

	var/mob/living/carbon/human/old_body_human = old_body
	if(ishuman(old_body_human))
		old_body_human.dna.species.punchdamage -= 2

	var/mob/living/carbon/human/user = owner.current
	if(ishuman(owner.current))
		var/datum/species/user_species = user.dna.species
		user_species.species_traits += TRAIT_DRINKSBLOOD
		user_species.punchdamage += 2

	//Give Bloodsucker Traits
	old_body?.remove_traits(bloodsucker_traits, BLOODSUCKER_TRAIT)
	new_body.add_traits(bloodsucker_traits, BLOODSUCKER_TRAIT)

/datum/antagonist/bloodsucker/greet()
	. = ..()
	var/fullname = return_full_name()
	to_chat(owner, "<span class='userdanger'>You are [fullname], a strain of vampire known as a Bloodsucker!</span>")
	owner.announce_objectives()
	if(bloodsucker_level_unspent >= 1)
		to_chat(owner, "<span class='announce'>As a latejoin, you have [bloodsucker_level_unspent] bonus Ranks, entering your claimed coffin allows you to spend a Rank.</span>")
	owner.current.playsound_local(null, 'sound/bloodsuckers/BloodsuckerAlert.ogg', 100, FALSE, pressure_affected = FALSE)
	antag_memory += "Although you were born a mortal, in undeath you earned the name <b>[fullname]</b>.<br>"

/datum/antagonist/bloodsucker/farewell()
	to_chat(owner.current, "<span class='userdanger'><FONT size = 3>With a snap, your curse has ended. You are no longer a Bloodsucker. You live once more!</FONT></span>")
	// Refill with Blood so they don't instantly die.
	if(!HAS_TRAIT(owner.current, TRAIT_NO_BLOOD))
		owner.current.blood_volume = max(owner.current.blood_volume, BLOOD_VOLUME_NORMAL)

// Called when using admin tools to give antag status
/datum/antagonist/bloodsucker/admin_add(datum/mind/new_owner, mob/admin)
	var/levels = input("How many unspent Ranks would you like [new_owner] to have?","Bloodsucker Rank", bloodsucker_level_unspent) as null | num
	var/msg = " made [key_name_admin(new_owner)] into \a [name]"
	if(levels > 0)
		bloodsucker_level_unspent = levels
		msg += " with [levels] extra unspent Ranks."
	message_admins("[key_name_admin(usr)][msg]")
	log_admin("[key_name(usr)][msg]")
	new_owner.add_antag_datum(src)

/datum/antagonist/bloodsucker/ui_static_data(mob/user)
	var/list/data = list()
	//we don't need to update this that much.
	data["in_clan"] = !!my_clan
	var/list/clan_data = list()
	if(my_clan)
		clan_data["clan_name"] = my_clan.name
		clan_data["clan_description"] = my_clan.description
		clan_data["clan_icon"] = my_clan.join_icon_state

	data["clan"] += list(clan_data)

	for(var/datum/action/cooldown/bloodsucker/power as anything in powers)
		var/list/power_data = list()

		power_data["power_name"] = power.name
		power_data["power_explanation"] = power.power_explanation
		power_data["power_icon"] = power.button_icon_state

		data["power"] += list(power_data)

	return data + ..()

/datum/antagonist/bloodsucker/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("join_clan")
			if(my_clan)
				return
			assign_clan_and_bane()
			ui.send_full_update(force = TRUE)
			return

/datum/antagonist/bloodsucker/roundend_report()
	var/list/report = list()

	// Vamp name
	report += "<br><span class='header'><b>\[[return_full_name()]\]</b></span>"
	report += printplayer(owner)
	if(my_clan)
		report += "They were part of the <b>[my_clan.name]</b>!"

	// Default Report
	var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(objective.name == "Optional Objective")
				continue
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	// Now list their vassals
	if(vassals.len)
		report += "<span class='header'>Their Vassals were...</span>"
		for(var/datum/antagonist/vassal/all_vassals as anything in vassals)
			if(!all_vassals.owner)
				continue
			var/list/vassal_report = list()
			vassal_report += "<b>[all_vassals.owner.name]</b>"

			if(all_vassals.owner.assigned_role)
				vassal_report += " the [all_vassals.owner.assigned_role]"
			if(IS_FAVORITE_VASSAL(all_vassals.owner.current))
				vassal_report += " and was the <b>Favorite Vassal</b>"
			else if(IS_REVENGE_VASSAL(all_vassals.owner.current))
				vassal_report += " and was the <b>Revenge Vassal</b>"
			report += vassal_report.Join()

	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")

/datum/antagonist/bloodsucker/proc/give_starting_powers()
	for(var/datum/action/cooldown/bloodsucker/all_powers as anything in all_bloodsucker_powers)
		if(!(initial(all_powers.purchase_flags) & BLOODSUCKER_DEFAULT_POWER))
			continue
		BuyPower(new all_powers)

/datum/antagonist/bloodsucker/proc/assign_starting_stats()
	var/mob/living/carbon/human/user = owner.current

	//Traits: Species
	if(ishuman(user))
		var/datum/species/user_species = user.dna.species
		user_species.species_traits += TRAIT_DRINKSBLOOD
		user_species.punchdamage += 2
		user.dna?.remove_all_mutations()
	//Give Bloodsucker Traits
	user.add_traits(bloodsucker_traits, BLOODSUCKER_TRAIT)
	//Clear Addictions
	user.reagents.addiction_list = new()
	owner.remove_quirk(/datum/quirk/junkie)
	owner.remove_quirk(/datum/quirk/junkie/smoker)
	//No Skittish "People" allowed
	if(HAS_TRAIT(user, TRAIT_SKITTISH))
		REMOVE_TRAIT(user, TRAIT_SKITTISH, ROUNDSTART_TRAIT)
	// Tongue & Language
	user.grant_all_languages(FALSE, FALSE, TRUE)
	user.grant_language(/datum/language/vampiric)
	/// Clear Disabilities & Organs
	heal_vampire_organs()

/**
 * ##clear_power_and_stats()
 *
 * Removes all Bloodsucker related Powers/Stats changes, setting them back to pre-Bloodsucker
 * Order of steps and reason why:
 * Remove clan - Clans like Nosferatu give Powers on removal, we have to make sure this is given before removing Powers.
 * Powers - Remove all Powers, so things like Masquerade are off.
 * Species traits, Traits, MaxHealth, Language - Misc stuff, has no priority.
 * Organs - At the bottom to ensure everything that changes them has reverted themselves already.
 * Update Sight - Done after Eyes are regenerated.
 */
/datum/antagonist/bloodsucker/proc/clear_powers_and_stats()
	var/mob/living/carbon/user = owner.current

	// Remove clan first
	if(my_clan)
		QDEL_NULL(my_clan)
	// Powers
	for(var/datum/action/cooldown/bloodsucker/all_powers as anything in powers)
		RemovePower(all_powers)
	/// Stats
	if(ishuman(owner.current))
		//var/mob/living/carbon/human/user = owner.current
		var/datum/species/user_species = user.dna.species
		user_species.species_traits -= TRAIT_DRINKSBLOOD
	// Remove all bloodsucker traits
	user.remove_traits(bloodsucker_traits, BLOODSUCKER_TRAIT)
	// Update Health
	owner.current.setMaxHealth(initial(owner.current.maxHealth))
	// Language
	owner.current.remove_language(/datum/language/vampiric)
	// Heart
	var/obj/item/organ/heart/newheart = owner.current.getorganslot(ORGAN_SLOT_HEART)
	newheart?.beating = initial(newheart.beating)
	// Eyes
	var/obj/item/organ/eyes/user_eyes = user.getorganslot(ORGAN_SLOT_EYES)
	user_eyes?.flash_protect = initial(user_eyes.flash_protect)
	user_eyes?.sight_flags = initial(user_eyes.sight_flags)
	user_eyes?.see_in_dark = NIGHTVISION_FOV_RANGE
	user_eyes?.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	user.update_sight()

/datum/antagonist/bloodsucker/proc/claim_coffin(obj/structure/closet/crate/claimed, area/current_area)
	// ALREADY CLAIMED
	if(claimed.resident)
		if(claimed.resident == owner.current)
			to_chat(owner, "This is your [src].")
		else
			to_chat(owner, "This [src] has already been claimed by another.")
		return FALSE
	if(!(GLOB.the_station_areas.Find(current_area.type)))
		claimed.balloon_alert(owner.current, "not part of station!")
		return
	// This is my Lair
	coffin = claimed
	bloodsucker_lair_area = current_area
	if(!(/datum/crafting_recipe/vassalrack in owner?.learned_recipes))
		owner.teach_crafting_recipe(/datum/crafting_recipe/vassalrack)
		owner.teach_crafting_recipe(/datum/crafting_recipe/candelabrum)
		owner.teach_crafting_recipe(/datum/crafting_recipe/bloodthrone)
		owner.teach_crafting_recipe(/datum/crafting_recipe/meatcoffin)
		owner.current.balloon_alert(owner.current, "new recipes learned!")
	to_chat(owner, "<span class='userdanger'>You have claimed the [claimed] as your place of immortal rest! Your lair is now [bloodsucker_lair_area].</span>")
	to_chat(owner, "<span class='announce'>Bloodsucker Tip: Find new lair recipes in the Structures tab of the <i>Crafting Menu</i>, including the <i>Persuasion Rack</i> for converting crew into Vassals.</span>")
	return TRUE

/// Name shown on antag list
/datum/antagonist/bloodsucker/antag_listing_name()
	return ..() + "([return_full_name()])"

/// Whatever interesting things happened to the antag admins should know about
/// Include additional information about antag in this part
/datum/antagonist/bloodsucker/antag_listing_status()
	if(owner && !considered_alive(owner))
		return "<font color=red>Final Death</font>"
	return ..()

/datum/antagonist/bloodsucker/proc/forge_bloodsucker_objectives()
	// Claim a Lair Objective
	var/datum/objective/bloodsucker/lair/lair_objective = new
	lair_objective.owner = owner
	objectives += lair_objective
	// Survive Objective
	var/datum/objective/survive/bloodsucker/survive_objective = new
	survive_objective.owner = owner
	objectives += survive_objective

	// Objective 1: Vassalize a Head/Command, or a specific target
	switch(rand(1, 3))
		if(1) // Conversion Objective
			var/datum/objective/bloodsucker/conversion/chosen_subtype = pick(subtypesof(/datum/objective/bloodsucker/conversion))
			var/datum/objective/bloodsucker/conversion/conversion_objective = new chosen_subtype
			conversion_objective.owner = owner
			conversion_objective.name = "Optional Objective"
			objectives += conversion_objective
		if(2) // Heart Thief Objective
			var/datum/objective/bloodsucker/heartthief/heartthief_objective = new
			heartthief_objective.owner = owner
			heartthief_objective.name = "Optional Objective"
			objectives += heartthief_objective
		if(3) // Drink Blood Objective
			var/datum/objective/bloodsucker/gourmand/gourmand_objective = new
			gourmand_objective.owner = owner
			gourmand_objective.name = "Optional Objective"
			objectives += gourmand_objective

// For the malkavian clan final death
/datum/antagonist/shaded_bloodsucker
	name = "\improper Shaded Bloodsucker"
	antagpanel_category = "Bloodsucker"
	show_in_roundend = FALSE
	banning_key = ROLE_BLOODSUCKER

/datum/antagonist/shaded_bloodsucker/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	add_antag_hud(ANTAG_HUD_BLOODSUCKER, "bloodsucker", current_mob)

/datum/antagonist/shaded_bloodsucker/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	remove_antag_hud(ANTAG_HUD_BLOODSUCKER, current_mob)
