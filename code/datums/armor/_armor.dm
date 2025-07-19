/// Assosciative list of type -> armor. Used to ensure we always hold a reference to default armor datums
GLOBAL_LIST_INIT(armor_by_type, generate_armor_type_cache())

/proc/generate_armor_type_cache()
	var/list/armor_cache = list()
	for(var/datum/armor/armor_type as anything in subtypesof(/datum/armor))
		armor_type = new armor_type
		armor_cache[armor_type.type] = armor_type
		armor_type.GenerateTag()
	return armor_cache

/**
 * Gets an armor type datum using the given type by formatting it into the expected datum tag
 */
/proc/get_armor_by_type(armor_type)
	var/armor = locate(replacetext("[armor_type]", "/", "-"))
	if(armor)
		return armor
	if(armor_type == /datum/armor)
		CRASH("Attempted to get the base armor type, you probably meant to use /datum/armor/none")
	CRASH("Attempted to get an armor type that did not exist! '[armor_type]'")

/**
 * The armor datum holds information about different types of armor that an atom can have.
 * It also contains logic and helpers for calculating damage and effective damage
 */
/datum/armor
	/// How much penetration resistance the armour has
	/// Sharp damage is converted into blunt based on this, and
	/// then reduced by the blunt resistance amount.
	/// Reduces based on the health proportion of the armour.
	VAR_PROTECTED/penetration = 0
	/// Percentage of blunt damage reduction. 30 means 30%
	/// of incoming blunt damage is fully protected against.
	/// Reduces based on the health proportion of the armour.
	VAR_PROTECTED/blunt = 0
	/// How much is the armour protected from damage that it
	/// absorbs? A value of 50 means that if a user is protected
	/// against 10 damage, then the armour takes 5 damage.
	/// Reflects the underlying strength of the armour and
	/// affects damage taken from acid
	VAR_PROTECTED/absorption = 0
	/// How much does the armour protect against light based
	/// projectiles. Higher values reduce the amount of damage
	/// caused by energy/laser projectiles and give some
	/// chance for those projectiles to be reflected.
	VAR_PROTECTED/reflectivity = 0
	/// Amount of protection from heat based attacks such as
	/// lasers and fire.
	VAR_PROTECTED/heat = 0

/// A version of armor with no protections
/datum/armor/none

/// A version of armor that cannot be modified and will always return itself when attempted to be modified
/datum/armor/immune

/datum/armor/Destroy(force, ...)
	if(!force && tag)
		return QDEL_HINT_LETMELIVE

	// something really wants us gone
	datum_flags &= ~DF_USE_TAG
	tag = null
	return ..()

/datum/armor/GenerateTag()
	..()
	tag = replacetext("[type]", "/", "-")

/datum/armor/vv_edit_var(var_name, var_value)
	return FALSE

/datum/armor/can_vv_mark()
	return FALSE

/datum/armor/vv_get_dropdown()
	SHOULD_CALL_PARENT(FALSE)
	return list("", "MUST MODIFY ARMOR VALUES ON THE PARENT ATOM")

/datum/armor/CanProcCall(procname)
	return FALSE

/// Generate a brand new armor datum with the modifiers given, if ARMOR_ALL is specified only that modifier is used
/datum/armor/proc/generate_new_with_modifiers(list/modifiers)
	var/datum/armor/new_armor = new

	var/all_keys = ARMOR_LIST_ALL
	if(ARMOR_ALL in modifiers)
		var/modifier_all = modifiers[ARMOR_ALL]
		if(!modifier_all)
			return src
		for(var/mod in all_keys)
			new_armor.vars[mod] = vars[mod] + modifier_all
		return new_armor

	for(var/modifier in modifiers)
		if(modifier in all_keys)
			new_armor.vars[modifier] = vars[modifier] + modifiers[modifier]
		else
			stack_trace("Attempt to call generate_new_with_modifiers with illegal modifier '[modifier]'! Ignoring it")
	return new_armor

/datum/armor/immune/generate_new_with_modifiers(list/modifiers)
	return src

/// Generate a brand new armor datum with the multiplier given, if ARMOR_ALL is specified only that modifer is used
/datum/armor/proc/generate_new_with_multipliers(list/multipliers)
	var/datum/armor/new_armor = new

	var/all_keys = ARMOR_LIST_ALL
	if(ARMOR_ALL in multipliers)
		var/multiplier_all = multipliers[ARMOR_ALL]
		if(!multiplier_all)
			return src
		for(var/multiplier in all_keys)
			new_armor.vars[multiplier] = vars[multiplier] * multiplier_all
		return new_armor

	for(var/multiplier in multipliers)
		if(multiplier in all_keys)
			new_armor.vars[multiplier] = vars[multiplier] * multipliers[multiplier]
		else
			stack_trace("Attempt to call generate_new_with_multipliers with illegal multiplier '[multiplier]'! Ignoring it")
	return new_armor

/datum/armor/immune/generate_new_with_multipliers(list/multipliers)
	return src

/// Generate a brand new armor datum with the values given, if a value is not present it carries over
/datum/armor/proc/generate_new_with_specific(list/values)
	var/datum/armor/new_armor = new

	var/all_keys = ARMOR_LIST_ALL
	if(ARMOR_ALL in values)
		var/value_all = values[ARMOR_ALL]
		if(!value_all)
			return src
		for(var/mod in all_keys)
			new_armor.vars[mod] = value_all
		return new_armor

	for(var/armor_rating in all_keys)
		if(armor_rating in values)
			new_armor.vars[armor_rating] = values[armor_rating]
		else
			new_armor.vars[armor_rating] = vars[armor_rating]
	return new_armor

/datum/armor/immune/generate_new_with_specific(list/values)
	return src

/// Gets the rating of armor for the specified rating
/datum/armor/proc/get_rating(rating)
	// its not that I dont trust coders, its just that I don't trust coders
	if(!(rating in ARMOR_LIST_ALL))
		CRASH("Attempted to get a rating '[rating]' that doesnt exist")
	return vars[rating]

/datum/armor/immune/get_rating(rating)
	return 100

/// Converts all the ratings of the armor into a list, optionally inversed
/datum/armor/proc/get_rating_list(inverse = FALSE)
	var/ratings = list()
	for(var/rating in ARMOR_LIST_ALL)
		var/value = vars[rating]
		if(inverse)
			value *= -1
		ratings[rating] = value
	return ratings

/datum/armor/immune/get_rating_list(inverse)
	var/ratings = ..() // get all ratings
	for(var/rating in ratings)
		ratings[rating] = 100 // and set them to 100
	return ratings

/// Returns a new armor datum with the given armor added onto this one
/datum/armor/proc/add_other_armor(datum/armor/other)
	if(ispath(other))
		other = get_armor_by_type(other)
	return generate_new_with_modifiers(other.get_rating_list())

/datum/armor/immune/add_other_armor(datum/armor/other)
	return src

/// Returns a new armor datum with the given armor removed from this one
/datum/armor/proc/subtract_other_armor(datum/armor/other)
	if(ispath(other))
		other = get_armor_by_type(other)
	return generate_new_with_modifiers(other.get_rating_list(inverse = TRUE))

/datum/armor/immune/subtract_other_armor(datum/armor/other)
	return src

/// Checks if any of the armor values are non-zero, so this technically also counts negative armor!
/datum/armor/proc/has_any_armor()
	for(var/rating as anything in ARMOR_LIST_ALL)
		if(vars[rating])
			return TRUE
	return FALSE

/datum/armor/immune/has_any_armor()
	return TRUE

/**
 * Returns the client readable name of an armor type
 *
 * Arguments:
 * * armor_type - The type to convert
 */
/proc/armor_to_protection_name(armor_type)
	switch(armor_type)
		if(ARMOUR_PENETRATION)
			return "PENETRATION"
		if(ARMOUR_BLUNT)
			return "BLUNT"
		if(ARMOUR_ABSORPTION)
			return "ABSORPTION"
		if(ARMOUR_REFLECTIVITY)
			return "REFLECTIVITY"
		if(ARMOUR_HEAT)
			return "HEAT"
	CRASH("Unknown armor type '[armor_type]'")
