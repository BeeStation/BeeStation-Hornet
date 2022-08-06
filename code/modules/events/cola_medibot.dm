/*
	spawns medibots that sometimes inject cola, and also pays cargo.
	check medbot.dm for more info

	-candycane/etherware
*/

/datum/round_event_control/cola_bot
	name = "Cola-Sponsored Medibots"
	typepath = /datum/round_event/cola_bot
	weight = 20
	min_players = 3
	can_malf_fake_alert = TRUE
	var/atom/special_target

/datum/round_event_control/cola_bot/admin_setup()
	if(!check_rights(R_FUN))
		return

	var/aimed = alert("Spawn at current location?","Targeted Delivery", "Yes", "No")
	if(aimed == "Yes")
		special_target = get_turf(usr)


/datum/round_event/cola_bot
	announceWhen = 0

/datum/round_event/cola_bot/announce(fake)
	priority_announce("After many negotiations, Robust Softdrinks has agreed to sponsor our station, in return for supplying specially modified medical bots. Nanotrasen and Robust softdrinks are not responsible for any injuries or death that may occur as a result.", "General Alert", SSstation.announcer.get_rand_alert_sound())


/datum/round_event/cola_bot/start()
	var/datum/round_event_control/cola_bot/C = control
	var/turf/special_target = C.special_target  // typecast and simplify in the same line wow
	for(var/I in 1 to rand(5, 10))

		var/turf/airdrop = special_target || find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)
		special_target = null  // only spawns on loc the first time

		var/obj/structure/closet/supplypod/bluespacepod/pod = new()
		pod.explosionSize = list(0,0,0,0)
		var/mob/living/simple_animal/bot/medbot/cola/shipment = new()
		shipment.forceMove(pod)

		new /obj/effect/pod_landingzone(airdrop, pod)
