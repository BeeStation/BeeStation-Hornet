/**
 * # Synapse Leech
 *
 * The Synapse Leech is a small, grub-like creature that burrows into the skulls of its victims to feed on their brain matter.
 *
 */

/mob/living/basic/synapse_leech
	name = "Synapse Leech"
	desc = "A disgusting grub-like worm. It's body is constantly writhing, as if something inside it is trying to get out."
	icon = 'icons/synapse_leech/mob.dmi'
	icon_state = "leech"
	icon_living = "leech"
	icon_dead = "leech_dead"
	hud_type = /datum/hud/leech

	// Attributes and Traits
	maxHealth = LEECH_MAX_HEALTH
	health = LEECH_MAX_HEALTH
	mob_biotypes = MOB_BUG
	basic_mob_flags = FLAMMABLE_MOB
	status_flags = CANPUSH

	// Movement
	speed = -0.5

	// Damage and Combat
	combat_mode = TRUE
	melee_damage = 1 // Token amount
	obj_damage = 5
	melee_damage_type = TOX
	melee_attack_cooldown = 1 SECONDS

	// Flavor
	death_message = "slumps into a pile of pulpy mush"
	attack_sound = 'sound/weapons/pierce.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_verb_continuous = "stings"
	attack_verb_simple = "sting"

	// Misc Stuff
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSMOB | PASSTABLE
	see_in_dark = NIGHTVISION_FOV_RANGE

	// AI
	environment_smash = ENVIRONMENT_SMASH_NONE
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile
	faction = list(FACTION_LEECH)

	// Custom

	/// Saturation (We do not use the basic mob satiety)
	var/saturation = LEECH_INITIAL_SATURATION // We start at half

	/// Basic leech resource.
	var/max_substrate = LEECH_MAX_SUBSTRATE
	var/substrate = LEECH_MAX_SUBSTRATE

	/// The type of toxin the leech injects per attack
	var/toxin_type = /datum/reagent/toxin/leech_toxin

	/// Whether the leech is currently "hiding" (low layer so it slips under objects).
	var/hidden = FALSE

	/// The mob we are currently burrowed inside, if any.
	var/mob/living/carbon/host
	/// Whether we are currently nested (burrowed) inside a host.
	var/nested = FALSE

/mob/living/basic/synapse_leech/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(do_leech_toxin))
	RegisterSignal(src, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))
	grant_leech_abilities()

/// Grants the synapse leech's innate ability set. Called once on Initialize.
/mob/living/basic/synapse_leech/proc/grant_leech_abilities()
	for(var/action_type in subtypesof(/datum/action/leech))
		var/datum/action/leech/dummy = action_type
		if(initial(dummy.abstract_type) == action_type)
			continue // skip abstract intermediaries
		GRANT_ACTION(action_type)

/// Called when the HUD is first created so we can initialize display values.
/mob/living/basic/synapse_leech/proc/on_hud_created(datum/source)
	SIGNAL_HANDLER
	update_leech_hud()

// We do not use combat mode.
/mob/living/basic/synapse_leech/set_combat_mode(new_mode, silent = TRUE)
	return

/**
 * Synapse leeches cannot speak out loud, ever. While nested they can whisper telepathically to
 * their host (and only their host); outside of a host, anything they "say" is silently swallowed
 * with feedback explaining why.
 */
/mob/living/basic/synapse_leech/say(message, bubble_type, list/spans, sanitize = TRUE, datum/language/language, ignore_spam, forced, filterproof = FALSE, message_range = 7, datum/saymode/saymode, list/message_mods = list())
	if(sanitize)
		message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!length(message))
		return
	// Outside of a host, we have no medium to project our voice through.
	if(!nested || !host || QDELETED(host))
		return
	leech_speak_to_host(message)

/// Sends a private telepathic message
/mob/living/basic/synapse_leech/proc/leech_speak_to_host(message)
	if(CHAT_FILTER_CHECK(message))
		to_chat(src, span_warning("Your message contains forbidden words."))
		return
	if(!host || QDELETED(host))
		return
	var/leech_text = "[span_bolditalics("[span_name("[src]")] -> [span_name("[host.name]")]:")] [span_notice(message)]"
	var/host_text = "[span_bolditalics("[span_name("[src]")]:")] [span_notice(message)]"
	host.balloon_alert(host, "You hear a voice in your head...")
	to_chat(src, leech_text, type = MESSAGE_TYPE_RADIO, avoid_highlighting = TRUE)
	to_chat(host, host_text, type = MESSAGE_TYPE_RADIO)
	log_talk(message, LOG_SAY, tag = "synapse leech ([key_name(src)] -> [key_name(host)])")

/// No interacting while inside the host. This is likely to be wrong, please review
/mob/living/basic/synapse_leech/ClickOn(atom/A, params)
	if(nested)
		/// Everything but these
		if(istype(A, /atom/movable/screen))
			return ..()
		// What the fuck are we doing here
		var/list/modifiers = params2list(params)
		if(check_click_intercept(params, A))
			return
		if(SEND_SIGNAL(src, COMSIG_MOB_CLICKON, A, modifiers) & COMSIG_MOB_CANCEL_CLICKON)
			return
		return
	return ..()
