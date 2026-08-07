#define ARMAMENT_CHOICE_SPEAR "Brass Spear"
#define ARMAMENT_CHOICE_HAMMER "Brass Battlehammer"
#define ARMAMENT_CHOICE_SWORD "Brass Sword"
#define ARMAMENT_CHOICE_BOW "Brass Bow"
#define ARMAMENT_CHOICE_STANDARD "Standard Equipment (Unarmed)"

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
		ARMAMENT_CHOICE_SPEAR,
		ARMAMENT_CHOICE_HAMMER,
		ARMAMENT_CHOICE_SWORD,
		ARMAMENT_CHOICE_BOW,
		ARMAMENT_CHOICE_STANDARD,
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
		if(ARMAMENT_CHOICE_SPEAR)
			armaments_spear.equip(living_invoker)
		if(ARMAMENT_CHOICE_HAMMER)
			armaments_hammer.equip(living_invoker)
		if(ARMAMENT_CHOICE_SWORD)
			armaments_sword.equip(living_invoker)
		if(ARMAMENT_CHOICE_BOW)
			armaments_bow.equip(living_invoker)
		if(ARMAMENT_CHOICE_STANDARD)
			default.equip(living_invoker)
	return ..()

#undef ARMAMENT_CHOICE_SPEAR
#undef ARMAMENT_CHOICE_HAMMER
#undef ARMAMENT_CHOICE_SWORD
#undef ARMAMENT_CHOICE_BOW
#undef ARMAMENT_CHOICE_STANDARD
