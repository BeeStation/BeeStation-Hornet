/obj/item/reagent_containers/chem_bag
	name = "chemical bag"
	desc = "Contains chemicals used for transfusion. Must be attached to an IV drip."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "bloodpack"
	volume = 200
	fill_icon_thresholds = list(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
	has_variable_transfer_amount = FALSE
	reagent_flags = TRANSPARENT | ABSOLUTELY_GRINDABLE | INJECTABLE | DRAWABLE

/obj/item/reagent_containers/chem_bag/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = "bloodpack"
		update_icon()

/obj/item/reagent_containers/chem_bag/examine(mob/user)
	. = ..()
	if(reagents)
		if(volume == reagents.total_volume)
			. += span_notice("It is fully filled.")
		else if(!reagents.total_volume)
			. += span_notice("It's empty.")
		else
			. += span_notice("It seems [round(reagents.total_volume/volume*100)]% filled.")

// this is specifically made as an example for a sleeper feature that uses a chem bag at roundstart.
/obj/item/reagent_containers/chem_bag/oxy_mix
	name = "Quadra-oxymix Medicines Bag"
	desc = "a small note on it says: Perfluorodecalin 70u, Dexalin 10u, Dexalin Plus 10u, Salbutamol 10u."
	label_name = "Quadra-oxymix Medicines"
	list_reagents = list(
		/datum/reagent/medicine/perfluorodecalin = 70,
		/datum/reagent/medicine/dexalin = 10,
		/datum/reagent/medicine/dexalinp = 10,
		/datum/reagent/medicine/salbutamol = 10
		) // you are welcome to change the chem contents here

/obj/item/reagent_containers/chem_bag/epi
	name = "epinephrine reserve bag"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 200)

/obj/item/reagent_containers/chem_bag/bicaridine
	name = "bicaridine reserve bag"
	list_reagents=  list(/datum/reagent/medicine/bicaridine = 100)

/obj/item/reagent_containers/chem_bag/triamed
	name = "triamed reserve bag"
	list_reagents=  list(/datum/reagent/medicine/bicaridine = 40, /datum/reagent/medicine/kelotane = 40, /datum/reagent/medicine/epinephrine = 20)

/obj/item/reagent_containers/chem_bag/tricordrazine
	name = "tricordrazine reserve bag"
	list_reagents=  list(/datum/reagent/medicine/tricordrazine = 100)

/obj/item/reagent_containers/chem_bag/kelotane
	name = "kelotane reserve bag"
	list_reagents=  list(/datum/reagent/medicine/kelotane = 100)

/obj/item/reagent_containers/chem_bag/antitoxin
	name = "anti-toxin reserve bag"
	list_reagents=  list(/datum/reagent/medicine/antitoxin = 100)

/obj/item/reagent_containers/chem_bag/syndicate
	name = "suspicious reserve bag"
	list_reagents = list(/datum/reagent/medicine/leporazine = 30, /datum/reagent/medicine/syndicate_nanites = 40, /datum/reagent/medicine/stabilizing_nanites = 30)
