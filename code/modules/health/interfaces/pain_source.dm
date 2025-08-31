// Pain level
#define TRAIT_PAIN_LEVEL "pain_level"

/datum/pain_source
	/// The owner of the consciousness datum
	var/mob/living/owner
	/// How much pain are we currently in?
	var/pain

/datum/pain_source/proc/Initialize(mob/living/owner)
	src.owner = owner
	register_signals()

/datum/pain_source/proc/register_signals()
	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(update_stat))

/datum/pain_source/proc/on_life()

/datum/pain_source/proc/update_stat()
	// If we are unconscious, we can't feel pain
	if (owner.stat >= UNCONSCIOUS)
		set_pain_modifier(0, FROM_UNCONSCIOUS)
	else
		set_pain_modifier(1, FROM_UNCONSCIOUS)

/datum/pain_source/proc/update_pain(pain_value)
	pain = pain_value
	update_damage_overlay(pain)
	owner.update_health_hud()
	owner.med_hud_set_health()
	var/consciousness_impact = max(pain - 20, 0)
	var/impact_maximum = 80
	// The more pain we have, the less conscious we are
	var/consciousness_modifier = -min((consciousness_impact / impact_maximum) * owner.consciousness.max_value, owner.consciousness.max_value)
	owner.consciousness.set_consciousness_source(consciousness_modifier, FROM_PAIN_SHOCK)
	if (pain >= 100)
		enter_pain_crit()
	else
		exit_pain_crit()

/datum/pain_source/proc/enter_pain_crit()
	owner.blood.enter_shock(FROM_PAIN_SHOCK)
	to_chat(owner, span_pain(pick(\
		"You collapse from the unbearable pain!",\
		"The pain overwhelms you, and you collapse!",\
		"You fall, barely conscious, the pain completely unbearable.",\
		"The intense pain absorbs your entire body, you feel ready to give up.",\
		"As pain overwhelms your body, your skin goes pale and you collapse."\
	)))

/datum/pain_source/proc/exit_pain_crit()
	owner.blood.exit_shock(FROM_PAIN_SHOCK)

/// Update the damage overlay, pain level between
/// 0: no pain
/// 100: max pain
/datum/pain_source/proc/update_damage_overlay(pain_level)
	if(pain_level)
		var/severity = 0
		switch(pain_level)
			if(5 to 15)
				severity = 1
			if(15 to 30)
				severity = 2
			if(30 to 45)
				severity = 3
			if(45 to 70)
				severity = 4
			if(70 to 85)
				severity = 5
			if(85 to INFINITY)
				severity = 6
		owner.overlay_fullscreen("pain", /atom/movable/screen/fullscreen/brute, severity)
	else
		owner.clear_fullscreen("pain")

/// Set an active pain source that automatically clears after some time
/datum/pain_source/proc/set_pain_source_until(amount, source, time)
	set_pain_source(amount, source, time)
	addtimer(src, CALLBACK(src, PROC_REF(set_pain_source), 0, source), time)

/// Provide a source of consciousness. Without one consciousness will be 0, which is dead.
/// Source: The source of the modifier
/// Amount: The amount of consciousness provided by the source.
/datum/pain_source/proc/set_pain_source(amount, source)
	if (!amount)
		REMOVE_TRAIT(src, TRAIT_PAIN_LEVEL, source)
	else
		ADD_CUMULATIVE_TRAIT(src, TRAIT_PAIN_LEVEL, source, amount)
	update_pain(GET_TRAIT_VALUE(src, TRAIT_PAIN_LEVEL))

/// Set a consciousness modifier.
/// Source: The source of the modifier
/// Amount: The multiplier for the modifier, set to 1 to remove
/datum/pain_source/proc/set_pain_modifier(amount, source)
	if (amount == 1)
		REMOVE_TRAIT(src, TRAIT_PAIN_LEVEL, source)
	else
		ADD_MULTIPLICATIVE_TRAIT(src, TRAIT_PAIN_LEVEL, source, amount)
	update_pain(GET_TRAIT_VALUE(src, TRAIT_PAIN_LEVEL))

/// Add a pain message caused by a specific source
/datum/pain_source/proc/add_pain_message(message, source)

/// Remove all pain messages associated with that source
/datum/pain_source/proc/remove_pain_messages(source)

#undef TRAIT_PAIN_LEVEL
