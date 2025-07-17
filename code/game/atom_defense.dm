/// The essential proc to call when an atom must receive damage of any kind.
/// amount: The amount of damage to be received
/// penetration: The amount of penetration that the damage is applying
/// type: The damage type being dealt
/// flag: Defines a special DAMAGE_ flag, which changes the behaviour of how armour is calculated.
/// hit_direction: The direction that the attack was performed from.
/// sound_effect: Should we play the attack sound effect?
/// zone: Optional bodyzone to be targeted, not all atoms account for this
/atom/proc/deal_damage(amount, penetration, type = BRUTE, flag = DAMAGE_STANDARD, dir = NONE, sound = TRUE, zone = null)
	if(!uses_integrity)
		CRASH("[src] had /atom/proc/apply_damage() called on it without it being a type that has uses_integrity = TRUE!")
	if(QDELETED(src))
		CRASH("[src] taking damage after deletion")
	if(atom_integrity <= 0)
		CRASH("[src] taking damage while having <= 0 integrity")
	if(sound)
		play_attack_sound(amount, type, flag)
	if((resistance_flags & INDESTRUCTIBLE))
		return
	if(flag == DAMAGE_STANDARD && amount < damage_deflection)
		return
	if(amount < DAMAGE_PRECISION)
		return
	run_armour_damage(amount, penetration, type, flag, dir, zone)

/// Convert a damage flag into an armour rating.
/// Does not work for DAMAGE_STANDARD, as the logic is more complex.
/// Output value is between 0 and 100.
/atom/proc/damage_flag_to_armour_rating(damage_flag, zone = null)
	switch (damage_flag)
		// Runs through absorption and blunt independantly
		if (DAMAGE_ACID)
			var/absorption = (100 - get_armor_rating(ARMOUR_ABSORPTION) * 0.5) / 100
			var/blunt = (100 - get_armor_rating(ARMOUR_BLUNT) * 0.5) / 100
			// 0 = 100, 1 = 0
			var/multiplier = absorption * blunt
			return (1 - multiplier) * 100
		// Runs through absorption
		if (DAMAGE_ABSORPTION)
			return get_armor_rating(ARMOUR_ABSORPTION)
		// Runs through absorption and 50% of the heat, 50% of the absorption and 50% of the blunt independantly
		if (DAMAGE_BOMB)
			var/heat = (100 - get_armor_rating(ARMOUR_HEAT) * 0.5) / 100
			var/absorption = (100 - get_armor_rating(ARMOUR_ABSORPTION) * 0.5) / 100
			var/blunt = (100 - get_armor_rating(ARMOUR_BLUNT) * 0.5) / 100
			// 0 = 100, 1 = 0
			var/multiplier = heat * absorption * blunt
			return (1 - multiplier) * 100
		// 50% heat, 50% absorption and 50% blunt independantly.
		// Having 50% in all categories results in 87.5% protection.
		if (DAMAGE_SHOCK)
			var/reflectivity = (100 - get_armor_rating(ARMOUR_REFLECTIVITY) * 0.5) / 100
			var/absorption = (100 - get_armor_rating(ARMOUR_ABSORPTION) * 0.5) / 100
			var/blunt = (100 - get_armor_rating(ARMOUR_BLUNT) * 0.5) / 100
			// 0 = 100, 1 = 0
			var/multiplier = reflectivity * absorption * blunt
			return (1 - multiplier) * 100
		// Runs through 50% of the reflectivity
		if (DAMAGE_ENERGY)
			return get_armor_rating(ARMOUR_REFLECTIVITY) * 0.5
		// Runs through 100% of the heat armour
		if (DAMAGE_FIRE)
			return get_armor_rating(ARMOUR_HEAT)
		// Runs through the average armour between reflectivity and heat, simultaneously
		if (DAMAGE_LASER)
			return get_armor_rating(ARMOUR_REFLECTIVITY) * 0.5 + get_armor_rating(ARMOUR_HEAT) * 0.5
	CRASH("Could not convert damage flag '[damage_flag]' into an armour value as it is incompatible.")

/atom/proc/run_armour_damage(amount, penetration, type = BRUTE, flag = DAMAGE_STANDARD, dir = NONE, zone = null)
	switch (flag)
		// Runs through absorption and blunt independantly
		if (DAMAGE_ACID)
			var/armour_multiplier = (100 - damage_flag_to_armour_rating(flag)) / 100
			var/damage_amount = round(amount * armour_multiplier, DAMAGE_PRECISION)
			if (damage_amount < 0)
				return
			take_direct_damage(damage_amount, type, flag, zone)
		// Runs through absorption
		if (DAMAGE_ABSORPTION)
			var/armour_multiplier = (100 - damage_flag_to_armour_rating(flag)) / 100
			var/damage_amount = round(amount * armour_multiplier, DAMAGE_PRECISION)
			if (damage_amount < 0)
				return
			take_direct_damage(damage_amount, type, flag, zone)
		// Runs through absorption and 50% of the heat, 50% of the absorption and 50% of the blunt independantly
		if (DAMAGE_BOMB)
			var/armour_multiplier = (100 - damage_flag_to_armour_rating(flag)) / 100
			var/damage_amount = round(amount * armour_multiplier, DAMAGE_PRECISION)
			if (damage_amount < 0)
				return
			take_direct_damage(damage_amount, type, flag, zone)
		// Shock damage
		if (DAMAGE_SHOCK)
			var/armour_multiplier = (100 - damage_flag_to_armour_rating(flag)) / 100
			var/damage_amount = round(amount * armour_multiplier, DAMAGE_PRECISION)
			if (damage_amount < 0)
				return
			take_direct_damage(damage_amount, type, flag, zone)
		// Runs through 50% of the reflectivity
		if (DAMAGE_ENERGY)
			var/armour_multiplier = (100 - damage_flag_to_armour_rating(flag)) / 100
			var/damage_amount = round(amount * armour_multiplier, DAMAGE_PRECISION)
			if (damage_amount < 0)
				return
			take_direct_damage(damage_amount, type, flag, zone)
		// Runs through 100% of the heat armour
		if (DAMAGE_FIRE)
			var/armour_multiplier = (100 - damage_flag_to_armour_rating(flag)) / 100
			var/damage_amount = round(amount * armour_multiplier, DAMAGE_PRECISION)
			if (damage_amount < 0)
				return
			take_direct_damage(damage_amount, type, flag, zone)
		// Runs through the average armour between reflectivity and heat, simultaneously
		if (DAMAGE_LASER)
			var/armour_multiplier = (100 - damage_flag_to_armour_rating(flag)) / 100
			var/damage_amount = round(amount * armour_multiplier, DAMAGE_PRECISION)
			if (damage_amount < 0)
				return
			take_direct_damage(damage_amount, type, flag, zone)
		// Standard penetration calculation
		if (DAMAGE_STANDARD)
			var/penetration_rating = get_armor_rating(ARMOUR_PENETRATION)
			// Calculate how much damage is taken as penetration
			// If we have 0 penetration armour, then 100% of damage is always
			// taken as penetration damage.
			// If we have the same penetration armour as the penetration damage,
			// then 100% is absorbed into blunt damage.
			// In between the 2 values (armour rating between 0 and penetration),
			// then we have a linear amount of penetration damage being blocked
			var/penetration_proportion = penetration <= 0 ? 0 : CLAMP01((penetration - penetration_rating) / penetration)
			var/penetration_damage = amount * penetration_proportion
			// Unprotected damage
			take_sharpness_damage(penetration_damage, type, flag, zone, penetration)
			// Protected damage
			var/blunt_damage = amount * (1 - penetration_proportion)
			var/blunt_rating = 100 - (get_armor_rating(ARMOUR_BLUNT) / 100)
			var/absorbed_damage = blunt_damage * (1 - blunt_rating)
			var/taken_damage = blunt_damage * blunt_rating
			absorb_damage_amount(absorbed_damage, type)
			// Blunt damage splits into 50% consciousness and 50% actual damage, if brute
			// stamina and burn damage doesn't result in blunt force trauma
			if (type == BRUTE)
				take_direct_damage(taken_damage * 0.5, type, flag, zone)
				take_direct_damage(taken_damage * 0.5, CONSCIOUSNESS, flag, zone)
			else
				take_direct_damage(taken_damage, type, flag, zone)

/atom/proc/take_sharpness_damage(amount, type, flag = DAMAGE_STANDARD, zone = null, sharpness = 0)
	if (!uses_integrity)
		CRASH("take_direct_damage called on [src.type] not using atom integrity which also hasn't implemented it's own handling.")
	take_direct_damage(amount, type)

/atom/proc/take_direct_damage(amount, type, flag = DAMAGE_STANDARD, zone = null)
	if (!uses_integrity)
		CRASH("take_direct_damage called on [src.type] not using atom integrity which also hasn't implemented it's own handling.")
	var/previous_atom_integrity = atom_integrity

	update_integrity(atom_integrity - amount)

	var/integrity_failure_amount = integrity_failure * max_integrity

	//BREAKING FIRST
	if(integrity_failure && previous_atom_integrity > integrity_failure_amount && atom_integrity <= integrity_failure_amount)
		atom_break(flag)

	//DESTROYING SECOND
	if(atom_integrity <= 0 && previous_atom_integrity > 0)
		atom_destruction(flag)

/// Absorb damage, does nothing by default as this is intended for when
/// your armour is protected something else from an attack (such as when
/// you are wearing armour and that protects a mob)
/atom/proc/absorb_damage_amount(amount, type)
	return

/// Proc for recovering atom_integrity. Returns the amount repaired by
/atom/proc/repair_damage(amount)
	if(amount <= 0) // We only recover here
		return
	var/new_integrity = min(max_integrity, atom_integrity + amount)
	. = new_integrity - atom_integrity

	update_integrity(new_integrity)

	if(integrity_failure && atom_integrity > integrity_failure * max_integrity)
		atom_fix()

/// Handles the integrity of an atom changing. This must be called instead of changing integrity directly.
/atom/proc/update_integrity(new_value)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!uses_integrity)
		CRASH("/atom/proc/update_integrity() was called on [src] when it doesnt use integrity!")
	var/old_value = atom_integrity
	new_value = max(0, new_value)
	if(atom_integrity == new_value)
		return
	atom_integrity = new_value
	SEND_SIGNAL(src, COMSIG_ATOM_INTEGRITY_CHANGED, old_value, new_value)

/// This mostly exists to keep atom_integrity private. Might be useful in the future.
/atom/proc/get_integrity()
	SHOULD_BE_PURE(TRUE)
	return atom_integrity

/atom/proc/get_integrity_ratio()
	SHOULD_BE_PURE(TRUE)
	return (atom_integrity - integrity_failure * max_integrity) / (max_integrity * (1 - integrity_failure))

///the sound played when the atom is damaged.
/atom/proc/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/smash.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

///Called to get the damage that hulks will deal to the atom.
/atom/proc/hulk_damage()
	return 150 //the damage hulks do on punches to this atom, is affected by melee armor

/atom/proc/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, armor_penetration = 0) //used by attack_alien, attack_animal, and attack_slime
	if(!uses_integrity)
		CRASH("unimplemented /atom/proc/attack_generic()!")
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	return deal_damage(damage_amount, armor_penetration, damage_type, damage_flag, get_dir(src, user), sound_effect, zone = ran_zone(user.get_combat_bodyzone()))

/// Called after the atom takes damage and integrity is below integrity_failure level
/atom/proc/atom_break(damage_flag)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_BREAK)

/// Called when integrity is repaired above the breaking point having been broken before
/atom/proc/atom_fix()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_FIX)

///what happens when the atom's integrity reaches zero.
/atom/proc/atom_destruction(damage_flag)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_DESTRUCTION, damage_flag)

///changes max_integrity while retaining current health percentage, returns TRUE if the atom got broken.
/atom/proc/modify_max_integrity(new_max, can_break = TRUE, damage_type = BRUTE)
	if(!uses_integrity)
		CRASH("/atom/proc/modify_max_integrity() was called on [src] when it doesnt use integrity!")
	var/current_integrity = atom_integrity
	var/current_max = max_integrity

	if(current_integrity != 0 && current_max != 0)
		var/percentage = current_integrity / current_max
		current_integrity = max(1, round(percentage * new_max)) //don't destroy it as a result
		atom_integrity = current_integrity

	max_integrity = new_max

	if(can_break && integrity_failure && current_integrity <= integrity_failure * max_integrity)
		atom_break(damage_type)
		return TRUE
	return FALSE
