/obj/effect/anomaly/trap
	name = "beartrap anomaly"
	icon_state = "trap"
	anomaly_core = /obj/item/assembly/signaler/anomaly/trap

	COOLDOWN_DECLARE(pulse_cooldown)
	var/pulse_interval = 20 SECONDS
