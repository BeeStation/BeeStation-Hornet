/*
	Malfunction
	These traits cause the xenoartifact to malfunction, typically making the artifact wrose

	* weight - All malfunctions should have a weight that is a multiple of 7
	* conductivity - If a malfunction should have conductivity, it will be a multiple of 7 too
*/
/datum/xenoartifact_trait/malfunction
	priority = TRAIT_PRIORITY_MALFUNCTION
	register_targets = FALSE
	weight = 7
	conductivity = 0
	contribute_calibration = FALSE
	can_pearl = FALSE

/*
	Parallel Bearspace Retrieval
	Summons bears
*/
/datum/xenoartifact_trait/malfunction/bear
	label_name = "P.B.R."
	alt_label_name = "Parallel Bearspace Retrieval"
	label_desc = "Parallel Bearspace Retrieval: A strange malfunction causes the Artifact to open a gateway to deep bearspace."
	flags = XENOA_BLUESPACE_TRAIT| XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	///List of our current bears
	var/list/bears = list()
	///How much can we bear?
	var/max_bears = 4

/datum/xenoartifact_trait/malfunction/bear/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	if(length(bears) >= max_bears)
		return
	var/turf/T = get_turf(parent.parent)
	var/mob/living/simple_animal/hostile/bear/malnourished/new_bear = new(T)
	new_bear.name = pick(list("Freddy", "Bearington", "Smokey", "Beorn", "Pooh", "Winnie", "Baloo", "Rupert", "Yogi", "Fozzie", "Boo"))
	bears += new_bear
	RegisterSignal(new_bear, COMSIG_MOB_DEATH, PROC_REF(handle_death))

/datum/xenoartifact_trait/malfunction/bear/proc/handle_death(datum/source)
	SIGNAL_HANDLER

	bears -= source
	UnregisterSignal(source, COMSIG_MOB_DEATH)

/*
	Bluespace Axis Desync
	Strips a random article from the target
*/
/datum/xenoartifact_trait/malfunction/strip
	label_name = "B.A.D."
	alt_label_name = "Bluespace Axis Desync"
	label_desc = "Bluespace Axis Desync: A strange malfunction causes the Artifact to remove articles from the target."
	flags = XENOA_BLUESPACE_TRAIT| XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = TRUE

/datum/xenoartifact_trait/malfunction/strip/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/M in focus)
		var/list/clothing_list = list()
		for(var/obj/item/clothing/I in M.contents)
			clothing_list += I
		if(!length(clothing_list))
			break
		var/obj/item/clothing/C = pick(clothing_list)
		if(!HAS_TRAIT_FROM(C, TRAIT_NODROP, GLUED_ITEM_TRAIT))
			M.dropItemToGround(C)
	dump_targets()
	clear_focus()

/*
	Cerebral Dysfunction Emergence
	Gives the target a trauma
*/
/datum/xenoartifact_trait/malfunction/trauma
	label_name = "C.D.E."
	alt_label_name = "Cerebral Dysfunction Emergence"
	label_desc = "Cerebral Dysfunction Emergence: A strange malfunction causes the Artifact to cause traumas to emerge in the target."
	flags = XENOA_BLUESPACE_TRAIT| XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = TRUE
	///Possbile traumas
	var/list/possible_traumas = list(
			/datum/brain_trauma/mild/hallucinations, /datum/brain_trauma/mild/stuttering, /datum/brain_trauma/mild/dumbness,
			/datum/brain_trauma/mild/speech_impediment, /datum/brain_trauma/mild/concussion, /datum/brain_trauma/mild/muscle_weakness,
			/datum/brain_trauma/mild/expressive_aphasia, /datum/brain_trauma/severe/narcolepsy, /datum/brain_trauma/severe/discoordination,
			/datum/brain_trauma/severe/pacifism, /datum/brain_trauma/special/beepsky)
	///Choosen trauma
	var/datum/brain_trauma/trauma

/datum/xenoartifact_trait/malfunction/trauma/New(atom/_parent)
	. = ..()
	trauma = pick(possible_traumas)

/datum/xenoartifact_trait/malfunction/trauma/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/carbon/M in focus)
		M.Unconscious(0.5 SECONDS)
		M.gain_trauma(trauma, TRAUMA_RESILIENCE_BASIC)
	dump_targets()
	clear_focus()

/*
	Mass Area Combustion
	Makes a bunch of hotspots near the artifact
*/
/datum/xenoartifact_trait/malfunction/heated
	label_name = "M.A.C."
	alt_label_name = "Mass Area Combustion"
	label_desc = "Mass Area Combustion: A strange malfunction that causes the Artifact to violently combust."
	flags = XENOA_BLUESPACE_TRAIT| XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT

/datum/xenoartifact_trait/malfunction/heated/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/turf/T = get_turf(parent.parent)
	playsound(T, 'sound/effects/bamf.ogg', 50, TRUE)
	for(var/turf/open/turf in RANGE_TURFS(max(1, 4*(parent.trait_strength/100)), T))
		if(!locate(/obj/effect/safe_fire) in turf)
			new /obj/effect/safe_fire(turf)

//Lights on fire, does nothing else damage / atmos wise
/obj/effect/safe_fire
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	layer = GASFIRE_LAYER
	blend_mode = BLEND_ADD
	light_system = MOVABLE_LIGHT
	light_range = LIGHT_RANGE_FIRE
	light_power = 1
	light_color = LIGHT_COLOR_FIRE

/obj/effect/safe_fire/Initialize(mapload)
	. = ..()
	for(var/atom/AT in loc)
		if(!QDELETED(AT) && AT != src) // It's possible that the item is deleted in temperature_expose
			AT.fire_act(400, 50) //should be average enough to not do too much damage
	addtimer(CALLBACK(src, PROC_REF(after_burn)), 0.3 SECONDS)

/obj/effect/safe_fire/proc/after_burn()
	qdel(src)

/*
	Rapid Particle Emmision
	Irradiates the artifact and targets
*/
/datum/xenoartifact_trait/malfunction/radiation
	label_name = "R.P.E."
	alt_label_name = "Rapid Particle Emmision"
	label_desc = "Rapid Particle Emmision: A strange malfunction that causes the Artifact to irradiate itself and its targets."
	flags = XENOA_BLUESPACE_TRAIT| XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = TRUE
	///Max amount of radiation we can deal
	var/max_rad = 25

/datum/xenoartifact_trait/malfunction/radiation/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/atom/A = parent.parent
	A.rad_act(max_rad*(parent.trait_strength/100))
	for(var/atom/target in focus)
		target.rad_act(max_rad*(parent.trait_strength/100))
	dump_targets()
	clear_focus()

/*
	Mirrored Bluespace Collapse
	Makes evil clones!
*/
/datum/xenoartifact_trait/malfunction/twin
	label_name = "M.B.C."
	alt_label_name = "Mirrored Bluespace Collapse"
	label_desc = "Mirrored Bluespace Collapse: The Artifact produces an arguably maleviolent clone of target."
	flags = XENOA_BLUESPACE_TRAIT| XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = TRUE
	///List of our evil clones
	var/list/clones = list()
	///Max amount of evil clones
	var/max_clones = 5

/datum/xenoartifact_trait/malfunction/twin/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	//Stop artifact making one morbillion clones
	if(length(clones) >= max_clones)
		return
	for(var/atom/target in focus)
		if(!isitem(target) && !ismob(target))
			continue
		var/mob/living/simple_animal/hostile/twin/T = new(get_turf(parent.parent))
		//Setup appearance for evil twin
		T.appearance = target.appearance
		T.color = parent.artifact_type.material_color
		//Handle limit and hardel
		clones += T
		RegisterSignal(T, COMSIG_PARENT_QDELETING, PROC_REF(handle_death))
	dump_targets()
	clear_focus()

/datum/xenoartifact_trait/malfunction/twin/proc/handle_death(datum/source)
	clones -= source
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

/mob/living/simple_animal/hostile/twin
	name = "evil twin"
	desc = "It looks so familiar."
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	maxHealth = 10
	health = 10
	melee_damage = 5
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("evil_clone")
	status_flags = CANPUSH
	del_on_death = TRUE
	do_footstep = TRUE
	mobchatspan = "syndmob"

/*
	Expansive Explosive Emition
	I'm about to blow up, and act like I don't know nobody! AH AH AH AH AH!
*/
/datum/xenoartifact_trait/malfunction/explosion
	label_name = "E.E.E."
	alt_label_name = "Expansive Explosive Emmission"
	label_desc = "Expansive Explosive Emmission: A strange malfunction that causes the Artifact to explode."
	flags = XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	rarity = XENOA_TRAIT_WEIGHT_RARE
	///Max explosion stat
	var/max_explosion = 5

/datum/xenoartifact_trait/malfunction/explosion/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/atom/A = parent.parent
	A.visible_message("<span class='warning'>The [A] begins to heat up, it's delaminating!</span>", allow_inside_usr = TRUE)
	addtimer(CALLBACK(src, PROC_REF(explode)), 30*(parent.trait_strength/100) SECONDS)
	//Fancy animation
	//TODO: Picking up and dropping breaks this animation - Racc
	A.color = COLOR_RED
	var/matrix/old_transform = A.transform
	var/matrix/new_transform = A.transform
	new_transform.Scale(1.3, 1.3)
	animate(parent.parent, transform = new_transform, time = 0.5 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)
	animate(transform = old_transform, time = 0.5 SECONDS)

/datum/xenoartifact_trait/malfunction/explosion/proc/explode()
	explosion(get_turf(parent.parent), max_explosion/3*(parent.trait_strength/100), max_explosion/2*(parent.trait_strength/100), max_explosion*(parent.trait_strength/100), max_explosion*(parent.trait_strength/100))
	parent.calcify()

/*
	Mass Hallucinatory Injection
	Makes the target/s hallucinate
*/
/datum/xenoartifact_trait/malfunction/hallucination
	label_name = "M.H.I."
	alt_label_name = "Mass Hallucinatory Injection"
	label_desc = "Mass Hallucinatory Injection: The Artifact causes the target to hallucinate."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_PLASMA_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = TRUE

/datum/xenoartifact_trait/malfunction/hallucination/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/target in focus)
		var/datum/hallucination/H = pick(GLOB.hallucination_list)
		H = new H(target)
	dump_targets()
	clear_focus()
