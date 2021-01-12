

//Creates a throwing star
/obj/item/clothing/gloves/space_ninja/proc/ninjafabricate(var/mob/living/carbon/human/user)
	if(fabrication_charges > 0)
		var/choice = input(user,"Which item would you like to fabricate?","Select an Item") as null|anything in sortList(fabrication_options)
		new choice(user)
		if(user.put_in_hands(choice))
			to_chat(user, "<span class='notice'>A [choice] has been created in your hand! The gloves have [fabrication_charges] left.</span>")
			fabrication_charges--
		else
			qdel(choice)
		user.throw_mode_on() //So they can quickly throw it.
	else 
		to_chat(user, "<span class='warning'>No charges left!</span>")


/obj/item/throwing_star/ninja
	name = "ninja throwing star"
	throwforce = 30
	embedding = list("embedded_pain_multiplier" = 6, "embed_chance" = 100, "embedded_fall_chance" = 0)