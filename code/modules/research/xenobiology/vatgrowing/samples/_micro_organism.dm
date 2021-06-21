///A single type of growth.
/datum/micro_organism
	///Name, shown on microscope
	var/name = "Unknown fluids"
	///Desc, shown by science goggles
	var/desc = "White fluid that tastes like salty coins and milk"

///Returns a short description of the cell line
/datum/micro_organism/proc/get_details(show_details)
	return "<span class='notice'>[desc]</span>"

///A "mob" cell. Can grow into a mob in a growing vat.
/datum/micro_organism/cell_line
	///Our growth so far, needs to get up to 100
	var/growth = 0
	///All the reagent types required for letting this organism grow into whatever it should become
	var/list/required_reagents
	///Reagent types that further speed up growth, but aren't needed.  Assoc list of reagent datum type || bonus growth per tick
	var/list/supplementary_reagents
	///Reagent types that surpress growth. Assoc list of reagent datum type || lost growth per tick
	var/list/suppressive_reagents
	///This var modifies how much this micro_organism is affected by viruses. Higher is more slowdown
	var/virus_suspectibility = 1
	///This var defines how much % the organism grows per process(), without modifiers, if you have all required reagents
	var/growth_rate = 4
	///Resulting atoms from growing this cell line. List is assoc atom type || amount
	var/list/resulting_atoms = list()

///Handles growth of the micro_organism. This only runs if the micro organism is in the growing vat. Reagents is the growing vats reagents
/datum/micro_organism/cell_line/proc/handle_growth(var/obj/machinery/plumbing/growing_vat/vat)
	if(!try_eat(vat.reagents))
		return FALSE
	growth = max(growth, growth + calculate_growth(vat.reagents, vat.biological_sample)) //Prevent you from having minus growth.
	if(growth >= 100)
		finish_growing(vat)
	return TRUE

///Tries to consume the required reagents. Can only do this if all of them are available. Reagents is the growing vats reagents
/datum/micro_organism/cell_line/proc/try_eat(var/datum/reagents/reagents)
	for(var/i in required_reagents)
		if(!reagents.has_reagent(i))
			return FALSE
	for(var/i in required_reagents) //Delete the required reagents if used
		reagents.remove_reagent(i, REAGENTS_METABOLISM)
	return TRUE

///Apply modifiers on growth_rate based on supplementary and supressive reagents. Reagents is the growing vats reagents
/datum/micro_organism/cell_line/proc/calculate_growth(var/datum/reagents/reagents, var/datum/biological_sample/biological_sample)
	. = growth_rate

	//Handle growth based on supplementary reagents here.
	for(var/i in supplementary_reagents)
		if(!reagents.has_reagent(i, REAGENTS_METABOLISM))
			continue
		. += supplementary_reagents[i]
		reagents.remove_reagent(i, REAGENTS_METABOLISM)

	//Handle degrowth based on supressive reagents here.
	for(var/i in suppressive_reagents)
		if(!reagents.has_reagent(i, REAGENTS_METABOLISM))
			continue
		. += suppressive_reagents[i]
		reagents.remove_reagent(i, REAGENTS_METABOLISM)

	//Handle debuffing growth based on viruses here.
	for(var/datum/micro_organism/cell_line/virus in biological_sample.micro_organisms)
		if(reagents.has_reagent(/datum/reagent/medicine/spaceacillin, REAGENTS_METABOLISM))
			reagents.remove_reagent(/datum/reagent/medicine/spaceacillin, REAGENTS_METABOLISM)
			continue //This virus is stopped, We have antiviral stuff
		. -= virus_suspectibility

///Called once a cell line reaches 100 growth. Then we check if any cell_line is too far so we can perform an epic fail roll
/datum/micro_organism/cell_line/proc/finish_growing(var/obj/machinery/plumbing/growing_vat/vat)
	var/risk = 0 //Penalty for failure, goes up based on how much growth the other cell_lines have

	for(var/datum/micro_organism/cell_line/cell_line in vat.biological_sample.micro_organisms)
		if(cell_line == src) //well duh
			continue
		if(cell_line.growth >= VATGROWING_DANGER_MINIMUM)
			risk += cell_line.growth * 0.6 //60% per cell_line potentially. Kryson should probably tweak this
	playsound(vat, 'sound/effects/splat.ogg', 50, TRUE)
	if(rand(1, 100) < risk) //Fail roll!
		fuck_up_growing(vat)
		return FALSE
	succeed_growing(vat)
	return TRUE

/datum/micro_organism/cell_line/proc/fuck_up_growing(var/obj/machinery/plumbing/growing_vat/vat)
	vat.visible_message("<span class='warning'>The biological sample in [vat] seems to have dissipated!</span>")
	QDEL_NULL(vat.biological_sample) //Kill off the sample, we're done
	if(prob(50))
		new /obj/effect/gibspawner/generic(get_turf(vat)) //Spawn some gibs.


/datum/micro_organism/cell_line/proc/succeed_growing(var/obj/machinery/plumbing/growing_vat/vat)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(0, vat.loc)
	smoke.start()
	for(var/created_thing in resulting_atoms)
		for(var/x in 1 to resulting_atoms[created_thing])
			var/atom/thing = new created_thing(get_turf(vat))
			vat.visible_message("<span class='nicegreen'>[thing] pops out of [vat]!</span>")

	QDEL_NULL(vat.biological_sample) //Kill off the sample, we're done

///Overriden to show more info like needs, supplementary and supressive reagents and also growth.
/datum/micro_organism/cell_line/get_details(show_details)
	. += "<span class='notice'>[desc] - growth progress: [growth]%</span>\n"
	if(show_details)
		. += return_reagent_text("It requires:", required_reagents)
		. += return_reagent_text("It likes:", supplementary_reagents)
		. += return_reagent_text("It hates:", suppressive_reagents)

///Return a nice list of all the reagents in a specific category with a specific prefix. This needs to be reworked because the formatting sucks ass.
/datum/micro_organism/cell_line/proc/return_reagent_text(var/prefix_text = "It requires:", var/list/reagentlist)
	if(!reagentlist.len)
		return
	var/all_reagents_text
	for(var/i in reagentlist)
		var/datum/reagent/reagent = i
		all_reagents_text += " - [initial(reagent.name)]\n"
	return "<span class='notice'>[prefix_text]\n[all_reagents_text]</span>"

///This datum is a simple holder for the micro_organisms in a sample.
/datum/biological_sample
	///List of all micro_organisms in the sample. These are instantiated
	var/list/micro_organisms = list()
	///Prevents someone from stacking too many layers onto a swabber
	var/sample_layers = 1
	///Picked from a specific group of colors, limited to a specific group.
	var/sample_color = COLOR_SAMPLE_YELLOW

///Generate a sample from a specific weighted list, and a specific amount of cell line with a chance for a virus
/datum/biological_sample/proc/GenerateSample(cell_line_define, virus_define, cell_line_amount, virus_chance)
	sample_color = pick(GLOB.xeno_sample_colors)

	var/list/temp_weight_list = GLOB.cell_line_tables[cell_line_define].Copy() //Temp list to prevent double picking
	for(var/i in 1 to cell_line_amount)
		var/datum/micro_organism/chosen_type = pickweight(temp_weight_list)
		temp_weight_list -= chosen_type
		micro_organisms += new chosen_type
	if(virus_chance)
		if(!GLOB.cell_virus_tables[virus_define])
			return
		var/datum/micro_organism/chosen_type = pickweight(GLOB.cell_virus_tables[virus_define])
		micro_organisms += new chosen_type

///Takes another sample and merges it into use. This can cause one very big sample but we limit it to 3 layers.
/datum/biological_sample/proc/Merge(var/datum/biological_sample/other_sample)
	if(sample_layers >= 3)//No more than 3 layers, at that point you're entering danger zone.
		return FALSE
	micro_organisms += other_sample.micro_organisms
	qdel(other_sample)
	return TRUE

///Call handle_growth on all our microorganisms.
/datum/biological_sample/proc/handle_growth(var/obj/machinery/plumbing/growing_vat/vat)
	for(var/datum/micro_organism/cell_line/organism in micro_organisms) //Types because we don't grow viruses.
		organism.handle_growth(vat)
