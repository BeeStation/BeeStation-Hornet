//BEEBOT
/mob/living/simple_animal/pet/beebot
	name = "Beebot"
	desc = "The happy bee bot pet of the Research Director"
	icon_state = "beebot"
	icon_living = "beebot"
	icon_dead = "beebot_dead"
	mob_biotypes = MOB_ROBOTIC
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	speak = list("Yipeee!", "I'm feeling funky!", "BeeBot time!", "His mango")
	speak_emote = list("barks", "woofs")
	speak_language = /datum/language/metalanguage
	emote_hear = list("flaps its wings happily.","displays a happy face.")
	emote_see = list("flaps its wings.","buzzes.")
	faction = list("neutral")
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 10
	can_be_held = TRUE
	chat_color = "#ffd000"
	mobchatspan = "beebot"
	held_state = "beebot"
	worn_slot_flags = ITEM_SLOT_HEAD
	footstep_type = FOOTSTEP_OBJ_ROBOT


	var/obj/item/inventory_head
	var/obj/item/inventory_back
	var/blood_state
	blood_state = BLOOD_STATE_OIL
/mob/living/simple_animal/pet/beebot/update_resting()
	. = ..()
	if(stat == DEAD)
		return
	if (resting)
		icon_state = "[icon_living]_rest"
	else
		icon_state = "[icon_living]"
	regenerate_icons()

/mob/living/simple_animal/pet/beebot/Life()
	if(!stat && !buckled && !client)
		if(prob(1))
			manual_emote(pick("lands.", "rests a little."))
			set_resting(TRUE)
		else if (prob(1))
			manual_emote(pick("lands.", "rests a little."))
			set_resting(TRUE)
			icon_state = "[icon_living]_sit"
		else if (prob(1))
			if (resting)
				manual_emote(pick("starts flying again.", "flies around.", "displays a hearts on its face."))
				set_resting(FALSE)
			else
				manual_emote(pick("buzzes.", "restarts its software.", "cleans its screen using windshields."))

	..()
