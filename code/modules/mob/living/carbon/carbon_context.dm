/mob/living/carbon/add_context_self(datum/source, datum/screentip_context/context, mob/user)
	. = ..()

	/*
	if (!isnull(context.held_item))
		context.add_ctrl_shift_click_item_action("Offer item")
		return
	*/

	if (!ishuman(user))
		return .

	var/mob/living/carbon/human/human_user = user

	if (human_user.a_intent == INTENT_HARM) //if (human_user.combat_mode) (I)
		context.add_left_click_action("Attack")
	else if (human_user == src)
		context.add_left_click_action("Check injuries")

	if (human_user != src)
		if(human_user.a_intent == INTENT_DISARM) //Delete this line (I)
			context.add_left_click_action("Shove")

		else if (human_user.a_intent != INTENT_HARM) //if (!human_user.combat_mode) (I)
			if (body_position == STANDING_UP)
				if(check_zone(user.get_combat_bodyzone(src)) == BODY_ZONE_HEAD && get_bodypart(BODY_ZONE_HEAD))
					context.add_left_click_action("Headpat")
				else
					context.add_left_click_action("Hug")
			else if (health >= 0 && !HAS_TRAIT(src, TRAIT_FAKEDEATH))
				context.add_left_click_action("Shake")
			else
				context.add_left_click_action("CPR")
