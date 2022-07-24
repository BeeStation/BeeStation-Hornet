/datum/round_event_control/infcola
	name = "Cola Infinite"
	typepath = /datum/round_event/infcola
	min_players = 1
	max_occurrences = 10
	var/atom/special_target
	can_malf_fake_alert = TRUE

/datum/round_event/infcola
	announceWhen = 2

/datum/round_event/infcola/announce(fake)
	priority_announce("Our long-range anomaly scanners have detected leakage from a soda filled dimension. Nanotrasen is [fake ? "very" : "not"] responsible for any damages caused by these anomalous canisters.", "General Alert", SSstation.announcer.get_rand_alert_sound())

/obj/item/reagent_containers/food/drinks/soda_cans/inf
	name = "Space Cola INFINITE"
	desc = "Cola. Probably not from space. Proceed with caution."
	icon_state = "inf"
	list_reagents = list()

/obj/item/reagent_containers/food/drinks/soda_cans/inf/Initialize(mapload)
	var/reagents = volume
	while(reagents)
		var/newreagent = rand(1, min(reagents, 30))
		var/category = CHEMICAL_RNG_GENERAL
		if(prob(10))
			category = CHEMICAL_RNG_FUN

		list_reagents += list(get_random_reagent_id(category) = newreagent)
		reagents -= newreagent
	. = ..()

/obj/item/reagent_containers/food/drinks/soda_cans/inf/open_soda(mob/user)  // different pop message copy-pasted
	to_chat(user, "As you pull the tab off \the [src], an indescribable smell fills the air.") //warning
	ENABLE_BITFIELD(reagents.flags, OPENCONTAINER)
	playsound(src, "can_open", 50, 1)
	spillable = TRUE

/obj/item/reagent_containers/food/drinks/soda_cans/inf/examine()
	. = ..()
	if(reagents && reagents.reagent_list.len)
		. += "<span class='notice'>The can seems filled with something, but you can't tell what.</span>"
	else
		. += "<span class='notice'>The can seems empty.</span>"


/datum/round_event/infcola/start()
	for(var/i in 1 to rand(5, 20))  // generates between 5-20 cans
		var/obj/item/reagent_containers/food/drinks/soda_cans/inf/newCan = new(src)
		var/turf/warp = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)
		newCan.forceMove(warp)
		do_smoke(location=warp)
