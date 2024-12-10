/obj/item/book/granter/martial/tribal_claw
	martial = /datum/martial_art/tribal_claw
	name = "mysterious scroll"
	martial_name = "tribal claw"
	desc = "A scroll filled with strange markings. It seems to be drawings of some sort of martial art."
	greet = "<span class='sciradio'>You have learned the ancient martial art of the Sleeping Carp! Your hand-to-hand combat has become much more effective, and you are now able to deflect any projectiles \
		directed toward you while in Throw Mode. Your body has also hardened itself, granting extra protection against lasting wounds that would otherwise mount during extended combat. \
		However, you are also unable to use any ranged weaponry. You can learn more about your newfound art by using the Recall Teachings verb in the Sleeping Carp tab.</span>"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	worn_icon_state = "scroll"
	remarks = list(
		"Something something lizard" //Pretty please helpsies with this
	)

/obj/item/book/granter/martial/tribal_claw/on_reading_finished(mob/living/carbon/user)
	. = ..()
	update_appearance()

/obj/item/book/granter/martial/tribal_claw/update_appearance(updates)
	. = ..()
	if(uses <= 0)
		name = "empty scroll"
		desc = "It's completely blank."
		icon_state = "blankscroll"
	else
		name = initial(name)
		desc = initial(desc)
		icon_state = initial(icon_state)
