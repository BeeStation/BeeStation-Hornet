/datum/antagonist/ex_vassal
	name = "\improper Ex-Vassal"
	roundend_category = "vassals"
	antagpanel_category = "Vampire"
	banning_key = ROLE_VAMPIRE
	var/vassal_hud_name = "vassal_grey"
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	silent = TRUE
	ui_name = FALSE

	///The revenge vassal that brought us into the fold.
	var/datum/antagonist/vassal/revenge/revenge_vassal
	///Reuse the vampire team
	var/datum/team/vampire/vampire_team
	///Timer we have to live
	COOLDOWN_DECLARE(blood_timer)

/datum/antagonist/ex_vassal/apply_innate_effects(mob/living/mob_override)
	. = ..()
	set_antag_hud(owner.current, vassal_hud_name)

/datum/antagonist/ex_vassal/remove_innate_effects(mob/living/mob_override)
	. = ..()
	set_antag_hud(owner.current, null)

/datum/antagonist/ex_vassal/on_removal()
	if(revenge_vassal)
		revenge_vassal.ex_vassals -= src
		revenge_vassal = null
	blood_timer = null

	vampire_team.remove_member(owner.current.mind)
	vampire_team.hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

	return ..()

/*
 * Fold return
 *
 * Called when a Revenge vampire gets a vassal back into the fold.
 */
/datum/antagonist/ex_vassal/proc/return_to_fold(datum/antagonist/vassal/revenge/mike_ehrmantraut)
	revenge_vassal = mike_ehrmantraut // what did john fulp willard mean by this
	revenge_vassal.ex_vassals += src

	vampire_team.add_member(owner.current.mind)
	vampire_team.hud.join_hud(owner.current)
	set_antag_hud(owner.current, vassal_hud_name)

	COOLDOWN_START(src, blood_timer, 10 MINUTES)
	RegisterSignal(src, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/antagonist/ex_vassal/proc/on_life(datum/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	if(COOLDOWN_TIMELEFT(src, blood_timer) <= 5 MINUTES + 2 && COOLDOWN_TIMELEFT(src, blood_timer) >= 5 MINUTES - 2) //just about halfway
		to_chat(owner.current, span_cultbold("You need new blood from your Master!"))
	if(!COOLDOWN_FINISHED(src, blood_timer))
		return
	to_chat(owner.current, span_cultbold("You are out of blood!"))
	to_chat(revenge_vassal.owner.current, span_cultbold("[owner.current] has ran out of blood and has permanently left the fold!"))
	owner.remove_antag_datum(/datum/antagonist/ex_vassal)
