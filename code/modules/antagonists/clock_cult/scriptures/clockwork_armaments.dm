//==================================//
// !           Armaments          ! //
//==================================//
/datum/clockcult/scripture/clockwork_armaments
	name = "Clockwork Armaments"
	desc = "Summon clockwork armor and weapons, to be ready for battle."
	tip = "Summon clockwork armor and weapons, to be ready for battle."
	button_icon_state = "clockwork_armor"
	power_cost = 150
	invokation_time = 20
	invokation_text = list("Through courage and hope...", "we shall protect thee!")
	category = SPELLTYPE_PRESERVATION
	cogs_required = 0

/datum/clockcult/scripture/clockwork_armaments/invoke_success()
	var/mob/living/M = invoker
	var/choice = input(M,"What weapon do you want to call upon?", "Clockwork Armaments") as anything in list("Brass Spear","Brass Battlehammer","Brass Sword", "Brass Bow")
	var/datum/antagonist/servant_of_ratvar/servant = is_servant_of_ratvar(M)
	if(!servant)
		return FALSE
	//Equip mob with gamer gear
	var/static/datum/outfit/clockcult/armaments/armaments_spear = new
	var/static/datum/outfit/clockcult/armaments/hammer/armaments_hammer = new
	var/static/datum/outfit/clockcult/armaments/sword/armaments_sword = new
	var/static/datum/outfit/clockcult/armaments/bow/armaments_bow = new
	switch(choice)
		if("Brass Spear")
			armaments_spear.equip(M)
		if("Brass Battlehammer")
			armaments_hammer.equip(M)
		if("Brass Sword")
			armaments_sword.equip(M)
		if("Brass Bow")
			armaments_bow.equip(M)
