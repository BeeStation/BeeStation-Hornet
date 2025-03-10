//Dogs.

/mob/living/basic/pet/dog
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	speak_emote = list("barks", "woofs")
	faction = list(FACTION_NEUTRAL)
	see_in_dark = 5
	ai_controller = /datum/ai_controller/dog
	can_be_held = TRUE
	chat_color = "#ECDA88"
	mobchatspan = "corgi"

/mob/living/basic/pet/dog/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "woofs happily!")
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	var/dog_area = get_area(src)
	for(var/obj/structure/bed/dogbed/D in dog_area)
		if(D.update_owner(src)) //No muscling in on my turf you fucking parrot
			break

/mob/living/basic/pet/dog/proc/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speak = string_list(list("YAP", "Woof!", "Bark!", "AUUUUUU"))
	speech.emote_hear = string_list(list("barks!", "woofs!", "yaps.","pants."))
	speech.emote_see = string_list(list("shakes [p_their()] head.", "chases [p_their()] tail.","shivers."))

/mob/living/basic/pet/dog/corgi/Ian/Life()
	if(!stat && SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory(FALSE)
		memory_saved = TRUE
	..()

/mob/living/basic/pet/dog/corgi/Ian/death()
	if(!memory_saved)
		Write_Memory(TRUE)
	..()

//Corgis and pugs are now under one dog subtype

/mob/living/basic/pet/dog/corgi
	name = "\improper corgi"
	real_name = "corgi"
	desc = "It's a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	butcher_results = list(/obj/item/food/meat/slab/corgi = 3, /obj/item/stack/sheet/animalhide/corgi = 1)
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_icon_state = "corgi"
	ai_controller = /datum/ai_controller/dog/corgi
	held_state = "corgi"
	var/obj/item/inventory_head
	var/obj/item/inventory_back
	/// Access card for Ian.
	var/obj/item/card/id/access_card = null
	worn_slot_flags = ITEM_SLOT_HEAD
	var/shaved = FALSE
	var/nofur = FALSE 		//Corgis that have risen past the material plane of existence.
	/// Is this corgi physically slow due to age, etc?
	var/is_slow = FALSE

/mob/living/basic/pet/dog/corgi/Destroy()
	QDEL_NULL(inventory_head)
	QDEL_NULL(inventory_back)
	QDEL_NULL(access_card)
	return ..()

/mob/living/basic/pet/dog/corgi/handle_atom_del(atom/A)
	if(A == inventory_head)
		inventory_head = null
		update_corgi_fluff()
		regenerate_icons()
	if(A == inventory_back)
		inventory_back = null
		update_corgi_fluff()
		regenerate_icons()
	return ..()

/mob/living/basic/pet/dog/pug
	name = "\improper pug"
	real_name = "pug"
	desc = "It's a pug."
	icon = 'icons/mob/pets.dmi'
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	butcher_results = list(/obj/item/food/meat/slab/pug = 3)
	gold_core_spawnable = FRIENDLY_SPAWN
	worn_slot_flags = ITEM_SLOT_HEAD
	collar_icon_state = "pug"
	held_state = "pug"

/mob/living/basic/pet/dog/bullterrier
	name = "\improper bull terrier"
	real_name = "bull terrier"
	desc = "It's a bull terrier."
	icon = 'icons/mob/pets.dmi'
	icon_state = "bullterrier"
	icon_living = "bullterrier"
	icon_dead = "bullterrier_dead"
	butcher_results = list(/obj/item/food/meat/slab/corgi = 3) // Would feel redundant to add more new dog meats.
	gold_core_spawnable = FRIENDLY_SPAWN
	worn_slot_flags = ITEM_SLOT_HEAD //by popular demand
	collar_icon_state = "bullterrier"
	held_state = "bullterrier"
	head_icon = 'icons/mob/pets_held_large.dmi'

/mob/living/basic/pet/dog/bullterrier/walter
	name = "Walter"
	real_name = "Walter"
	gender = MALE
	desc = "Nar'sie and rat'var are nothing compared to the might of this monstertruck loving dog."
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/dog/bullterrier/walter/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speak = string_list(list("barks!", "woofs!", "Walter", "firetrucks", "monstertrucks"))
	speech.emote_hear = string_list(list("barks!", "woofs!", "yaps.","pants."))
	speech.emote_see = string_list(list("shakes [p_their()] head.", "chases [p_their()] tail.","shivers."))

/mob/living/basic/pet/dog/corgi/exoticcorgi
	name = "Exotic Corgi"
	desc = "As cute as it is colorful!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "corgigrey"
	icon_living = "corgigrey"
	icon_dead = "corgigrey_dead"
	nofur = TRUE
	worn_slot_flags = null

/mob/living/basic/pet/dog/corgi/Initialize(mapload)
	. = ..()
	regenerate_icons()
	AddElement(/datum/element/strippable, GLOB.strippable_corgi_items)

/**
 * Handler for COMSIG_MOB_TRIED_ACCESS
 */
/mob/living/basic/pet/dog/corgi/proc/on_tried_access(mob/accessor, obj/locked_thing)
	SIGNAL_HANDLER

	return locked_thing?.check_access(access_card) ? ACCESS_ALLOWED : ACCESS_DISALLOWED

/mob/living/basic/pet/dog/corgi/exoticcorgi/Initialize(mapload)
		. = ..()
		var/newcolor = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
		add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)

/mob/living/basic/pet/dog/corgi/death(gibbed)
	..(gibbed)
	regenerate_icons()

GLOBAL_LIST_INIT(strippable_corgi_items, create_strippable_list(list(
	/datum/strippable_item/corgi_head,
	/datum/strippable_item/corgi_back,
	/datum/strippable_item/pet_collar
)))

/datum/strippable_item/corgi_head
	key = STRIPPABLE_ITEM_HEAD

/datum/strippable_item/corgi_head/get_item(atom/source)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if(!istype(corgi_source))
		return
	return corgi_source.inventory_head


/datum/strippable_item/corgi_head/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if(!istype(corgi_source))
		return

	corgi_source.place_on_head(equipping, user)

/datum/strippable_item/corgi_head/finish_unequip(atom/source, mob/user)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if(!istype(corgi_source))
		return

	user.put_in_hands(corgi_source.inventory_head)
	corgi_source.inventory_head = null
	corgi_source.update_corgi_fluff()
	corgi_source.regenerate_icons()

/datum/strippable_item/corgi_back
	key = STRIPPABLE_ITEM_BACK

/datum/strippable_item/corgi_back/get_item(atom/source)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if(!istype(corgi_source))
		return

	return corgi_source.inventory_back

/datum/strippable_item/corgi_back/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!ispath(equipping.dog_fashion, /datum/dog_fashion/back))
		to_chat(user, span_warning("You set [equipping] on [source]'s back, but it falls off!"))
		equipping.forceMove(source.drop_location())
		if(prob(25))
			step_rand(equipping)
		var/mob/M = source
		M.emote("spin")

		return FALSE

	return TRUE

/datum/strippable_item/corgi_back/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if(!istype(corgi_source))
		return

	equipping.forceMove(corgi_source)
	corgi_source.inventory_back = equipping
	corgi_source.update_corgi_fluff()
	corgi_source.regenerate_icons()

/datum/strippable_item/corgi_back/finish_unequip(atom/source, mob/user)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if(!istype(corgi_source))
		return

	user.put_in_hands(corgi_source.inventory_back)
	corgi_source.inventory_back = null
	corgi_source.update_corgi_fluff()
	corgi_source.regenerate_icons()

/datum/strippable_item/pet_collar
	key = STRIPPABLE_ITEM_PET_COLLAR

/datum/strippable_item/pet_collar/get_item(atom/source)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if (!istype(corgi_source))
		return

	return corgi_source.collar

/datum/strippable_item/pet_collar/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if (!.)
		return FALSE

	if (!istype(equipping, /obj/item/clothing/neck/petcollar))
		to_chat(user, span_warning("That's not a collar."))
		return FALSE

	return TRUE

/datum/strippable_item/pet_collar/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if (!istype(corgi_source))
		return

	corgi_source.add_collar(equipping, user)

/datum/strippable_item/pet_collar/finish_unequip(atom/source, mob/user)
	var/mob/living/basic/pet/dog/corgi/corgi_source = source
	if (!istype(corgi_source))
		return

	var/obj/collar = corgi_source.remove_collar(user.drop_location())
	user.put_in_hands(collar)

	user.put_in_hands(corgi_source.collar)
	corgi_source.collar = null
	corgi_source.update_corgi_fluff()
	corgi_source.regenerate_icons()

/mob/living/basic/pet/dog/corgi/getarmor(def_zone, type, penetration)
	var/armorval = 1

	if(def_zone)
		if(def_zone == BODY_ZONE_HEAD)
			if(inventory_head)
				return ((1 - (inventory_head.get_armor_rating(type) / 100)) * (1 - penetration / 100)) * 100
		else
			if(inventory_back)
				return ((1 - (inventory_back.get_armor_rating(type) / 100)) * (1 - penetration / 100)) * 100
		return 0
	else
		if(inventory_head)
			armorval *= 1 - min((inventory_head.get_armor_rating(type) / 100) * (1 - penetration / 100), 1)
		if(inventory_back)
			armorval *= 1 - min((inventory_back.get_armor_rating(type) / 100) * (1 - penetration / 100), 1)
	return (1 - armorval) * 100

/mob/living/basic/pet/dog/corgi/attackby(obj/item/O, mob/user, params)
	if (istype(O, /obj/item/razor))
		if (shaved)
			to_chat(user, span_warning("You can't shave this corgi, it's already been shaved!"))
			return
		if (nofur)
			to_chat(user, span_warning(" You can't shave this corgi, it doesn't have a fur coat!"))
			return
		user.visible_message("[user] starts to shave [src] using \the [O].", span_notice("You start to shave [src] using \the [O]..."))
		if(do_after(user, 50, target = src))
			user.visible_message("[user] shaves [src]'s hair using \the [O].")
			playsound(loc, 'sound/items/welder2.ogg', 20, 1)
			shaved = TRUE
			icon_living = "[initial(icon_living)]_shaved"
			icon_dead = "[initial(icon_living)]_shaved_dead"
			if(stat == CONSCIOUS)
				icon_state = icon_living
			else
				icon_state = icon_dead
		return
	..()
	update_corgi_fluff()

//Corgis are supposed to be simpler, so only a select few objects can actually be put
//to be compatible with them. The objects are below.
//Many  hats added, Some will probably be removed, just want to see which ones are popular.
// > some will probably be removed

/mob/living/basic/pet/dog/corgi/proc/place_on_head(obj/item/item_to_add, mob/user, drop = TRUE)
	if(inventory_head)
		if(user)
			to_chat(user, span_warning("You can't put more than one hat on [src]!"))
		return
	if(!item_to_add)
		user.visible_message("[user] pets [src].",span_notice("You rest your hand on [src]'s head for a moment."))
		if(flags_1 & HOLOGRAM_1)
			return
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, src, /datum/mood_event/pet_animal, src)
		return

	if(user && !user.temporarilyRemoveItemFromInventory(item_to_add))
		to_chat(user, span_warning("\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s head!"))
		return 0

	var/valid = FALSE
	if(ispath(item_to_add.dog_fashion, /datum/dog_fashion/head))
		valid = TRUE

	//Various hats and items (worn on his head) change Ian's behaviour. His attributes are reset when a hat is removed.

	if(valid)
		if(health <= 0)
			to_chat(user, span_notice("There is merely a dull, lifeless look in [real_name]'s eyes as you put the [item_to_add] on [p_them()]."))
		else if(user)
			user.visible_message("[user] puts [item_to_add] on [real_name]'s head.  [src] looks at [user] and barks once.",
				span_notice("You put [item_to_add] on [real_name]'s head.  [src] gives you a peculiar look, then wags [p_their()] tail once and barks."),
				span_italics("You hear a friendly-sounding bark."))
		item_to_add.forceMove(src)
		src.inventory_head = item_to_add
		update_corgi_fluff()
		regenerate_icons()
	else
		to_chat(user, span_warning("You set [item_to_add] on [src]'s head, but it falls off!"))
		if (drop)
			item_to_add.forceMove(drop_location())
		if(prob(25))
			step_rand(item_to_add)
		INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "spin")

	return valid

/mob/living/basic/pet/dog/corgi/proc/update_corgi_fluff()
	// First, change back to defaults
	name = real_name
	desc = initial(desc)
	// BYOND/DM doesn't support the use of initial on lists.
	speak_emote = list("barks", "woofs")
	desc = initial(desc)
	set_light(0)

	if(inventory_head?.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_head.dog_fashion(src)
		DF.apply(src)

	if(inventory_back && inventory_back.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_back.dog_fashion(src)
		DF.apply(src)

//IAN! SQUEEEEEEEEE~
/mob/living/basic/pet/dog/corgi/Ian
	name = "Ian"
	real_name = "Ian"	//Intended to hold the name without altering it.
	gender = MALE
	desc = "It's the HoP's beloved corgi."
	var/obj/movement_target
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	var/age = 0
	var/record_age = 1
	var/memory_saved = FALSE
	var/saved_head //path
	worn_slot_flags = ITEM_SLOT_HEAD


/mob/living/basic/pet/dog/corgi/Ian/Initialize(mapload)
	. = ..()
	//parent call must happen first to ensure IAN
	//is not in nullspace when child puppies spawn
	Read_Memory()
	if(age == 0)
		var/turf/target = get_turf(loc)
		if(target)
			new /mob/living/basic/pet/dog/corgi/puppy/Ian(target)
			Write_Memory(FALSE)
			return INITIALIZE_HINT_QDEL
	else if(age == record_age)
		icon_state = "old_corgi"
		icon_living = "old_corgi"
		icon_dead = "old_corgi_dead"
		desc = "At a ripe old age of [record_age], Ian's not as spry as he used to be, but he'll always be the HoP's beloved corgi." //RIP
		held_state = "old_corgi"
		ai_controller?.blackboard[BB_DOG_IS_SLOW] = TRUE
		is_slow = TRUE

/mob/living/basic/pet/dog/corgi/Ian/proc/Read_Memory()
	if(fexists("data/npc_saves/Ian.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/Ian.sav")
		S["age"] 		>> age
		S["record_age"]	>> record_age
		S["saved_head"] >> saved_head
		fdel("data/npc_saves/Ian.sav")
	else
		var/json_file = file("data/npc_saves/Ian.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(rustg_file_read(json_file))
		age = json["age"]
		record_age = json["record_age"]
		saved_head = json["saved_head"]
	if(isnull(age))
		age = 0
	if(isnull(record_age))
		record_age = 1
	if(saved_head)
		place_on_head(new saved_head)

/mob/living/basic/pet/dog/corgi/Ian/proc/Write_Memory(dead)
	var/json_file = file("data/npc_saves/Ian.json")
	var/list/file_data = list()
	if(!dead)
		file_data["age"] = age + 1
		if((age + 1) > record_age)
			file_data["record_age"] = record_age + 1
		else
			file_data["record_age"] = record_age
		if(inventory_head)
			file_data["saved_head"] = inventory_head.type
		else
			file_data["saved_head"] = null
	else
		file_data["age"] = 0
		file_data["record_age"] = record_age
		file_data["saved_head"] = null
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/mob/living/basic/pet/dog/corgi/Ian/narsie_act()
	playsound(src, 'sound/magic/demon_dies.ogg', 75, TRUE)
	var/mob/living/basic/pet/dog/corgi/narsie/N = new(loc)
	N.setDir(dir)
	investigate_log("has been gibbed by Nar'Sie.", INVESTIGATE_DEATHS)
	gib()

/mob/living/basic/pet/dog/corgi/narsie
	name = "Nars-Ian"
	desc = "Ia! Ia!"
	icon_state = "narsian"
	icon_living = "narsian"
	icon_dead = "narsian_dead"
	faction = list(FACTION_NEUTRAL, FACTION_CULT)
	gold_core_spawnable = NO_SPAWN
	nofur = TRUE
	unique_pet = TRUE
	held_state = "narsian"
	worn_slot_flags = null

/mob/living/basic/pet/dog/corgi/narsie/Life()
	..()
	for(var/mob/living/basic/pet/P in ohearers(1, src))
		if(!istype(P,/mob/living/basic/pet/dog/corgi/narsie))
			visible_message(span_warning("[src] devours [P]!"), \
			span_cultbigbold("DELICIOUS SOULS"))
			playsound(src, 'sound/magic/demon_attack1.ogg', 75, TRUE)
			narsie_act()
			if(P.mind)
				if(P.mind.hasSoul)
					P.mind.hasSoul = FALSE //Nars-Ian ate your soul; you don't have one anymore
				else
					visible_message(span_cultbigbold("... Aw, someone beat me to this one."))
			P.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
			P.gib()

/mob/living/basic/pet/dog/corgi/narsie/update_corgi_fluff()
	..()
	speak_emote = list("growls", "barks ominously")

/mob/living/basic/pet/dog/corgi/narsie/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speak = string_list(list("Tari'karat-pasnar!", "IA! IA!", "BRRUUURGHGHRHR"))
	speech.emote_hear = string_list(list("barks echoingly!", "woofs hauntingly!", "yaps in an eldritch manner.", "mutters something unspeakable."))
	speech.emote_see = string_list(list("communes with the unnameable.", "ponders devouring some souls.", "shakes."))

/mob/living/basic/pet/dog/corgi/narsie/narsie_act()

/mob/living/basic/pet/dog/corgi/narsie/narsie_act()
	adjustBruteLoss(-maxHealth)


/mob/living/basic/pet/dog/corgi/regenerate_icons()
	..()
	cut_overlays() //we are redrawing the mob after all
	if(inventory_head)
		var/image/head_icon
		var/datum/dog_fashion/DF = new inventory_head.dog_fashion(src)

		if(!DF.obj_icon_state)
			DF.obj_icon_state = inventory_head.icon_state
		if(!DF.obj_alpha)
			DF.obj_alpha = inventory_head.alpha
		if(!DF.obj_color)
			DF.obj_color = inventory_head.color

		if(health <= 0)
			head_icon = DF.get_overlay(dir = EAST)
			head_icon.pixel_y = -8
			head_icon.transform = turn(head_icon.transform, 180)
		else
			head_icon = DF.get_overlay()

		add_overlay(head_icon)

	if(inventory_back)
		var/image/back_icon
		var/datum/dog_fashion/DF = new inventory_back.dog_fashion(src)

		if(!DF.obj_icon_state)
			DF.obj_icon_state = inventory_back.icon_state
		if(!DF.obj_alpha)
			DF.obj_alpha = inventory_back.alpha
		if(!DF.obj_color)
			DF.obj_color = inventory_back.color

		if(health <= 0)
			back_icon = DF.get_overlay(dir = EAST)
			back_icon.pixel_y = -11
			back_icon.transform = turn(back_icon.transform, 180)
		else
			back_icon = DF.get_overlay()
		add_overlay(back_icon)

	return



/mob/living/basic/pet/dog/corgi/puppy
	name = "\improper corgi puppy"
	real_name = "corgi"
	desc = "It's a corgi puppy!"
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	collar_icon_state = "puppy"
	worn_slot_flags = ITEM_SLOT_HEAD

//puppies cannot wear anything.
/mob/living/basic/pet/dog/corgi/puppy/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, span_warning("You can't fit this on [src]!"))
		return
	..()

/mob/living/basic/pet/dog/corgi/puppy/Ian
	name = "Ian"
	real_name = "Ian"
	gender = MALE
	desc = "It's the HoP's beloved corgi puppy."


/mob/living/basic/pet/dog/corgi/puppy/void		//Tribute to the corgis born in nullspace
	name = "\improper void puppy"
	real_name = "voidy"
	desc = "A corgi puppy that has been infused with deep space energy. It's staring back..."
	icon_state = "void_puppy"
	icon_living = "void_puppy"
	icon_dead = "void_puppy_dead"
	nofur = TRUE
	held_state = "void_puppy"
	worn_slot_flags = ITEM_SLOT_HEAD

/mob/living/basic/pet/dog/corgi/puppy/void/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_AI_BAGATTACK, INNATE_TRAIT)

/mob/living/basic/pet/dog/corgi/puppy/void/Process_Spacemove(movement_dir = 0)
	return 1	//Void puppies can navigate space.


//LISA! SQUEEEEEEEEE~
/mob/living/basic/pet/dog/corgi/Lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "She's tearing you apart."
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	held_state = "lisa"
	worn_slot_flags = ITEM_SLOT_HEAD
	var/puppies = 0

//Lisa already has a cute bow!
/mob/living/basic/pet/dog/corgi/Lisa/Topic(href, href_list)
	if(href_list["remove_inv"] || href_list["add_inv"])
		to_chat(usr, span_danger("[src] already has a cute bow!"))
		return
	..()

	if(!stat && !resting && !buckled)
		if(prob(1))
			INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "me", 1, pick("dances around.","chases her tail."))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					setDir(i)
					sleep(1)

/mob/living/basic/pet/dog/pug/Life()
	..()

	if(!stat && !resting && !buckled)
		if(prob(1))
			INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "me", 1, pick("chases its tail."))
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
					setDir(i)
					sleep(1)

/mob/living/basic/pet/dog/corgi/cardigan
	name = "\improper cardigan corgi"
	real_name = "Cardigan Welsh corgi"
	desc = "Ian's tailed cousin"
	icon_state = "cardigan_corgi"
	icon_living = "cardigan_corgi"
	icon_dead = "cardigan_corgi_dead"
	held_state = "cardigan_corgi"

/mob/living/basic/pet/dog/corgi/puppy/cardigan
	name = "\improper cardigan corgi puppy"
	real_name = "Cardigan Welsh corgi"
	desc = "It's a corgi puppy!"
	icon_state = "cardigan_puppy"
	icon_living = "cardigan_puppy"
	icon_dead = "cardigan_puppy_dead"
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	collar_icon_state = "puppy"
	worn_slot_flags = ITEM_SLOT_HEAD

/mob/living/basic/pet/dog/corgi/capybara
	name = "\improper capybara"
	real_name = "capybara"
	desc = "It's a capybara."
	icon_state = "capybara"
	icon_living = "capybara"
	icon_dead = "capybara_dead"
	held_state = null
	can_be_held = FALSE
	butcher_results = list()

/mob/living/basic/pet/dog/corgi/capybara/update_corgi_fluff()
	// First, change back to defaults
	name = real_name
	desc = initial(desc)
	// BYOND/DM doesn't support the use of initial on lists.
	speak_emote = list("barks", "squeaks")
	desc = initial(desc)
	set_light(0)

	if(inventory_head && inventory_head.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_head.dog_fashion(src)
		DF.apply(src)

	if(inventory_back && inventory_back.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_back.dog_fashion(src)
		DF.apply(src)

/mob/living/basic/pet/dog/corgi/capybara/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speak = string_list(list("Bark!", "Squee!", "Squee."))
	speech.emote_hear = string_list(list("barks!", "squees!", "squeaks!", "yaps.", "squeaks."))
	speech.emote_see = string_list(list("shakes its head.", "medidates on peace.", "looks to be in peace.", "shivers."))
