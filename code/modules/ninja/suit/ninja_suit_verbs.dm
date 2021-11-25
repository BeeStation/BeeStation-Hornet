//Wakes the user so they are able to do their thing.
//Movement impairing would indicate drugs and the like.
/obj/item/clothing/suit/space/space_ninja/proc/ninja_boost()
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

//Disables nearby tech equipment.
/obj/item/clothing/suit/space/space_ninja/proc/ninja_pulse()
		cancel_stealth()
		playsound(suit_user.loc, 'sound/effects/empulse.ogg', 60, 2)
		empulse(suit_user, 4, 6) //Procs sure are nice. Slightly weaker than wizard's disable tch.

//Allows the ninja to kidnap people
/obj/item/clothing/suit/space/space_ninja/proc/ninja_net()
	var/mob/living/carbon/C = input("Select who to capture:","Capture who?",null) as null|mob in sortNames(oview(suit_user))

	if(QDELETED(C)||!(C in oview(suit_user)))
		cell.charge += 600
		return FALSE

	if(!C.mind)//Monkeys without a client can still step_to() and bypass the net. Also, netting inactive people is lame.
		to_chat(suit_user, "<span class='warning'>[C.p_they(TRUE)] will bring no honor to your Clan!</span>")
		cell.charge += 600
		return

	if(locate(/obj/structure/energy_net) in get_turf(C))//Check if they are already being affected by an energy net.
		to_chat(suit_user, "<span class='warning'>[C.p_they(TRUE)] are already trapped inside an energy net!</span>")
		cell.charge += 600
		return

	for(var/turf/T in getline(get_turf(suit_user), get_turf(C)))
		if(T.density)//Don't want them shooting nets through walls. It's kind of cheesy.
			to_chat(suit_user, "<span class='warning'>You may not use an energy net through solid obstacles!</span>")
			cell.charge += 600
			return

	cancel_stealth()
	suit_user.Beam(C,"n_beam",time=15)
	suit_user.say("Get over here!", forced = "ninja net")
	var/obj/structure/energy_net/E = new /obj/structure/energy_net(C.drop_location())
	E.affecting = C
	E.master = suit_user
	suit_user.visible_message("<span class='danger'>[suit_user] caught [C] with an energy net!</span>","<span class='notice'>You caught [C] with an energy net!</span>")

	if(C.buckled)
		C.buckled.unbuckle_mob(suit_user,TRUE)
	E.buckle_mob(C, TRUE) //No moving for you!
		//The person can still try and attack the net when inside.

	START_PROCESSING(SSobj, E)

//Smoke bomb
/obj/item/clothing/suit/space/space_ninja/proc/ninja_smoke()
	var/datum/effect_system/smoke_spread/bad/smoke = new
	smoke.set_up(4, suit_user.loc)
	smoke.start()
	playsound(suit_user.loc, 'sound/effects/bamf.ogg', 50, 2)

//Creates a throwing star
/obj/item/clothing/suit/space/space_ninja/proc/ninja_star()
	var/obj/item/throwing_star/ninja/N = new(suit_user)
	if(suit_user.put_in_hands(N))
		to_chat(suit_user, "<span class='notice'>A throwing star has been created in your hand!</span>")
		suit_user.throw_mode_on() //So they can quickly throw it.
	else
		to_chat(suit_user, "<span class='notice'>A throwing star has been created under your feet!</span>")

/obj/item/clothing/suit/space/space_ninja/proc/ninja_sword_recall()
	if(!energyKatana)
		to_chat(suit_user, "<span class='warning'>Could not locate Energy Katana!</span>")
		return

	if(get_dist(suit_user, energyKatana) <= 1)
		return

	if(iscarbon(energyKatana.loc))
		var/mob/living/carbon/C = energyKatana.loc
		C.transferItemToLoc(energyKatana, get_turf(energyKatana), TRUE)

	else
		energyKatana.forceMove(get_turf(energyKatana))

	energyKatana.return_to_owner(suit_user, 1)

//Stealth verbs

/obj/item/clothing/suit/space/space_ninja/proc/toggle_stealth()
	if(!suit_user)
		return
	if(stealth)
		cancel_stealth()
	else
		stealth()


/obj/item/clothing/suit/space/space_ninja/proc/cancel_stealth()
	if(!stealth)
		return FALSE

	stealth = FALSE
	animate(suit_user, alpha = 255, time = 15)
	suit_user.visible_message("<span class='warning'>[suit_user.name] appears from thin air!</span>", \
							"<span class='notice'>You are now visible.</span>")
	STOP_PROCESSING(SSprocessing, src)
	return TRUE


/obj/item/clothing/suit/space/space_ninja/proc/stealth()
	if(s_busy)
		return FALSE

	if(cell.charge <= 0)
		to_chat(suit_user, "<span class='warning'>You don't have enough power to enable Stealth!</span>")
		return FALSE

	stealth = TRUE
	animate(suit_user, alpha = 50,time = 15)
	suit_user.visible_message("<span class='warning'>[suit_user.name] vanishes into thin air!</span>", \
						"<span class='notice'>You are now mostly invisible to normal detection.</span>")
	START_PROCESSING(SSprocessing, src)
	return TRUE
