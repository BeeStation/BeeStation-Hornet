/*
	'Tracker' for artifacts, can be attached to generate points
	from successful artifact activations.
	Currently just a prototype
	//TODO: Consider setting up certain trait incompatabilities - Racc : PLAYTEST
*/
/obj/item/sticker/artifact_tracker
	name = "anomalous material tracker"
	icon = 'icons/obj/xenoarchaeology/xenoartifact_tech.dmi'
	icon_state = "tracker"
	sticker_icon_state = "tracker_small"
	do_outline = FALSE
	///Reward stuff
	var/list/rewards = list(TECHWEB_POINT_TYPE_DISCOVERY = 100, TECHWEB_POINT_TYPE_GENERIC = 300)
	///radio used to send messages on science channel
	var/obj/item/radio/headset/radio
	var/use_radio = TRUE
	///Which science server receives points
	var/datum/techweb/linked_techweb

/obj/item/sticker/artifact_tracker/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ARTIFACT_IGNORE, GENERIC_ITEM_TRAIT)
	//Radio setup
	radio = new /obj/item/radio/headset/headset_sci(src)
	//Link relevant stuff
	linked_techweb = SSresearch.science_tech

/obj/item/sticker/artifact_tracker/Destroy()
	. = ..()
	QDEL_NULL(radio)

/obj/item/sticker/artifact_tracker/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-Click to disable the radio & reward notice.</span>"

/obj/item/sticker/artifact_tracker/afterattack(atom/movable/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!can_stick(target) || !proximity_flag)
		return
	var/sound_in = 'sound/machines/buzz-sigh.ogg'
	var/datum/component/xenoartifact/X = target.GetComponent(/datum/component/xenoartifact)
	if(X)
		if(X.calibrated)
			sound_in = 'sound/machines/click.ogg'
			RegisterSignal(X, XENOA_TRIGGER, PROC_REF(catch_activation))
		else
			say("Error: [target] needs to be calibrated.")
	else
		say("Error: [target] is not compatible with [src].")
	playsound(src, sound_in, 50, TRUE)

/obj/item/sticker/artifact_tracker/AltClick(mob/user)
	. = ..()
	use_radio = !use_radio
	to_chat(user, "<span class='[use_radio ? "notice" : "warning"]'>Internal radio [use_radio ? "enabled" : "disabled"].</span>")

/obj/item/sticker/artifact_tracker/proc/catch_activation(datum/source, priority)
	SIGNAL_HANDLER

	if(priority != TRAIT_PRIORITY_ACTIVATOR)
		return
	for(var/reward in rewards)
		//Reward
		var/reward_amount = rewards[reward]
		linked_techweb?.add_point_type(reward, reward_amount)
		//Message
		if(!use_radio)
			return
		var/datum/component/xenoartifact/X = source
		var/message = "[X.parent] has generated [reward_amount] points of [reward] at [get_area(get_turf(src))]."
		say(message)
		radio?.talk_into(src, message, RADIO_CHANNEL_SCIENCE)
