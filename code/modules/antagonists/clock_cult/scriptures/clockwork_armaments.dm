/datum/clockcult/scripture/clockwork_armaments
	name = "Clockwork Armaments"
	desc = "Summon clockwork armor and weapons, to be ready for battle."
	tip = "Summon clockwork armor and weapons, to be ready for battle."
	invokation_text = list("Through courage and hope...", "we shall protect thee!")
	invokation_time = 2 SECONDS
	button_icon_state = "clockwork_armor"
	power_cost = 150
	category = SPELLTYPE_PRESERVATION

	/// List of possible choices
	var/list/clockwork_armaments = list(
		"Brass Spear",
		"Brass Battlehammer",
		"Brass Sword",
		"Brass Bow",
		"Standard Equipment (Unarmed)",
	)

/datum/clockcult/scripture/clockwork_armaments/on_invoke_success()
	var/mob/living/living_invoker = invoker
	var/choice = tgui_input_list(living_invoker, "What weapon do you want to call upon?", "Clockwork Armaments", clockwork_armaments)
	if(!choice)
		return

	// Possible armaments
	var/static/datum/outfit/clockcult/armaments/armaments_spear = new
	var/static/datum/outfit/clockcult/armaments/hammer/armaments_hammer = new
	var/static/datum/outfit/clockcult/armaments/sword/armaments_sword = new
	var/static/datum/outfit/clockcult/armaments/bow/armaments_bow = new
	var/static/datum/outfit/clockcult/default = new
	var/static/datum/outfit/clockcult_plasmaman/plasmaman = new

	// Plasmamen get a special outfit, don't want to remove their envirosuit!
	if(isplasmaman(living_invoker))
		plasmaman.equip(living_invoker)

	// Give gear
	switch(choice)
		if("Brass Spear")
			armaments_spear.equip(living_invoker)
		if("Brass Battlehammer")
			armaments_hammer.equip(living_invoker)
		if("Brass Sword")
			armaments_sword.equip(living_invoker)
		if("Brass Bow")
			armaments_bow.equip(living_invoker)
		if("Standard Equipment (Unarmed)")
			default.equip(living_invoker)
	return ..()
