
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
	armor = list("melee" = 60, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100, "stamina" = 60)
	strip_delay = 12

	actions_types = list(/datum/action/item_action/initialize_ninja_suit, /datum/action/item_action/ninjasmoke, /datum/action/item_action/ninjaboost, /datum/action/item_action/ninjapulse, /datum/action/item_action/ninjastar, /datum/action/item_action/ninjanet, /datum/action/item_action/ninja_sword_recall, /datum/action/item_action/ninja_stealth, /datum/action/item_action/toggle_glove)

		//Important parts of the suit.
	var/mob/living/carbon/human/affecting = null
	var/obj/item/stock_parts/cell/cell
	var/datum/effect_system/spark_spread/spark_system
	var/datum/techweb/stored_research
	var/obj/item/disk/tech_disk/t_disk//To copy design onto disk.
	var/obj/item/energy_katana/energyKatana //For teleporting the katana back to the ninja (It's an ability)

		//Other articles of ninja gear worn together, used to easily reference them after initializing.
	var/obj/item/clothing/head/helmet/space/space_ninja/n_hood
	var/obj/item/clothing/shoes/space_ninja/n_shoes
	var/obj/item/clothing/gloves/space_ninja/n_gloves

		//Main function variables.
	var/s_initialized = 0//Suit starts off.
	var/s_coold = 0//If the suit is on cooldown. Can be used to attach different cooldowns to abilities. Ticks down every second based on suit ntick().
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
	var/s_bombs = 10//Number of smoke bombs.
	var/a_boost = 3//Number of adrenaline boosters.


/obj/item/clothing/suit/space/space_ninja/get_cell()
	return cell

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
	if(!QDELETED(energyKatana))
		energyKatana.visible_message("<span class='warning'>[src] flares and then turns to dust!</span>")
		qdel(energyKatana)
	if(!QDELETED(src))
		qdel(src)

//Randomizes suit parameters.
/obj/item/clothing/suit/space/space_ninja/proc/randomize_param()
	s_cost = rand(1,10)
	s_acost = rand(10,50)
	s_delay = rand(10,100)
	s_bombs = rand(5,20)
	a_boost = rand(1,7)


//This proc prevents the suit from being taken off.
/obj/item/clothing/suit/space/space_ninja/proc/lock_suit(mob/living/carbon/human/H)
	if(!istype(H))
		return FALSE
	if(!is_ninja(H))
		to_chat(H, "<span class='danger'><B>fÄTaL ÈÈRRoR</B>: 382200-*#00CÖDE <B>RED</B>\nUNAUHORIZED USÈ DETÈCeD\nCoMMÈNCING SUB-R0UIN3 13...\nTÈRMInATING U-U-USÈR...</span>")
		H.gib()
		return FALSE
	if(!istype(H.head, /obj/item/clothing/head/helmet/space/space_ninja))
		to_chat(H, "<span class='userdanger'>ERROR</span>: 100113 UNABLE TO LOCATE HEAD GEAR\nABORTING...")
		return FALSE
	if(!istype(H.shoes, /obj/item/clothing/shoes/space_ninja))
		to_chat(H, "<span class='userdanger'>ERROR</span>: 122011 UNABLE TO LOCATE FOOT GEAR\nABORTING...")
		return FALSE
	if(!istype(H.gloves, /obj/item/clothing/gloves/space_ninja))
		to_chat(H, "<span class='userdanger'>ERROR</span>: 110223 UNABLE TO LOCATE HAND GEAR\nABORTING...")
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
		n_shoes.slowdown++
	if(n_gloves)
		n_gloves.icon_state = "s-ninja"
		n_gloves.item_state = "s-ninja"
		REMOVE_TRAIT(n_gloves, TRAIT_NODROP, NINJA_SUIT_TRAIT)
		n_gloves.candrain = FALSE
		n_gloves.draining = FALSE


/obj/item/clothing/suit/space/space_ninja/examine(mob/user)
	. = .()
	if(s_initialized)
		if(user == affecting)
			. += "All systems operational. Current energy capacity: <B>[display_energy(cell.charge)]</B>.\n"+\
			"The CLOAK-tech device is <B>[stealth?"active":"inactive"]</B>.\n"+\
			"There are <B>[s_bombs]</B> smoke bomb\s remaining.\n"+\
			"There are <B>[a_boost]</B> adrenaline booster\s remaining."

/obj/item/clothing/suit/space/space_ninja/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/initialize_ninja_suit))
		toggle_on_off()
		return TRUE
	if(!s_initialized)
		to_chat(user, "<span class='warning'><b>ERROR</b>: suit offline.  Please activate suit.</span>")
		return FALSE
	if(istype(action, /datum/action/item_action/ninjasmoke))
		ninjasmoke()
		return TRUE
	if(istype(action, /datum/action/item_action/ninjaboost))
		ninjaboost()
		return TRUE
	if(istype(action, /datum/action/item_action/ninjapulse))
		ninjapulse()
		return TRUE
	if(istype(action, /datum/action/item_action/ninjastar))
		ninjastar()
		return TRUE
	if(istype(action, /datum/action/item_action/ninjanet))
		ninjanet()
		return TRUE
	if(istype(action, /datum/action/item_action/ninja_sword_recall))
		ninja_sword_recall()
		return TRUE
	if(istype(action, /datum/action/item_action/ninja_stealth))
		stealth()
		return TRUE
	if(istype(action, /datum/action/item_action/toggle_glove))
		n_gloves.toggledrain()
		return TRUE
	return FALSE
