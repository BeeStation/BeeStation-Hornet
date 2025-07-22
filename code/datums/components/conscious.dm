/datum/component/conscious
	/// How much consciousness damage we heal per second
	var/consciousness_heal_rate = 5
	/// Current amount of consciousness damage that we have sustained
	var/damage = 0
	/// Maximum amount of consciousness damage that we can sustain
	var/max_damage = 200
	/// Damage we have taken recently
	var/recent_damage = 0
	/// Time that we are unconscious for without pain
	var/unconscious_time = 0
	/// The point at which we fall unconscious
	var/unconscious_threshold = 100
	/// Time that we are allowed to start healing consciousnses damage
	var/consciousness_heal_time = 0
	/// Are we unconscious?
	var/is_unconscious = FALSE
	/// Are we deaf due to unconsciousness?
	var/is_deaf = FALSE
	/// The client that owns the mob
	var/client/client

/datum/component/conscious/Initialize(...)
	. = ..()
	RegisterSignal(parent, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(associate_with_client))
	RegisterSignal(parent, COMSIG_MOB_LOGOUT, PROC_REF(logout))

/datum/component/conscious/process(delta_time)
	if (consciousness_heal_time > world.time)
		return
	damage = clamp(damage - consciousness_heal_rate * delta_time, 0, max_damage)
	recent_damage = max(recent_damage - consciousness_heal_rate * delta_time * 2, 0)
	if (damage < unconscious_threshold + 20 && is_deaf)
		REMOVE_TRAIT(parent, TRAIT_DEAF, FROM_UNCONSCIOUS)
		is_deaf = FALSE
	// Unconsciousness hud blur
	if(damage + recent_damage)
		var/severity = 0
		switch(damage)
			if(30 to 40)
				severity = 1
			if(40 to 50)
				severity = 2
			if(50 to 60)
				severity = 3
			if(60 to 70)
				severity = 4
			if(70 to 80)
				severity = 5
			if(80 to 90)
				severity = 6
			if(90 to INFINITY)
				severity = 7
		overlay_fullscreen("pain", /atom/movable/screen/fullscreen/oxy, severity)
	else
		clear_fullscreen("pain")
	// While our consciousness value is above 0, we will wince from pain occassionally
	if (damage < unconscious_threshold)
		if (DT_PROB(damage * 0.1, delta_time))
			wince_from_pain(owner)

/datum/component/conscious/proc/associate_with_client(datum/source, client/target)
	client = target

/datum/component/conscious/proc/logout()
	client = null

/datum/component/conscious/proc/wince_from_pain(atom/victim)
	to_chat(client, span_pain(pick(
		"You wince in pain.",
		"You flinch as pain shoots through your body.",
		"You grit your teeth and try to tough out the pain.",
		"You shudder, clutching at your hurting body.",
		"You hiss softly, as the pain flares up.",
		"You recoil as a jolt of pain overcomes your body.",
		"You bite your lip.",
		"You stagger slightly as you feel overcome with pain.",
		"You feel a sharp, stabbing sensation.",
		"You clench your jaw, the pain hurting more and more with every passing minute.",
		"You feel a twinge of pain... probably nothing...",
		"Your body aches.",
		"You feel a surge of pain.",
		"Your feel a pain from inside your body.",
		"Your head hurts.",
		"Your head hurts.",
		"You feel a tiny prick!",
	)))

/// Called when we take damage, damage causes us to wake up faster
/datum/component/conscious/proc/take_regular_damage(atom/victim, amount)

/// Called when consciousness damage should be applied to the owner
/datum/component/conscious/proc/take_consciousness_damage(atom/victim, amount)
	damage = clamp(amount + damage, 0, max_damage)
	recent_damage = clamp(recent_damage + amount, 0, 100)
	// Become unconscious
	if (damage >= unconscious_threshold)
		become_unconscious(victim, client)

/datum/component/conscious/proc/become_unconscious(atom/victim)
	ADD_TRAIT(victim, TRAIT_KNOCKEDOUT, FROM_UNCONSCIOUS)
	ADD_TRAIT(victim, TRAIT_DEAF, FROM_UNCONSCIOUS)
	ADD_VALUE_TRAIT(victim, TRAIT_VALUE_SOUND_SCAPE, FROM_UNCONSCIOUS, SOUND_ENVIRONMENT_DIZZY, SOUND_PRIORITY_UNCONSCIOUS)
	// Stop all playing sounds
	SEND_SOUND(client, sound(null))
	consciousness_heal_time = world.time + 5 SECONDS
	is_unconscious = TRUE
	is_deaf = TRUE

/datum/component/conscious/proc/regain_consciousness(atom/victim)
	REMOVE_TRAIT(victim, TRAIT_KNOCKEDOUT, FROM_UNCONSCIOUS)
	REMOVE_TRAIT(victim, TRAIT_DEAF, FROM_UNCONSCIOUS)
	REMOVE_TRAIT(victim, TRAIT_VALUE_SOUND_SCAPE, FROM_UNCONSCIOUS)
	is_unconscious = FALSE
	is_deaf = FALSE
