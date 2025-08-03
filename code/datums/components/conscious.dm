/// How much pain moves towards the damage amount per second by
#define PAIN_DELTA 2

/datum/component/conscious
	/// How much consciousness damage we heal per second
	var/consciousness_heal_rate = 3
	/// The current amount of pain that we are feeling, slowly
	/// moves towards the amount of damage that we have.
	var/pain = 0
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
	var/mob/living/living_parent = parent
	if (consciousness_heal_time > world.time || living_parent.stat >= HARD_CRIT)
		return
	if (IS_IN_STASIS(living_parent))
		return
	// Heal consciousness damage
	damage = clamp(damage - consciousness_heal_rate * delta_time, 0, max_damage)
	pain = clamp(pain + clamp(damage - pain, -PAIN_DELTA * delta_time, PAIN_DELTA * delta_time), 0, 100)
	update_pain_overlay()
	// Take consciousness damage to match our health
	var/current_damage = min(max(living_parent.maxHealth - living_parent.health - 40, 0) * (living_parent.maxHealth / (living_parent.maxHealth - 40)), unconscious_threshold * 0.8)
	if (damage < current_damage)
		var/diff = current_damage - damage
		diff = min(diff, 4)
		take_consciousness_damage(parent, diff, FALSE)
	// Stop being deaf
	if (damage < unconscious_threshold + 10 && is_deaf)
		REMOVE_TRAIT(parent, TRAIT_DEAF, FROM_UNCONSCIOUS)
		is_deaf = FALSE
		if (living_parent.stat <= SOFT_CRIT)
			living_parent.custom_emote("twitches")
	// While our consciousness value is above 0, we will wince from pain occassionally
	if (damage < unconscious_threshold && world.time > unconscious_time)
		if (DT_PROB(pain * 0.15, delta_time))
			wince_from_pain(parent)
		if (is_unconscious)
			regain_consciousness(parent)

/datum/component/conscious/proc/update_pain_overlay()
	// Unconsciousness hud blur
	if(pain)
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

/datum/component/conscious/proc/associate_with_client(datum/source, client/target)
	client = target

/datum/component/conscious/proc/logout()
	client = null

/datum/component/conscious/proc/wince_from_pain(mob/living/victim)
	if (damage > 70 && prob(15))
		victim.emote("scream")
		pain += 20
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
	)))
	pain += 30
	update_pain_overlay()

/// Called when consciousness damage should be applied to the owner
/datum/component/conscious/proc/take_consciousness_damage(mob/living/victim, amount, pause_healing = FALSE)
	if (victim.stat >= SOFT_CRIT)
		amount *= 4
	damage = clamp(amount + damage, 0, max_damage)
	// Feel pain from this injury
	if (amount > 0)
		pain += damage * 2
		update_pain_overlay()
	// Become unconscious
	if (damage >= unconscious_threshold)
		become_unconscious(victim, client)
	if (amount < 0)
		unconscious_time += amount
	if (!is_unconscious && pause_healing)
		consciousness_heal_time = max(world.time + 3 SECONDS, consciousness_heal_time)

/datum/component/conscious/proc/become_unconscious(mob/victim)
	is_unconscious = TRUE
	is_deaf = TRUE
	consciousness_heal_time = max(world.time + 5 SECONDS, consciousness_heal_time)
	damage = min(unconscious_threshold + 20, damage)
	ADD_TRAIT(victim, TRAIT_IMMOBILIZED, FROM_UNCONSCIOUS)
	ADD_TRAIT(victim, TRAIT_KNOCKEDOUT, FROM_UNCONSCIOUS)
	ADD_TRAIT(victim, TRAIT_INCAPACITATED, FROM_UNCONSCIOUS)
	ADD_TRAIT(victim, TRAIT_DEAF, FROM_UNCONSCIOUS)
	ADD_VALUE_TRAIT(victim, TRAIT_VALUE_SOUND_SCAPE, FROM_UNCONSCIOUS, SOUND_ENVIRONMENT_DIZZY, SOUND_PRIORITY_UNCONSCIOUS)
	if (victim.stat <= SOFT_CRIT)
		// Stop all playing sounds
		SEND_SOUND(client, sound(null))
		victim.custom_emote("passes out")
		to_chat(victim, span_userdanger("You fall unconscious!"))

/datum/component/conscious/proc/regain_consciousness(mob/living/victim)
	REMOVE_TRAIT(victim, TRAIT_INCAPACITATED, FROM_UNCONSCIOUS)
	REMOVE_TRAIT(victim, TRAIT_KNOCKEDOUT, FROM_UNCONSCIOUS)
	REMOVE_TRAIT(victim, TRAIT_IMMOBILIZED, FROM_UNCONSCIOUS)
	REMOVE_TRAIT(victim, TRAIT_DEAF, FROM_UNCONSCIOUS)
	REMOVE_TRAIT(victim, TRAIT_VALUE_SOUND_SCAPE, FROM_UNCONSCIOUS)
	is_unconscious = FALSE
	is_deaf = FALSE
	victim.Knockdown(5 SECONDS)

/datum/component/conscious/proc/fall_unconscious(atom/victim, duration)
	unconscious_time = max(unconscious_time, world.time + duration)
	become_unconscious(victim)

/datum/component/conscious/vv_edit_var(var_name, var_value)
	if (var_name == "damage")
		damage = 0
		take_consciousness_damage(parent, var_value)
		return TRUE
	. = ..()
