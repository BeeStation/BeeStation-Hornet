/datum/action/changeling/biodegrade
	name = "Biodegrade"
	desc = "Dissolves restraints or other objects preventing free movement. Costs 15 chemicals."
	helptext = "Will immediately remove legcuffs and burn anyone grabbing us. Will break handcuffs and lockers after a short timer."
	button_icon_state = "biodegrade"
	chemical_cost = 15
	dna_cost = 1
	req_human = TRUE

/datum/action/changeling/biodegrade/sting_action(mob/living/carbon/human/user)
	. = FALSE

	if(!HAS_TRAIT(user, TRAIT_RESTRAINED) && isopenturf(user.loc) && !user.legcuffed && !user.pulledby)
		to_chat(user, span_warning("We are already free!"))
		return

	if(user.legcuffed)
		qdel(user.legcuffed)
		. = TRUE

	if(user.pulledby)
		var/mob/living/target = user.pulledby
		to_chat(user, span_changeling("We discrete an acidic solution from our pours onto [user.pulledby]."))
		to_chat(target, span_userdanger("A burning glob of acid pours onto your hand!"))
		target.Paralyze(20)
		target.apply_damage(5, BURN, pick(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND))
		target.emote("scream")
		target.stop_pulling()
		. = TRUE

	if(user.handcuffed)
		var/obj/O = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
		if(istype(O))
			to_chat(user, span_warning("We vomit acidic ooze onto our restraints!"))
			addtimer(CALLBACK(src, PROC_REF(dissolve_handcuffs), user, O), 30)
			. = TRUE

	if(user.wear_suit && user.wear_suit.breakouttime)
		var/obj/item/clothing/suit/S = user.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		if(istype(S))
			to_chat(user, span_warning("We vomit acidic ooze onto our straight jacket!"))
			addtimer(CALLBACK(src, PROC_REF(dissolve_straightjacket), user, S), 30)
			. = TRUE


	if(istype(user.loc, /obj/structure/closet))
		var/obj/structure/closet/C = user.loc
		if(istype(C))
			C.visible_message(span_warning("[C]'s hinges suddenly begin to melt and run!"))
			to_chat(user, span_warning("We vomit acidic goop onto the interior of [C]!"))
			addtimer(CALLBACK(src, PROC_REF(open_closet), user, C), 70)
			. = TRUE

	if(istype(user.loc, /obj/structure/spider/cocoon))
		var/obj/structure/spider/cocoon/C = user.loc
		if(istype(C))
			C.visible_message(span_warning("[src] shifts and starts to fall apart!"))
			to_chat(user, span_warning("We secrete acidic enzymes from our skin and begin melting our cocoon..."))
			addtimer(CALLBACK(src, PROC_REF(dissolve_cocoon), user, C), 25) //Very short because it's just webs
			. = TRUE
	..()

/datum/action/changeling/biodegrade/proc/dissolve_handcuffs(mob/living/carbon/human/user, obj/O)
	if(O && user.handcuffed == O)
		user.visible_message(span_warning("[O] dissolve[O.gender==PLURAL?"":"s"] into a puddle of sizzling goop."))
		new /obj/effect/decal/cleanable/greenglow(O.drop_location())
		qdel(O)

/datum/action/changeling/biodegrade/proc/dissolve_straightjacket(mob/living/carbon/human/user, obj/S)
	if(S && user.wear_suit == S)
		user.visible_message(span_warning("[S] dissolves into a puddle of sizzling goop."))
		new /obj/effect/decal/cleanable/greenglow(S.drop_location())
		qdel(S)

/datum/action/changeling/biodegrade/proc/open_closet(mob/living/carbon/human/user, obj/structure/closet/C)
	if(C && user.loc == C)
		C.visible_message(span_warning("[C]'s door breaks and opens!"))
		new /obj/effect/decal/cleanable/greenglow(C.drop_location())
		C.welded = FALSE
		C.locked = FALSE
		C.broken = TRUE
		C.open()
		to_chat(user, span_warning("We open the container restraining us!"))

/datum/action/changeling/biodegrade/proc/dissolve_cocoon(mob/living/carbon/human/user, obj/structure/spider/cocoon/C)
	if(C && user.loc == C)
		new /obj/effect/decal/cleanable/greenglow(C.drop_location())
		qdel(C) //The cocoon's destroy will move the changeling outside of it without interference
		to_chat(user, span_warning("We dissolve the cocoon!"))
