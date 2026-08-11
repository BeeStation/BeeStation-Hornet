/datum/action/spell/pointed/dominate
	name = "Dominate"
	desc = "This spell dominates the mind of a lesser creature to the will of Nar'Sie, \
		allying it only to her direct followers."
	background_icon_state = "bg_demon"
	button_icon = 'icons/hud/actions/actions_cult.dmi'
	button_icon_state = "dominate"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'

	school = SCHOOL_EVOCATION
	cooldown_time = 1 MINUTES
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	// An UNHOLY, MAGIC SPELL that INFLUENCES THE MIND - all things work here, logically
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY|MAGIC_RESISTANCE_MIND

	cast_range = 7
	active_msg = "You prepare to dominate the mind of a target..."

/datum/action/spell/pointed/dominate/is_valid_spell(mob/user, atom/target)
	if(!isliving(target))
		return FALSE

	var/mob/living/animal = target
	if(animal.mind)
		return FALSE
	if(animal.stat == DEAD)
		return FALSE
	if(!animal.compare_sentience_type(SENTIENCE_ORGANIC)) // Will also return false if not a basic or simple mob, which are the only two we want anyway
		return FALSE
	if(FACTION_CULT in animal.faction)
		return FALSE
	if(HAS_TRAIT(animal, TRAIT_HOLY))
		return FALSE

	return TRUE

/datum/action/spell/pointed/dominate/on_cast(mob/user, mob/living/simple_animal/target)
	. = ..()
	if(target.can_block_magic(antimagic_flags))
		to_chat(target, span_warning("Your feel someone attempting to subject your mind to terrible machinations!"))
		to_chat(owner, span_warning("[target] resists your domination!"))
		return FALSE

	var/turf/cast_turf = get_turf(target)
	target.add_atom_colour("#990000", FIXED_COLOUR_PRIORITY)
	target.faction |= FACTION_CULT
	playsound(cast_turf, 'sound/effects/ghost.ogg', 100, TRUE)
	new /obj/effect/temp_visual/cult/sac(cast_turf)
