// Used by /turf/open/chasm and subtypes to implement the "dropping" mechanic
/datum/component/chasm
	var/turf/target_turf
	var/fall_message = "GAH! Ah... where are you?"
	var/oblivion_message = "You stumble and stare into the abyss before you. It stares back, and you fall into the enveloping dark."

	/// Lazy associative list of: refs to falling objects -> how many levels deep we've fallen
	var/static/list/falling_atoms
	var/static/list/forbidden_types = typecacheof(list(
		/obj/anomaly,
		/obj/eldritch/narsie,
		/obj/docking_port,
		/obj/structure/lattice,
		/obj/structure/stone_tile,
		/obj/projectile,
		/obj/effect/projectile,
		/obj/effect/portal,
		/obj/effect/abstract,
		/obj/effect/hotspot,
		/obj/effect/landmark,
		/obj/effect/temp_visual,
		/obj/effect/light_emitter/tendril,
		/obj/effect/collapse,
		/obj/effect/particle_effect/ion_trails,
		/obj/effect/dummy/phased_mob,
		/obj/effect/mapping_helpers
	))

/datum/component/chasm/Initialize(turf/target, mapload)
	if(!isturf(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_CHASM_STOPPED), PROC_REF(on_chasm_stopped))
	RegisterSignal(parent, SIGNAL_REMOVETRAIT(TRAIT_CHASM_STOPPED), PROC_REF(on_chasm_no_longer_stopped))
	target_turf = target
	RegisterSignal(parent, COMSIG_ATOM_ABSTRACT_ENTERED, PROC_REF(entered))
	RegisterSignal(parent, COMSIG_ATOM_ABSTRACT_EXITED, PROC_REF(exited))
	RegisterSignal(parent, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(initialized_on))
	//allow catwalks to give the turf the CHASM_STOPPED trait before dropping stuff when the turf is changed.
	//otherwise don't do anything because turfs and areas are initialized before movables.
	if(!mapload)
		addtimer(CALLBACK(src, PROC_REF(drop_stuff)), 0)

/datum/component/chasm/proc/entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	drop_stuff()

/datum/component/chasm/proc/exited(datum/source, atom/movable/exited)
	SIGNAL_HANDLER
	UnregisterSignal(exited, list(COMSIG_MOVETYPE_FLAG_DISABLED, COMSIG_LIVING_SET_BUCKLED, COMSIG_MOVABLE_THROW_LANDED))

/datum/component/chasm/proc/initialized_on(datum/source, atom/movable/movable, mapload)
	SIGNAL_HANDLER
	drop_stuff(movable)

/datum/component/chasm/proc/on_chasm_stopped(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON))
	for(var/atom/movable/movable as anything in source)
		UnregisterSignal(movable, list(COMSIG_MOVETYPE_FLAG_DISABLED, COMSIG_LIVING_SET_BUCKLED, COMSIG_MOVABLE_THROW_LANDED))

/datum/component/chasm/proc/on_chasm_no_longer_stopped(datum/source)
	SIGNAL_HANDLER
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(entered))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(exited))
	RegisterSignal(parent, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(initialized_on))
	drop_stuff()

#define CHASM_NOT_DROPPING 0
#define CHASM_DROPPING 1
///Doesn't drop the movable, but registers a few signals to try again if the conditions change.
#define CHASM_REGISTER_SIGNALS 2

/datum/component/chasm/proc/drop_stuff(atom/movable/dropped_thing)
	if(HAS_TRAIT(parent, TRAIT_CHASM_STOPPED))
		return
	var/atom/atom_parent = parent
	var/to_check = dropped_thing ? list(dropped_thing) : atom_parent.contents
	for (var/atom/movable/thing as anything in to_check)
		var/dropping = droppable(thing)
		switch(dropping)
			if(CHASM_DROPPING)
				INVOKE_ASYNC(src, PROC_REF(drop), thing)
			if(CHASM_REGISTER_SIGNALS)
				RegisterSignals(thing, list(COMSIG_MOVETYPE_FLAG_DISABLED, COMSIG_LIVING_SET_BUCKLED, COMSIG_MOVABLE_THROW_LANDED), PROC_REF(drop_stuff), TRUE)

/datum/component/chasm/proc/droppable(atom/movable/dropped_thing)
	var/datum/weakref/falling_ref = WEAKREF(dropped_thing)
	// avoid an infinite loop, but allow falling a large distance
	var/falling_atom = LAZYACCESS(falling_atoms, falling_ref)
	if(falling_atom && falling_atom > 30)
		return CHASM_NOT_DROPPING
	if(is_type_in_typecache(dropped_thing, forbidden_types) || (!isliving(dropped_thing) && !isobj(dropped_thing)))
		return CHASM_NOT_DROPPING
	if(dropped_thing.throwing || (dropped_thing.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return CHASM_REGISTER_SIGNALS

	if(!ismob(dropped_thing))
		return CHASM_DROPPING
	else if(ishuman(dropped_thing))
		// ew, snowflake code
		var/mob/living/carbon/human/dropped_human = dropped_thing
		if(istype(dropped_human.belt, /obj/item/wormhole_jaunter))
			var/obj/item/wormhole_jaunter/jaunter = dropped_human.belt
			//To freak out any bystanders
			dropped_human.visible_message(span_boldwarning("[dropped_human] falls into [parent]!"))
			jaunter.chasm_react(dropped_human)
			return CHASM_NOT_DROPPING

	//Flies right over the chasm
	var/mob/victim = dropped_thing
	if(victim.buckled && droppable(victim.buckled) != CHASM_DROPPING)
		return CHASM_REGISTER_SIGNALS
	return CHASM_DROPPING

#undef CHASM_NOT_DROPPING
#undef CHASM_DROPPING
#undef CHASM_REGISTER_SIGNALS

/datum/component/chasm/proc/drop(atom/movable/dropped_thing)
	var/datum/weakref/falling_ref = WEAKREF(dropped_thing)
	//Make sure the item is still there after our sleep
	if(!dropped_thing || !falling_ref?.resolve())
		LAZYREMOVE(falling_atoms, falling_ref)
		return
	LAZYSET(falling_atoms, falling_ref, (falling_atoms[falling_ref] || 0) + 1)
	var/turf/below_turf = target_turf

	// send to the turf below
	if(below_turf)
		dropped_thing.visible_message(span_boldwarning("[dropped_thing] falls into [parent]!"), span_userdanger("[fall_message]"))
		below_turf.visible_message(span_boldwarning("[dropped_thing] falls from above!"))
		dropped_thing.forceMove(below_turf)
		if(isliving(dropped_thing))
			var/mob/living/fallen_mob = dropped_thing
			fallen_mob.Paralyze(10 SECONDS)
			fallen_mob.adjustBruteLoss(30)
		LAZYREMOVE(falling_atoms, falling_ref)
		return

	// no turf below? to oblivion you go

	dropped_thing.visible_message(span_boldwarning("[dropped_thing] falls into [parent]!"), span_userdanger("[oblivion_message]"))
	if (isliving(dropped_thing))
		var/mob/living/falling_mob = dropped_thing
		ADD_TRAIT(falling_mob, TRAIT_NO_TRANSFORM, REF(src))
		falling_mob.Stun(20 SECONDS, ignore_canstun = TRUE)

		if (HAS_MIND_TRAIT(falling_mob, TRAIT_NAIVE))
			falling_mob.do_alert_animation()
			dropped_thing.visible_message(span_boldwarning("[dropped_thing] kicks [dropped_thing.p_their()] legs in the air, as if running in place!"))
			dropped_thing.Shake(1, 0, 2 SECONDS, 0.3 SECONDS)
			sleep(3 SECONDS)

		if (get_turf(falling_mob) != get_turf(parent))
			REMOVE_TRAIT(falling_mob, TRAIT_NO_TRANSFORM, REF(src))
			falling_mob.Paralyze(17 SECONDS, ignore_canstun = TRUE) // Wow nice job
			return

	if(ismecha(dropped_thing))
		var/obj/vehicle/sealed/mecha/mech = dropped_thing
		mech.canmove = FALSE

	var/oldtransform = dropped_thing.transform
	var/oldcolor = dropped_thing.color
	var/oldalpha = dropped_thing.alpha
	animate(dropped_thing, transform = matrix() - matrix(), alpha = 0, color = rgb(0, 0, 0), time = 15)
	for(var/i in 1 to 5)
		//Make sure the item is still there after our sleep
		if(!dropped_thing || QDELETED(dropped_thing))
			return
		dropped_thing.pixel_y--
		sleep(3)
		if(i == 2 && ismecha(dropped_thing))
			var/obj/vehicle/sealed/mecha/mech = dropped_thing
			mech.Eject() //ABORT ABORT
	//Make sure the item is still there after our sleep
	if(!dropped_thing || QDELETED(dropped_thing))
		return

	if(iscyborg(dropped_thing))
		var/mob/living/silicon/robot/S = dropped_thing
		if(S.shell && S.deployed && S.mainframe)
			S.undeploy()
		else
			qdel(S.mmi)

	LAZYREMOVE(falling_atoms, falling_ref)
	qdel(dropped_thing)
	if(dropped_thing && !QDELETED(dropped_thing))	//It's indestructible
		var/atom/parent = src.parent
		parent.visible_message(span_boldwarning("[parent] spits out [dropped_thing]!"))
		dropped_thing.alpha = oldalpha
		dropped_thing.color = oldcolor
		dropped_thing.transform = oldtransform
		dropped_thing.throw_at(get_edge_target_turf(parent,pick(GLOB.alldirs)),rand(1, 10),rand(1, 10))
