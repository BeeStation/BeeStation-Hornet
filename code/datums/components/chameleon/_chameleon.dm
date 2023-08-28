/datum/component/chameleon
	/// The original name for this chameleon item, such as "chameleon jumpsuit"
	var/original_name = "Object"
	/// The base type that disguises will be fetched from.
	var/base_disguise_path
	/// A typecache of items allowed to be selected for this item. Will be used instead of `base_disguise_path` if set.
	var/list/disguise_whitelist
	/// A typecache of items not allowed to be selected for this item.
	var/list/disguise_blacklist
	/// A normal list of paths of which disguises can be selected.
	var/list/disguise_paths = list()
	/// An associative list (name = callback(mob/living/user, datum/component/chameleon/source)) of "extra actions" to present in the UI for this item.
	var/list/extra_actions = list()
	/// The typepath that is currently being disguised as.
	var/current_disguise
	/// A callback to run whenever the disguise is changed, with the arguments (mob/living/user, datum/component/chameleon/source, old_disguise_path, new_disguise_path)
	var/datum/callback/on_disguise
	/// Whether the chameleon functionality is 'locked' or not.
	var/locked = FALSE
	/// Whether to hide duplicates or not.
	var/hide_duplicates = TRUE
	///	Whenever the EMP effect will end.
	COOLDOWN_DECLARE(emp_timer)

/datum/component/chameleon/Initialize(original_name, base_disguise_path, list/disguise_whitelist, list/disguise_blacklist, hide_duplicates, list/extra_actions, datum/callback/on_disguise)
	if(!(base_disguise_path || src.base_disguise_path) && !(disguise_whitelist || src.disguise_whitelist))
		return COMPONENT_INCOMPATIBLE
	if(original_name && !istext(original_name))
		return COMPONENT_INCOMPATIBLE
	if(base_disguise_path && !ispath(base_disguise_path, /obj/item))
		return COMPONENT_INCOMPATIBLE
	if(disguise_whitelist && !islist(disguise_whitelist))
		return COMPONENT_INCOMPATIBLE
	if(original_name)
		src.original_name = original_name
	if(disguise_whitelist)
		src.disguise_whitelist = disguise_whitelist
	else if(src.disguise_whitelist)
		src.disguise_whitelist = typecacheof(src.disguise_whitelist)
	if(base_disguise_path)
		src.base_disguise_path = base_disguise_path
	if(disguise_blacklist)
		src.disguise_blacklist = disguise_blacklist
	else if(src.disguise_blacklist)
		src.disguise_blacklist = typecacheof(src.disguise_blacklist, only_root_path = TRUE)
	else
		src.disguise_blacklist = list()
	if(!isnull(hide_duplicates))
		src.hide_duplicates = hide_duplicates
	if(LAZYLEN(extra_actions))
		src.extra_actions = extra_actions
	if(istype(on_disguise))
		src.on_disguise = on_disguise
	setup_disguises()

/datum/component/chameleon/RegisterWithParent()
	RegisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_PICKUP), PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(on_pre_qdel))
	RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), PROC_REF(on_multitool_act))

/datum/component/chameleon/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_PICKUP, COMSIG_ITEM_DROPPED, COMSIG_PARENT_QDELETING, COMSIG_ATOM_EMP_ACT, COMSIG_PARENT_EXAMINE, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL)))

/datum/component/chameleon/process()
	random_look()
	if(COOLDOWN_FINISHED(src, emp_timer))
		return PROCESS_KILL

/datum/component/chameleon/proc/on_equip(datum/source, mob/user)
	SIGNAL_HANDLER
	setup_action(user)

/datum/component/chameleon/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER
	setup_action(user, include_self = FALSE)

/datum/component/chameleon/proc/on_pre_qdel(datum/source)
	SIGNAL_HANDLER
	var/mob/living/holder = get(parent, /mob/living)
	if(!QDELETED(holder))
		setup_action(holder, include_self = FALSE)

/datum/component/chameleon/proc/on_emp(datum/source, severity)
	SIGNAL_HANDLER
	emp_randomize()

/datum/component/chameleon/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(isobserver(user) || can_use(user, dist_limit = 3))
		examine_list += "<span class='boldnotice'>It has a hidden panel, revealing a mechanism for changing its appearance!</span>"

/datum/component/chameleon/proc/on_multitool_act(datum/_source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(locked)
		locked = FALSE
		log_game("[key_name(user)] has removed the disguise lock on \the [parent] ([original_name]) with [tool]")
	else
		locked = TRUE
		log_game("[key_name(user)] has locked the disguise of \the [parent] ([original_name]) with [tool]")
	user.playsound_local(get_turf(user), 'sound/machines/click.ogg', vol = 30, vary = TRUE)
	setup_action(user)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/datum/component/chameleon/proc/can_use(mob/living/user, dist_limit = 0)
	. = TRUE
	if(!istype(user))
		return FALSE
	if(locked)
		return FALSE
	if(dist_limit ? (get_dist(user, parent) > dist_limit) : !(parent in user.contents))
		return FALSE

/datum/component/chameleon/proc/random_look()
	if(!LAZYLEN(disguise_paths))
		return
	disguise(disguise_path = pick(disguise_paths))

/datum/component/chameleon/proc/emp_randomize(amount = 30 SECONDS)
	random_look()
	COOLDOWN_START(src, emp_timer, amount)
	START_PROCESSING(SSprocessing, src)

/datum/component/chameleon/proc/disguise(mob/living/user, disguise_path)
	if(!ispath(disguise_path, /obj/item))
		CRASH("[user ? key_name(user) : "null"] attempted to disguise using an invalid path: [disguise_path]")
	if(!(disguise_path in disguise_paths))
		if(user && ispath(disguise_path, /obj/item))
			var/obj/item/failed_disguise = disguise_path
			to_chat(user, "<span class='warning'>The Chameleon [original_name] cannot disguise as '[initial(failed_disguise.name)] ([initial(failed_disguise.icon_state)])'.</span>")
		return
	var/old_disguise_path = current_disguise
	var/obj/item/picked_item = disguise_path
	var/obj/item/chameleon_item = parent
	chameleon_item.worn_icon = initial(picked_item.worn_icon)
	chameleon_item.lefthand_file = initial(picked_item.lefthand_file)
	chameleon_item.righthand_file = initial(picked_item.righthand_file)
	if(initial(picked_item.greyscale_colors))
		chameleon_item.greyscale_colors = initial(picked_item.greyscale_colors)
		if(initial(picked_item.greyscale_config_worn))
			chameleon_item.worn_icon = SSgreyscale.GetColoredIconByType(initial(picked_item.greyscale_config_worn), initial(picked_item.greyscale_colors))
		if(initial(picked_item.greyscale_config_inhand_left))
			chameleon_item.lefthand_file = SSgreyscale.GetColoredIconByType(initial(picked_item.greyscale_config_inhand_left), initial(picked_item.greyscale_colors))
		if(initial(picked_item.greyscale_config_inhand_right))
			chameleon_item.righthand_file = SSgreyscale.GetColoredIconByType(initial(picked_item.greyscale_config_inhand_right), initial(picked_item.greyscale_colors))
	chameleon_item.worn_icon_state = initial(picked_item.worn_icon_state)
	chameleon_item.item_state = initial(picked_item.item_state)
	if(isclothing(chameleon_item) && ispath(picked_item, /obj/item/clothing))
		var/obj/item/clothing/chameleon_clothing = chameleon_item
		var/obj/item/clothing/picked_clothing = picked_item
		chameleon_clothing.flags_cover = initial(picked_clothing.flags_cover)
	if(initial(picked_item.greyscale_config) && initial(picked_item.greyscale_colors))
		chameleon_item.icon = SSgreyscale.GetColoredIconByType(initial(picked_item.greyscale_config), initial(picked_item.greyscale_colors))
	else
		chameleon_item.icon = initial(picked_item.icon)
	chameleon_item.desc = initial(picked_item.desc)
	chameleon_item.icon_state = initial(picked_item.icon_state)
	if(istype(chameleon_item, /obj/item/card/id) && ispath(disguise_path, /obj/item/card/id))
		var/obj/item/card/id/picked_id = disguise_path
		var/obj/item/card/id/chameleon_id = chameleon_item
		chameleon_id.hud_state = initial(picked_id.hud_state)
	else
		chameleon_item.name = initial(picked_item.name)
	chameleon_item.update_slot_icon()
	current_disguise = disguise_path
	on_disguise?.Invoke(user, src, old_disguise_path, disguise_path)

/datum/component/chameleon/proc/setup_disguises()
	disguise_paths.Cut()
	for(var/path in list_chameleon_disguises(base_disguise_path, disguise_whitelist, disguise_blacklist, hide_duplicates))
		disguise_paths += path

/datum/component/chameleon/proc/setup_action(mob/living/user, include_self = TRUE)
	if(!istype(user))
		return
	var/user_has_chameleon_panel = FALSE
	for(var/obj/item/item in user.contents)
		if(!include_self && item == parent)
			continue
		var/datum/component/chameleon/item_chameleon = item.GetComponent(/datum/component/chameleon)
		if(item_chameleon?.can_use(user))
			user_has_chameleon_panel = TRUE
			break
	if(user_has_chameleon_panel)
		give_action(user)
	else
		take_action(user)

/datum/component/chameleon/proc/give_action(mob/living/user)
	if(!GLOB.user_chameleon_actions[user])
		GLOB.user_chameleon_actions[user] = new /datum/action/chameleon_panel(user = user)
	var/datum/action/chameleon_panel/action = GLOB.user_chameleon_actions[user]
	if(action in user.actions)
		action.update_static_data(user)
	else
		action.Grant(user)

/datum/component/chameleon/proc/take_action(mob/living/user)
	var/datum/action/chameleon_panel/action = GLOB.user_chameleon_actions[user]
	action?.Remove(user)
