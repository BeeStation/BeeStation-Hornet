/obj/item/implant/mindshield
	name = "mindshield implant"
	desc = "Protects against brainwashing."
	activated = 0

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
			target.mind.remove_antag_datum(/datum/antagonist/brainwashed)

		if(target.mind.has_antag_datum(/datum/antagonist/rev/head) || target.mind.unconvertable)
			if(!silent)
				target.visible_message("<span class='warning'>[target] seems to resist the implant!</span>", "<span class='warning'>You feel something interfering with your mental conditioning, but you resist it!</span>")
			removed(target, 1)
			qdel(src)
			return FALSE

		var/datum/antagonist/hivemind/hiv= target.mind.has_antag_datum(/datum/antagonist/hivemind)
		if(hiv)
			var/timer = round(rand(1800,3000))
			addtimer(CALLBACK(hiv, TYPE_PROC_REF(/datum/antagonist/hivemind, handle_implant)), timer, TIMER_STOPPABLE)
			hiv.handle_implant()

		if(is_hivemember(target))
			for(var/datum/antagonist/hivemind/hive in GLOB.antagonists)
				if(hive.hivemembers.Find(target.mind))
					var/mob/living/carbon/C = hive.owner.current
					if(C?.mind)
						to_chat(C, "<span class='assimilator'>We detect a surge of psionic energy from a far away vessel before they disappear from the hive. Whatever happened, there's a good chance they're after us now.</span>")
			if(IS_WOKEVESSEL(target))
				target.mind.remove_antag_datum(/datum/antagonist/hivevessel)
				target.visible_message("<span class='deconversion_message'>[target]'s thoughts seem to clear!</span>", null, null, null, target)
				ADD_TRAIT(target, TRAIT_HIVE_BURNT, HIVEMIND_TRAIT)
			to_chat(target, "<span class='assimilator'>You hear supernatural wailing echo throughout your mind as you are finally set free. Deep down, you can feel the lingering presence of those who enslaved you... as can they!</span>")
			remove_hivemember(target)

		var/datum/antagonist/rev/rev = target.mind.has_antag_datum(/datum/antagonist/rev)
		if(rev)
			rev.remove_revolutionary(FALSE, user)
		if(!silent)
			if(target.mind in SSticker.mode.cult)
				to_chat(target, "<span class='warning'>You feel something interfering with your mental conditioning, but you resist it!</span>")
			else
				to_chat(target, "<span class='notice'>You feel a sense of peace and security. You are now protected from brainwashing.</span>")
		ADD_TRAIT(target, TRAIT_MINDSHIELD, "implant")
		target.sec_hud_set_implants()
		return TRUE
	return FALSE

/obj/item/implant/mindshield/removed(mob/target, silent = FALSE, special = 0)
	if(..())
		if(isliving(target))
			var/mob/living/L = target
			REMOVE_TRAIT(L, TRAIT_MINDSHIELD, "implant")
			L.sec_hud_set_implants()
		if(target.stat != DEAD && !silent)
			to_chat(target, "<span class='boldnotice'>Your mind suddenly feels terribly vulnerable. You are no longer safe from brainwashing.</span>")
		return 1
	return 0

/obj/item/implanter/mindshield
	name = "implanter (mindshield)"
	imp_type = /obj/item/implant/mindshield

/obj/item/implantcase/mindshield
	name = "implant case - 'Mindshield'"
	desc = "A glass case containing a mindshield implant."
	imp_type = /obj/item/implant/mindshield
