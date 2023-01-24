/datum/dmm_change_handler/proc/on_mapload(atom/target)
	return

// this is used to change dmm mob data based on DEFINE, because using DEFINE in dmm is not valid.
// for example, wizard's medibot "nobody's perfect" is supposed to have special faction defines because we don't want experiment 35b is taunted by it.
// but using DEFINE in dmm is not valid, so we need to give a new datum for it.


/* this is an example
-------------------------------
/mob/living/simple_animal/bot/medbot/mysterious{
	name = "Nobody's Perfect";
	desc = "If you don't accidentally blow yourself up from time to time you're not really a wizard anyway.";
	dmm_handler = /datum/dmm_change_handler/faction_changer/wizard_medibot
	},
-------------------------------
*/
