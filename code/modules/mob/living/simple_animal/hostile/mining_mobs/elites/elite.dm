#define TUMOR_INACTIVE 0
#define TUMOR_ACTIVE 1
#define TUMOR_PASSIVE 2

//Elite mining mobs
/mob/living/simple_animal/hostile/asteroid/elite
	name = "elite"
	desc = "An elite monster, found in one of the strange tumors on lavaland."
	icon = 'icons/mob/lavaland/lavaland_elites.dmi'
	faction = list(FACTION_BOSS)
	robust_searching = TRUE
	ranged_ignores_vision = TRUE
	ranged = TRUE
	obj_damage = 5
	vision_range = 6
	aggro_vision_range = 18
	environment_smash = ENVIRONMENT_SMASH_NONE  //This is to prevent elites smashing up the mining station, we'll make sure they can smash minerals fine below.
	stat_attack = HARD_CRIT
	layer = LARGE_MOB_LAYER
	sentience_type = SENTIENCE_BOSS
	var/chosen_attack = 1
	var/list/attack_action_types = list()
	var/can_talk = FALSE
	var/obj/loot_drop = null
	discovery_points = 5000

//Gives player-controlled variants the ability to swap attacks
/mob/living/simple_animal/hostile/asteroid/elite/Initialize(mapload)
	. = ..()
	for(var/action_type in attack_action_types)
		var/datum/action/innate/elite_attack/attack_action = new action_type()
		attack_action.Grant(src)

//Prevents elites from attacking members of their faction (can't hurt themselves either) and lets them mine rock with an attack despite not being able to smash walls.
/mob/living/simple_animal/hostile/asteroid/elite/AttackingTarget()
	if(istype(target, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/M = target
		if(faction_check_mob(M))
			return FALSE
	if(istype(target, /obj/structure/elite_tumor))
		var/obj/structure/elite_tumor/T = target
		if(T.mychild == src && T.activity == TUMOR_PASSIVE)
			var/elite_remove = alert("Re-enter the tumor?", "Despawn yourself?", "Yes", "No")
			if(elite_remove != "Yes" || !src || QDELETED(src))
				return
			T.mychild = null
			T.activity = TUMOR_INACTIVE
			T.icon_state = "advanced_tumor"
			qdel(src)
			return FALSE
	. = ..()
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.gets_drilled()

//Elites can't talk (normally)!
/mob/living/simple_animal/hostile/asteroid/elite/can_speak(allow_mimes)
	return can_talk && ..()

/*Basic setup for elite attacks, based on Whoneedspace's megafauna attack setup.
While using this makes the system rely on OnFire, it still gives options for timers not tied to OnFire, and it makes using attacks consistent across the board for player-controlled elites.*/

/datum/action/innate/elite_attack
	name = "Elite Attack"
	button_icon = 'icons/hud/actions/actions_elites.dmi'
	button_icon_state = null
	background_icon_state = "bg_default"
	var/chosen_message
	var/chosen_attack_num = 0

/datum/action/innate/elite_attack/Grant(mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/asteroid/elite))
		return ..()
	return FALSE

/datum/action/innate/elite_attack/on_activate()
	var/mob/living/simple_animal/hostile/asteroid/elite/elite_owner = owner
	elite_owner.chosen_attack = chosen_attack_num
	to_chat(elite_owner, chosen_message)

//The Pulsing Tumor, the actual "spawn-point" of elites, handles the spawning, arena, and procs for dealing with basic scenarios.

/obj/structure/elite_tumor
	name = "pulsing tumor"
	desc = "An odd, pulsing tumor sticking out of the ground.  You feel compelled to reach out and touch it..."
	armor_type = /datum/armor/structure_elite_tumor
	resistance_flags = INDESTRUCTIBLE
	icon = 'icons/obj/lavaland/tumor.dmi'
	icon_state = "tumor"
	pixel_x = -16
	base_pixel_x = -16
	light_color = LIGHT_COLOR_RED
	light_range = 3
	anchored = TRUE
	density = FALSE
	var/activity = TUMOR_INACTIVE
	var/boosted = FALSE
	var/times_won = 0
	var/mob/living/carbon/human/activator = null
	var/mob/living/simple_animal/hostile/asteroid/elite/mychild = null
	var/potentialspawns = list(/mob/living/simple_animal/hostile/asteroid/elite/broodmother,
								/mob/living/simple_animal/hostile/asteroid/elite/pandora,
								/mob/living/simple_animal/hostile/asteroid/elite/legionnaire,
								/mob/living/simple_animal/hostile/asteroid/elite/herald)


/datum/armor/structure_elite_tumor
	melee = 100
	bullet = 100
	laser = 100
	energy = 100
	bomb = 100
	bio = 100
	fire = 100
	acid = 100

/obj/structure/elite_tumor/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(ishuman(user))
		switch(activity)
			if(TUMOR_PASSIVE)
				activity = TUMOR_ACTIVE
				visible_message(span_boldwarning("[src] convulses as your arm enters its radius.  Your instincts tell you to step back."))
				activator = user
				if(boosted)
					mychild.playsound_local(get_turf(mychild), 'sound/effects/magic.ogg', 40, 0)
					to_chat(mychild, "<b>Someone has activated your tumor.  You will be returned to fight shortly, get ready!</b>")
				addtimer(CALLBACK(src, PROC_REF(return_elite)), 30)
				INVOKE_ASYNC(src, PROC_REF(arena_checks))
			if(TUMOR_INACTIVE)
				activity = TUMOR_ACTIVE
				visible_message(span_boldwarning("[src] begins to convulse.  Your instincts tell you to step back."))
				activator = user
				if(!boosted)
					addtimer(CALLBACK(src, PROC_REF(spawn_elite)), 30)
					return
				visible_message(span_boldwarning("Something within [src] stirs..."))
				var/datum/poll_config/config = new()
				config.check_jobban = ROLE_LAVALAND_ELITE
				config.poll_time = 10 SECONDS
				config.jump_target = src
				config.role_name_text = "lavaland elite"
				config.alert_pic = src
				var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(config)
				if(candidate)
					audible_message(span_boldwarning("The stirring sounds increase in volume!"))
					candidate.playsound_local(null, 'sound/effects/magic.ogg', 40, 0)
					to_chat(candidate, "<b>You have been chosen to play as a Lavaland Elite.\nIn a few seconds, you will be summoned on Lavaland as a monster to fight your activator, in a fight to the death.\nYour attacks can be switched using the buttons on the top left of the HUD, and used by clicking on targets or tiles similar to a gun.\nWhile the opponent might have an upper hand with  powerful mining equipment and tools, you have great power normally limited by AI mobs.\nIf you want to win, you'll have to use your powers in creative ways to ensure the kill.  It's suggested you try using them all as soon as possible.\nShould you win, you'll receive extra information regarding what to do after.  Good luck!</b>")
					addtimer(CALLBACK(src, PROC_REF(spawn_elite), candidate), 10 SECONDS)
				else
					visible_message(span_boldwarning("The stirring stops, and nothing emerges.  Perhaps try again later."))
					activity = TUMOR_INACTIVE
					activator = null

/obj/structure/elite_tumor/proc/spawn_elite(mob/dead/observer/elitemind)
	var/selectedspawn = pick(potentialspawns)
	mychild = new selectedspawn(loc)
	visible_message(span_boldwarning("[mychild] emerges from [src]!"))
	playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	if(boosted)
		mychild.key = elitemind.key
		mychild.sentience_act()
		notify_ghosts("\A [mychild] has been awakened in \the [get_area(src)]!", source = mychild, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Lavaland Elite awakened")
	mychild.log_message("has been awakened by [key_name(activator)]!", LOG_GAME, color="#960000")
	activator.log_message("has awakened [key_name(mychild)]!", LOG_GAME, color="#960000")
	icon_state = "tumor_popped"
	INVOKE_ASYNC(src, PROC_REF(arena_checks))

/obj/structure/elite_tumor/proc/return_elite()
	mychild.forceMove(loc)
	visible_message(span_boldwarning("[mychild] emerges from [src]!"))
	playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	mychild.revive(HEAL_ALL)
	if(boosted)
		mychild.maxHealth = mychild.maxHealth * 2
		mychild.health = mychild.maxHealth
		notify_ghosts("\A [mychild] has been challenged in \the [get_area(src)]!", source = mychild, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Lavaland Elite challenged")
	mychild.log_message("has been challenged by [key_name(activator)]!", LOG_GAME, color="#960000")

/obj/structure/elite_tumor/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "Menacing Signal")
	START_PROCESSING(SSobj, src)

/obj/structure/elite_tumor/Destroy()
	STOP_PROCESSING(SSobj, src)
	mychild = null
	activator = null
	return ..()

/obj/structure/elite_tumor/process(delta_time)
	if(isturf(loc))
		for(var/mob/living/simple_animal/hostile/asteroid/elite/elitehere in loc)
			if(elitehere == mychild && activity == TUMOR_PASSIVE)
				mychild.adjustHealth(-mychild.maxHealth*0.025*delta_time)
				var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(mychild))
				H.color = "#FF0000"

/obj/structure/elite_tumor/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/organ/regenerative_core) && activity == TUMOR_INACTIVE && !boosted)
		var/obj/item/organ/regenerative_core/core = I
		if(!core.preserved)
			return
		visible_message(span_boldwarning("As [user] drops the core into [src], [src] appears to swell."))
		icon_state = "advanced_tumor"
		boosted = TRUE
		light_range = 6
		desc = "[desc]  This one seems to glow with a strong intensity."
		qdel(core)
		return TRUE

/obj/structure/elite_tumor/proc/arena_checks()
	if(activity != TUMOR_ACTIVE || QDELETED(src))
		return
	INVOKE_ASYNC(src, PROC_REF(fighters_check))  //Checks to see if our fighters died.
	INVOKE_ASYNC(src, PROC_REF(arena_trap))  //Gets another arena trap queued up for when this one runs out.
	INVOKE_ASYNC(src, PROC_REF(border_check))  //Checks to see if our fighters got out of the arena somehow.
	if(!QDELETED(src))
		addtimer(CALLBACK(src, PROC_REF(arena_checks)), 50)

/obj/structure/elite_tumor/proc/fighters_check()
	if(activator != null && activator.stat == DEAD || activity == TUMOR_ACTIVE && QDELETED(activator))
		onEliteWon()
	if(mychild != null && mychild.stat == DEAD || activity == TUMOR_ACTIVE && QDELETED(mychild))
		onEliteLoss()

/obj/structure/elite_tumor/proc/arena_trap()
	var/turf/T = get_turf(src)
	if(loc == null)
		return
	for(var/t in RANGE_TURFS(12, T))
		if(get_dist(t, T) == 12)
			var/obj/effect/temp_visual/elite_tumor_wall/newwall
			newwall = new /obj/effect/temp_visual/elite_tumor_wall(t, src)
			newwall.activator = src.activator
			newwall.ourelite = src.mychild

/obj/structure/elite_tumor/proc/border_check()
	if(activator != null && get_dist(src, activator) >= 12)
		activator.forceMove(loc)
		visible_message(span_boldwarning("[activator] suddenly reappears above [src]!"))
		playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	if(mychild != null && get_dist(src, mychild) >= 12)
		mychild.forceMove(loc)
		visible_message(span_boldwarning("[mychild] suddenly reappears above [src]!"))
		playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)

/obj/structure/elite_tumor/proc/onEliteLoss()
	playsound(loc,'sound/effects/tendril_destroyed.ogg', 200, 0, 50, TRUE, TRUE)
	visible_message(span_boldwarning("[src] begins to convulse violently before beginning to dissipate."))
	visible_message(span_boldwarning("As [src] closes, something is forced up from down below."))
	var/obj/structure/closet/crate/necropolis/tendril/lootbox = new /obj/structure/closet/crate/necropolis/tendril(loc)
	if(!boosted)
		mychild = null
		activator = null
		qdel(src)
		return
	var/lootpick = rand(1, 2)
	if(lootpick == 1 && mychild.loot_drop != null)
		new mychild.loot_drop(lootbox)
	else
		new /obj/item/tumor_shard(lootbox)
	mychild = null
	activator = null
	qdel(src)

/obj/structure/elite_tumor/proc/onEliteWon()
	activity = TUMOR_PASSIVE
	activator = null
	mychild.revive(HEAL_ALL)
	if(boosted)
		times_won++
		mychild.maxHealth = mychild.maxHealth * 0.5
		mychild.health = mychild.maxHealth
	if(times_won == 1)
		mychild.playsound_local(get_turf(mychild), 'sound/effects/magic.ogg', 40, 0)
		to_chat(mychild, span_boldwarning("As the life in the activator's eyes fade, the forcefield around you dies out and you feel your power subside.\nDespite this inferno being your home, you feel as if you aren't welcome here anymore.\nWithout any guidance, your purpose is now for you to decide."))
		to_chat(mychild, "<b>Your max health has been halved, but can now heal by standing on your tumor.  Note, it's your only way to heal.\nBear in mind, if anyone interacts with your tumor, you'll be resummoned here to carry out another fight.  In such a case, you will regain your full max health.\nAlso, be weary of your fellow inhabitants, they likely won't be happy to see you!</b>")
		to_chat(mychild, span_bigbold("Note that you are a lavaland monster, and thus not allied to the station.  You should not cooperate or act friendly with any station crew unless under extreme circumstances!"))

/obj/item/tumor_shard
	name = "tumor shard"
	desc = "A strange, sharp, crystal shard from an odd tumor on Lavaland.  Stabbing the corpse of a lavaland elite with this will revive them, assuming their soul still lingers.  Revived lavaland elites only have half their max health, but are completely loyal to their reviver."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "crevice_shard"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	inhand_icon_state = "screwdriver_head"
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	var/using = FALSE

/obj/item/tumor_shard/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(istype(target, /mob/living/simple_animal/hostile/asteroid/elite) && proximity_flag)
		var/mob/living/simple_animal/hostile/asteroid/elite/E = target
		if(E.stat != DEAD || E.sentience_type != SENTIENCE_BOSS)
			user.visible_message(span_notice("[E] does not respond to [src]."))
			return
		if(!E.key && !using)
			using = TRUE //No ghost poll spam please.
			user.visible_message(span_notice("[E] stirs briefly..."))
			var/datum/poll_config/config = new()
			config.check_jobban = ROLE_SENTIENCE
			config.poll_time = 15 SECONDS
			config.jump_target = E
			config.role_name_text = "enslaved lavaland elite"
			config.alert_pic = E
			var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(config)
			if(candidate)
				E.key = candidate.key
			else
				user.visible_message(span_notice("It appears [E] is unable to be revived right now.  Perhaps try again later."))
				using = FALSE
				return
		E.faction = list(FACTION_NEUTRAL)
		E.revive(HEAL_ALL)
		user.visible_message(span_notice("[user] stabs [E] with [src], reviving it."))
		E.playsound_local(get_turf(E), 'sound/effects/magic.ogg', 40, 0)
		to_chat(E, span_userdanger("You have been revived by [user].  While you can't speak to them, you owe [user] a great debt.  Assist [user.p_them()] in achieving [user.p_their()] goals, regardless of risk."))
		to_chat(E, span_bigbold("Note that you now share the loyalties of [user].  You are expected not to intentionally sabotage their faction unless commanded to!"))
		E.maxHealth = E.maxHealth * 0.5
		E.health = E.maxHealth
		E.desc = "[E.desc]  However, this one appears appears less wild in nature, and calmer around people."
		E.sentience_type = SENTIENCE_ORGANIC
		qdel(src)
	else
		to_chat(user, span_info("[src] only works on the corpse of a sentient lavaland elite."))

/obj/effect/temp_visual/elite_tumor_wall
	name = "magic wall"
	icon = 'icons/turf/walls/hierophant_wall_temp.dmi'
	icon_state = "hierophant_wall_temp-0"
	base_icon_state = "hierophant_wall_temp"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_HIERO_WALL)
	canSmoothWith = list(SMOOTH_GROUP_HIERO_WALL)
	duration = 50
	layer = BELOW_MOB_LAYER
	color = rgb(255,0,0)
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	light_color = LIGHT_COLOR_RED
	var/mob/living/carbon/human/activator = null
	var/mob/living/simple_animal/hostile/asteroid/elite/ourelite = null

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/temp_visual/elite_tumor_wall)

/obj/effect/temp_visual/elite_tumor_wall/Initialize(mapload, new_caster)
	. = ..()
	QUEUE_SMOOTH_NEIGHBORS(src)
	QUEUE_SMOOTH(src)

/obj/effect/temp_visual/elite_tumor_wall/Destroy()
	QUEUE_SMOOTH_NEIGHBORS(src)
	activator = null
	ourelite = null
	return ..()

/obj/effect/temp_visual/elite_tumor_wall/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(mover == ourelite || mover == activator)
		return FALSE

#undef TUMOR_INACTIVE
#undef TUMOR_ACTIVE
#undef TUMOR_PASSIVE
