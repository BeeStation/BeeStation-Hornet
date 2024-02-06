/datum/tutorial/ss13/intents
	name = "Space Station 13 - Intents"
	desc = "Learn how the intent interaction system works."
	tutorial_id = "ss13_intents_1"
	tutorial_template = /datum/map_template/tutorial/s12x12

/datum/tutorial/ss13/intents/start_tutorial(mob/starting_mob)
	. = ..()
	if(!.)
		return

	init_mob()
	message_to_player("This is the tutorial for the <b>intents</b> system of Space Station 13. The highlighted UI element in the bottom-right corner is your current intent.")
//	var/datum/hud/human/human_hud = tutorial_mob.hud_used
//	add_highlight(human_hud.action_intent)

	addtimer(CALLBACK(src, PROC_REF(require_help)), 4.5 SECONDS)

/datum/tutorial/ss13/intents/proc/require_help()
    tutorial_mob.a_intent_change(INTENT_DISARM)
    message_to_player("Your intent has been changed off of <b>help</b>. Change back to it by pressing <b>[retrieve_bind("select_help_intent")]</b>.")
    RegisterSignal(tutorial_mob, COMSIG_MOB_INTENT_CHANGE, PROC_REF(on_help_intent))

/datum/tutorial/ss13/intents/proc/on_help_intent(datum/source, new_intent)
    SIGNAL_HANDLER

    if(new_intent != INTENT_HELP)
        return

    UnregisterSignal(tutorial_mob, COMSIG_MOB_INTENT_CHANGE)

    var/mob/living/carbon/human/dummy/tutorial_dummy = new(loc_from_corner(2, 3))
    message_to_player("The first of the intents is <b>help</b> intent. It is used to harmlessly touch others, put out fire, give CPR, and similar. Click on the <b>Test Dummy</b> to give them a hug.")

//    RegisterSignal(tutorial_mob, COMSIG_MOB_ATTACK_HAND, PROC_REF(on_help_attack))
