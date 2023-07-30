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
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_EARS
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	item_flags = ISWEAPON
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/iron=10)
	pressure_resistance = 2
	grind_results = list(/datum/reagent/iron = 2, /datum/reagent/iodine = 1)
	var/colour = "black"	//what colour the ink is!
	var/degrees = 0
	var/font = PEN_FONT

/obj/item/pen/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is scribbling numbers all over [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit sudoku...</span>")
	return(BRUTELOSS)

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
	to_chat(user, "<span class='notice'>\The [src] will now write in [colour].</span>")
	desc = "It's a fancy four-color ink pen, set to [colour]."

/obj/item/pen/fountain
	name = "fountain pen"
	desc = "It's a common fountain pen, with a faux wood body."
	icon_state = "pen-fountain"
	font = FOUNTAIN_PEN_FONT

/obj/item/pen/charcoal
	name = "charcoal stylus"
	desc = "It's just a wooden stick with some compressed ash on the end. At least it can write."
	icon_state = "pen-charcoal"
	colour = "dimgray"
	font = CHARCOAL_FONT
	custom_materials = null

/datum/crafting_recipe/charcoal_stylus
	name = "Charcoal Stylus"
	result = /obj/item/pen/charcoal
	reqs = list(/obj/item/stack/sheet/wood = 1, /datum/reagent/ash = 30)
	time = 30
	category = CAT_PRIMAL


/obj/item/pen/fountain/captain
	name = "captain's fountain pen"
	desc = "It's an expensive Oak fountain pen. The nib is quite sharp."
	icon_state = "pen-fountain-o"
	force = 5
	throwforce = 5
	throw_speed = 4
	colour = "crimson"
	materials = list(/datum/material/gold = 750)
	sharpness = IS_SHARP
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
	var/deg = input(user, "What angle would you like to rotate the pen head to? (1-360)", "Rotate Pen Head") as null|num
	if(deg && (deg > 0 && deg <= 360))
		degrees = deg
		to_chat(user, "<span class='notice'>You rotate the top of the pen to [degrees] degrees.</span>")
		SEND_SIGNAL(src, COMSIG_PEN_ROTATED, deg, user)

/obj/item/pen/attack(mob/living/M, mob/user,stealth)
	if(!istype(M))
		return

	if(!force)
		if(M.can_inject(user, 1))
			to_chat(user, "<span class='warning'>You stab [M] with the pen.</span>")
			if(!stealth)
				to_chat(M, "<span class='danger'>You feel a tiny prick!</span>")
			. = 1

		log_combat(user, M, "stabbed", src)

	else
		. = ..()

/obj/item/pen/afterattack(obj/O, mob/living/user, proximity)
	. = ..()
	//Changing Name/Description of items. Only works if they have the 'unique_rename' flag set
	if(isobj(O) && proximity && (O.obj_flags & UNIQUE_RENAME))
		var/penchoice = input(user, "What would you like to edit?", "Rename or change description?") as null|anything in list("Rename","Change description")
		if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
			return
		if(penchoice == "Rename")
			var/input = stripped_input(user,"What do you want to name \the [O.name]?", ,"", MAX_NAME_LEN)
			var/oldname = O.name
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			if(oldname == input)
				to_chat(user, "You changed \the [O.name] to... well... \the [O.name].")
			else
				O.name = input
				to_chat(user, "\The [oldname] has been successfully been renamed to \the [input].")
				O.renamedByPlayer = TRUE

		if(penchoice == "Change description")
			var/input = stripped_input(user,"Describe \the [O.name] here", ,"", 100)
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			O.desc = input
			to_chat(user, "You have successfully changed \the [O.name]'s description.")

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

/obj/item/pen/sleepy

/obj/item/pen/sleepy/attack(mob/living/M, mob/user)
	if(!istype(M))
		return

	if(reagents?.total_volume && M.reagents)
		// Obvious message to other people, so that they can call out suspicious activity.
		to_chat(user, "<span class='notice'>You prepare to engage the sleepy pen's internal mechanism!</span>")
		if (!do_after(user, 0.5 SECONDS, M) || !..())
			to_chat(user, "<span class='warning'>You fail to engage the sleepy pen mechanism!</span>")
			return
		reagents.trans_to(M, reagents.total_volume, transfered_by = user, method = INJECT)
		user.visible_message("<span class='warning'>[user] stabs [M] with [src]!</span>", "<span class='notice'>You successfully inject [M] with the pen's contents!</span>", vision_distance = COMBAT_MESSAGE_RANGE, ignored_mobs = list(M))
		// Looks like a normal pen once it has been used
		qdel(reagents)
		reagents = null
	else
		return ..()

/obj/item/pen/sleepy/Initialize(mapload)
	. = ..()
	create_reagents(45, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/toxin/chloralhydrate, 20)
	reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 15)
	reagents.add_reagent(/datum/reagent/toxin/staminatoxin, 10)

/*
 * (Alan) Edaggers
 */
/obj/item/pen/edagger
	attack_verb = list("slashed", "stabbed", "sliced", "tore", "ripped", "diced", "cut") //these wont show up if the pen is off
	var/on = FALSE

/obj/item/pen/edagger/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 60, 100, 0, 'sound/weapons/blade1.ogg', TRUE)

/obj/item/pen/edagger/attack_self(mob/living/user)
	if(on)
		on = FALSE
		force = initial(force)
		throw_speed = initial(throw_speed)
		w_class = initial(w_class)
		name = initial(name)
		hitsound = initial(hitsound)
		embedding = list(embed_chance = EMBED_CHANCE, armour_block = 30)
		throwforce = initial(throwforce)
		playsound(user, 'sound/weapons/saberoff.ogg', 5, 1)
		to_chat(user, "<span class='warning'>[src] can now be concealed.</span>")
	else
		on = TRUE
		force = 18
		throw_speed = 4
		w_class = WEIGHT_CLASS_NORMAL
		name = "energy dagger"
		hitsound = 'sound/weapons/blade1.ogg'
		embedding = list(embed_chance = 200, max_damage_mult = 15, armour_block = 40) //rule of cool
		throwforce = 35
		playsound(user, 'sound/weapons/saberon.ogg', 5, 1)
		to_chat(user, "<span class='warning'>[src] is now active.</span>")
	updateEmbedding()
	var/datum/component/butchering/butchering = src.GetComponent(/datum/component/butchering)
	butchering.butchering_enabled = on
	update_icon()

/obj/item/pen/edagger/update_icon()
	if(on)
		icon_state = "edagger"
		item_state = "edagger"
		lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
		righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	else
		icon_state = initial(icon_state) //looks like a normal pen when off.
		item_state = initial(item_state)
		lefthand_file = initial(lefthand_file)
		righthand_file = initial(righthand_file)


/*
 * Screwdriver Pen
 */

/obj/item/pen/screwdriver
	var/extended = FALSE
	desc = "A pen with an extendable screwdriver tip. This one has a yellow cap."
	icon_state = "pendriver"
	toolspeed = 1.20  // gotta have some downside

/obj/item/pen/screwdriver/attack_self(mob/living/user)
	if(extended)
		extended = FALSE
		w_class = initial(w_class)
		tool_behaviour = initial(tool_behaviour)
		force = initial(force)
		throwforce = initial(throwforce)
		throw_speed = initial(throw_speed)
		throw_range = initial(throw_range)
		to_chat(user, "You retract the screwdriver.")

	else
		extended = TRUE
		tool_behaviour = TOOL_SCREWDRIVER
		w_class = WEIGHT_CLASS_SMALL  // still can fit in pocket
		force = 4  // copies force from screwdriver
		throwforce = 5
		throw_speed = 3
		throw_range = 5
		to_chat(user, "You extend the screwdriver.")
	playsound(src, 'sound/machines/pda_button2.ogg', 50, TRUE) // click
	update_icon()

/obj/item/pen/screwdriver/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!extended)
		return ..()
	if(!istype(M))
		return ..()
	if(user.zone_selected != BODY_ZONE_PRECISE_EYES && user.zone_selected != BODY_ZONE_HEAD)
		return ..()
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to harm [M]!</span>")
		return
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		M = user
	return eyestab(M,user)

/obj/item/pen/screwdriver/update_icon()
	if(extended)
		icon_state = "pendriverout"
	else
		icon_state = initial(icon_state)
