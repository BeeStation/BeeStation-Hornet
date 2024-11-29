/datum/religion_sect/forge_sect
	name = "Forge"
	quote = "Work the metal of the gods. Touch divinity."
	desc = "A sect dedicated to forging minerals together to create rare and valuable materials. "
	tgui_icon = "hammer" // https://fontawesome.com/icons/
	alignment = ALIGNMENT_NEUT
	desired_items = list(/obj/item/stack/ore = "with ore") //Items you can offer into the altar by clicking
	rites_list = list(
	/datum/religion_rites/metal_sacrifice,
	/datum/religion_rites/create_adamantine,
	/datum/religion_rites/bulk_adamantine,
	/datum/religion_rites/forge_minor,
	/datum/religion_rites/forge_major,
	/datum/religion_rites/create_golem) //List of rites the sect has.
	altar_icon_state = "convertaltar-red" //Icon for alter
	max_favor = 10000 //Max amount they can reach
	var/list/ore_values = list(/datum/material/iron = 2, /datum/material/glass = 2, /datum/material/copper = 6, /datum/material/plasma = 19,  /datum/material/silver = 20, /datum/material/gold = 23, /datum/material/titanium = 38, /datum/material/uranium = 38, /datum/material/diamond = 63, /datum/material/bluespace = 63, /datum/material/bananium = 63)

/datum/religion_sect/forge_sect/sect_bless(mob/living/target, mob/living/chap) //what happens when you bash someone with the bible, You can put anything here really, by default it does nothing afaik
	return TRUE

/datum/religion_sect/forge_sect/on_sacrifice(obj/item/stack/ore/I, mob/living/L)//When an object is offered to the altar
	if(!istype(I, /obj/item/stack/ore))
		return
	adjust_favor(I.points * I.amount, L) //Adjust the sects favor, you can add or subtract, but for offerings its good to add.
	to_chat(L, "<span class='notice'>You offer [I] to [GLOB.deity], pleasing them and gaining [I.points*I.amount] favor in the process.</span>")
	qdel(I)
	return TRUE

//artifacts we can make, except the shield and armor (those are in /modules/research/xenobiology/crossbreeding, clothing and weapons)
/obj/item/melee/resonation_staff
	name = "resonation staff"
	desc = "A large, rough staff made of adamantine. Occasionally, it resonates with unheard sounds."
	icon_state = "adamantine-staff"
	item_state = "adamantine-staff"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("thrashes", "beats", "slams", "resonates")
	attack_verb_simple = list("thrash", "beat", "slam", "resonate")

/obj/item/clothing/accessory/pendant
	name = "adamantine pendant"
	desc = "A smooth pendant, looped on an adamantine chain and containing a bluespace crystal. It glitters with a gentle, cyan light."
	icon_state = "pendant"
	armor = list(MELEE = 10,  BULLET = 5, LASER = 0, ENERGY = 0, BOMB = 20, BIO = 0, RAD = 5, FIRE = 0, ACID = 0, STAMINA = 10, BLEED = 20)

/obj/item/clothing/head/helmet/adamantine_crown
	desc = "A crown composed of adamantine spikes. It's a tuning fork for curses and hexes."
	icon_state = "adamantine-crown"
	item_state = "adamantine-crown"
	armor = list(MELEE = 15,  BULLET = 10, LASER = 20, ENERGY = 30, BOMB = 20, BIO = 0, RAD = 0, FIRE = 0, ACID = 50, STAMINA = 10, BLEED = 10)

/obj/item/clothing/head/helmet/adamantinecrown/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD && istype(user))
		ADD_TRAIT(user, TRAIT_WARDED, CLOTHING_TRAIT)

/obj/item/clothing/head/helmet/adamantinecrown/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_WARDED, CLOTHING_TRAIT)

/obj/item/borg/upgrade/holy
	name = "cyborg adamantine plating"
	desc = "A set of holy internal plating that makes a cyborg resistant to arcane influence. Like a tinfoil hat for magic."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "adamantine-plate"

/obj/item/borg/upgrade/holy/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		if(HAS_TRAIT(R, HOLYWATER_TRAIT))
			to_chat(R, "<span class='notice'>The adamantine plating is already installed!</span>")
			to_chat(user, "<span class='notice'>There's no room for more plating!</span>")
			return FALSE
		R.AddComponent(/datum/component/anti_magic, type, _magic = FALSE, _holy = TRUE)

/obj/item/borg/upgrade/holy/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for (var/datum/component/anti_magic/anti_magic in R.GetComponents(/datum/component/anti_magic))
			if (anti_magic.source == type)
				qdel(anti_magic)

//rituals

/datum/religion_rites/metal_sacrifice
	name = "Metal Sacrifice"
	desc = "Feed metal sheets into the divine crucible for favor."
	ritual_length = 15 SECONDS
	ritual_invocations = list("Take this metal into your divine fire ...",
	"... purge it of all impurity ...",
	"... unmake its bindings and remake it anew ...",
	"... take it into your grand alloy ...",
	"... shape it into a new part of creation ...")
	invoke_msg = "... and may it once again find purpose, at the tip of your blade. "
	var/obj/item/stack/sheet/chosen_sheet
	favor_cost = 0

/datum/religion_rites/metal_sacrifice/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/stack/sheet/Sheets in get_turf(religious_tool))
		if(istype(Sheets, /obj/item/stack/sheet/mineral/adamantine))
			to_chat(user, "<span class='warning'>You cannot offer up adamantine!</span>")
			return FALSE
		return ..()
	return FALSE

/datum/religion_rites/metal_sacrifice/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	for(var/obj/item/stack/sheet/Sheets in get_turf(religious_tool))
		if(istype(Sheets, /obj/item/stack/sheet/mineral/adamantine))
			to_chat(user, "<span class='warning'>You cannot offer up adamantine!</span>")
			return FALSE
		chosen_sheet = Sheets
		if(!QDELETED(chosen_sheet) && get_turf(religious_tool) == chosen_sheet.loc)
			var/favor_gained = (chosen_sheet.amount * 2)
			GLOB.religious_sect?.adjust_favor(favor_gained, user)
			playsound(get_turf(religious_tool), 'sound/magic/fireball.ogg', 50, TRUE)
			to_chat(user, "<span class='notice'>[GLOB.deity] absorbs [chosen_sheet], leaving drips of molten metal behind. [GLOB.deity] rewards you with [favor_gained] favor.</span>")
			qdel(chosen_sheet)
			chosen_sheet = null
			return TRUE
		else
			to_chat(user, "<span class='warning'>The right sacrifice is no longer on the altar!</span>")
			chosen_sheet = null
			return FALSE
	to_chat(user, "<span class='notice'>You've exhausted the supply of sheets.</span>")

/datum/religion_rites/create_adamantine
	name = "Create Adamantine"
	desc = "Create a sheet of Adamantine for further refinement into armor and tools."
	ritual_length = 10 SECONDS
	ritual_invocations = list(
		"As I reach into the crucible ...",
		"... plunge my hand into the fire ...",
		"... reward my tenacity ...")
	invoke_msg = "with the metal of the gods!."
	favor_cost = 100

/datum/religion_rites/create_adamantine/invoke_effect(mob/living/user, atom/religious_tool)
	new /obj/item/stack/sheet/mineral/adamantine(get_turf(religious_tool))
	playsound(get_turf(religious_tool), 'sound/magic/fireball.ogg', 50, TRUE)
	return ..()


/datum/religion_rites/bulk_adamantine
	name = "Bulk Create Adamantine"
	desc = "Create five Adamantine for further refinement into armor and tools."
	ritual_length = 15 SECONDS
	ritual_invocations = list(
		"As I reach into the crucible ...",
		"... plunge my hand into the fire ...",
		"... reward my tenacity ...")
	invoke_msg = "with the metal of the gods!."
	favor_cost = 500

/datum/religion_rites/bulk_adamantine/invoke_effect(mob/living/user, atom/religious_tool)
	new /obj/item/stack/sheet/mineral/adamantine/five(get_turf(religious_tool))
	playsound(get_turf(religious_tool), 'sound/magic/fireball.ogg', 50, TRUE)
	return ..()

/datum/religion_rites/forge_minor
	name = "Forge Minor Artifact"
	desc = "Spend five adamantine to create a minor artifact, either a crown, a necklace, or a resonance scepter."
	ritual_length = 15 SECONDS
	ritual_invocations = list(
		"I call upon the fires of your forge ...",
		"... to shape this holy metal ...",
		"... to bring new works into the world ...")
	invoke_msg = "I bid thee, craft my vision!."
	favor_cost = 250

/datum/religion_rites/forge_minor/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/stack/sheet/mineral/adamantine/Adamantine in get_turf(religious_tool))
		if(Adamantine.amount < 5)
			to_chat(user, "<span class='warning'>There's not enough adamantine.")
			return FALSE
		return ..()
	to_chat(user, "<span_class='warning'>There's no adamantine on the altar.")
	return FALSE

/datum/religion_rites/forge_minor/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/list/items = list(
		"Resonation Staff" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "adamantine-staff"),
		"Adamantine Pendant" = image(icon = 'icons/obj/clothing/accessories.dmi', icon_state = "pendant"),
		"Adamantine Crown" = image(icon = 'icons/obj/clothing/head/helmet.dmi', icon_state = "adamantine-crown")
		)
	for(var/obj/item/stack/sheet/mineral/adamantine/Adamantine in get_turf(religious_tool))
		if(Adamantine.amount == 5)
			qdel(Adamantine)
		else(Adamantine.amount -= 5)
		Adamantine = null
	var/choice = show_radial_menu(user, religious_tool, items, require_near = TRUE, tooltips = TRUE)
	var/list/pickedtype = list()
	switch(choice)
		if("Resonation Staff")
			pickedtype += /obj/item/melee/resonation_staff
		if("Adamantine Pendant")
			pickedtype += /obj/item/clothing/accessory/pendant
		if("Adamantine Crown")
			pickedtype += /obj/item/clothing/head/helmet/adamantine_crown
		else
			return FALSE
	if(religious_tool && !QDELETED(religious_tool) && pickedtype && !user.incapacitated())
		for(var/N in pickedtype)
			new N(get_turf(religious_tool))
			to_chat(user, "<span class='notice'>Fire leaps, and molten adamantine drains into the altar, leaving the [choice] behind.</span>")
			playsound(get_turf(religious_tool), 'sound/magic/fireball.ogg', 50, TRUE)
			return ..()

/datum/religion_rites/forge_major
	name = "Forge Major Artifact"
	desc = "Spend ten adamantine to create a suit a major artifact, either a suit of armor, a shield, or some cyborg plating."
	ritual_length = 15 SECONDS
	ritual_invocations = list(
		"I call upon the fires of your forge ...",
		"... to shape this holy metal ...",
		"... to bring new works into this world ...")
	invoke_msg = "I bid thee, craft my vision!."
	favor_cost = 500

/datum/religion_rites/forge_major/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/stack/sheet/mineral/adamantine/Adamantine in get_turf(religious_tool))
		if(Adamantine.amount < 10)
			to_chat(user, "<span class='warning'>There's not enough adamantine.")
			return FALSE
		return ..()
	to_chat(user, "<span_class='warning'>There's no adamantine on the altar.")
	return FALSE

/datum/religion_rites/forge_major/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/list/items = list(
		"Adamantine Shield" = image(icon = 'icons/obj/slimecrossing.dmi', icon_state = "adamshield"),
		"Adamantine Armor" = image(icon = 'icons/obj/clothing/suits/armor.dmi', icon_state = "adamsuit"),
		"Adamantine Plating" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "adamantine-plate")
		)
	for(var/obj/item/stack/sheet/mineral/adamantine/Adamantine in get_turf(religious_tool))
		if(Adamantine.amount == 10)
			qdel(Adamantine)
		else(Adamantine.amount -= 10)
		Adamantine = null
	var/choice = show_radial_menu(user, religious_tool, items, require_near = TRUE, tooltips = TRUE)
	var/list/pickedtype = list()
	switch(choice)
		if("Adamantine Shield")
			pickedtype += /obj/item/shield/adamantineshield
		if("Adamantine Armor")
			pickedtype += /obj/item/clothing/suit/armor/heavy/adamantine
		if("Adamantine Plating")
			pickedtype += /obj/item/borg/upgrade/holy
		else
			return FALSE
	if(religious_tool && !QDELETED(religious_tool) && pickedtype && !user.incapacitated())
		for(var/N in pickedtype)
			new N(get_turf(religious_tool))
			to_chat(user, "<span class='notice'>Fire leaps, and molten adamantine drains into the altar, leaving the [choice] behind.</span>")
			playsound(get_turf(religious_tool), 'sound/magic/fireball.ogg', 50, TRUE)
			return ..()


/datum/religion_rites/create_golem
	name = "Shape Golem"
	desc = "Spend fifteen adamantine to create a blank golem shell."
	ritual_length = 20 SECONDS
	ritual_invocations = list(
		"I call upon the fires of your forge ...",
		"... to shape this holy metal ...",
		"... create a new acolyte for your church...",
		"... weave a soul through this holy steel ...")
	invoke_msg = "I bid thee, craft a golem shell!."
	favor_cost = 750

/datum/religion_rites/create_golem/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/stack/sheet/mineral/adamantine/Adamantine in get_turf(religious_tool))
		if(Adamantine.amount < 15)
			to_chat(user, "<span class='warning'>There's not enough adamantine.")
			return FALSE
		return ..()
	return FALSE

/datum/religion_rites/create_golem/invoke_effect(mob/living/user, atom/movable/religious_tool)
	for(var/obj/item/stack/sheet/mineral/adamantine/Adamantine in get_turf(religious_tool))
		if(Adamantine.amount == 15)
			qdel(Adamantine)
		else(Adamantine.amount -= 15)
		Adamantine = null
	new /obj/item/golem_shell/servant(get_turf(religious_tool))
	playsound(get_turf(religious_tool), 'sound/magic/fireball.ogg', 50, TRUE)
	return ..()
