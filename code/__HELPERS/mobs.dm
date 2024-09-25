//check_target_facings() return defines
/// Two mobs are facing the same direction
#define FACING_SAME_DIR 1
/// Two mobs are facing each others
#define FACING_EACHOTHER 2
/// Two mobs one is facing a person, but the other is perpendicular
#define FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR 3 //! Do I win the most informative but also most stupid define award?

/proc/random_blood_type()
	return pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")

/proc/random_eye_color()
	switch(pick(20;"brown",20;"hazel",20;"grey",15;"blue",15;"green",1;"amber",1;"albino"))
		if("brown")
			return "630"
		if("hazel")
			return "542"
		if("grey")
			return pick("666","777","888","999","aaa","bbb","ccc")
		if("blue")
			return "36c"
		if("green")
			return "060"
		if("amber")
			return "fc0"
		if("albino")
			return pick("c","d","e","f") + pick("0","1","2","3","4","5","6","7","8","9") + pick("0","1","2","3","4","5","6","7","8","9")
		else
			return "000"

/proc/random_underwear(gender)
	if(!GLOB.underwear_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear, GLOB.underwear_list, GLOB.underwear_m, GLOB.underwear_f)
	switch(gender)
		if(MALE)
			return pick(GLOB.underwear_m)
		if(FEMALE)
			return pick(GLOB.underwear_f)
		else
			return pick(GLOB.underwear_list)

/proc/random_undershirt(gender)
	if(!GLOB.undershirt_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/undershirt, GLOB.undershirt_list, GLOB.undershirt_m, GLOB.undershirt_f)
	switch(gender)
		if(MALE)
			return pick(GLOB.undershirt_m)
		if(FEMALE)
			return pick(GLOB.undershirt_f)
		else
			return pick(GLOB.undershirt_list)

/proc/random_socks()
	if(!GLOB.socks_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/socks, GLOB.socks_list)
	return pick(GLOB.socks_list)

/proc/random_features(gender)
	if(!GLOB.tails_list_human.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/human, GLOB.tails_list_human)
	if(!GLOB.tails_roundstart_list_human.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/human, GLOB.tails_roundstart_list_human)
	if(!GLOB.tails_list_lizard.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/lizard, GLOB.tails_list_lizard)
	if(!GLOB.snouts_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts, GLOB.snouts_list)
	if(!GLOB.horns_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/horns, GLOB.horns_list)
	if(!GLOB.ears_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/ears, GLOB.horns_list)
	if(!GLOB.frills_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/frills, GLOB.frills_list)
	if(!GLOB.spines_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/spines, GLOB.spines_list)
	if(!GLOB.legs_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/legs, GLOB.legs_list)
	if(!GLOB.body_markings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings, GLOB.body_markings_list)
	if(!GLOB.wings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/wings, GLOB.wings_list)
	if(!GLOB.moth_wings_roundstart_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_wings, GLOB.moth_wings_roundstart_list)
	if(!GLOB.moth_antennae_roundstart_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_antennae, GLOB.moth_antennae_roundstart_list)
	if(!GLOB.moth_markings_roundstart_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_markings, GLOB.moth_markings_roundstart_list)
	if(!GLOB.ipc_screens_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/ipc_screens, GLOB.ipc_screens_list)
	if(!GLOB.ipc_antennas_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/ipc_antennas, GLOB.ipc_antennas_list)
	if(!GLOB.ipc_chassis_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/ipc_chassis, GLOB.ipc_chassis_list)
	if(!GLOB.insect_type_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/insect_type, GLOB.insect_type_list)
	if(!GLOB.apid_antenna_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/apid_antenna, GLOB.apid_antenna_list)
	if(!GLOB.apid_stripes_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/apid_stripes, GLOB.apid_stripes_list)
	if(!GLOB.apid_headstripes_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/apid_headstripes, GLOB.apid_headstripes_list)
	if(!GLOB.psyphoza_cap_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/psyphoza_cap, GLOB.psyphoza_cap_list)
	//For now we will always return none for tail_human and ears.
	return(
		list(
		"body_size" = "Normal",
		"mcolor" = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F"),
		"ethcolor" = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)],
		"tail_lizard" = pick(GLOB.tails_list_lizard),
		"tail_human" = "None",
		"wings" = "None",
		"snout" = pick(GLOB.snouts_list),
		"horns" = pick(GLOB.horns_list),
		"ears" = "None",
		"frills" = pick(GLOB.frills_list),
		"spines" = pick(GLOB.spines_list),
		"body_markings" = pick(GLOB.body_markings_list),
		"legs" = "Normal Legs",
		"caps" = pick(GLOB.caps_list),
		"moth_wings" = pick(GLOB.moth_wings_roundstart_list),
		"moth_antennae" = pick(GLOB.moth_antennae_roundstart_list),
		"moth_markings" = pick(GLOB.moth_markings_roundstart_list),
		"ipc_screen" = pick(GLOB.ipc_screens_list),
		"ipc_antenna" = pick(GLOB.ipc_antennas_list),
		"ipc_chassis" = pick(GLOB.ipc_chassis_list),
		"insect_type" = pick(GLOB.insect_type_list),
		"apid_antenna" = pick(GLOB.apid_antenna_list),
		"apid_stripes" = pick(GLOB.apid_stripes_list),
		"apid_headstripes" = pick(GLOB.apid_headstripes_list),
		"body_model" = gender == MALE ? MALE : gender == FEMALE ? FEMALE : pick(MALE, FEMALE),
		"psyphoza_cap" = pick(GLOB.psyphoza_cap_list)
		)
	)

/proc/random_hair_style(gender)
	switch(gender)
		if(MALE)
			return pick(GLOB.hair_styles_male_list)
		if(FEMALE)
			return pick(GLOB.hair_styles_female_list)
		else
			return pick(GLOB.hair_styles_list)

/proc/random_facial_hair_style(gender)
	switch(gender)
		if(MALE)
			return pick(GLOB.facial_hair_styles_male_list)
		if(FEMALE)
			return pick(GLOB.facial_hair_styles_female_list)
		else
			return pick(GLOB.facial_hair_styles_list)

/proc/random_unique_name(gender, attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		if(gender==FEMALE)
			. = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
		else if(gender==MALE)
			. = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
		else
			. = capitalize(pick(GLOB.first_names)) + " " + capitalize(pick(GLOB.last_names))

		if(!findname(.))
			break

/proc/random_lizard_name(gender, attempts)
	if(gender == MALE)
		. = "[pick(GLOB.lizard_names_male)]-[pick(GLOB.lizard_names_male)]"
	else
		. = "[pick(GLOB.lizard_names_female)]-[pick(GLOB.lizard_names_female)]"

	if(attempts < 10)
		if(findname(.))
			. = .(gender, ++attempts)

/proc/random_skin_tone()
	return pick(GLOB.skin_tones)

GLOBAL_LIST_INIT(skin_tones, sort_list(list(
	"albino",
	"caucasian1",
	"caucasian2",
	"caucasian3",
	"latino",
	"mediterranean",
	"asian1",
	"asian2",
	"arab",
	"indian",
	"african1",
	"african2"
	)))

GLOBAL_LIST_INIT(skin_tone_names, list(
	"african1" = "Medium brown",
	"african2" = "Dark brown",
	"albino" = "Albino",
	"arab" = "Light brown",
	"asian1" = "Ivory",
	"asian2" = "Beige",
	"caucasian1" = "Porcelain",
	"caucasian2" = "Light peach",
	"caucasian3" = "Peach",
	"indian" = "Brown",
	"latino" = "Light beige",
	"mediterranean" = "Olive",
))

/// An assoc list of species IDs to type paths
GLOBAL_LIST_EMPTY(species_list)

/proc/age2agedescription(age)
	switch(age)
		if(0 to 1)
			return "infant"
		if(1 to 3)
			return "toddler"
		if(3 to 13)
			return "child"
		if(13 to 19)
			return "teenager"
		if(19 to 30)
			return "young adult"
		if(30 to 45)
			return "adult"
		if(45 to 60)
			return "middle-aged"
		if(60 to 70)
			return "aging"
		if(70 to INFINITY)
			return "elderly"
		else
			return "unknown"

//some additional checks as a callback for for do_afters that want to break on losing health or on the mob taking action
/mob/proc/break_do_after_checks(list/checked_health, check_clicks)
	if(check_clicks && next_move > world.time)
		return FALSE
	return TRUE

//pass a list in the format list("health" = mob's health var) to check health during this
/mob/living/break_do_after_checks(list/checked_health, check_clicks)
	if(islist(checked_health))
		if(health < checked_health["health"])
			return FALSE
		checked_health["health"] = health
	return ..()

/**
 * Timed action involving one mob user. A target can also be specified, but it is optional.
 *
 * Checks that `user` does not move, change hands, get stunned, etc. for the
 * given `delay`. Returns `TRUE` on success or `FALSE` on failure.
 *
 * Arguments:
 * * user - the primary "user" of the do_after.
 * * delay - how long the do_after takes. Defaults to 3 SECONDS.
 * * target - the (optional) target mob of the do_after. If they move/cease to exist, the do_after is cancelled.
 * * timed_action_flags - optional flags to override certain do_after checks (see DEFINES/timed_action.dm).
 * * progress - if TRUE, a progress bar is displayed.
 * * extra_checks - a callback that can be used to add extra checks to the do_after. Returning false in this callback will cancel the do_after.
 */
/proc/do_after(mob/user, delay = 3 SECONDS, atom/target, timed_action_flags = NONE, progress = TRUE, datum/callback/extra_checks)
	if(!user)
		return FALSE

	if(target)
		LAZYADD(user.do_afters, target)
		LAZYADD(target.targeted_by, user)

	var/atom/user_loc = user.loc
	var/atom/target_loc = target?.loc

	var/drifting = FALSE
	if(SSmove_manager.processing_on(user, SSspacedrift))
		drifting = TRUE

	var/holding = user.get_active_held_item()

	delay *= user.cached_multiplicative_actions_slowdown

	var/datum/progressbar/progbar
	if(progress)
		if(target) // the progress bar needs a target, so if we don't have one just pass it the user.
			progbar = new(user, delay, target)
		else
			progbar = new(user, delay, user)

	var/endtime = world.time + delay
	var/starttime = world.time
	. = TRUE
	while(world.time < endtime)
		stoplag(1)

		if(QDELETED(user))
			. = FALSE
			break

		if(progress)
			progbar.update(world.time - starttime)

		if(drifting && SSmove_manager.processing_on(user, SSspacedrift))
			drifting = FALSE
			user_loc = user.loc

		// Check flags
		if(!(timed_action_flags & IGNORE_USER_LOC_CHANGE) && !drifting && user.loc != user_loc)
			. = FALSE

		if(!(timed_action_flags & IGNORE_HELD_ITEM) && user.get_active_held_item() != holding)
			. = FALSE

		if(!(timed_action_flags & IGNORE_INCAPACITATED) && user.incapacitated(ignore_restraints = (timed_action_flags & IGNORE_RESTRAINED)))
			. = FALSE


		if(extra_checks && !extra_checks.Invoke())
			. = FALSE

		// If we have a target, we check for them moving here. We don't care about it if we're drifting or we ignore target loc change
		if(!(timed_action_flags & IGNORE_TARGET_LOC_CHANGE) && !drifting)
			if(target_loc && user != target && (QDELETED(target) || target_loc != target.loc))
				. = FALSE

		if(target && !(timed_action_flags & IGNORE_TARGET_IN_DOAFTERS) && !(target in user.do_afters))
			. = FALSE

		if(!.)
			break

	if(progress)
		qdel(progbar)

	if(!QDELETED(target))
		LAZYREMOVE(user.do_afters, target)
		LAZYREMOVE(target.targeted_by, user)

/proc/is_species(A, species_datum)
	. = FALSE
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.dna && istype(H.dna.species, species_datum))
			. = TRUE

/proc/spawn_atom_to_turf(spawn_type, target, amount, admin_spawn=FALSE, list/extra_args)
	var/turf/T = get_turf(target)
	if(!T)
		CRASH("attempt to spawn atom type: [spawn_type] in nullspace")

	var/list/new_args = list(T)
	if(extra_args)
		new_args += extra_args
	var/atom/X
	for(var/j in 1 to amount)
		X = new spawn_type(arglist(new_args))
		if (admin_spawn)
			X.flags_1 |= ADMIN_SPAWNED_1
	return X //return the last mob spawned

/proc/spawn_and_random_walk(spawn_type, target, amount, walk_chance=100, max_walk=3, always_max_walk=FALSE, admin_spawn=FALSE)
	var/turf/T = get_turf(target)
	var/step_count = 0
	if(!T)
		CRASH("attempt to spawn atom type: [spawn_type] in nullspace")

	var/list/spawned_mobs = new(amount)

	for(var/j in 1 to amount)
		var/atom/movable/X

		if (istype(spawn_type, /list))
			var/mob_type = pick(spawn_type)
			X = new mob_type(T)
		else
			X = new spawn_type(T)

		if (admin_spawn)
			X.flags_1 |= ADMIN_SPAWNED_1

		spawned_mobs[j] = X

		if(always_max_walk || prob(walk_chance))
			if(always_max_walk)
				step_count = max_walk
			else
				step_count = rand(1, max_walk)

			for(var/i in 1 to step_count)
				step(X, pick(NORTH, SOUTH, EAST, WEST))

	return spawned_mobs

/proc/deadchat_broadcast(message, mob/follow_target=null, turf/turf_target=null, speaker_key=null, message_type=DEADCHAT_REGULAR)
	message = "<span class='linkify'>[message]</span>"
	for(var/mob/M in GLOB.player_list)
		var/death_rattle = TRUE
		var/arrivals_rattle = TRUE
		var/dchat = FALSE
		var/ghostlaws = TRUE
		var/list/ignoring
		if(M?.client.prefs)
			var/datum/preferences/prefs = M.client.prefs
			ignoring = prefs.ignoring
			death_rattle = prefs.read_player_preference(/datum/preference/toggle/death_rattle)
			arrivals_rattle = prefs.read_player_preference(/datum/preference/toggle/arrivals_rattle)
			dchat = prefs.read_player_preference(/datum/preference/toggle/chat_dead)
			ghostlaws = prefs.read_player_preference(/datum/preference/toggle/chat_ghostlaws)

		var/override = FALSE
		if(M?.client.holder && dchat)
			override = TRUE
		if(HAS_TRAIT(M, TRAIT_SIXTHSENSE))
			override = TRUE
		if(SSticker.current_state == GAME_STATE_FINISHED)
			override = TRUE
		if(isnewplayer(M) && !override)
			continue
		if(M.stat != DEAD && !override)
			continue
		if(speaker_key && (speaker_key in ignoring))
			continue

		switch(message_type)
			if(DEADCHAT_DEATHRATTLE)
				if(!death_rattle)
					continue
			if(DEADCHAT_ARRIVALRATTLE)
				if(!arrivals_rattle)
					continue
			if(DEADCHAT_LAWCHANGE)
				if(!ghostlaws)
					continue

		if(isobserver(M))
			var/rendered_message = message

			if(follow_target)
				var/F
				if(turf_target)
					F = FOLLOW_OR_TURF_LINK(M, follow_target, turf_target)
				else
					F = FOLLOW_LINK(M, follow_target)
				rendered_message = "[F] [message]"
			else if(turf_target)
				var/turf_link = TURF_LINK(M, turf_target)
				rendered_message = "[turf_link] [message]"

			to_chat(M, rendered_message, avoid_highlighting = speaker_key == M.key)
		else
			to_chat(M, message, avoid_highlighting = speaker_key == M.key)

//Used in chemical_mob_spawn. Generates a random mob based on a given gold_core_spawnable value.
/proc/create_random_mob(spawn_location, mob_class = HOSTILE_SPAWN)
	var/static/list/mob_spawn_meancritters = list() // list of possible hostile mobs
	var/static/list/mob_spawn_nicecritters = list() // and possible friendly mobs

	if(mob_spawn_meancritters.len <= 0 || mob_spawn_nicecritters.len <= 0)
		for(var/T in typesof(/mob/living/simple_animal))
			var/mob/living/simple_animal/SA = T
			switch(initial(SA.gold_core_spawnable))
				if(HOSTILE_SPAWN)
					mob_spawn_meancritters += T
				if(FRIENDLY_SPAWN)
					mob_spawn_nicecritters += T
		for(var/mob/living/basic/basic_mob as anything in typesof(/mob/living/basic))
			switch(initial(basic_mob.gold_core_spawnable))
				if(HOSTILE_SPAWN)
					mob_spawn_meancritters += basic_mob
				if(FRIENDLY_SPAWN)
					mob_spawn_nicecritters += basic_mob

	var/chosen
	if(mob_class == FRIENDLY_SPAWN)
		chosen = pick(mob_spawn_nicecritters)
	else
		chosen = pick(mob_spawn_meancritters)
	var/mob/living/spawned_mob = new chosen(spawn_location)
	return spawned_mob

/proc/passtable_on(target, source)
	var/mob/living/L = target
	if (!HAS_TRAIT(L, TRAIT_PASSTABLE) && L.pass_flags & PASSTABLE)
		ADD_TRAIT(L, TRAIT_PASSTABLE, INNATE_TRAIT)
	ADD_TRAIT(L, TRAIT_PASSTABLE, source)
	L.pass_flags |= PASSTABLE

/proc/passtable_off(target, source)
	var/mob/living/L = target
	REMOVE_TRAIT(L, TRAIT_PASSTABLE, source)
	if(!HAS_TRAIT(L, TRAIT_PASSTABLE))
		L.pass_flags &= ~PASSTABLE

//Gets the sentient mobs that are not on centcom and are alive
/proc/get_sentient_mobs()
	. = list()
	for(var/mob/living/player in GLOB.mob_living_list)
		if(player.stat != DEAD && player.mind && !is_centcom_level(player.z) && !isnewplayer(player) && !isbrain(player))
			. |= player

//Gets all sentient humans that are alive
/proc/get_living_crew()
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.mob_living_list)
		if(player.stat != DEAD && player.mind)
			. |= player

//Gets all sentient humans that are on the station
/proc/get_living_station_crew()
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.mob_living_list)
		if(player.stat != DEAD && player.mind && is_station_level(player.z))
			. |= player

//Gets all the minds of humans that are on station
/proc/get_living_station_minds()
	. = list()
	for(var/mob/living/carbon/human/player in GLOB.mob_living_list)
		if(player.stat != DEAD && player.mind && is_station_level(player.z))
			. |= player.mind

/// Gets the client of the mob, allowing for mocking of the client.
/// You only need to use this if you know you're going to be mocking clients somewhere else.
#define GET_CLIENT(mob) (##mob.client || ##mob.mock_client)

///Return a string for the specified body zone. Should be used for parsing non-instantiated bodyparts, otherwise use [/obj/item/bodypart/var/plaintext_zone]
/proc/parse_zone(zone)
	switch(zone)
		if(BODY_ZONE_CHEST)
			return "chest"
		if(BODY_ZONE_HEAD)
			return "head"
		if(BODY_ZONE_PRECISE_R_HAND)
			return "right hand"
		if(BODY_ZONE_PRECISE_L_HAND)
			return "left hand"
		if(BODY_ZONE_L_ARM)
			return "left arm"
		if(BODY_ZONE_R_ARM)
			return "right arm"
		if(BODY_ZONE_L_LEG)
			return "left leg"
		if(BODY_ZONE_R_LEG)
			return "right leg"
		if(BODY_ZONE_PRECISE_L_FOOT)
			return "left foot"
		if(BODY_ZONE_PRECISE_R_FOOT)
			return "right foot"
		else
			return zone

///Returns the direction that the initiator and the target are facing
/proc/check_target_facings(mob/living/initator, mob/living/target)
	/*This can be used to add additional effects on interactions between mobs depending on how the mobs are facing each other, such as adding a crit damage to blows to the back of a guy's head.
	Given how click code currently works (Nov '13), the initiating mob will be facing the target mob most of the time
	That said, this proc should not be used if the change facing proc of the click code is overridden at the same time*/
	if(!ismob(target) || !(target.mobility_flags & MOBILITY_STAND))
	//Make sure we are not doing this for things that can't have a logical direction to the players given that the target would be on their side
		return FALSE
	if(initator.dir == target.dir) //mobs are facing the same direction
		return FACING_SAME_DIR
	if(is_source_facing_target(initator,target) && is_source_facing_target(target,initator)) //mobs are facing each other
		return FACING_EACHOTHER
	if(initator.dir + 2 == target.dir || initator.dir - 2 == target.dir || initator.dir + 6 == target.dir || initator.dir - 6 == target.dir) //Initating mob is looking at the target, while the target mob is looking in a direction perpendicular to the 1st
		return FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR

///Returns the occupant mob or brain from a specified input
/proc/get_mob_or_brainmob(occupant)
	var/mob/living/mob_occupant

	if(isliving(occupant))
		mob_occupant = occupant

	else if(isbodypart(occupant))
		var/obj/item/bodypart/head/head = occupant

		mob_occupant = head.brainmob

	else if(isorgan(occupant))
		var/obj/item/organ/brain/brain = occupant
		mob_occupant = brain.brainmob

	return mob_occupant

///Returns the amount of currently living players
/proc/living_player_count()
	var/living_player_count = 0
	for(var/mob in GLOB.player_list)
		if(mob in GLOB.alive_mob_list)
			living_player_count += 1
	return living_player_count

GLOBAL_DATUM_INIT(dview_mob, /mob/dview, new)

///Version of view() which ignores darkness, because BYOND doesn't have it (I actually suggested it but it was tagged redundant, BUT HEARERS IS A T- /rant).
/proc/dview(range = world.view, center, invis_flags = 0)
	if(!center)
		return

	GLOB.dview_mob.loc = center

	GLOB.dview_mob.see_invisible = invis_flags

	. = view(range, GLOB.dview_mob)
	GLOB.dview_mob.loc = null

/mob/dview
	name = "INTERNAL DVIEW MOB"
	invisibility = 101
	density = FALSE
	see_in_dark = 1e6
	move_resist = INFINITY
	var/ready_to_die = FALSE

/mob/dview/Initialize(mapload) //Properly prevents this mob from gaining huds or joining any global lists
	SHOULD_CALL_PARENT(FALSE)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1
	return INITIALIZE_HINT_NORMAL

/mob/dview/Destroy(force = FALSE)
	if(!ready_to_die)
		stack_trace("ALRIGHT WHICH FUCKER TRIED TO DELETE *MY* DVIEW?")

		if (!force)
			return QDEL_HINT_LETMELIVE

		log_world("EVACUATE THE SHITCODE IS TRYING TO STEAL MUH JOBS")
		GLOB.dview_mob = new
	return ..()


#define FOR_DVIEW(type, range, center, invis_flags) \
	GLOB.dview_mob.loc = center;           \
	GLOB.dview_mob.see_invisible = invis_flags; \
	for(type in view(range, GLOB.dview_mob))

#define FOR_DVIEW_END GLOB.dview_mob.loc = null

///Makes a call in the context of a different usr. Use sparingly
/world/proc/push_usr(mob/user_mob, datum/callback/invoked_callback, ...)
	var/temp = usr
	usr = user_mob
	if (length(args) > 2)
		. = invoked_callback.Invoke(arglist(args.Copy(3)))
	else
		. = invoked_callback.Invoke()
	usr = temp

/proc/invertDir(var/input_dir)
	switch(input_dir)
		if(UP)
			return DOWN
		if(DOWN)
			return UP
		if(-INFINITY to 0, 11 to INFINITY)
			CRASH("Can't turn invalid directions!")
	return turn(input_dir, 180)


///////////////////////
///Silicon Mob Procs///
///////////////////////

/// Returns a list of unslaved cyborgs
/proc/active_free_borgs()
	. = list()
	for(var/mob/living/silicon/robot/borg in GLOB.silicon_mobs)
		if(borg.connected_ai || borg.shell)
			continue
		if(borg.stat == DEAD)
			continue
		if(borg.emagged || borg.scrambledcodes)
			continue
		. += borg

/// Returns a list of AI's
/proc/active_ais(check_mind=FALSE)
	. = list()
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		if(ai.stat == DEAD)
			continue
		if(ai.control_disabled)
			continue
		if(check_mind)
			if(!ai.mind)
				continue
		. += ai

/// Find an active ai with the least borgs. VERBOSE PROCNAME HUH!
/proc/select_active_ai_with_fewest_borgs()
	var/mob/living/silicon/ai/selected
	var/list/active = active_ais()
	for(var/mob/living/silicon/ai/A in active)
		if((!selected || (selected.connected_robots.len > A.connected_robots.len)) && !is_servant_of_ratvar(A))
			selected = A

	return selected

/// Select a random active and free borg
/proc/select_active_free_borg(mob/user)
	var/list/borgs = active_free_borgs()
	if(borgs.len)
		if(user)
			. = input(user,"Unshackled cyborg signals detected:", "Cyborg Selection", borgs[1]) in sort_list(borgs)
		else
			. = pick(borgs)
	return .

/// Select a random and active free AI
/proc/select_active_ai(mob/user)
	var/list/ais = active_ais()
	if(ais.len)
		if(user)
			. = input(user,"AI signals detected:", "AI Selection", ais[1]) in sort_list(ais)
		else
			. = pick(ais)
	return .

//// Generalised helper proc for letting mobs rename themselves. Used to be clname() and ainame()
/mob/proc/apply_pref_name(preference_type, client/C)
	if(!C)
		C = client
	var/oldname = real_name
	var/newname
	var/loop = 1
	var/safety = 0

	var/banned = C ? is_banned_from(C.ckey, "Appearance") : null

	while(loop && safety < 5)
		if(!safety && !banned)
			newname = C?.prefs?.read_character_preference(preference_type)
		else
			var/datum/preference/preference = GLOB.preference_entries[preference_type]
			newname = preference.create_informed_default_value(C.prefs)

		for(var/mob/living/M in GLOB.player_list)
			if(M == src)
				continue
			if(!newname || M.real_name == newname)
				newname = null
				loop++ // name is already taken so we roll again
				break
		loop--
		safety++

	if(newname)
		fully_replace_character_name(oldname,newname)
		return TRUE
	return FALSE

/proc/view_or_range(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = view(distance,center)
		if("range")
			. = range(distance,center)
	return

//Currently not used
/proc/oview_or_orange(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = oview(distance,center)
		if("range")
			. = orange(distance,center)
	return

/**
 * Gets the mind from a variable, whether it be a mob, or a mind itself.
 * If [include_last] is true, then it will also return last_mind for carbons if there isn't a current mind.
 */
/proc/get_mind(target, include_last = FALSE)
	if(istype(target, /datum/mind))
		return target
	if(ismob(target))
		var/mob/mob_target = target
		if(!QDELETED(mob_target.mind))
			return mob_target.mind
		if(include_last && iscarbon(mob_target))
			var/mob/living/carbon/carbon_target = mob_target
			if(!QDELETED(carbon_target.last_mind))
				return carbon_target.last_mind

#undef FACING_SAME_DIR
#undef FACING_EACHOTHER
#undef FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR
