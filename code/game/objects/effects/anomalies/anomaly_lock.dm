/obj/effect/anomaly/lock
	name = "lock anomaly"
	icon_state = "lock"
	anomaly_core = /obj/item/assembly/signaler/anomaly/lock

	COOLDOWN_DECLARE(pulse_cooldown)
	var/pulse_interval = 20 SECONDS
