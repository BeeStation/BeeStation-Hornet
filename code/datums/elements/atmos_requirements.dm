	///Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	///Leaving something at 0 means it's off - has no maximum.

	///This damage is taken when atmos doesn't fit all the requirements above.


/**
 * ## atmos requirements element!
 *
 * bespoke element that deals damage to the attached mob when the atmos requirements aren't satisfied
 */
/datum/element/atmos_requirements
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	var/list/atmos_requirements
	var/unsuitable_atmos_damage

/datum/element/atmos_requirements/Attach(datum/target, list/atmos_requirements, unsuitable_atmos_damage)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.atmos_requirements = string_assoc_list(atmos_requirements)
	RegisterSignal(target, COMSIG_LIVING_HANDLE_BREATHING, PROC_REF(on_non_stasis_life))

/datum/element/atmos_requirements/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_HANDLE_BREATHING)

/datum/element/atmos_requirements/proc/on_non_stasis_life(mob/living/target, delta_time = SSMOBS_DT)
	SIGNAL_HANDLER
	if(is_breathable_atmos(target))
		target.clear_alert("not_enough_oxy")
		return
	target.adjustBruteLoss(unsuitable_atmos_damage * delta_time)
	target.throw_alert("not_enough_oxy", /atom/movable/screen/alert/not_enough_oxy)

/datum/element/atmos_requirements/proc/is_breathable_atmos(mob/living/target)
	if(target.pulledby && target.pulledby.grab_state >= GRAB_KILL && atmos_requirements["min_oxy"])
		return FALSE

	if(!isopenturf(target.loc))
		return TRUE

	var/turf/open/ST = target.loc
	if(!ST.air && (atmos_requirements["min_oxy"] || atmos_requirements["min_tox"] || atmos_requirements["min_n2"] || atmos_requirements["min_co2"]))
		return FALSE

	var/plas = ST.air.get_moles(GAS_PLASMA)
	var/oxy = ST.air.get_moles(GAS_O2)
	var/n2  = ST.air.get_moles(GAS_N2)
	var/co2 = ST.air.get_moles(GAS_CO2)

	. = TRUE
	if(atmos_requirements["min_oxy"] && oxy < atmos_requirements["min_oxy"])
		. = FALSE
	else if(atmos_requirements["max_oxy"] && oxy > atmos_requirements["max_oxy"])
		. = FALSE
	else if(atmos_requirements["min_plas"] && plas < atmos_requirements["min_plas"])
		. = FALSE
	else if(atmos_requirements["max_plas"] && plas > atmos_requirements["max_plas"])
		. = FALSE
	else if(atmos_requirements["min_n2"] && n2 < atmos_requirements["min_n2"])
		. = FALSE
	else if(atmos_requirements["max_n2"] && n2 > atmos_requirements["max_n2"])
		. = FALSE
	else if(atmos_requirements["min_co2"] && co2 < atmos_requirements["min_co2"])
		. = FALSE
	else if(atmos_requirements["max_co2"] && co2 > atmos_requirements["max_co2"])
		. = FALSE
