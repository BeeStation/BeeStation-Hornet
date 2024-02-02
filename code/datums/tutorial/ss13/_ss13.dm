/datum/tutorial/ss13
	category = TUTORIAL_CATEGORY_SS13
	parent_path = /datum/tutorial/ss13
	icon_state = "ss13"

/datum/tutorial/ss13/init_mob()

	var/mob/living/carbon/human/new_character = new(bottom_left_corner)
	tutorial_mob.close_spawn_windows()
	if(tutorial_mob.mind)
		tutorial_mob.mind_initialize()
		tutorial_mob.mind.transfer_to(new_character, TRUE)
	tutorial_mob = new_character
	return ..()
