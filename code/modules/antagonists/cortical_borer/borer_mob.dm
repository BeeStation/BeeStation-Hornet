/**
 * # Cortical Borer
 *
 * The Cortical Borer is a small, grub-like creature that burrows into the skulls of its victims to feed on their brain matter.
 *
 */

/mob/living/basic/cortical_borer
	name = "Cortical Borer"
	desc = "A disgusting grub-like worm. It's body is constantly writhing, as if something inside it is trying to get out."
	icon = 'icons/cortical_borers/mob.dmi'
	icon_state = "borer"
	icon_living = "borer"
	icon_dead = "borer_dead"
	hud_type = /datum/hud/borer

	// Attributes and Traits
	maxHealth = 50
	health = 50
	mob_biotypes = MOB_BUG
	basic_mob_flags = FLAMMABLE_MOB
	status_flags = CANPUSH
	// Very hidey
	layer = ABOVE_NORMAL_TURF_LAYER

	// Movement
	speed = -0.5

	// Damage and Combat
	combat_mode = TRUE
	melee_damage = 5
	obj_damage = 5
	armour_penetration = 75
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
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	// AI
	environment_smash = ENVIRONMENT_SMASH_NONE
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile
	faction = list(FACTION_BORER)

	// Custom
	/// The type of toxin the borer injects per attack
	var/toxin_type = /datum/reagent/toxin/borer_toxin
	/// The amount of toxin the borer injects per attack
	var/toxin_per_attack = 5

/mob/living/basic/cortical_borer/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(do_borer_toxin))

/mob/living/basic/cortical_borer/proc/do_borer_toxin(mob/living/element_owner, atom/target, success)
	SIGNAL_HANDLER

	if(!success || !isliving(target))
		return

	var/mob/living/living_target = target
	if(living_target.stat == DEAD)
		return

	if(!living_target.reagents)
		return

	if(HAS_TRAIT(living_target, TRAIT_PIERCEIMMUNE))
		return

	living_target.reagents.add_reagent(toxin_type, rand(0, toxin_per_attack))
