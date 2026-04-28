
/**
 * SOUL TAP!
 *
 * Trades 20 max health for a refresh on all of your spells.
 * I was considering making it depend on the cooldowns of your spells, but I want to support "Big spell wizard" with this loadout.
 * The two spells that sound most problematic with this is mindswap and lichdom,
 * but soul tap requires clothes for mindswap and lichdom takes your soul.
 */
/datum/action/spell/tap
	name = "Soul Tap"
	desc = "Fuel your spells using your own soul!"
	button_icon_state = "soultap"

	// I could see why this wouldn't be necromancy, but messing with souls or whatever. Ectomancy?
	school = SCHOOL_NECROMANCY
	cooldown_time = 1 SECONDS
	invocation = "AT ANY COST!"
	invocation_type = INVOCATION_SHOUT
	spell_max_level = 1

	/// The amount of health we take on tap
	var/tap_health_taken = 20

/datum/action/spell/tap/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE

	// We call this here so we can get feedback if they try to cast it when they shouldn't.
	if(!is_valid_spell(owner))
		if(feedback)
			to_chat(owner, ("<span class='warning'>You have no soul to tap into!</span>"))
		return FALSE

	return TRUE

/datum/action/spell/tap/is_valid_spell(mob/user, atom/target)
	return isliving(user) && !HAS_TRAIT(owner, TRAIT_NO_SOUL)

/datum/action/spell/tap/on_cast(mob/living/user, atom/target)
	. = ..()
	user.maxHealth -= tap_health_taken
	user.health = min(user.health, user.maxHealth)

	for(var/datum/action/spell/spell in user.actions)
		spell.reset_spell_cooldown()

	// If the tap took all of our life, we die and lose our soul!
	if(user.maxHealth <= 0)
		to_chat(user, ("<span class='userdanger'>Your weakened soul is completely consumed by the tap!</span>"))
		ADD_TRAIT(user, TRAIT_NO_SOUL, MAGIC_TRAIT)

		user.visible_message(("<span class='danger'>[user] suddenly dies!</span>"), ignored_mobs = user)
		user.death()

	// If the next tap will kill us, give us a heads-up
	else if(user.maxHealth - tap_health_taken <= 0)
		to_chat(user, ("<span class='bolddanger'>Your body feels incredibly drained, and the burning is hard to ignore!</span>"))

	// Otherwise just give them some feedback
	else
		to_chat(user, ("<span class='danger'>Your body feels drained and there is a burning pain in your chest.</span>"))
