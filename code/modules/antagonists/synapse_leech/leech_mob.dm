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
	speed = LEECH_SPEED

	// Damage and Combat
	combat_mode = TRUE
	melee_damage = LEECH_MELEE_DAMAGE
	obj_damage = LEECH_MELEE_DAMAGE
	armour_penetration = LEECH_ARMOUR_PENETRATION
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
	lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE

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

/mob/living/basic/synapse_leech/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(do_leech_toxin))
	RegisterSignal(src, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))

/// Called when the HUD is first created so we can initialize display values.
/mob/living/basic/synapse_leech/proc/on_hud_created(datum/source)
	SIGNAL_HANDLER
	update_leech_hud()

// We do not use combat mode.
/mob/living/basic/synapse_leech/set_combat_mode(new_mode, silent = TRUE)
	return
