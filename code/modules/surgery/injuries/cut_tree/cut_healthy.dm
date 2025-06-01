/datum/injury/cut_healthy

/datum/injury/cut_healthy/apply_to_human(mob/living/carbon/human/target)
	. = ..()
	RegisterSignal(target, SIGNAL_ADD_STATUS_EFFECT(/datum/status_effect/bleeding), PROC_REF(on_bleeding_start))

/datum/injury/cut_healthy/proc/on_bleeding_start(datum/status_effect/bleeding/bleeding)
	transition_to(/datum/injury/cut_minor)
