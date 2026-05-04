/obj/item/mob_lasso
	name = "space lasso"
	desc = "Comes standard with every space-cowboy.\n" + span_notice("Can be used to tame space carp.")
	icon = 'icons/obj/carp_lasso.dmi'
	icon_state = "lasso"
	///Ref to timer
	var/timer
	///Ref to lasso'd carp
	var/mob/living/simple_animal/mob_target
	///Range we can lasso things at
	var/range = 8
	///Uses per lasso
	var/uses = 4
	///Whitelist of allowed animals
	var/list/whitelist_mobs
	///blacklist of disallowed animals
	var/list/blacklist_mobs
	///Typecache caches
	var/static/list/whitelist_mob_cache = list()
	var/static/list/blacklist_mob_cache = list()
	/// Instructions you can give to tamed targets - stolen from dogs
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/good_boy,
		/datum/pet_command/follow,
		/datum/pet_command/attack,
	)

/obj/item/mob_lasso/Initialize(mapload)
	. = ..()
	if(!whitelist_mob_cache[type] && !blacklist_mob_cache[type])
		init_whitelists()
	whitelist_mobs = whitelist_mob_cache[type]
	blacklist_mobs = blacklist_mob_cache[type]

/obj/item/mob_lasso/proc/init_whitelists()
	whitelist_mob_cache[type] = typecacheof(list(
		/mob/living/simple_animal/hostile/carp,
		/mob/living/simple_animal/hostile/carp/megacarp,
		/mob/living/simple_animal/hostile/carp/lia,
		/mob/living/basic/cow,
		/mob/living/simple_animal/hostile/retaliate/dolphin,
	), only_root_path = TRUE)

/obj/item/mob_lasso/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	var/failed = FALSE
	if(!isliving(target))
		failed = TRUE
	if(!check_allowed(target))
		failed = TRUE
	if(iscarbon(target) || issilicon(target))
		failed = TRUE
	if(failed)
		if(ismob(target))
			to_chat(user, span_warning("[target] seems a bit big for this..."))
		return
	if(!(locate(target) in oview(range, user)))
		if(ismob(target))
			to_chat(user, span_warning("You can't lasso [target] from here!"))
		return
	var/mob/living/simple_animal/C = target
	if(IS_DEAD_OR_INCAP(C))
		to_chat(user, span_warning("[target] is dead."))
		return
	if(!user.combat_mode && C == mob_target) //if trying to tie up previous target
		to_chat(user, span_notice("You begin to untie [C]"))
		if(istype(C))
			C.toggle_ai(AI_ON)
		if(proximity_flag && do_after(user, 2 SECONDS, target, timed_action_flags = IGNORE_HELD_ITEM))
			C.transform = C.transform.Turn(-180)
		//Riding and Tamed
			C.tamed()
			if(!C.can_buckle) //This is kind of a sleazy way of checking if they made themselves ridable or not
				C.AddElement(/datum/element/ridable, /datum/component/riding/creature)
				C.can_buckle = TRUE
				C.buckle_lying = 0
			if(C.ai_controller)
				QDEL_NULL(C.ai_controller)
			C.ai_controller = C.ai_controller || new /datum/ai_controller/basic_controller/dog(C) //This should be fine, we want them to act like dogs anyway
			C.AddComponent(/datum/component/obeys_commands, pet_commands)
			C.befriend(user)
		//Faction - overwrites the fuckass faction code from befreind()
			user.faction |= "carpboy_[user]"
			C.faction = list(FACTION_NEUTRAL) //So the mob doesn't go back to mauling everyone
			C.faction |= "carpboy_[user]"
			C.faction |= user.faction
		//Housekeeping
			to_chat(user, span_notice("[C] nuzzles you."))
			UnregisterSignal(mob_target, COMSIG_QDELETING)
			mob_target = null
			if(timer)
				deltimer(timer)
				timer = null
			uses--
			if(!uses)
				to_chat(user, span_warning("[src] falls apart!"))
				qdel(src)
			return
	else if(timer) //if trying to add new target while old target is still flipped
		to_chat(user, span_warning("You can't do that right now!"))
		return
	//Do lasso/beam for style points
	user.Beam(BeamTarget=C,icon_state = "carp_lasso",icon='icons/effects/beam.dmi', time = 1 SECONDS)
	C.unbuckle_all_mobs()
	mob_target = C
	C.throw_at(get_turf(src), 9, 2, user, FALSE, force = 0)
	C.transform = transform.Turn(180)
	if(istype(C))
		C.toggle_ai(AI_OFF)
	RegisterSignal(C, COMSIG_QDELETING, PROC_REF(handle_hard_del), override=TRUE)
	to_chat(user, span_notice("You lasso [C]!"))
	timer = addtimer(CALLBACK(src, PROC_REF(fail_ally)), 6 SECONDS, TIMER_STOPPABLE) //after 6 seconds set the carp back

/obj/item/mob_lasso/proc/check_allowed(atom/target)
	return ((!whitelist_mobs || is_type_in_typecache(target, whitelist_mobs)) && (!blacklist_mobs || !is_type_in_typecache(target, blacklist_mobs)))

/obj/item/mob_lasso/proc/fail_ally()
	if(!mob_target)
		return
	visible_message(span_warning("[mob_target] breaks free!"))
	mob_target.transform = mob_target.transform.Turn(-180)
	mob_target.toggle_ai(AI_ON)
	UnregisterSignal(mob_target, COMSIG_QDELETING)
	mob_target = null
	timer = null

/obj/item/mob_lasso/proc/handle_hard_del()
	SIGNAL_HANDLER
	mob_target = null
	timer = null

///Primal version, allows lavaland goobers to tame goliaths
/obj/item/mob_lasso/primal
	name = "primal lasso"
	desc = "A lasso fashioned out of goliath plating that is often found in the possession of Ash Walkers.\n" + span_notice("Can be used to tame some lavaland animals")
	uses = 2

/obj/item/mob_lasso/primal/init_whitelists(mapload)
	whitelist_mob_cache[type] = typecacheof(list(
		/mob/living/simple_animal/hostile/asteroid/goldgrub,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher,
		/mob/living/simple_animal/hostile/asteroid/gutlunch,
	))

/obj/item/mob_lasso/drake
	name = "drake lasso"
	desc = "A lasso fashioned out of the scaly hide of an ash drake.\n" + span_notice("Can be used to tame one, if you can get close enough.")
	range = 3
	uses = 1

/obj/item/mob_lasso/drake/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!user.mind?.has_antag_datum(/datum/antagonist/ashwalker))
		to_chat(user, span_warning("You don't know how to use this!"))
		return
	. = ..()

/obj/item/mob_lasso/drake/init_whitelists(mapload)
	whitelist_mob_cache[type] = typecacheof(list(
		/mob/living/simple_animal/hostile/megafauna/dragon
	), only_root_path = TRUE)

/obj/item/mob_lasso/traitor
	name = "bluespace lasso"
	desc = "Comes standard with every administrator space-cowboy!\n" + span_notice("Can be used to tame almost anything.")
	uses = INFINITY

/obj/item/mob_lasso/traitor/init_whitelists(mapload)
	blacklist_mob_cache[type] = typecacheof(list(
		/mob/living/simple_animal/hostile/megafauna,
		/mob/living/simple_animal/hostile/alien,
		/mob/living/simple_animal/hostile/syndicate,
	))

/obj/item/mob_lasso/debug
	name = "debug lasso"
	desc = "Comes standard with every administrator space-cowboy!\n" + span_notice("Can be used to tame anything.")
	uses = INFINITY

/obj/item/mob_lasso/debug/init_whitelists(mapload)
	blacklist_mob_cache[type] = list() // An empty list so we know this got initialized
