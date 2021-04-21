/obj/item/implant/gang
	name = "gang implant"
	desc = "Makes you a gangster or such."
	activated = 0
	var/datum/team/gang/gang

/obj/item/implant/gang/Initialize(loc, setgang)
	..()
	gang = setgang

/obj/item/implant/gang/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Criminal brainwash implant<BR>
				<b>Life:</b> A few seconds after injection.<BR>
				<b>Important Notes:</b> Illegal<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small pod of nanobots that change the host's brain to be loyal to a certain organization.<BR>
				<b>Special Features:</b> This device also contains healing nanites that can revive people already loyal to the organization.<BR>
				<b>Integrity:</b> Implant's EMP function will destroy itself in the process."}
	return dat

/obj/item/implant/gang/implant(mob/living/target, mob/user, silent = 0)
	if(!target || !target.mind || target.stat == DEAD)
		return 0
	if (HAS_TRAIT(target, TRAIT_MINDSHIELD))
		target.visible_message("<span class='warning'>[target] seems to resist the implant!</span>", "<span class='warning'>You resist the gang implant. You are reminded of the anti-gang PSA instead.</span>")
		return FALSE
	var/datum/antagonist/gang/G = target.mind.has_antag_datum(/datum/antagonist/gang)
	if(G && G.gang == G)
		if (target.stat == DEAD)
			target.revive(1,1)					
			return TRUE
		return FALSE // it's pointless
	if(..())
		if(ishuman(target))
			var/success
			if(G)
				if(!istype(G, /datum/antagonist/gang/boss))
					success = TRUE	//Was not a gang boss, convert as usual
					target.mind.remove_antag_datum(/datum/antagonist/gang)
			else
				success = TRUE
			if(!success)
				target.visible_message("<span class='warning'>[target] seems to resist the implant!</span>", "<span class='warning'>You feel the influence of your enemies try to invade your mind!</span>")
				return FALSE
		target.mind.add_antag_datum(/datum/antagonist/gang, gang)
		qdel(src)
		return TRUE

/obj/item/implanter/gang
	name = "implanter (gang)"

/obj/item/implanter/gang/Initialize(loc, gang)
	if(!gang)
		qdel(src)
		return
	imp = new /obj/item/implant/gang(src,gang)
	..() 



/obj/item/implant/mindshield/implant(mob/living/target, mob/user, silent = FALSE) //putting this here, pls no bulli. - qwerty
	if(..())
		if(!target.mind)
			return TRUE
		if(target.mind.has_antag_datum(/datum/antagonist/gang/boss))
			if(!silent)
				target.visible_message("<span class='warning'>[target] seems to resist the implant!</span>", "<span class='warning'>You feel something interfering with your mental conditioning, but you resist it!</span>")
			removed(target, 1)
			qdel(src)
			return FALSE
		target.mind.remove_antag_datum(/datum/antagonist/gang)
		if(!silent)
			to_chat(target, "<span class='notice'>You feel a sense of peace and security. You are now protected from brainwashing.</span>")
		return TRUE
	return FALSE
