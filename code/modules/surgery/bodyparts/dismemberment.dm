
/obj/item/bodypart/proc/can_dismember(obj/item/item)
	if((bodypart_flags & BODYPART_UNREMOVABLE) || (owner && HAS_TRAIT(owner, TRAIT_NODISMEMBER)))
		return FALSE
	return TRUE

///Remove target limb from its owner, with side effects.
/obj/item/bodypart/proc/dismember(dam_type = BRUTE, silent = FALSE)
	if(!owner || (bodypart_flags & BODYPART_UNREMOVABLE))
		return FALSE
	var/mob/living/carbon/limb_owner = owner
	if(HAS_TRAIT(limb_owner, TRAIT_GODMODE) || HAS_TRAIT(limb_owner, TRAIT_NODISMEMBER))
		return FALSE

	var/obj/item/bodypart/affecting = limb_owner.get_bodypart(BODY_ZONE_CHEST)
	affecting.receive_damage(clamp(brute_dam/2 * affecting.body_damage_coeff, 15, 50), clamp(burn_dam/2 * affecting.body_damage_coeff, 0, 50)) //Damage the chest based on limb's existing damage
	if(!silent)
		limb_owner.visible_message(span_danger("<B>[limb_owner]'s [name] is violently dismembered!</B>"))
	INVOKE_ASYNC(limb_owner, TYPE_PROC_REF(/mob, emote), "scream")
	playsound(get_turf(limb_owner), 'sound/effects/dismember.ogg', 80, TRUE)
	SEND_SIGNAL(limb_owner, COMSIG_ADD_MOOD_EVENT, "dismembered", /datum/mood_event/dismembered)

	drop_limb(dismembered = TRUE)

	limb_owner.update_equipment_speed_mods() // Update in case speed affecting item unequipped by dismemberment
	if(can_bleed())
		limb_owner.add_bleeding(BLEED_CRITICAL)

	if(QDELETED(src)) //Could have dropped into lava/explosion/chasm/whatever
		return TRUE
	if(dam_type == BURN)
		burn()
		return TRUE
	if (can_bleed())
		add_mob_blood(limb_owner)
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

/obj/item/bodypart/chest/dismember(dam_type = BRUTE, silent = FALSE)
	if(!owner)
		return FALSE
	var/mob/living/carbon/chest_owner = owner
	if(chest_owner.stat != DEAD) //organs cannot spill from chest whilst living for balance reasons
		return FALSE
	if(bodypart_flags & BODYPART_UNREMOVABLE)
		return FALSE
	if(HAS_TRAIT(chest_owner, TRAIT_NODISMEMBER))
		return FALSE
	. = list()
	if(isturf(chest_owner.loc) && can_bleed())
		chest_owner.add_splatter_floor(chest_owner.loc)
		chest_owner.add_bleeding(BLEED_CRITICAL)
	playsound(get_turf(chest_owner), 'sound/misc/splort.ogg', 80, TRUE)
	for(var/obj/item/organ/organ in contents)
		var/org_zone = check_zone(organ.zone)
		if(org_zone != BODY_ZONE_CHEST)
			continue
		organ.Remove(chest_owner)
		organ.forceMove(chest_owner.loc)
		. += organ

	if(cavity_item)
		cavity_item.forceMove(chest_owner.loc)
		. += cavity_item
		cavity_item = null

///limb removal. The "special" argument is used for swapping a limb with a new one without the effects of losing a limb kicking in.
/obj/item/bodypart/proc/drop_limb(special, dismembered, move_to_floor = TRUE)
	if(!owner)
		return
	var/atom/drop_loc = owner.drop_location()

	SEND_SIGNAL(owner, COMSIG_CARBON_REMOVE_LIMB, src, special, dismembered)
	SEND_SIGNAL(src, COMSIG_BODYPART_REMOVED, owner, special, dismembered)
	bodypart_flags &= ~BODYPART_IMPLANTED //limb is out and about, it can't really be considered an implant
	owner.remove_bodypart(src, special)

	var/mob/living/carbon/phantom_owner = update_owner(null) // so we can still refer to the guy who lost their limb after said limb forgets 'em
	update_limb(dropping_limb = TRUE)

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
				if(mutation.limb_req && (mutation.limb_req == body_zone))
					to_chat(phantom_owner, span_warning("You feel your [mutation] deactivating from the loss of your [body_zone]!"))
					phantom_owner.dna.force_lose(mutation)

	update_icon_dropped()
	phantom_owner.update_health_hud() //update the healthdoll
	phantom_owner.update_body()
	if(!special)
		phantom_owner.hud_used?.update_locked_slots()

	if(bodypart_flags & BODYPART_PSEUDOPART)
		drop_organs(phantom_owner) //Psuedoparts shouldn't have organs, but just in case
		qdel(src)
		return

	if(move_to_floor)
		if(!drop_loc) // drop_loc = null happens when a "dummy human" used for rendering icons on prefs screen gets its limbs replaced.
			qdel(src)
			return
		forceMove(drop_loc)

	SEND_SIGNAL(phantom_owner, COMSIG_CARBON_POST_REMOVE_LIMB, src, special, dismembered)

/obj/item/bodypart/chest/drop_limb(special, dismembered, move_to_floor = TRUE)
	if(special)
		return ..()
	//if this is not a special drop, this is a mistake
	return FALSE

/obj/item/bodypart/arm/drop_limb(special, dismembered, move_to_floor = TRUE)
	var/mob/living/carbon/arm_owner = owner

	if(special || !arm_owner)
		return ..()

	if(arm_owner.hand_bodyparts[held_index] == src)
		// We only want to do this if the limb being removed is the active hand part.
		// This catches situations where limbs are "hot-swapped" such as augmentations and roundstart prosthetics.
		arm_owner.dropItemToGround(arm_owner.get_item_for_held_index(held_index), 1)
	if(arm_owner.handcuffed)
		arm_owner.handcuffed.forceMove(drop_location())
		arm_owner.handcuffed.dropped(arm_owner)
		arm_owner.set_handcuffed(null)
		arm_owner.update_handcuffed()
	if(arm_owner.hud_used)
		var/atom/movable/screen/inventory/hand/associated_hand = arm_owner.hud_used.hand_slots["[held_index]"]
		associated_hand?.update_appearance()
	if(arm_owner.gloves)
		arm_owner.dropItemToGround(arm_owner.gloves, TRUE)
	. = ..()
	arm_owner.update_worn_gloves() //to remove the bloody hands overlay

/obj/item/bodypart/leg/drop_limb(special, dismembered, move_to_floor = TRUE)
	if(owner && !special)
		if(owner.legcuffed)
			owner.legcuffed.forceMove(owner.drop_location()) //At this point bodypart is still in nullspace
			owner.legcuffed.dropped(owner)
			owner.legcuffed = null
			owner.update_worn_legcuffs()
		if(owner.shoes)
			owner.dropItemToGround(owner.shoes, TRUE)
	return ..()

/obj/item/bodypart/head/drop_limb(special, dismembered, move_to_floor = TRUE)
	if(!special)
		//Drop all worn head items
		for(var/obj/item/head_item as anything in list(owner.glasses, owner.ears, owner.wear_mask, owner.head))
			owner.dropItemToGround(head_item, force = TRUE)

	qdel(owner.GetComponent(/datum/component/creamed)) //clean creampie overlay flushed emoji

	//Handle dental implants
	for(var/datum/action/item_action/hands_free/activate_pill/pill_action in owner.actions)
		pill_action.Remove(owner)
		var/obj/pill = UNLINT(pill_action.master)
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

///Checks if a limb qualifies as a BODYPART_IMPLANTED
/obj/item/bodypart/proc/check_for_frankenstein(mob/living/carbon/human/monster)
	if(!istype(monster))
		return FALSE
	var/obj/item/bodypart/original_type = monster.dna.species.bodypart_overrides[body_zone]
	if(!original_type || (limb_id != initial(original_type.limb_id)))
		return TRUE
	return FALSE

///Checks if you can attach a limb, returns TRUE if you can.
/obj/item/bodypart/proc/can_attach_limb(mob/living/carbon/new_limb_owner, special)
	if(SEND_SIGNAL(new_limb_owner, COMSIG_ATTEMPT_CARBON_ATTACH_LIMB, src, special) & COMPONENT_NO_ATTACH)
		return FALSE

	var/obj/item/bodypart/chest/mob_chest = new_limb_owner.get_bodypart(BODY_ZONE_CHEST)
	if(mob_chest && !(mob_chest.acceptable_bodytype & bodytype) && !(mob_chest.acceptable_bodyshape & bodyshape) && !special)
		return FALSE
	return TRUE

///Attach src to target mob if able, returns FALSE if it fails to.
/obj/item/bodypart/proc/try_attach_limb(mob/living/carbon/new_limb_owner, special)
	if(!can_attach_limb(new_limb_owner, special))
		return FALSE

	SEND_SIGNAL(new_limb_owner, COMSIG_CARBON_ATTACH_LIMB, src, special)
	SEND_SIGNAL(src, COMSIG_BODYPART_ATTACHED, new_limb_owner, special)
	new_limb_owner.add_bodypart(src)

	if(special) //non conventional limb attachment
		for(var/datum/surgery/attach_surgery as anything in new_limb_owner.surgeries) //if we had an ongoing surgery to attach a new limb, we stop it.
			var/surgery_zone = check_zone(attach_surgery.location)
			if(surgery_zone == body_zone)
				new_limb_owner.surgeries -= attach_surgery
				qdel(attach_surgery)
				break

		for(var/obj/item/organ/organ as anything in new_limb_owner.organs)
			if(deprecise_zone(organ.zone) != body_zone)
				continue
			organ.bodypart_insert(src)

	update_bodypart_damage_state()
	if(can_be_disabled)
		update_disabled()

	// Bodyparts need to be sorted for leg masking to be done properly. It also will allow for some predictable
	// behavior within said bodyparts list. We sort it here, as it's the only place we make changes to bodyparts.
	new_limb_owner.bodyparts = sort_list(new_limb_owner.bodyparts, GLOBAL_PROC_REF(cmp_bodypart_by_body_part_asc))
	new_limb_owner.updatehealth()
	new_limb_owner.update_body()
	new_limb_owner.update_damage_overlays()
	if(!special)
		new_limb_owner.hud_used?.update_locked_slots()

	SEND_SIGNAL(new_limb_owner, COMSIG_CARBON_POST_ATTACH_LIMB, src, special)
	return TRUE

/obj/item/bodypart/head/try_attach_limb(mob/living/carbon/new_head_owner, special = FALSE)
	// These are stored before calling super. This is so that if the head is from a different body, it persists its appearance.
	var/old_real_name = src.real_name

	. = ..()

	if(!.)
		return

	if(old_real_name)
		new_head_owner.real_name = old_real_name
	real_name = new_head_owner.real_name

	//Handle dental implants
	for(var/obj/item/reagent_containers/pill/pill in src)
		for(var/datum/action/item_action/hands_free/activate_pill/pill_action in pill.actions)
			pill.forceMove(new_head_owner)
			pill_action.Grant(new_head_owner)
			break

	///Transfer existing hair properties to the new human.
	if(!special && ishuman(new_head_owner))
		var/mob/living/carbon/human/sexy_chad = new_head_owner
		sexy_chad.hairstyle = hairstyle
		sexy_chad.hair_color = hair_color
		sexy_chad.facial_hairstyle = facial_hairstyle
		sexy_chad.facial_hair_color = facial_hair_color
		sexy_chad.grad_style = gradient_styles.Copy()
		sexy_chad.grad_color = gradient_colors.Copy()
		sexy_chad.lip_style = lip_style
		sexy_chad.lip_color = lip_color

	new_head_owner.updatehealth()
	new_head_owner.update_body()
	new_head_owner.update_damage_overlays()

/obj/item/bodypart/arm/try_attach_limb(mob/living/carbon/new_arm_owner, special = FALSE)
	. = ..()

	if(!.)
		return

	new_arm_owner.update_worn_gloves() // To apply bloody hands overlay

/mob/living/carbon/proc/regenerate_limbs(list/excluded_zones = list())
	SEND_SIGNAL(src, COMSIG_CARBON_REGENERATE_LIMBS, excluded_zones)
	var/list/zone_list = GLOB.all_body_zones.Copy()

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

		//Copied from /datum/species/proc/on_species_gain()
		for(var/obj/item/organ/organ_path as anything in dna.species.mutant_organs)
			//Load a persons preferences from DNA
			var/zone = initial(organ_path.zone)
			if(zone != limb_zone)
				continue
			var/obj/item/organ/new_organ = SSwardrobe.provide_type(organ_path)
			new_organ.Insert(src)

		update_body_parts()
		return TRUE
