GLOBAL_DATUM_INIT(ai_os, /datum/ai_os, new)

/datum/ai_os
	var/name = "Computational Resource Management System (CRMS)"

	var/total_cpu = 0

	var/total_ram = 0

	var/previous_cpu = 0
	var/previous_ram = 0

	var/list/cpu_assigned
	var/list/ram_assigned

/datum/ai_os/New()
	update_hardware()
	cpu_assigned = list()
	ram_assigned = list()

/datum/ai_os/proc/remove_ai(mob/living/silicon/ai/AI)
	cpu_assigned.Remove(AI)
	ram_assigned.Remove(AI)
	update_allocations()

/datum/ai_os/proc/total_cpu_assigned()
	var/total = 0
	for(var/N in cpu_assigned)
		total += cpu_assigned[N]
	return total

/datum/ai_os/proc/total_ram_assigned()
	var/total = 0
	for(var/N in ram_assigned)
		total += ram_assigned[N]
	return total

/datum/ai_os/proc/update_hardware()
	previous_cpu = total_cpu
	previous_ram = total_ram
	total_cpu = 0
	total_ram = 0
	for(var/obj/machinery/ai/expansion_card_holder/C in GLOB.expansion_card_holders)
		if(!C.valid_holder() && !C.roundstart)
			continue
		for(var/CARD in C.installed_cards)
			if(istype(CARD, /obj/item/processing_card))
				var/obj/item/processing_card/PC = CARD
				total_cpu += PC.tier
			if(istype(CARD, /obj/item/memory_card))
				var/obj/item/memory_card/MC = CARD
				total_ram += MC.tier

	update_allocations()

/datum/ai_os/proc/update_allocations()
	//If we have the same amount of CPU & RAM as before, do nothing
	if(total_cpu >= previous_cpu && total_ram >= previous_ram)
		return

	//Find out how much is actually assigned. We can have more total_cpu than the sum of cpu_assigned. Same with RAM
	var/total_assigned_cpu = total_cpu_assigned()
	var/total_assigned_ram = total_ram_assigned()
	//If we have less assigned cpu and ram than we have cpu and ram, just return, everything is fine.
	if(total_assigned_cpu < total_cpu || total_assigned_ram < total_ram)
		return

	//Copy the lists of assigned resources so we don't manipulate the list prematurely
	var/list/cpu_assigned_copy = cpu_assigned.Copy()
	var/list/ram_assigned_copy = ram_assigned.Copy()

	var/list/affected_AIs = list()

	//Less CPU than we have assigned, proceed to remove CPU
	if(total_assigned_cpu > total_cpu)
		//How much do we need to remove to break even?
		var/needed_amount = total_assigned_cpu - total_cpu
		for(var/A in cpu_assigned_copy)
			var/mob/living/silicon/ai/AI = A
			//If this AI has enough for us to break even, deduct that amount and break
			if(cpu_assigned_copy[AI] >= needed_amount)
				cpu_assigned_copy[AI] -= needed_amount
				affected_AIs |= AI
				total_assigned_cpu -= needed_amount
				break
			else if(cpu_assigned_copy[AI]) //AI doesn't have enough so we deduct everything they have.
				var/amount = cpu_assigned_copy[AI]
				cpu_assigned_copy[AI] -= amount
				affected_AIs |= AI
				total_assigned_cpu -= amount
				needed_amount -= amount //Decrease the amount needed to break even so if we go to the next AI we can do the previous if statement.
				if(total_cpu >= total_assigned_cpu) //If this was enough we are done
					break

//If that somehow didn't work we clear everything just in case. Technically not needed and needs to be removed when we're sure everything works
		//TODO: Remove
		if(total_cpu < total_assigned_cpu)
			for(var/A in cpu_assigned_copy)
				var/amount = cpu_assigned_copy[A]
				cpu_assigned_copy[A] = 0
				affected_AIs |= A
				total_assigned_cpu -= amount

	if(total_assigned_ram > total_ram)
		var/needed_amount = total_assigned_ram - total_ram
		for(var/A in ram_assigned_copy)
			var/mob/living/silicon/ai/AI = A
			if(ram_assigned_copy[AI] >= needed_amount)
				ram_assigned_copy[AI] -= needed_amount
				total_assigned_ram -= needed_amount
				affected_AIs |= AI
				break
			else if(cpu_assigned_copy[AI])
				var/amount = cpu_assigned_copy[AI]
				ram_assigned_copy[AI] -= amount
				affected_AIs |= AI
				needed_amount -= amount
				total_assigned_ram -= amount
				if(total_ram >= total_assigned_ram)
					break

		//If that somehow didn't work we clear everything just in case. Technically not needed and needs to be removed when we're sure everything works
		if(total_ram < total_assigned_ram)
			for(var/A in ram_assigned_copy)
				var/amount = ram_assigned_copy[A]
				ram_assigned_copy[A] = 0
				affected_AIs |= A
				total_assigned_ram -= amount
	//Set the actual values of the assigned to our manipulated copies. Bypass helper procs as we assume we're correct.
	ram_assigned = ram_assigned_copy
	cpu_assigned = cpu_assigned_copy

	to_chat(affected_AIs, ("<span_class='warning'>You have been deducted processing capabilities. Please contact your network administrator if you believe this to be an error.</span>"))

/datum/ai_os/proc/add_cpu(mob/living/silicon/ai/AI, amount)
	if(!AI || !amount)
		return
	if(!istype(AI))
		return
	cpu_assigned[AI] += amount

	update_allocations()

/datum/ai_os/proc/remove_cpu(mob/living/silicon/ai/AI, amount)
	if(!AI || !amount)
		return
	if(!istype(AI))
		return
	if(cpu_assigned[AI] - amount < 0)
		cpu_assigned[AI] = 0
	else
		cpu_assigned[AI] -= amount

	update_allocations()

/datum/ai_os/proc/add_ram(mob/living/silicon/ai/AI, amount)
	if(!AI || !amount)
		return
	if(!istype(AI))
		return
	ram_assigned[AI] += amount

	update_allocations()

/datum/ai_os/proc/remove_ram(mob/living/silicon/ai/AI, amount)
	if(!AI || !amount)
		return
	if(!istype(AI))
		return
	if(ram_assigned[AI] - amount < 0)
		ram_assigned[AI] = 0
	else
		ram_assigned[AI] -= amount

	update_allocations()


/datum/ai_os/proc/clear_ai_resources(mob/living/silicon/ai/AI)
	if(!AI || !istype(AI))
		return

	remove_ram(AI, ram_assigned[AI])
	remove_cpu(AI, cpu_assigned[AI])

	update_allocations()
