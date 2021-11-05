#define INTERNALS_TOGGLE_DELAY (4 SECONDS)
#define POCKET_EQUIP_DELAY (1 SECONDS)

GLOBAL_LIST_INIT(strippable_human_items, create_strippable_list(list(
	/datum/strippable_item/mob_item_slot/head,
	/datum/strippable_item/mob_item_slot/back,
	/datum/strippable_item/mob_item_slot/mask,
	/datum/strippable_item/mob_item_slot/neck,
	/datum/strippable_item/mob_item_slot/eyes,
	/datum/strippable_item/mob_item_slot/ears,
	/datum/strippable_item/mob_item_slot/jumpsuit,
	/datum/strippable_item/mob_item_slot/suit,
	/datum/strippable_item/mob_item_slot/gloves,
	/datum/strippable_item/mob_item_slot/feet,
	/datum/strippable_item/mob_item_slot/suit_storage,
	/datum/strippable_item/mob_item_slot/needs_jumpsuit/id,
	/datum/strippable_item/mob_item_slot/needs_jumpsuit/belt,
	/datum/strippable_item/mob_item_slot/needs_jumpsuit/pocket/left,
	/datum/strippable_item/mob_item_slot/needs_jumpsuit/pocket/right,
	/datum/strippable_item/hand/left,
	/datum/strippable_item/hand/right,
	/datum/strippable_item/mob_item_slot/handcuffs,
	/datum/strippable_item/mob_item_slot/legcuffs
)))

GLOBAL_LIST_INIT(strippable_human_layout, list(
	list(
		new /datum/strippable_item_layout("left_hand"),
		new /datum/strippable_item_layout("right_hand")
	),
	list(
		new /datum/strippable_item_layout("back")
	),
	list(
		new /datum/strippable_item_layout("head"),
		new /datum/strippable_item_layout("mask"),
		new /datum/strippable_item_layout("neck"),
		new /datum/strippable_item_layout("corgi_collar"),
		new /datum/strippable_item_layout("parrot_headset"),
		new /datum/strippable_item_layout("eyes"),
		new /datum/strippable_item_layout("ears")
	),
	list(
		new /datum/strippable_item_layout("suit"),
		new /datum/strippable_item_layout("suit_storage", TRUE),
		new /datum/strippable_item_layout("shoes"),
		new /datum/strippable_item_layout("gloves"),
		new /datum/strippable_item_layout("jumpsuit"),
		new /datum/strippable_item_layout("belt", TRUE),
		new /datum/strippable_item_layout("left_pocket", TRUE),
		new /datum/strippable_item_layout("right_pocket", TRUE),
		new /datum/strippable_item_layout("id", TRUE),
		new /datum/strippable_item_layout("handcuffs"),
		new /datum/strippable_item_layout("legcuffs")
	),
))

/mob/living/carbon/human/proc/should_strip(mob/user)
	if(user.pulling != src || user.grab_state != GRAB_AGGRESSIVE)
		return TRUE

	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		return !human_user.can_be_firemanned(src)

	return TRUE

/datum/strippable_item/mob_item_slot/eyes
	key = STRIPPABLE_ITEM_EYES
	item_slot = ITEM_SLOT_EYES

/datum/strippable_item/mob_item_slot/ears
	key = STRIPPABLE_ITEM_EARS
	item_slot = ITEM_SLOT_EARS

/datum/strippable_item/mob_item_slot/jumpsuit
	key = STRIPPABLE_ITEM_JUMPSUIT
	item_slot = ITEM_SLOT_ICLOTHING

/datum/strippable_item/mob_item_slot/jumpsuit/get_alternate_action(atom/source, mob/user)
	var/obj/item/clothing/under/jumpsuit = get_item(source)
	if(!istype(jumpsuit))
		return null
	return jumpsuit?.has_sensor? "adjust_sensors" : null

/datum/strippable_item/mob_item_slot/jumpsuit/alternate_action(atom/source, mob/user)
	var/obj/item/clothing/under/jumpsuit = get_item(source)
	if(!istype(jumpsuit))
		return null
	jumpsuit.set_sensors(user)

/datum/strippable_item/mob_item_slot/suit
	key = STRIPPABLE_ITEM_SUIT
	item_slot = ITEM_SLOT_OCLOTHING

/datum/strippable_item/mob_item_slot/gloves
	key = STRIPPABLE_ITEM_GLOVES
	item_slot = ITEM_SLOT_GLOVES

/datum/strippable_item/mob_item_slot/feet
	key = STRIPPABLE_ITEM_FEET
	item_slot = ITEM_SLOT_FEET

/datum/strippable_item/mob_item_slot/suit_storage
	key = STRIPPABLE_ITEM_SUIT_STORAGE
	item_slot = ITEM_SLOT_SUITSTORE

/datum/strippable_item/mob_item_slot/suit_storage/is_unavailable(atom/source)
	. = ..()
	if(.)
		return

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/human = source

	if(!human.wear_suit)
		return TRUE

/datum/strippable_item/mob_item_slot/suit_storage/get_alternate_action(atom/source, mob/user)
	return get_strippable_alternate_action_internals(get_item(source), source)

/datum/strippable_item/mob_item_slot/suit_storage/alternate_action(atom/source, mob/user)
	return strippable_alternate_action_internals(get_item(source), source, user)

/datum/strippable_item/mob_item_slot/needs_jumpsuit

/datum/strippable_item/mob_item_slot/needs_jumpsuit/is_unavailable(atom/source)
	. = ..()
	if(.)
		return

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/human = source
	var/obj/item/bodypart/bodypart = human.get_bodypart(BODY_ZONE_CHEST)
	if(!human.w_uniform && !human.dna?.species?.nojumpsuit && (!bodypart || bodypart.status != BODYPART_ROBOTIC))
		return TRUE

/datum/strippable_item/mob_item_slot/needs_jumpsuit/id
	key = STRIPPABLE_ITEM_ID
	item_slot = ITEM_SLOT_ID

/datum/strippable_item/mob_item_slot/needs_jumpsuit/belt
	key = STRIPPABLE_ITEM_BELT
	item_slot = ITEM_SLOT_BELT

/datum/strippable_item/mob_item_slot/needs_jumpsuit/belt/get_alternate_action(atom/source, mob/user)
	return get_strippable_alternate_action_internals(get_item(source), source)

/datum/strippable_item/mob_item_slot/needs_jumpsuit/belt/alternate_action(atom/source, mob/user)
	return strippable_alternate_action_internals(get_item(source), source, user)

/datum/strippable_item/mob_item_slot/needs_jumpsuit/pocket
	/// Which pocket we're referencing. Used for visible text.
	var/pocket_side

/datum/strippable_item/mob_item_slot/needs_jumpsuit/pocket/get_obscuring(atom/source)
	return isnull(get_item(source)) \
		? STRIPPABLE_OBSCURING_NONE \
		: STRIPPABLE_OBSCURING_HIDDEN

/datum/strippable_item/mob_item_slot/needs_jumpsuit/pocket/get_equip_delay(obj/item/equipping)
	return POCKET_EQUIP_DELAY

/datum/strippable_item/mob_item_slot/needs_jumpsuit/pocket/start_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		warn_owner(source)

/datum/strippable_item/mob_item_slot/needs_jumpsuit/pocket/start_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if(isnull(item))
		return FALSE

	to_chat(user, "<span class='notice'>You try to empty [source]'s [pocket_side] pocket.</span>")

	var/log_message = "[key_name(source)] is being pickpocketed of [item] by [key_name(user)] ([pocket_side])"
	source.log_message(log_message, LOG_ATTACK, color="red")
	user.log_message(log_message, LOG_ATTACK, color="red", log_globally=FALSE)
	item.add_fingerprint(src)

	var/result = start_unequip_mob(item, source, user, POCKET_STRIP_DELAY)

	if(!result)
		warn_owner(source)

	return result

/datum/strippable_item/mob_item_slot/needs_jumpsuit/pocket/proc/warn_owner(atom/owner)
	to_chat(owner, "<span class='warning'>You feel your [pocket_side] pocket being fumbled with!</span>")

/datum/strippable_item/mob_item_slot/needs_jumpsuit/pocket/left
	key = STRIPPABLE_ITEM_LPOCKET
	item_slot = ITEM_SLOT_LPOCKET
	pocket_side = "left"

/datum/strippable_item/mob_item_slot/needs_jumpsuit/pocket/right
	key = STRIPPABLE_ITEM_RPOCKET
	item_slot = ITEM_SLOT_RPOCKET
	pocket_side = "right"

/proc/get_strippable_alternate_action_internals(obj/item/item, atom/source)
	if(!iscarbon(source))
		return

	var/mob/living/carbon/carbon_source = source

	var/obj/item/clothing/mask = carbon_source.wear_mask
	if(!istype(mask))
		return

	if((mask.clothing_flags & MASKINTERNALS) && istype(item, /obj/item/tank))
		return isnull(carbon_source.internal) ? "enable_internals" : "disable_internals"

/proc/strippable_alternate_action_internals(obj/item/item, atom/source, mob/user)
	var/obj/item/tank/tank = item
	if(!istype(tank))
		return

	var/mob/living/carbon/carbon_source = source
	if(!istype(carbon_source))
		return

	var/obj/item/clothing/mask = carbon_source.wear_mask
	if(!istype(mask) || !(mask.clothing_flags & MASKINTERNALS))
		return

	carbon_source.visible_message(
		"<span class='danger'>[user] tries to [isnull(carbon_source.internal) ? "open": "close"] the valve on [source]'s [item.name].</span>",
		"<span class='userdanger'>[user] tries to [isnull(carbon_source.internal) ? "open": "close"] the valve on your [item.name].</span>",
		ignored_mobs = user,
	)

	to_chat(user, "<span class='notice'>You try to [isnull(carbon_source.internal) ? "open": "close"] the valve on [source]'s [item.name]...</span>")

	if(!do_mob(user, carbon_source, INTERNALS_TOGGLE_DELAY))
		return

	if(carbon_source.internal)
		carbon_source.internal = null

		// This isn't meant to be FALSE, it correlates to the icon's name.
		carbon_source.update_internals_hud_icon(0)
	else if(!QDELETED(item))
		if((carbon_source.wear_mask?.clothing_flags & MASKINTERNALS) || carbon_source.getorganslot(ORGAN_SLOT_BREATHING_TUBE))
			carbon_source.internal = item
			carbon_source.update_internals_hud_icon(1)

	carbon_source.visible_message(
		"<span class='danger'>[user] [isnull(carbon_source.internal) ? "closes": "opens"] the valve on [source]'s [item.name].</span>",
		"<span class='userdanger'>[user] [isnull(carbon_source.internal) ? "closes": "opens"] the valve on your [item.name].</span>",
		ignored_mobs = user,
	)

	to_chat(user, "<span class='notice'>You [isnull(carbon_source.internal) ? "close" : "open"] the valve on [source]'s [item.name].</span>")

#undef INTERNALS_TOGGLE_DELAY
#undef POCKET_EQUIP_DELAY
