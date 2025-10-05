/*	Pens!
 *	Contains:
 *		Pens
 *		Sleepy Pens
 *		Parapens
 *		Edaggers
 *		Screwdriver pen
 */


/*
 * Pens
 */
/obj/item/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	worn_icon_state = "pen"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_EARS
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	item_flags = ISWEAPON
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=10)
	pressure_resistance = 2
	grind_results = list(/datum/reagent/iron = 2, /datum/reagent/iodine = 1)
	var/colour = "black"	//what colour the ink is!
	var/degrees = 0
	var/font = PEN_FONT

/obj/item/pen/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is scribbling numbers all over [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit sudoku..."))
	return BRUTELOSS

/obj/item/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"
	throw_speed = 4 // red ones go faster (in this case, fast enough to embed!)

/obj/item/pen/invisible
	desc = "It's an invisible pen marker."
	icon_state = "pen"
	colour = "white"

/obj/item/pen/fourcolor
	desc = "It's a fancy four-color ink pen, set to black."
	name = "four-color pen"
	colour = "black"

/obj/item/pen/fourcolor/attack_self(mob/living/carbon/user)
	switch(colour)
		if("black")
			colour = "red"
			throw_speed++
		if("red")
			colour = "green"
			throw_speed = initial(throw_speed)
		if("green")
			colour = "blue"
		else
			colour = "black"
	to_chat(user, span_notice("\The [src] will now write in [colour]."))
	desc = "It's a fancy four-color ink pen, set to [colour]."

/obj/item/pen/fountain
	name = "fountain pen"
	desc = "It's a common fountain pen, with a faux wood body."
	icon_state = "pen-fountain"
	font = FOUNTAIN_PEN_FONT

/obj/item/pen/brush
	name = "calligraphy brush"
	desc = "A traditional brush usually used for calligraphy and poems."
	icon_state = "pen-brush"
	font = BRUSH_PEN_FONT

/obj/item/pen/charcoal
	name = "charcoal stylus"
	desc = "It's just a wooden stick with some compressed ash on the end. At least it can write."
	icon_state = "pen-charcoal"
	colour = "dimgray"
	font = CHARCOAL_FONT
	custom_materials = null

/obj/item/pen/fountain/captain
	name = "captain's fountain pen"
	desc = "It's an expensive Oak fountain pen. The nib is quite sharp."
	icon_state = "pen-fountain-o"
	force = 5
	throwforce = 5
	throw_speed = 4
	colour = "crimson"
	custom_materials = list(/datum/material/gold = 750)
	sharpness = SHARP
	bleed_force = BLEED_SURFACE
	resistance_flags = FIRE_PROOF
	unique_reskin_icon = list("Oak" = "pen-fountain-o",
						"Gold" = "pen-fountain-g",
						"Rosewood" = "pen-fountain-r",
						"Black and Silver" = "pen-fountain-b",
						"Command Blue" = "pen-fountain-cb"
						)
	embedding = list("embed_chance" = 75, "armour_block" = 40)

/obj/item/pen/fountain/captain/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 200, 115) //the pen is mightier than the sword

/obj/item/pen/fountain/captain/reskin_obj(mob/M)
	if(isnull(unique_reskin))
		unique_reskin = list(
			"Oak" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "pen-fountain-o"),
			"Gold" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "pen-fountain-g"),
			"Rosewood" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "pen-fountain-r"),
			"Black and Silver" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "pen-fountain-b"),
			"Command Blue" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "pen-fountain-cb")
		)
	if(current_skin)
		desc = "It's an expensive [current_skin] fountain pen. The nib is quite sharp."
	. = ..()

/obj/item/pen/attack_self(mob/living/carbon/user)
	. = ..()
	if(.)
		return

	var/deg = tgui_input_number(user, "What angle would you like to rotate the pen head to? (1-360)", "Rotate Pen Head", 0, 360, 0)
	degrees = deg
	to_chat(user, span_notice("You rotate the top of the pen to [degrees] degrees."))
	SEND_SIGNAL(src, COMSIG_PEN_ROTATED, deg, user)

/obj/item/pen/attack(mob/living/M, mob/user,stealth)
	if(!istype(M))
		return

	if(!force)
		if(M.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))
			to_chat(user, span_warning("You stab [M] with the pen."))
			if(!stealth)
				to_chat(M, span_danger("You feel a tiny prick!"))
			. = 1

		log_combat(user, M, "stabbed", src)

	else
		. = ..()

/obj/item/pen/afterattack(obj/O, mob/living/user, proximity)
	. = ..()
	//Changing Name/Description of items. Only works if they have the 'unique_rename' flag set
	if(isobj(O) && proximity && (O.obj_flags & UNIQUE_RENAME))
		var/penchoice = tgui_input_list(user, "What would you like to edit?", "Rename or change description?", list("Rename","Change description"))
		if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
			return
		var/anythingchanged = FALSE
		if(penchoice == "Rename")
			var/input = tgui_input_text(user,"What do you want to name [O]?", "", O.name, MAX_NAME_LEN)
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			if(!input) // empty input so we return
				to_chat(user, span_warning("You need to enter a name!"))
				return
			if(CHAT_FILTER_CHECK(input)) // check for forbidden words
				to_chat(user, span_warning("Your message contains forbidden words."))
				return
			if(O.name == input)
				to_chat(user, "You changed [O] to... well... [O].")
				return
			to_chat(user, capitalize("[O] has been successfully been renamed to [input]."))
			O.name = input
			O.renamedByPlayer = TRUE
			anythingchanged = TRUE
		if(penchoice == "Change description") // we'll allow empty descriptions
			var/input = tgui_input_text(user, "Describe [O] here", "", O.desc) // max_lenght to the default MAX_MESSAGE_LEN, what's the worst that could happen?
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			if(CHAT_FILTER_CHECK(input)) // check for forbidden words
				to_chat(user, span_warning("Your message contains forbidden words."))
				return
			O.desc = input
			to_chat(user, "You have successfully changed \the [O.name]'s description.")
			anythingchanged = TRUE
		if(anythingchanged)
			O.update_icon()

/obj/item/pen/get_writing_implement_details()
	return list(
		interaction_mode = MODE_WRITING,
		font = font,
		color = colour,
		use_bold = FALSE,
	)

/*
 * Sleepypens
 */

/obj/item/pen/paralytic

/obj/item/pen/paralytic/attack(mob/living/M, mob/user)
	if(!istype(M))
		return

	if(reagents?.total_volume && M.reagents)
		// Obvious message to other people, so that they can call out suspicious activity.
		to_chat(user, span_notice("You prepare to engage the sleepy pen's internal mechanism!"))
		if (!do_after(user, 1 SECONDS, M) || !..())
			to_chat(user, span_warning("You fail to engage the sleepy pen mechanism!"))
			return
		reagents.trans_to(M, reagents.total_volume, transfered_by = user, method = INJECT)
		user.visible_message(span_warning("[user] stabs [M] with [src]!"), span_notice("You successfully inject [M] with the pen's contents!"), vision_distance = COMBAT_MESSAGE_RANGE, ignored_mobs = list(M))
		to_chat(M, span_danger("You feel a tiny prick!"))
	else
		return ..()

/obj/item/pen/paralytic/Initialize(mapload)
	. = ..()
	create_reagents(45, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/toxin/curare, 20)
	reagents.add_reagent(/datum/reagent/toxin/whispertoxin, 15)
	reagents.add_reagent(/datum/reagent/toxin/staminatoxin, 10)

/*
 * (Alan) Edaggers
 */
/obj/item/pen/edagger
	attack_verb_continuous = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts") //these won't show up if the pen is off
	attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP
	/// The real name of our item when extended.
	var/hidden_name = "energy dagger"

/obj/item/pen/edagger/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, _speed = 6 SECONDS, _butcher_sound = 'sound/weapons/blade1.ogg')
	AddComponent(/datum/component/transforming, \
		force_on = 18, \
		throwforce_on = 35, \
		throw_speed_on = 4, \
		bleedforce_on = BLEED_CUT, \
		sharpness_on = SHARP_DISMEMBER, \
		w_class_on = WEIGHT_CLASS_NORMAL, \
		inhand_icon_change = FALSE, \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/pen/edagger/suicide_act(mob/living/user)
	if(HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		user.visible_message(span_suicide("[user] forcefully rams the pen into their mouth!"))
	else
		user.visible_message(span_suicide("[user] is holding a pen up to their mouth! It looks like [user.p_theyre()] trying to commit suicide!"))
		attack_self(user)
	return BRUTELOSS

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Handles swapping their icon files to edagger related icon files -
 * as they're supposed to look like a normal pen.
 */
/obj/item/pen/edagger/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(active)
		name = hidden_name
		icon_state = "edagger"
		item_state = "edagger"
		lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
		righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
		embedding = list(embed_chance = 100) // Rule of cool
	else
		name = initial(name)
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		lefthand_file = initial(lefthand_file)
		righthand_file = initial(righthand_file)
		embedding = list(embed_chance = EMBED_CHANCE)

	updateEmbedding()
	if(user)
		balloon_alert(user, "[hidden_name] [active ? "active" : "concealed"]")
	playsound(src, active ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 5, TRUE)
	set_light_on(active)
	return COMPONENT_NO_DEFAULT_MESSAGE


/*
 * Screwdriver Pen
 */

/obj/item/pen/screwdriver
	desc = "A pen with an extendable screwdriver tip. This one has a yellow cap."
	icon_state = "pendriver"
	toolspeed = 1.2  // gotta have some downside

/obj/item/pen/screwdriver/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/transforming, \
		throwforce_on = 5, \
		w_class_on = WEIGHT_CLASS_SMALL, \
		sharpness_on = TRUE, \
		inhand_icon_change = FALSE, \
	)

	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(toggle_screwdriver))
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/pen/screwdriver/proc/toggle_screwdriver(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(user)
		balloon_alert(user, active ? "extended" : "retracted")
	playsound(src, 'sound/weapons/batonextend.ogg', 50, TRUE)

	if(!active)
		tool_behaviour = initial(tool_behaviour)
	else
		tool_behaviour = TOOL_SCREWDRIVER

	update_appearance(UPDATE_ICON)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/pen/screwdriver/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) ? "out" : null]"
	item_state = initial(item_state) //since transforming component switches the icon.
