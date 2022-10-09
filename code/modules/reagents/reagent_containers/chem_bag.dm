/obj/item/reagent_containers/chem_bag
	name = "chemical bag"
	desc = "Contains chemicals used for transfusion. Must be attached to an IV drip."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "bloodpack"
	volume = 200
	fill_icon_thresholds = list(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
	reagent_flags = TRANSPARENT | ABSOLUTELY_GRINDABLE
	var/label_name // this is to support when you don't want to display "chemical bag" part with a custom name

/obj/item/reagent_containers/chem_bag/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = "bloodpack"
		update_icon()
	if(label_name)
		name = "[label_name] chemical bag"

/obj/item/reagent_containers/chem_bag/examine(mob/user)
	. = ..()
	if(reagents)
		if(volume == reagents.total_volume)
			. += "<span class='notice'>It is fully filled.</span>"
		else if(!reagents.total_volume)
			. += "<span class='notice'>It's empty.</span>"
		else
			. += "<span class='notice'>It seems [round(reagents.total_volume/volume*100)]% filled.</span>"

/obj/item/reagent_containers/chem_bag/epinephrine
	label_name = "epinephrine"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 200)

/obj/item/reagent_containers/chem_bag/bicaridine
	label_name = "bicaridine"
	list_reagents = list(/datum/reagent/medicine/bicaridine = 200)

/obj/item/reagent_containers/chem_bag/kelotane
	label_name = "kelotane"
	list_reagents = list(/datum/reagent/medicine/kelotane = 200)

/obj/item/reagent_containers/chem_bag/antitoxin
	label_name = "antitoxin"
	list_reagents = list(/datum/reagent/medicine/antitoxin = 200)

/obj/item/reagent_containers/chem_bag/morphine
	label_name = "morphine"
	list_reagents = list(/datum/reagent/medicine/morphine = 200)

/obj/item/reagent_containers/chem_bag/perfluorodecalin
	label_name = "perfluorodecalin"
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
