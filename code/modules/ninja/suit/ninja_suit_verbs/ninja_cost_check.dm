

//Cost function for suit Procs/Verbs/Abilities
//This proc is so stupid lol
/obj/item/clothing/suit/space/space_ninja/proc/ninjacost(cost = 0, specificCheck = 0)
	var/actualCost = cost*10
	if(cost && cell.charge < actualCost)
		to_chat(suit_user, "<span class='danger'>Not enough energy.</span>")
		return TRUE
	else
		//This shit used to be handled individually on every proc.. why even bother with a universal check proc then?
		cell.charge-=(actualCost)

	switch(specificCheck)
		if(N_STEALTH_CANCEL)
			cancel_stealth()//Get rid of it.
		if(N_SMOKE_BOMB)
			if(!s_bombs)
				to_chat(suit_user, "<span class='danger'>There are no more smoke bombs remaining.</span>")
				return TRUE
		if(N_ADRENALINE)
			if(!a_boost)
				to_chat(suit_user, "<span class='danger'>You do not have any more adrenaline boosters.</span>")
				return TRUE
	return (s_coold)//Returns the value of the variable which counts down to zero.
