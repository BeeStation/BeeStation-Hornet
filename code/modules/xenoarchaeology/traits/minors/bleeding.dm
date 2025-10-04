/*
	Bleeding
	The artifact bleeds for a short period after being activated
*/
/datum/xenoartifact_trait/minor/bleed
	label_name = "Bleeding"
	label_desc = "Bleeding: The artifact's design seems to incorporate bleeding elements. This will cause the artifact to bleed when triggered."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 15
	blacklist_traits = list(/datum/xenoartifact_trait/minor/bleed/fun)
	///Timer stuff to keep track of when we're bleeding
	var/bleed_duration = 5 SECONDS
	var/bleed_timer
	///Which blood decal do we use?
	var/blood_splat = /obj/effect/decal/cleanable/blood
	var/blood_tracks = /obj/effect/decal/cleanable/blood/tracks

/datum/xenoartifact_trait/minor/bleed/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!. || bleed_timer)
		return
	playsound(component_parent.parent, 'sound/effects/splat.ogg', 50, TRUE)
	new blood_splat(get_turf(component_parent.parent))
	bleed_timer = addtimer(CALLBACK(src, PROC_REF(reset_timer)), bleed_duration, TIMER_STOPPABLE)

/datum/xenoartifact_trait/minor/bleed/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("bleed red blood"))

/datum/xenoartifact_trait/minor/bleed/catch_move(datum/source, atom/target, dir)
	. = ..()
	if(!bleed_timer)
		return
	var/obj/effect/decal/cleanable/blood/tracks/T = new blood_tracks(get_turf(component_parent.parent))
	T.setDir(dir)

/datum/xenoartifact_trait/minor/bleed/proc/reset_timer()
	if(bleed_timer)
		deltimer(bleed_timer)
	bleed_timer = null

//Fun variant
/obj/effect/decal/cleanable/blood/fun

/obj/effect/decal/cleanable/blood/fun/Initialize(mapload)
	color = "#[random_color()]"
	return ..()

/obj/effect/decal/cleanable/blood/tracks/fun

/obj/effect/decal/cleanable/blood/tracks/fun/Initialize(mapload)
	color = "#[random_color()]"
	return ..()

/datum/xenoartifact_trait/minor/bleed/fun
	label_name = "Bleeding Δ"
	label_desc = "Bleeding Δ: The artifact's design seems to incorporate bleeding elements. This will cause the artifact to bleed when triggered."
	conductivity = 15
	flags = XENOA_MISC_TRAIT | XENOA_HIDE_TRAIT //Delete this line when the blood changes come back
	blacklist_traits = list(/datum/xenoartifact_trait/minor/bleed)
	blood_splat = /obj/effect/decal/cleanable/blood/fun
	blood_tracks = /obj/effect/decal/cleanable/blood/tracks/fun

/datum/xenoartifact_trait/minor/bleed/fun/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("bleed 'clown' blood"))
