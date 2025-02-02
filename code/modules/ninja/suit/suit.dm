
/*

Contents:
- The Ninja Space Suit
- Ninja Space Suit Procs

*/


// /obj/item/clothing/suit/space/space_ninja


/obj/item/clothing/suit/space/space_ninja
	name = "ninja suit"
	desc = "A unique, vacuum-proof suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	icon_state = "s-ninja"
	item_state = "s-ninja_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/stock_parts/cell)
	slowdown = 1
	resistance_flags = LAVA_PROOF | ACID_PROOF
	armor_type = /datum/armor/space_ninja
	strip_delay = 12
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	cell = null
	show_hud = FALSE
	actions_types = list(
		/datum/action/item_action/initialize_ninja_suit,
		/datum/action/item_action/ninjaboost,
		/datum/action/item_action/ninjapulse,
		/datum/action/item_action/ninjastar,
		/datum/action/item_action/ninja_sword_recall,
		/datum/action/item_action/ninja_stealth,
		/datum/action/item_action/toggle_glove,
		/datum/action/item_action/ninja_hack
	)

	//Important parts of the suit.
	var/mob/living/carbon/human/affecting = null
	var/datum/effect_system/spark_spread/spark_system
	var/datum/techweb/stored_research
	var/obj/item/disk/tech_disk/t_disk //To copy design onto disk.
	var/obj/item/energy_katana/energyKatana //For teleporting the katana back to the ninja (It's an ability)

	//Other articles of ninja gear worn together, used to easily reference them after initializing.
	var/obj/item/clothing/head/helmet/space/space_ninja/n_hood
	var/obj/item/clothing/shoes/space_ninja/n_shoes
	var/obj/item/clothing/gloves/space_ninja/n_gloves

	//Main function variables.
	var/s_initialized = 0//Suit starts off.
	var/s_cost = 2.5//Base energy cost each ntick.
	var/s_acost = 12.5//Additional cost for additional powers active.
	var/s_delay = 40//How fast the suit does certain things, lower is faster. Can be overridden in specific procs. Also determines adverse probability.
	var/a_transfer = 20//How much radium is used per adrenaline boost.
	var/a_maxamount = 7//Maximum number of adrenaline boosts.
	var/s_maxamount = 20//Maximum number of smoke bombs.

	//Support function variables.
	var/stealth = FALSE//Stealth off.
	var/s_busy = FALSE//Is the suit busy with a process? Like AI hacking. Used for safety functions.

	//Ability function variables.
	var/a_boost = 3//Number of adrenaline boosters.

/datum/armor/space_ninja
	melee = 20
	bullet = 40
	laser = 40
	energy = 70
	bomb = 60
	bio = 100
	rad = 30
	fire = 100
	acid = 100
	stamina = 70
	bleed = 40

/obj/item/clothing/suit/space/space_ninja/examine(mob/user)
	. = ..()
	if(s_initialized)
		if(user == affecting)
			. += "All systems operational. Current energy capacity: <B>[display_energy(cell.charge)]</B>.\n"+\
			"The CLOAK-tech device is <B>[stealth?"active":"inactive"]</B>.\n"+\
			"There are <B>[a_boost]</B> adrenaline booster\s remaining."

/obj/item/clothing/suit/space/space_ninja/Initialize(mapload)
	. = ..()

	//Spark Init
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	//Research Init
	stored_research = new()

	//Cell Init
	cell = new/obj/item/stock_parts/cell/high
	cell.charge = 9000
	cell.name = "black power cell"
	cell.icon_state = "bscell"

// seal the cell in the ninja outfit
/obj/item/clothing/suit/space/space_ninja/toggle_spacesuit_cell(mob/user)
	return

// Space Suit temperature regulation and power usage
/obj/item/clothing/suit/space/space_ninja/process()
	var/mob/living/carbon/human/user = src.loc
	if(!user || !ishuman(user) || !(user.wear_suit == src))
		return
	user.adjust_bodytemperature(BODYTEMP_NORMAL - user.bodytemperature)
	update_action_buttons()
	if (!s_initialized)
		return
	if(!affecting)
		terminate()//Kills the suit and attached objects.
		return
	cell.use(s_cost)
	user.nutrition = NUTRITION_LEVEL_WELL_FED
	// Slowly heals bleeding wounds over time
	user.cauterise_wounds(0.1)

/obj/item/clothing/suit/space/space_ninja/Destroy()
	QDEL_NULL(spark_system)
	QDEL_NULL(cell)
	if(ismob(loc))
		UnregisterSignal(loc, COMSIG_PARENT_QDELETING)
	return ..()

/obj/item/clothing/suit/space/space_ninja/equipped(mob/user, slot)
	. = ..()
	RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(terminate))

/obj/item/clothing/suit/space/space_ninja/dropped(mob/user)
	UnregisterSignal(user, COMSIG_PARENT_QDELETING)
	. = ..()

//Simply deletes all the attachments and self, killing all related procs.
/obj/item/clothing/suit/space/space_ninja/proc/terminate()
	if(!QDELETED(n_hood))
		qdel(n_hood)
	if(!QDELETED(n_gloves))
		qdel(n_gloves)
	if(!QDELETED(n_shoes))
		qdel(n_shoes)
	if(!QDELETED(src))
		qdel(src)

//This proc prevents the suit from being taken off.
/obj/item/clothing/suit/space/space_ninja/proc/lock_suit(mob/living/carbon/human/H)
	if(!istype(H))
		return FALSE
	if(!is_ninja(H))
		to_chat(H, span_danger("<B>fÄTaL ÈÈRRoR</B>: 382200-*#00CÖDE <B>RED</B>\nUNAUHORIZED USÈ DETÈCeD\nCoMMÈNCING SUB-R0UIN3 13...\nTÈRMInATING U-U-USÈR..."))
		H.gib()
		return FALSE
	if(!istype(H.head, /obj/item/clothing/head/helmet/space/space_ninja))
		to_chat(H, "[span_userdanger("ERROR")]: 100113 UNABLE TO LOCATE HEAD GEAR\nABORTING...")
		return FALSE
	if(!istype(H.shoes, /obj/item/clothing/shoes/space_ninja))
		to_chat(H, "[span_userdanger("ERROR")]: 122011 UNABLE TO LOCATE FOOT GEAR\nABORTING...")
		return FALSE
	if(!istype(H.gloves, /obj/item/clothing/gloves/space_ninja))
		to_chat(H, "[span_userdanger("ERROR")]: 110223 UNABLE TO LOCATE HAND GEAR\nABORTING...")
		return FALSE
	affecting = H
	ADD_TRAIT(src, TRAIT_NODROP, NINJA_SUIT_TRAIT)
	slowdown = 0
	n_hood = H.head
	ADD_TRAIT(n_hood, TRAIT_NODROP, NINJA_SUIT_TRAIT)
	n_shoes = H.shoes
	ADD_TRAIT(n_shoes, TRAIT_NODROP, NINJA_SUIT_TRAIT)
	n_shoes.slowdown -= 0.5
	n_gloves = H.gloves
	ADD_TRAIT(n_gloves, TRAIT_NODROP, NINJA_SUIT_TRAIT)
	H.update_equipment_speed_mods()
	return TRUE

/obj/item/clothing/suit/space/space_ninja/proc/lockIcons(mob/living/carbon/human/H)
	icon_state = H.dna.features["body_model"] == FEMALE ? "s-ninjanf" : "s-ninjan"
	H.gloves.icon_state = "s-ninjan"
	H.gloves.item_state = "s-ninjan"


//This proc allows the suit to be taken off.
/obj/item/clothing/suit/space/space_ninja/proc/unlock_suit()
	affecting = null
	REMOVE_TRAIT(src, TRAIT_NODROP, NINJA_SUIT_TRAIT)
	slowdown = 1
	icon_state = "s-ninja"
	if(n_hood)//Should be attached, might not be attached.
		REMOVE_TRAIT(n_hood, TRAIT_NODROP, NINJA_SUIT_TRAIT)
	if(n_shoes)
		REMOVE_TRAIT(n_shoes, TRAIT_NODROP, NINJA_SUIT_TRAIT)
		n_shoes.slowdown += 0.5
	if(n_gloves)
		n_gloves.icon_state = "s-ninja"
		n_gloves.item_state = "s-ninja"
		REMOVE_TRAIT(n_gloves, TRAIT_NODROP, NINJA_SUIT_TRAIT)
		n_gloves.candrain = FALSE
		n_gloves.draining = FALSE
	if (isliving(loc))
		var/mob/living/worn_mob = loc
		worn_mob.update_equipment_speed_mods()

/obj/item/clothing/suit/space/space_ninja/ui_action_click(mob/user, datum/action/action)
	if(istype(action, /datum/action/item_action/initialize_ninja_suit))
		toggle_on_off()
		return TRUE
	if(!s_initialized)
		to_chat(user, span_warning("<b>ERROR</b>: suit offline.  Please activate suit."))
		return FALSE
	if(istype(action, /datum/action/item_action/ninjaboost))
		ninjaboost()
		return TRUE
	if(istype(action, /datum/action/item_action/ninjastar))
		ninjastar()
		return TRUE
	if(istype(action, /datum/action/item_action/ninja_sword_recall))
		ninja_sword_recall()
		return TRUE
	if(istype(action, /datum/action/item_action/toggle_glove))
		n_gloves.toggledrain()
		return TRUE
	return FALSE

/obj/item/clothing/suit/space/space_ninja/attackby(obj/item/I, mob/U, params)
	if(U != affecting)//Safety, in case you try doing this without wearing the suit/being the person with the suit.
		return ..()

	if(istype(I, /obj/item/reagent_containers/cup))//If it's a glass beaker.
		if(I.reagents.has_reagent(/datum/reagent/uranium/radium, a_transfer) && a_boost < a_maxamount)
			I.reagents.remove_reagent(/datum/reagent/uranium/radium, a_transfer)
			a_boost++;
			to_chat(U, span_notice("There are now [a_boost] adrenaline boosts remaining."))
			return

	else if(istype(I, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/CELL = I
		if(CELL.maxcharge > cell.maxcharge && n_gloves && n_gloves.candrain)
			to_chat(U, span_notice("Higher maximum capacity detected.\nUpgrading..."))
			if (n_gloves?.candrain && do_after(U,s_delay, target = src))
				U.transferItemToLoc(CELL, src)
				CELL.charge = min(CELL.charge+cell.charge, CELL.maxcharge)
				var/obj/item/stock_parts/cell/old_cell = cell
				old_cell.charge = 0
				U.put_in_hands(old_cell)
				old_cell.add_fingerprint(U)
				old_cell.corrupt()
				old_cell.update_icon()
				cell = CELL
				to_chat(U, span_notice("Upgrade complete. Maximum capacity: <b>[round(cell.maxcharge/100)]</b>%"))
			else
				to_chat(U, span_danger("Procedure interrupted. Protocol terminated."))
		return

	else if(istype(I, /obj/item/disk/tech_disk))//If it's a data disk, we want to copy the research on to the suit.
		var/obj/item/disk/tech_disk/TD = I
		var/has_research = 0
		if(has_research)//If it has something on it.
			to_chat(U, "Research information detected, processing...")
			if(do_after(U,s_delay, target = src))
				TD.stored_research.copy_research_to(stored_research)
				to_chat(U, span_notice("Data analyzed and updated. Disk erased."))
			else
				to_chat(U, "[span_userdanger("ERROR")]: Procedure interrupted. Process terminated.")
		else
			to_chat(U, span_notice("No research information detected."))
		return
	return ..()


/datum/action/item_action/initialize_ninja_suit
	name = "Toggle ninja suit"

/datum/action/item_action/ninjaboost
	check_flags = NONE
	name = "Adrenaline Boost"
	desc = "Inject a secret chemical that will counteract all movement-impairing effect."
	button_icon_state = "repulse"
	icon_icon = 'icons/hud/actions/actions_spells.dmi'

/datum/action/item_action/ninjastar
	name = "Create Throwing Stars (10W)"
	desc = "Creates some throwing stars"
	button_icon_state = "throwingstar"
	icon_icon = 'icons/obj/items_and_weapons.dmi'

/datum/action/item_action/ninjastar/is_available()
	if (!..())
		return FALSE
	var/obj/item/clothing/suit/space/space_ninja/ninja = master
	return ninja.cell.charge >= 50

/datum/action/item_action/ninja_sword_recall
	name = "Recall Energy Katana (Variable Cost)"
	desc = "Teleports the Energy Katana linked to this suit to its wearer, cost based on distance."
	button_icon_state = "energy_katana"
	icon_icon = 'icons/obj/items_and_weapons.dmi'

/datum/action/item_action/toggle_glove
	name = "Toggle interaction"
	desc = "Switch between normal interaction and drain mode."
	button_icon_state = "s-ninjan"
	icon_icon = 'icons/obj/clothing/gloves.dmi'

