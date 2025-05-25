/datum/holoparasite_ability/major/gravity
	name = "Gravity"
	desc = "The $theme's punches apply heavy gravity to whatever it punches."
	ui_icon = "angle-double-down"
	cost = 2
	thresholds = list(
		list(
			"stat" = "Potential",
			"desc" = "Increases the distance the holoparasite can maintain the gravity effect from."
		)
	)
	var/list/gravito_targets = list()

/datum/holoparasite_ability/major/gravity/register_signals()
	..()
	RegisterSignal(owner, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_attack))
	RegisterSignal(owner, COMSIG_HOLOPARA_RECALL, PROC_REF(on_recall))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(recheck_distances))
	RegisterSignal(owner, COMSIG_MOB_ALTCLICKON, PROC_REF(on_alt_click))

/datum/holoparasite_ability/major/gravity/unregister_signals()
	..()
	UnregisterSignal(owner, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_HOLOPARA_RECALL, COMSIG_MOVABLE_MOVED, COMSIG_MOB_ALTCLICKON))

/datum/holoparasite_ability/major/gravity/proc/on_attack(datum/_source, mob/living/target)
	SIGNAL_HANDLER
	ASSERT_ABILITY_USABILITY_SILENT
	if(!istype(target))
		return
	if(owner.has_matching_summoner(target))
		return
	to_chat(owner, span_dangerbold("Your punch has applied heavy gravity to [target]!"))
	add_gravity(target, 2)
	to_chat(target, span_userdanger("Everything feels really heavy!"))

/**
 * Handles undoing gravity whenever the holoparasite is recalled.
 */
/datum/holoparasite_ability/major/gravity/proc/on_recall()
	SIGNAL_HANDLER
	for(var/i in gravito_targets)
		if(get_dist(src, i) > (master_stats.potential * 2))
			remove_gravity(i)

/datum/holoparasite_ability/major/gravity/proc/recheck_distances()
	SIGNAL_HANDLER
	for(var/i in gravito_targets)
		if(get_dist(src, i) > (master_stats.potential * 2))
			remove_gravity(i)

/datum/holoparasite_ability/major/gravity/proc/on_alt_click(datum/_source, turf/open/target)
	SIGNAL_HANDLER
	ASSERT_ABILITY_USABILITY
	if(!istype(target) || !owner.is_manifested() || !in_range(owner, target))
		return
	if(isspaceturf(target))
		to_chat(owner, span_warning("You cannot add gravity to space!"))
		return
	owner.visible_message(span_danger("[owner.color_name] slams their fist into \the [target]!"), span_notice("You modify the gravity of \the [target]."))
	owner.do_attack_animation(target)
	add_gravity(target, 4)

/datum/holoparasite_ability/major/gravity/proc/add_gravity(atom/target, new_gravity = 2)
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(__distance_check))
	target.AddElement(/datum/element/forced_gravity, new_gravity)
	gravito_targets[target] = new_gravity
	playsound(src, 'sound/effects/gravhit.ogg', vol = 100, vary = TRUE)

/datum/holoparasite_ability/major/gravity/proc/remove_gravity(atom/target)
	if(isnull(gravito_targets[target]))
		return
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	target.RemoveElement(/datum/element/forced_gravity, gravito_targets[target])
	gravito_targets -= target

/datum/holoparasite_ability/major/gravity/proc/__distance_check(atom/movable/target, old_loc, dir, forced)
	SIGNAL_HANDLER
	if(get_dist(src, target) > (master_stats.potential * 2))
		remove_gravity(target)
