/obj/item/book/granter/martial/tribal_claw
	martial = /datum/martial_art/tribal_claw
	name = "mysterious scroll"
	martial_name = "tribal claw"
	desc = "A scroll filled with strange markings. It seems to be drawings of some sort of martial art."
	greet = "<span class='sciradio'>You have learned the ancient martial art of the Tribal Claw! \
		You are now able to use your tail and claws in a fight much better than before.</span>"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	worn_icon_state = "scroll"
	remarks = list(
		"You trace the strange markings, they twist like claw marks rather than letters...",
		"Your tail is not for balance alone, it binds, breaks, and claims...",
		"When the foe lunges, meet them claw to face. Blind their sight, twist their balance, leave them lost...",
		"Only when the prey stills, gasping, bound, or broken may the river be opened. Slice cleanly..."
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
