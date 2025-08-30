
/obj/item/bodypart
	name = "limb"
	desc = "Why is it detached..."
	force = 3
	throwforce = 3
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/mob/species/human/bodyparts.dmi'
	icon_state = ""
	/// The icon for Organic limbs using greyscale
	VAR_PROTECTED/icon_greyscale = DEFAULT_BODYPART_ICON_ORGANIC
	///The icon for non-greyscale limbs
	var/icon_static = 'icons/mob/species/human/bodyparts.dmi'
	///The icon for husked limbs
	VAR_PROTECTED/icon_husk = 'icons/mob/species/human/bodyparts.dmi'
	///The type of husk for building an iconstate
	var/husk_type = "humanoid"
	layer = BELOW_MOB_LAYER //so it isn't hidden behind objects when on the floor
	/// The mob that "owns" this limb
	/// DO NOT MODIFY DIRECTLY. Use set_owner()
	var/mob/living/carbon/owner
	var/datum/weakref/original_owner
	var/needs_processing = TRUE
	///A bitfield of bodytypes for clothing, surgery, and misc information
	var/bodytype = BODYTYPE_HUMANOID | BODYTYPE_ORGANIC
	/// Flags that represent how this bodypart cirulates blood
	var/circulation_flags = CIRCULATION_BLOOD
	///Defines when a bodypart should not be changed. Example: BP_BLOCK_CHANGE_SPECIES prevents the limb from being overwritten on species gain
	var/change_exempt_flags
	///Whether the bodypart (and the owner) is husked.
	var/is_husked = FALSE
	///The ID of a species used to generate the icon. Needs to match the icon_state portion in the limbs file!
	var/limb_id = SPECIES_HUMAN
	//Defines what sprite the limb should use if it is also sexually dimorphic.
	var/limb_gender = "m"
	var/uses_mutcolor = TRUE //Does this limb have a greyscale version?
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
	/// For limbs that don't really exist, eg chainsaws
	var/is_pseudopart = FALSE

	///If disabled, limb is as good as missing.
	var/bodypart_disabled = FALSE
	///Multiplied by max_damage it returns the threshold which defines a limb being disabled or not. From 0 to 1.
	var/disable_threshold = 1
	///Controls whether bodypart_disabled makes sense or not for this limb.
	var/can_be_disabled = FALSE

	var/body_damage_coeff = 1 //Multiplier of the limb's damage that gets applied to the mob
	var/stam_damage_coeff = 0.7 //Why is this the default???
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/max_stamina_damage = 0
	var/max_damage = 0

	var/stamina_dam = 0
	var/stamina_heal_rate = 1	//Stamina heal multiplier

	// Damage reduction variables for damage handled on the limb level. Handled after worn armor.
	///Amount subtracted from brute damage inflicted on the limb.
	var/brute_reduction = 0
	///Amount subtracted from burn damage inflicted on the limb.
	var/burn_reduction = 0

	//Coloring and proper item icon update
	var/skin_tone = ""
	var/species_color = ""
	///Limbs need this information as a back-up incase they are generated outside of a carbon (limbgrower)
	var/should_draw_greyscale = TRUE

	///whether it can be dismembered with a weapon.
	var/dismemberable = TRUE
	/// Does dismemberment require the mob to be dead?
	var/dismemberment_requires_death = FALSE

	/// Effectiveness of the limb
	/// Pairs of limbs together make up 100%
	var/effectiveness = 50

	var/px_x = 0
	var/px_y = 0

	var/species_flags_list = list()
	///the type of damage overlay (if any) to use when this bodypart is bruised/burned.
	var/dmg_overlay_type = "human"

	//Damage messages used by help_shake_act()
	var/light_brute_msg = "bruised"
	var/medium_brute_msg = "battered"
	var/heavy_brute_msg = "mangled"

	var/light_burn_msg = "numb"
	var/medium_burn_msg = "burnt"
	var/heavy_burn_msg = "peeling away"

	/// So we know if we need to scream if this limb hits max damage
	var/last_maxed

	/// List of organs contained by this bodypart.
	var/list/organ_slots = null

	/// Amount of penetration that the skin will reduce an attack by
	var/skin_penetration_resistance = 5
	// The amount of damage that will be deleted when the damage reaches bones
	var/bone_deflection = 0
	/// The amount of penetration that the bones reduce an attack by
	var/bone_penetration_resistance = 15
	/// Amount of blunt armour provided by the skin
	var/skin_blunt_armour = 5
	/// Amount of blunt armour provided by the bones
	var/bone_blunt_armour = 15
	/// Injury status effects applied to this limb
	var/list/injuries = list()

	/// If the bodypart is permanently destroyed
	var/destroyed = FALSE

	/// How much pain does this limb feel?
	var/pain_multiplier = 0.4

	/// Damage taken per second
	var/decay_rate = STANDARD_ORGAN_DECAY

/obj/item/bodypart/Initialize(mapload)
	. = ..()
	if(can_be_disabled)
		RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_PARALYSIS), PROC_REF(on_paralysis_trait_gain))
		RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_PARALYSIS), PROC_REF(on_paralysis_trait_loss))
	name = "[limb_id] [parse_zone(body_zone)]"
	if(is_dimorphic)
		limb_gender = pick("m", "f")
	update_icon_dropped()
	setup_injury_trees()
	// Start processing decay
	if (!owner && !destroyed)
		START_PROCESSING(SSinjuries, src)

/// Not all bodyparts have the same injury trees
/// Allow them to be overriden
/obj/item/bodypart/proc/setup_injury_trees()
	apply_injury_tree(/datum/injury/healthy_skin_burn)
	apply_injury_tree(/datum/injury/cut_healthy)
	apply_injury_tree(/datum/injury/trauma_healthy)

/obj/item/bodypart/Destroy()
	if(owner)
		owner.remove_bodypart(src)
		set_owner(null)
	return ..()

/obj/item/bodypart/process(delta_time)
	// Decay
	receive_damage(decay_rate)
	if (get_damage() >= max_damage)
		destroyed = TRUE
		update_disabled()
		return PROCESS_KILL

/obj/item/bodypart/forceMove(atom/destination) //Please. Never forcemove a limb if its's actually in use. This is only for borgs.
	. = ..()
	if(isturf(destination))
		update_icon_dropped()

/obj/item/bodypart/examine(mob/user)
	. = ..()
	if(brute_dam >= DAMAGE_PRECISION)
		. += span_warning("This limb has [brute_dam > 30 ? "severe" : "minor"] bruising.")
	if(burn_dam >= DAMAGE_PRECISION)
		. += span_warning("This limb has [burn_dam > 30 ? "severe" : "minor"] burns.")
	if(limb_id)
		. += span_notice("It is a [limb_id] [parse_zone(body_zone)].")

/**
 * Called when a bodypart is checked for injuries.
 *
 * Modifies the check_list list with the resulting report of the limb's status.
 */
/obj/item/bodypart/proc/check_for_injuries(mob/living/carbon/human/examiner, list/check_list, list/whole_body_issues)

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

	// Get the injury texts for our injuries
	var/list/injury_texts = list()
	for (var/datum/injury/injuries in injuries)
		if (injuries.examine_description)
			var/tooltip_desc = injuries.examine_description
			// TODO: When we merge to master, add tooltips for limb effectiveness here
			if (injuries.whole_body)
				whole_body_issues |= tooltip_desc
			else
				injury_texts += tooltip_desc
	var/no_damage
	if(status == "OK" || status == "no damage")
		no_damage = TRUE
	// Put it into a list
	var/stringified_injuries = null
	if (length(injury_texts))
		stringified_injuries = injury_texts[1]
	for (var/i in 2 to length(injury_texts) - 1)
		stringified_injuries += ", [injury_texts[i]]"
	if (length(injury_texts) > 1)
		stringified_injuries += ", and [injury_texts[length(injury_texts)]]"
	var/auxiliary_verb = self_aware ? "has" : "is"
	if (no_damage && stringified_injuries)
		status = stringified_injuries
		stringified_injuries = null
		no_damage = FALSE
		auxiliary_verb = "has"
	var/isdisabled = ""
	if(bodypart_disabled)
		isdisabled = " is disabled"
		if(no_damage)
			isdisabled += " but otherwise"
		else if (stringified_injuries)
			isdisabled += ","
		else
			isdisabled += " and"
	if (destroyed)
		check_list += "\t <span class='[no_damage ? "notice" : "warning"]'>Your [name] is injured beyond treatment.</span>"
	else
		check_list += "\t <span class='[no_damage ? "notice" : "warning"]'>Your [name][isdisabled] [auxiliary_verb] [status][stringified_injuries ? " and has " : ""][stringified_injuries].</span>"


	for(var/obj/item/embedded_thing in embedded_objects)
		var/stuck_word = embedded_thing.isEmbedHarmless() ? "stuck" : "embedded"
		check_list += "\t<a href='byond://?src=[REF(src)];embedded_object=[REF(embedded_thing)];embedded_limb=[REF(body_part)]' class='warning'>There is \a [embedded_thing] [stuck_word] in your [name]!</a>"

/obj/item/bodypart/blob_act()
	take_direct_damage(max_damage)

/obj/item/bodypart/attack(mob/living/carbon/C, mob/user)
	SHOULD_CALL_PARENT(TRUE)

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(HAS_TRAIT(C, TRAIT_LIMBATTACHMENT))
			if(!H.get_bodypart(body_zone))
				user.temporarilyRemoveItemFromInventory(src, TRUE)
				if(!try_attach_limb(C))
					to_chat(user, span_warning("[H]'s body rejects [src]!"))
					forceMove(H.loc)
					return
				if(H == user)
					H.visible_message(span_warning("[H] jams [src] into [H.p_their()] empty socket!"),\
					span_notice("You force [src] into your empty socket, and it locks into place!"))
				else
					H.visible_message(span_warning("[user] jams [src] into [H]'s empty socket!"),\
					span_notice("[user] forces [src] into your empty socket, and it locks into place!"))
				return
	..()

/obj/item/bodypart/attackby(obj/item/W, mob/user, params)
	SHOULD_CALL_PARENT(TRUE)

	if(W.is_sharp())
		add_fingerprint(user)
		if(!contents.len)
			to_chat(user, span_warning("There is nothing left inside [src]!"))
			return
		playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
		user.visible_message(span_warning("[user] begins to cut open [src]."),\
			span_notice("You begin to cut open [src]..."))
		if(do_after(user, 54, target = src))
			drop_organs(user, TRUE)
	else
		return ..()

/obj/item/bodypart/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(IS_ORGANIC_LIMB(src))
		playsound(get_turf(src), 'sound/misc/splort.ogg', 50, TRUE, -1)
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3)

//empties the bodypart from its organs and other things inside it
/obj/item/bodypart/proc/drop_organs(mob/user, violent_removal)
	var/turf/T = get_turf(src)
	if(IS_ORGANIC_LIMB(src))
		playsound(T, 'sound/misc/splort.ogg', 50, 1, -1)
	for(var/obj/item/I in src)
		I.forceMove(T)

///since organs aren't actually stored in the bodypart themselves while attached to a person, we have to query the owner for what we should have
/obj/item/bodypart/proc/get_organs()
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	return contents

//Return TRUE to get whatever mob this is in to update health.
/obj/item/bodypart/proc/on_life(delta_time, times_fired, stam_regen)
	SHOULD_CALL_PARENT(TRUE)
	//DO NOT update health here, it'll be done in the carbon's life.
	if(stamina_dam >= DAMAGE_PRECISION && stam_regen)
		heal_damage(0, 0, stam_regen, null, FALSE)
		. |= BODYPART_LIFE_UPDATE_HEALTH
	var/circulation_disruption = 1
	if (!(owner.blood.circulation_type_provided & circulation_flags))
		circulation_disruption = 0
	else
		circulation_disruption = owner.blood.get_circulation_proportion()
	// Organ damage due to lack of blood circulation
	if (circulation_disruption < 1)
		var/damage_applied = (1 - circulation_disruption) * delta_time
		// Organic bodyparts that need blood and nothing else die without it
		if (circulation_flags == CIRCULATION_BLOOD)
			var/circulation_rating = owner.blood.get_circulation_proportion()
			var/desired_hypoxia_damage = max(0, (max_damage * 3) - (((CLAMP01(circulation_rating) * (max_damage * 3)) ** 0.3) / ((max_damage * 3) ** (-0.7))))
			receive_damage(clamp(damage_applied * 0.1, 0, desired_hypoxia_damage - damage_applied * 0.1))

//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/bodypart/proc/receive_damage(brute = 0, burn = 0, stamina = 0, blocked = 0, updating_health = TRUE, required_status = null)
	SHOULD_CALL_PARENT(TRUE)

	var/hit_percent = (100-blocked)/100
	if((!brute && !burn && !stamina) || hit_percent <= 0)
		return FALSE
	if(owner && HAS_TRAIT(owner, TRAIT_GODMODE))
		return FALSE	//godmode
	if(required_status && !(bodytype & required_status))
		return FALSE

	var/dmg_mlt = CONFIG_GET(number/damage_multiplier) * hit_percent
	brute = round(max(brute * dmg_mlt, 0),DAMAGE_PRECISION)
	burn = round(max(burn * dmg_mlt, 0),DAMAGE_PRECISION)
	stamina = round(max(stamina * dmg_mlt, 0),DAMAGE_PRECISION)
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
	if(stamina && !HAS_TRAIT(src, TRAIT_BODYPART_NO_STAMINA_REGENERATION))
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
/obj/item/bodypart/proc/heal_damage(brute, burn, stamina, required_status, updating_health = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(required_status && !(bodytype & required_status)) //So we can only heal certain kinds of limbs, ie robotic vs organic.
		return

	if(brute)
		set_brute_dam(round(max(brute_dam - brute, 0), DAMAGE_PRECISION))
	if(burn)
		set_burn_dam(round(max(burn_dam - burn, 0), DAMAGE_PRECISION))
	if(stamina && !HAS_TRAIT(src, TRAIT_BODYPART_NO_STAMINA_REGENERATION))
		set_stamina_dam(round(max(stamina_dam - stamina, 0), DAMAGE_PRECISION))

	if(owner)
		if(can_be_disabled)
			update_disabled()
		if(updating_health)
			owner.updatehealth()
		if(owner.dna?.species && (REVIVESBYHEALING in owner.dna.species.species_traits))
			if(owner.health > 0 && owner.stat == DEAD)
				owner.revive()
				owner.cure_husk(0) // If it has REVIVESBYHEALING, it probably can't be cloned. No husk cure.
	return update_bodypart_damage_state()

///Proc to hook behavior associated to the change of the brute_dam variable's value.
/obj/item/bodypart/proc/set_brute_dam(new_value)
	if(brute_dam == new_value)
		return
	. = brute_dam
	brute_dam = new_value


///Proc to hook behavior associated to the change of the burn_dam variable's value.
/obj/item/bodypart/proc/set_burn_dam(new_value)
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

//Returns total damage.
/obj/item/bodypart/proc/get_damage(include_stamina = FALSE)
	var/total = brute_dam + burn_dam
	if(include_stamina)
		total = max(total, stamina_dam)
	return total

//Returns only stamina damage.
/obj/item/bodypart/proc/get_staminaloss()
	return stamina_dam

//Checks disabled status thresholds
/obj/item/bodypart/proc/update_disabled()
	SHOULD_CALL_PARENT(TRUE)

	if(!owner)
		return

	if (destroyed)
		set_disabled(TRUE)
		return

	if(!can_be_disabled)
		set_disabled(FALSE)
		CRASH("update_disabled called with can_be_disabled false")

	if(HAS_TRAIT(src, TRAIT_PARALYSIS))
		set_disabled(TRUE)
		return

	var/total_damage = max(brute_dam + burn_dam, stamina_dam)

	if(total_damage >= max_damage * disable_threshold) //Easy limb disable disables the limb at 40% health instead of 0%
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

///Proc to change the value of the `owner` variable and react to the event of its change.
/obj/item/bodypart/proc/set_owner(mob/living/carbon/new_owner)
	SHOULD_CALL_PARENT(TRUE)

	if(owner == new_owner)
		return FALSE //`null` is a valid option, so we need to use a num var to make it clear no change was made.
	var/mob/living/carbon/old_owner = owner
	owner = new_owner
	if (owner || destroyed)
		STOP_PROCESSING(SSinjuries, src)
	else
		START_PROCESSING(SSinjuries, src)
	var/needs_update_disabled = FALSE //Only really relevant if there's an owner
	if(old_owner)
		if(initial(can_be_disabled))
			if(HAS_TRAIT(old_owner, TRAIT_NOLIMBDISABLE))
				if(!owner || !HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE))
					set_can_be_disabled(initial(can_be_disabled))
					needs_update_disabled = TRUE
			UnregisterSignal(old_owner, list(
				SIGNAL_REMOVETRAIT(TRAIT_NOLIMBDISABLE),
				SIGNAL_ADDTRAIT(TRAIT_NOLIMBDISABLE),
				))
		// Remove all injuries
		for (var/datum/injury/injury in injuries)
			injury.remove_from_human(old_owner)
	if(owner)
		if(initial(can_be_disabled))
			if(HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE))
				set_can_be_disabled(FALSE)
				needs_update_disabled = FALSE
			RegisterSignal(new_owner, SIGNAL_REMOVETRAIT(TRAIT_NOLIMBDISABLE), PROC_REF(on_owner_nolimbdisable_trait_loss))
			RegisterSignal(new_owner, SIGNAL_ADDTRAIT(TRAIT_NOLIMBDISABLE), PROC_REF(on_owner_nolimbdisable_trait_gain))

		if(needs_update_disabled)
			update_disabled()

		// Apply all injuries
		for (var/datum/injury/injury in injuries)
			injury.apply_to_human(owner)

	return old_owner


///Proc to change the value of the `can_be_disabled` variable and react to the event of its change.
/obj/item/bodypart/proc/set_can_be_disabled(new_can_be_disabled)
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


///Called when TRAIT_EASYLIMBWOUND is added to the owner.
/obj/item/bodypart/proc/on_owner_easylimbwound_trait_gain(mob/living/carbon/source)
	PROTECTED_PROC(TRUE)
	SIGNAL_HANDLER

	disable_threshold = 0.6
	if(can_be_disabled)
		update_disabled()


///Called when TRAIT_EASYLIMBWOUND is removed from the owner.
/obj/item/bodypart/proc/on_owner_easylimbwound_trait_loss(mob/living/carbon/source)
	PROTECTED_PROC(TRUE)
	SIGNAL_HANDLER

	disable_threshold = initial(disable_threshold)
	if(can_be_disabled)
		update_disabled()

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
		if(HAS_TRAIT(owner, TRAIT_HUSK))
			dmg_overlay_type = "" //no damage overlay shown when husked
			is_husked = TRUE
		else
			dmg_overlay_type = initial(dmg_overlay_type)
			is_husked = FALSE

	if(HAS_TRAIT(src, TRAIT_OVERRIDE_SKIN_COLOUR))
		draw_color = GET_TRAIT_VALUE(src, TRAIT_OVERRIDE_SKIN_COLOUR)
	else if(should_draw_greyscale)
		draw_color = (species_color) || (skin_tone && skintone2hex(skin_tone, include_tag = FALSE))
	else
		draw_color = null

	if(!is_creating || !owner)
		return

	// There should technically to be an ishuman(owner) check here, but it is absent because no basetype carbons use bodyparts
	// No, xenos don't actually use bodyparts. Don't ask.
	var/mob/living/carbon/human/human_owner = owner

	var/datum/species/owner_species = human_owner.dna.species
	species_flags_list = owner_species.species_traits
	limb_gender = (human_owner.dna.features["body_model"] == MALE) ? "m" : "f"
	if(owner_species.use_skintones)
		skin_tone = human_owner.skin_tone
	else
		skin_tone = ""

	if(((MUTCOLORS in owner_species.species_traits) || (DYNCOLORS in owner_species.species_traits)) && uses_mutcolor) //Ethereal code. Motherfuckers.
		if(owner_species.fixed_mut_color)
			species_color = owner_species.fixed_mut_color
		else
			species_color = human_owner.dna.features["mcolor"]
	else
		species_color = null

	draw_color = GET_TRAIT_VALUE(src, TRAIT_OVERRIDE_SKIN_COLOUR)
	if(should_draw_greyscale) //Should the limb be colored?
		draw_color ||= (species_color) || (skin_tone && skintone2hex(skin_tone, include_tag = FALSE))

//to update the bodypart's icon when not attached to a mob
/obj/item/bodypart/proc/update_icon_dropped()
	SHOULD_CALL_PARENT(TRUE)

	cut_overlays()
	var/list/standing = get_limb_icon(TRUE)
	if(!standing.len)
		icon_state = initial(icon_state)//no overlays found, we default back to initial icon.
		return
	for(var/image/I in standing)
		I.pixel_x = px_x
		I.pixel_y = px_y
	add_overlay(standing)


/obj/item/bodypart/proc/get_limb_icon(dropped)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	icon_state = "" //to erase the default sprite, we're building the visual aspects of the bodypart through overlays alone.

	. = list()

	//Handles dropped icons
	var/image_dir = 0
	if(dropped)
		image_dir = SOUTH
		if(dmg_overlay_type)
			if(brutestate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_[brutestate]0", CALCULATE_MOB_OVERLAY_LAYER(DAMAGE_LAYER), image_dir)
			if(burnstate)
				. += image('icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_0[burnstate]", CALCULATE_MOB_OVERLAY_LAYER(DAMAGE_LAYER), image_dir)

	var/image/limb = image(layer = CALCULATE_MOB_OVERLAY_LAYER(BODYPARTS_LAYER), dir = image_dir)
	var/image/aux

	if(is_husked)
		limb.icon = icon_husk
		limb.icon_state = "[husk_type]_husk_[body_zone]"
		. += emissive_blocker(limb.icon, limb.icon_state, limb.layer, limb.alpha)
		icon_exists(limb.icon, limb.icon_state, scream = TRUE) //Prints a stack trace on the first failure of a given iconstate.
		. += limb
		if(aux_zone) //Hand shit
			aux = image(limb.icon, "[husk_type]_husk_[aux_zone]", CALCULATE_MOB_OVERLAY_LAYER(aux_layer), image_dir)
			. += aux
			. += emissive_blocker(limb.icon, "[husk_type]_husk_[aux_zone]", CALCULATE_MOB_OVERLAY_LAYER(aux_layer), image_dir)
		return .

	////This is the MEAT of limb icon code
	limb.icon = icon_greyscale
	if(!should_draw_greyscale || !icon_greyscale)
		limb.icon = icon_static

	if(is_dimorphic) //Does this type of limb have sexual dimorphism?
		limb.icon_state = "[limb_id]_[body_zone]_[limb_gender]"
	else
		limb.icon_state = "[limb_id]_[body_zone]"
	. += emissive_blocker(limb.icon, limb.icon_state, limb.layer, limb.alpha)

	icon_exists(limb.icon, limb.icon_state, TRUE) //Prints a stack trace on the first failure of a given iconstate.

	. += limb

	if(aux_zone) //Hand shit
		aux = image(limb.icon, "[limb_id]_[aux_zone]", CALCULATE_MOB_OVERLAY_LAYER(aux_layer), image_dir)
		. += aux
		. += emissive_blocker(limb.icon, "[limb_id]_[aux_zone]", CALCULATE_MOB_OVERLAY_LAYER(aux_layer), image_dir)

	draw_color = GET_TRAIT_VALUE(src, TRAIT_OVERRIDE_SKIN_COLOUR)
	if(should_draw_greyscale) //Should the limb be colored?
		draw_color ||= (species_color) || (skin_tone && skintone2hex(skin_tone, include_tag = FALSE))

	if(draw_color)
		limb.color = "#[draw_color]"
		if(aux_zone)
			aux.color = "#[draw_color]"

/obj/item/bodypart/deconstruct(disassembled = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	drop_organs()
	return ..()

/obj/item/bodypart/proc/run_limb_injuries(damage, damage_type, damage_flag, penetration_power)
	var/current_damage = damage
	if (!owner || damage <= 0)
		return
	// =====================================
	// Calculate skin and bone strength
	// =====================================
	var/skin_rating = 1
	var/bone_rating = 1
	for (var/datum/injury/injury_graph as anything in injuries)
		skin_rating *= injury_graph.skin_armour_modifier
		bone_rating *= injury_graph.bone_armour_modifier
	// =====================================
	// Account for armour resistance
	// =====================================
	// Deal with armour, the penetration power gets flat reduced by the relevant armour stat
	var/armour = owner.get_bodyzone_armor_flag(body_zone, ARMOUR_PENETRATION)
	// Blunt armour from clothing is applied before we ever touch this proc
	var/blunt_armour = 0
	penetration_power -= armour
	// Damage multiplier if unarmoured and taking penetration damage
	damage += max(0, max(clamp(penetration_power, 0, 30) - blunt_armour, 0) / 30 * (UNPROTECTED_SHARPNESS_INJURY_MULTIPLIER - 1) * damage)
	// Deal with base damage
	current_damage = damage
	// Innate resistance to injury damage when dead, prevent being completely impossible to revive
	// due to so many injuries.
	if (owner && owner.stat == DEAD)
		current_damage *= 0.2
	// If the penetration delta falls below -30, then we deal no blunt damage at all
	if (current_damage < 0)
		return
	// Add in blunt armour from skin
	blunt_armour += skin_rating * skin_blunt_armour
	blunt_armour = clamp(blunt_armour, 0, 100)
	// Calculate damages
	var/proportion = CLAMP01(penetration_power / BLUNT_DAMAGE_START)
	var/blunt_damage = (current_damage * (1 - proportion)) * BLUNT_DAMAGE_RATIO * ((100 - blunt_armour) / 100)
	var/sharp_damage = current_damage * proportion
	// Take sharp & blunt damage
	for (var/datum/injury/injury_graph as anything in injuries)
		injury_graph.apply_damage(sharp_damage, damage_type, damage_flag, TRUE)
		// Burn damage affects the skin, not the bones
		if (damage_type == BURN)
			injury_graph.apply_damage(blunt_damage, damage_type, damage_flag, FALSE)
	// =====================================
	// Account for skin resistance
	// =====================================
	penetration_power -= rand(0, skin_penetration_resistance * skin_rating)
	// Deflection - Permanently reduces damage
	damage -= bone_deflection * bone_rating
	current_damage = damage
	if (current_damage <= 0)
		return
	// Add in blunt armour from bones
	blunt_armour += bone_rating * bone_blunt_armour
	blunt_armour = clamp(blunt_armour, 0, 100)
	// Bone health
	proportion = CLAMP01(penetration_power / BLUNT_DAMAGE_START)
	blunt_damage = (current_damage * (1 - proportion)) * BLUNT_DAMAGE_RATIO * ((100 - blunt_armour) / 100)
	if (damage_type != BURN)
		for (var/datum/injury/injury_graph as anything in injuries)
			injury_graph.apply_damage(blunt_damage, damage_type, damage_flag, FALSE)
	// =====================================
	// Account for bone resistance
	// =====================================
	penetration_power -= rand(0, bone_penetration_resistance * bone_rating)
	current_damage = damage
	// Organ damage
	proportion = CLAMP01(penetration_power / BLUNT_DAMAGE_START)
	sharp_damage = current_damage * proportion
	blunt_damage = (current_damage * (1 - proportion)) * BLUNT_DAMAGE_RATIO
	// If our bones are destroyed, then they will cause damage to organs when taking blunt hits
	sharp_damage += blunt_damage * (1 - bone_rating)
	if (sharp_damage <= 0)
		return
	// Damage organs
	if (!HAS_TRAIT(owner, TRAIT_NO_ORGAN_PENETRATION))
		for (var/slot in shuffle(organ_slots))
			var/obj/item/organ/organ = owner.get_organ_slot(slot)
			if (!organ)
				continue
			if (!prob(organ.organ_size))
				continue
			organ.applyOrganDamage(sharp_damage * ORGAN_DAMAGE_MULTIPLIER)
			break
	// Dismemberment
	var/dismemberment_chance = (1 - bone_rating) * sharpness
	// Can always be dismembered
	if (HAS_TRAIT(owner, TRAIT_EASYDISMEMBER))
		dismemberment_chance = sharpness
	if (dismemberment_requires_death && bone_rating > 0.1)
		dismemberment_chance = 0
	if (dismemberable && prob(dismemberment_chance))
		dismember(damage_type)

/// Internal, do not move to transition injuries to another type
/// since this completely removes the entire damage tree and the
/// ability to be injured by that type of damage.
/obj/item/bodypart/proc/remove_injury_tree(datum/injury/injury)
	injuries -= injury
	injury.remove_from_part(src)
	if (owner && ishuman(owner))
		injury.remove_from_human(owner)
	qdel(injury)
	check_effectiveness()

/obj/item/bodypart/proc/get_injury_by_base(base_path)
	for (var/datum/injury/injury in injuries)
		if (injury.base_type == base_path)
			return injury
	return null

/// Add a new injury to the set of injury trees on this bodypart
/// Do not use this to set an injury, as the previous injury tree
/// node has to be removed first, simply adding a new injury due
/// to damage will result in multiple trees of that damage type.
/obj/item/bodypart/proc/apply_injury_tree(injury_path, injury_base_path)
	for (var/datum/injury/injury in injuries)
		if (injury.type == injury_path)
			return
	var/datum/injury/injury = new injury_path()
	injury.base_type = injury_base_path || injury_path
	injuries += injury
	injury.bodypart = src
	injury.gained_time = world.time
	injury.apply_to_part(src)
	if (owner && ishuman(owner))
		injury.apply_to_human(owner)
	check_effectiveness()

/obj/item/bodypart/proc/get_skin_multiplier()
	var/rate = 1
	for (var/datum/injury/injury in injuries)
		rate *= injury.skin_armour_modifier
	return rate

/obj/item/bodypart/proc/get_bone_multiplier()
	var/rate = 1
	for (var/datum/injury/injury in injuries)
		rate *= injury.bone_armour_modifier
	return rate

/obj/item/bodypart/proc/check_effectiveness()
	check_destroyed()
	if (destroyed)
		effectiveness = 0
		clear_effectiveness_modifiers()
		update_effectiveness()
		return
	effectiveness = initial(effectiveness)
	for (var/datum/injury/injury in injuries)
		effectiveness *= injury.effectiveness_modifier
	if (!owner)
		return
	clear_effectiveness_modifiers()
	update_effectiveness()

/obj/item/bodypart/proc/update_effectiveness()
	return

/obj/item/bodypart/proc/clear_effectiveness_modifiers()
	return

/obj/item/bodypart/proc/check_destroyed()
	if (destroyed)
		return
	for (var/datum/injury/injury_graph as anything in injuries)
		if (injury_graph.skin_armour_modifier && injury_graph.bone_armour_modifier)
			continue
		destroyed = TRUE
		if (owner)
			to_chat(owner, span_userdanger("Your [name] falls limp and unresponsive!"))
		update_disabled()

///A multi-purpose setter for all things immediately important to the icon and iconstate of the limb.
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

	if(owner)
		owner.update_body_parts()
	else
		update_icon_dropped()

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

	if(owner)
		owner.update_body_parts()
	else
		update_icon_dropped()
