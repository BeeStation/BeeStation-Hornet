/obj/effect/proc_holder/spell/pointed/manse_link
	name = "Mansus Link"
	desc = "Piercing through reality, connecting minds. This spell allows you to add people to a Mansus Net, allowing them to communicate with each other from afar."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_link"
	action_background_icon_state = "bg_ecult"
	invocation = "PI'RC' TH' M'ND"
	invocation_type = INVOCATION_WHISPER
	requires_heretic_focus = TRUE
	charge_max = 300
	clothes_req = FALSE
	range = 10

/obj/effect/proc_holder/spell/pointed/manse_link/can_target(atom/target, mob/user, silent)
	if(!isliving(target))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/manse_link/cast(list/targets, mob/user)
	var/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/originator = user

	var/mob/living/target = targets[1]

	to_chat(originator, "<span class='notice'>You begin linking [target]'s mind to yours...</span>")
	to_chat(target, "<span class='warning'>You feel your mind being pulled... connected... intertwined with the very fabric of reality...</span>")
	if(!do_after(originator, 6 SECONDS, target = target))
		return
	if(!originator.link_mob(target))
		to_chat(originator, "<span class='warning'>You can't seem to link [target]'s mind...</span>")
		to_chat(target, "<span class='warning'>The foreign presence leaves your mind.</span>")
		return
	to_chat(originator, "<span class='notice'>You connect [target]'s mind to your mansus link!</span>")


/datum/action/innate/mansus_speech
	name = "Mansus Link"
	desc = "Send a psychic message to everyone connected to your Mansus Net."
	button_icon_state = "link_speech"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_ecult"
	/// The raw prophet that hosts our link.
	var/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/originator

/datum/action/innate/mansus_speech/New(originator)
	. = ..()
	src.originator = originator

/datum/action/innate/mansus_speech/Activate()
	var/mob/living/living_owner = owner
	if(!originator?.linked_mobs[living_owner])
		CRASH("Uh oh, a Mansus Link ([type]) got somehow called Activate() [isnull(originator) ? "without an originator Raw Prophet" : "without being in the originator's linked_mobs list"].")

	var/message = sanitize(input(living_owner, "Enter your message", "Telepathy from the Mansus"))
	if(!message)
		return

	if(QDELETED(living_owner))
		return

	if(!originator?.linked_mobs[living_owner])
		to_chat(living_owner, "<span class='warning'>The link seems to have been severed...</span>")
		Remove(living_owner)
		return

	var/msg = "<i><font color=#568b00>\[Mansus Link\] <b>[living_owner]:</b> [message]</font></i>"
	log_directed_talk(living_owner, originator, msg, LOG_SAY, "Mansus Link")
	to_chat(originator.linked_mobs, msg)

	for(var/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, living_owner)
		to_chat(dead_mob, "[link] [msg]")
