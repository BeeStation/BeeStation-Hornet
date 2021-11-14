
/obj/item/clothing/suit/space/space_ninja/proc/ninja_sword_recall()
	var/cost = 0
	var/inview = 1

	if(!energyKatana)
		to_chat(suit_user, "<span class='warning'>Could not locate Energy Katana!</span>")
		return

	var/distance = get_dist(suit_user, energyKatana)

	if(distance <= 1)
		return

	if(!(energyKatana in view(suit_user)))
		cost = distance //Actual cost is cost x 10, so 5 turfs is 50 cost.
		inview = 0

	if(!ninjacost(cost))
		if(iscarbon(energyKatana.loc))
			var/mob/living/carbon/C = energyKatana.loc
			C.transferItemToLoc(energyKatana, get_turf(energyKatana), TRUE)

		else
			energyKatana.forceMove(get_turf(energyKatana))

		if(inview) //If we can see the katana, throw it towards ourselves, damaging people as we go.
			energyKatana.spark_system.start()
			playsound(suit_user, "sparks", 50, 1)
			suit_user.visible_message("<span class='danger'>\the [energyKatana] flies towards [suit_user]!</span>","<span class='warning'>You hold out your hand and \the [energyKatana] flies towards you!</span>")
			energyKatana.throw_at(suit_user, distance+1, energyKatana.throw_speed, suit_user)

		else //Else just TP it to us.
			energyKatana.returnToOwner(suit_user, 1)
