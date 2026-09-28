/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	anchored = TRUE
	max_integrity = 200
	integrity_failure = 0.5
	flags_ricochet = RICOCHET_SHINY
	layer = ABOVE_WINDOW_LAYER
	var/magical = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/mirror, 28)

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/mirror)

/obj/structure/mirror/Initialize(mapload, dir, building)
	. = ..()
	var/static/list/reflection_filter = alpha_mask_filter(icon = icon('icons/obj/watercloset.dmi', "mirror_mask"))
	var/static/matrix/reflection_matrix = matrix(0.75, 0, 0, 0, 0.75, 0)
	AddComponent(/datum/component/reflection, \
		reflection_filter = reflection_filter, \
		reflection_matrix = reflection_matrix, \
		can_reflect = CALLBACK(src, PROC_REF(can_reflect)), \
		update_signals = list(COMSIG_ATOM_BREAK), \
		check_reflect_signals = list(SIGNAL_ADDTRAIT(TRAIT_NO_MIRROR_REFLECTION), SIGNAL_REMOVETRAIT(TRAIT_NO_MIRROR_REFLECTION)), \
	)

/obj/structure/mirror/proc/can_reflect(atom/movable/target)
	// I'm doing it this way too, because the signal is sent before the broken variable is set to TRUE.
	if(atom_integrity <= integrity_failure * max_integrity || broken)
		return FALSE
	if(!isliving(target) || HAS_TRAIT(target, TRAIT_NO_MIRROR_REFLECTION))
		return FALSE
	return TRUE

/obj/structure/mirror/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(broken || !Adjacent(user) || !ishuman(user) || magical)
		return

	var/mob/living/carbon/human/human_user = user

	var/choice = tgui_input_list(user, "Style your Hair or Facial Hair?", "Grooming", list("Hair", "Facial"))
	switch(choice)
		if("Hair")
			//handle normal hair
			var/new_style = tgui_input_list(user, "Select a hair style", "Grooming", GLOB.hairstyles_list, human_user.hair_style)
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK) || !new_style)
				return //no tele-grooming
			human_user.set_hairstyle(new_style, update = TRUE)
		if("Facial")
			//handle facial hair
			var/new_style = tgui_input_list(user, "Select a facial hair style", "Grooming", GLOB.facial_hairstyles_list, human_user.facial_hairstyle)
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK) || !new_style)
				return //no tele-grooming
			human_user.set_facial_hairstyle(new_style, update = TRUE)

/obj/structure/mirror/atom_break(damage_flag)
	. = ..()
	if(broken)
		return
	icon_state = "mirror_broke"
	playsound(src, "shatter", 70, TRUE)
	if(desc == initial(desc))
		desc = "Oh no, seven years of bad luck!"
	broken = TRUE

/obj/structure/mirror/deconstruct(disassembled)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!disassembled)
			new /obj/item/shard(loc)
		else if(broken)
			new /obj/item/wallframe/mirror/broken(loc)
		else
			new /obj/item/wallframe/mirror(loc)
	return ..()

/obj/structure/mirror/welder_act(mob/living/user, obj/item/tool)
	if(!broken || !tool.tool_start_check(user, amount = 0))
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "repairing...")
	if(tool.use_tool(src, user, 10, volume = 50))
		balloon_alert(user, "repaired")
		broken = FALSE
		icon_state = initial(icon_state)
		desc = initial(desc)

	return ITEM_INTERACT_SUCCESS

/obj/structure/mirror/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
		if(BURN)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)

/obj/structure/mirror/broken
	desc = "Oh no, seven years of bad luck!"
	icon_state = "mirror_broke"
	broken = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/mirror/broken, 28)

/obj/structure/mirror/magic
	name = "magic mirror"
	desc = "Turn and face the strange... face."
	icon_state = "magic_mirror"
	magical = TRUE
	var/list/choosable_races

/obj/structure/mirror/magic/Initialize(mapload)
	. = ..()
	if(!islist(choosable_races))
		choosable_races = list()
		for(var/datum/species/species_type as anything in subtypesof(/datum/species))
			if(species_type::changesource_flags & MIRROR_MAGIC)
				choosable_races += species_type::id
	choosable_races = sort_list(choosable_races)

/obj/structure/mirror/magic/lesser/Initialize(mapload)
	var/list/selectable = get_selectable_species()
	choosable_races = selectable.Copy()
	return ..()

/obj/structure/mirror/magic/badmin/Initialize(mapload)
	for(var/datum/species/species_type as anything in subtypesof(/datum/species))
		if(species_type::changesource_flags & MIRROR_BADMIN)
			choosable_races += species_type::id
	return ..()

/obj/structure/mirror/magic/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	var/choice = input(user, "Something to change?", "Magical Grooming") as null|anything in list("name", "race", "gender", "hair", "eyes")

	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	switch(choice)
		if("name")
			var/newname = sanitize_name(stripped_input(H, "Who are we again?", "Name change", H.name, MAX_NAME_LEN), allow_numbers = TRUE) //It's magic so whatever.

			if(!newname)
				return
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			H.real_name = newname
			H.name = newname
			if(H.dna)
				H.dna.real_name = newname
			if(H.mind)
				H.mind.name = newname

		if("race")
			var/newrace
			var/racechoice = input(H, "What are we again?", "Race change") as null|anything in choosable_races
			newrace = GLOB.species_list[racechoice]

			if(!newrace)
				return
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			H.set_species(newrace, icon_update=0)

			if(HAS_TRAIT(H, TRAIT_USES_SKINTONES))
				var/new_s_tone = tgui_input_list(H, "Choose your skin tone", "Race change", GLOB.skin_tones)
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return

				if(new_s_tone)
					H.skin_tone = new_s_tone
					H.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)

			else if(HAS_TRAIT(H, TRAIT_MUTANT_COLORS) && !HAS_TRAIT(H, TRAIT_FIXED_MUTANT_COLORS))
				var/new_mutantcolor = tgui_color_picker(user, "Choose your skin color:", "Race change", H.dna.features["mcolor"])
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				if(new_mutantcolor)
					var/list/mutant_hsv = rgb2hsv(new_mutantcolor)

					if(mutant_hsv[3] >= 50) // mutantcolors must be bright
						H.dna.features["mcolor"] = sanitize_hexcolor(new_mutantcolor)
						H.dna.update_uf_block(DNA_MUTANT_COLOR_BLOCK)

					else
						to_chat(H, span_notice("Invalid color. Your color is not bright enough."))

			H.update_body(is_creating = TRUE)
			H.update_mutations_overlay() // no hulk lizard

		if("gender")
			if(!(H.gender in list("male", "female"))) //blame the patriarchy
				return
			if(H.gender == "male")
				if(alert(H, "Become a Witch?", "Confirmation", "Yes", "No") == "Yes")
					if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
						return
					H.gender = "female"
					to_chat(H, span_notice("Man, you feel like a woman!"))
				else
					return

			else
				if(alert(H, "Become a Warlock?", "Confirmation", "Yes", "No") == "Yes")
					if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
						return
					H.gender = "male"
					to_chat(H, span_notice("Whoa man, you feel like a man!"))
				else
					return
			H.dna.update_ui_block(DNA_GENDER_BLOCK)
			H.update_body()
			H.update_mutations_overlay() //(hulk male/female)

		if("hair")
			var/hairchoice = alert(H, "Hair style or hair color?", "Change Hair", "Style", "Color")
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(hairchoice == "Style") //So you just want to use a mirror then?
				var/new_style = tgui_input_list(user, "Select a hair style", "Hair Style", GLOB.hairstyles_list, H.hair_style)
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				if(new_style)
					H.hair_style = new_style
			else
				var/new_hair_color = tgui_color_picker(H, "Choose your hair color", "Hair Color", H.hair_color)
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				if(new_hair_color)
					H.hair_color = sanitize_hexcolor(new_hair_color)
					H.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
				if(H.gender == "male")
					var/new_face_color = tgui_color_picker(H, "Choose your facial hair color", "Hair Color", H.facial_hair_color)
					if(new_face_color)
						H.facial_hair_color = sanitize_hexcolor(new_face_color)
						H.dna.update_ui_block(DNA_FACIAL_HAIR_COLOR_BLOCK)
			H.update_body_parts()

		if(BODY_ZONE_PRECISE_EYES)
			var/new_eye_color = tgui_color_picker(H, "Choose your eye color", "Eye Color", H.eye_color_left)
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(new_eye_color)
				H.eye_color_left = sanitize_hexcolor(new_eye_color)
				H.eye_color_right = sanitize_hexcolor(new_eye_color)
				H.dna.update_ui_block(DNA_EYE_COLOR_LEFT_BLOCK)
				H.dna.update_ui_block(DNA_EYE_COLOR_RIGHT_BLOCK)
				H.update_body()
	if(choice)
		curse(user)

/obj/structure/mirror/magic/proc/curse(mob/living/user)
	return


//basically stolen from human_defense.dm
/obj/structure/mirror/bullet_act(obj/projectile/P)
	if(P.reflectable & REFLECT_NORMAL)
		if(P.starting)
			var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
			var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
			var/turf/current_location = get_turf(src)

			// redirect the projectile
			P.original = locate(new_x, new_y, P.z)
			P.starting = current_location
			P.firer = src
			P.yo = new_y - current_location.y
			P.xo = new_x - current_location.x
			var/new_angle_s = P.Angle + 180
			while(new_angle_s > 180)	// Translate to regular projectile degrees
				new_angle_s -= 360
			P.set_angle(new_angle_s)

	return BULLET_ACT_FORCE_PIERCE // complete projectile permutation

/obj/item/wallframe/mirror
	name = "mirror"
	desc = "An unmounted mirror. Attach it to a wall for use."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	custom_materials = list(/datum/material/glass = MINERAL_MATERIAL_AMOUNT * 5, /datum/material/silver = MINERAL_MATERIAL_AMOUNT * 2)
	result_path = /obj/structure/mirror
	pixel_shift = 28

/obj/item/wallframe/mirror/broken
	name = "broken mirror"
	desc = "An unmounted and broken mirror. Attach it to a wall for decor."
	icon_state = "mirror_broke"
	result_path = /obj/structure/mirror/broken
