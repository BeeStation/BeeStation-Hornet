

//Creates a throwing star
/obj/item/clothing/gloves/space_ninja/proc/ninjafabricate(var/mob/living/carbon/human/user)
	if(fabrication_charges > 0)
		var/choice = input(user,"Which item would you like to fabricate?","Select an Item") as null|anything in sortList(fabrication_options)
		var/obj/new_item = new choice()
		if(user.put_in_hands(new_item))
			to_chat(user, "<span class='notice'>A [new_item] has been created in your hand! The gloves have [fabrication_charges] left.</span>")
			fabrication_charges--
		else
			qdel(choice)
			to_chat(user, "<span class='warning'>Error: hands are full. [new_item] was not created.</span>")
		user.throw_mode_on() //So they can quickly throw it.
	else 
		to_chat(user, "<span class='warning'>No charges left!</span>")