/**
 * # Cortical Borer
 *
 * The Cortical Borer is a small, grub-like creature that burrows into the skulls of its victims to feed on their brain matter.
 *
 */

/mob/living/basic/cortical_borer
	name = "Cortical Borer"
	desc = "A disgusting grub-like worm. It's body is constantly writhing, as if something inside it is trying to get out."
	icon = 'icons/mob/borer.dmi'
	icon_state = "borer"
	icon_living = "borer"
	icon_dead = "borer_dead"

	// Attributes and Traits
	maxHealth = 50
	health = 50
	mob_biotypes = MOB_BUG
	basic_mob_flags = FLAMMABLE_MOB
	status_flags = CANPUSH

	// SPACE!
	damage_coeff = list(BRUTE = 1, BURN = 1.5, TOX = 0, STAMINA = 0, OXY = 0)
	pressure_resistance = 200
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = T0C + 100
	unsuitable_cold_damage = 0
	habitable_atmos = null

	// Movement
	speed = -0.5
	/// Make attacks not cause bleeding (carbon defense only adds bleed for BRUTE melee damage)
	melee_damage_type = STAMINA

	// Damage and Combat
	combat_mode = TRUE
	melee_damage = 2
	obj_damage = 5
	armour_penetration = 100
	melee_attack_cooldown = CLICK_CD_MELEE

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
	// Register a short post-attack handler (spider-style) to add toxin directly to the target's reagent container
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
	if(islist(toxin_per_attack))
		living_target.reagents.add_reagent(toxin_type, rand(toxin_per_attack[1], toxin_per_attack[2]))
	else
		living_target.reagents.add_reagent(toxin_type, toxin_per_attack)
