////////////////
// BLOB SPORE //
////////////////

/mob/living/simple_animal/hostile/blob/blobspore
	name = "blob spore"
	desc = "A floating, fragile spore."
	icon_state = "blobpod"
	icon_living = "blobpod"
	health_doll_icon = "blobpod"
	health = BLOBMOB_SPORE_HEALTH
	maxHealth = BLOBMOB_SPORE_HEALTH
	verb_say = "psychically pulses"
	verb_ask = "psychically probes"
	verb_exclaim = "psychically yells"
	verb_yell = "psychically screams"
	melee_damage = BLOBMOB_SPORE_DMG
	obj_damage = BLOBMOB_SPORE_OBJ_DMG
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	attack_verb_continuous = "hits"
	attack_verb_simple = "hit"
	attack_sound = 'sound/weapons/genhit1.ogg'
	is_flying_animal = TRUE
	no_flying_animation = TRUE
	del_on_death = TRUE
	death_message = "explodes into a cloud of gas!"
	gold_core_spawnable = HOSTILE_SPAWN
	/// Size of cloud produced from a dying spore
	var/death_cloud_size = 1
	/// The attached person
	var/mob/living/carbon/human/corpse
	/// If this is attached to a person
	var/is_zombie = FALSE
	/// Whether or not this is a fragile spore from Distributed Neurons
	var/is_weak = FALSE
	//Shitcode.
	var/list/datum/disease/spore_diseases = list()

	flavor_text = FLAVOR_TEXT_GOAL_ANTAG

CREATION_TEST_IGNORE_SUBTYPES(/mob/living/simple_animal/hostile/blob/blobspore)

/mob/living/simple_animal/hostile/blob/blobspore/Initialize(mapload, obj/structure/blob/special/linked_node)
	. = ..()

	if(!istype(linked_node))
		return

	factory = linked_node
	factory.spores += src
	if(linked_node.overmind && istype(linked_node.overmind.blobstrain, /datum/blobstrain/reagent/distributed_neurons) && !istype(src, /mob/living/simple_animal/hostile/blob/blobspore/weak))
		notify_ghosts(
			"A controllable spore has been created in \the [get_area(src)].",
			source = src,
			notify_flags = NOTIFY_CATEGORY_NOFLASH,
			header = "Sentient Spore Created"
		)

/mob/living/simple_animal/hostile/blob/blobspore/mind_initialize()
	. = ..()
	if(independent || !overmind)
		return FALSE
	var/datum/antagonist/blob_minion/blob_zombie/zombie = new(overmind)
	mind.add_antag_datum(zombie)

/mob/living/simple_animal/hostile/blob/blobspore/Life(delta_time = SSMOBS_DT, times_fired)
	if(!is_zombie && isturf(src.loc))
		for(var/mob/living/carbon/human/H in hearers(1, src)) //Only for corpse right next to/on same tile
			if(!is_weak && H.stat == DEAD)
				zombify(H)
				break
	if(factory && !is_valid_z_level(get_turf(src), get_turf(factory)))
		death()
	return ..()

/mob/living/simple_animal/hostile/blob/blobspore/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	humanize_pod(user)

/mob/living/simple_animal/hostile/blob/blobspore/death(gibbed)
	// On death, create a small smoke of harmful gas (s-Acid)
	var/datum/effect_system/smoke_spread/chem/spores  = new
	var/turf/location = get_turf(src)

	// Create the reagents to put into the air
	create_reagents(10)

	if(overmind?.blobstrain)
		overmind.blobstrain.on_sporedeath(src)
	else
		reagents.add_reagent(/datum/reagent/toxin/spore, 10)

	// Attach the smoke spreader and setup/start it.
	spores.attach(location)
	spores.set_up(reagents, death_cloud_size, location, silent = TRUE)
	spores.start()
	if(factory)
		factory.spore_delay = world.time + factory.spore_cooldown //put the factory on cooldown

	return ..()

/mob/living/simple_animal/hostile/blob/blobspore/death()
	if(factory)
		factory.spores -= src
	corpse?.forceMove(loc)
	corpse = null
	return ..()

/mob/living/simple_animal/hostile/blob/blobspore/update_icons()
	if(overmind)
		add_atom_colour(overmind.blobstrain.complementary_color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
	if(!is_zombie)
		return FALSE

	copy_overlays(corpse, TRUE)
	var/mutable_appearance/blob_head_overlay = mutable_appearance('icons/mob/blob.dmi', "blob_head")
	if(overmind)
		blob_head_overlay.color = overmind.blobstrain.complementary_color
	color = initial(color)//looks better.
	add_overlay(blob_head_overlay)

/mob/living/simple_animal/hostile/blob/blobspore/independent
	gold_core_spawnable = HOSTILE_SPAWN
	independent = TRUE

/mob/living/simple_animal/hostile/blob/blobspore/weak
	name = "fragile blob spore"
	health = 15
	maxHealth = 15
	melee_damage = 2
	death_cloud_size = 0
	is_weak = TRUE

/** Ghost control a blob zombie */
/mob/living/simple_animal/hostile/blob/blobspore/proc/humanize_pod(mob/user)
	if((!overmind || istype(src, /mob/living/simple_animal/hostile/blob/blobspore/weak) || !istype(overmind.blobstrain, /datum/blobstrain/reagent/distributed_neurons)) && !is_zombie)
		return FALSE
	if(key || stat)
		return FALSE
	var/pod_ask = tgui_alert(usr, "Are you bulbous enough?", "Blob Spore", list("Yes", "No"))
	if(pod_ask != "Yes" || QDELETED(src))
		return FALSE
	if(key)
		to_chat(user, span_warning("Someone else already took this spore!"))
		return FALSE
	key = user.key
	log_message("took control of [name].", LOG_GAME)

/** Zombifies a dead mob, turning it into a blob zombie */
/mob/living/simple_animal/hostile/blob/blobspore/proc/zombify(mob/living/carbon/human/target)
	is_zombie = 1
	if(target.wear_suit)
		maxHealth += target.get_armor_rating(MELEE)
	maxHealth += 40
	health = maxHealth
	name = "blob zombie"
	desc = "A shambling corpse animated by the blob."
	mob_biotypes |= MOB_HUMANOID
	melee_damage += 11
	obj_damage = 20
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	movement_type = GROUND
	death_cloud_size = 0
	icon = target.icon
	icon_state = "zombie"
	target.hair_style = null
	target.update_hair()
	target.forceMove(src)
	corpse  = target
	update_icons()
	visible_message(span_warning("The corpse of [target.name] suddenly rises!"))
	if(!key)
		notify_ghosts(
			"\A [src] has been created in \the [get_area(src)].",
			source = src,
			notify_flags = NOTIFY_CATEGORY_NOFLASH,
			header = "Blob Zombie Created"
		)
		set_playable(ROLE_BLOB)
