
/obj/item/clothing/gloves/space_ninja/proc/ninja_sword_recall(var/mob/living/carbon/human/user)
	var/inview = 1

	if(!energyKatana)
		to_chat(user, "<span class='warning'>Could not locate Energy Katana!</span>")
		return

	if(energyKatana in user)
		return

	var/distance = get_dist(user,energyKatana)

	if(!(energyKatana in view(user)))
		inview = 0

	if(recall_charges > 0)
		if(iscarbon(energyKatana.loc))
			var/mob/living/carbon/C = energyKatana.loc
			C.transferItemToLoc(energyKatana, get_turf(energyKatana), TRUE)

		else
			energyKatana.forceMove(get_turf(energyKatana))

		if(inview) //If we can see the katana, throw it towards ourselves, damaging people as we go.
			energyKatana.spark_system.start()
			playsound(user, "sparks", 50, 1)
			user.visible_message("<span class='danger'>\the [energyKatana] flies towards [user]!</span>","<span class='warning'>You hold out your hand and \the [energyKatana] flies towards you!</span>")
			energyKatana.throw_at(user, distance+1, energyKatana.throw_speed,user)

		else //Else just TP it to us.
			energyKatana.returnToOwner(user,1)

		recall_charges--
		to_chat(user, "<span class='warning'>The gloves have [recall_charges] recall charges left.</span>")
	else 
		to_chat(user, "<span class='warning'>Out of charges!</span>")