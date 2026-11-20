/obj/effect/decal/cleanable
	abstract_type = /obj/effect/decal/cleanable
	gender = PLURAL
	layer = ABOVE_NORMAL_TURF_LAYER
	var/list/random_icon_states = null
	///When two of these are on a same tile or do we need to merge them into just one?
	var/mergeable_decal = TRUE
	//var/beauty = 0
	///The type of cleaning required to clean the decal. See __DEFINES/cleaning.dm for the options
	var/clean_type = CLEAN_TYPE_LIGHT_DECAL
	///The reagent this decal holds. Leave blank for none.
	var/datum/reagent/decal_reagent
	///The amount of reagent this decal holds, if decal_reagent is defined
	var/reagent_amount = 0

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/decal/cleanable)

/obj/effect/decal/cleanable/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	if (LAZYLEN(random_icon_states) && icon_state == initial(icon_state))
		icon_state = pick(random_icon_states)
		base_icon_state = icon_state

	if (isturf(loc))
		for (var/obj/effect/decal/cleanable/other in loc)
			if (other != src && other.type == type && !QDELETED(other) && replace_decal(other))
				handle_merge_decal(other)
				return INITIALIZE_HINT_QDEL

	if (LAZYLEN(diseases))
		add_diseases(diseases)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_uncrossed),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/decal/cleanable/proc/add_diseases(list/datum/disease/diseases)
	var/list/datum/disease/diseases_to_add = list()
	for (var/datum/disease/disease as anything in diseases)
		if (disease.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS)
			diseases_to_add += disease
	if (LAZYLEN(diseases_to_add))
		AddComponent(/datum/component/infective, diseases_to_add)

/// Check if we should give up in favor of the pre-existing decal
/obj/effect/decal/cleanable/proc/replace_decal(obj/effect/decal/cleanable/other)
	if (mergeable_decal)
		return TRUE

/obj/effect/decal/cleanable/attackby(obj/item/W, mob/user, list/modifiers)
	if((istype(W, /obj/item/reagent_containers/cup) && !istype(W, /obj/item/rag)) || istype(W, /obj/item/reagent_containers/cup/glass))
		if(W.reagents)
			. = 1 //so the containers don't splash their content on the src while scooping.
			if(!lazy_init_reagents()?.total_volume)
				to_chat(user, span_notice("[src] isn't thick enough to scoop up!"))
				return
			if(W.reagents.total_volume >= W.reagents.maximum_volume)
				to_chat(user, span_notice("[W] is full!"))
				return
			to_chat(user, span_notice("You scoop up [src] into [W]!"))
			reagents.trans_to(W, reagents.total_volume, transfered_by = user)
			if(!reagents.total_volume) //scooped up all of it
				qdel(src)
				return
	if(W.get_temperature()) //todo: make heating a reagent holder proc
		if(istype(W, /obj/item/cigarette))
			return
		else
			var/hotness = W.get_temperature()
			lazy_init_reagents()?.expose_temperature(hotness)
			to_chat(user, span_notice("You heat [name] with [W]!"))
	else
		return ..()

/obj/effect/decal/cleanable/fire_act(exposed_temperature, exposed_volume)
	lazy_init_reagents()?.expose_temperature(exposed_temperature)
	..()

/obj/effect/decal/cleanable/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	return

/obj/effect/decal/cleanable/proc/on_uncrossed(datum/source, atom/movable/O)
	SIGNAL_HANDLER
	return

/obj/effect/decal/cleanable/wash(clean_types)
	. = ..()
	if (. || (clean_types & clean_type))
		qdel(src)
		return TRUE
	return .

/obj/effect/decal/cleanable/proc/handle_merge_decal(obj/effect/decal/cleanable/merger)
	if (!reagents && !decal_reagent)
		return

	if (!reagents && !merger.reagents && (!merger.decal_reagent || merger.decal_reagent == decal_reagent))
		merger.decal_reagent = decal_reagent
		merger.reagent_amount += reagent_amount
	else if (lazy_init_reagents() && merger.lazy_init_reagents())
		merger.reagents.maximum_volume += reagents.total_volume
		reagents.trans_to(merger, reagents.total_volume)

/// Returns reagents datum if it exists, or lazyloads one if it doesn't
/obj/effect/decal/cleanable/proc/lazy_init_reagents()
	RETURN_TYPE(/datum/reagents)
	if (reagents)
		return reagents

	if (!decal_reagent)
		return

	create_reagents(reagent_amount)
	reagents.add_reagent(decal_reagent, reagent_amount)
	return reagents

/// Checks if this decal can be bloodcrawled in
/obj/effect/decal/cleanable/proc/can_bloodcrawl_in()
	if (decal_reagent == /datum/reagent/blood || reagents?.has_reagent(/datum/reagent/blood))
		return TRUE

	var/list/blood_DNA = GET_ATOM_BLOOD_DECALS(src)
	for (var/blood_key in blood_DNA)
		var/datum/blood_type/blood_type = blood_DNA[blood_key]
		if (blood_type.reagent_type == /datum/reagent/blood)
			return TRUE
	return FALSE

/// Creates a cleanable decal on a turf
/// Use this if your decal is one of one, and thus we should not spawn it if it's there already
/// Returns either the existing cleanable, the one we created, or null if we can't spawn on that turf
/turf/proc/spawn_unique_cleanable(obj/effect/decal/cleanable/cleanable_type)
	// There is no need to spam unique cleanables, they don't stack and it just chews cpu
	var/obj/effect/decal/cleanable/existing = locate(cleanable_type) in src
	if (existing)
		return existing
	return new cleanable_type(src)
