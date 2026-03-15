/*
	Parallel Entity Retrieval
	Summons entitiess
*/
/datum/xenoartifact_trait/malfunction/animal
	label_name = "P.E.R."
	alt_label_name = "Parallel Entity Retrieval"
	label_desc = "Parallel Entity Retrieval: A strange malfunction causes the Artifact to open a gateway to another plane that summons a random entity."
	flags = XENOA_BLUESPACE_TRAIT| XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	///List of our current summons
	var/list/summons = list()
	///Max summons?
	var/max_summons = 4
	///What kinda of *thing* are we summoning
	var/mob/summon_type = /mob/living/simple_animal/hostile/bear/malnourished

/datum/xenoartifact_trait/malfunction/animal/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	if(length(summons) >= max_summons)
		return
	build_summon()

/datum/xenoartifact_trait/malfunction/animal/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("summon bears"))

//Keep this here so inheritance & poly is easier
/datum/xenoartifact_trait/malfunction/animal/proc/build_summon()
	var/turf/T = get_turf(component_parent.parent)
	var/mob/living/M = new summon_type(T)
	summons += M
	RegisterSignal(M, COMSIG_LIVING_DEATH, PROC_REF(handle_death))

/datum/xenoartifact_trait/malfunction/animal/proc/handle_death(datum/source)
	SIGNAL_HANDLER

	summons -= source
	UnregisterSignal(source, COMSIG_LIVING_DEATH)

//carp variant
/datum/xenoartifact_trait/malfunction/animal/carp
	label_name = "P.E.R. Δ"
	alt_label_name = "Parallel Entity Retrieval Δ"
	label_desc = "Parallel Entity Retrieval Δ: A strange malfunction causes the Artifact to open a gateway to another plane that summons a random entity."
	max_summons = 6
	summon_type = /mob/living/simple_animal/hostile/carp
	conductivity = 7

/datum/xenoartifact_trait/malfunction/animal/carp/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("summon space carps"))

/*	Mirrored Bluespace Collapse
	Makes evil clones!
*/
/datum/xenoartifact_trait/malfunction/animal/twin
	label_name = "M.B.C."
	alt_label_name = "Mirrored Bluespace Collapse"
	label_desc = "Mirrored Bluespace Collapse: The Artifact produces an arguably maleviolent clone of target."
	flags = XENOA_BLUESPACE_TRAIT| XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = TRUE

/datum/xenoartifact_trait/malfunction/animal/twin/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/target in focus)
		if(!isitem(target) && !isliving(target))
			continue
		build_summon(target)
	dump_targets()
	clear_focus()

/datum/xenoartifact_trait/malfunction/animal/twin/build_summon(atom/target)
	if(!target || !isitem(target) && !ismob(target) || length(summons) >= max_summons)
		return
	var/mob/living/simple_animal/hostile/twin/T = new(get_turf(component_parent.parent))
	//Setup appearance for evil twin
	T.appearance = target.appearance
	T.color = component_parent.artifact_material.material_color
	//Handle limit and hardel
	summons += T
	RegisterSignal(T, COMSIG_QDELETING, PROC_REF(handle_death))

/mob/living/simple_animal/hostile/twin
	name = "evil twin"
	desc = "It looks so familiar."
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	speak_chance = 0
	turns_per_move = 5
	speed = 0
	maxHealth = 10
	health = 10
	melee_damage = 5
	attack_sound = 'sound/weapons/punch1.ogg'
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("evil_clone")
	status_flags = CANPUSH
	del_on_death = TRUE
	mobchatspan = "syndmob"
