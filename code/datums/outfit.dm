/**
  * # Outfit datums
  *
  * This is a clean system of applying outfits to mobs, if you need to equip someone in a uniform
  * this is the way to do it cleanly and properly.
  *
  * You can also specify an outfit datum on a job to have it auto equipped to the mob on join
  *
  * /mob/living/carbon/human/proc/equipOutfit(outfit) is the mob level proc to equip an outfit
  * and you pass it the relevant datum outfit
  *
  * outfits can also be saved as json blobs downloadable by a client and then can be uploaded
  * by that user to recreate the outfit, this is used by admins to allow for custom event outfits
  * that can be restored at a later date
  */
/datum/outfit
	///Name of the outfit (shows up in the equip admin verb)
	var/name = "Naked"

	/// Type path of item to go in uniform slot
	var/uniform = null

	/// Type path of item to go in suit slot
	var/suit = null

	/// Type path of item to go in back slot
	var/back = null

	/// Type path of item to go in belt slot
	var/belt = null

	/// Type path of item to go in gloves slot
	var/gloves = null

	/// Type path of item to go in shoes slot
	var/shoes = null

	/// Type path of item to go in head slot
	var/head = null

	/// Type path of item to go in mask slot
	var/mask = null

	/// Type path of item to go in neck slot
	var/neck = null

	/// Type path of item to go in ears slot
	var/ears = null

	/// Type path of item to go in the glasses slot
	var/glasses = null

	/// Type path of item to go in the idcard slot
	var/id = null

	/// Type path of item for left pocket slot
	var/l_pocket = null

	/// Type path of item for right pocket slot
	var/r_pocket = null

	/**
	  * Type path of item to go in suit storage slot
	  *
	  * (make sure it's valid for that suit)
	  */
	var/suit_store = null

	///Type path of item to go in the right hand
	var/r_hand = null

	//Type path of item to go in left hand
	var/l_hand = null

	/// Should the toggle helmet proc be called on the helmet during equip
	var/toggle_helmet = TRUE

	///ID of the slot containing a gas tank
	var/internals_slot = null

	/**
	  * list of items that should go in the backpack of the user
	  *
	  * Format of this list should be: list(path=count,otherpath=count)
	  */
	var/list/backpack_contents = null

	/// Internals box. Will be inserted at the start of backpack_contents
	var/box

	/** 
	  * Any implants the mob should start implanted with
	  *
	  * Format of this list is (typepath, typepath, typepath)
	  */
	var/list/implants = null

	/// Any clothing accessory item
	var/accessory = null

	/// Set to FALSE if your outfit requires runtime parameters
	var/can_be_admin_equipped = TRUE

	/**
	  * extra types for chameleon outfit changes, mostly guns
	  *
	  * Format of this list is (typepath, typepath, typepath)
	  *
	  * These are all added and returns in the list for get_chamelon_diguise_info proc
	  */
	var/list/chameleon_extras

/**
  * Called at the start of the equip proc
  *
  * Override to change the value of the slots depending on client prefs, species and
  * other such sources of change
  *
  * Extra Arguments
  * * visualsOnly true if this is only for display (in the character setup screen)
  *
  * If visualsOnly is true, you can omit any work that doesn't visually appear on the character sprite
  */
/datum/outfit/proc/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//to be overridden for customization depending on client prefs,species etc
	return

/**
  * Called after the equip proc has finished
  *
  * All items are on the mob at this point, use this proc to toggle internals
  * fiddle with id bindings and accesses etc
  *
  * Extra Arguments
  * * visualsOnly true if this is only for display (in the character setup screen)
  *
  * If visualsOnly is true, you can omit any work that doesn't visually appear on the character sprite
  */
/datum/outfit/proc/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//to be overridden for toggling internals, id binding, access etc
	return

/**
  * Equips all defined types and paths to the mob passed in
  *
  * Extra Arguments
  * * visualsOnly true if this is only for display (in the character setup screen)
  *
  * If visualsOnly is true, you can omit any work that doesn't visually appear on the character sprite
  */
/datum/outfit/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	pre_equip(H, visualsOnly)

	//Start with uniform,suit,backpack for additional slots
	if(uniform)
		H.equip_to_slot_or_del(new uniform(H),SLOT_W_UNIFORM)
	if(suit)
		H.equip_to_slot_or_del(new suit(H),SLOT_WEAR_SUIT)
	if(back)
		H.equip_to_slot_or_del(new back(H),SLOT_BACK)
	if(belt)
		H.equip_to_slot_or_del(new belt(H),SLOT_BELT)
	if(gloves)
		H.equip_to_slot_or_del(new gloves(H),SLOT_GLOVES)
	if(shoes)
		H.equip_to_slot_or_del(new shoes(H),SLOT_SHOES)
	if(head)
		H.equip_to_slot_or_del(new head(H),SLOT_HEAD)
	if(mask)
		H.equip_to_slot_or_del(new mask(H),SLOT_WEAR_MASK)
	if(neck)
		H.equip_to_slot_or_del(new neck(H),SLOT_NECK)
	if(ears)
		H.equip_to_slot_or_del(new ears(H),SLOT_EARS)
	if(glasses)
		H.equip_to_slot_or_del(new glasses(H),SLOT_GLASSES)
	if(id)
		H.equip_to_slot_or_del(new id(H),SLOT_WEAR_ID)
	if(suit_store)
		H.equip_to_slot_or_del(new suit_store(H),SLOT_S_STORE)

	if(accessory)
		var/obj/item/clothing/under/U = H.w_uniform
		if(U)
			U.attach_accessory(new accessory(H))
		else
			WARNING("Unable to equip accessory [accessory] in outfit [name]. No uniform present!")

	if(l_hand)
		H.put_in_l_hand(new l_hand(H))
	if(r_hand)
		H.put_in_r_hand(new r_hand(H))

	if(!visualsOnly) // Items in pockets or backpack don't show up on mob's icon.
		if(l_pocket)
			H.equip_to_slot_or_del(new l_pocket(H),SLOT_L_STORE)
		if(r_pocket)
			H.equip_to_slot_or_del(new r_pocket(H),SLOT_R_STORE)

		if(box)
			if(!backpack_contents)
				backpack_contents = list()
			backpack_contents.Insert(1, box)
			backpack_contents[box] = 1

		if(backpack_contents)
			for(var/path in backpack_contents)
				var/number = backpack_contents[path]
				if(!isnum(number))//Default to 1
					number = 1
				for(var/i in 1 to number)
					H.equip_to_slot_or_del(new path(H),SLOT_IN_BACKPACK)

	if(!H.head && toggle_helmet && istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/HS = H.wear_suit
		HS.ToggleHelmet()

	post_equip(H, visualsOnly)

	if(!visualsOnly)
		apply_fingerprints(H)
		if(internals_slot)
			H.internal = H.get_item_by_slot(internals_slot)
			H.update_action_buttons_icon()
		if(implants)
			for(var/implant_type in implants)
				var/obj/item/implant/I = new implant_type(H)
				I.implant(H, null, TRUE)

	H.update_body()
	return TRUE

/**
  * Apply a fingerprint from the passed in human to all items in the outfit
  *
  * Used for forensics setup when the mob is first equipped at roundstart
  * essentially calls add_fingerprint to every defined item on the human
  *
  */
/datum/outfit/proc/apply_fingerprints(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(H.back)
		H.back.add_fingerprint(H,1)	//The 1 sets a flag to ignore gloves
		for(var/obj/item/I in H.back.contents)
			I.add_fingerprint(H,1)
	if(H.wear_id)
		H.wear_id.add_fingerprint(H,1)
	if(H.w_uniform)
		H.w_uniform.add_fingerprint(H,1)
	if(H.wear_suit)
		H.wear_suit.add_fingerprint(H,1)
	if(H.wear_mask)
		H.wear_mask.add_fingerprint(H,1)
	if(H.wear_neck)
		H.wear_neck.add_fingerprint(H,1)
	if(H.head)
		H.head.add_fingerprint(H,1)
	if(H.shoes)
		H.shoes.add_fingerprint(H,1)
	if(H.gloves)
		H.gloves.add_fingerprint(H,1)
	if(H.ears)
		H.ears.add_fingerprint(H,1)
	if(H.glasses)
		H.glasses.add_fingerprint(H,1)
	if(H.belt)
		H.belt.add_fingerprint(H,1)
		for(var/obj/item/I in H.belt.contents)
			I.add_fingerprint(H,1)
	if(H.s_store)
		H.s_store.add_fingerprint(H,1)
	if(H.l_store)
		H.l_store.add_fingerprint(H,1)
	if(H.r_store)
		H.r_store.add_fingerprint(H,1)
	for(var/obj/item/I in H.held_items)
		I.add_fingerprint(H,1)
	return 1

/// Return a list of all the types that are required to disguise as this outfit type
/datum/outfit/proc/get_chameleon_disguise_info()
	var/list/types = list(uniform, suit, back, belt, gloves, shoes, head, mask, neck, ears, glasses, id, l_pocket, r_pocket, suit_store, r_hand, l_hand)
	types += chameleon_extras
	listclearnulls(types)
	return types
