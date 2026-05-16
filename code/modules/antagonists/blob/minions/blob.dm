
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
	maxbodytemp = INFINITY
	unique_name = 1
	combat_mode = TRUE
	see_in_dark = NIGHTVISION_FOV_RANGE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	initial_language_holder = /datum/language_holder/empty
	retreat_distance = null //! retreat doesn't obey pass_flags, so won't work on blob mobs.

	mobchatspan = "blob"
	discovery_points = 1000

	/// Blob camera that controls the blob
	var/mob/camera/blob/overmind = null
	/// If this is related to anything else
	var/independent = FALSE
	/// The factory blob tile that generated this blob minion
	var/obj/structure/blob/special/factory/factory

/mob/living/simple_animal/hostile/blob/update_icons()
	if(overmind)
		add_atom_colour(overmind.blobstrain.color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/hostile/blob/Initialize(mapload)
	. = ..()
	if(!independent || overmind) //no pulling people deep into the blob
		remove_verb(/mob/living/verb/pulled)
		GLOB.blob_telepathy_mobs |= src
	else
		pass_flags &= ~PASSBLOB

/mob/living/simple_animal/hostile/blob/death()
	factory = null
	if(overmind)
		overmind.blob_mobs -= src
	overmind = null
	return ..()

/mob/living/simple_animal/hostile/blob/get_stat_tab_status()
	var/list/tab_data = ..()
	if(overmind)
		tab_data["Blobs to Win"] = GENERATE_STAT_TEXT("[overmind.blobs_legit.len]/[overmind.blobwincount]")
	return tab_data

/mob/living/simple_animal/hostile/blob/blob_act(obj/structure/blob/B)
	if(stat != DEAD && health < maxHealth)
		for(var/unused in 1 to 2)
			var/obj/effect/temp_visual/heal/heal_effect = new /obj/effect/temp_visual/heal(get_turf(src)) //hello yes you are being healed
			if(overmind)
				heal_effect.color = overmind.blobstrain.complementary_color
			else
				heal_effect.color = COLOR_BLACK
		adjustHealth(-maxHealth*BLOBMOB_HEALING_MULTIPLIER)

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

///override to use astar/JPS instead of walk_to so we can take our blob pass_flags into account.
/mob/living/simple_animal/hostile/blob/Goto(target, delay, minimum_distance)
	if(prevent_goto_movement)
		return FALSE
	if(target == src.target)
		approaching_target = TRUE
	else
		approaching_target = FALSE

	SSmove_manager.jps_move(moving = src, chasing = target, delay = delay, repath_delay = 2 SECONDS, minimum_distance = minimum_distance, simulated_only = FALSE, skip_first = TRUE, timeout = 5 SECONDS, flags = MOVEMENT_LOOP_IGNORE_GLIDE)
	return TRUE

/mob/living/simple_animal/hostile/blob/Process_Spacemove(movement_dir = 0)
	for(var/obj/structure/blob/blob in range(1, src))
		return 1
	return ..()

/mob/living/simple_animal/hostile/blob/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, message_range = 7, datum/saymode/saymode = null)
	for(var/M in GLOB.mob_list)
		INVOKE_ASYNC(src, PROC_REF(send_blob_telepathy), message)
		return

/mob/living/simple_animal/hostile/blob/proc/send_blob_telepathy(message)
	var/list/message_mods = list()
	// Note: check_for_custom_say_emote can sleep.
	var/adjusted_message = src.check_for_custom_say_emote(message, message_mods)
	src.log_sayverb_talk(message, message_mods, tag = "blob hivemind telepathy")
	var/spanned_message = src.generate_messagepart(adjusted_message, message_mods = message_mods)
	var/rendered = span_blob("<b>\[Blob Telepathy\] [src.real_name]</b> [spanned_message]")
	relay_to_list_and_observers(rendered, GLOB.blob_telepathy_mobs, src, MESSAGE_TYPE_RADIO)
