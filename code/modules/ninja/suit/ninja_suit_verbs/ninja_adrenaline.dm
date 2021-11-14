//Wakes the user so they are able to do their thing. Also injects a decent dose of radium.
//Movement impairing would indicate drugs and the like.
/obj/item/clothing/suit/space/space_ninja/proc/ninjaboost()

	if(!ninjacost(0,N_ADRENALINE))
		suit_user.SetUnconscious(0)
		suit_user.SetStun(0)
		suit_user.SetKnockdown(0)
		suit_user.SetImmobilized(0)
		suit_user.SetParalyzed(0)
		suit_user.adjustStaminaLoss(-75)
		suit_user.stuttering = 0
		suit_user.lying = 0
		suit_user.update_mobility()
		suit_user.reagents.add_reagent(/datum/reagent/medicine/amphetamine, 5)
		a_boost--
		to_chat(suit_user, "<span class='notice'>There are <B>[a_boost]</B> adrenaline boosts remaining.</span>")
		s_coold = 6
