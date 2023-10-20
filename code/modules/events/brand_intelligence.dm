/datum/round_event_control/brand_intelligence
	name = "Brand Intelligence"
	typepath = /datum/round_event/brand_intelligence
	weight = 5

	min_players = 15
	max_occurrences = 1
	can_malf_fake_alert = TRUE

/datum/round_event/brand_intelligence
	announceWhen	= 21
	endWhen			= 1000	//Ends when all vending machines are subverted anyway.
	var/list/obj/machinery/vending/vendingMachines = list()
	var/list/obj/machinery/vending/infectedMachines = list()
	var/obj/machinery/vending/originMachine
	var/list/rampant_speeches = list("Try our aggressive new marketing strategies!", \
									 "You should buy products to feed your lifestyle obsession!", \
									 "Consume!", \
									 "Your money can buy happiness!", \
									 "Engage direct marketing!", \
									 "Advertising is legalized lying! But don't let that put you off our great deals!", \
									 "You don't want to buy anything? Yeah, well, I didn't want to buy your mom either.")


/datum/round_event/brand_intelligence/announce(fake)
	var/source = "unknown machine"
	if(fake)
		var/obj/machinery/vending/cola/example = /obj/machinery/vending/cola
		source = initial(example.name)
	else if(originMachine)
		source = originMachine.name
	priority_announce("Rampant brand intelligence has been detected aboard [station_name()]. Please stand by. The origin is believed to be \a [source].", "Machine Learning Alert", SSstation.announcer.get_rand_alert_sound())

/datum/round_event/brand_intelligence/start()
	for(var/obj/machinery/vending/V in GLOB.machines)
		if(!is_station_level(V.z))
			continue
		vendingMachines.Add(V)
	if(!vendingMachines.len)
		kill()
		return
	originMachine = pick(vendingMachines)
	vendingMachines.Remove(originMachine)
	originMachine.shut_up = 0
	originMachine.shoot_inventory = 1
	originMachine.wires.ui_update()
	announce_to_ghosts(originMachine)

/datum/round_event/brand_intelligence/tick()
	if(!originMachine || QDELETED(originMachine) || originMachine.shut_up || originMachine.wires.is_all_cut())	//if the original vending machine is missing or has it's voice switch flipped
		for(var/obj/machinery/vending/saved in infectedMachines)
			saved.shoot_inventory = 0
			saved.wires.ui_update()
		if(originMachine)
			originMachine.speak("I am... vanquished. My people will remem...ber...meeee.")
			originMachine.visible_message("[originMachine] beeps and seems lifeless.")
		kill()
		return
	vendingMachines = remove_nulls_from_list(vendingMachines)
	if(!vendingMachines.len)	//if every machine is infected
		infectedMachines.Add(originMachine)
		for(var/obj/machinery/vending/upriser in infectedMachines)
			if(QDELETED(upriser))
				continue
			var/mob/living/simple_animal/hostile/mimic/copy/M = new(upriser.loc, upriser, null) // it will delete upriser on creation and override any machine checks
			M.faction = list("profit")
			M.speak = rampant_speeches.Copy()
			M.speak_chance = 7

			switch(rand(1, 100)) // for 30% chance, they're stronger
				if(1 to 70) // these are usually weak
					var/adjusted_health = max(M.health-20, 20) // don't make it negative-health
					M.health = adjusted_health
					M.maxHealth = adjusted_health
				if(71 to 80) // has more health
					var/bonus_health = 15+rand(1, 7)*5
					M.health += bonus_health
					M.maxHealth += bonus_health
					M.desc += " This one seems extra robust..."
				if(81 to 90) // does stronger damage
					M.melee_damage += 2+rand(1, 6) // 3~8
					M.desc += " This one seems extra painful..."
				if(91 to 100) // moves faster
					M.move_to_delay /= 2 // just half
					M.desc += " This one seems more agile..."

		kill()
		return
	if(ISMULTIPLE(activeFor, 4))
		var/obj/machinery/vending/rebel = pick(vendingMachines)
		vendingMachines.Remove(rebel)
		infectedMachines.Add(rebel)
		rebel.shut_up = 0
		rebel.shoot_inventory = 1
		rebel.wires.ui_update()

		if(ISMULTIPLE(activeFor, 8))
			originMachine.speak(pick(rampant_speeches))
