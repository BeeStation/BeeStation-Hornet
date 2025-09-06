/datum/action/spell/pointed/manse_link
	name = "Manse Link"
	desc = "This spell allows you to pierce through reality and connect minds to one another \
		via your Mansus Link. All minds connected to your Mansus Link will be able to communicate discreetly across great distances."
	background_icon_state = "bg_heretic"
	button_icon = 'icons/hud/actions/actions_ecult.dmi'
	button_icon_state = "mansus_link"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS

	invocation = "PI'RC' TH' M'ND."
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

	cast_range = 7

	/// The time it takes to link to a mob.
	var/link_time = 6 SECONDS

/datum/action/spell/pointed/manse_link/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		stack_trace("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")
		qdel(src)

/datum/action/spell/pointed/manse_link/is_valid_spell(mob/user, atom/target)
	. = ..()
	if(!.)
		return FALSE
	return isliving(target)

/datum/action/spell/pointed/manse_link/pre_cast(mob/living/cast_on, atom/target)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	// If we fail to link, cancel the spell.
	if(!do_linking(cast_on))
		return . | SPELL_CANCEL_CAST

/**
* The actual process of linking [linkee] to our network.
*/
/datum/action/spell/pointed/manse_link/proc/do_linking(mob/living/linkee)
	var/datum/component/mind_linker/linker = master
	if(linkee.stat == DEAD)
		to_chat(owner, ("<span class='warning'>They're dead!</span>"))
		return FALSE
	to_chat(owner, ("<span class='notice'>You begin linking [linkee]'s mind to yours...</span>"))
	to_chat(linkee, ("<span class='warning'>You feel your mind being pulled somewhere... connected... intertwined with the very fabric of reality...</span>"))
	if(!do_after(owner, link_time, linkee))
		to_chat(owner, ("<span class='warning'>You fail to link to [linkee]'s mind.</span>"))
		to_chat(linkee, ("<span class='warning'>The foreign presence leaves your mind.</span>"))
		return FALSE
	if(QDELETED(src) || QDELETED(owner) || QDELETED(linkee))
		return FALSE
	if(!linker.link_mob(linkee))
		to_chat(owner, ("<span class='warning'>You can't seem to link to [linkee]'s mind.</span>"))
		to_chat(linkee, ("<span class='warning'>The foreign presence leaves your mind.</span>"))
		return FALSE
	return TRUE

/datum/action/innate/mansus_speech
	name = "Mansus Link"
	desc = "Send a psychic message to everyone connected to your Mansus Net."
	button_icon_state = "link_speech"
	button_icon = 'icons/hud/actions/actions_slime.dmi'
	background_icon_state = "bg_heretic"
	/// The raw prophet that hosts our link.
	var/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/originator

/datum/action/innate/mansus_speech/New(originator)
	. = ..()
	src.originator = originator

/datum/action/innate/mansus_speech/on_activate()
	var/mob/living/living_owner = owner
	if(!originator?.linked_mobs[living_owner])
		CRASH("Uh oh, a Mansus Link ([type]) got somehow called Activate() [isnull(originator) ? "without an originator Raw Prophet" : "without being in the originator's linked_mobs list"].")

	var/message = sanitize(tgui_input_text(living_owner, "Enter your message", "Telepathy from the Mansus"))
	if(!message)
		return

	if(QDELETED(living_owner))
		return

	if(!originator?.linked_mobs[living_owner])
		to_chat(living_owner, span_warning("The link seems to have been severed..."))
		Remove(living_owner)
		return

	var/msg = "<i><font color=#568b00>\[Mansus Link\] <b>[living_owner]:</b> [message]</font></i>"
	log_directed_talk(living_owner, originator, msg, LOG_SAY, "Mansus Link")
	to_chat(originator.linked_mobs, msg)

	for(var/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, living_owner)
		to_chat(dead_mob, "[link] [msg]")
