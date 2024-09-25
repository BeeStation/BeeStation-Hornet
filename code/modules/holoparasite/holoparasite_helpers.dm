/mob/living/simple_animal/hostile/holoparasite
	/// A typecache of objects that the holoparasite where, if the holoparasite's summoner is inside of one of these objects, the holoparasite will not be allowed to manifest.
	var/static/list/no_manifest_locs

/mob/living/simple_animal/hostile/holoparasite/Initialize(_mapload, _key, _name, datum/holoparasite_theme/_theme, _accent_color, _notes, datum/mind/_summoner, datum/holoparasite_stats/_stats)
	. = ..()
	if(!no_manifest_locs)
		no_manifest_locs = typecacheof(list(/obj/effect, /obj/machinery/clonepod)) - typecacheof(list(/obj/effect/abstract/sync_holder, /obj/effect/dummy))

/**
 * Returns whether the holoparasite is allowed to be manifested or not.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/can_be_manifested()
	. = TRUE
	if(QDELETED(summoner.current))
		return FALSE
	var/summoner_loc = summoner.current.loc
	if(isnull(loc) || isnull(summoner_loc)) // no manifesting from nullspace!!
		return FALSE
	if(is_type_in_typecache(summoner_loc, no_manifest_locs))
		return FALSE

/**
 * Whether the holoparasite should be 'attached' to its summoner or not.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/is_attached_to_summoner(permanently = FALSE, check_manifested = TRUE)
	if(QDELETED(summoner.current))
		return FALSE
	if(check_manifested && !is_manifested())
		return FALSE
	if(range <= 0)
		return FALSE
	return (!permanently && attached_to_summoner) || stats?.range == 1

/**
 * Returns whether the holoparasite is within range of its summoner or not.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/is_in_range(atom/target)
	if(!can_be_manifested())
		return FALSE
	// Range <= 0 means infinite range.
	if(range <= 0)
		return TRUE
	target = target ? get_turf(target) : get_turf(src)
	if(get_dist(target, get_turf(summoner.current)) <= range)
		return TRUE
	return FALSE

/**
 * Returns whether the holoparasite's summoner is dead or not.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/is_summoner_dead()
	. = FALSE
	if(QDELETED(summoner.current))
		return TRUE
	if(summoner.current.stat == DEAD && !HAS_TRAIT(summoner.current, TRAIT_NODEATH))
		return TRUE

/**
 * Returns whether the holoparasite is manifested or not.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/is_manifested()
	return !isnull(loc) && loc != summoner.current

/**
 * Returns whether this holoparasite has a matching summoner with another holoparasite, or if the other mob is the summoner.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/has_matching_summoner(mob/living/other, include_summoner = TRUE)
	if(!istype(other))
		return FALSE
	if(other == src)
		return TRUE
	if(isholopara(other))
		var/mob/living/simple_animal/hostile/holoparasite/other_holopara = other
		return other_holopara.summoner == summoner
	return include_summoner && other.mind == summoner

/**
 * Returns a list of all holoparasites summoned by this mob.
 */
/mob/living/proc/holoparasites()
	return mind?.holoparasite_holder?.holoparasites

/**
 * Returns TRUE if a mob has any holoparasites, FALSE if they do not.
 */
/mob/living/proc/has_holoparasites()
	return length(holoparasites())

/**
 * Returns a list containing the summoner, and all holoparasites summoned by the owner.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/list_summoner_and_or_holoparasites(include_self = TRUE, include_summoner = TRUE)
	. = list()
	if(include_self)
		. += src
	if(include_summoner && summoner.current)
		. += summoner.current
	. += (parent_holder.holoparasites - src)

/**
 * Returns TRUE if the holoparasite's light is enabled or not, taking emissiveness into account.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/is_light_on()
	return emissive ? (max(light_range, light_power) > 0.1) : light_on

/**
 * Creates an outline filter around an object, colored with the holoparasite's accent color.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/give_accent_border(atom/target, size = 1)
	if(QDELETED(target))
		return
	target.remove_filter("holoparasite_accent_color")
	target.add_filter("holoparasite_accent_color", 1, drop_shadow_filter(x = 0, y = -2, size = size, color = "[accent_color]AA"))
