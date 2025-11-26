
/obj/item/bodypart/proc/can_dismember(obj/item/I)
	if(dismemberable)
		return TRUE

///Remove target limb from it's owner, with side effects.
/obj/item/bodypart/proc/dismember(dam_type = BRUTE)
	if(!owner)
		return FALSE
	var/mob/living/carbon/C = owner
	if(!dismemberable)
		return FALSE
	if(HAS_TRAIT(C, TRAIT_GODMODE))
		return FALSE
	if(HAS_TRAIT(C, TRAIT_NODISMEMBER))
		return FALSE

	var/obj/item/bodypart/affecting = C.get_bodypart(BODY_ZONE_CHEST)
	affecting.receive_damage(clamp(brute_dam/2 * affecting.body_damage_coeff, 15, 50), clamp(burn_dam/2 * affecting.body_damage_coeff, 0, 50)) //Damage the chest based on limb's existing damage
	C.visible_message(span_danger("<B>[C]'s [src.name] has been violently dismembered!</B>"))

	if(C.stat <= SOFT_CRIT)//No more screaming while unconsious
		if(IS_ORGANIC_LIMB(affecting))//Chest is a good indicator for if a carbon is robotic in nature or not.
			C.emote("scream")

	SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "dismembered", /datum/mood_event/dismembered)
	drop_limb()

	C.update_equipment_speed_mods() // Update in case speed affecting item unequipped by dismemberment
	C.add_bleeding(BLEED_CRITICAL)

	if(QDELETED(src)) //Could have dropped into lava/explosion/chasm/whatever
		return TRUE
	if(dam_type == BURN)
		burn()
		return TRUE
	add_mob_blood(C)
	var/direction = pick(GLOB.cardinals)
	var/t_range = rand(2,max(throw_range/2, 2))
	var/turf/target_turf = get_turf(src)
	for(var/i in 1 to t_range-1)
		var/turf/new_turf = get_step(target_turf, direction)
		if(!new_turf)
			break
		target_turf = new_turf
		if(new_turf.density)
			break
	throw_at(target_turf, throw_range, throw_speed)
	return TRUE

/obj/item/bodypart/head/dismember()
	if(!owner)
		return FALSE
	var/mob/living/carbon/C = owner
	if(C.stat == CONSCIOUS) //Beheading can only happen to someone who has at least fallen into crit for balance reasons
		return FALSE
	. = ..()

/obj/item/bodypart/chest/dismember()
	if(!owner)
		return FALSE
	var/mob/living/carbon/C = owner
	if(!dismemberable || C.stat != DEAD) //Organs spilling out of the chest cannot happen before death for player sanity reasons
		return FALSE
	if(HAS_TRAIT(C, TRAIT_NODISMEMBER))
		return FALSE
	. = list()
	var/turf/T = get_turf(C)
	C.add_bleeding(BLEED_CRITICAL)
	playsound(get_turf(C), 'sound/misc/splort.ogg', 80, 1)
	for(var/X in C.internal_organs)
		var/obj/item/organ/O = X
		var/org_zone = check_zone(O.zone)
		if(org_zone != BODY_ZONE_CHEST)
			continue
		O.Remove(C)
		O.forceMove(T)
		. += X
	if(cavity_item)
		cavity_item.forceMove(T)
		. += cavity_item
		cavity_item = null

//limb removal. The "special" argument is used for swapping a limb with a new one without the effects of losing a limb kicking in.
/obj/item/bodypart/proc/drop_limb(special, dismembered)
	if(!owner)
		return
	var/atom/Tsec = owner.drop_location()
	var/mob/living/carbon/C = owner
	SEND_SIGNAL(owner, COMSIG_CARBON_REMOVE_LIMB, src, dismembered)
	SEND_SIGNAL(src, COMSIG_BODYPART_REMOVED, owner, dismembered)
	update_limb(TRUE)
	C.remove_bodypart(src)

	if(held_index)
		C.dropItemToGround(owner.get_item_for_held_index(held_index), 1)
		C.hand_bodyparts[held_index] = null

	owner = null

	for(var/X in C.surgeries) //if we had an ongoing surgery on that limb, we stop it.
		var/datum/surgery/S = X
		if(S.operated_bodypart == src)
			C.surgeries -= S
			qdel(S)
			break

	for(var/obj/item/I in embedded_objects)
		embedded_objects -= I
		I.forceMove(src)
	if(!C.has_embedded_objects())
		C.clear_alert("embeddedobject")
		SEND_SIGNAL(C, COMSIG_CLEAR_MOOD_EVENT, "embedded")

	if(!special)
		if(C.dna)
			for(var/datum/mutation/MT as() in C.dna.mutations) //some mutations require having specific limbs to be kept.
				if(MT.limb_req && MT.limb_req == body_zone)
					C.dna.force_lose(MT)

		for(var/X in C.internal_organs) //internal organs inside the dismembered limb are dropped.
			var/obj/item/organ/O = X
			var/org_zone = check_zone(O.zone)
			if(org_zone != body_zone)
				continue
			O.transfer_to_limb(src, C)


	synchronize_bodytypes(C)

	update_icon_dropped()
	C.update_health_hud() //update the healthdoll
	C.update_body()
	C.update_hair()
	if(!special)
		C.hud_used?.update_locked_slots()

	if(!Tsec)	// Tsec = null happens when a "dummy human" used for rendering icons on prefs screen gets its limbs replaced.
		qdel(src)
		return

	if(is_pseudopart)
		drop_organs(C)	//Psuedoparts shouldn't have organs, but just in case
		qdel(src)
		return

	forceMove(Tsec)
	SEND_SIGNAL(C, COMSIG_CARBON_POST_REMOVE_LIMB, src, dismembered)


//when a limb is dropped, the internal organs are removed from the mob and put into the limb
/obj/item/organ/proc/transfer_to_limb(obj/item/bodypart/LB, mob/living/carbon/C)
	Remove(C, TRUE)
	forceMove(LB)

/obj/item/organ/brain/transfer_to_limb(obj/item/bodypart/head/LB, mob/living/carbon/human/C)
	Remove(C)	//Changeling brain concerns are now handled in Remove
	forceMove(LB)
	LB.brain = src
	if(brainmob)
		LB.brainmob = brainmob
		brainmob = null
		LB.brainmob.forceMove(LB)
		LB.brainmob.set_stat(DEAD)

/obj/item/organ/eyes/transfer_to_limb(obj/item/bodypart/head/LB, mob/living/carbon/human/C)
	LB.eyes = src
	..()

/obj/item/organ/ears/transfer_to_limb(obj/item/bodypart/head/LB, mob/living/carbon/human/C)
	LB.ears = src
	..()

/obj/item/organ/tongue/transfer_to_limb(obj/item/bodypart/head/LB, mob/living/carbon/human/C)
	LB.tongue = src
	..()

/obj/item/bodypart/chest/drop_limb(special)
	if(special)
		return ..()

/obj/item/bodypart/arm/right/drop_limb(special)
	. = ..()

	var/mob/living/carbon/C = owner
	if(C && !special)
		if(C.handcuffed)
			C.handcuffed.forceMove(drop_location())
			C.handcuffed.dropped(C)
			C.set_handcuffed(null)
			C.update_handcuffed()
		if(C.hud_used)
			var/atom/movable/screen/inventory/hand/R = C.hud_used.hand_slots["[held_index]"]
			if(R)
				R.update_icon()
		if(C.gloves)
			C.dropItemToGround(C.gloves, TRUE)
		C.update_worn_gloves() //to remove the bloody hands overlay


/obj/item/bodypart/arm/left/drop_limb(special)
	. = ..()

	var/mob/living/carbon/C = owner
	if(C && !special)
		if(C.handcuffed)
			C.handcuffed.forceMove(drop_location())
			C.handcuffed.dropped(C)
			C.set_handcuffed(null)
			C.update_handcuffed()
		if(C.hud_used)
			var/atom/movable/screen/inventory/hand/L = C.hud_used.hand_slots["[held_index]"]
			if(L)
				L.update_icon()
		if(C.gloves)
			C.dropItemToGround(C.gloves, TRUE)
		C.update_worn_gloves() //to remove the bloody hands overlay


/obj/item/bodypart/leg/right/drop_limb(special)
	if(owner && !special)
		if(owner.legcuffed)
			owner.legcuffed.forceMove(owner.drop_location()) //At this point bodypart is still in nullspace
			owner.legcuffed.dropped(owner)
			owner.legcuffed = null
			owner.update_worn_legcuffs()
		if(owner.shoes)
			owner.dropItemToGround(owner.shoes, TRUE)
	return ..()

/obj/item/bodypart/leg/left/drop_limb(special) //copypasta
	if(owner && !special)
		if(owner.legcuffed)
			owner.legcuffed.forceMove(owner.drop_location())
			owner.legcuffed.dropped(owner)
			owner.legcuffed = null
			owner.update_worn_legcuffs()
		if(owner.shoes)
			owner.dropItemToGround(owner.shoes, TRUE)
	return ..()

/obj/item/bodypart/head/drop_limb(special)
	if(!special)
		//Drop all worn head items
		for(var/X in list(owner.glasses, owner.ears, owner.wear_mask, owner.head))
			var/obj/item/I = X
			owner.dropItemToGround(I, TRUE)

	//Remove the creampie overlay
	qdel(owner.GetComponent(/datum/component/creamed))

	//Handle dental implants
	for(var/datum/action/item_action/hands_free/activate_pill/AP in owner.actions)
		AP.Remove(owner)
		var/obj/pill = UNLINT(AP.master)
		if(pill)
			pill.forceMove(src)

	name = owner ? "[owner.real_name]'s head" : "unknown [limb_id] head"
	return ..()

///Try to attach this bodypart to a mob, while replacing one if it exists, does nothing if it fails.
/obj/item/bodypart/proc/replace_limb(mob/living/carbon/limb_owner, special)
	if(!istype(limb_owner))
		return
	var/obj/item/bodypart/old_limb = limb_owner.get_bodypart(body_zone)
	if(old_limb)
		old_limb.drop_limb(TRUE)

	. = try_attach_limb(limb_owner, special)
	if(!.) //If it failed to replace, re-attach their old limb as if nothing happened.
		old_limb.try_attach_limb(limb_owner, TRUE)

///Checks if you can attach a limb, returns TRUE if you can.
/obj/item/bodypart/proc/can_attach_limb(mob/living/carbon/new_limb_owner, special, is_creating = FALSE)
	if(SEND_SIGNAL(new_limb_owner, COMSIG_ATTEMPT_CARBON_ATTACH_LIMB, src, special) & COMPONENT_NO_ATTACH)
		return FALSE

	var/obj/item/bodypart/chest/mob_chest = new_limb_owner.get_bodypart(BODY_ZONE_CHEST)
	if(mob_chest && !(mob_chest.acceptable_bodytype & bodytype) && !special)
		return FALSE
	return TRUE

///Attach src to target mob if able, returns FALSE if it fails to.
/obj/item/bodypart/proc/try_attach_limb(mob/living/carbon/new_limb_owner, special)
	if(!can_attach_limb(new_limb_owner, special))
		return FALSE

	SEND_SIGNAL(new_limb_owner, COMSIG_CARBON_ATTACH_LIMB, src, special)
	moveToNullspace()
	set_owner(new_limb_owner)
	new_limb_owner.add_bodypart(src)
	if(held_index)
		if(held_index > new_limb_owner.hand_bodyparts.len)
			new_limb_owner.hand_bodyparts.len = held_index
		new_limb_owner.hand_bodyparts[held_index] = src
		if(new_limb_owner.dna.species.mutanthands && !is_pseudopart)
			new_limb_owner.put_in_hand(new new_limb_owner.dna.species.mutanthands(), held_index)
		if(new_limb_owner.hud_used)
			var/atom/movable/screen/inventory/hand/hand = new_limb_owner.hud_used.hand_slots["[held_index]"]
			if(hand)
				hand.update_icon()
		new_limb_owner.update_worn_gloves()

	if(special) //non conventional limb attachment
		for(var/datum/surgery/attach_surgery as anything in new_limb_owner.surgeries) //if we had an ongoing surgery to attach a new limb, we stop it.
			var/surgery_zone = check_zone(attach_surgery.location)
			if(surgery_zone == body_zone)
				new_limb_owner.surgeries -= attach_surgery
				qdel(attach_surgery)
				break

	for(var/obj/item/organ/limb_organ in contents)
		limb_organ.Insert(new_limb_owner)

	update_bodypart_damage_state()
	if(can_be_disabled)
		update_disabled()

	synchronize_bodytypes(new_limb_owner)
	new_limb_owner.updatehealth()
	new_limb_owner.update_body()
	new_limb_owner.update_hair()
	new_limb_owner.update_damage_overlays()
	if(!special)
		new_limb_owner.hud_used?.update_locked_slots()
	SEND_SIGNAL(new_limb_owner, COMSIG_CARBON_POST_ATTACH_LIMB, src, special)
	return TRUE


/obj/item/bodypart/head/try_attach_limb(mob/living/carbon/new_head_owner, special = FALSE, abort = FALSE)
	var/real_name = src.real_name

	. = ..()
	if(!.)
		return

	//Transfer some head appearance vars over
	if(brain)
		if(brainmob)
			brainmob.container = null //Reset brainmob head var.
			brainmob.forceMove(brain) //Throw mob into brain.
			brain.brainmob = brainmob //Set the brain to use the brainmob
			brainmob = null //Set head brainmob var to null
		brain.Insert(new_head_owner) //Now insert the brain proper
		brain = null //No more brain in the head

	if(tongue)
		tongue = null
	if(ears)
		ears = null
	if(eyes)
		eyes = null

	if(real_name)
		new_head_owner.real_name = real_name
	real_name = ""

	if(!special && ishuman(new_head_owner))
		var/mob/living/carbon/human/H = new_head_owner
		H.hair_color = hair_color
		H.hair_style = hair_style
		H.facial_hair_color = facial_hair_color
		H.facial_hair_style = facial_hair_style
		H.lip_style = lip_style
		H.lip_color = lip_color

	//Handle dental implants
	for(var/obj/item/reagent_containers/pill/P in src)
		for(var/datum/action/item_action/hands_free/activate_pill/AP in P.actions)
			P.forceMove(new_head_owner)
			AP.Grant(new_head_owner)
			break

	new_head_owner.updatehealth()
	new_head_owner.update_body()
	new_head_owner.update_hair()
	new_head_owner.update_damage_overlays()

///Makes sure that the owner's bodytype flags match the flags of all of it's parts.
/obj/item/bodypart/proc/synchronize_bodytypes(mob/living/carbon/carbon_owner)
	if(!carbon_owner?.dna?.species) //carbon_owner and dna can somehow be null during garbage collection, at which point we don't care anyway.
		return
	//This codeblock makes sure that the owner's bodytype flags match the flags of all of it's parts.
	var/all_limb_flags
	for(var/obj/item/bodypart/limb as anything in carbon_owner.bodyparts)
		//for(var/obj/item/organ/external/ext_organ as anything in limb.external_organs)
		//	all_limb_flags = all_limb_flags | ext_organ.external_bodytypes
		all_limb_flags = all_limb_flags | limb.bodytype

	carbon_owner.dna.species.bodytype = all_limb_flags

/mob/living/carbon/proc/regenerate_limbs(list/excluded_zones = list())
	SEND_SIGNAL(src, COMSIG_CARBON_REGENERATE_LIMBS, excluded_zones)
	var/list/zone_list = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	if(length(excluded_zones))
		zone_list -= excluded_zones
	for(var/limb_zone in zone_list)
		regenerate_limb(limb_zone)

/mob/living/carbon/proc/regenerate_limb(limb_zone)
	var/obj/item/bodypart/limb
	if(get_bodypart(limb_zone))
		return FALSE
	limb = newBodyPart(limb_zone, 0, 0)
	if(limb)
		if(!limb.try_attach_limb(src, TRUE))
			qdel(limb)
			return FALSE
		limb.update_limb(is_creating = TRUE)

		update_body_parts()
		return TRUE
