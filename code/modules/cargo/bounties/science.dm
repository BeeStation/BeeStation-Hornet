/datum/bounty/item/science/genetics
	name = "Genetics Disability Mutator"
	description = "Understanding the humanoid genome is the first step to curing many spaceborn genetic defects, and exceeding our basest limits."
	reward = CARGO_CRATE_VALUE * 2
	wanted_types = list(/obj/item/dnainjector)
	///What's the instability
	var/desired_instability = 0

/datum/bounty/item/science/genetics/New()
	. = ..()
	desired_instability = rand(10,40)
	reward += desired_instability * 100
	description += " We want a DNA injector whose total instability is higher than [desired_instability] points."

/datum/bounty/item/science/genetics/applies_to(obj/O)
	if(!..())
		return FALSE
	var/obj/item/dnainjector/mutator = O
	if(mutator.used)
		return FALSE
	var/inst_total = 0
	for(var/pot_mut in mutator.add_mutations)
		var/datum/mutation/human/mutation = pot_mut
		if(initial(mutation.quality) != POSITIVE)
			continue
		inst_total += mutation.instability
	if(inst_total >= desired_instability)
		return TRUE
	return FALSE

//******Modular Computer Bounties******
/datum/bounty/item/science/NTNet
	name = "Modular Tablets"
	description = "Turns out that NTNet wasn't actually a fad afterall, who knew. Ship us some fully constructed tablets and send it turned on."
	reward = CARGO_CRATE_VALUE * 6
	required_count = 4
	wanted_types = list(/obj/item/modular_computer/tablet)

/datum/bounty/item/science/NTNet/laptops
	name = "Modular Laptops"
	description = "Central command brass need something more powerful than a tablet, but more portable than a console. Help these old fogeys out by shipping us some working laptops. Send it turned on."
	reward = CARGO_CRATE_VALUE * 3
	required_count = 2
	wanted_types = list(/obj/item/modular_computer/laptop)

/datum/bounty/item/science/NTNet/console
	name = "Modular Computer Console"
	description = "Our big data devision needs more powerful hardware to play 'Outbomb Cuban Pe-', err, to closely monitor threats in your sector. Send us a working modular computer console."
	reward = CARGO_CRATE_VALUE * 6
	required_count = 1
	wanted_types = list(/obj/machinery/modular_computer/console)

/datum/bounty/item/science/NTnet/applies_to(obj/O)
	. = ..()
	var/obj/item/modular_computer/computer = O
	if(computer.enabled)
		return TRUE
	return TRUE

/datum/bounty/item/science/NTnet/console/applies_to(obj/O)
	var/obj/machinery/modular_computer/console/computer = O
	if(computer.cpu)
		return TRUE
	return FALSE
