/// A global list of vampire antag datums that have broken the Masquerade
GLOBAL_LIST_EMPTY(masquerade_breakers)

#define REVELATION_MIN_COOLDOWN	20 SECONDS
#define REVELATION_MAX_COOLDOWN	1 MINUTES

/datum/vampire_clan/malkavian
	name = CLAN_MALKAVIAN
	description = "Little is documented about Malkavians. Complete insanity is the most common theme.\n\
		The Favorite Vassal will suffer the same fate as the Master."
	join_icon_state = "malkavian"
	join_description = "Completely insane. You gain constant hallucinations, become a prophet with unintelligable rambling, \
		and are the enforcer of the Masquerade code. You can also travel through Phobetor tears, rifts through spacetime only you can travel through."
	COOLDOWN_DECLARE(revelation_cooldown)

/datum/vampire_clan/malkavian/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_VAMPIRE_BROKE_MASQUERADE, PROC_REF(on_vampire_broke_masquerade))
	ADD_TRAIT(vampiredatum.owner.current, TRAIT_XRAY_VISION, TRAIT_VAMPIRE)
	var/mob/living/carbon/carbon_owner = vampiredatum.owner.current
	if(istype(carbon_owner))
		carbon_owner.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbon_owner.gain_trauma(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)
	owner_datum.owner.current.update_sight()

	// Masquerade breakers
	for(var/datum/antagonist/vampire/unmasked in GLOB.masquerade_breakers)
		if(unmasked.owner.current && unmasked.owner.current.stat != DEAD)
			on_vampire_broke_masquerade(vampiredatum.owner.current, unmasked)

	vampiredatum.owner.current.playsound_local(get_turf(vampiredatum.owner.current), 'sound/ambience/antag/creepalert.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(vampiredatum.owner.current, span_hypnophrase("Welcome to the Malkavian..."))

/datum/vampire_clan/malkavian/Destroy(force)
	UnregisterSignal(SSdcs, COMSIG_VAMPIRE_BROKE_MASQUERADE)
	REMOVE_TRAIT(vampiredatum.owner.current, TRAIT_XRAY_VISION, TRAIT_VAMPIRE)
	var/mob/living/carbon/carbon_owner = vampiredatum.owner.current
	if(istype(carbon_owner))
		carbon_owner.cure_trauma_type(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbon_owner.cure_trauma_type(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)
	vampiredatum.owner.current.update_sight()
	return ..()

/datum/vampire_clan/malkavian/handle_clan_life(datum/antagonist/vampire/source)
	. = ..()
	if(!COOLDOWN_FINISHED(src, revelation_cooldown) || prob(85) || vampiredatum.owner.current.stat != CONSCIOUS || HAS_TRAIT(vampiredatum.owner.current, TRAIT_MASQUERADE))
		return

	var/message = pick(strings("malkavian_revelations.json", "revelations", "strings"))
	INVOKE_ASYNC(vampiredatum.owner.current, TYPE_PROC_REF(/mob/living, whisper), message)

	COOLDOWN_START(src, revelation_cooldown, rand(REVELATION_MIN_COOLDOWN, REVELATION_MAX_COOLDOWN))

/datum/vampire_clan/malkavian/on_favorite_vassal(datum/antagonist/vampire/source, datum/antagonist/vassal/vassaldatum)
	var/mob/living/carbon/carbonowner = vassaldatum.owner.current
	if(istype(carbonowner))
		carbonowner.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbonowner.gain_trauma(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)
	to_chat(vassaldatum.owner.current, span_notice("Additionally, you now suffer the same fate as your Master."))

/datum/vampire_clan/malkavian/on_exit_torpor(datum/antagonist/vampire/source)
	var/mob/living/carbon/carbonowner = vampiredatum.owner.current
	if(istype(carbonowner))
		carbonowner.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbonowner.gain_trauma(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/vampire_clan/malkavian/proc/on_vampire_broke_masquerade(datum/source, datum/antagonist/vampire/masquerade_breaker)
	SIGNAL_HANDLER

	if(masquerade_breaker == vampiredatum)
		return

	to_chat(vampiredatum.owner.current, span_userdanger("[masquerade_breaker.owner.current] has broken the Masquerade! Ensure [masquerade_breaker.owner.current.p_they()] [masquerade_breaker.owner.current.p_are()] eliminated at all costs!"))
	var/datum/objective/assassinate/masquerade_objective = new()
	masquerade_objective.target = masquerade_breaker.owner.current
	masquerade_objective.name = "Clan Objective"
	masquerade_objective.explanation_text = "Ensure [masquerade_breaker.owner.current], who has broken the Masquerade, succumbs to Final Death."
	vampiredatum.objectives += masquerade_objective
	vampiredatum.owner.announce_objectives()

#undef REVELATION_MAX_COOLDOWN
#undef REVELATION_MIN_COOLDOWN
