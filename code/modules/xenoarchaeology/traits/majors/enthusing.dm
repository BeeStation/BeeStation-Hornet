/*
	Enthusing
	Makes the target emote, if they can
*/
/datum/xenoartifact_trait/major/emote
	label_name = "Enthusing"
	label_desc = "Enthusing: The artifact seems to contain emoting components. Triggering these components will cause the target to emote."
	cooldown = XENOA_TRAIT_COOLDOWN_EXTRA_SAFE
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	///List of possible emotes
	var/list/possible_emotes = list(/datum/emote/flip, /datum/emote/spin, /datum/emote/living/laugh,
	/datum/emote/living/shiver, /datum/emote/living/tremble, /datum/emote/living/whimper,
	/datum/emote/living/smile, /datum/emote/living/pout, /datum/emote/living/gag,
	/datum/emote/living/deathgasp, /datum/emote/living/dance, /datum/emote/living/blush)
	///Emote to preform
	var/datum/emote/emote

/datum/xenoartifact_trait/major/emote/New(atom/_parent)
	. = ..()
	emote = pick(possible_emotes)
	emote = new emote()

/datum/xenoartifact_trait/major/emote/Destroy(force, ...)
	QDEL_NULL(emote)
	return ..()

/datum/xenoartifact_trait/major/emote/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/carbon/target in focus)
		INVOKE_ASYNC(src, PROC_REF(run_emote), target)
	dump_targets()
	clear_focus()

/datum/xenoartifact_trait/major/emote/proc/run_emote(mob/living/carbon/target)
	emote.run_emote(target)

/datum/xenoartifact_trait/major/emote/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_RANDOMISED)
