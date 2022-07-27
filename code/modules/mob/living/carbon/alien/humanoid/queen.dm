/mob/living/carbon/alien/humanoid/royal
	//Common stuffs for Praetorian and Queen
	icon = 'icons/mob/alienqueen.dmi'
	status_flags = 0
	ventcrawler = VENTCRAWLER_NONE //pull over that ass too fat
	unique_name = 0
	pixel_x = -16
	bubble_icon = "alienroyal"
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER //above most mobs, but below speechbubbles
	pressure_resistance = 200 //Because big, stompy xenos should not be blown around like paper.
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/xeno = 20, /obj/item/stack/sheet/animalhide/xeno = 3)

	var/alt_inhands_file = 'icons/mob/alienqueen.dmi'
	var/game_end_timer

/mob/living/carbon/alien/humanoid/royal/can_inject()
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
	var/datum/action/small_sprite/smallsprite = new/datum/action/small_sprite/queen()

/mob/living/carbon/alien/humanoid/royal/queen/Initialize(mapload)
	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, .proc/check_hostile)
	check_hostile() //still need to call this
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

	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/repulse/xeno(src))
	AddAbility(new/obj/effect/proc_holder/alien/royal/queen/promote())
	smallsprite.Grant(src)
	return ..()

/mob/living/carbon/alien/humanoid/royal/queen/create_internal_organs()
	internal_organs += new /obj/item/organ/alien/plasmavessel/large/queen
	internal_organs += new /obj/item/organ/alien/resinspinner
	internal_organs += new /obj/item/organ/alien/acid
	internal_organs += new /obj/item/organ/alien/neurotoxin
	internal_organs += new /obj/item/organ/alien/eggsac
	..()

/mob/living/carbon/alien/humanoid/royal/queen/proc/check_hostile()
	SIGNAL_HANDLER
	if(is_station_level(src.z)) //we don't want the hostile environment if the xenos aren't actually on station
		SSshuttle.registerHostileEnvironment(src) //aliens delay shuttle
		if(game_end_timer)	//clear the timer if it exists
			deltimer(game_end_timer)
		game_end_timer = addtimer(CALLBACK(src, .proc/game_end), 30 MINUTES, TIMER_STOPPABLE) //time until shuttle is freed/called
		return
	if(src in SSshuttle.hostileEnvironments)
		SSshuttle.clearHostileEnvironment(src) //left the z level, no longer matters

/mob/living/carbon/alien/humanoid/royal/queen/proc/game_end()
	var/turf/T = get_turf(src)
	if(stat != DEAD && is_station_level(T.z))
		SSshuttle.clearHostileEnvironment(src)
		if(EMERGENCY_IDLE_OR_RECALLED)
			priority_announce("Xenomorph infestation detected: crisis shuttle protocols activated - jamming recall signals across all frequencies.", SSstation.announcer.get_rand_alert_sound())
			SSshuttle.emergency.request(null, set_coefficient=0.5)
			SSshuttle.emergencyNoRecall = TRUE
			UnregisterSignal(src, COMSIG_MOVABLE_Z_CHANGED) // we don't care anymore

/mob/living/carbon/alien/humanoid/royal/queen/death() //dead queen doesnt stop shuttle
	UnregisterSignal(src, COMSIG_MOVABLE_Z_CHANGED)
	SSshuttle.clearHostileEnvironment(src)
	..()

/mob/living/carbon/alien/humanoid/royal/queen/revive(full_heal = 0, admin_revive = 0)
	if(..())
		RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, .proc/check_hostile)
		check_hostile()

/mob/living/carbon/alien/humanoid/royal/queen/Destroy()
	UnregisterSignal(src, COMSIG_MOVABLE_Z_CHANGED)
	SSshuttle.clearHostileEnvironment(src)
	..()

//Queen verbs
/obj/effect/proc_holder/alien/lay_egg
	name = "Lay Egg"
	desc = "Lay an egg to produce huggers to impregnate prey with. Costs 75 Plasma."
	plasma_cost = 75
	check_turf = TRUE
	action_icon_state = "alien_egg"

/obj/effect/proc_holder/alien/lay_egg/fire(mob/living/carbon/user)
	if(locate(/obj/structure/alien/egg) in get_turf(user))
		to_chat(user, "<span class='alertalien'>There's already an egg here.</span>")
		return FALSE

	if(!check_vent_block(user))
		return FALSE

	user.visible_message("<span class='alertalien'>[user] has laid an egg!</span>")
	new /obj/structure/alien/egg(user.loc)
	return TRUE

//Button to let queen choose her praetorian.
/obj/effect/proc_holder/alien/royal/queen/promote
	name = "Create Royal Parasite"
	desc = "Produce a royal parasite to grant one of your children the honor of being your Praetorian. Costs 500 Plasma."
	plasma_cost = 500 //Plasma cost used on promotion, not spawning the parasite.

	action_icon_state = "alien_queen_promote"

/obj/effect/proc_holder/alien/royal/queen/promote/fire(mob/living/carbon/alien/user)
	var/obj/item/queenpromote/prom
	if(get_alien_type_in_hive(/mob/living/carbon/alien/humanoid/royal/praetorian/))
		to_chat(user, "<span class='noticealien'>You already have a Praetorian!</span>")
		return 0
	else
		for(prom in user)
			to_chat(user, "<span class='noticealien'>You discard [prom].</span>")
			qdel(prom)
			return 0

		prom = new (user.loc)
		if(!user.put_in_active_hand(prom, 1))
			to_chat(user, "<span class='warning'>You must empty your hands before preparing the parasite.</span>")
			return 0
		else //Just in case telling the player only once is not enough!
			to_chat(user, "<span class='noticealien'>Use the royal parasite on one of your children to promote her to Praetorian!</span>")
	return 0

/obj/item/queenpromote
	name = "\improper royal parasite"
	desc = "Inject this into one of your grown children to promote her to a Praetorian!"
	icon_state = "alien_medal"
	item_flags = ABSTRACT | DROPDEL
	icon = 'icons/mob/alien.dmi'

/obj/item/queenpromote/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/queenpromote/attack(mob/living/M, mob/living/carbon/alien/humanoid/user)
	if(!isalienadult(M) || isalienroyal(M))
		to_chat(user, "<span class='noticealien'>You may only use this with your adult, non-royal children!</span>")
		return
	if(get_alien_type_in_hive(/mob/living/carbon/alien/humanoid/royal/praetorian/))
		to_chat(user, "<span class='noticealien'>You already have a Praetorian!</span>")
		return

	var/mob/living/carbon/alien/humanoid/A = M
	if(A.stat == CONSCIOUS && A.mind && A.key)
		if(!user.usePlasma(500))
			to_chat(user, "<span class='noticealien'>You must have 500 plasma stored to use this!</span>")
			return

		to_chat(A, "<span class='noticealien'>The queen has granted you a promotion to Praetorian!</span>")
		user.visible_message("<span class='alertalien'>[A] begins to expand, twist and contort!</span>")
		var/mob/living/carbon/alien/humanoid/royal/praetorian/new_prae = new (A.loc)
		A.mind.transfer_to(new_prae)
		qdel(A)
		qdel(src)
		return
	else
		to_chat(user, "<span class='warning'>This child must be alert and responsive to become a Praetorian!</span>")

/obj/item/queenpromote/attack_self(mob/user)
	to_chat(user, "<span class='noticealien'>You discard [src].</span>")
	qdel(src)
