/obj/item/bodypart
	name = "limb"
	desc = "Why is it detached..."
	force = 3
	throwforce = 3
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/mob/human/bodyparts.dmi'
	icon_state = "" //Leave this blank! Bodyparts are built using overlays
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1 //actually mindblowing
	/// The icon for Organic limbs using greyscale
	VAR_PROTECTED/icon_greyscale = DEFAULT_BODYPART_ICON_ORGANIC
	///The icon for non-greyscale limbs
	VAR_PROTECTED/icon_static = 'icons/mob/human/bodyparts.dmi'
	///The icon for husked limbs
	VAR_PROTECTED/icon_husk = 'icons/mob/human/bodyparts.dmi'
	///The type of husk for building an iconstate
	var/husk_type = "humanoid"
	///The color to multiply the greyscaled husk sprites by. Can be null. Old husk sprite chest color is #A6A6A6
	var/husk_color = "#A6A6A6"
	layer = BELOW_MOB_LAYER //so it isn't hidden behind objects when on the floor
	/// The mob that "owns" this limb
	/// DO NOT MODIFY DIRECTLY. Use update_owner()
	var/mob/living/carbon/owner

	var/needs_processing = FALSE

	///A bitfield of bodytypes for surgery, and misc information
	var/bodytype = BODYTYPE_ORGANIC
	///A bitfield of bodyshapes for clothing and other sprite information
	var/bodyshape = BODYSHAPE_HUMANOID
	///Defines when a bodypart should not be changed. Example: BP_BLOCK_CHANGE_SPECIES prevents the limb from being overwritten on species gain
	var/change_exempt_flags = NONE
	///Random flags that describe this bodypart
	var/bodypart_flags = NONE

	var/is_husked = FALSE
	///The ID of a species used to generate the icon. Needs to match the icon_state portion in the limbs file!
	var/limb_id = SPECIES_HUMAN
	//Defines what sprite the limb should use if it is also sexually dimorphic.
	var/limb_gender = "m"
	///Is there a sprite difference between male and female?
	var/is_dimorphic = FALSE
	///The actual color a limb is drawn as, set by /proc/update_limb()
	var/draw_color //NEVER. EVER. EDIT THIS VALUE OUTSIDE OF UPDATE_LIMB. I WILL FIND YOU. It ruins the limb icon pipeline.

	/// BODY_ZONE_CHEST, BODY_ZONE_L_ARM, etc , used for def_zone
	var/body_zone
	/// The body zone of this part in english ("chest", "left arm", etc) without the species attached to it
	var/plaintext_zone
	var/aux_zone // used for hands
	var/aux_layer = BODYPARTS_LAYER
	/// bitflag used to check which clothes cover this bodypart
	var/body_part
	/// List of obj/item's embedded inside us. Managed by embedded components, do not modify directly
	var/list/embedded_objects = list()
	/// are we a hand? if so, which one!
	var/held_index = 0
	/// A speed modifier we apply to the owner when attached, if any. Positive numbers make it move slower, negative numbers make it move faster.
	var/movespeed_contribution = 0

	// Limb disabling variables
	///Whether it is possible for the limb to be disabled whatsoever. TRUE means that it is possible.
	var/can_be_disabled = FALSE //Defaults to FALSE, as only human limbs can be disabled, and only the appendages.
	///Controls if the limb is disabled. TRUE means it is disabled (similar to being removed, but still present for the sake of targeted interactions).
	var/bodypart_disabled = FALSE

	// Damage variables
	///A mutiplication of the burn and brute damage that the limb's stored damage contributes to its attached mob's overall wellbeing.
	var/body_damage_coeff = 1
	///Multiplier of the limb's stamina damage that gets applied to the mob. Why is this 0.75 by default? Good question!
	var/stam_damage_coeff = 0.75
	///The current amount of brute damage the limb has
	var/brute_dam = 0
	///The current amount of burn damage the limb has
	var/burn_dam = 0
	///The current amount of stamina damage the limb has
	var/stamina_dam = 0
	///The maximum stamina damage a bodypart can take
	var/max_stamina_damage = 0
	///The maximum "physical" damage a bodypart can take. Set by children
	var/max_damage = 0
	//Stamina heal multiplier
	var/stamina_heal_rate = 1

	//Used in determining overlays for limb damage states. As the mob receives more burn/brute damage, their limbs update to reflect.
	var/brutestate = 0
	var/burnstate = 0

	//Multiplicative damage modifiers
	/// Brute damage gets multiplied by this on receive_damage()
	var/brute_modifier = 1
	/// Burn damage gets multiplied by this on receive_damage()
	var/burn_modifier = 1
	/// Stamina damage gets multiplied by this on receive_damage()
	var/stamina_modifier = 1
	/// Stun damage gets multiplied by this on receive_damage()
	//var/stun_modifier = 1 (this should probably be here. TODO: implement this on limbs rather than species, jackass)

	// Damage reduction variables for damage handled on the limb level. Handled after worn armor.
	/// Amount subtracted from brute damage inflicted on the limb.
	var/brute_reduction = 0
	/// Amount subtracted from burn damage inflicted on the limb.
	var/burn_reduction = 0

	//Coloring and proper item icon update
	var/skin_tone = ""
	var/species_color = ""
	///Limbs need this information as a back-up incase they are generated outside of a carbon (limbgrower)
	var/should_draw_greyscale = TRUE
	/// An assoc list of priority (as a string because byond) -> color, used to override draw_color.
	var/list/color_overrides
	/// The colour of damage done to this bodypart
	var/damage_color = ""
	/// Should we even use a color?
	var/use_damage_color = FALSE

	var/px_x = 0
	var/px_y = 0

	///the type of damage overlay (if any) to use when this bodypart is bruised/burned.
	var/dmg_overlay_type = "human"
	///a color (optionally matrix) for the damage overlays to give the limb
	var/damage_overlay_color

	//Damage messages used by help_shake_act()
	var/light_brute_msg = "bruised"
	var/medium_brute_msg = "battered"
	var/heavy_brute_msg = "mangled"

	var/light_burn_msg = "numb"
	var/medium_burn_msg = "blistered"
	var/heavy_burn_msg = "peeling away"

	/// So we know if we need to scream if this limb hits max damage
	var/last_maxed

	///A list of all bodypart overlays to draw
	var/list/bodypart_overlays = list()

	/// Type of an attack from this limb does. Arms will do punches, Legs for kicks, and head for bites. (TO ADD: tactical chestbumps)
	var/attack_type = BRUTE
	/// the verb used for an unarmed attack when using this limb, such as arm.unarmed_attack_verb = punch
	var/unarmed_attack_verb = "bump"
	/// what visual effect is used when this limb is used to strike someone.
	var/unarmed_attack_effect = ATTACK_EFFECT_PUNCH
	/// Sounds when this bodypart is used in an umarmed attack
	var/sound/unarmed_attack_sound = 'sound/weapons/punch1.ogg'
	var/sound/unarmed_miss_sound = 'sound/weapons/punchmiss.ogg'
	///punch damage this bodypart can give.
	var/unarmed_damage = 1

	/// Traits that are given to the holder of the part. If you want an effect that changes this, don't add directly to this. Use the add_bodypart_trait() proc
	var/list/bodypart_traits = list()
	/// The name of the trait source that the organ gives. Should not be altered during the events of gameplay, and will cause problems if it is.
	var/bodypart_trait_source = BODYPART_TRAIT
	/// List of the above datums which have actually been instantiated, managed automatically
	var/list/feature_offsets = list()

	/// A potential texturing overlay to put on the limb
	var/datum/bodypart_overlay/texture/texture_bodypart_overlay

/obj/item/bodypart/Initialize(mapload)
	. = ..()
	if(can_be_disabled)
		RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS), PROC_REF(on_paralysis_trait_gain))
		RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS), PROC_REF(on_paralysis_trait_loss))

	RegisterSignal(src, COMSIG_ATOM_RESTYLE, PROC_REF(on_attempt_feature_restyle))

	if(texture_bodypart_overlay)
		texture_bodypart_overlay = new texture_bodypart_overlay()
		add_bodypart_overlay(texture_bodypart_overlay)

	name = "[limb_id] [parse_zone(body_zone)]"
	if(is_dimorphic)
		limb_gender = pick("m", "f")
	update_icon_dropped()

/obj/item/bodypart/add_context_self(datum/screentip_context/context, mob/user, atom/target)
	if(istype(context.held_item, /obj/item/clothing/accessory))
		context.add_right_click_action("Color Limb")

/obj/item/bodypart/Destroy()
	if(owner && !QDELETED(owner))
		forced_removal(special = FALSE, dismembered = TRUE, move_to_floor = FALSE)
		update_owner(null)
	/*
	for(var/wound in wounds)
		qdel(wound) // wounds is a lazylist, and each wound removes itself from it on deletion.
	if(length(wounds))
		stack_trace("[type] qdeleted with [length(wounds)] uncleared wounds")
		wounds.Cut()
	*/

	owner = null

	for(var/atom/movable/movable in contents)
		qdel(movable)

	QDEL_LIST_ASSOC_VAL(feature_offsets)

	return ..()

/obj/item/bodypart/ex_act(severity, target)
	if(owner) //trust me bro you dont want this
		return FALSE
	return  ..()

/obj/item/bodypart/proc/on_forced_removal(atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	forced_removal(special = FALSE, dismembered = TRUE, move_to_floor = FALSE)

/// In-case someone, somehow only teleports someones limb
/obj/item/bodypart/proc/forced_removal(special, dismembered, move_to_floor)
	drop_limb(special, dismembered, move_to_floor)

	update_icon_dropped()

/obj/item/bodypart/examine(mob/user)
	SHOULD_CALL_PARENT(TRUE)

	. = ..()
	if(brute_dam >= DAMAGE_PRECISION)
		. += span_warning("This limb has [brute_dam > 30 ? "severe" : "minor"] bruising.")
	if(burn_dam >= DAMAGE_PRECISION)
		. += span_warning("This limb has [burn_dam > 30 ? "severe" : "minor"] burns.")

	/*
	for(var/datum/wound/wound as anything in wounds)
		var/wound_desc = wound.get_limb_examine_description()
		if(wound_desc)
			. += wound_desc
	*/

/**
 * Called when a bodypart is checked for injuries.
 *
 * Modifies the check_list list with the resulting report of the limb's status.
 */
/obj/item/bodypart/proc/check_for_injuries(mob/living/carbon/human/examiner, list/check_list)

	var/list/limb_damage = list(BRUTE = brute_dam, BURN = burn_dam)

	SEND_SIGNAL(src, COMSIG_BODYPART_CHECKED_FOR_INJURY, examiner, check_list, limb_damage)
	SEND_SIGNAL(examiner, COMSIG_CARBON_CHECKING_BODYPART, src, check_list, limb_damage)

	var/shown_brute = limb_damage[BRUTE]
	var/shown_burn = limb_damage[BURN]
	var/status = ""
	var/self_aware = HAS_TRAIT(examiner, TRAIT_SELF_AWARE)

	if(self_aware)
		if(!shown_brute && !shown_burn)
			status = "no damage"
		else
			status = "[shown_brute] brute damage and [shown_burn] burn damage"

	else
		if(shown_brute > (max_damage * 0.8))
			status += heavy_brute_msg
		else if(shown_brute > (max_damage * 0.4))
			status += medium_brute_msg
		else if(shown_brute > DAMAGE_PRECISION)
			status += light_brute_msg

		if(shown_brute > DAMAGE_PRECISION && shown_burn > DAMAGE_PRECISION)
			status += " and "

		if(shown_burn > (max_damage * 0.8))
			status += heavy_burn_msg
		else if(shown_burn > (max_damage * 0.2))
			status += medium_burn_msg
		else if(shown_burn > DAMAGE_PRECISION)
			status += light_burn_msg

		if(status == "")
			status = "OK"

	var/no_damage
	if(status == "OK" || status == "no damage")
		no_damage = TRUE

	var/is_disabled = ""
	if(bodypart_disabled)
		is_disabled = " is disabled"
		if(no_damage)
			is_disabled += " but otherwise"
		else
			is_disabled += " and"

	check_list += "\t <span class='[no_damage ? "notice" : "warning"]'>Your [name][is_disabled][self_aware ? " has " : " is "][status].</span>"

	/*
	for(var/datum/wound/wound as anything in wounds)
		switch(wound.severity)
			if(WOUND_SEVERITY_TRIVIAL)
				check_list += "\t [span_danger("Your [name] is suffering [wound.a_or_from] [LOWER_TEXT(wound.name)].")]"
			if(WOUND_SEVERITY_MODERATE)
				check_list += "\t [span_warning("Your [name] is suffering [wound.a_or_from] [LOWER_TEXT(wound.name)]!")]"
			if(WOUND_SEVERITY_SEVERE)
				check_list += "\t [span_boldwarning("Your [name] is suffering [wound.a_or_from] [LOWER_TEXT(wound.name)]!")]"
			if(WOUND_SEVERITY_CRITICAL)
				check_list += "\t [span_boldwarning("Your [name] is suffering [wound.a_or_from] [LOWER_TEXT(wound.name)]!!")]"
	*/

	for(var/obj/item/embedded_thing in embedded_objects)
		var/stuck_word = embedded_thing.isEmbedHarmless() ? "stuck" : "embedded"
		check_list += "\t<a href='byond://?src=[REF(examiner)];embedded_object=[REF(embedded_thing)];embedded_limb=[REF(src)]' class='warning'>There is \a [embedded_thing] [stuck_word] in your [name]!</a>"

/obj/item/bodypart/blob_act()
	receive_damage(max_damage)

/obj/item/bodypart/attack(mob/living/carbon/victim, mob/user)
	SHOULD_CALL_PARENT(TRUE)

	if(ishuman(victim))
		var/mob/living/carbon/human/human_victim = victim
		if(HAS_TRAIT(victim, TRAIT_LIMBATTACHMENT))
			if(!human_victim.get_bodypart(body_zone))
				user.temporarilyRemoveItemFromInventory(src, TRUE)
				if(!try_attach_limb(victim))
					to_chat(user, span_warning("[human_victim]'s body rejects [src]!"))
					forceMove(human_victim.loc)
					return
				if(check_for_frankenstein(victim))
					bodypart_flags |= BODYPART_IMPLANTED
				if(human_victim == user)
					human_victim.visible_message(span_warning("[human_victim] jams [src] into [human_victim.p_their()] empty socket!"),\
					span_notice("You force [src] into your empty socket, and it locks into place!"))
				else
					human_victim.visible_message(span_warning("[user] jams [src] into [human_victim]'s empty socket!"),\
					span_notice("[user] forces [src] into your empty socket, and it locks into place!"))
				return
	return ..()

/obj/item/bodypart/attackby(obj/item/W, mob/user, params)
	SHOULD_CALL_PARENT(TRUE)

	if(W.get_sharpness())
		add_fingerprint(user)
		if(!contents.len)
			to_chat(user, span_warning("There is nothing left inside [src]!"))
			return
		playsound(loc, 'sound/weapons/slice.ogg', 50, TRUE, -1)
		user.visible_message(span_warning("[user] begins to cut open [src]."),\
			span_notice("You begin to cut open [src]..."))
		if(do_after(user, 54, target = src))
			drop_organs(user, TRUE)
	else
		return ..()

/obj/item/bodypart/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	SHOULD_CALL_PARENT(TRUE)

	..()
	if(IS_ORGANIC_LIMB(src))
		playsound(get_turf(src), 'sound/misc/splort.ogg', 50, TRUE, -1)
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3)

//empties the bodypart from its organs and other things inside it
/obj/item/bodypart/proc/drop_organs(mob/user, violent_removal)
	SHOULD_CALL_PARENT(TRUE)

	var/atom/drop_loc = drop_location()
	if(IS_ORGANIC_LIMB(src))
		playsound(drop_loc, 'sound/misc/splort.ogg', 50, TRUE, -1)

	for(var/obj/item/organ/bodypart_organ in contents)
		if(bodypart_organ.organ_flags & ORGAN_UNREMOVABLE)
			continue
		if(owner)
			bodypart_organ.Remove(bodypart_organ.owner)
		else
			if(bodypart_organ.bodypart_remove(src))
				if(drop_loc) //can be null if being deleted
					bodypart_organ.forceMove(get_turf(drop_loc))

	if(drop_loc) //can be null during deletion
		for(var/atom/movable/movable as anything in src)
			movable.forceMove(drop_loc)

	update_icon_dropped()

//Return TRUE to get whatever mob this is in to update health.
/obj/item/bodypart/proc/on_life(delta_time, times_fired, stam_regen)
	SHOULD_CALL_PARENT(TRUE)
	//DO NOT update health here, it'll be done in the carbon's life.
	if(stamina_dam >= DAMAGE_PRECISION && stam_regen)
		heal_damage(0, 0, stam_regen, null, FALSE)
		. |= BODYPART_LIFE_UPDATE_HEALTH

/**
 * #receive_damage
 *
 * called when a bodypart is taking damage
 * Damage will not exceed max_damage using this proc, and negative damage cannot be used to heal
 * Returns TRUE if damage icon states changes
 * Args:
 * brute - The amount of brute damage dealt.
 * burn - The amount of burn damage dealt.
 * blocked - The amount of damage blocked by armor.
 * update_health - Whether to update the owner's health from receiving the hit.
 * required_bodytype - A bodytype flag requirement to get this damage (ex: BODYTYPE_ORGANIC)
 * sharpness - Flag on whether the attack is edged or pointy
 * attack_direction - The direction the bodypart is attacked from, used to send blood flying in the opposite direction.
 * damage_source - The source of damage, typically a weapon.
 */
/obj/item/bodypart/proc/receive_damage(brute = 0, burn = 0, stamina = 0, blocked = 0, updating_health = TRUE, forced = FALSE, required_bodytype = null, sharpness = NONE, attack_direction = null, damage_source)
	SHOULD_CALL_PARENT(TRUE)

	var/hit_percent = forced ? 1 : (100-blocked)/100
	if((!brute && !burn && !stamina) || hit_percent <= 0)
		return FALSE
	if (!forced)
		if(!isnull(owner))
			if (HAS_TRAIT(owner, TRAIT_GODMODE))
				return FALSE
			if (SEND_SIGNAL(owner, COMSIG_CARBON_LIMB_DAMAGED, src, brute, burn) & COMPONENT_PREVENT_LIMB_DAMAGE)
				return FALSE
		if(required_bodytype && !(bodytype & required_bodytype))
			return FALSE

	var/dmg_multi = CONFIG_GET(number/damage_multiplier) * hit_percent
	brute = round(max(brute * dmg_multi * brute_modifier, 0), DAMAGE_PRECISION)
	burn = round(max(burn * dmg_multi * burn_modifier, 0), DAMAGE_PRECISION)
	stamina = round(max(stamina * dmg_multi * stamina_modifier, 0), DAMAGE_PRECISION)

	brute = max(0, brute - brute_reduction)
	burn = max(0, burn - burn_reduction)
	//No stamina scaling.. for now..

	if(!brute && !burn && !stamina)
		return FALSE

	if(bodytype & (BODYTYPE_ALIEN|BODYTYPE_LARVA_PLACEHOLDER)) //aliens take double burn //nothing can burn with so much snowflake code around
		burn *= 2

	var/can_inflict = (max_damage * 2) - get_damage()
	if(can_inflict <= 0)
		return FALSE
	var/total_damage = brute + burn
	if(total_damage > can_inflict)
		brute = round(brute * (can_inflict / total_damage),DAMAGE_PRECISION)
		burn = round(burn * (can_inflict / total_damage),DAMAGE_PRECISION)

	if(brute)
		set_brute_dam(brute_dam + brute)
	if(burn)
		set_burn_dam(burn_dam + burn)

	//We've dealt the physical damages, if there's room lets apply the stamina damage.
	if(stamina)
		set_stamina_dam(stamina_dam + round(clamp(stamina, 0, max_stamina_damage - stamina_dam), DAMAGE_PRECISION))

	if(owner)
		if(can_be_disabled)
			update_disabled()
		if(updating_health)
			owner.updatehealth()
			if(stamina >= DAMAGE_PRECISION)
				owner.update_stamina(TRUE)
				owner.stam_regen_start_time = max(owner.stam_regen_start_time, world.time + STAMINA_REGEN_BLOCK_TIME)
				. = TRUE
	return update_bodypart_damage_state() || .

//Heals brute and burn damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/bodypart/proc/heal_damage(brute, burn, stamina, updating_health = TRUE, forced = FALSE, required_bodytype)
	SHOULD_CALL_PARENT(TRUE)

	if(!forced && required_bodytype && !(bodytype & required_bodytype)) //So we can only heal certain kinds of limbs, ie robotic vs organic.
		return

	if(brute)
		set_brute_dam(round(max(brute_dam - brute, 0), DAMAGE_PRECISION))
	if(burn)
		set_burn_dam(round(max(burn_dam - burn, 0), DAMAGE_PRECISION))
	if(stamina)
		set_stamina_dam(round(max(stamina_dam - stamina, 0), DAMAGE_PRECISION))

	if(owner)
		if(can_be_disabled)
			update_disabled()
		if(updating_health)
			owner.updatehealth()
		if(owner.dna?.species && (TRAIT_REVIVESBYHEALING in owner.dna.species.inherent_traits))
			if(owner.health > 0 && owner.stat == DEAD)
				owner.revive()
				owner.cure_husk(0) // If it has REVIVESBYHEALING, it probably can't be cloned. No husk cure.
	return update_bodypart_damage_state()

///Proc to hook behavior associated to the change of the brute_dam variable's value.
/obj/item/bodypart/proc/set_brute_dam(new_value)
	PROTECTED_PROC(TRUE)

	if(brute_dam == new_value)
		return
	. = brute_dam
	brute_dam = new_value


///Proc to hook behavior associated to the change of the burn_dam variable's value.
/obj/item/bodypart/proc/set_burn_dam(new_value)
	PROTECTED_PROC(TRUE)

	if(burn_dam == new_value)
		return
	. = burn_dam
	burn_dam = new_value


///Proc to hook behavior associated to the change of the stamina_dam variable's value.
/obj/item/bodypart/proc/set_stamina_dam(new_value)
	PROTECTED_PROC(TRUE)

	if(stamina_dam == new_value)
		return
	. = stamina_dam
	stamina_dam = new_value
	if(stamina_dam > DAMAGE_PRECISION)
		needs_processing = TRUE
	else
		needs_processing = FALSE

//Returns total damage.
/obj/item/bodypart/proc/get_damage(include_stamina = FALSE)
	return include_stamina ? max(brute_dam + burn_dam, stamina_dam) : brute_dam + burn_dam

//Returns only stamina damage.
/obj/item/bodypart/proc/get_staminaloss()
	return stamina_dam

//Checks disabled status thresholds
/obj/item/bodypart/proc/update_disabled()
	SHOULD_CALL_PARENT(TRUE)

	if(!owner)
		return

	if(!can_be_disabled)
		set_disabled(FALSE)
		CRASH("update_disabled called with can_be_disabled false")

	if(HAS_TRAIT(src, TRAIT_PARALYSIS))
		set_disabled(TRUE)
		return

	var/total_damage = max(brute_dam + burn_dam, stamina_dam)
	var/disable_threshold = 1

	if(HAS_TRAIT(owner, TRAIT_EASYLIMBDISABLE))
		disable_threshold = 0.6 //Easy limb disable disables the limb at 40% health instead of 0%

	if(total_damage >= max_damage * disable_threshold)
		if(!last_maxed)
			if(owner.stat < UNCONSCIOUS)
				INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), "scream")
			last_maxed = TRUE
		set_disabled(TRUE)
		return

	if(bodypart_disabled && total_damage <= max_damage * 0.5)
		last_maxed = FALSE
		set_disabled(FALSE)

///Proc to change the value of the `disabled` variable and react to the event of its change.
/obj/item/bodypart/proc/set_disabled(new_disabled)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)

	if(bodypart_disabled == new_disabled)
		return
	. = bodypart_disabled
	bodypart_disabled = new_disabled

	if(!owner)
		return
	owner.update_health_hud() //update the healthdoll
	owner.update_body()

/// Proc to change the value of the `owner` variable and react to the event of its change.
/obj/item/bodypart/proc/update_owner(new_owner)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(owner == new_owner)
		return FALSE //`null` is a valid option, so we need to use a num var to make it clear no change was made.

	SEND_SIGNAL(src, COMSIG_BODYPART_CHANGED_OWNER, new_owner, owner)

	if(owner)
		. = owner //return value is old owner
		clear_ownership(owner)
	if(new_owner)
		apply_ownership(new_owner)

	return .

/// Run all necessary procs to remove a limbs ownership and remove the appropriate signals and traits
/obj/item/bodypart/proc/clear_ownership(mob/living/carbon/old_owner)
	SHOULD_CALL_PARENT(TRUE)

	owner = null

	if(movespeed_contribution)
		old_owner.update_bodypart_movespeed_contribution()
	if(length(bodypart_traits))
		old_owner.remove_traits(bodypart_traits, bodypart_trait_source)

	UnregisterSignal(old_owner, list(
		SIGNAL_REMOVETRAIT(TRAIT_NOLIMBDISABLE),
	SIGNAL_ADDTRAIT(TRAIT_NOLIMBDISABLE),
		SIGNAL_REMOVETRAIT(TRAIT_NOBLOOD),
		SIGNAL_ADDTRAIT(TRAIT_NOBLOOD),
		))

	UnregisterSignal(old_owner, COMSIG_ATOM_RESTYLE)

/// Apply ownership of a limb to someone, giving the appropriate traits, updates and signals
/obj/item/bodypart/proc/apply_ownership(mob/living/carbon/new_owner)
	SHOULD_CALL_PARENT(TRUE)

	owner = new_owner

	if(movespeed_contribution)
		owner.update_bodypart_movespeed_contribution()
	if(length(bodypart_traits))
		owner.add_traits(bodypart_traits, bodypart_trait_source)

	if(initial(can_be_disabled))
		if(HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE))
			set_can_be_disabled(FALSE)

		// Listen to disable traits being added
		RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_NOLIMBDISABLE), PROC_REF(on_owner_nolimbdisable_trait_loss))
		RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_NOLIMBDISABLE), PROC_REF(on_owner_nolimbdisable_trait_gain))

	if(can_be_disabled)
		update_disabled()

	RegisterSignal(owner, COMSIG_ATOM_RESTYLE, PROC_REF(on_attempt_feature_restyle_mob))

	forceMove(owner)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_forced_removal)) //this must be set after we moved, or we insta gib

/// Called on addition of a bodypart
/obj/item/bodypart/proc/on_adding(mob/living/carbon/new_owner)
	SHOULD_CALL_PARENT(TRUE)

	item_flags |= ABSTRACT
	ADD_TRAIT(src, TRAIT_NODROP, ORGAN_INSIDE_BODY_TRAIT)

/// Called on removal of a bodypart.
/obj/item/bodypart/proc/on_removal(mob/living/carbon/old_owner)
	SHOULD_CALL_PARENT(TRUE)

	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

	item_flags &= ~ABSTRACT
	REMOVE_TRAIT(src, TRAIT_NODROP, ORGAN_INSIDE_BODY_TRAIT)

	if(!length(bodypart_traits))
		return

	owner.remove_traits(bodypart_traits, bodypart_trait_source)

///Proc to change the value of the `can_be_disabled` variable and react to the event of its change.
/obj/item/bodypart/proc/set_can_be_disabled(new_can_be_disabled)
	PROTECTED_PROC(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(can_be_disabled == new_can_be_disabled)
		return
	. = can_be_disabled
	can_be_disabled = new_can_be_disabled
	if(can_be_disabled)
		if(owner)
			if(HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE))
				CRASH("set_can_be_disabled to TRUE with for limb whose owner has TRAIT_NOLIMBDISABLE")
			RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS), PROC_REF(on_paralysis_trait_gain))
			RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS), PROC_REF(on_paralysis_trait_loss))
		update_disabled()
	else if(.)
		if(owner)
			UnregisterSignal(owner, list(
				SIGNAL_ADDTRAIT(TRAIT_PARALYSIS),
				SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS),
				))
		set_disabled(FALSE)


///Called when TRAIT_PARALYSIS is added to the limb.
/obj/item/bodypart/proc/on_paralysis_trait_gain(obj/item/bodypart/source)
	PROTECTED_PROC(TRUE)
	SIGNAL_HANDLER

	if(can_be_disabled)
		set_disabled(TRUE)


///Called when TRAIT_PARALYSIS is removed from the limb.
/obj/item/bodypart/proc/on_paralysis_trait_loss(obj/item/bodypart/source)
	PROTECTED_PROC(TRUE)
	SIGNAL_HANDLER

	if(can_be_disabled)
		update_disabled()


///Called when TRAIT_NOLIMBDISABLE is added to the owner.
/obj/item/bodypart/proc/on_owner_nolimbdisable_trait_gain(mob/living/carbon/source)
	PROTECTED_PROC(TRUE)
	SIGNAL_HANDLER

	set_can_be_disabled(FALSE)


///Called when TRAIT_NOLIMBDISABLE is removed from the owner.
/obj/item/bodypart/proc/on_owner_nolimbdisable_trait_loss(mob/living/carbon/source)
	PROTECTED_PROC(TRUE)
	SIGNAL_HANDLER

	set_can_be_disabled(initial(can_be_disabled))

//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/bodypart/proc/update_bodypart_damage_state()
	SHOULD_CALL_PARENT(TRUE)

	var/tbrute = round((min(brute_dam, max_damage) / max_damage) * 3, 1)
	var/tburn = round((min(burn_dam, max_damage) / max_damage) * 3, 1)
	if((tbrute != brutestate) || (tburn != burnstate))
		brutestate = tbrute
		burnstate = tburn
		return TRUE
	return FALSE

//we inform the bodypart of the changes that happened to the owner, or give it the informations from a source mob.
//set is_creating to true if you want to change the appearance of the limb outside of mutation changes or forced changes.
/obj/item/bodypart/proc/update_limb(dropping_limb = FALSE, is_creating = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	if(IS_ORGANIC_LIMB(src))
		if(owner && HAS_TRAIT(owner, TRAIT_HUSK))
			dmg_overlay_type = "" //no damage overlay shown when husked
			is_husked = TRUE
		else
			dmg_overlay_type = initial(dmg_overlay_type)
			is_husked = FALSE

	update_draw_color()

	if(!is_creating || !owner)
		return

	// There should technically to be an ishuman(owner) check here, but it is absent because no basetype carbons use bodyparts
	// No, xenos don't actually use bodyparts. Don't ask.
	var/mob/living/carbon/human/human_owner = owner

	if(!ismonkey(human_owner)) //temporary. Fuck monkeys
		limb_gender = (human_owner.physique == MALE) ? "m" : "f"

	if(HAS_TRAIT(human_owner, TRAIT_USES_SKINTONES))
		skin_tone = human_owner.skin_tone
	else if(HAS_TRAIT(human_owner, TRAIT_MUTANT_COLORS))
		skin_tone = ""
		var/datum/species/owner_species = human_owner.dna.species
		if(owner_species.fixed_mut_color)
			species_color = owner_species.fixed_mut_color
		else
			species_color = human_owner.dna.features["mcolor"]
	else
		skin_tone = ""
		species_color = ""

	update_draw_color()

	// Recolors mutant overlays to match new mutant colors
	for(var/datum/bodypart_overlay/mutant/overlay in bodypart_overlays)
		overlay.inherit_color(src, force = TRUE)
	// Ensures marking overlays are updated accordingly as well
	for(var/datum/bodypart_overlay/simple/body_marking/marking in bodypart_overlays)
		marking.set_appearance(human_owner.dna.features[marking.dna_feature_key], species_color)

	return TRUE

/obj/item/bodypart/proc/update_draw_color()
	draw_color = null
	if(LAZYLEN(color_overrides))
		var/priority
		for (var/override_priority in color_overrides)
			if (text2num(override_priority) > priority)
				priority = text2num(override_priority)
				draw_color = color_overrides[override_priority]
		return
	if(should_draw_greyscale)
		draw_color = species_color || (skin_tone ? skintone2hex(skin_tone) : null)

/obj/item/bodypart/proc/add_color_override(new_color, color_priority)
	LAZYSET(color_overrides, "[color_priority]", new_color)

/obj/item/bodypart/proc/remove_color_override(color_priority)
	LAZYREMOVE(color_overrides, "[color_priority]")

//to update the bodypart's icon when not attached to a mob
/obj/item/bodypart/proc/update_icon_dropped()
	SHOULD_CALL_PARENT(TRUE)

	cut_overlays()
	var/list/standing = get_limb_icon(TRUE)
	if(!standing.len)
		icon_state = initial(icon_state)//no overlays found, we default back to initial icon.
		return
	for(var/image/img as anything in standing)
		img.pixel_x = px_x
		img.pixel_y = px_y
	add_overlay(standing)

///Generates an /image for the limb to be used as an overlay
/obj/item/bodypart/proc/get_limb_icon(dropped)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	icon_state = "" //to erase the default sprite, we're building the visual aspects of the bodypart through overlays alone.

	. = list()

	//Handles dropped icons
	var/image_dir = NONE
	if(dropped)
		image_dir = SOUTH
		if(dmg_overlay_type)
			if(brutestate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_[brutestate]0", CALCULATE_MOB_OVERLAY_LAYER(DAMAGE_LAYER), image_dir)
			if(burnstate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_0[burnstate]", CALCULATE_MOB_OVERLAY_LAYER(DAMAGE_LAYER), image_dir)

	var/image/limb = image(layer = CALCULATE_MOB_OVERLAY_LAYER(BODYPARTS_LAYER), dir = image_dir)
	var/image/aux

	// Normal non-husk handling
	// This is the MEAT of limb icon code
	limb.icon = icon_greyscale
	if(!should_draw_greyscale || !icon_greyscale)
		limb.icon = icon_static

	if(is_dimorphic) //Does this type of limb have sexual dimorphism?
		limb.icon_state = "[limb_id]_[body_zone]_[limb_gender]"
	else
		limb.icon_state = "[limb_id]_[body_zone]"

	icon_exists_or_scream(limb.icon, limb.icon_state) //Prints a stack trace on the first failure of a given iconstate.

	. += limb

	if(aux_zone) //Hand shit
		aux = image(limb.icon, "[limb_id]_[aux_zone]", CALCULATE_MOB_OVERLAY_LAYER(aux_layer), image_dir)
		. += aux

	update_draw_color()

	if(is_husked)
		huskify_image(thing_to_husk = limb)
		if(aux)
			huskify_image(thing_to_husk = aux)
		draw_color = husk_color
	if(draw_color)
		limb.color = "[draw_color]"
		if(aux_zone)
			aux.color = "[draw_color]"

	//EMISSIVE CODE START
		// For some reason this was applied as an overlay on the aux image and limb image before.
		// I am very sure that this is unnecessary, and i need to treat it as part of the return list
		// to be able to mask it proper in case this limb is a leg.
	if(!is_husked)
		if(blocks_emissive)
			var/atom/location = loc || owner || src
			var/mutable_appearance/limb_em_block = emissive_blocker(limb.icon, limb.icon_state, location, layer = CALCULATE_MOB_OVERLAY_LAYER(limb.layer), alpha = limb.alpha)
			limb_em_block.dir = image_dir
			. += limb_em_block

			if(aux_zone)
				var/mutable_appearance/aux_em_block = emissive_blocker(aux.icon, aux.icon_state, location, layer = CALCULATE_MOB_OVERLAY_LAYER(aux.layer), alpha = aux.alpha)
				aux_em_block.dir = image_dir
				. += aux_em_block
		//EMISSIVE CODE END

	//No need to handle leg layering if dropped, we only face south anyways
	if(!dropped && ((body_zone == BODY_ZONE_R_LEG) || (body_zone == BODY_ZONE_L_LEG)))
		//Legs are a bit goofy in regards to layering, and we will need two images instead of one to fix that
		var/obj/item/bodypart/leg/leg_source = src
		for(var/image/limb_image in .)
			//remove the old, unmasked image
			. -= limb_image
			//add two masked images based on the old one
			. += leg_source.generate_masked_leg(limb_image, image_dir)

	// And finally put bodypart_overlays on if not husked
	if(!is_husked)
		//Draw external organs like horns and frills
		for(var/datum/bodypart_overlay/overlay as anything in bodypart_overlays)
			if(!overlay.can_draw_on_bodypart(src, owner))
				continue
			//Some externals have multiple layers for background, foreground and between
			for(var/external_layer in overlay.all_layers)
				if(overlay.layers & external_layer)
					//to_chat(world, "setting organ [src] with layer [external_layer], bitflag [overlay.bitflag_to_layer(external_layer)]")
					. += overlay.get_overlay(external_layer, src)
			for(var/datum/layer in .)
				overlay.modify_bodypart_appearance(layer)
	return .

/obj/item/bodypart/proc/huskify_image(image/thing_to_husk, draw_blood = TRUE)
	var/icon/husk_icon = new(thing_to_husk.icon)
	husk_icon.ColorTone(HUSK_COLOR_TONE)
	thing_to_husk.icon = husk_icon
	if(draw_blood)
		var/mutable_appearance/husk_blood = mutable_appearance(icon_husk, "[husk_type]_husk_[body_zone]")
		husk_blood.blend_mode = BLEND_INSET_OVERLAY
		husk_blood.appearance_flags |= RESET_COLOR
		husk_blood.dir = thing_to_husk.dir
		thing_to_husk.add_overlay(husk_blood)

///Add a bodypart overlay and call the appropriate update procs
/obj/item/bodypart/proc/add_bodypart_overlay(datum/bodypart_overlay/overlay, update = TRUE)
	bodypart_overlays += overlay
	overlay.added_to_limb(src)
	if(!update)
		return
	if(!owner)
		update_icon_dropped()
	else if(!(owner.living_flags & STOP_OVERLAY_UPDATE_BODY_PARTS))
		owner.update_body_parts()

///Remove a bodypart overlay and call the appropriate update procs
/obj/item/bodypart/proc/remove_bodypart_overlay(datum/bodypart_overlay/overlay, update = TRUE)
	bodypart_overlays -= overlay
	overlay.removed_from_limb(src)
	if(!update)
		return
	if(!owner)
		update_icon_dropped()
	else if(!(owner.living_flags & STOP_OVERLAY_UPDATE_BODY_PARTS))
		owner.update_body_parts()

/obj/item/bodypart/deconstruct(disassembled = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	drop_organs()
	return ..()

/// INTERNAL PROC, DO NOT USE
/// Properly sets us up to manage an inserted embeded object
/obj/item/bodypart/proc/_embed_object(obj/item/embed)
	if(embed in embedded_objects) // go away
		return
	// We don't need to do anything with projectile embedding, because it will never reach this point
	embedded_objects += embed

/// INTERNAL PROC, DO NOT USE
/// Cleans up any attachment we have to the embedded object, removes it from our list
/obj/item/bodypart/proc/_unembed_object(obj/item/unembed)
	embedded_objects -= unembed

//A multi-purpose setter for all things immediately important to the icon and iconstate of the limb.
/obj/item/bodypart/proc/change_appearance(icon, id, greyscale, dimorphic)
	var/icon_holder
	if(greyscale)
		icon_greyscale = icon
		icon_holder = icon
		should_draw_greyscale = TRUE
	else
		icon_static = icon
		icon_holder = icon
		should_draw_greyscale = FALSE

	if(id) //limb_id should never be falsey
		limb_id = id

	if(!isnull(dimorphic))
		is_dimorphic = dimorphic

	if(!owner)
		update_icon_dropped()
	else if(!(owner.living_flags & STOP_OVERLAY_UPDATE_BODY_PARTS))
		owner.update_body_parts()

	//This foot gun needs a safety
	if(!icon_exists(icon_holder, "[limb_id]_[body_zone][is_dimorphic ? "_[limb_gender]" : ""]"))
		reset_appearance()
		stack_trace("change_appearance([icon], [id], [greyscale], [dimorphic]) generated null icon")

///Resets the base appearance of a limb to it's default values.
/obj/item/bodypart/proc/reset_appearance()
	icon_static = initial(icon_static)
	icon_greyscale = initial(icon_greyscale)
	limb_id = initial(limb_id)
	is_dimorphic = initial(is_dimorphic)
	should_draw_greyscale = initial(should_draw_greyscale)

	if(!owner)
		update_icon_dropped()
	else if(!(owner.living_flags & STOP_OVERLAY_UPDATE_BODY_PARTS))
		owner.update_body_parts()

// Note: For effects on subtypes, use the emp_effect() proc instead
/obj/item/bodypart/emp_act(severity)
	var/protection = ..()
	// If the limb doesn't protect contents, strike them first
	if(!(protection & EMP_PROTECT_CONTENTS))
		for(var/atom/content as anything in contents)
			content.emp_act(severity)

	if((protection & (EMP_PROTECT_WIRES | EMP_PROTECT_SELF)))
		return protection

	emp_effect(severity, protection)
	return protection

/// The actual effect of EMPs on the limb. Allows children to override it however they want
/obj/item/bodypart/proc/emp_effect(severity, protection)
	if(!IS_ROBOTIC_LIMB(src))
		return FALSE

	// - EMPs pierce armor, disable limbs, and usually have splash damage
	var/time_needed = AUGGED_LIMB_EMP_PARALYZE_TIME
	var/brute_damage = AUGGED_LIMB_EMP_BRUTE_DAMAGE
	var/burn_damage = AUGGED_LIMB_EMP_BURN_DAMAGE
	var/stamina_damage = 0

	if(severity == EMP_HEAVY)
		time_needed *= 2
		brute_damage *= 2
		burn_damage *= 2

	receive_damage(brute_damage, burn_damage)
	do_sparks(number = 1, cardinal_only = FALSE, source = owner || src)

	// Only disable the limb if it's already damaged (makes damaged augs more vulnerable)
	if(can_be_disabled && (get_damage() / max_damage) >= ROBOTIC_EMP_PARALYZE_DAMAGE_THRESHOLD)
		// Calculate stamina damage needed to disable based on current damage
		var/damage_ratio = get_damage() / max_damage
		stamina_damage = max_stamina_damage * (damage_ratio + 0.3) // Scale with existing damage
		receive_damage(stamina = stamina_damage)
		// Heal the stamina damage after the timer expires
		addtimer(CALLBACK(src, PROC_REF(heal_emp_damage), stamina_damage), time_needed)
		owner?.visible_message(span_danger("[owner]'s [plaintext_zone] seems to malfunction!"))

	if(HAS_TRAIT(owner, TRAIT_EASYDISMEMBER) && (body_zone != BODY_ZONE_CHEST))
		if(prob(5))
			dismember(BRUTE)

	return TRUE

/obj/item/bodypart/proc/heal_emp_damage(amount)
	heal_damage(stamina = amount)

/obj/item/bodypart/proc/can_bleed()
	SHOULD_BE_PURE(TRUE)

	return /*((biological_state & BIO_BLOODED) &&*/ (!owner || !HAS_TRAIT(owner, TRAIT_NOBLOOD))
