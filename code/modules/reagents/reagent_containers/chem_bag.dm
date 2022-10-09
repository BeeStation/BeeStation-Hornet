/obj/item/reagent_containers/chem_bag
	name = "chemical bag"
	desc = "Contains chemicals used for transfusion. Must be attached to an IV drip."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "bloodpack"
	volume = 200
	fill_icon_thresholds = list(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
	reagent_flags = TRANSPARENT

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
		else
			. += "<span class='notice'>It seems [round(reagents.total_volume/volume*100)]% filled.</span>"

/obj/item/reagent_containers/chem_bag/epinephrine
	name = "epinephrine chemical bag"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 200)

/obj/item/reagent_containers/chem_bag/bicaridine
	name = "bicaridine chemical bag"
	list_reagents = list(/datum/reagent/medicine/bicaridine = 200)

/obj/item/reagent_containers/chem_bag/kelotane
	name = "kelotane chemical bag"
	list_reagents = list(/datum/reagent/medicine/kelotane = 200)

/obj/item/reagent_containers/chem_bag/antitoxin
	name = "antitoxin chemical bag"
	list_reagents = list(/datum/reagent/medicine/antitoxin = 200)

/obj/item/reagent_containers/chem_bag/morphine
	name = "morphine chemical bag"
	list_reagents = list(/datum/reagent/medicine/morphine = 200)

/obj/item/reagent_containers/chem_bag/perfluorodecalin
	name = "perfluorodecalin chemical bag"
	list_reagents = list(/datum/reagent/medicine/perfluorodecalin = 200)

// 80u is enough to treat 10 people with the new sleeper rework
/obj/item/reagent_containers/chem_bag/epinephrine/sleeper_roundstart
	list_reagents = list(/datum/reagent/medicine/epinephrine = 80)

/obj/item/reagent_containers/chem_bag/bicaridine/sleeper_roundstart
	list_reagents = list(/datum/reagent/medicine/bicaridine = 80)

/obj/item/reagent_containers/chem_bag/kelotane/sleeper_roundstart
	list_reagents = list(/datum/reagent/medicine/kelotane = 80)

/obj/item/reagent_containers/chem_bag/antitoxin/sleeper_roundstart
	list_reagents = list(/datum/reagent/medicine/antitoxin = 80)

/obj/item/reagent_containers/chem_bag/morphine/sleeper_roundstart
	list_reagents = list(/datum/reagent/medicine/morphine = 80)

/obj/item/reagent_containers/chem_bag/perfluorodecalin/sleeper_roundstart
	list_reagents = list(/datum/reagent/medicine/perfluorodecalin = 80)
