/datum/component/conscious
	/// How much consciousness damage we heal per second
	var/consciousness_heal_rate = 3
	/// Current amount of consciousness damage that we have sustained
	var/damage = 0
	/// Maximum amount of consciousness damage that we can sustain
	var/max_damage = 150
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
	if (ismob(parent))
		var/mob/mob = parent
		client = mob.client
	RegisterSignal(parent, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(associate_with_client))
	RegisterSignal(parent, COMSIG_MOB_LOGOUT, PROC_REF(logout))
	RegisterSignal(parent, COMSIG_MOB_TAKE_CONSCIOUSNESS_DAMAGE, PROC_REF(take_consciousness_damage))
	START_PROCESSING(SSinjuries, src)

/datum/component/conscious/process(delta_time)
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
		client?.mob.overlay_fullscreen("pain", /atom/movable/screen/fullscreen/oxy, severity)
	else
		client?.mob.clear_fullscreen("pain")
	if (consciousness_heal_time > world.time)
		return
	// Heal consciousness damage
	var/mob/living/living_parent = parent
	damage = clamp(damage - consciousness_heal_rate * delta_time, 0, max_damage)
	recent_damage = max(recent_damage - consciousness_heal_rate * delta_time * 2, 0)
	// Take consciousness damage to match our health
	var/current_damage = min(living_parent.maxHealth - living_parent.health, unconscious_threshold * 0.8)
	if (damage < current_damage)
		var/diff = current_damage - damage
		diff = min(diff, 4)
		take_consciousness_damage(parent, diff, FALSE)
	if (living_parent.stat >= SOFT_CRIT)
		var/probability_bonus = max(0, (current_damage - living_parent.maxHealth) / living_parent.maxHealth) * 10
		if (DT_PROB(10 + probability_bonus, delta_time))
			fall_unconscious(parent, rand(3 SECONDS, 6 SECONDS))
	// Stop being deaf
	if (damage < unconscious_threshold + 20 && is_deaf)
		REMOVE_TRAIT(parent, TRAIT_DEAF, FROM_UNCONSCIOUS)
		living_parent.custom_emote("twitches")
		is_deaf = FALSE
	// While our consciousness value is above 0, we will wince from pain occassionally
	if (damage < unconscious_threshold && world.time > unconscious_time)
		if (DT_PROB(damage * 0.1, delta_time))
			wince_from_pain(parent)
		if (is_unconscious)
			regain_consciousness(parent)

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

/// Called when consciousness damage should be applied to the owner
/datum/component/conscious/proc/take_consciousness_damage(atom/victim, amount, pause_healing = FALSE)
	damage = clamp(amount + damage, 0, max_damage)
	if (pause_healing)
		recent_damage = clamp(recent_damage + amount, 0, 100)
	// Become unconscious
	if (damage >= unconscious_threshold)
		become_unconscious(victim, client)
	if (damage < 0)
		unconscious_time += damage
	if (!is_unconscious && pause_healing)
		consciousness_heal_time = max(world.time + 3 SECONDS, consciousness_heal_time)

/datum/component/conscious/proc/become_unconscious(mob/victim)
	is_unconscious = TRUE
	is_deaf = TRUE
	consciousness_heal_time = max(world.time + 5 SECONDS, consciousness_heal_time)
	victim.custom_emote("passes out")
	damage = min(unconscious_threshold + 20, damage)
	ADD_TRAIT(victim, TRAIT_KNOCKEDOUT, FROM_UNCONSCIOUS)
	ADD_TRAIT(victim, TRAIT_DEAF, FROM_UNCONSCIOUS)
	ADD_VALUE_TRAIT(victim, TRAIT_VALUE_SOUND_SCAPE, FROM_UNCONSCIOUS, SOUND_ENVIRONMENT_DIZZY, SOUND_PRIORITY_UNCONSCIOUS)
	// Stop all playing sounds
	SEND_SOUND(client, sound(null))
	to_chat(victim, span_userdanger("You fall unconscious!"))

/datum/component/conscious/proc/regain_consciousness(atom/victim)
	REMOVE_TRAIT(victim, TRAIT_KNOCKEDOUT, FROM_UNCONSCIOUS)
	REMOVE_TRAIT(victim, TRAIT_DEAF, FROM_UNCONSCIOUS)
	REMOVE_TRAIT(victim, TRAIT_VALUE_SOUND_SCAPE, FROM_UNCONSCIOUS)
	is_unconscious = FALSE
	is_deaf = FALSE

/datum/component/conscious/proc/fall_unconscious(atom/victim, duration)
	unconscious_time = max(unconscious_time, world.time + duration)
	become_unconscious(victim)

/datum/component/conscious/vv_edit_var(var_name, var_value)
	if (var_name == "damage")
		damage = 0
		take_consciousness_damage(parent, var_value)
		return TRUE
	. = ..()
