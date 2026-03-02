/datum/species/pumpkin_man
	name = "\improper Pumpkinperson"
	plural_form = "Pumpkinpeople"
	id = SPECIES_PUMPKINPERSON
	sexes = FALSE
	meat = /obj/item/food/pieslice/pumpkin
	inherent_traits = list(
		TRAIT_BEEFRIEND,
		TRAIT_MUTANT_COLORS,
	)
	inherent_factions = list(FACTION_PLANTS, FACTION_VINES)
	heatmod = 1.5
	meat = /obj/item/food/meat/slab/human/mutant/diona
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/diona

	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN

	mutantbrain = /obj/item/organ/brain/pumpkin_brain
	mutanttongue = /obj/item/organ/tongue/diona/pumpkin

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/pumpkin_man,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/pumpkin_man,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/pumpkin_man,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/pumpkin_man,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/pumpkin_man,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/pumpkin_man
	)

//Only allow race roundstart on Halloween
/datum/species/pumpkin_man/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/*
/datum/species/pumpkin_man/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	//They can't speak!
	//Register signal for carving
	RegisterSignal(C, COMSIG_MOB_ITEM_ATTACKBY, PROC_REF(handle_carving))

/datum/species/pumpkin_man/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_ITEM_ATTACKBY)
*/

/datum/species/pumpkin_man/spec_life(mob/living/carbon/human/H)
	. = ..()
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1,T.get_lumcount()) - 0.5
		H.adjust_nutrition(light_amount * 10)
		if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
			H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)
		if(light_amount > 0.2) //if there's enough light, heal
			H.heal_overall_damage(1,1, 0, BODYTYPE_ORGANIC)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(brute = 2, required_bodytype = BODYTYPE_ORGANIC)

/datum/species/pumpkin_man/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()

/datum/species/pumpkin_man/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	switch(P.type)
		if(/obj/projectile/energy/floramut)
			if(prob(15))
				H.Paralyze(100)
				H.visible_message(span_warning("[H] writhes in pain as [H.p_their()] vacuoles boil."), span_userdanger("You writhe in pain as your vacuoles boil!"), span_italics("You hear the crunching of leaves."))
				if(prob(80))
					H.easy_random_mutate(NEGATIVE+MINOR_NEGATIVE)
				else
					H.easy_random_mutate(POSITIVE)
				H.random_mutate()
				H.domutcheck()
			else
				H.adjustFireLoss(rand(5,15))
				H.show_message(span_userdanger("The radiation beam singes you!"))
		if(/obj/projectile/energy/florayield)
			H.set_nutrition(min(H.nutrition+30, NUTRITION_LEVEL_FULL))

/datum/species/pumpkin_man/get_species_description()
	return "A rare species of Pumpkinpeople, gourdy and orange, appearing every halloween."

/datum/species/pumpkin_man/get_species_lore()
	return null

/datum/species/pumpkin_man/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "candy-cane",
			SPECIES_PERK_NAME = "Candy Head!",
			SPECIES_PERK_DESC = "The heads of Pumpkinpeople are known to create delicious candy. Be careful though, take too much and you might pull your brain out!",
		),
	)

	return to_add

/*
//Handler for face carving!
/datum/species/pumpkin_man/proc/handle_carving(datum/_source, mob/living/_user, obj/item/_item)
	//Check if the item is sharp - give owner a random face if applicable
	var/mob/living/carbon/human/M = _source
	var/obj/item/bodypart/head/pumpkin_man/head = M.get_bodypart(BODY_ZONE_HEAD)
	if(_item.get_sharpness() && istype(head) && !_user.combat_mode && _user.is_zone_selected(BODY_ZONE_HEAD))
		to_chat(_user, span_notice("You begin to carve a face into [_source]..."))
		//Do after for *flourish*
		if(do_after(_user, 3 SECONDS))
			//generate option list
			var/list/face_options = list()
			for(var/i in 0 to 8)
				face_options += list("face[i]" = image('icons/mob/pumpkin_faces.dmi', "face[i]"))
			var/face_choosen = show_radial_menu(_user, _source, face_options, require_near = TRUE)
			//Reset overlays
			M.cut_overlay(head.carved_overlay) //This is needed in addition to the head icon getter's - for some reason?
			head.carved_overlay.icon_state = face_choosen
			M.update_body_parts_head_only()
			to_chat(_user, span_notice("You carve a face into [_source]."))
			//Adjust the tongue
			var/obj/item/organ/tongue/diona/pumpkin/P = M.organs_slot[ORGAN_SLOT_TONGUE]
			if(istype(P))
				P?.carved = TRUE
		else
			to_chat(_user, span_warning("You fail to carve a face into [_source]!"))
*/

/obj/item/organ/brain/pumpkin_brain
	name = "pumpkinperson brain"
	actions_types = list(/datum/action/item_action/organ_action/pumpkin_head_candy)
	color = COLOR_TAN_ORANGE

/datum/action/item_action/organ_action/pumpkin_head_candy
	name = "Make Candy"
	desc = "Pull a piece of candy from your pumpkin head."
	///List of candy available to you
	var/list/available_candy = list()
	///Max amount of candy you can hold. Var for admins to edit
	var/candy_limit = 10

/datum/action/item_action/organ_action/pumpkin_head_candy/New(Target)
	. = ..()
	//generate initial candy
	for(var/i in 1 to 10)
		generate_candy()
	START_PROCESSING(SSfastprocess, src)

/datum/action/item_action/organ_action/pumpkin_head_candy/process(delta_time)
	//Every 15 seconds, otherwise early return
	if(world.time % 15 != 0 || available_candy.len > candy_limit)
		return
	generate_candy()

/datum/action/item_action/organ_action/pumpkin_head_candy/on_activate(mob/user, atom/target)
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/H = owner
	if(!IS_DEAD_OR_INCAP(H))
		//Get candy if we have it
		var/obj/item/type
		if(available_candy.len)
			type = available_candy[1]
			available_candy -= type
			//if we're low on candy, warn player
			if(available_candy.len <= 1)
				to_chat(H, span_warning("You're running low on candy, it would be unwise to continue..."))
			to_chat(H, span_notice("You pull out a piece of candy from your head."))
			//Put candy into hand, if we can
			H.equip_to_slot_if_possible(type, ITEM_SLOT_HANDS)
		//Otherwise pull our brain out
		else
			to_chat(H, span_warning("You pull your brain out!"))
			var/obj/item/organ/B = H.get_organ_slot(ORGAN_SLOT_BRAIN)
			B.Remove(H)
			B.forceMove(get_turf(H))

/datum/action/item_action/organ_action/pumpkin_head_candy/proc/generate_candy()
	//Get a candy type
	var/obj/item/type = pick(/obj/item/food/cookie/sugar/spookyskull,
		/obj/item/food/cookie/sugar/spookycoffin,
		/obj/item/food/candy_corn,
		/obj/item/food/candy,
		/obj/item/food/candiedapple,
		/obj/item/food/chocolatebar)
	//Make some candy & put it in the list
	type = new type
	available_candy += type
