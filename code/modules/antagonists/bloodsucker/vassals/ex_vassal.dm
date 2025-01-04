#define BLOOD_TIMER_REQUIREMENT (10 MINUTES)
#define BLOOD_TIMER_HALWAY (BLOOD_TIMER_REQUIREMENT / 2)

/datum/antagonist/ex_vassal
	name = "\improper Ex-Vassal"
	roundend_category = "vassals"
	antagpanel_category = "Bloodsucker"
	banning_key = ROLE_BLOODSUCKER
	var/vassal_hud_name = "vassal_grey"
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	silent = TRUE
	ui_name = FALSE

	///The revenge vassal that brought us into the fold.
	var/datum/antagonist/vassal/revenge/revenge_vassal
	///Timer we have to live
	COOLDOWN_DECLARE(blood_timer)

/datum/antagonist/ex_vassal/on_gain()
	. = ..()
	RegisterSignal(owner.current, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/antagonist/ex_vassal/on_removal()
	if(revenge_vassal)
		revenge_vassal.ex_vassals -= src
		revenge_vassal = null
	blood_timer = null

	remove_antag_hud(ANTAG_HUD_BLOODSUCKER, owner.current)
	return ..()

/datum/antagonist/ex_vassal/proc/on_examine(datum/source, mob/examiner, examine_text)
	SIGNAL_HANDLER

	var/datum/antagonist/vassal/revenge/vassaldatum = examiner.mind.has_antag_datum(/datum/antagonist/vassal/revenge)
	if(vassaldatum && !revenge_vassal)
		examine_text += "<span class='notice'>[owner.current] is an ex-vassal!</span>"

/**
 * Fold return
 *
 * Called when a Revenge bloodsucker gets a vassal back into the fold.
 */
/datum/antagonist/ex_vassal/proc/return_to_fold(datum/antagonist/vassal/revenge/mike_ehrmantraut)
	revenge_vassal = mike_ehrmantraut // what did john fulp willard mean by this
	mike_ehrmantraut.ex_vassals += src
	COOLDOWN_START(src, blood_timer, BLOOD_TIMER_REQUIREMENT)
	add_antag_hud(ANTAG_HUD_BLOODSUCKER, vassal_hud_name, owner.current)

	RegisterSignal(src, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/antagonist/ex_vassal/proc/on_life(datum/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	if(COOLDOWN_TIMELEFT(src, blood_timer) <= BLOOD_TIMER_HALWAY + 2 && COOLDOWN_TIMELEFT(src, blood_timer) >= BLOOD_TIMER_HALWAY - 2) //just about halfway
		to_chat(owner.current, "<span class='cultbold'>You need new blood from your Master!</span>")
	if(!COOLDOWN_FINISHED(src, blood_timer))
		return
	to_chat(owner.current, "<span class='cultbold'>You are out of blood!</span>")
	to_chat(revenge_vassal.owner.current, "<span class='cultbold'>[owner.current] has ran out of blood and is no longer in the fold!</span>")
	owner.remove_antag_datum(/datum/antagonist/ex_vassal)


/**
 * Bloodsucker Blood
 *
 * Artificially made, this must be fed to ex-vassals to keep them on their high.
 */
/datum/reagent/blood/bloodsucker
	name = "Blood two"

/datum/reagent/blood/bloodsucker/on_mob_metabolize(mob/living/L)
	var/datum/antagonist/ex_vassal/former_vassal = L.mind.has_antag_datum(/datum/antagonist/ex_vassal)
	if(former_vassal)
		to_chat(L, "<span class='cult'>You feel the blood restore you... You feel safe.</span>")
		COOLDOWN_RESET(former_vassal, blood_timer)
		COOLDOWN_START(former_vassal, blood_timer, BLOOD_TIMER_REQUIREMENT)
	return ..()

#undef BLOOD_TIMER_REQUIREMENT
#undef BLOOD_TIMER_HALWAY
