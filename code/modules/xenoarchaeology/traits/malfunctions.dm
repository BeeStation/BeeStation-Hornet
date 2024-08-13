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
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE

/datum/xenoartifact_trait/malfunction/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/M in oview(XENOA_TRAIT_BALLOON_HINT_DIST, get_turf(parent.parent)))
		do_hint(M)

/datum/xenoartifact_trait/malfunction/do_hint(mob/user, atom/item)
	//If they have science goggles, or equivilent, they are shown exatcly what trait this is
	if(!user?.can_see_reagents())
		return
	var/atom/A = parent.parent
	if(!isturf(A.loc))
		A = A.loc
	A.balloon_alert(user, label_name, parent.artifact_type.material_color, offset_y = 8)
	//show_in_chat doesn't work
	to_chat(user, "<span class='notice'>[parent.parent] : [label_name]</span>")

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
	var/turf/T = get_turf(parent.parent)
	var/mob/living/M = new summon_type(T)
	summons += M
	RegisterSignal(M, COMSIG_MOB_DEATH, PROC_REF(handle_death))

/datum/xenoartifact_trait/malfunction/animal/proc/handle_death(datum/source)
	SIGNAL_HANDLER

	summons -= source
	UnregisterSignal(source, COMSIG_MOB_DEATH)

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

/*
	Mirrored Bluespace Collapse
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
	var/mob/living/simple_animal/hostile/twin/T = new(get_turf(parent.parent))
	//Setup appearance for evil twin
	T.appearance = target.appearance
	T.color = parent.artifact_type.material_color
	//Handle limit and hardel
	summons += T
	RegisterSignal(T, COMSIG_PARENT_QDELETING, PROC_REF(handle_death))

/mob/living/simple_animal/hostile/twin
	name = "evil twin"
	desc = "It looks so familiar."
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speak_chance = 0
	turns_per_move = 5
	speed = 0
	maxHealth = 10
	health = 10
	melee_damage = 5
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("evil_clone")
	status_flags = CANPUSH
	del_on_death = TRUE
	mobchatspan = "syndmob"

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
	Expansive Explosive Emmission
	I'm about to blow up, and act like I don't know nobody! AH AH AH AH AH!
*/
/datum/xenoartifact_trait/malfunction/explosion
	label_name = "E.E.E."
	alt_label_name = "Expansive Explosive Emmission"
	label_desc = "Expansive Explosive Emmission: A strange malfunction that causes the Artifact to explode."
	flags = XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	rarity = XENOA_TRAIT_WEIGHT_RARE
	can_pearl = FALSE
	///Max explosion stat
	var/max_explosion = 4
	///Are we exploding?
	var/exploding
	///Ref to the exploding effect
	var/atom/movable/exploding_indicator //We can't use an overlay, becuase it breaks filters, and the overlay filter doesn't animate

/datum/xenoartifact_trait/malfunction/explosion/register_parent(datum/source)
	. = ..()
	if(!parent?.parent)
		return
	var/obj/A = parent.parent
	//Make the artifact robust so it doesn't destroy itself
	A.armor = list(MELEE = 20,  BULLET = 0, LASER = 20, ENERGY = 10, BOMB = 500, BIO = 0, RAD = 0, FIRE = 80, ACID = 50, STAMINA = 10)
	//Build indicator appearance
	exploding_indicator = new()
	exploding_indicator.appearance = mutable_appearance('icons/obj/xenoarchaeology/xenoartifact.dmi', "explosion_warning", plane = LOWEST_EVER_PLANE)
	exploding_indicator.render_target = "[REF(exploding_indicator)]"
	exploding_indicator.vis_flags = VIS_UNDERLAY
	exploding_indicator.appearance_flags = KEEP_APART
	//Get it nearby so we can render it later
	A.vis_contents += exploding_indicator
	//Register a signal to cancel the process
	RegisterSignal(parent, XENOA_CALCIFIED, PROC_REF(cancel_explosion))

/datum/xenoartifact_trait/malfunction/explosion/Destroy(force, ...)
	. = ..()
	QDEL_NULL(exploding_indicator)

/datum/xenoartifact_trait/malfunction/explosion/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!. || exploding)
		return
	var/atom/A = parent.parent
	A.visible_message("<span class='warning'>The [A] begins to heat up, it's delaminating!</span>", allow_inside_usr = TRUE)
	exploding = addtimer(CALLBACK(src, PROC_REF(explode)), 30*(parent.trait_strength/100) SECONDS, TIMER_STOPPABLE)
	//Fancy effect to alert players
	A.add_filter("explosion_indicator", 1.1, layering_filter(render_source = exploding_indicator.render_target, blend_mode = BLEND_INSET_OVERLAY))
	A.add_filter("wave_effect", 5, wave_filter(x = 1, size = 0.6))
	var/filter = A.get_filter("wave_effect")
	animate(filter, offset = 5, time = 5 SECONDS, loop = -1)
	animate(offset = 0, time = 5 SECONDS)

/datum/xenoartifact_trait/malfunction/explosion/proc/explode()
	var/atom/A = parent.parent
	A.remove_filter("explosion_indicator")
	A.remove_filter("wave_effect")
	if(parent.calcified) //Just in-case this somehow happens
		return
	explosion(get_turf(parent.parent), max_explosion/3*(parent.trait_strength/100), max_explosion/2*(parent.trait_strength/100), max_explosion*(parent.trait_strength/100), max_explosion*(parent.trait_strength/100))
	parent.calcify()

//Tidy stuff up when we're calcified
/datum/xenoartifact_trait/malfunction/explosion/proc/cancel_explosion()
	SIGNAL_HANDLER

	var/atom/A = parent.parent
	A.remove_filter("explosion_indicator")
	A.remove_filter("wave_effect")
	deltimer(exploding)
	UnregisterSignal(parent, XENOA_CALCIFIED)

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

/*
	Spontaneous Stomach Evacuation
	makes the target puke
*/
/datum/xenoartifact_trait/malfunction/vomit
	label_name = "S.S.E."
	alt_label_name = "Spontaneous Stomach Evacuation"
	label_desc = "Spontaneous Stomach Evacuationc: A strange malfunction causes the Artifact to make the target vomit."
	flags = XENOA_BLUESPACE_TRAIT| XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = TRUE

/datum/xenoartifact_trait/malfunction/vomit/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/M in focus)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			C.vomit(distance = rand(1, 2))
		else
			new /obj/effect/decal/cleanable/vomit(get_turf(parent.parent))
	dump_targets()
	clear_focus()

/*
	Immediate Organ Extraction
	steals the target's appendix
*/
/datum/xenoartifact_trait/malfunction/organ_stealer
	label_name = "I.O.E"
	alt_label_name = "Immediate Organ Extraction"
	label_desc = "Immediate Organ Extraction: A strange malfunction causes the Artifact to extract the target's appendix."
	flags = XENOA_BLUESPACE_TRAIT| XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = TRUE
	///What organ slot do we yank from
	var/target_organ_slot = ORGAN_SLOT_APPENDIX

/datum/xenoartifact_trait/malfunction/organ_stealer/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/carbon/M in focus)
		var/obj/item/organ/O = M.getorganslot(target_organ_slot)
		O?.Remove(M)
		O?.forceMove(get_turf(parent.parent))
	dump_targets()
	clear_focus()

/datum/xenoartifact_trait/malfunction/organ_stealer/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("steal the target's appendix"))

//This variant will steal the target's tongue
/datum/xenoartifact_trait/malfunction/organ_stealer/tongue
	label_name = "I.O.E Δ"
	alt_label_name = "Immediate Organ Extraction Δ"
	label_desc = "Immediate Organ Extraction Δ: A strange malfunction causes the Artifact to extract the target's tongue."
	target_organ_slot = ORGAN_SLOT_TONGUE
	conductivity = 14

/datum/xenoartifact_trait/malfunction/organ_stealer/tongue/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("steal the target's tongue"))
