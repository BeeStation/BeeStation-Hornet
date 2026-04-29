#define PEN_ROTATIONS 2

GLOBAL_LIST_EMPTY(uplinks)

/**
 * Uplinks
 *
 * All /obj/item(s) can be given an uplink. Give the item one with AddComponent(/datum/component/uplink, mind)
 * Use whatever conditionals you want to check that the user has an uplink
 * This component will handle UI interactions.
**/
/datum/component/uplink
	dupe_mode = COMPONENT_DUPE_ALLOWED
	can_transfer = TRUE
	var/name = "syndicate uplink"
	var/active = FALSE
	var/lockable = TRUE
	var/locked = TRUE
	var/allow_restricted = TRUE
	var/telecrystals
	var/selected_cat
	// Antag datum of the owner
	var/datum/mind/owner = null
	var/uplink_flag
	var/datum/uplink_log/uplink_log
	var/list/uplink_items
	var/hidden_crystals = 0
	var/unlock_text
	var/unlock_note
	var/unlock_code
	var/failsafe_code
	var/compact_mode = FALSE
	var/debug = FALSE
	var/non_traitor_allowed = TRUE
	// Tied to uplink rather than mind since generally traitors only have 1 uplink
	// and tying it to anything else is difficult due to how much uses an uplink
	var/reputation = REPUTATION_TRAITOR_START
	var/directive_flags = NONE
	/// How long until we get a personal objective
	var/next_personal_objective_time = 0
	/// TC multiplier for completed directives
	var/directive_tc_multiplier = 1
	/// If true then this component will be transfered to the owner's mind when the
	/// parent is destroyed, allowing the owner to re-activate the uplink in another
	/// location.
	var/persistent = FALSE

	var/list/previous_attempts

/datum/component/uplink/Initialize(datum/mind/_owner,
		_lockable = TRUE,
		_enabled = FALSE,
		uplink_flag = UPLINK_TRAITORS,
		starting_tc = TELECRYSTALS_DEFAULT,
		_reputation = REPUTATION_TRAITOR_START,
		directive_flags = NONE
		)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if (_owner && !istype(_owner))
		CRASH("Uplink initialized with a key instead of a /datum/mind.")

	if(_owner)
		owner = _owner
		LAZYINITLIST(GLOB.uplink_logs_by_key)
		if(GLOB.uplink_logs_by_key[owner.key])
			uplink_log = GLOB.uplink_logs_by_key[owner.key]
		else
			uplink_log = new(owner.key, src)
	lockable = _lockable
	active = _enabled
	reputation = _reputation
	src.uplink_flag = uplink_flag
	src.directive_flags = directive_flags
	update_items()
	telecrystals = starting_tc
	if(!lockable)
		active = TRUE
		locked = FALSE

	previous_attempts = list()

	// We need to start running this now
	SSdirectives.can_fire = TRUE
	next_personal_objective_time = SSdirectives.get_next_personal_objective_time()
	GLOB.uplinks += src

/datum/component/uplink/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(OnAttackBy))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(interact))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(stay_alive))
	if(istype(parent, /obj/item/implant))
		RegisterSignal(parent, COMSIG_IMPLANT_ACTIVATED, PROC_REF(implant_activation))
		RegisterSignal(parent, COMSIG_IMPLANT_IMPLANTING, PROC_REF(implanting))
		RegisterSignal(parent, COMSIG_IMPLANT_OTHER, PROC_REF(old_implant))
		RegisterSignal(parent, COMSIG_IMPLANT_EXISTING_UPLINK, PROC_REF(new_implant))
	else if(istype(parent, /obj/item/modular_computer/tablet))
		RegisterSignal(parent, COMSIG_TABLET_CHANGE_RINGTONE, PROC_REF(new_ringtone))
	else if(istype(parent, /obj/item/radio))
		RegisterSignal(parent, COMSIG_RADIO_MESSAGE, PROC_REF(radio_message))
	else if(istype(parent, /obj/item/pen))
		RegisterSignal(parent, COMSIG_PEN_ROTATED, PROC_REF(pen_rotation))

/datum/component/uplink/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)
	UnregisterSignal(parent, COMSIG_QDELETING)
	UnregisterSignal(parent, COMSIG_IMPLANT_ACTIVATED)
	UnregisterSignal(parent, COMSIG_IMPLANT_IMPLANTING)
	UnregisterSignal(parent, COMSIG_IMPLANT_OTHER)
	UnregisterSignal(parent, COMSIG_IMPLANT_EXISTING_UPLINK)
	UnregisterSignal(parent, COMSIG_TABLET_CHANGE_RINGTONE)
	UnregisterSignal(parent, COMSIG_RADIO_MESSAGE)
	UnregisterSignal(parent, COMSIG_PEN_ROTATED)

/datum/component/uplink/PostTransfer()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/uplink/InheritComponent(datum/component/uplink/U)
	lockable |= U.lockable
	active |= U.active
	uplink_flag |= U.uplink_flag
	telecrystals += U.telecrystals
	if(uplink_log && U.uplink_log)
		uplink_log.MergeWithAndDel(U.uplink_log)

/datum/component/uplink/Destroy()
	uplink_log = null
	GLOB.uplinks -= src
	if (persistent)
		stack_trace("Persistent uplink was deleted.")
	return ..()

/datum/component/uplink/proc/stay_alive()
	SIGNAL_HANDLER
	if (!persistent)
		return
	// Enter the ether
	ClearFromParent()
	parent = null

/datum/component/uplink/proc/update_items()
	var/updated_items
	updated_items = get_uplink_items(uplink_flag, TRUE, allow_restricted)
	update_sales(updated_items)
	uplink_items = updated_items

/datum/component/uplink/proc/update_sales(updated_items)
	var/discount_categories = list("Discounted Gear", "Discounted Team Gear", "Limited Stock Team Gear")
	if (uplink_items == null)
		return
	for (var/category in discount_categories) // Makes sure discounted items aren't renewed or replaced
		if (uplink_items[category] != null && updated_items[category] != null)
			updated_items[category] = uplink_items[category]

/datum/component/uplink/proc/LoadTC(mob/user, obj/item/stack/sheet/telecrystal/TC, silent = FALSE)
	if(!silent)
		to_chat(user, span_notice("You slot [TC] into [parent] and charge its internal uplink."))
	var/amt = TC.amount
	telecrystals += amt
	TC.use(amt)

/datum/component/uplink/proc/OnAttackBy(datum/source, obj/item/I, mob/user)
	SIGNAL_HANDLER

	if(!active)
		return	//no hitting everyone/everything just to try to slot tcs in!
	if(istype(I, /obj/item/stack/sheet/telecrystal))
		LoadTC(user, I)
	for(var/category in uplink_items)
		for(var/item in uplink_items[category])
			var/datum/uplink_item/UI = uplink_items[category][item]
			var/path = UI.refund_path || UI.item
			var/cost = UI.refund_amount || UI.cost
			//Check that the uplink items path is right
			//Check that the uplink item is refundable
			//Check that the uplink is valid
			//Check that the uplink has purchased this item (Sales can be refunded as the path relates to the old one)
			var/hash = uplink_log.hash_purchase(UI, UI.cost)
			var/datum/uplink_purchase_entry/UPE = uplink_log.uplink_log[hash]
			if(I.type == path && UI.can_be_refunded(I, src) && I.check_uplink_validity() && UPE?.amount_purchased > 0 && UPE.allow_refund)
				UPE.amount_purchased --
				if(!UPE.amount_purchased)
					uplink_log.uplink_log.Remove(hash)
				telecrystals += cost
				uplink_log.total_spent -= cost
				to_chat(user, span_notice("[I] refunded."))
				qdel(I)
				return

/datum/component/uplink/proc/interact(datum/source, mob/user)
	SIGNAL_HANDLER

	if(locked)
		return
	if(!non_traitor_allowed && !user.mind.special_role)
		return
	active = TRUE
	update_items()
	if(user)
		INVOKE_ASYNC(src, PROC_REF(ui_interact), user)
	// an unlocked uplink blocks also opening the PDA or headset menu
	return COMPONENT_CANCEL_ATTACK_CHAIN


/datum/component/uplink/ui_state(mob/user)
	return GLOB.inventory_state

/datum/component/uplink/ui_interact(mob/user, datum/tgui/ui)
	active = TRUE
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Uplink", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/component/uplink/ui_data(mob/user)
	if(!user.mind)
		return
	var/list/data = list()
	data["telecrystals"] = telecrystals
	data["lockable"] = lockable
	data["compactMode"] = compact_mode
	data["reputation"] = reputation
	data += SSdirectives.get_uplink_data(src)
	return data

/datum/component/uplink/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()
	for(var/category in uplink_items)
		var/list/cat = list(
			"name" = category,
			"items" = (category == selected_cat ? list() : null))
		for(var/item in uplink_items[category])
			var/datum/uplink_item/I = uplink_items[category][item]
			if(I.limited_stock == 0)
				continue
			if(I.murderbone_type)
				if(!user.mind.is_murderbone()) // this is a damn proc to check a variable of every objective in you. DO NOT put it into the `if` above, or you call this proc needlessly.
					continue
			if(I.restricted_roles.len && I.discounted == FALSE)
				var/is_inaccessible = TRUE
				for(var/R in I.restricted_roles)
					if(R == user.mind.assigned_role || debug)
						is_inaccessible = FALSE
				if(is_inaccessible)
					continue
			if(I.restricted_species && I.discounted == FALSE)
				if(ishuman(user))
					var/is_inaccessible = TRUE
					var/mob/living/carbon/human/H = user
					for(var/F in I.restricted_species)
						if(F == H.dna.species.id || debug)
							is_inaccessible = FALSE
							break
					if(is_inaccessible)
						continue
			cat["items"] += list(list(
				"name" = I.name,
				"cost" = I.cost,
				"desc" = I.desc,
				"is_illegal" = I.illegal_tech,
				"are_contents_illegal" = I.contents_are_illegal_tech,
				"reputation" = I.reputation_required
			))
		data["categories"] += list(cat)
	return data

/datum/component/uplink/ui_act(action, params)
	if(!active)
		return
	switch(action)
		if("buy")
			var/item_name = params["name"]
			var/list/buyable_items = list()
			for(var/category in uplink_items)
				buyable_items += uplink_items[category]
			if(item_name in buyable_items)
				var/datum/uplink_item/I = buyable_items[item_name]
				MakePurchase(usr, I)
				return TRUE
		if("lock")
			lock()
		if("select")
			selected_cat = params["category"]
			return TRUE
		if("compact_toggle")
			compact_mode = !compact_mode
			return TRUE
		if ("directive_action")
			SSdirectives.directive_action(src, usr)
			return TRUE

/datum/component/uplink/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/radar_assets),
	)

/datum/component/uplink/proc/MakePurchase(mob/user, datum/uplink_item/U)
	if(!istype(U))
		return
	if (!user || user.incapacitated)
		return

	if(telecrystals < U.cost || U.limited_stock == 0)
		return
	if (reputation < U.reputation_required)
		return
	telecrystals -= U.cost

	U.purchase(user, src)

	if(U.limited_stock > 0)
		U.limited_stock -= 1

	SSblackbox.record_feedback("nested tally", "traitor_uplink_items_bought", 1, list("[initial(U.name)]", "[U.cost]"))
	log_game("[initial(U.name)] purchased by [user.ckey]/[user.name] the [user.job ? user.job : "Unknown Job"] for [U.cost] TC, [telecrystals] TC remaining.")
	return TRUE

// Implant signal responses

/datum/component/uplink/proc/implant_activation()
	SIGNAL_HANDLER

	var/obj/item/implant/implant = parent
	unlock()
	interact(null, implant.imp_in)

/datum/component/uplink/proc/implanting(datum/source, mob/user, mob/living/target)
	SIGNAL_HANDLER

	owner = target?.mind
	if(owner && !uplink_log)
		LAZYINITLIST(GLOB.uplink_logs_by_key)
		if(GLOB.uplink_logs_by_key[owner.key])
			uplink_log = GLOB.uplink_logs_by_key[owner.key]
		else
			uplink_log = new(owner.key, src)

/datum/component/uplink/proc/old_implant(datum/source, list/arguments, obj/item/implant/new_implant)
	SIGNAL_HANDLER

	// It kinda has to be weird like this until implants are components
	return SEND_SIGNAL(new_implant, COMSIG_IMPLANT_EXISTING_UPLINK, src)

/datum/component/uplink/proc/new_implant(datum/source, datum/component/uplink/uplink)
	SIGNAL_HANDLER

	uplink.telecrystals += telecrystals
	return COMPONENT_DELETE_NEW_IMPLANT

// PDA signal responses

/datum/component/uplink/proc/new_ringtone(datum/source, mob/living/user, new_ring_text)
	SIGNAL_HANDLER

	if(trim(LOWER_TEXT(new_ring_text)) != trim(LOWER_TEXT(unlock_code)))
		if(failsafe_code && trim(LOWER_TEXT(new_ring_text)) == trim(LOWER_TEXT(failsafe_code)))
			failsafe()
			return COMPONENT_STOP_RINGTONE_CHANGE
		return
	unlock()
	interact(null, user)
	to_chat(user, span_hear("The computer softly beeps."))
	return COMPONENT_STOP_RINGTONE_CHANGE

// Radio signal responses

/datum/component/uplink/proc/new_frequency(datum/source, list/arguments)
	SIGNAL_HANDLER

	var/obj/item/radio/master = parent
	var/frequency = arguments[1]
	if(frequency != unlock_code)
		if(frequency == failsafe_code)
			failsafe()
		return
	unlock()
	if(ismob(master.loc))
		interact(null, master.loc)


/datum/component/uplink/proc/radio_message(datum/source, mob/living/user, treated_message, channel, list/message_mods)
	SIGNAL_HANDLER
	var/message_to_use = message_mods[MODE_UNTREATED_MESSAGE]

	if(channel != RADIO_CHANNEL_UPLINK)
		return

	if(!findtext(LOWER_TEXT(message_to_use), LOWER_TEXT(unlock_code)))
		if(failsafe_code && findtext(LOWER_TEXT(message_to_use), LOWER_TEXT(failsafe_code)))
			failsafe()
		return
	unlock()
	interact(null, user)
	to_chat(user, "As you whisper the code into your headset, a soft chime fills your ears.")
	return COMPONENT_CANNOT_USE_RADIO

// Pen signal responses

/datum/component/uplink/proc/pen_rotation(datum/source, degrees, mob/living/carbon/user)
	SIGNAL_HANDLER

	var/obj/item/pen/master = parent
	previous_attempts += degrees
	if(length(previous_attempts) > PEN_ROTATIONS)
		popleft(previous_attempts)

	if(compare_list(previous_attempts, unlock_code))
		unlock()
		previous_attempts.Cut()
		master.degrees = 0
		interact(null, user)
		to_chat(user, span_warning("Your pen makes a clicking noise, before quickly rotating back to 0 degrees!"))

	else if(compare_list(previous_attempts, failsafe_code))
		failsafe()

/datum/component/uplink/proc/setup_unlock_code()
	unlock_code = generate_code()
	var/obj/item/P = parent
	if(istype(parent,/obj/item/modular_computer/tablet))
		unlock_note = "<B>Uplink Passcode:</B> [unlock_code] ([P.name])."
	else if(istype(parent,/obj/item/radio))
		unlock_note = "<B>Radio Passcode:</B> [unlock_code] ([P.name], :d channel)."
	else if(istype(parent,/obj/item/pen))
		unlock_note = "<B>Uplink Degrees:</B> [english_list(unlock_code)] ([P.name])."

/datum/component/uplink/proc/generate_code()
	if(istype(parent, /obj/item/modular_computer/tablet))
		return "[random_code(3)] [pick(GLOB.phonetic_alphabet)]"
	else if(istype(parent, /obj/item/radio))
		return "[pick(GLOB.phonetic_alphabet)]"
	else if(istype(parent, /obj/item/pen))
		var/list/L = list()
		for(var/i in 1 to PEN_ROTATIONS)
			L += rand(1, 360)
		return L

/datum/component/uplink/proc/failsafe()
	if(!parent)
		return
	var/turf/T = get_turf(parent)
	if(!T)
		return
	explosion(T,1,2,3)
	qdel(parent) //Alternatively could brick the uplink.

/datum/component/uplink/proc/unlock()
	locked = FALSE
	// Lock any other uplinks that are on the same item
	for (var/datum/component/uplink/uplink in parent.GetComponents(/datum/component/uplink))
		if (uplink == src)
			continue
		uplink.lock()

/datum/component/uplink/proc/lock()
	active = FALSE
	locked = TRUE
	telecrystals += hidden_crystals
	hidden_crystals = 0
	SStgui.close_uis(src)

#undef PEN_ROTATIONS
