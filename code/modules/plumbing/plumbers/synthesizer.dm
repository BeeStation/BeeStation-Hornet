///A single machine that produces a single chem. Can be placed in unison with others through plumbing to create chemical factories
/obj/machinery/plumbing/synthesizer
	name = "chemical synthesizer"
	desc = "Produces a single chemical at a given volume. Must be plumbed. Most effective when working in unison with other chemical synthesizers, heaters and filters."

	icon_state = "synthesizer"
	icon = 'icons/obj/plumbing/plumbers.dmi'
	rcd_cost = 25
	rcd_delay = 15
	active_power_usage = 500

	///Amount we produce for every process. Ideally keep under 5 since thats currently the standard duct capacity
	var/amount = 1
	///The maximum we can produce for every process
	buffer = 5
	///I track them here because I have no idea how I'd make tgui loop like that
	var/static/list/possible_amounts = list(0,1,2,3,4,5)
	///The reagent we are producing. We are a typepath, but are also typecast because there's several occations where we need to use initial.
	var/datum/reagent/reagent_id = null
	///reagent overlay. its the colored pipe thingies. we track this because overlays.Cut() is bad
	var/image/r_overlay
	///The amount of reagent dispensable before requiring a refill from a compressed matter cartridge.
	var/volume_left = 0
	///The maximum amount of precursor in a synthesizer.
	var/max_volume = 1000
	///straight up copied from chem dispenser. Being a subtype would be extremely tedious and making it global would restrict potential subtypes using different dispensable_reagents
	var/list/dispensable_reagents = list(
		/datum/reagent/aluminium,
		/datum/reagent/bromine,
		/datum/reagent/carbon,
		/datum/reagent/chlorine,
		/datum/reagent/copper,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fluorine,
		/datum/reagent/hydrogen,
		/datum/reagent/iodine,
		/datum/reagent/iron,
		/datum/reagent/lithium,
		/datum/reagent/mercury,
		/datum/reagent/nitrogen,
		/datum/reagent/oxygen,
		/datum/reagent/phosphorus,
		/datum/reagent/potassium,
		/datum/reagent/uranium/radium,
		/datum/reagent/silicon,
		/datum/reagent/silver,
		/datum/reagent/sodium,
		/datum/reagent/stable_plasma,
		/datum/reagent/consumable/sugar,
		/datum/reagent/sulfur,
		/datum/reagent/toxin/acid,
		/datum/reagent/water,
		/datum/reagent/fuel
	)




/obj/machinery/plumbing/synthesizer/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt)
	update_appearance() //so the input/output pipes will overlay properly during init

/obj/machinery/plumbing/synthesizer/process(delta_time)
	if(machine_stat & NOPOWER || !reagent_id || !amount)
		return
	if(reagents.total_volume >= amount*delta_time*0.5) //otherwise we get leftovers, and we need this to be precise
		return
	if(volume_left < amount) //Empty
		return
	reagents.add_reagent(reagent_id, amount*delta_time*0.5)
	volume_left = max(volume_left - amount*delta_time*0.5, 0)

/obj/machinery/plumbing/synthesizer/attackby(obj/item/O, mob/user, params)
	if(!istype(O, /obj/item/rcd_ammo))
		return ..()
	var/obj/item/rcd_ammo/R = O
	if(!R.ammoamt)
		to_chat(user, "<span class='warning'>The [R.name] doesn't have any reagent left!</span>")
		return ..()
	var/added_volume = -volume_left //For the difference calculation
	volume_left = min(volume_left+R.ammoamt*10, src.max_volume) //400 per cartridge
	added_volume = added_volume+volume_left
	R.ammoamt -= added_volume/10
	if(R.ammoamt <= 0) //Emptied
		to_chat(user, "<span class='notice'>You refill the chemical synthesizer with the [R.name], emptying it completely!</span>")
		qdel(R)
		return
	if(added_volume == 0) //No change
		to_chat(user, "<span class='notice'>The chemical synthesizer is full!</span>")
		return
	to_chat(user, "<span class='notice'>You refill the chemical synthesizer with the [R.name], leaving [R.ammoamt*10] units in it.</span>")

/obj/machinery/plumbing/synthesizer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>A display says it currently holds [volume_left] units of precursor before requiring a refill.</span>"

/obj/machinery/plumbing/synthesizer/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/plumbing/synthesizer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemSynthesizer")
		ui.open()

/obj/machinery/plumbing/synthesizer/ui_data(mob/user)
	var/list/data = list()

	var/is_hallucinating = user.hallucinating()
	var/list/chemicals = list()

	for(var/A in dispensable_reagents)
		var/datum/reagent/R = GLOB.chemical_reagents_list[A]
		if(R)
			var/chemname = R.name
			if(is_hallucinating && prob(5))
				chemname = "[pick_list_replacements("hallucination.json", "chemicals")]"
			chemicals.Add(list(list("title" = chemname, "id" = ckey(R.name))))
	data["chemicals"] = chemicals
	data["amount"] = amount
	data["possible_amounts"] = possible_amounts

	data["current_reagent"] = ckey(initial(reagent_id.name))
	return data

/obj/machinery/plumbing/synthesizer/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("amount")
			var/new_amount = text2num(params["target"])
			if(new_amount in possible_amounts)
				amount = new_amount
				. = TRUE
		if("select")
			var/new_reagent = GLOB.name2reagent[params["reagent"]]
			if(new_reagent in dispensable_reagents)
				reagent_id = new_reagent
				. = TRUE
	if(.)
		update_icon()
		reagents.clear_reagents()

/obj/machinery/plumbing/synthesizer/update_icon()
	if(!r_overlay)
		r_overlay = image(icon, "[icon_state]_overlay")
	else
		overlays -= r_overlay //we remove it because overlays are completely unnaffected by changing the object, you need to reapply it

	if(reagent_id)
		r_overlay.color = initial(reagent_id.color)
	else
		r_overlay.color = "#FFFFFF"

	overlays += r_overlay
	..()
