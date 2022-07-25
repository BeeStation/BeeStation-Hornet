#define COLA_AMT = 5

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
	desc = "Cola. Probably not from space. Proceed with caution. A no-tamper filter prevents the drink from being drained and resold."
	icon_state = "inf"
	list_reagents = list(/datum/reagent/consumable/space_cola = COLA_AMT)
	prevent_grinding = TRUE
	reagent_flags = AMOUNT_VISIBLE | REFILLABLE  // disables dumping chems into container, you can still fill with dangerous chems for a cool trick

/obj/item/reagent_containers/food/drinks/soda_cans/inf/Initialize(mapload)
	var/reagents = volume - COLA_AMT
	while(reagents)
		var/newreagent = rand(1, min(reagents, 30))
		var/category = prob(10) ? CHEMICAL_RNG_FUN : CHEMICAL_RNG_GENERAL

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
		. += "<span class='notice'>You feel an urge to finish off the drink.</span>"


/datum/round_event/infcola/start()
	for(var/i in 1 to rand(5, 20))  // generates between 5-20 cans
		var/obj/item/reagent_containers/food/drinks/soda_cans/inf/newCan = new(src)
		var/turf/warp = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)
		newCan.forceMove(warp)
		do_smoke(location=warp)

#undef COLA_AMT
