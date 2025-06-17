/obj/item/organ/zombie_infection
	name = "festering ooze"
	desc = "A black web of pus and viscera."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_ZOMBIE
	icon_state = "blacktumor"
	visual = FALSE
	var/causes_damage = TRUE
	var/datum/species/old_species = /datum/species/human
	var/living_transformation_time = 30
	var/converts_living = FALSE

	var/revive_time_min = 60 SECONDS
	var/revive_time_max = 100 SECONDS
	var/timer_id
	var/zombietype = /datum/species/zombie/infectious

/obj/item/organ/zombie_infection/Initialize(mapload)
	. = ..()
	if(iscarbon(loc))
		Insert(loc)
	GLOB.zombie_infection_list += src

/obj/item/organ/zombie_infection/Destroy()
	GLOB.zombie_infection_list -= src
	. = ..()

/obj/item/organ/zombie_infection/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE, pref_load = FALSE)
	. = ..()
	if(!.)
		return .
	START_PROCESSING(SSobj, src)

/obj/item/organ/zombie_infection/Remove(mob/living/carbon/M, special = 0, pref_load = FALSE)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	if(iszombie(M) && old_species && !QDELETED(M) && !special)
		M.set_species(old_species)
	if(timer_id)
		deltimer(timer_id)

/obj/item/organ/zombie_infection/on_find(mob/living/finder)
	to_chat(finder, span_warning("Inside the head is a disgusting black web of pus and viscera, bound tightly around the brain like some biological harness."))

/obj/item/organ/zombie_infection/process(delta_time)
	if(!owner)
		return
	if(!(src in owner.internal_organs))
		Remove(owner, TRUE)
	if(MOB_INORGANIC in owner.mob_biotypes)//does not process in inorganic things
		return
	if (causes_damage && !iszombie(owner) && owner.stat != DEAD)
		owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1 * delta_time)
	if(timer_id)
		return
	if(owner.suiciding)
		return
	if(owner.stat != DEAD && !converts_living)
		return
	if(!owner.get_organ_by_type(/obj/item/organ/brain))
		return
	if(!iszombie(owner))
		to_chat(owner, span_cultlarge("You can feel your heart stopping, but something isn't right... \
		life has not abandoned your broken form. You can only feel a deep and immutable hunger that \
		not even death can stop, you will rise again!"))
	var/revive_time = rand(revive_time_min, revive_time_max)
	var/flags = TIMER_STOPPABLE
	timer_id = addtimer(CALLBACK(src, PROC_REF(zombify), owner), revive_time, flags)

/obj/item/organ/zombie_infection/proc/zombify(var/mob/living/carbon/C)
	timer_id = null

	if(!converts_living && owner.stat != DEAD)
		return

	if(!iszombie(owner))
		old_species = owner.dna.species.type
		C.set_species(zombietype)

	var/stand_up = (C.stat == DEAD) || (C.stat == UNCONSCIOUS)

	//Fully heal the zombie's damage the first time they rise
	C.setOrganLoss(ORGAN_SLOT_BRAIN, 0)
	if(C.heal_and_revive(0, span_danger("[C] suddenly convulses, as [C.p_they()][stand_up ? " stagger to [C.p_their()] feet and" : ""] gain a ravenous hunger in [C.p_their()] eyes!")))
		return
	C.grab_ghost()

	to_chat(C, span_alien("You HUNGER!"))
	to_chat(C, span_alertalien("You are now a zombie! Do not seek to be cured, do not help any non-zombies in any way, do not harm your zombie brethren and spread the disease by killing others. You are a creature of hunger and violence."))
	playsound(C, 'sound/hallucinations/far_noise.ogg', 50, 1)
	if(C.handcuffed)
		C.visible_message(span_danger("[owner] continues convulsing breaking free of [owner.p_their()] restraints!"))
		C.uncuff()
	C.do_jitter_animation(living_transformation_time)
	C.Stun(living_transformation_time)

/obj/item/organ/zombie_infection/nodamage
	causes_damage = FALSE

/obj/item/organ/zombie_infection/virus
	zombietype = /datum/species/zombie/infectious/viral
