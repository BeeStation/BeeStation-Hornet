#define REVELATION_MIN_COOLDOWN	20 SECONDS
#define REVELATION_MAX_COOLDOWN	1 MINUTES

/datum/vampire_clan/malkavian
	name = CLAN_MALKAVIAN
	description = "Malkavians are the brood of Malkav and one of the great vampiric clans. They are deranged vampires, afflicted with the insanity of their Antediluvian progenitor.<br><br>\
		Members of the clan have assumed the roles of seers and oracles among Kindred and kine, eerie figures bound by strange compulsions and the ability to perceive what others cannot.<br><br>\
		They are also notorious pranksters whose 'jokes' range from silly to sadistic. Against all odds, however, the children of Malkav are among the oldest surviving vampiric lineages."
	join_icon_state = "malkavian"
	join_description = "Completely insane. You gain constant hallucinations, become a prophet with unintelligable rambling, and gain insights better left unknown. You can also travel through Phobetor tears, rifts through spacetime only you can travel through.\n\
		<b>DISCIPLINES:</b> Dementation, Auspex, Obfuscate"

	default_humanity = 7

	COOLDOWN_DECLARE(revelation_cooldown)

/datum/vampire_clan/malkavian/New(datum/antagonist/vampire/owner_datum)
	. = ..()

	var/mob/living/carbon/carbon_owner = vampiredatum.owner.current
	if(istype(carbon_owner))
		carbon_owner.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbon_owner.gain_trauma(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)

	ADD_TRAIT(vampiredatum.owner.current, TRAIT_XRAY_VISION, TRAIT_VAMPIRE)
	vampiredatum.owner.current.update_sight()

	vampiredatum.owner.current.playsound_local(get_turf(vampiredatum.owner.current), 'sound/ambience/antag/creepalert.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(vampiredatum.owner.current, span_hypnophrase("Welcome, childe of Malkav..."))

/datum/vampire_clan/malkavian/Destroy(force)
	REMOVE_TRAIT(vampiredatum.owner.current, TRAIT_XRAY_VISION, TRAIT_VAMPIRE)
	vampiredatum.owner.current.update_sight()

	var/mob/living/carbon/carbon_owner = vampiredatum.owner.current
	if(istype(carbon_owner))
		carbon_owner.cure_trauma_type(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbon_owner.cure_trauma_type(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)
	return ..()

/datum/vampire_clan/malkavian/handle_clan_life()
	. = ..()
	var/mob/living/living_vampire = vampiredatum.owner.current
	if(!COOLDOWN_FINISHED(src, revelation_cooldown) || HAS_TRAIT(living_vampire, TRAIT_MASQUERADE) || living_vampire.stat != CONSCIOUS)
		return

	if(prob(15))
		var/message = pick(strings("malkavian_revelations.json", "revelations", "strings"))
		INVOKE_ASYNC(living_vampire, TYPE_PROC_REF(/mob/living, whisper), message)
		COOLDOWN_START(src, revelation_cooldown, rand(REVELATION_MIN_COOLDOWN, REVELATION_MAX_COOLDOWN))

/datum/vampire_clan/malkavian/on_favorite_ghoul(datum/antagonist/ghoul/favorite/favorite_ghoul)
	var/mob/living/carbon/carbon_ghoul = favorite_ghoul.owner.current
	if(istype(carbon_ghoul))
		carbon_ghoul.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbon_ghoul.gain_trauma(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)
		to_chat(carbon_ghoul, span_notice("Additionally, you now suffer the same fate as your Master."))

/datum/vampire_clan/malkavian/on_exit_torpor()
	var/mob/living/carbon/carbon_vampire = vampiredatum.owner.current
	if(istype(carbon_vampire))
		carbon_vampire.gain_trauma(/datum/brain_trauma/mild/hallucinations, TRAUMA_RESILIENCE_ABSOLUTE)
		carbon_vampire.gain_trauma(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)

#undef REVELATION_MAX_COOLDOWN
#undef REVELATION_MIN_COOLDOWN
