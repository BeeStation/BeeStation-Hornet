//Disables nearby tech equipment.
/obj/item/clothing/suit/space/space_ninja/proc/ninjapulse()

	if(!ninjacost(250, N_STEALTH_CANCEL))
		playsound(suit_user.loc, 'sound/effects/empulse.ogg', 60, 2)
		empulse(suit_user, 4, 6) //Procs sure are nice. Slightly weaker than wizard's disable tch.
		s_coold = 4
