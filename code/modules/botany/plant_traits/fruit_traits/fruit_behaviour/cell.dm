#define CABLE_AMOUNT 5
//% restored every second
#define REGEN_COEF 0.005 //0.5%

/*
	The fruit can be turned into a battery
	These batteries regen charge

*/
/datum/plant_trait/fruit/cell
	name = "Capacitive Cells"
	desc = "The fruit exhibits capacitive properties. A rudimentary battery can be made by combining this fruit with cable segments."
	genetic_cost = 2
	///How far we teleport, at a minimum
	var/teleport_radius = 10
	///Reference to the cell, if we're attached to one
	var/obj/item/stock_parts/cell/cell_parent

/datum/plant_trait/fruit/cell/setup_fruit_parent()
	. = ..()
	cell_parent = fruit_parent
	if(istype(fruit_parent))
		RegisterSignal(fruit_parent, COMSIG_ATOM_ATTACKBY, PROC_REF(catch_attackby))
	if(istype(cell_parent))
		START_PROCESSING(SSobj, src)

/datum/plant_trait/fruit/cell/process(delta_time)
	cell_parent.charge += (cell_parent.maxcharge*(trait_power * REGEN_COEF))*delta_time
	cell_parent.charge = clamp(cell_parent.charge, 0, cell_parent.maxcharge)

/datum/plant_trait/fruit/cell/proc/catch_attackby(datum/source, obj/item, mob/living/user, params)
	SIGNAL_HANDLER

	var/obj/item/stack/cable_coil/cable = item
	if(!istype(cable))
		return
	if(!cable.use(CABLE_AMOUNT))
		to_chat(user, span_warning("You need five lengths of cable to make a [fruit_parent] battery!"))
		return
	to_chat(user, span_notice("You add some cable to [fruit_parent] and slide it inside the battery encasing."))
	var/obj/item/stock_parts/cell/potato/pocell = new /obj/item/stock_parts/cell/potato(user.loc)
//Visuals
	pocell.appearance = fruit_parent.appearance
	pocell.underlays += icon('icons/obj/power.dmi', "grown_wires_under")
//Charge logic
	pocell.maxcharge = pocell.maxcharge * trait_power
	pocell.charge = pocell.maxcharge
	pocell.desc = "A rechargeable plant-based power cell. This one can store up to [display_power(pocell.maxcharge)], and you should not swallow it."
//Special interactions
	if(fruit_parent.reagents.has_reagent(/datum/reagent/toxin/plasma, 2))
		pocell.rigged = TRUE
//Cleanup
	copy(pocell)
	qdel(fruit_parent)

#undef CABLE_AMOUNT
#undef REGEN_COEF
