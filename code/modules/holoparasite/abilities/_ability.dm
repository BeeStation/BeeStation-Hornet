GLOBAL_LIST_INIT_TYPED(holoparasite_abilities, /datum/holoparasite_ability, init_holoparasite_abilities()) //! A global list of every holoparasite ability type, mapped to an instance of said ability.

/datum/holoparasite_ability
	/// The name of the ability.
	var/name = "ERROR"
	/// A description describing the ability.
	var/desc = "You should not see this!"
	/**
	 * The point cost of the ability.
	 * If this is null (or well, anything that isn't a safe number), then this ability CANNOT be obtained through the usual builder.
	 */
	var/cost
	/// If this is TRUE, then this ability will be hidden from the builder UI.
	var/hidden = FALSE
	/// The font-awesome UI icon that appears in the holoparasite builder tgui interface.
	var/ui_icon
	/// A list of which stats this ability is affected by in some way.
	var/list/thresholds = list()
	/// The 'master' stats used by this ability - either the stats of a holoparasite builder, or of the owning holoparasite.
	var/datum/holoparasite_stats/master_stats
	/// The holoparasite that owns this ability.
	var/mob/living/simple_animal/hostile/holoparasite/owner

/datum/holoparasite_ability/New(datum/holoparasite_stats/master_stats)
	// Convert single-stat format to the multi-stat format.
	// I'm too lazy to just change all the threshold defines to use the new format, and doing so would make the code less readable, so this is the best solution.
	for(var/list/threshold as() in thresholds)
		var/old_stat = threshold["stat"]
		var/old_minimum = threshold["minimum"]
		if(old_stat)
			var/list/converted_stat = list(
				"name" = old_stat
			)
			if(old_minimum)
				converted_stat["minimum"] = old_minimum
			threshold["stats"] = list(converted_stat)
		threshold -= list("stat", "minimum")
	if(master_stats && istype(master_stats))
		src.master_stats = master_stats

/datum/holoparasite_ability/Destroy()
	if(owner)
		remove()
	return ..()

/**
 * Applies the effects of the ability to the owner holoparasite.
 * Note: this should ALWAYS be able to be called multiple times in a row without causing problems!
 */
/datum/holoparasite_ability/proc/apply()
	SHOULD_CALL_PARENT(TRUE)
	register_signals()

/**
 * Removes the effect of the ability from the owner holoparasite.
 */
/datum/holoparasite_ability/proc/remove()
	SHOULD_CALL_PARENT(TRUE)
	unregister_signals()

/**
 * Registers the signals associated with this ability.
 */
/datum/holoparasite_ability/proc/register_signals()
	SHOULD_CALL_PARENT(TRUE)
	unregister_signals()

/**
 * Unregisters the signals associated with this ability.
 */
/datum/holoparasite_ability/proc/unregister_signals()
	SHOULD_CALL_PARENT(TRUE)

/**
 * Determines whether this ability can be bought or not when building a holoparasite.
 */
/datum/holoparasite_ability/proc/can_buy()
	return TRUE

/**
 * A simple proc called after login, to notify the user of any specifics with the ability.
 */
/datum/holoparasite_ability/proc/notify_user()
	return

/datum/holoparasite_ability/proc/ability_ui_data()
	. = list(
		"name" = name,
		"desc" = desc,
		"cost" = cost,
		"thresholds" = thresholds
	)
	if(ui_icon)
		.["icon"] = ui_icon

/proc/init_holoparasite_abilities()
	. = list()
	for(var/ability_path in subtypesof(/datum/holoparasite_ability))
		var/datum/holoparasite_ability/ability = new ability_path
		if(ability.name == "ERROR")
			qdel(ability)
			continue
		.[ability_path] = ability
