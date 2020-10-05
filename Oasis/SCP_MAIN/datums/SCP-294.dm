GLOBAL_LIST_EMPTY(scp294_reagents)

/obj/machinery/scp294
	name = "SCP-294"
	icon = 'Oasis/SCP_MAIN/icons/scpobj/scp294.dmi'
	desc = "<b><span class='notice''><big>SCP-294</big></span></b> - A standard coffee vending machine."
	icon_state = "coffee_294"
	layer = 2.9
	anchored = 1
	density = 1
	flags_1 = NODECONSTRUCT_1
	var/uses_left = 25
	var/last_use = 0
	var/restocking_timer = 0

/obj/machinery/scp294/examine(mob/user)
	. = ..()


/obj/machinery/scp294/Initialize()
	. = ..()

	if(!GLOB.scp294_reagents.len)
		//Chemical Reagents - Initialises all /6 into a list indexed by reagent id
		var/paths = subtypesof(/datum/reagent)
		for(var/path in paths)
			var/datum/reagent/D = new path
			if(D.can_synth)
				GLOB.scp294_reagents[D.name] = D

/obj/machinery/scp294/attack_hand(mob/user)

	if((last_use + 30 SECONDS) > world.time)
		visible_message("<span class='notice'>[src] displays NOT READY message.</span>")
		return

	last_use = world.time
	if(uses_left < 1)
		visible_message("<span class='notice'>[src] displays OUT OF STOCK message.</span>")
		uses_left = 0 //  So it never restocks, but kept in code so it can be altered if needed
		return

	var/product = null
	var/input_reagent = (input("Enter the name of any liquid") as text)
	product = find_reagent(input_reagent)

	if(product)
		var/obj/item/reagent_containers/food/drinks/bottle/blank/small/D = new /obj/item/reagent_containers/food/drinks/bottle/blank/small/(loc)
		D.reagents.add_reagent(product, 50)
	//	D.name = trim("[input_reagent] bottle")
		visible_message("<span class='notice'>[src] dispenses a full bottle of [input_reagent]</span>")
	else
		visible_message("<span class='notice'>[src]'s OUT OF RANGE light flashes rapidly.</span>")

/obj/machinery/scp294/proc/find_reagent(input)
	. = FALSE
	if(GLOB.scp294_reagents[input])
		var/datum/reagent/R = GLOB.scp294_reagents[input]
		if(R)
			return R.type
	else
		for(var/X in GLOB.scp294_reagents)
			var/datum/reagent/R = GLOB.scp294_reagents[X]
			if (ckey(input) == ckey(R.name))
				return R.type
