//This is the proc for gibbing a mob. Cannot gib ghosts.
//added different sort of gibs and animations. N
/mob/proc/gib()
	return

//This is the proc for turning a mob into ash. Mostly a copy of gib code (above).
//Originally created for wizard disintegrate. I've removed the virus code since it's irrelevant here.
//Dusting robots does not eject the MMI, so it's a bit more powerful than gib() /N
/mob/proc/dust(just_ash, drop_items, force)
	return

/mob/proc/death(gibbed)
	SEND_SIGNAL(src, COMSIG_MOB_DEATH, gibbed)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_DEATH, src , gibbed)

///Marks a mob as being unable to return from death
/mob/living/proc/fragment_soul()
	if(!soul_fragmented)
		RegisterSignal(src, COMSIG_MOB_DEATH, TYPE_PROC_REF(/mob/living, soulless_death))
		soul_fragmented = TRUE

/mob/living/proc/soulless_death()
	SIGNAL_HANDLER
	to_chat(src, span_userdanger("Your fragmented soul can never return..."))
	ghostize(FALSE)
	UnregisterSignal(src, COMSIG_MOB_DEATH) //This mob can never die again
