/obj/structure/fusioncell
	name = "Fusion Cell"
	desc = "A simple way to store radioactive energy with many capabilities."
	icon = 'icons/obj/objects.dmi'
	icon_state = "oldshieldoff"
	density = FALSE
	anchored = FALSE
	max_integrity = INFINITY
	var/emitting = FALSE
	var/radiation_count = 0
	var/emittingmount = 0
	var/i
	var/datum/looping_sound/geiger/soundloop


	/obj/structure/fusioncell/attackby(obj/item/I, mob/user, params)
		if(I.tool_behaviour == TOOL_WRENCH)
			default_unfasten_wrench(user, I, time = 5)
		return

	/obj/structure/fusioncell/proc/update_sound()
		var/datum/looping_sound/geiger/loop = soundloop
		if(emitting == FALSE)
			loop.stop()
			return
		if(radiation_count < 3500)
			loop.stop()
			return
		loop.start()

	/obj/structure/fusioncell/interact(mob/user)
		if(emitting == FALSE)
			to_chat(user, "You turn the cell on")
			rad_insulation = RAD_FULL_INSULATION //prevents infinite rads ie cant emit rads and gain rads at the same time
			icon_state = "oldshieldon"
			update_icon()
			emitting = TRUE
			update_sound()
			emittingmount = radiation_count/100
			for(i = 0, 101>i, i++)
				if(emitting == FALSE)
					return
				if(radiation_count < 3500)
					visible_message("<span class='warning'>The [src] does not have enough power to continue!!!.</span>",null,null,5)
					return
				visible_message("<span class='warning'>The [src] starts to release a pulse of <b>[emittingmount]</b> rads!!!.</span>",null,null,5)
				sleep(20 * world.tick_lag)
				radiation_pulse(src,emittingmount,5,TRUE,TRUE)
				radiation_count -= emittingmount
				visible_message("<span class='warning'>The [src] released a pulse of <b>[emittingmount]</b> rads!!!.</span>",null,null,5)
				continue
			return
		if(emitting == TRUE)
			to_chat(user, "You turn the cell off")
			rad_insulation = RAD_NO_INSULATION
			icon_state = "oldshieldoff"
			update_icon()
			emitting = FALSE
			update_sound()
			emittingmount = 0
			return

	/obj/structure/fusioncell/screwdriver_act(mob/living/user, obj/item/I)
		if(emitting == TRUE)
			update_sound()
			I.play_tool_sound(src, 50)
			visible_message("<span class='warning'>[user] starts to release <b>[radiation_count]</b> rads!!!.</span>",null,null,5)
			do_after(user,100, target = src, progress = 1)
			radiation_pulse(src,radiation_count,5,TRUE,TRUE)
			radiation_count = 0
			return
		if(emitting == FALSE)
			to_chat(user, "You cannot release the radiation while the cell is off")
			return

	/obj/structure/fusioncell/rad_act(pulse_strength)
		if(emitting == TRUE)
			return
		if(emitting == FALSE)
			radiation_count += pulse_strength/50
			return

	/obj/structure/fusioncell/examine(mob/user)
		if(emitting == TRUE)
			to_chat(user, "<span class='notice'>[src]'s display states that it has stored <b>[radiation_count]</b> rads, and is emitting <b>[emittingmount]</b>.</span>")
			return
		if(emitting == FALSE)
			to_chat(user, "<span class='notice'>[src]'s display states that it has stored <b>[radiation_count]</b> rads, and is not emitting.</span>")
			return

	/obj/structure/fusioncell/update_icon()
		return



