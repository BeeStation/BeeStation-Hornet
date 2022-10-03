#define COLA_AMT 5

/datum/round_event_control/infcola
	name = "Cola Infinite"
	typepath = /datum/round_event/infcola
	min_players = 1
	max_occurrences = 10
	can_malf_fake_alert = TRUE

/datum/round_event/infcola
	announceWhen = 2

/datum/round_event/infcola/announce(fake)
	priority_announce("Due to some failed bluespace experiments, corrupted bottles of Space Cola may appear across your station. Please refrain from drinking out of these bottles, as there is no current information on the contents. We are not responsible for any damages.", "General Alert", SSstation.announcer.get_rand_alert_sound())

/datum/round_event/infcola/start()
	for(var/i in 1 to rand(5, 20))  // generates between 5-20 cans
		var/obj/item/reagent_containers/food/drinks/soda_cans/inf/newCan = new(src)
		var/turf/warp = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)
		newCan.forceMove(warp)
		do_smoke(location=warp)

/obj/item/reagent_containers/food/drinks/soda_cans/inf
	name = "Space Cola INFINITE"
	desc = "Cola. Probably not from space. Proceed with caution. A tamper-proof container prevents the drink from being drained and resold."
	icon_state = "inf"
	list_reagents = list(/datum/reagent/consumable/space_cola = COLA_AMT)
	prevent_grinding = TRUE
	reagent_flags = AMOUNT_VISIBLE | REFILLABLE  // disables dumping chems into container, you can still fill with dangerous chems for a cool trick

/obj/item/reagent_containers/food/drinks/soda_cans/inf/Initialize(mapload)
	var/reagents_left = volume - COLA_AMT
	while(reagents_left)
		var/newreagent = rand(1, min(reagents_left, 30))
		var/category = prob(10) ? CHEMICAL_RNG_FUN : CHEMICAL_RNG_GENERAL

		list_reagents += list(get_random_reagent_id(category) = newreagent)
		reagents_left -= newreagent
	. = ..()

/obj/item/reagent_containers/food/drinks/soda_cans/inf/open_soda(mob/user)  // different pop message copy-pasted
	to_chat(user, "As you pull off the tab, an indescribable smell fills the air.") //warning
	ENABLE_BITFIELD(reagents.flags, OPENCONTAINER)
	playsound(src, "can_open", 50, 1)
	spillable = TRUE

/obj/item/reagent_containers/food/drinks/soda_cans/inf/examine()
	. = ..()
	if(length(reagents?.reagent_list))
		. += "<span class='notice'>You feel an urge to finish the drink.</span>"

#undef COLA_AMT
