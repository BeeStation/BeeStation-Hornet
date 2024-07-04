/mob/living/simple_animal/pet/drone
	name = "Drone"
	desc = "It's a cute drone."
	butcher_results = list(/obj/item/stack/sheet/iron/ten = 1, /obj/item/aicard/aitater = 1)
	
	mob_biotypes = list(MOB_ROBOTIC)
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	force_threshold = 5
	speak = list("Roger, roger!", "Beep, boop!", "Low battery...", "Bzzz!", "BZZZ!!")
	speak_emote = list("clicks")
	speak_language = /datum/language_holder/drone
	emote_hear = list("beeps!", "BEEPS!", "dwoops.", "beep, beep.", "chirps")
	emote_see = list("makes a series of clicks and beeps.")
	faction = list("neutral")
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 10
	ai_controller = /datum/ai_controller/dog
	can_be_held = TRUE
	chat_color = "#ECDA88"
	mobchatspan = "drone"
	gold_core_spawnable = FRIENDLY_SPAWN
	
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_maint_grey"
	icon_living = "drone_maint_grey"
	icon_dead = "drone_maint_dead"
	
	footstep_type = FOOTSTEP_OBJ_ROBOT
	
/mob/living/simple_animal/pet/drone/syndie
	name = "Syndrone"
	desc = "It's an evil drone."
	
	speak = list("Kill, kill!", "I want secret NT research!", "I want it now!", "NUKE! NUKE! NUKE!")
	speak_emote = list("clicks")
	speak_language = /datum/language_holder/drone
	emote_hear = list("beeps!", "BEEPS!", "dwoops.", "beep, beep.", "chirps.")
	emote_see = list("makes a series of clicks and beeps.")
	list("Syndicate")
	
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_synd"
	icon_living = "drone_synd"
	icon_dead = "drone_maint_dead"
	
	turns_per_move = 15
	gold_core_spawnable = NO_SPAWN
