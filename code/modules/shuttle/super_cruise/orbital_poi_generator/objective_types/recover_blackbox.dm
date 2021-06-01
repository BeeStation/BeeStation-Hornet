/datum/orbital_objective/recover_blackbox
	name = "Blackbox Recovery"
	var/generated = FALSE
	//The blackbox required to recover.
	var/obj/item/blackbox/objective/linked_blackbox
	//Relatively easy mission.
	min_payout = 10000
	max_payout = 40000

/datum/orbital_objective/recover_blackbox/generate_objective_stuff(turf/chosen_turf)
	generated = TRUE
	linked_blackbox = new(chosen_turf)
	linked_blackbox.linked_obj = src

/datum/orbital_objective/recover_blackbox/get_text()
	return "Outpost [new_station_name()] recently went dark and is no longer responding to our attempts \
		to contact them. Send in a team and recover the station's blackbox for a payout of [payout] credits. \
		The station is located at the beacon marked [linked_beacon.name]. Good luck."

/datum/orbital_objective/recover_blackbox/check_failed()
	if(!QDELETED(linked_blackbox) || !generated)
		return FALSE
	return TRUE

/*
 * Blackbox Item: Objective target, handles completion
 * Traitors can steal the Nanotrasen blackbox to prevent the station
 * from completing their objective and recover invaluable data.
 */
/obj/item/blackbox/objective
	name = "damaged blackbox"
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/recovered = FALSE
	var/datum/orbital_objective/recover_blackbox/linked_obj

/obj/item/blackbox/objective/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/gps, "BLACKBOX #[rand(1000, 9999)]", TRUE)

/obj/item/blackbox/objective/examine(mob/user)
	. = ..()
	if(recovered)
		. += "<span class='notice'>It is in the process of being recovered by Central Command!</span>"
	else
		. += "<span class='notice'>Use in hand on the <b>bridge</b> of the station to send it to Nanotrasen and complete the objective.</span>"

/obj/item/blackbox/objective/attack_self(mob/user)
	. = ..()
	var/turf/T = get_turf(src)
	var/area/A = T.loc
	if(istype(A, /area/bridge) && is_station_level(T.z))
		initiate_recovery()
	else
		say("Blackbox must be recovered at the station's bridge.")

/obj/item/blackbox/objective/proc/initiate_recovery()
	if(recovered)
		return
	recovered = TRUE
	//Prevent picking up
	anchored = TRUE
	//Drop to ground
	forceMove(get_turf(src))
	//Complete objective
	if(linked_obj)
		linked_obj.complete_objective()
	else
		say("Non-priority beacon recovered, dispensing 2000 credit reward.")
		new /obj/item/stack/spacecash/c1000(get_turf(src), 2)
	//Fly away
	var/mutable_appearance/balloon
	var/mutable_appearance/balloon2
	var/obj/effect/extraction_holder/holder_obj = new(loc)
	holder_obj.appearance = appearance
	forceMove(holder_obj)
	balloon2 = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_expand")
	balloon2.pixel_y = 10
	balloon2.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	holder_obj.add_overlay(balloon2)
	sleep(4)
	balloon = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_balloon")
	balloon.pixel_y = 10
	balloon.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	holder_obj.cut_overlay(balloon2)
	holder_obj.add_overlay(balloon)
	playsound(holder_obj.loc, 'sound/items/fultext_deploy.ogg', 50, 1, -3)
	animate(holder_obj, pixel_z = 10, time = 20)
	sleep(20)
	animate(holder_obj, pixel_z = 15, time = 10)
	sleep(10)
	animate(holder_obj, pixel_z = 10, time = 10)
	sleep(10)
	animate(holder_obj, pixel_z = 15, time = 10)
	sleep(10)
	animate(holder_obj, pixel_z = 10, time = 10)
	sleep(10)
	playsound(holder_obj.loc, 'sound/items/fultext_launch.ogg', 50, 1, -3)
	animate(holder_obj, pixel_z = 1000, time = 30)
	sleep(30)
	qdel(src)
	qdel(holder_obj)
