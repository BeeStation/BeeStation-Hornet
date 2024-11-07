/*
	Sentient
	Allows ghosts to control the artifact
*/
/datum/xenoartifact_trait/minor/sentient
	label_name = "Sentient"
	label_desc = "Sentient: The artifact's design seems to incorporate sentient elements. This will cause the artifact to have a mind of its own."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 30
	incompatabilities = TRAIT_INCOMPATIBLE_MOB
	can_pearl = FALSE
	///Mob who lives inside the artifact, and who we give actions to
	var/mob/living/simple_animal/shade/sentience/sentience
	///Mob spawner for ghosts
	var/obj/effect/mob_spawn/sentient_artifact/mob_spawner
	///Ref to our landmark
	var/obj/effect/landmark/landmark

/datum/xenoartifact_trait/minor/sentient/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	//Register a signal to KILL!
	RegisterSignal(component_parent, COMSIG_XENOA_CALCIFIED, PROC_REF(suicide))
	//Setup ghost canidates and mob spawners
	if(SSticker.HasRoundStarted())
		INVOKE_ASYNC(src, PROC_REF(get_canidate))
	else
		mob_spawner = new(component_parent.parent, src)
	//Landmarking
	landmark = new(component_parent?.parent)

/datum/xenoartifact_trait/minor/sentient/Destroy(force, ...)
	QDEL_NULL(sentience)
	QDEL_NULL(mob_spawner)
	QDEL_NULL(landmark)
	return ..()

/datum/xenoartifact_trait/minor/sentient/proc/handle_ghost(datum/source, mob/M, list/examine_text)
	if(isobserver(M) && !sentience?.key && (alert(M, "Are you sure you want to control of [sentience]?", "Assume control of [sentience]", "Yes", "No") == "Yes"))
		sentience.key = M.ckey

/datum/xenoartifact_trait/minor/sentient/proc/get_canidate()
	var/list/mob/dead/observer/candidates = poll_ghost_candidates("Do you want to play as the maleviolent force inside the [component_parent?.parent]?", ROLE_SENTIENT_XENOARTIFACT, null, 8 SECONDS)
	if(LAZYLEN(candidates) && component_parent?.parent)
		var/mob/dead/observer/O = pick(candidates)
		if(istype(O) && O.ckey) //I though LAZYLEN would catch this, I guess NULL is getting injected somewhere
			setup_sentience(O.ckey)
			return
	mob_spawner = new(component_parent?.parent, src)

/datum/xenoartifact_trait/minor/sentient/proc/setup_sentience(ckey)
	var/atom/atom_parent = component_parent?.parent
	if(!component_parent?.parent || !ckey || !atom_parent?.loc)
		return
	//Sentience
	sentience = new(component_parent?.parent)
	sentience.name = pick(SSxenoarchaeology.xenoa_artifact_names)
	sentience.real_name = "[sentience.name] - [component_parent?.parent]"
	sentience.key = ckey
	sentience.status_flags |= GODMODE
	ADD_TRAIT(sentience, TRAIT_ARTIFACT_IGNORE, TRAIT_GENERIC)
	//Stop them from wriggling away
	var/atom/movable/movable = component_parent.parent
	movable.buckle_mob(movable, TRUE)
	//Action
	var/obj/effect/proc_holder/spell/targeted/artifact_senitent_action/P = new /obj/effect/proc_holder/spell/targeted/artifact_senitent_action(component_parent?.parent, component_parent)
	sentience.AddSpell(P)
	//Display traits to sentience
	to_chat(sentience, "<span class='notice'>Your traits are: \n</span>")
	var/trait_dialogue = ""
	for(var/index in component_parent.artifact_traits)
		for(var/datum/xenoartifact_trait/T as() in component_parent.artifact_traits[index])
			to_chat(sentience, "<span class='notice'>[T.label_name]\n</span>")
			var/trait_name = T.label_name
			trait_name = replacetext(trait_name, "Δ", "delta")
			trait_name = replacetext(trait_name, "Σ", "sigma")
			trait_name = replacetext(trait_name, "Ω", "omega")
			trait_dialogue = "[trait_dialogue]\n[trait_name]"
	sentience.add_memory(trait_dialogue)
	playsound(get_turf(component_parent?.parent), 'sound/items/haunted/ghostitemattack.ogg', 50, TRUE)
	//Cleanup
	QDEL_NULL(mob_spawner)

//Throw calcification logic here
/datum/xenoartifact_trait/minor/sentient/proc/suicide(datum/source)
	SIGNAL_HANDLER

	QDEL_NULL(sentience)
	QDEL_NULL(mob_spawner)

//Spawner for sentience
/obj/effect/mob_spawn/sentient_artifact
	death = FALSE
	name = "Sentient Xenoartifact"
	short_desc = "You're a maleviolent sentience, possesing an ancient alien artifact."
	flavour_text = "Return to your master..."
	use_cooldown = TRUE
	ghost_usable = TRUE
	instant = FALSE
	roundstart = FALSE
	banType = ROLE_SENTIENT_XENOARTIFACT
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = 101
	///Ref to the trait we're handling
	var/datum/xenoartifact_trait/minor/sentient/trait

/obj/effect/mob_spawn/sentient_artifact/Initialize(mapload, datum/xenoartifact_trait/minor/sentient/new_trait)
	trait = new_trait
	return ..()

/obj/effect/mob_spawn/sentient_artifact/create(ckey)
	trait?.setup_sentience(ckey)

//Action for sentience
/obj/effect/proc_holder/spell/targeted/artifact_senitent_action
	name = "Trigger Artifact"
	desc = "Select a target to activate your artifact on."
	range = 1
	charge_max = 0 SECONDS
	clothes_req = 0
	include_user = 0
	action_icon = 'icons/hud/actions/actions_revenant.dmi'
	action_icon_state = "r_transmit"
	action_background_icon_state = "bg_spell"
	///Ref to the artifact we're handling
	var/datum/component/xenoartifact/sentient_artifact

/obj/effect/proc_holder/spell/targeted/artifact_senitent_action/Initialize(mapload, datum/component/xenoartifact/artifact)
	. = ..()
	sentient_artifact = artifact
	range = sentient_artifact?.target_range

/obj/effect/proc_holder/spell/targeted/artifact_senitent_action/cast(list/targets, mob/user = usr)
	if(!sentient_artifact || sentient_artifact.use_cooldown_timer)
		if(sentient_artifact?.use_cooldown_timer)
			to_chat(user, "<span class='warning'>The artifact is still cooling down, wait [timeleft(sentient_artifact.use_cooldown_timer)/10] seconds!</span>")
		return
	for(var/atom/M in targets)
		//We have to check the range ourselves
		if(get_dist(get_turf(sentient_artifact.parent), get_turf(M)) <= range)
			sentient_artifact.register_target(M)
	sentient_artifact.trigger()

/mob/living/simple_animal/shade/sentience
	desc = "Wait, what the fuck?"
