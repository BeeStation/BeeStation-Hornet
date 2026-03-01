/obj/item/implant/mindshield
	name = "mindshield implant"
	desc = "Protects against brainwashing."
	actions_types = null

/obj/item/implant/mindshield/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nanotrasen Employee Management Implant<BR>
				<b>Life:</b> Ten years.<BR>
				<b>Important Notes:</b> Personnel injected with this device are much more resistant to brainwashing.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small pod of nanobots that protects the host's mental functions from manipulation.<BR>
				<b>Special Features:</b> Will prevent and cure most forms of brainwashing.<BR>
				<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
	return dat


/obj/item/implant/mindshield/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	if(..())
		if(!target.mind)
			ADD_TRAIT(target, TRAIT_MINDSHIELD, "implant")
			target.sec_hud_set_implants()
			return TRUE

		if(target.mind.has_antag_datum(/datum/antagonist/brainwashed))
			unbrainwash(target)

		if ((locate(/obj/item/implant/bloodbrother) in target.implants) && !target.mind.has_antag_datum(/datum/antagonist/brother/prime))
			if(!silent)
				target.visible_message(span_warning("[target] seems to resist the implant!"), span_warning("You feel something interfering with your mental conditioning, but you resist it!"))
			removed(target, 1)
			qdel(src)
			return FALSE

		if(target.mind.has_antag_datum(/datum/antagonist/rev/head) || target.mind.unconvertable)
			if(!silent)
				target.visible_message(span_warning("[target] seems to resist the implant!"), span_warning("You feel something interfering with your mental conditioning, but you resist it!"))
			removed(target, 1)
			qdel(src)
			return FALSE

		var/datum/antagonist/rev/rev = IS_REVOLUTIONARY(target)
		if(rev)
			rev.remove_revolutionary(FALSE, user)
		if(!silent)
			if(target.mind.has_antag_datum(/datum/antagonist/cult))
				to_chat(target, span_warning("You feel something interfering with your mental conditioning, but you resist it!"))
			else
				to_chat(target, span_notice("You feel a sense of peace and security. You are now protected from brainwashing."))

		var/datum/antagonist/vassal/vassal = IS_VASSAL(target)
		if(vassal)
			if(vassal.special_type)
				if(!silent)
					target.visible_message(span_warning("[target] seems to resist the implant!"), span_warning("You feel something interfering with your mental conditioning, but you resist it!"))
				return FALSE
			target.mind.remove_antag_datum(/datum/antagonist/vassal)
		ADD_TRAIT(target, TRAIT_MINDSHIELD, "implant")
		target.sec_hud_set_implants()
		return TRUE
	return FALSE

/obj/item/implant/mindshield/removed(mob/target, silent = FALSE, destroyed = FALSE)
	if(..())
		if(isliving(target))
			var/mob/living/L = target
			REMOVE_TRAIT(L, TRAIT_MINDSHIELD, "implant")
			L.sec_hud_set_implants()
		if(target.stat != DEAD && !silent)
			to_chat(target, span_boldnotice("Your mind suddenly feels terribly vulnerable. You are no longer safe from brainwashing."))
		return 1
	return 0

/obj/item/implanter/mindshield
	name = "implanter (mindshield)"
	imp_type = /obj/item/implant/mindshield

/obj/item/implantcase/mindshield
	name = "implant case - 'Mindshield'"
	desc = "A glass case containing a mindshield implant."
	imp_type = /obj/item/implant/mindshield
