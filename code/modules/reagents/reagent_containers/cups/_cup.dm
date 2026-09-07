/obj/item/reagent_containers/cup
	abstract_type = /obj/item/reagent_containers/cup
	name = "glass"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50)
	volume = 50
	obj_flags = UNIQUE_RENAME
	initial_reagent_flags = OPENCONTAINER | DUNKABLE
	resistance_flags = ACID_PROOF

	lefthand_file = 'icons/mob/inhands/misc/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/drinks_righthand.dmi'

	///Like Edible's food type, what kind of drink is this?
	var/drink_type = NONE
	///The last time we have checked for taste.
	var/last_check_time
	///How much we drink at once, shot glasses drink more.
	var/gulp_size = 5
	///Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it.
	var/isGlass = FALSE

/obj/item/reagent_containers/cup/Initialize(mapload, vol)
	. = ..()
	AddElement(/datum/element/reagents_item_heatable)

/obj/item/reagent_containers/cup/examine(mob/user)
	. = ..()
	if(drink_type)
		var/list/types = bitfield_to_list(drink_type, FOOD_FLAGS)
		. += span_notice("It is [LOWER_TEXT(english_list(types))].")

/obj/item/reagent_containers/cup/proc/checkLiked(fraction, mob/M)
	if(last_check_time + 50 >= world.time)
		return
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	var/obj/item/organ/tongue/T = H.get_organ_slot(ORGAN_SLOT_TONGUE)

	if((drink_type & BREAKFAST) && world.time - SSticker.round_start_time < STOP_SERVING_BREAKFAST)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "breakfast", /datum/mood_event/breakfast)
	last_check_time = world.time

	if(!T) //if you don't have a tongue you don't taste..
		return

	if(HAS_TRAIT(H, TRAIT_AGEUSIA))
		if(drink_type & T.toxic_foodtypes)
			to_chat(H, span_warning("You don't feel so good..."))
			H.adjust_disgust(25 + 30 * fraction)
	else
		if(drink_type & T.toxic_foodtypes)
			to_chat(H, span_warning("What the hell was that thing?!"))
			H.adjust_disgust(25 + 30 * fraction)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "toxic_food", /datum/mood_event/disgusting_food)
		else if(drink_type & T.disliked_foodtypes)
			to_chat(H, span_notice("That didn't taste very good..."))
			H.adjust_disgust(11 + 15 * fraction)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "gross_food", /datum/mood_event/gross_food)
		else if(drink_type & T.liked_foodtypes)
			to_chat(H, span_notice("I love this taste!"))
			H.adjust_disgust(-5 + -2.5 * fraction)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "fav_food", /datum/mood_event/favorite_food)

/obj/item/reagent_containers/cup/proc/try_drink(mob/living/target_mob, mob/living/user)
	if(!canconsume(target_mob, user))
		return ITEM_INTERACT_BLOCKING

	user.changeNext_move(CLICK_CD_MELEE)
	if(target_mob != user)
		if(DOING_INTERACTION_WITH_TARGET(user, target_mob))
			return ITEM_INTERACT_BLOCKING
		target_mob.visible_message(
			span_danger("[user] attempts to feed [target_mob] something from [src]."),
			span_userdanger("[user] attempts to feed you something from [src]."),
		)
		if(!do_after(user, 3 SECONDS, target_mob))
			return ITEM_INTERACT_BLOCKING
		if(!reagents || !reagents.total_volume)
			return ITEM_INTERACT_BLOCKING // The drink might be empty after the delay, such as by spam-feeding
		target_mob.visible_message(
			span_danger("[user] feeds [target_mob] something from [src]."),
			span_userdanger("[user] feeds you something from [src]."),
		)
		if(target_mob.is_blind())
			to_chat(target_mob, span_notice("You feel someone feed you something."))
		log_combat(user, target_mob, "fed", reagents.get_reagent_log_string())

	else
		to_chat(user, span_notice("You swallow a gulp of [src]."))

	SEND_SIGNAL(src, COMSIG_GLASS_DRANK, target_mob, user)
	var/fraction = min(gulp_size / reagents.total_volume, 1)
	reagents.trans_to(target_mob, gulp_size, transfered_by = user, method = INGEST)
	checkLiked(fraction, target_mob)
	playsound(target_mob, 'sound/items/drink.ogg', rand(10,50), TRUE)
	var/list/datum/disease/diseases_to_add
	for(var/datum/disease/malady as anything in target_mob.get_static_viruses())
		if(malady.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS)
			LAZYADD(diseases_to_add, malady)
	if(LAZYLEN(diseases_to_add))
		AddComponent(/datum/component/infective, diseases_to_add)

	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/cup/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return
	if(!is_open_container())
		return NONE

	if(target.is_refillable()) //Something like a glass. Player probably wants to transfer TO it.
		return try_refill(target, user)

	if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		return try_drain(target, user)

	if(isliving(target))
		return try_drink(target, user)

	return NONE

/obj/item/reagent_containers/cup/interact_with_atom_secondary(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	if(!is_open_container())
		return NONE

	if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		return try_drain(target, user)

	return NONE

/obj/item/reagent_containers/cup/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!is_open_container() || !istype(tool, /obj/item/food/egg))
		return NONE

	//breaking eggs
	if(reagents.holder_full())
		to_chat(user, span_notice("[src] is full."))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("You break [tool] in [src]."))
	tool.reagents.trans_to(src, tool.reagents.total_volume, transfered_by = user)
	qdel(tool)
	return ITEM_INTERACT_SUCCESS

/// Callback for [datum/component/takes_reagent_appearance] to inherent style footypes
/obj/item/reagent_containers/cup/proc/on_cup_change(datum/glass_style/has_foodtype/style)
	if(!istype(style))
		return
	drink_type = style.drink_type

/// Callback for [datum/component/takes_reagent_appearance] to reset to no foodtypes
/obj/item/reagent_containers/cup/proc/on_cup_reset()
	drink_type = NONE

/obj/item/reagent_containers/cup/beaker
	name = "beaker"
	desc = "A beaker. It can hold up to 50 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beaker"
	inhand_icon_state = "beaker"
	worn_icon_state = "beaker"
	custom_materials = list(/datum/material/glass=500)
	fill_icon_thresholds = list(1, 10, 20, 40, 60, 80, 100)
	label_icon = "label_beaker"

/obj/item/reagent_containers/cup/beaker/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/reagent_containers/cup/beaker/get_part_rating()
	return reagents.maximum_volume

/obj/item/reagent_containers/cup/beaker/jar
	name = "honey jar"
	desc = "A jar for honey. It can hold up to 50 units of sweet delight."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "vapour"
	fill_icon_state = null
	fill_icon_thresholds = null
	label_icon = null

/obj/item/reagent_containers/cup/beaker/large
	name = "large beaker"
	desc = "A large beaker. Can hold up to 100 units."
	icon_state = "beakerlarge"
	custom_materials = list(/datum/material/glass=2500)
	volume = 100
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100)
	label_icon = "label_beakerlarge"

/obj/item/reagent_containers/cup/beaker/plastic
	name = "x-large beaker"
	desc = "An extra-large beaker. Can hold up to 120 units."
	icon_state = "beakerwhite"
	custom_materials = list(/datum/material/glass=2500, /datum/material/plastic=3000)
	volume = 120
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,60,120)
	label_icon = "label_beakerlarge"

/obj/item/reagent_containers/cup/beaker/meta
	name = "metamaterial beaker"
	desc = "A large beaker. Can hold up to 180 units."
	icon_state = "beakergold"
	custom_materials = list(/datum/material/glass=2500, /datum/material/plastic=3000, /datum/material/gold=1000, /datum/material/titanium=1000)
	volume = 180
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,60,120,180)
	fill_icon_thresholds = list(1, 10, 25, 35, 50, 60, 80, 100)
	label_icon = "label_beakerlarge"

/obj/item/reagent_containers/cup/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without \
		reactions. Can hold up to 50 units."
	icon_state = "beakernoreact"
	custom_materials = list(/datum/material/iron=3000)
	initial_reagent_flags = OPENCONTAINER | NO_REACT
	volume = 50
	amount_per_transfer_from_this = 10
	fill_icon_state = null
	fill_icon_thresholds = null
	label_icon = null

/obj/item/reagent_containers/cup/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology \
		and Element Cuban combined with the Compound Pete. Can hold up to \
		300 units."
	icon_state = "beakerbluespace"
	custom_materials = list(/datum/material/glass = 5000, /datum/material/plasma = 3000, /datum/material/diamond = 1000, /datum/material/bluespace = 1000)
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100,300)
	fill_icon_state = null
	fill_icon_thresholds = null
	label_icon = "label_beakerlarge"

/obj/item/reagent_containers/cup/beaker/cryoxadone
	list_reagents = list(/datum/reagent/medicine/cryoxadone = 30)

/obj/item/reagent_containers/cup/beaker/meta/omnizine
	list_reagents = list(/datum/reagent/medicine/omnizine = 180)

/obj/item/reagent_containers/cup/beaker/meta/sal_acid
	list_reagents = list(/datum/reagent/medicine/sal_acid = 180)

/obj/item/reagent_containers/cup/beaker/meta/oxandrolone
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 180)

/obj/item/reagent_containers/cup/beaker/meta/pen_acid
	list_reagents = list(/datum/reagent/medicine/pen_acid = 180)

/obj/item/reagent_containers/cup/beaker/meta/atropine
	list_reagents = list(/datum/reagent/medicine/atropine = 180)

/obj/item/reagent_containers/cup/beaker/stabilizing_nanites
	list_reagents = list(/datum/reagent/medicine/stabilizing_nanites = 50)

/obj/item/reagent_containers/cup/beaker/meta/rezadone
	list_reagents = list(/datum/reagent/medicine/rezadone = 180)

/obj/item/reagent_containers/cup/beaker/sulfuric
	list_reagents = list(/datum/reagent/toxin/acid = 50)

/obj/item/reagent_containers/cup/beaker/slime
	list_reagents = list(/datum/reagent/toxin/slimejelly = 50)

/obj/item/reagent_containers/cup/beaker/large/styptic
	name = "styptic reserve tank"
	list_reagents = list(/datum/reagent/medicine/styptic_powder = 50)

/obj/item/reagent_containers/cup/beaker/large/silver_sulfadiazine
	name = "silver sulfadiazine reserve tank"
	list_reagents = list(/datum/reagent/medicine/silver_sulfadiazine = 50)

/obj/item/reagent_containers/cup/beaker/large/charcoal
	name = "charcoal reserve tank"
	list_reagents = list(/datum/reagent/medicine/charcoal = 50)

/obj/item/reagent_containers/cup/beaker/large/epinephrine
	name = "epinephrine reserve tank"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 50)

/obj/item/reagent_containers/cup/beaker/large/kelobic
	name = "kelotane-bicaridine reserve tank"
	list_reagents = list(/datum/reagent/medicine/kelotane = 50, /datum/reagent/medicine/bicaridine = 50)

/obj/item/reagent_containers/cup/beaker/synthflesh
	list_reagents = list(/datum/reagent/medicine/synthflesh = 50)

/obj/item/reagent_containers/cup/beaker/large/nanites
	name = "suspicious nanite reserve tank"
	list_reagents = list(/datum/reagent/medicine/leporazine = 30, /datum/reagent/medicine/syndicate_nanites = 40, /datum/reagent/medicine/stabilizing_nanites = 30)

/obj/item/reagent_containers/cup/bucket
	name = "bucket"
	desc = "It's a bucket."
	icon = 'icons/obj/janitor.dmi'
	worn_icon = 'icons/mob/clothing/head/utility.dmi'
	icon_state = "bucket"
	inhand_icon_state = "bucket"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	custom_materials = list(/datum/material/iron=200)
	w_class = WEIGHT_CLASS_NORMAL
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(5,10,15,20,25,30,50,70)
	volume = 70
	flags_inv = HIDEHAIR
	slot_flags = ITEM_SLOT_HEAD
	resistance_flags = NONE
	armor_type = /datum/armor/cup_bucket
	slot_equipment_priority = list(
		ITEM_SLOT_BACK, ITEM_SLOT_ID,
		ITEM_SLOT_ICLOTHING, ITEM_SLOT_OCLOTHING,
		ITEM_SLOT_MASK, ITEM_SLOT_HEAD, ITEM_SLOT_NECK,
		ITEM_SLOT_FEET, ITEM_SLOT_GLOVES,
		ITEM_SLOT_EARS, ITEM_SLOT_EYES,
		ITEM_SLOT_BELT, ITEM_SLOT_SUITSTORE,
		ITEM_SLOT_LPOCKET, ITEM_SLOT_RPOCKET,
		ITEM_SLOT_DEX_STORAGE
	)

/datum/armor/cup_bucket
	melee = 10
	fire = 75
	acid = 50

/obj/item/reagent_containers/cup/bucket/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/mop))
		if(reagents.total_volume < 1)
			user.balloon_alert(user, "empty!")
			return ITEM_INTERACT_BLOCKING
		reagents.trans_to(tool, 5, transfered_by = user)
		user.balloon_alert(user, "doused [tool]")
		playsound(src, 'sound/effects/slosh.ogg', 25, TRUE)
		return ITEM_INTERACT_SUCCESS
	if(isprox(tool)) //This works with wooden buckets for now. Somewhat unintended, but maybe someone will add sprites for it soon(TM)
		to_chat(user, span_notice("You add [tool] to [src]."))
		qdel(tool)
		var/obj/item/bot_assembly/cleanbot/new_cleanbot_ass = new()
		user.put_in_hands(new_cleanbot_ass)
		return ITEM_INTERACT_SUCCESS

	return ..()

/obj/item/reagent_containers/cup/bucket/equipped(mob/user, slot)
	. = ..()
	if (slot & ITEM_SLOT_HEAD)
		if(reagents.total_volume)
			to_chat(user, span_userdanger("[src]'s contents spill all over you!"))
			reagents.expose(user, TOUCH)
			reagents.clear_reagents()
		update_container_flags(NONE)

/obj/item/reagent_containers/cup/bucket/dropped(mob/user)
	. = ..()
	reset_container_flags()

/obj/item/reagent_containers/cup/bucket/equip_to_best_slot(mob/M)
	if(reagents.total_volume) //If there is water in a bucket, don't quick equip it to the head
		var/index = slot_equipment_priority.Find(ITEM_SLOT_HEAD)
		slot_equipment_priority.Remove(ITEM_SLOT_HEAD)
		. = ..()
		slot_equipment_priority.Insert(index, ITEM_SLOT_HEAD)
		return
	return ..()

/obj/item/pestle
	name = "pestle"
	desc = "An ancient, simple tool used in conjunction with a mortar to grind or juice items."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pestle"
	force = 7

/obj/item/reagent_containers/cup/mortar
	name = "mortar"
	desc = "A specially formed bowl of ancient design. It is possible to crush or juice items placed in it using a pestle; however the process, unlike modern methods, is slow and physically exhausting."
	desc_controls = "Alt click to eject the item."
	icon_state = "mortar"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50, 100)
	volume = 100
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT)
	initial_reagent_flags = OPENCONTAINER
	var/obj/item/grinded

/obj/item/reagent_containers/cup/mortar/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(grinded)
		grinded.forceMove(drop_location())
		grinded = null
		to_chat(user, "You eject the item inside.")

/obj/item/reagent_containers/cup/mortar/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return

	if(istype(tool, /obj/item/pestle))
		if(!grinded)
			to_chat(user, span_warning("There is nothing to grind!"))
			return ITEM_INTERACT_BLOCKING
		if(user.getStaminaLoss() > 50)
			to_chat(user, span_warning("You are too tired to work!"))
			return ITEM_INTERACT_BLOCKING

		to_chat(user, span_notice("You start grinding..."))
		if(!do_after(user, 2.5 SECONDS, target = src))
			return ITEM_INTERACT_BLOCKING

		user.adjustStaminaLoss(40)

		//food and pills
		grinded.reagents?.trans_to(src, grinded.reagents.total_volume, transfered_by = user)
		if(grinded.juice_typepath) //prioritize juicing
			grinded.on_juice()
			reagents.add_reagent_list(grinded.juice_typepath)
			to_chat(user, span_notice("You juice [grinded] into a fine liquid."))
		else
			grinded.on_grind()
			reagents.add_reagent_list(grinded.grind_results)
			to_chat(user, span_notice("You break [grinded] into powder."))

		QDEL_NULL(grinded)
		return ITEM_INTERACT_SUCCESS

	if(grinded)
		to_chat(user, span_warning("There is something inside already!"))
		return ITEM_INTERACT_BLOCKING

	if(istype(tool, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/cup = tool
		if(cup.prevent_grinding)
			to_chat(user, span_danger("You can't grind this!"))
			return ITEM_INTERACT_BLOCKING

	if((length(tool.grind_results) || tool.reagents?.total_volume || tool.is_grindable()) && user.transferItemToLoc(tool, src))
		grinded = tool
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/reagent_containers/cup/saline
	name = "saline canister"
	volume = 5000
	list_reagents = list(/datum/reagent/medicine/salglu_solution = 5000)

/obj/item/reagent_containers/cup/saline/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	if (loc && !istype(loc, /obj/machinery/iv_drip/saline))
		qdel(src)
		return
	return ..()

//A cup made from coconuts harvested in botany
/obj/item/reagent_containers/cup/coconutcup
	name = "coconut cup"
	desc = "A showy form of cup typically intended for both use and display."
	icon = 'icons/obj/drinks/drinks.dmi'
	icon_state = "coconutcup_empty"
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50, 100)
	volume = 50
	resistance_flags = ACID_PROOF
	obj_flags = UNIQUE_RENAME
	drop_sound = 'sound/items/handling/drinkglass_drop.ogg'
	pickup_sound =  'sound/items/handling/drinkglass_pickup.ogg'

/obj/item/reagent_containers/cup/coconutcup/on_reagent_change(changetype)
	if (reagents && reagents.total_volume > 0)
		icon_state = "coconutcup_full"
	else
		icon_state = "coconutcup_empty"

