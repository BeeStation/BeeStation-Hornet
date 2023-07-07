/datum/holoparasite_stats
	var/damage = 1
	var/defense = 1
	var/speed = 1
	var/potential = 1
	var/range = 1
	var/max_level = 5
	/// The (optional) major ability used by this holoparasite.
	var/datum/holoparasite_ability/major/ability
	/// The weapon ability used by this holoparasite to attack.
	var/datum/holoparasite_ability/weapon/weapon = new /datum/holoparasite_ability/weapon/punch
	/// Any minor abilities used by this holoparasite.
	var/list/datum/holoparasite_ability/lesser/lesser_abilities = list()
	/// The last holoparasite that these stats were applied/removed from.
	var/mob/living/simple_animal/hostile/holoparasite/last_holopara

/datum/holoparasite_stats/Destroy()
	remove()
	if(ability)
		QDEL_NULL(ability)
	QDEL_LIST(lesser_abilities)
	QDEL_NULL(weapon)
	return ..()

/datum/holoparasite_stats/proc/apply(mob/living/simple_animal/hostile/holoparasite/holopara)
	holopara = holopara || last_holopara
	if(!istype(holopara))
		return
	last_holopara = holopara
	holopara.range = range * 2
	var/armor = clamp((max(6 - defense, 1) / 2.5) / 2, 0.25, 1)
	holopara.damage_coeff = list(BRUTE = armor, BURN = armor, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	holopara.set_varspeed(-clamp(speed / 5, 0.2, 1))
	if(ability)
		ability.master_stats = src
		ability.owner = holopara
		ability.apply()
	for(var/datum/holoparasite_ability/lesser/lability as() in lesser_abilities)
		lability.master_stats = src
		lability.owner = holopara
		lability.apply()
	weapon.master_stats = src
	weapon.owner = holopara
	weapon.apply()
	holopara.recreate_hud()
	SEND_SIGNAL(src, COMSIG_HOLOPARA_STATS_APPLY, holopara)

/datum/holoparasite_stats/proc/remove(mob/living/simple_animal/hostile/holoparasite/holopara)
	holopara = holopara || last_holopara
	if(!istype(holopara))
		return
	last_holopara = holopara
	holopara.range = initial(holopara.range)
	holopara.ranged_cooldown_time = initial(holopara.ranged_cooldown_time)
	holopara.melee_damage = initial(holopara.melee_damage)
	holopara.obj_damage = initial(holopara.obj_damage)
	holopara.damage_coeff = initial(holopara.damage_coeff)
	holopara.environment_smash = initial(holopara.environment_smash)
	holopara.set_varspeed(initial(holopara.speed))
	if(ability)
		ability.remove()
	for(var/datum/holoparasite_ability/lesser/lability as() in lesser_abilities)
		lability.remove()
	weapon.remove()
	holopara.recreate_hud()
	SEND_SIGNAL(src, COMSIG_HOLOPARA_STATS_REMOVE, holopara)
	last_holopara = null

/datum/holoparasite_stats/proc/refresh(mob/living/simple_animal/hostile/holoparasite/holopara)
	remove(holopara)
	apply(holopara)

/datum/holoparasite_stats/proc/randomize(points = 15)
	// Reset all stats and abilities.
	damage = 1
	defense = 1
	speed = 1
	potential = 1
	range = 1
	if(ability)
		QDEL_NULL(ability)
	QDEL_NULL(weapon)
	QDEL_LIST(lesser_abilities)
	// 80% chance to pick a major ability.
	if(prob(80))
		var/list/possible_abilities = list()
		for(var/ability_path in subtypesof(/datum/holoparasite_ability/major))
			var/datum/holoparasite_ability/major/ability = GLOB.holoparasite_abilities[ability_path]
			if(ability && !ability.hidden && ability.cost < (points - 1))
				possible_abilities += ability
		if(length(possible_abilities))
			set_major_ability(pick(possible_abilities))
			points -= ability.cost
	// If major ability has a forced weapon, well, force it.
	if(ability?.forced_weapon)
		weapon = new ability.forced_weapon
	else
		// 70% chance for weapon to be punch.
		var/weapon_path = /datum/holoparasite_ability/weapon/punch
		if(prob(30))
			// 30% chance to pick a random non-punch, non-hidden weapon.
			var/list/possible_abilities = list()
			for(var/ability_path in subtypesof(/datum/holoparasite_ability/weapon) - weapon_path)
				var/datum/holoparasite_ability/weapon/weapon_ability = GLOB.holoparasite_abilities[ability_path]
				if(weapon_ability && !weapon_ability.hidden && weapon_ability.cost < (points - 1))
					possible_abilities += weapon_ability
			if(length(possible_abilities))
				weapon_path = pick(possible_abilities)
		set_weapon(weapon_path)
	points -= weapon.cost
	// 25% chance to pick a random lesser ability.
	if(prob(25))
		var/list/possible_abilities = list()
		for(var/ability_path in subtypesof(/datum/holoparasite_ability/lesser))
			var/datum/holoparasite_ability/lesser/ability = GLOB.holoparasite_abilities[ability_path]
			if(ability && !ability.hidden && ability.cost < (points - 1))
				possible_abilities += ability
		if(length(possible_abilities))
			var/datum/holoparasite_ability/lesser/l_ability = add_lesser_ability(pick(possible_abilities))
			points -= l_ability
	// Randomize stats until they're either all maxed out, or we run out of points.
	var/list/stats = list("damage", "defense", "speed", "potential", "range")
	while(min(points, length(stats)) > 0)
		points--
		switch(pick(stats))
			if("damage")
				damage++
				if(damage >= 5)
					stats -= "damage"
			if("defense")
				defense++
				if(defense >= 5)
					stats -= "defense"
			if("speed")
				speed++
				if(speed >= 5)
					stats -= "speed"
			if("potential")
				potential++
				if(potential >= 5)
					stats -= "potential"
			if("range")
				range++
				if(range >= 5)
					stats -= "range"

/**
 * Sets the major ability of this holoparasite to an instance of the given typepath.
 */
/datum/holoparasite_stats/proc/set_major_ability(typepath_or_instance)
	var/datum/holoparasite_ability/major/old_ability = ability
	if(ispath(typepath_or_instance, /datum/holoparasite_ability/major))
		. = ability = new typepath_or_instance(src)
	else if(istype(typepath_or_instance, /datum/holoparasite_ability/major))
		. = ability = typepath_or_instance
		if(ability.owner)
			ability.remove(ability.owner)
		ability.master_stats = src
	else
		CRASH("Attempted to set a major ability to a holoparasite with an invalid typepath or instance: [typepath_or_instance]")
	SEND_SIGNAL(src, COMSIG_HOLOPARA_STATS_SET_MAJOR_ABILITY, old_ability, ability)
	if(old_ability)
		qdel(old_ability)

/**
 * Checks to see if a holoparasite has a minor ability matching the given typepath.
 */
/datum/holoparasite_stats/proc/has_lesser_ability(typepath_or_instance)
	if(ispath(typepath_or_instance, /datum/holoparasite_ability/lesser))
		return locate(typepath_or_instance) in lesser_abilities
	else if(istype(typepath_or_instance, /datum/holoparasite_ability/lesser))
		var/datum/holoparasite_ability/lesser/ability_instance = typepath_or_instance
		return locate(ability_instance.type) in lesser_abilities

/**
 * Adds a minor ability to this holoparasite.
 */
/datum/holoparasite_stats/proc/add_lesser_ability(typepath_or_instance)
	var/datum/holoparasite_ability/lesser/existing_ability = has_lesser_ability(typepath_or_instance)
	if(existing_ability)
		return existing_ability
	var/datum/holoparasite_ability/lesser/ability
	if(ispath(typepath_or_instance, /datum/holoparasite_ability/lesser))
		. = ability = new typepath_or_instance(src)
	else if(istype(typepath_or_instance, /datum/holoparasite_ability/lesser))
		. = ability = typepath_or_instance
		if(ability.owner)
			ability.remove(ability.owner)
		ability.master_stats = src
	else
		CRASH("Attempted to add a minor ability to a holoparasite with an invalid typepath or instance: [typepath_or_instance]")
	lesser_abilities += ability
	SEND_SIGNAL(src, COMSIG_HOLOPARA_STATS_ADD_LESSER_ABILITY, ability)

/**
 * Removes a minor ability from this holoparasite.
 */
/datum/holoparasite_stats/proc/take_lesser_ability(typepath_or_instance)
	var/datum/holoparasite_ability/lesser/lesser_ability = has_lesser_ability(typepath_or_instance)
	if(!lesser_ability)
		return
	lesser_abilities -= lesser_ability
	SEND_SIGNAL(src, COMSIG_HOLOPARA_STATS_TAKE_LESSER_ABILITY, lesser_ability)
	qdel(lesser_ability)

/**
 * Sets the weapon ability of this holoparasite to an instance of the given typepath.
 */
/datum/holoparasite_stats/proc/set_weapon(typepath_or_instance)
	var/datum/holoparasite_ability/weapon/old_weapon = weapon
	var/datum/holoparasite_ability/weapon/new_weapon
	if(ispath(typepath_or_instance, /datum/holoparasite_ability/weapon))
		new_weapon = new typepath_or_instance(src)
	else if(istype(typepath_or_instance, /datum/holoparasite_ability/weapon))
		new_weapon = typepath_or_instance
		if(new_weapon.owner)
			new_weapon.remove(new_weapon.owner)
		new_weapon.master_stats = src
	else
		CRASH("Attempted to set a weapon to a holoparasite with an invalid typepath or instance: [typepath_or_instance]")
	. = weapon = new_weapon
	SEND_SIGNAL(src, COMSIG_HOLOPARA_STATS_SET_WEAPON, old_weapon, weapon)
	if(old_weapon)
		qdel(old_weapon)

/**
 * Ensure things are properly updated whenever an admin VVs stats.
 */
/datum/holoparasite_stats/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, last_holopara))
		return FALSE
	switch(var_name)
		if(NAMEOF(src, damage), NAMEOF(src, defense), NAMEOF(src, speed), NAMEOF(src, potential), NAMEOF(src, range))
			if(!isnum_safe(var_value))
				message_admins("[ADMIN_LOOKUPFLW(usr)] attempted to set an invalid stat ([var_value]) for the holoparasite stats of [ADMIN_LOOKUPFLW(last_holopara)].")
				log_admin("[key_name_admin(usr)] attempted to set an invalid stat ([var_value]) for the holoparasite stats of [key_name_admin(last_holopara)].")
				return FALSE
			vars[var_name] = clamp(var_value, 1, max_level)
			refresh()
			datum_flags |= DF_VAR_EDITED
			return TRUE
		if(NAMEOF(src, weapon))
			if(!istype(var_value, /datum/holoparasite_ability/weapon) && !ispath(var_value, /datum/holoparasite_ability/weapon))
				message_admins("[ADMIN_LOOKUPFLW(usr)] attempted to set an invalid weapon for the holoparasite stats of [ADMIN_LOOKUPFLW(last_holopara)].")
				log_admin("[key_name_admin(usr)] attempted to set an invalid weapon for the holoparasite stats of [key_name_admin(last_holopara)].")
				return FALSE
			var/datum/holoparasite_ability/weapon/new_weapon = set_weapon(var_value)
			message_admins("[ADMIN_LOOKUPFLW(usr)] set the weapon of [ADMIN_LOOKUPFLW(last_holopara)] to [new_weapon.type].")
			log_admin("[key_name_admin(usr)] set the weapon of [key_name_admin(last_holopara)] to [new_weapon.type].")
			refresh()
			datum_flags |= DF_VAR_EDITED
			return TRUE
		if(NAMEOF(src, ability))
			if(ability)
				QDEL_NULL(ability)
			if(isnull(var_value))
				message_admins("[ADMIN_LOOKUPFLW(usr)] deleted the major ability of [ADMIN_LOOKUPFLW(last_holopara)].")
				log_admin("[key_name_admin(usr)] deleted the major ability of [key_name_admin(last_holopara)].")
			else
				var/datum/holoparasite_ability/major/new_ability = set_major_ability(var_value)
				message_admins("[ADMIN_LOOKUPFLW(usr)] set the major ability of [ADMIN_LOOKUPFLW(last_holopara)] to [new_ability.type].")
				log_admin("[key_name_admin(usr)] set the major ability of [key_name_admin(last_holopara)] to [new_ability.type].")
			refresh()
			datum_flags |= DF_VAR_EDITED
			return TRUE
		if(NAMEOF(src, lesser_abilities))
			QDEL_LIST(lesser_abilities)
			if(isnull(var_value) || !length(var_value))
				message_admins("[ADMIN_LOOKUPFLW(usr)] cleared the minor abilities of [ADMIN_LOOKUPFLW(last_holopara)].")
				log_admin("[key_name_admin(usr)] cleared the minor abilities of [key_name_admin(last_holopara)].")
			else
				var/list/new_ability_types = list()
				var/list/abilities = var_value
				if(!islist(abilities))
					abilities = list(abilities)
				for(var/supposed_ability in abilities)
					var/datum/holoparasite_ability/lesser/new_ability = add_lesser_ability(supposed_ability)
					new_ability_types += "[new_ability.type]"
				var/english_abilities = english_list(new_ability_types)
				message_admins("[ADMIN_LOOKUPFLW(usr)] added the following minor abilities to [ADMIN_LOOKUPFLW(last_holopara)]: [english_abilities].")
				log_admin("[key_name_admin(usr)] added the following minor abilities to [key_name_admin(last_holopara)]: [english_abilities].")
			refresh()
			datum_flags |= DF_VAR_EDITED
			return TRUE
	return ..()

/**
 * Returns a quick n' dirty list of the stats and abilities.
 */
/datum/holoparasite_stats/proc/tldr()
	var/list/parts = list(
		"Damage [damage]",
		"Defense [defense]",
		"Speed [speed]",
		"Potential [potential]",
		"Range [range]"
	)
	if(!weapon.hidden)
		parts += "(Weapon) [weapon.name]"
	if(ability && !ability.hidden)
		parts += "(Ability) [ability.name]"
	for(var/datum/holoparasite_ability/lesser/ability as() in lesser_abilities)
		if(ability.hidden)
			continue
		parts += "(L.Ability) [ability.name]"
	return english_list(parts)
