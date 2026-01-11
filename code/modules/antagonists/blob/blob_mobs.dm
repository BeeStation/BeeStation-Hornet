
////////////////
// BASE TYPE //
////////////////

//Do not spawn
/mob/living/simple_animal/hostile/blob
	icon = 'icons/mob/blob.dmi'
	pass_flags = PASSBLOB
	faction = list(FACTION_BLOB)
	bubble_icon = "blob"
	speak_emote = null //so we use verb_yell/verb_say/etc
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 360
	unique_name = 1
	combat_mode = TRUE
	see_in_dark = NIGHTVISION_FOV_RANGE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	initial_language_holder = /datum/language_holder/empty
	var/mob/camera/blob/overmind = null
	var/obj/structure/blob/special/factory = null
	var/independent = FALSE
	mobchatspan = "blob"
	discovery_points = 1000

/mob/living/simple_animal/hostile/blob/update_icons()
	if(overmind)
		add_atom_colour(overmind.blobstrain.color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/hostile/blob/Initialize(mapload)
	. = ..()
	if(!independent) //no pulling people deep into the blob
		remove_verb(/mob/living/verb/pulled)
	else
		pass_flags &= ~PASSBLOB

/mob/living/simple_animal/hostile/blob/Destroy()
	if(overmind)
		overmind.blob_mobs -= src
	return ..()

/mob/living/simple_animal/hostile/blob/blob_act(obj/structure/blob/B)
	if(stat != DEAD && health < maxHealth)
		for(var/i in 1 to 2)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(src)) //hello yes you are being healed
			if(overmind)
				H.color = overmind.blobstrain.complementary_color
			else
				H.color = "#000000"
		adjustHealth(-maxHealth * BLOBMOB_HEALING_MULTIPLIER)

/mob/living/simple_animal/hostile/blob/fire_act(exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature)
		adjustFireLoss(clamp(0.01 * exposed_temperature, 1, 5))
	else
		adjustFireLoss(5)

/mob/living/simple_animal/hostile/blob/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/structure/blob))
		return TRUE

/mob/living/simple_animal/hostile/blob/Process_Spacemove(movement_dir = 0)
	for(var/obj/structure/blob/B in range(1, src))
		return 1
	return ..()

/mob/living/simple_animal/hostile/blob/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, message_range = 7, datum/saymode/saymode = null)
	if(!overmind)
		return ..()
	if(CHAT_FILTER_CHECK(message))
		to_chat(usr, span_warning("Your message contains forbidden words."))
		return
	message = treat_message_min(message)
	log_talk(message, LOG_SAY, tag="blob")
	var/spanned_message = say_quote(message)
	var/rendered = "<font color=\"#EE4000\"><b>\[Blob Telepathy\] [real_name]</b> [spanned_message]</font>"
	for(var/M in GLOB.mob_list)
		if(isovermind(M) || istype(M, /mob/living/simple_animal/hostile/blob))
			to_chat(M, rendered)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")

////////////////
// BLOB SPORE //
////////////////

/mob/living/simple_animal/hostile/blob/blobspore
	name = "blob spore"
	desc = "A floating, fragile spore."
	icon_state = "blobpod"
	icon_living = "blobpod"
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
	deathmessage = "explodes into a cloud of gas!"
	gold_core_spawnable = HOSTILE_SPAWN
	var/death_cloud_size = 1 //size of cloud produced from a dying spore
	var/mob/living/carbon/human/oldguy
	var/is_zombie = FALSE
	var/list/datum/disease/spore_diseases = list()
	flavor_text = FLAVOR_TEXT_GOAL_ANTAG

CREATION_TEST_IGNORE_SUBTYPES(/mob/living/simple_animal/hostile/blob/blobspore)

/mob/living/simple_animal/hostile/blob/blobspore/Initialize(mapload, obj/structure/blob/special/linked_node)
	if(istype(linked_node))
		factory = linked_node
		factory.spores += src
	. = ..()

/mob/living/simple_animal/hostile/blob/blobspore/Life(delta_time = SSMOBS_DT, times_fired)
	if(!is_zombie && isturf(src.loc))
		for(var/mob/living/carbon/human/H in hearers(1, src)) //Only for corpse right next to/on same tile
			if(H.stat == DEAD)
				Zombify(H)
				break
	if(factory && z != factory.z)
		death()
	..()

/mob/living/simple_animal/hostile/blob/blobspore/proc/Zombify(mob/living/carbon/human/H)
	is_zombie = 1
	if(H.wear_suit)
		maxHealth += H.get_armor_rating(MELEE)
	maxHealth += 40
	health = maxHealth
	name = "blob zombie"
	desc = "A shambling corpse animated by the blob."
	mob_biotypes |= MOB_HUMANOID
	melee_damage += 11
	movement_type = GROUND
	death_cloud_size = 0
	icon = H.icon
	icon_state = "zombie"
	H.hair_style = null
	H.update_hair()
	H.forceMove(src)
	oldguy = H
	update_icons()
	visible_message(span_warning("The corpse of [H.name] suddenly rises!"))
	if(!key)
		set_playable(ROLE_BLOB)

/mob/living/simple_animal/hostile/blob/blobspore/death(gibbed)
	// On death, create a small smoke of harmful gas (s-Acid)
	var/datum/effect_system/smoke_spread/chem/S = new
	var/turf/location = get_turf(src)

	// Create the reagents to put into the air
	create_reagents(10)



	if(overmind?.blobstrain)
		overmind.blobstrain.on_sporedeath(src)
	else
		reagents.add_reagent(/datum/reagent/toxin/spore, 10)

	// Attach the smoke spreader and setup/start it.
	S.attach(location)
	S.set_up(reagents, death_cloud_size, location, silent = TRUE)
	S.start()
	if(factory)
		factory.spore_delay = world.time + factory.spore_cooldown //put the factory on cooldown

	..()

/mob/living/simple_animal/hostile/blob/blobspore/Destroy()
	if(factory)
		factory.spores -= src
	factory = null
	if(oldguy)
		oldguy.forceMove(get_turf(src))
		oldguy = null
	return ..()

/mob/living/simple_animal/hostile/blob/blobspore/update_icons()
	if(overmind)
		add_atom_colour(overmind.blobstrain.complementary_color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
	if(is_zombie)
		copy_overlays(oldguy, TRUE)
		var/mutable_appearance/blob_head_overlay = mutable_appearance('icons/mob/blob.dmi', "blob_head")
		if(overmind)
			blob_head_overlay.color = overmind.blobstrain.complementary_color
		color = initial(color)//looks better.
		add_overlay(blob_head_overlay)

/mob/living/simple_animal/hostile/blob/blobspore/Goto(target, delay, minimum_distance)
	if(target == src.target)
		approaching_target = TRUE
	else
		approaching_target = FALSE
	SSmove_manager.hostile_jps_move(src, target,delay, minimum_distance = minimum_distance)

/mob/living/simple_animal/hostile/blob/blobspore/weak
	name = "fragile blob spore"
	health = 15
	maxHealth = 15
	melee_damage = 2
	death_cloud_size = 0

/////////////////
// BLOBBERNAUT //
/////////////////

/mob/living/simple_animal/hostile/blob/blobbernaut
	name = "blobbernaut"
	desc = "A hulking, mobile chunk of blobmass."
	icon_state = "blobbernaut"
	icon_living = "blobbernaut"
	icon_dead = "blobbernaut_dead"
	health = BLOBMOB_BLOBBERNAUT_HEALTH
	maxHealth = BLOBMOB_BLOBBERNAUT_HEALTH
	damage_coeff = list(BRUTE = 0.5, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	melee_damage = BLOBMOB_BLOBBERNAUT_DMG_SOLO
	obj_damage = BLOBMOB_BLOBBERNAUT_OBJ_DMG
	attack_verb_continuous = "slams"
	attack_verb_simple = "slam"
	attack_sound = 'sound/effects/blobattack.ogg'
	verb_say = "gurgles"
	verb_ask = "demands"
	verb_exclaim = "roars"
	verb_yell = "bellows"
	force_threshold = 10
	pressure_resistance = 50
	mob_size = MOB_SIZE_LARGE
	hud_type = /datum/hud/blobbernaut
	flavor_text = FLAVOR_TEXT_GOAL_ANTAG
	move_resist = MOVE_FORCE_STRONG

/mob/living/simple_animal/hostile/blob/blobbernaut/Life(delta_time = SSMOBS_DT, times_fired)
	if(!..())
		return
	var/list/blobs_in_area = range(2, src)

	if(independent)
		return // strong independent blobbernaut that don't need no blob

	var/damagesources = 0

	if(!(locate(/obj/structure/blob) in blobs_in_area))
		damagesources++

	if(!factory)
		damagesources++
	else
		if(locate(/obj/structure/blob/special/core) in blobs_in_area)
			adjustHealth(-maxHealth*BLOBMOB_BLOBBERNAUT_HEALING_CORE * delta_time)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(src)) //hello yes you are being healed
			if(overmind)
				H.color = overmind.blobstrain.complementary_color
			else
				H.color = "#000000"
		if(locate(/obj/structure/blob/special/node) in blobs_in_area)
			adjustHealth(-maxHealth*BLOBMOB_BLOBBERNAUT_HEALING_NODE * delta_time)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(src))
			if(overmind)
				H.color = overmind.blobstrain.complementary_color
			else
				H.color = "#000000"

	if(!damagesources)
		return

	adjustHealth(maxHealth * BLOBMOB_BLOBBERNAUT_HEALTH_DECAY * damagesources * delta_time) //take 2.5% of max health as damage when not near the blob or if the naut has no factory, 5% if both
	var/image/I = new('icons/mob/blob.dmi', src, "nautdamage", MOB_LAYER+0.01)
	I.appearance_flags = RESET_COLOR

	if(overmind)
		I.color = overmind.blobstrain.complementary_color

	flick_overlay_view(I, src, 8)

/mob/living/simple_animal/hostile/blob/blobbernaut/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(updating_health)
		update_health_hud()

/mob/living/simple_animal/hostile/blob/blobbernaut/update_health_hud()
	if(hud_used)
		hud_used.healths.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round((health / maxHealth) * 100, 0.5)]%</font></div>")

/mob/living/simple_animal/hostile/blob/blobbernaut/AttackingTarget()
	. = ..()
	if(. && isliving(target) && overmind)
		overmind.blobstrain.blobbernaut_attack(target)

/mob/living/simple_animal/hostile/blob/blobbernaut/update_icons()
	..()
	if(overmind) //if we have an overmind, we're doing chemical reactions instead of pure damage
		melee_damage = BLOBMOB_BLOBBERNAUT_DMG
		attack_verb_continuous = overmind.blobstrain.blobbernaut_message
	else
		melee_damage = BLOBMOB_BLOBBERNAUT_DMG_SOLO
		attack_verb_continuous = overmind.blobstrain.blobbernaut_message

/mob/living/simple_animal/hostile/blob/blobbernaut/death(gibbed)
	..(gibbed)
	if(factory)
		factory.naut = null //remove this naut from its factory
		factory.max_integrity = initial(factory.max_integrity)
	flick("blobbernaut_death", src)

/mob/living/simple_animal/hostile/blob/blobbernaut/independent
	independent = TRUE
	gold_core_spawnable = HOSTILE_SPAWN

