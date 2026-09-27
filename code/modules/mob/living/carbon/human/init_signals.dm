/mob/living/carbon/human/register_init_signals()
	. = ..()

	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_UNKNOWN_APPEARANCE), SIGNAL_REMOVETRAIT(TRAIT_UNKNOWN_APPEARANCE)), PROC_REF(on_unknown_appearance_trait))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_TRACKED_SENSORS), PROC_REF(add_to_suit_sensors))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_TRACKED_SENSORS), PROC_REF(remove_from_suit_sensors))

	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_FAT), SIGNAL_REMOVETRAIT(TRAIT_FAT)), PROC_REF(on_fat))

	RegisterSignal(src, COMSIG_ATOM_CONTENTS_WEIGHT_CLASS_CHANGED, PROC_REF(check_pocket_weight))

/// Gaining or losing [TRAIT_UNKNOWN_APPEARANCE] updates our name and our sechud
/mob/living/carbon/human/proc/on_unknown_appearance_trait(datum/source)
	SIGNAL_HANDLER

	name = get_visible_name()
	sec_hud_set_ID()

/// Called when [TRAIT_TRACKED_SENSORS] is added to the mob.
/mob/living/carbon/human/proc/add_to_suit_sensors(datum/source)
	SIGNAL_HANDLER
	GLOB.suit_sensors_list |= src

/// Called when [TRAIT_TRACKED_SENSORS] is removed from the mob.
/mob/living/carbon/human/proc/remove_from_suit_sensors(datum/source)
	SIGNAL_HANDLER
	GLOB.suit_sensors_list -= src

/mob/living/carbon/human/proc/on_fat(datum/source)
	SIGNAL_HANDLER

	if(HAS_TRAIT(src, TRAIT_FAT))
		add_movespeed_modifier(/datum/movespeed_modifier/obesity)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/obesity)

/// Signal proc for [COMSIG_ATOM_CONTENTS_WEIGHT_CLASS_CHANGED] to check if an item is suddenly too heavy for our pockets
/mob/living/carbon/human/proc/check_pocket_weight(datum/source, obj/item/changed, old_w_class, new_w_class)
	SIGNAL_HANDLER
	if(changed != r_store && changed != l_store)
		return
	if(new_w_class <= POCKET_WEIGHT_CLASS)
		return
	if(!dropItemToGround(changed, force = TRUE))
		return
	visible_message(
		span_warning("[changed] falls out of [src]'s pockets!"),
		span_warning("[changed] falls out of your pockets!"),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)
	playsound(src, "rustle", 50, TRUE, -5, frequency = 0.8)
