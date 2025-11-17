//This item doesn't do much on its own, but is required by apps such as AtmoZphere.
/obj/item/computer_hardware/sensorpackage
	name = "sensor package"
	desc = "An integrated sensor package allowing a computer to take readings from the environment. Required by certain programs."
	icon_state = "servo"
	w_class = WEIGHT_CLASS_TINY
	device_type = MC_SENSORS
	expansion_hw = TRUE
	power_usage = 2 // Watts per second
	custom_price = PAYCHECK_MEDIUM
	can_hack = FALSE

/obj/item/computer_hardware/radio_card
	name = "integrated radio card"
	desc = "An integrated signaling assembly for computers to send an outgoing frequency signal. Required by certain programs."
	icon_state = "signal_card"
	w_class = WEIGHT_CLASS_TINY
	device_type = MC_SIGNALLER
	expansion_hw = TRUE
	power_usage = 2 // Watts per second
	custom_price = PAYCHECK_MEDIUM
	can_hack = FALSE

/obj/item/computer_hardware/camera_component
	name = "photographic camera"
	desc = "A camera to be installed into computers for the purposes of taking photos, yet, it is completely useless, such is the way of life."
	icon_state = "camera"
	w_class = WEIGHT_CLASS_TINY
	device_type = MC_CAMERA
	expansion_hw = TRUE
	power_usage = 10 // Watts per second
	custom_price = 30
	can_hack = FALSE
