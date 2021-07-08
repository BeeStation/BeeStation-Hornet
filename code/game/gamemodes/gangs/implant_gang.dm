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
				<b>Notice:</b> Latest NT Mindshield implants counteract the effect of this implant.<BR>
				<b>Integrity:</b> Latest NT Mindshield will neutralize this implant."}
	return dat

/obj/item/implant/gang/implant(mob/living/target, mob/user, silent = 0)
	if(!target || !target.mind  || target.stat == DEAD || !ishuman(target) || !..())
		return FALSE
	if (HAS_TRAIT(target, TRAIT_MINDSHIELD))
		target.visible_message("<span class='warning'>[target] seems to resist the implant!</span>", "<span class='warning'>You resist the gang implant. You are reminded of the anti-gang PSA instead.</span>")
		return FALSE

	var/datum/antagonist/gang/G = target.mind.has_antag_datum(/datum/antagonist/gang)
	if(G)
		if(G.gang == G || istype(G, /datum/antagonist/gang/boss))
			return FALSE
		target.mind.remove_antag_datum(/datum/antagonist/gang)
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
		return TRUE
	return FALSE
