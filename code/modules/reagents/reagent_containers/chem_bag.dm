/obj/item/reagent_containers/chem_bag
	name = "chemical bag"
	desc = "Contains chemicals used for transfusion. Must be attached to an IV drip."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "bloodpack"
	volume = 200
	fill_icon_thresholds = list(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
	reagent_flags = TRANSPARENT | ABSOLUTELY_GRINDABLE

/obj/item/reagent_containers/chem_bag/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = "bloodpack"
		update_icon()

/obj/item/reagent_containers/chem_bag/examine(mob/user)
	. = ..()
	if(reagents)
		if(volume == reagents.total_volume)
			. += "<span class='notice'>It is fully filled.</span>"
		else if(!reagents.total_volume)
			. += "<span class='notice'>It's empty.</span>"
		else
			. += "<span class='notice'>It seems [round(reagents.total_volume/volume*100)]% filled.</span>"

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
