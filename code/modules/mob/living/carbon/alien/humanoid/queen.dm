/mob/living/carbon/alien/humanoid/royal
	//Common stuffs for Praetorian and Queen
	icon = 'icons/mob/alienqueen.dmi'
	status_flags = 0
	unique_name = 0
	pixel_x = -16
	base_pixel_x = -16
	bubble_icon = "alienroyal"
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER //above most mobs, but below speechbubbles
	pressure_resistance = 200 //Because big, stompy xenos should not be blown around like paper.
	butcher_results = list(/obj/item/food/meat/slab/xeno = 20, /obj/item/stack/sheet/animalhide/xeno = 3)

	var/alt_inhands_file = 'icons/mob/alienqueen.dmi'
	var/game_end_timer

/mob/living/carbon/alien/humanoid/royal/Initialize(mapload)
	. = ..()
	// as a wise man once wrote: "pull over that ass too fat"
	REMOVE_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/carbon/alien/humanoid/royal/can_inject(mob/user, target_zone, injection_flags)
	return FALSE

/mob/living/carbon/alien/humanoid/royal/queen/proc/maidify()
	name = "alien queen maid"
	desc = "Lusty, Sexy"
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "alienqmaid"
	caste = "qmaid"
	update_icons()

/mob/living/carbon/alien/humanoid/royal/queen/proc/unmaidify()
	name = "alien queen"
	desc = ""
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "alienq"
	caste = "q"
	update_icons()

/mob/living/carbon/alien/humanoid/royal/queen
	name = "alien queen"
	caste = "q"
	maxHealth = 400
	health = 400
	icon_state = "alienq"

/mob/living/carbon/alien/humanoid/royal/queen/Initialize(mapload)
	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(set_countdown))
	set_countdown() //still need to call this
	SSshuttle.registerInfestation(src)
	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/royal/queen/Q in GLOB.carbon_list)
		if(Q == src)
			continue
		if(Q.stat == DEAD)
			continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name

	var/datum/action/spell/aoe/repulse/xeno/tail_whip = new(src)
	tail_whip.Grant(src)
	var/datum/action/small_sprite/queen/smallsprite = new(src)
	smallsprite.Grant(src)
	var/datum/action/alien/promote/promotion = new(src)
	promotion.Grant(src)
	return ..()

/mob/living/carbon/alien/humanoid/royal/queen/create_internal_organs()
	internal_organs += new /obj/item/organ/alien/plasmavessel/large/queen
	internal_organs += new /obj/item/organ/alien/resinspinner
	internal_organs += new /obj/item/organ/alien/acid
	internal_organs += new /obj/item/organ/alien/neurotoxin
	internal_organs += new /obj/item/organ/alien/eggsac
	return ..()

/mob/living/carbon/alien/humanoid/royal/queen/proc/set_countdown()
	SIGNAL_HANDLER
	if(game_end_timer)	//clear the timer if it exists, only one queen can normally exist at a time so resetting this means the old queen has died or an admin is involved
		deltimer(game_end_timer)
	game_end_timer = addtimer(CALLBACK(src, PROC_REF(game_end)), 30 MINUTES, TIMER_STOPPABLE) //If Queen isn't killed within 30 minutes, shuttle is force-called

/mob/living/carbon/alien/humanoid/royal/queen/proc/game_end()
	var/turf/T = get_turf(src)
	if(stat != DEAD && is_station_level(T.z)) //If the queen is not on the station, the infestation event will not auto-trigger
		SSshuttle.delayForInfestedStation()
		UnregisterSignal(src, COMSIG_MOVABLE_Z_CHANGED)

/mob/living/carbon/alien/humanoid/royal/queen/death() //dead queen doesnt cause shuttle
	UnregisterSignal(src, COMSIG_MOVABLE_Z_CHANGED)
	SSshuttle.clearInfestation(src)
	..()

/mob/living/carbon/alien/humanoid/royal/queen/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(!.)
		return
	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(set_countdown))
	set_countdown()
	SSshuttle.registerInfestation(src)

/mob/living/carbon/alien/humanoid/royal/queen/Destroy()
	UnregisterSignal(src, COMSIG_MOVABLE_Z_CHANGED)
	SSshuttle.clearInfestation(src)
	..()

//Queen verbs
/datum/action/alien/make_structure/lay_egg
	name = "Lay Egg"
	desc = "Lay an egg to produce huggers to impregnate prey with."
	button_icon_state = "alien_egg"
	plasma_cost = 75
	made_structure_type = /obj/structure/alien/egg

/datum/action/alien/make_structure/lay_egg/on_activate(mob/user, atom/target)
	. = ..()
	owner.visible_message(span_alertalien("[owner] lays an egg!"))

//Button to let queen choose her praetorian.
/datum/action/alien/promote
	name = "Create Royal Parasite"
	desc = "Produce a royal parasite to grant one of your children the honor of being your Praetorian."
	button_icon_state = "alien_queen_promote"
	/// The promotion only takes plasma when completed, not on activation.
	var/promotion_plasma_cost = 500

/datum/action/alien/promote/update_stat_status(list/stat)
	stat[STAT_STATUS] = GENERATE_STAT_TEXT("PLASMA - [promotion_plasma_cost]")

/datum/action/alien/promote/is_available()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/carbon_owner = owner
	if(carbon_owner.getPlasma() < promotion_plasma_cost)
		return FALSE

	if(get_alien_type(/mob/living/carbon/alien/humanoid/royal/praetorian))
		return FALSE

	return TRUE

/datum/action/alien/promote/on_activate(mob/user, atom/target)
	var/obj/item/queen_promotion/existing_promotion = locate() in owner.held_items
	if(existing_promotion)
		to_chat(owner, ("<span class='noticealien'>You discard [existing_promotion].</span>"))
		owner.temporarilyRemoveItemFromInventory(existing_promotion)
		qdel(existing_promotion)
		return TRUE

	if(!owner.get_empty_held_indexes())
		to_chat(owner, ("<span class='warning'>You must have an empty hand before preparing the parasite.</span>"))
		return FALSE

	var/obj/item/queen_promotion/new_promotion = new(owner.loc)
	if(!owner.put_in_hands(new_promotion, del_on_fail = TRUE))
		to_chat(owner, span_noticealien("You fail to prepare a parasite."))
		return FALSE

	to_chat(owner, span_noticealien("Use [new_promotion] on one of your children to promote her to a Praetorian!"))
	return TRUE

/obj/item/queen_promotion
	name = "\improper royal parasite"
	desc = "Inject this into one of your grown children to promote her to a Praetorian!"
	icon_state = "alien_medal"
	item_flags = NOBLUDGEON | ABSTRACT | DROPDEL
	icon = 'icons/mob/alien.dmi'

/obj/item/queen_promotion/attack(mob/living/to_promote, mob/living/carbon/alien/humanoid/queen)
	. = ..()
	if(.)
		return

	var/datum/action/alien/promote/promotion = locate() in queen.actions
	if(!promotion)
		CRASH("[type] was created and handled by a mob ([queen]) that didn't have a promotion action associated.")

	if(!isalienadult(to_promote) || isalienroyal(to_promote))
		to_chat(queen, span_noticealien("You may only use this with your adult, non-royal children!"))
		return

	if(!promotion.is_available())
		to_chat(queen, span_noticealien("You cannot promote a child right now!"))
		return

	if(to_promote.stat != CONSCIOUS || !to_promote.mind || !to_promote.key)
		return

	queen.adjustPlasma(-promotion.promotion_plasma_cost)

	to_chat(queen, span_noticealien("You have promoted [to_promote] to a Praetorian!"))
	to_promote.visible_message(
		span_alertalien("[to_promote] begins to expand, twist and contort!"),
		span_noticealien("The queen has granted you a promotion to Praetorian!"),
	)

	var/mob/living/carbon/alien/humanoid/royal/praetorian/new_prae = new(to_promote.loc)
	to_promote.mind.transfer_to(new_prae)

	qdel(to_promote)
	qdel(src)
	return TRUE

/obj/item/queen_promotion/attack_self(mob/user)
	to_chat(user, ("<span class='noticealien'>You discard [src].</span>"))
	qdel(src)

/obj/item/queen_promotion/dropped(mob/user, silent)
	if(!silent)
		to_chat(user, ("<span class='noticealien'>You discard [src].</span>"))
	return ..()
