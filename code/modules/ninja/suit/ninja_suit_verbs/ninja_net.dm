
//Allows the ninja to kidnap people
/obj/item/clothing/suit/space/space_ninja/proc/ninjanet()
	var/mob/living/carbon/C = input("Select who to capture:","Capture who?",null) as null|mob in sortNames(oview(suit_user))

	if(QDELETED(C)||!(C in oview(suit_user)))
		return FALSE

	if(!C.mind)//Monkeys without a client can still step_to() and bypass the net. Also, netting inactive people is lame.
		to_chat(suit_user, "<span class='warning'>[C.p_they(TRUE)] will bring no honor to your Clan!</span>")
		return
	if(locate(/obj/structure/energy_net) in get_turf(C))//Check if they are already being affected by an energy net.
		to_chat(suit_user, "<span class='warning'>[C.p_they(TRUE)] are already trapped inside an energy net!</span>")
		return
	for(var/turf/T in getline(get_turf(suit_user), get_turf(C)))
		if(T.density)//Don't want them shooting nets through walls. It's kind of cheesy.
			to_chat(suit_user, "<span class='warning'>You may not use an energy net through solid obstacles!</span>")
			return
	if(!ninjacost(200,N_STEALTH_CANCEL))
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
