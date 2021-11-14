//Smoke bomb
/obj/item/clothing/suit/space/space_ninja/proc/ninjasmoke()

	if(!ninjacost(0,N_SMOKE_BOMB))
		var/datum/effect_system/smoke_spread/bad/smoke = new
		smoke.set_up(4, suit_user.loc)
		smoke.start()
		playsound(suit_user.loc, 'sound/effects/bamf.ogg', 50, 2)
		s_bombs--
		to_chat(suit_user, "<span class='notice'>There are <B>[s_bombs]</B> smoke bombs remaining.</span>")
		s_coold = 2
