/// Battle hallucination, makes it sound like a melee or gun battle is going on in the background.
/datum/hallucination/battle
	abstract_hallucination_parent = /datum/hallucination/battle
	random_hallucination_weight = 3

/// Helper to play a 3D sound to the hallucinator.
/datum/hallucination/battle/proc/play_battle_sound(turf/source, soundin, vol = 70, vary = TRUE, max_distance = SOUND_RANGE)
	if(QDELETED(hallucinator) || !source || !soundin)
		return
	hallucinator.playsound_local(source, soundin, vol = vol, vary = vary, max_distance = max_distance)

/// Helper proc for battle hallucinations to retrieve an appropriate crewmember scream sound, or a default human scream.
/datum/hallucination/battle/proc/get_scream_sound()
	var/list/datum/mind/crew = get_crewmember_minds()
	if(length(crew))
		var/datum/mind/screamer_mind = pick(crew)
		var/mob/living/carbon/human/screamer_mob = screamer_mind?.current
		if(istype(screamer_mob))
			var/scream = screamer_mob.dna?.species?.get_scream_sound(screamer_mob)
			if(scream)
				return scream

	return pick(
		'sound/voice/human/femalescream_1.ogg',
		'sound/voice/human/femalescream_2.ogg',
		'sound/voice/human/femalescream_3.ogg',
		'sound/voice/human/femalescream_4.ogg',
		'sound/voice/human/malescream_1.ogg',
		'sound/voice/human/malescream_2.ogg',
		'sound/voice/human/malescream_3.ogg',
		'sound/voice/human/malescream_4.ogg',
		'sound/voice/human/malescream_5.ogg',
	)

/// Subtype of battle hallucination for gun based battles, where it sounds like someone is being shot.
/datum/hallucination/battle/gun
	abstract_hallucination_parent = /datum/hallucination/battle/gun
	/// The lower end to how many shots we'll fire.
	var/shots_to_fire_lower_range = 3
	/// The upper end to how many shots we'll fire.
	var/shots_to_fire_upper_range = 6
	/// The sound effect or list of sound effects we play when we "fire" a shot. If a list, one is picked at start.
	var/fire_sound = 'sound/weapons/shotgunshot.ogg'
	/// The sound we make when our shot actually "hits" "someone".
	var/hit_person_sound = 'sound/weapons/pierce.ogg'
	/// The sound we make when our shot misses someone and "hits" a "wall".
	var/hit_wall_sound = "ricochet"
	/// The number of successful hits required to "down" the "someone" we're firing at.
	var/number_of_hits_to_end = 2
	/// The probability chance we have to make our "hit" person fall down after we pass the number_of_hits_to_end.
	var/chance_to_fall = 80
	/// Base volume of the gun sound effects before distance falloff.
	var/volume = 70

/datum/hallucination/battle/gun/start()
	if(islist(fire_sound))
		fire_sound = pick(fire_sound)
	fire_loop(random_far_turf(), rand(shots_to_fire_lower_range, shots_to_fire_upper_range))
	return TRUE

/// The main loop for gun based hallucinations.
/datum/hallucination/battle/gun/proc/fire_loop(turf/source, shots_left = 3, hits = 0)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return

	// We shoot our shot.
	play_battle_sound(source, fire_sound, volume, TRUE)

	// Shortly after shooting our shot, it plays a hit (or miss) sound.
	var/next_hit_sound = rand(0.5 SECONDS, 1 SECONDS)
	if(prob(50))
		addtimer(CALLBACK(src, PROC_REF(play_battle_sound), source, hit_person_sound, volume), next_hit_sound)
		hits++
	else
		addtimer(CALLBACK(src, PROC_REF(play_battle_sound), source, hit_wall_sound, volume), next_hit_sound)

	// If we scored enough hits, we have a chance to knock them down and stop the hallucination early.
	if(hits >= number_of_hits_to_end && prob(chance_to_fall))
		addtimer(CALLBACK(src, PROC_REF(down_target), source), next_hit_sound)
		return

	// Or, if we do have shots left, keep it going.
	if(shots_left > 0)
		shots_left--
		source = get_step(source, pick(GLOB.alldirs)) || source
		addtimer(CALLBACK(src, PROC_REF(fire_loop), source, shots_left, hits), rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 6))
	else
		QDEL_IN(src, 1 SECONDS)

/// Knocks down the target in a gunfight with a bodyfall and scream.
/datum/hallucination/battle/gun/proc/down_target(turf/source)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return

	play_battle_sound(source, "bodyfall", volume)
	if(prob(60))
		addtimer(CALLBACK(src, PROC_REF(play_battle_sound), source, get_scream_sound(), volume), 0.2 SECONDS)
	QDEL_IN(src, 1 SECONDS)

/// Gun battle hallucination with ballistic weapon fire and ricochets.
/datum/hallucination/battle/gun/ballistic
	shots_to_fire_lower_range = 3
	shots_to_fire_upper_range = 6
	fire_sound = list( // someone port sound keys
		'sound/weapons/shotgunshot.ogg',
		'sound/weapons/revolver38shot.ogg',
		'sound/weapons/revolver357shot.ogg',
		'sound/weapons/rifleshot.ogg',
		'sound/weapons/smgshot.ogg',
		'sound/weapons/nps10/NPS-fire.ogg',
	)
	hit_person_sound = 'sound/weapons/pierce.ogg'
	hit_wall_sound = "ricochet"
	number_of_hits_to_end = 2
	chance_to_fall = 80
	volume = 80

/// Gun battle hallucination that sounds like disabler fire.
/datum/hallucination/battle/gun/disabler
	shots_to_fire_lower_range = 5
	shots_to_fire_upper_range = 10
	fire_sound = 'sound/weapons/taser2.ogg'
	hit_person_sound = 'sound/weapons/tap.ogg'
	hit_wall_sound = 'sound/weapons/effects/searwall.ogg'
	number_of_hits_to_end = 3
	chance_to_fall = 70
	volume = 60

/// Gun battle hallucination that sounds like laser fire.
/datum/hallucination/battle/gun/laser
	shots_to_fire_lower_range = 5
	shots_to_fire_upper_range = 10
	fire_sound = list(
		'sound/weapons/laser.ogg',
		'sound/weapons/laser3.ogg',
		'sound/weapons/pulse.ogg',
		'sound/weapons/pulse3.ogg',
	)
	hit_person_sound = 'sound/weapons/sear.ogg'
	hit_wall_sound = 'sound/weapons/effects/searwall.ogg'
	number_of_hits_to_end = 4
	chance_to_fall = 70
	volume = 70

/// Subtype of battle hallucination for melee fights.
/datum/hallucination/battle/melee
	abstract_hallucination_parent = /datum/hallucination/battle/melee
	/// Lower bound for melee hits.
	var/hits_lower_range = 3
	/// Upper bound for melee hits.
	var/hits_upper_range = 6
	/// Sound or list of sounds for attacking / hitting. If a list, one is picked at start.
	var/attack_sound = "swing_hit"
	/// Sound played on miss.
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	/// Optional defensive reaction sound (e.g. parry).
	var/defend_sound
	/// Chance for a swing to be a miss or parried.
	var/miss_chance = 25
	/// Hits needed to knock down.
	var/number_of_hits_to_end = 3
	/// Chance to fall after enough hits.
	var/chance_to_fall = 75
	/// Base volume of melee sounds before distance falloff.
	var/volume = 60

/datum/hallucination/battle/melee/start()
	if(islist(attack_sound))
		attack_sound = pick(attack_sound)
	melee_loop(random_far_turf(), rand(hits_lower_range, hits_upper_range))
	return TRUE

/// The main sound loop for melee hallucinations.
/datum/hallucination/battle/melee/proc/melee_loop(turf/source, hits_left = 3, landed_hits = 0)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return

	if(prob(miss_chance))
		if(defend_sound && prob(40))
			play_battle_sound(source, defend_sound, volume)
		else if(miss_sound)
			play_battle_sound(source, miss_sound, volume)
	else
		play_battle_sound(source, attack_sound, volume)
		landed_hits++

	// If we scored enough hits, we have a chance to knock them down and stop the hallucination early.
	if(landed_hits >= number_of_hits_to_end && prob(chance_to_fall))
		addtimer(CALLBACK(src, PROC_REF(down_target), source), 0.3 SECONDS)
		return

	if(hits_left > 0)
		hits_left--
		source = get_step(source, pick(GLOB.alldirs)) || source
		addtimer(CALLBACK(src, PROC_REF(melee_loop), source, hits_left, landed_hits), rand(CLICK_CD_MELEE, CLICK_CD_MELEE + 5))
	else
		QDEL_IN(src, 1 SECONDS)

/// Knocks down the target in a melee fight with a bodyfall and scream.
/datum/hallucination/battle/melee/proc/down_target(turf/source)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return

	play_battle_sound(source, "bodyfall", volume)
	if(prob(70))
		addtimer(CALLBACK(src, PROC_REF(play_battle_sound), source, get_scream_sound(), volume), 0.2 SECONDS)
	QDEL_IN(src, 1 SECONDS)

/// Melee fight hallucination involving weapons.
/datum/hallucination/battle/melee/armed
	attack_sound = list(
		'sound/weapons/bladeslice.ogg',
		'sound/weapons/blade1.ogg',
		'sound/weapons/slice.ogg',
		'sound/weapons/slash.ogg',
		"swing_hit",
	)
	miss_sound = 'sound/weapons/smash.ogg'
	defend_sound = 'sound/weapons/parry.ogg'
	miss_chance = 30
	number_of_hits_to_end = 2
	chance_to_fall = 80
	volume = 65

/// Melee fight hallucination involving blunt impacts and punches.
/datum/hallucination/battle/melee/brawl
	attack_sound = list(
		"punch",
		'sound/weapons/smash.ogg',
		'sound/weapons/genhit.ogg',
	)
	miss_sound = 'sound/weapons/punchmiss.ogg'
	miss_chance = 25
	number_of_hits_to_end = 4
	chance_to_fall = 70
	volume = 60

/datum/hallucination/battle/melee/brawl/melee_loop(turf/source, hits_left = 3, landed_hits = 0)
	if(prob(15))
		addtimer(CALLBACK(src, PROC_REF(play_battle_sound), source, pick('sound/effects/tableslam.ogg', "shatter"), volume), 0.1 SECONDS)
	return ..()

/// A hallucination of someone unsheathing an energy sword, going to town, and sheathing it again.
/datum/hallucination/battle/melee/e_sword
	attack_sound = 'sound/weapons/blade1.ogg'
	miss_sound = 'sound/weapons/smash.ogg'
	defend_sound = 'sound/weapons/parry.ogg'
	miss_chance = 30
	number_of_hits_to_end = 2
	chance_to_fall = 80
	volume = 65

/datum/hallucination/battle/melee/e_sword/start()
	var/turf/source = random_far_turf()

	play_battle_sound(source, 'sound/weapons/saberon.ogg', volume)

	addtimer(CALLBACK(src, PROC_REF(melee_loop), source, rand(hits_lower_range, hits_upper_range)), CLICK_CD_MELEE)
	return TRUE

/datum/hallucination/battle/melee/e_sword/down_target(turf/source)
	..()
	addtimer(CALLBACK(src, PROC_REF(play_battle_sound), source, 'sound/weapons/saberoff.ogg', volume), 0.5 SECONDS)

/// A hallucination of someone being hit with a stun prod, followed by cable cuffing.
/datum/hallucination/battle/melee/stun_prod
	attack_sound = 'sound/weapons/egloves.ogg'
	miss_sound = ""
	miss_chance = 30
	number_of_hits_to_end = 2
	chance_to_fall = 100
	volume = 65

/datum/hallucination/battle/melee/stun_prod/start()
	var/turf/source = random_far_turf()

	play_battle_sound(source, 'sound/weapons/egloves.ogg', volume)

	addtimer(CALLBACK(src, PROC_REF(melee_loop), source, rand(hits_lower_range, hits_upper_range)), CLICK_CD_MELEE)
	return TRUE

/datum/hallucination/battle/melee/stun_prod/down_target(turf/source)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return

	addtimer(CALLBACK(src, PROC_REF(play_battle_sound), source, 'sound/weapons/cablecuff.ogg', volume), CLICK_CD_MELEE + 4)
	QDEL_IN(src, CLICK_CD_MELEE + 5)

/// A hallucination of a syndicate bomb ticking down.
/datum/hallucination/battle/bomb

/datum/hallucination/battle/bomb/start()
	addtimer(CALLBACK(src, PROC_REF(fake_tick), random_far_turf(), rand(3, 11)), 1.5 SECONDS)
	return TRUE

/// The loop of the (fake) bomb ticking down.
/datum/hallucination/battle/bomb/proc/fake_tick(turf/source, ticks_remaining = 3)
	if(QDELETED(src) || QDELETED(hallucinator) || !source)
		return

	play_battle_sound(source, 'sound/items/timer.ogg', 50, vary = FALSE)
	ticks_remaining--
	if(ticks_remaining <= 0)
		qdel(src)

	else
		addtimer(CALLBACK(src, PROC_REF(fake_tick), source, ticks_remaining), 1.5 SECONDS)
