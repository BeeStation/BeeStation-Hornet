/datum/species/pod/pumpkin_man
	name = "\improper Pumpkinperson"
	id = "pumpkin_man"
	sexes = 0
	meat = /obj/item/reagent_containers/food/snacks/pumpkinpieslice
	species_traits = list(NOEYESPRITES)
	attack_verb = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	miss_sound = 'sound/weapons/punchmiss.ogg'
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN
	mutant_brain = /obj/item/organ/brain/pumpkin_brain

	species_chest = /obj/item/bodypart/chest/pumpkin_man
	species_head = /obj/item/bodypart/head/pumpkin_man
	species_l_arm = /obj/item/bodypart/l_arm/pumpkin_man
	species_r_arm = /obj/item/bodypart/r_arm/pumpkin_man
	species_l_leg = /obj/item/bodypart/l_leg/pumpkin_man
	species_r_leg = /obj/item/bodypart/r_leg/pumpkin_man

//Only allow race roundstart on Halloween
/datum/species/pod/pumpkin_man/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return FALSE

/obj/item/organ/brain/pumpkin_brain
	name = "pumpkinperson brain"
	actions_types = list(/datum/action/item_action/organ_action/pumpkin_head_candy)
	color = "#ff7b00"

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

/datum/action/item_action/organ_action/pumpkin_head_candy/Trigger()
	. = ..()
	if(iscarbon(owner) && !IS_DEAD_OR_INCAP(owner))
		var/mob/living/carbon/H = owner
		//Get candy if we have it
		var/obj/item/type
		if(available_candy.len)
			type = available_candy[1]
			available_candy -= type
			//if we're low on candy, warn player
			if(available_candy.len <= 1)
				to_chat(H, "<span class='warning'>You're running low on candy, it would be unwise to continue...</span>")
			to_chat(H, "<span class='notice'>You pull out a piece of candy from your head.</span>")
			//Put candy into hand, if we can
			H.equip_to_slot_if_possible(type, ITEM_SLOT_HANDS)
		//Otherwise pull our brain out
		else
			to_chat(H, "<span class='warning'>You pull your brain out!</span>")
			var/obj/item/organ/B = H.getorganslot(ORGAN_SLOT_BRAIN)
			B.Remove(H)
			B.forceMove(get_turf(H))

/datum/action/item_action/organ_action/pumpkin_head_candy/proc/generate_candy()
	//Get a candy type
	var/obj/item/type = pick(/obj/item/reagent_containers/food/snacks/sugarcookie/spookyskull,
		/obj/item/reagent_containers/food/snacks/sugarcookie/spookycoffin,
		/obj/item/reagent_containers/food/snacks/candy_corn,
		/obj/item/reagent_containers/food/snacks/candy,
		/obj/item/reagent_containers/food/snacks/candiedapple,
		/obj/item/reagent_containers/food/snacks/chocolatebar)
	//Make some candy & put it in the list
	type = new type
	available_candy += type
