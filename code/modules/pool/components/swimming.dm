//Component used to show that a mob is swimming, and force them to swim a lil' bit slower. Components are actually really based!

/datum/component/swimming
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/lengths = 0 //How far have we swum?
	var/lengths_for_bonus = 25 //If you swim this much, you'll count as having "excercised" and thus gain a buff.
	var/list/species = list()
	var/drowning = FALSE
	var/ticks_drowned = 0
	var/slowdown = 4
	var/bob_height_min = 2
	var/bob_height_max = 5
	var/bob_tick = 0

/datum/component/swimming/Initialize()
	. = ..()
	if(!isliving(parent))
		message_admins("Swimming component erroneously added to a non-living mob ([parent]).")
		return INITIALIZE_HINT_QDEL //Only mobs can swim, like Ian...
	var/mob/M = parent
	M.visible_message("<span class='notice'>[parent] starts splashing around in the water!</span>")
	M.add_movespeed_modifier(MOVESPEED_ID_SWIMMING, update=TRUE, priority=50, multiplicative_slowdown=slowdown, movetypes=GROUND)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/onMove)
	RegisterSignal(parent, COMSIG_CARBON_SPECIESCHANGE, .proc/onChangeSpecies)
	RegisterSignal(parent, COMSIG_MOB_ATTACK_HAND_TURF, .proc/try_leave_pool)
	START_PROCESSING(SSprocessing, src)
	enter_pool()

/datum/component/swimming/proc/onMove()
	lengths ++
	if(lengths > lengths_for_bonus)
		var/mob/living/L = parent
		SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "exercise", /datum/mood_event/exercise)
		L.apply_status_effect(STATUS_EFFECT_EXERCISED) //Swimming is really good excercise!
		lengths = 0

//Damn edge cases
/datum/component/swimming/proc/onChangeSpecies()
	var/mob/living/carbon/C = parent
	var/component_type = /datum/component/swimming
	if(istype(C) && C?.dna?.species)
		component_type = C.dna.species.swimming_component
	var/mob/M = parent
	RemoveComponent()
	M.AddComponent(component_type)

/datum/component/swimming/proc/try_leave_pool(datum/source, turf/clicked_turf)
	var/mob/living/L = parent
	if(!L.can_interact_with(clicked_turf))
		return
	if(is_blocked_turf(clicked_turf))
		return
	if(istype(clicked_turf, /turf/open/indestructible/sound/pool))
		return
	if(L.pulling)
		to_chat(parent, "<span class='notice'>You start to lift [L.pulling] out of the pool...</span>")
		var/atom/movable/pulled_object = L.pulling
		if(do_after(parent, 1 SECONDS, target=pulled_object))
			pulled_object.forceMove(clicked_turf)
			L.visible_message("<span class='notice'>[parent] pulls [pulled_object] out of the pool.</span>")
			var/datum/component/swimming/swimming_comp = pulled_object.GetComponent(/datum/component/swimming)
			if(swimming_comp)
				swimming_comp.RemoveComponent()
		return
	to_chat(parent, "<span class='notice'>You start to climb out of the pool...</span>")
	if(do_after(parent, 1 SECONDS, target=clicked_turf))
		L.forceMove(clicked_turf)
		L.visible_message("<span class='notice'>[parent] climbs out of the pool.</span>")
		RemoveComponent()

/datum/component/swimming/UnregisterFromParent()
	exit_pool()
	var/mob/M = parent
	if(drowning)
		stop_drowning(M)
	if(bob_tick)
		M.pixel_y = 0
	M.remove_movespeed_modifier(MOVESPEED_ID_SWIMMING)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(parent, COMSIG_CARBON_SPECIESCHANGE)
	UnregisterSignal(parent, COMSIG_MOB_ATTACK_HAND_TURF)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/component/swimming/process()
	var/mob/living/L = parent
	var/floating = FALSE
	var/obj/item/twohanded/required/pool/helditem = L.get_active_held_item()
	if(istype(helditem) && helditem.wielded)
		bob_tick ++
		animate(L, time=9.5, pixel_y = (L.pixel_y == bob_height_max) ? bob_height_min : bob_height_max)
		floating = TRUE
	else
		if(bob_tick)
			animate(L, time=5, pixel_y = 0)
			bob_tick = 0
	if(!floating && is_drowning(L))
		if(!drowning)
			start_drowning(L)
			drowning = TRUE
		drown(L)
	else if(drowning)
		stop_drowning(L)
		drowning = FALSE
	L.adjust_fire_stacks(-1)

/datum/component/swimming/proc/is_drowning(mob/living/victim)
	var/obj/item/twohanded/required/pool/helditem = victim.get_active_held_item()
	if(istype(helditem) && helditem.wielded)
		return
	return ((!(victim.mobility_flags & MOBILITY_STAND)) && (!HAS_TRAIT(victim, TRAIT_NOBREATH)))

/datum/component/swimming/proc/drown(mob/living/victim)
	if(victim.losebreath < 1)
		victim.losebreath += 1
	ticks_drowned ++
	if(prob(20))
		victim.emote("cough")
	else if(prob(25))
		victim.emote("gasp")
	if(ticks_drowned > 20)
		if(prob(10))
			victim.visible_message("<span class='warning'>[victim] falls unconcious for a moment!</span>")
			victim.Unconscious(10)

/datum/component/swimming/proc/start_drowning(mob/living/victim)
	to_chat(victim, "<span class='userdanger'>Water fills your lungs and mouth, you can't breathe!</span>")
	ADD_TRAIT(victim, TRAIT_MUTE, "pool")

/datum/component/swimming/proc/stop_drowning(mob/living/victim)
	victim.emote("cough")
	to_chat(victim, "<span class='notice'>You cough up the last of the water, regaining your ability to speak and breathe clearly!</span>")
	REMOVE_TRAIT(victim, TRAIT_MUTE, "pool")
	ticks_drowned = 0

/datum/component/swimming/proc/enter_pool()
	return

//Essentially the same as remove component, but easier for overiding
/datum/component/swimming/proc/exit_pool()
	return
