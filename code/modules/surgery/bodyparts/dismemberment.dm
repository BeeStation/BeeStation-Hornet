
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
	if(C.status_flags & GODMODE)
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


/obj/item/bodypart/chest/dismember()
	if(!owner)
		return FALSE
	var/mob/living/carbon/chest_owner = owner
	if(!dismemberable)
		return FALSE
	if(HAS_TRAIT(chest_owner, TRAIT_NODISMEMBER))
		return FALSE
	. = list()
	if(isturf(chest_owner.loc))
		chest_owner.add_splatter_floor(chest_owner.loc)
	chest_owner.add_bleeding(BLEED_CRITICAL)
	playsound(get_turf(chest_owner), 'sound/misc/splort.ogg', 80, TRUE)
	for(var/obj/item/organ/organ as anything in chest_owner.organs)
		var/org_zone = check_zone(organ.zone)
		if(org_zone != BODY_ZONE_CHEST)
			continue
		organ.Remove(chest_owner)
		organ.forceMove(chest_owner.loc)
		. += organ

	for(var/obj/item/organ/external/ext_organ as anything in src.external_organs)
		if(!(ext_organ.organ_flags & ORGAN_UNREMOVABLE))
			ext_organ.Remove(chest_owner)
			ext_organ.forceMove(chest_owner.loc)
			. += ext_organ

	if(cavity_item)
		cavity_item.forceMove(chest_owner.loc)
		. += cavity_item
		cavity_item = null

//limb removal. The "special" argument is used for swapping a limb with a new one without the effects of losing a limb kicking in.
/obj/item/bodypart/proc/drop_limb(special, dismembered)
	if(!owner)
		return
	var/atom/drop_loc = owner.drop_location()

	SEND_SIGNAL(owner, COMSIG_CARBON_REMOVE_LIMB, src, dismembered)
	SEND_SIGNAL(src, COMSIG_BODYPART_REMOVED, owner, dismembered)
	update_limb(dropping_limb = TRUE)
	owner.remove_bodypart(src)

	if(held_index)
		if(owner.hand_bodyparts[held_index] == src)
			// We only want to do this if the limb being removed is the active hand part.
			// This catches situations where limbs are "hot-swapped" such as augmentations and roundstart prosthetics.
			owner.dropItemToGround(owner.get_item_for_held_index(held_index), 1)
			owner.hand_bodyparts[held_index] = null

	for(var/obj/item/organ/external/ext_organ as anything in external_organs)
		ext_organ.transfer_to_limb(src, null) //Null is the second arg because the bodypart is being removed from it's owner.

	var/mob/living/carbon/phantom_owner = set_owner(null) // so we can still refer to the guy who lost their limb after said limb forgets 'em

	for(var/datum/surgery/surgery as anything in phantom_owner.surgeries) //if we had an ongoing surgery on that limb, we stop it.
		if(surgery.operated_bodypart == src)
			phantom_owner.surgeries -= surgery
			qdel(surgery)
			break

	for(var/obj/item/embedded in embedded_objects)
		embedded.forceMove(src) // It'll self remove via signal reaction, just need to move it
	if(!phantom_owner.has_embedded_objects())
		phantom_owner.clear_alert("embeddedobject")
		SEND_SIGNAL(phantom_owner, COMSIG_CLEAR_MOOD_EVENT, "embedded")

	if(!special)
		if(phantom_owner.dna)
			for(var/datum/mutation/human/mutation as anything in phantom_owner.dna.mutations) //some mutations require having specific limbs to be kept.
				if(mutation.limb_req && mutation.limb_req == body_zone)
					to_chat(phantom_owner, span_warning("You feel your [mutation] deactivating from the loss of your [body_zone]!"))
					phantom_owner.dna.force_lose(mutation)

		for(var/obj/item/organ/organ as anything in phantom_owner.organs) //internal organs inside the dismembered limb are dropped.
			var/org_zone = check_zone(organ.zone)
			if(org_zone != body_zone)
				continue
			organ.transfer_to_limb(src, phantom_owner)

	update_icon_dropped()
	phantom_owner.update_health_hud() //update the healthdoll
	phantom_owner.update_body()
	phantom_owner.update_body_parts()

	if(!drop_loc) // drop_loc = null happens when a "dummy human" used for rendering icons on prefs screen gets its limbs replaced.
		qdel(src)
		return

	if(is_pseudopart)
		drop_organs(phantom_owner) //Psuedoparts shouldn't have organs, but just in case
		qdel(src)
		return

	forceMove(drop_loc)
	SEND_SIGNAL(phantom_owner, COMSIG_CARBON_POST_REMOVE_LIMB, src, dismembered)


///Transfers the organ to the limb, and to the limb's owner, if it has one. This is done on drop_limb().
/obj/item/organ/proc/transfer_to_limb(obj/item/bodypart/bodypart, mob/living/carbon/bodypart_owner)
	Remove(bodypart_owner)
	add_to_limb(bodypart)

///Adds the organ to a bodypart, used in transfer_to_limb()
/obj/item/organ/proc/add_to_limb(obj/item/bodypart/bodypart)
	forceMove(bodypart)

///Removes the organ from the limb, placing it into nullspace.
/obj/item/organ/proc/remove_from_limb()
	moveToNullspace()

/obj/item/organ/internal/brain/transfer_to_limb(obj/item/bodypart/head/head, mob/living/carbon/human/head_owner)
	Remove(head_owner) //Changeling brain concerns are now handled in Remove
	forceMove(head)
	head.brain = src
	if(brainmob)
		head.brainmob = brainmob
		brainmob = null
		head.brainmob.forceMove(head)
		head.brainmob.set_stat(DEAD)

/obj/item/organ/internal/eyes/transfer_to_limb(obj/item/bodypart/head/LB, mob/living/carbon/human/C)
	LB.eyes = src
	..()

/obj/item/organ/internal/ears/transfer_to_limb(obj/item/bodypart/head/LB, mob/living/carbon/human/C)
	LB.ears = src
	..()

/obj/item/organ/internal/tongue/transfer_to_limb(obj/item/bodypart/head/LB, mob/living/carbon/human/C)
	LB.tongue = src
	..()

/obj/item/bodypart/chest/drop_limb(special)
	if(special)
		return ..()
	//if this is not a special drop, this is a mistake
	return FALSE

/obj/item/bodypart/r_arm/drop_limb(special)
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


/obj/item/bodypart/l_arm/drop_limb(special)
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


/obj/item/bodypart/r_leg/drop_limb(special)
	if(owner && !special)
		if(owner.legcuffed)
			owner.legcuffed.forceMove(owner.drop_location()) //At this point bodypart is still in nullspace
			owner.legcuffed.dropped(owner)
			owner.legcuffed = null
			owner.update_worn_legcuffs()
		if(owner.shoes)
			owner.dropItemToGround(owner.shoes, TRUE)
	return ..()

/obj/item/bodypart/l_leg/drop_limb(special) //copypasta
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
	SEND_SIGNAL(src, COMSIG_BODYPART_ATTACHED, new_limb_owner, special)
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
		limb_organ.Insert(new_limb_owner, TRUE)

	update_bodypart_damage_state()
	if(can_be_disabled)
		update_disabled()

	new_limb_owner.updatehealth()
	new_limb_owner.update_body()
	new_limb_owner.update_damage_overlays()
	SEND_SIGNAL(new_limb_owner, COMSIG_CARBON_POST_ATTACH_LIMB, src, special)
	return TRUE


/obj/item/bodypart/head/try_attach_limb(mob/living/carbon/new_head_owner, special = FALSE)
	var/old_real_name = src.real_name

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

	if(old_real_name)
		new_head_owner.real_name = old_real_name
	real_name = new_head_owner.real_name

	//Handle dental implants
	for(var/obj/item/reagent_containers/pill/P in src)
		for(var/datum/action/item_action/hands_free/activate_pill/AP in P.actions)
			P.forceMove(new_head_owner)
			AP.Grant(new_head_owner)
			break

	///Transfer existing hair properties to the new human.
	if(!special && ishuman(new_head_owner))
		var/mob/living/carbon/human/sexy_chad = new_head_owner
		sexy_chad.hairstyle = hairstyle
		sexy_chad.hair_color = hair_color

		sexy_chad.facial_hairstyle = facial_hairstyle
		sexy_chad.facial_hair_color = facial_hair_color
		sexy_chad.grad_style = gradient_styles?.Copy()
		sexy_chad.grad_color = gradient_colors?.Copy()
		sexy_chad.lip_style = lip_style
		sexy_chad.lip_color = lip_color

	new_head_owner.updatehealth()
	new_head_owner.update_body()
	new_head_owner.update_damage_overlays()

//Regenerates all limbs. Returns amount of limbs regenerated
/mob/living/proc/regenerate_limbs(list/excluded_zones = list())
	SEND_SIGNAL(src, COMSIG_LIVING_REGENERATE_LIMBS, excluded_zones)

/mob/living/carbon/regenerate_limbs(list/excluded_zones = list())
	SEND_SIGNAL(src, COMSIG_LIVING_REGENERATE_LIMBS, excluded_zones)
	var/list/zone_list = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	if(length(excluded_zones))
		zone_list -= excluded_zones
	for(var/limb_zone in zone_list)
		regenerate_limb(limb_zone)

/mob/living/proc/regenerate_limb(limb_zone)
	return

/mob/living/carbon/regenerate_limb(limb_zone)
	var/obj/item/bodypart/limb
	if(get_bodypart(limb_zone))
		return FALSE
	limb = newBodyPart(limb_zone, 0, 0)
	if(limb)
		if(!limb.try_attach_limb(src, TRUE))
			qdel(limb)
			return FALSE
		limb.update_limb(is_creating = TRUE)

		//Copied from /datum/species/proc/on_species_gain()
		for(var/obj/item/organ/external/organ_path as anything in dna.species.external_organs)
			//Load a persons preferences from DNA
			var/zone = initial(organ_path.zone)
			if(zone != limb_zone)
				continue
			var/obj/item/organ/external/new_organ = SSwardrobe.provide_type(organ_path)
			new_organ.Insert(src)

		update_body_parts()
		return TRUE
