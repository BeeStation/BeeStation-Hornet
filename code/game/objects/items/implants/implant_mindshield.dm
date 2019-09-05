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

		var/datum/antagonist/hivemind/host = target.mind.has_antag_datum(/datum/antagonist/hivemind) //Releases the target from mind control beforehand
		if(host)
			var/datum/mind/M = host.owner
			if(M)
				var/obj/effect/proc_holder/spell/target_hive/hive_control/the_spell = locate(/obj/effect/proc_holder/spell/target_hive/hive_control) in M.spell_list
				if(the_spell?.active)
					the_spell.release_control()

		if(target.mind.has_antag_datum(/datum/antagonist/rev/head) || target.mind.has_antag_datum(/datum/antagonist/hivemind) || target.mind.unconvertable)
			if(!silent)
				target.visible_message("<span class='warning'>[target] seems to resist the implant!</span>", "<span class='warning'>You feel something interfering with your mental conditioning, but you resist it!</span>")
			removed(target, 1)
			qdel(src)
			return FALSE

		var/datum/antagonist/hivevessel/woke = target.is_wokevessel()
		if(is_hivemember(target))
			for(var/datum/antagonist/hivemind/hive in GLOB.antagonists)
				if(hive.hivemembers.Find(target.mind))
					var/mob/living/carbon/C = hive.owner.current.get_real_hivehost()
					if(C)
						C.apply_status_effect(STATUS_EFFECT_HIVE_TRACKER, target, woke?TRACKER_AWAKENED_TIME:TRACKER_MINDSHIELD_TIME)
						target.apply_status_effect(STATUS_EFFECT_HIVE_TRACKER, C, TRACKER_DEFAULT_TIME)
						if(C.mind) //If you were using mind control, too bad
							C.apply_status_effect(STATUS_EFFECT_HIVE_RADAR)
							to_chat(C, "<span class='assimilator'>We detect a surge of psionic energy from a far away vessel before they disappear from the hive. Whatever happened, there's a good chance they're after us now.</span>")
			to_chat(target, "<span class='assimilator'>You hear supernatural wailing echo throughout your mind as you are finally set free. Deep down, you can feel the lingering presence of those who enslaved you... as can they!</span>")
			target.apply_status_effect(STATUS_EFFECT_HIVE_RADAR)
			remove_hivemember(target)

		if(woke)
			woke.one_mind?.remove_member(target.mind)
			target.mind.remove_antag_datum(/datum/antagonist/hivevessel)

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
