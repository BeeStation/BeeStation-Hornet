/mob/living/carbon/human/virtual_reality
	var/datum/mind/real_mind // where is my mind t. pixies
	var/obj/machinery/vr_sleeper/vr_sleeper
	var/datum/action/quit_vr/quit_action

/mob/living/carbon/human/virtual_reality/Initialize()
	. = ..()
	quit_action = new()
	quit_action.Grant(src)
	check_area()

/mob/living/carbon/human/virtual_reality/Moved()
	. = ..()
	check_area()

/mob/living/carbon/human/virtual_reality/death()
	revert_to_reality()
	. = ..()

/mob/living/carbon/human/virtual_reality/Destroy()
	revert_to_reality()
	return ..()

/mob/living/carbon/human/virtual_reality/Life()
	. = ..()
	if(real_mind)
		var/mob/living/real_me = real_mind.current
		if (real_me?.stat == CONSCIOUS)
			return
		revert_to_reality(FALSE)

/mob/living/carbon/human/virtual_reality/ghostize()
	if(!real_mind && !vr_sleeper)
		return ..()
	stack_trace("Ghostize was called on a virtual reality mob")

/mob/living/carbon/human/virtual_reality/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."
	revert_to_reality(FALSE)

/mob/living/carbon/human/virtual_reality/proc/check_area()
	var/area/check = get_area(src)
	if(!check || !istype(check, /area/awaymission/vr))
		return
	var/area/awaymission/vr/A = check
	if(A.death)
		to_chat(src, "<span class='userdanger'>It is unwise to attempt to break Virtual Reality.</span>")
		playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
		dust()
		return
	if(A.pacifist && !HAS_TRAIT_FROM(src, TRAIT_PACIFISM, VR_ZONE_TRAIT))
		ADD_TRAIT(src, TRAIT_PACIFISM, VR_ZONE_TRAIT)
		to_chat(src, "<span class='notice'>You feel like your ability to fight other living beings is being suppressed.</span>")
	else if(!A.pacifist && HAS_TRAIT_FROM(src, TRAIT_PACIFISM, VR_ZONE_TRAIT))
		REMOVE_TRAIT(src, TRAIT_PACIFISM, VR_ZONE_TRAIT)
		to_chat(src, "<span class='notice'>You feel that your ability to fight is no longer being suppressed.</span>")

/mob/living/carbon/human/virtual_reality/proc/revert_to_reality(deathchecks = TRUE)
	if(real_mind && mind)
		real_mind.current.ckey = ckey
		real_mind.current.stop_sound_channel(CHANNEL_HEARTBEAT)
		if(deathchecks && vr_sleeper)
			if(vr_sleeper.you_die_in_the_game_you_die_for_real)
				to_chat(real_mind, "<span class='warning'>You feel everything fading away...</span>")
				real_mind.current.death(0)
	if(deathchecks && vr_sleeper)
		vr_sleeper.vr_human = null
		vr_sleeper = null
	if(!real_mind && !vr_sleeper)
		ghostize()
	real_mind = null

/datum/action/quit_vr
	name = "Quit Virtual Reality"
	icon_icon = 'icons/mob/actions/actions_vr.dmi'
	button_icon_state = "logout"

/datum/action/quit_vr/Trigger()
	if(..())
		if(istype(owner, /mob/living/carbon/human/virtual_reality))
			var/mob/living/carbon/human/virtual_reality/VR = owner
			VR.revert_to_reality(FALSE)
		else
			Remove(owner)
