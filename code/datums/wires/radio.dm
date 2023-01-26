/datum/wires/radio
	holder_type = /obj/item/radio
	proper_name = "Radio"

/datum/wires/radio/New(atom/holder)
	wires = list(
		WIRE_SIGNAL,
		WIRE_RX, WIRE_TX
	)
	..()

/datum/wires/radio/interactable(mob/user)
	var/obj/item/radio/R = holder
	return R.unscrewed

/datum/wires/radio/on_pulse(index)
	var/obj/item/radio/R = holder
	switch(index)
		if(WIRE_SIGNAL)
			R.listening = !R.listening
			R.broadcasting = R.listening
			R.current_holder.refresh_known_radio_channels()
		if(WIRE_RX)
			R.listening = !R.listening
			R.current_holder.refresh_known_radio_channels()
		if(WIRE_TX)
			R.broadcasting = !R.broadcasting
