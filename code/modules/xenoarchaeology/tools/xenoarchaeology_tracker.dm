/*
	'Tracker' for artifacts, can be attached to generate points
	from successful artifact activations.
	Currently just a prototype
	//TODO: This should need a correct, maybe calibrated, sticker to work.- Racc
*/
/obj/item/sticker/artifact_tracker
	name = "anomalous material tracker" //TODO: Consider changing the name, since it doesn't GPS track it - Racc
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

/obj/item/sticker/artifact_tracker/afterattack(atom/movable/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!can_stick(target) || !proximity_flag)
		return
	var/datum/component/xenoartifact/X = target.GetComponent(/datum/component/xenoartifact)
	if(X)
		RegisterSignal(X, XENOA_TRIGGER, PROC_REF(catch_activation))

/obj/item/sticker/artifact_tracker/AltClick(mob/user)
	. = ..()
	use_radio = !use_radio
	to_chat(user, "<span class='[use_radio ? "notice" : "warning"]'>Internal radio [use_radio ? "enabled" : "disabled"].</span>")

/obj/item/sticker/artifact_tracker/proc/catch_activation(datum/source, priority)
	SIGNAL_HANDLER

	if(priority == TRAIT_PRIORITY_ACTIVATOR)
		var/message = "[src] has detected some awesome shit, alert!"
		say(message)
		radio?.talk_into(src, message, RADIO_CHANNEL_SCIENCE)
		linked_techweb?.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, 100)
