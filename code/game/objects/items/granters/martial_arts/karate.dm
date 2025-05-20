/obj/item/book/granter/martial/karate
	martial = /datum/martial_art/karate
	name = "dusty scroll"
	martial_name = "karate"
	desc = "A dusty scroll filled with martial lessons. There seems to be drawings of some sort of martial art."
	greet = "<span class='sciradio'>You have learned the ancient martial art of Karate! Your hand-to-hand combat has become more effective but require skill to combo effectively.\
	You can learn more about your newfound art by using the Recall Teachings verb in the Karate tab.</span>"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	remarks = list("I must prove myself worthy to the masters of Karate...", "Disable their legs so they can't escape...", "Strike at pressure points to daze my foes...", "Stomp their head for maximum damage...", "I don't think this would combine with other martial arts...", "Wind them with a flying knee...", "I must practice to fully grasp these teachings...")

/obj/item/book/granter/martial/karate/on_reading_finished(mob/living/carbon/user)
	..()
	if(uses <= 0)
		desc = "It's completely blank."
		name = "empty scroll"
		icon_state = "blankscroll"
