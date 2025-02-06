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

	///Should we preload some of this job's items?
	var/preload = FALSE

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

#define EQUIP_OUTFIT_ITEM(item_path, slot_name) if(##item_path) { \
	H.equip_to_slot_or_del(SSwardrobe.provide_type(##item_path, H), ##slot_name, TRUE); \
	var/obj/item/outfit_item = H.get_item_by_slot(##slot_name); \
	if (outfit_item && outfit_item.type == ##item_path) { \
		outfit_item.on_outfit_equip(H, visualsOnly, ##slot_name); \
	} \
}

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
		EQUIP_OUTFIT_ITEM(uniform, ITEM_SLOT_ICLOTHING)
	if(suit)
		EQUIP_OUTFIT_ITEM(suit, ITEM_SLOT_OCLOTHING)
	if(belt)
		EQUIP_OUTFIT_ITEM(belt, ITEM_SLOT_BELT)
	if(gloves)
		EQUIP_OUTFIT_ITEM(gloves, ITEM_SLOT_GLOVES)
	if(shoes)
		EQUIP_OUTFIT_ITEM(shoes, ITEM_SLOT_FEET)
	if(head)
		EQUIP_OUTFIT_ITEM(head, ITEM_SLOT_HEAD)
	if(mask)
		EQUIP_OUTFIT_ITEM(mask, ITEM_SLOT_MASK)
	if(neck)
		EQUIP_OUTFIT_ITEM(neck, ITEM_SLOT_NECK)
	if(ears)
		EQUIP_OUTFIT_ITEM(ears, ITEM_SLOT_EARS)
	if(glasses)
		EQUIP_OUTFIT_ITEM(glasses, ITEM_SLOT_EYES)
	if(back)
		EQUIP_OUTFIT_ITEM(back, ITEM_SLOT_BACK)
	if(id)
		EQUIP_OUTFIT_ITEM(id, ITEM_SLOT_ID)
	if(suit_store)
		EQUIP_OUTFIT_ITEM(suit_store, ITEM_SLOT_SUITSTORE)

	if(accessory)
		var/obj/item/clothing/under/U = H.w_uniform
		if(U)
			U.attach_accessory(SSwardrobe.provide_type(accessory, H))
		else
			WARNING("Unable to equip accessory [accessory] in outfit [name]. No uniform present!")

	if(l_hand)
		H.put_in_l_hand(SSwardrobe.provide_type(l_hand, H))
	if(r_hand)
		H.put_in_r_hand(SSwardrobe.provide_type(r_hand, H))

	if(!visualsOnly) // Items in pockets or backpack don't show up on mob's icon.
		if(l_pocket)
			EQUIP_OUTFIT_ITEM(l_pocket, ITEM_SLOT_LPOCKET)
		if(r_pocket)
			EQUIP_OUTFIT_ITEM(r_pocket, ITEM_SLOT_RPOCKET)

		if(box)
			if(!backpack_contents)
				backpack_contents = list()
			backpack_contents.Insert(1, box)
			backpack_contents[box] = 1

		if(backpack_contents)
			for(var/path in backpack_contents)
				var/number = backpack_contents[path]
				if(!isnum_safe(number))//Default to 1
					number = 1
				for(var/i in 1 to number)
					EQUIP_OUTFIT_ITEM(path, ITEM_SLOT_BACKPACK)

	if(!H.head && toggle_helmet && istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/HS = H.wear_suit
		HS.ToggleHelmet()

	post_equip(H, visualsOnly)

	if(!visualsOnly)
		apply_fingerprints(H)
		if(internals_slot)
			H.open_internals(H.get_item_by_slot(internals_slot))
		if(implants)
			for(var/implant_type in implants)
				var/obj/item/implant/I = SSwardrobe.provide_type(implant_type, H)
				I.implant(H, null, TRUE)

	H.update_body()
	return TRUE

#undef EQUIP_OUTFIT_ITEM

/**
  * Apply a fingerprint from the passed in human to all items in the outfit
  *
  * Used for forensics setup when the mob is first equipped at roundstart
  * essentially calls add_fingerprint to every defined item on the human
  *
  */
/datum/outfit/proc/apply_fingerprints(mob/living/carbon/human/H)
	if(!istype(H) && !ismonkey(H))
		return
	if(H.back)
		H.back.add_fingerprint(H, ignoregloves = TRUE)
		for(var/obj/item/I in H.back.contents)
			I.add_fingerprint(H, ignoregloves = TRUE)
	if(H.wear_id)
		H.wear_id.add_fingerprint(H, ignoregloves = TRUE)
	if(H.w_uniform)
		H.w_uniform.add_fingerprint(H, ignoregloves = TRUE)
	if(H.wear_suit)
		H.wear_suit.add_fingerprint(H, ignoregloves = TRUE)
	if(H.wear_mask)
		H.wear_mask.add_fingerprint(H, ignoregloves = TRUE)
	if(H.wear_neck)
		H.wear_neck.add_fingerprint(H, ignoregloves = TRUE)
	if(H.head)
		H.head.add_fingerprint(H, ignoregloves = TRUE)
	if(H.shoes)
		H.shoes.add_fingerprint(H, ignoregloves = TRUE)
	if(H.gloves)
		H.gloves.add_fingerprint(H, ignoregloves = TRUE)
	if(H.ears)
		H.ears.add_fingerprint(H, ignoregloves = TRUE)
	if(H.glasses)
		H.glasses.add_fingerprint(H, ignoregloves = TRUE)
	if(H.belt)
		H.belt.add_fingerprint(H, ignoregloves = TRUE)
		for(var/obj/item/I in H.belt.contents)
			I.add_fingerprint(H, ignoregloves = TRUE)
	if(H.s_store)
		H.s_store.add_fingerprint(H, ignoregloves = TRUE)
	if(H.l_store)
		H.l_store.add_fingerprint(H, ignoregloves = TRUE)
	if(H.r_store)
		H.r_store.add_fingerprint(H, ignoregloves = TRUE)
	for(var/obj/item/I in H.held_items)
		I.add_fingerprint(H, ignoregloves = TRUE)
	return TRUE

/// Return a list of all the types that are required to disguise as this outfit type
/datum/outfit/proc/get_chameleon_disguise_info()
	var/list/types = list(uniform, suit, back, belt, gloves, shoes, head, mask, neck, ears, glasses, id, l_pocket, r_pocket, suit_store, r_hand, l_hand)
	types += chameleon_extras
	list_clear_nulls(types)
	return types

/// Return a list of types to pregenerate for later equipping
/// This should not be things that do unique stuff in Initialize() based off their location, since we'll be storing them for a while
/datum/outfit/proc/get_types_to_preload()
	var/list/preload = list()
	preload += id
	preload += uniform
	preload += suit
	preload += suit_store
	preload += back
	//Load in backpack gear and shit
	for(var/type_to_load in backpack_contents)
		var/num_to_load = backpack_contents[type_to_load]
		if(!isnum(num_to_load))
			num_to_load = 1
		for(var/i in 1 to num_to_load)
			preload += type_to_load
	preload += belt
	preload += ears
	preload += glasses
	preload += gloves
	preload += head
	preload += mask
	preload += neck
	preload += shoes
	preload += l_pocket
	preload += r_pocket
	preload += l_hand
	preload += r_hand
	preload += accessory
	preload += box
	for(var/implant_type in implants)
		preload += implant_type
	/*
	for(var/skillpath in skillchips)
		preload += skillpath
	*/

	return preload

/datum/outfit/proc/get_json_data()
	. = list()
	.["outfit_type"] = type
	.["name"] = name
	.["uniform"] = uniform
	.["suit"] = suit
	.["toggle_helmet"] = toggle_helmet
	.["back"] = back
	.["belt"] = belt
	.["gloves"] = gloves
	.["shoes"] = shoes
	.["head"] = head
	.["mask"] = mask
	.["neck"] = neck
	.["ears"] = ears
	.["glasses"] = glasses
	.["id"] = id
	.["l_pocket"] = l_pocket
	.["r_pocket"] = r_pocket
	.["suit_store"] = suit_store
	.["r_hand"] = r_hand
	.["l_hand"] = l_hand
	.["internals_slot"] = internals_slot
	.["backpack_contents"] = backpack_contents
	.["box"] = box
	.["implants"] = implants
	.["accessory"] = accessory

/// Copy most vars from another outfit to this one
/datum/outfit/proc/copy_from(datum/outfit/target)
	name = target.name
	uniform = target.uniform
	suit = target.suit
	toggle_helmet = target.toggle_helmet
	back = target.back
	belt = target.belt
	gloves = target.gloves
	shoes = target.shoes
	head = target.head
	mask = target.mask
	neck = target.neck
	ears = target.ears
	glasses = target.glasses
	id = target.id
	l_pocket = target.l_pocket
	r_pocket = target.r_pocket
	suit_store = target.suit_store
	r_hand = target.r_hand
	l_hand = target.l_hand
	internals_slot = target.internals_slot
	backpack_contents = target.backpack_contents
	box = target.box
	implants = target.implants
	accessory = target.accessory

/datum/outfit/proc/save_to_file(mob/admin)
	var/stored_data = get_json_data()
	var/json = json_encode(stored_data)
	//Kinda annoying but as far as i can tell you need to make actual file.
	var/f = file("data/TempOutfitUpload")
	fdel(f)
	WRITE_FILE(f,json)
	admin << ftp(f,"[name].json")

/datum/outfit/proc/load_from(list/outfit_data)
	//This could probably use more strict validation
	name = outfit_data["name"]
	uniform = text2path(outfit_data["uniform"])
	suit = text2path(outfit_data["suit"])
	toggle_helmet = outfit_data["toggle_helmet"]
	back = text2path(outfit_data["back"])
	belt = text2path(outfit_data["belt"])
	gloves = text2path(outfit_data["gloves"])
	shoes = text2path(outfit_data["shoes"])
	head = text2path(outfit_data["head"])
	mask = text2path(outfit_data["mask"])
	neck = text2path(outfit_data["neck"])
	ears = text2path(outfit_data["ears"])
	glasses = text2path(outfit_data["glasses"])
	id = text2path(outfit_data["id"])
	l_pocket = text2path(outfit_data["l_pocket"])
	r_pocket = text2path(outfit_data["r_pocket"])
	suit_store = text2path(outfit_data["suit_store"])
	r_hand = text2path(outfit_data["r_hand"])
	l_hand = text2path(outfit_data["l_hand"])
	internals_slot = outfit_data["internals_slot"]
	var/list/backpack = outfit_data["backpack_contents"]
	backpack_contents = list()
	for(var/item in backpack)
		var/itype = text2path(item)
		if(itype)
			backpack_contents[itype] = backpack[item]
	box = text2path(outfit_data["box"])
	var/list/impl = outfit_data["implants"]
	implants = list()
	for(var/I in impl)
		var/imptype = text2path(I)
		if(imptype)
			implants += imptype
	accessory = text2path(outfit_data["accessory"])
	return TRUE

/datum/outfit/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---")
	VV_DROPDOWN_OPTION(VV_HK_TO_OUTFIT_EDITOR, "Outfit Editor")

/datum/outfit/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_TO_OUTFIT_EDITOR])
		usr.client.open_outfit_editor(src)
