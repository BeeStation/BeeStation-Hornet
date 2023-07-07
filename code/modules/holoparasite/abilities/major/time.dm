/datum/holoparasite_ability/major/time
	name = "Time Distoration"
	desc = "Distorts time and space, causing fragments from other timelines to appear as distractions."
	ui_icon = "theater-masks"
	cost = 4
	thresholds = list(
		list(
			"stat" = "Potential",
			"desc" = "Reduces the cooldown for spawning decoy fragments."
		)
	)
	/// Cooldown for decoy spawning.
	COOLDOWN_DECLARE(decoy_cooldown)

/datum/holoparasite_ability/major/time/register_signals()
	..()
	RegisterSignal(owner, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(on_after_attack))
	RegisterSignal(owner, COMSIG_HOLOPARA_STAT, PROC_REF(on_stat))

/datum/holoparasite_ability/major/time/unregister_signals()
	..()
	UnregisterSignal(owner, list(COMSIG_HOSTILE_POST_ATTACKINGTARGET, COMSIG_HOLOPARA_STAT))

/**
 * Handles spawning decoys after the holoparasite attacks someone.
 */
/datum/holoparasite_ability/major/time/proc/on_after_attack(datum/_source, atom/target)
	SIGNAL_HANDLER
	if(COOLDOWN_FINISHED(src, decoy_cooldown))
		COOLDOWN_START(src, decoy_cooldown, ((5 - master_stats.potential) + 8) SECONDS)
		spawn_decoys()

/**
 * Adds decoy cooldown info to the holoparasite's stat panel.
 */
/datum/holoparasite_ability/major/time/proc/on_stat(datum/_source, list/tab_data)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, decoy_cooldown))
		tab_data["Decoy Cooldown"] = GENERATE_STAT_TEXT(COOLDOWN_TIMELEFT_TEXT(src, decoy_cooldown))


/datum/holoparasite_ability/major/time/proc/spawn_decoys()
	var/list/immune = list()
	var/list/fakes = list()
	//Makes all the holoparasites immune
	if(owner.summoner.current)
		immune += owner.summoner.current
		for(var/mob/living/simple_animal/hostile/holoparasite/other_holopara as() in owner.summoner.current.holoparasites())
			immune += other_holopara
	for(var/mob/living/immune_mob as() in immune)
		SEND_SOUND(immune_mob, sound('sound/magic/timeparadox2.ogg'))
		if(isturf(immune_mob.loc))
			var/mob/living/simple_animal/hostile/illusion/doppelganger/doppelganger = new(immune_mob.loc)
			doppelganger.set_lifetime(6 SECONDS)
			doppelganger.setDir(immune_mob.dir)
			doppelganger.Copy_Parent(immune_mob, INFINITY, 100)
			doppelganger.target = null
			fakes += doppelganger
			doppelganger.remove_alt_appearance("decoy")
			var/image/immune_appearance = image(icon = 'icons/mob/simple_human.dmi', icon_state = "faceless", loc = doppelganger)
			immune_appearance.override = TRUE
			doppelganger.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/decoy, "decoy", immune_appearance, NONE, immune)

/datum/atom_hud/alternate_appearance/basic/decoy
	var/list/immune

/datum/atom_hud/alternate_appearance/basic/decoy/New(key, image/img, options, list/immune)
	..()
	src.immune = immune
	for(var/mob/mob in GLOB.mob_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)
			mob.reload_huds()

/datum/atom_hud/alternate_appearance/basic/decoy/mobShouldSee(mob/mob)
	return mob in immune

/mob/living/simple_animal/hostile/illusion/doppelganger
	melee_damage = 0
	speed = -1
	obj_damage = 0
	vision_range = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	var/removal_timer = null

/mob/living/simple_animal/hostile/illusion/doppelganger/proc/set_lifetime(time)
	if(removal_timer)
		log_runtime("A doppelganger was set to be destroyed, but is already being destroyed!")
		return
	removal_timer = addtimer(CALLBACK(src, PROC_REF(begin_fade_out)), time, TIMER_UNIQUE)

/mob/living/simple_animal/hostile/illusion/doppelganger/proc/begin_fade_out()
	if(QDELETED(src))
		return
	playsound(get_turf(src), 'sound/magic/timeparadox2.ogg', vol = 20, vary = TRUE, frequency = -1) //reverse!
	animate(src, time=10, alpha=0)
	addtimer(CALLBACK(src, PROC_REF(end_fade_out)), 10, TIMER_UNIQUE)

/mob/living/simple_animal/hostile/illusion/doppelganger/proc/end_fade_out()
	if(!QDELETED(src))
		qdel(src)
