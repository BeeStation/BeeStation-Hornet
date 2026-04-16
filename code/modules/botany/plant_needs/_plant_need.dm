/*
	Each plant feature that uses needs implements it in its own way
	Typically, these are checked *every* tick, but stuff like roots probably don't
*/
/datum/plant_need
	///Daddy-o
	var/datum/plant_feature/parent
	///A brief insert of what this needs is - Essentially, this plant needs [need_description], and [need_description]
	var/need_description = ""
	///Can this need be a random overdraw need?
	var/overdraw_need = FALSE
	///Is this need the product of a bad ?
	var/overdrawn = FALSE
//Buff stuff
	///is this need actually a buff? - Buff needs aren't needed to pass need checks
	var/buff = FALSE
	var/buff_applied = FALSE
	///Does this buff have negative effects when not met
	var/debuff = FALSE
	///Cooldown stuff for nectar buff toggle
	COOLDOWN_DECLARE(nectar_timer)
	var/nectar_buff_duration = 60 SECONDS
	///Buff overlay
	var/obj/effect/plant_buff/buff_appearance
	var/do_buff_appearance = TRUE

/datum/plant_need/New(datum/plant_feature/_parent, _overdrawn)
	. = ..()
	overdrawn = _overdrawn
	setup_parent(_parent)
	buff_appearance = new(src)

/datum/plant_need/proc/setup_parent(_parent)
	parent = _parent
	if(!parent?.parent)
		RegisterSignal(parent, COMSIG_PF_ATTACHED_PARENT, PROC_REF(setup_component_parent))
	else
		setup_component_parent(parent.parent)

/datum/plant_need/proc/setup_component_parent(datum/source)
	SIGNAL_HANDLER

	if(!parent || !parent.parent)
		return
	RegisterSignal(parent.parent, COMSIG_PLANT_NECTAR_BUFF, PROC_REF(catch_nectar))

/datum/plant_need/proc/copy(datum/plant_feature/_parent, datum/plant_need/_need)
	var/datum/plant_need/new_need = _need || new type(_parent)
	return new_need

/datum/plant_need/proc/check_need(_delta_time)
	return

///Use this to give ourselves what we need to fufill our needs
/datum/plant_need/proc/fufill_need(atom/location)
	return

/datum/plant_need/proc/catch_nectar(datum/source)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, nectar_timer))
		COOLDOWN_RESET(src, nectar_timer)
	COOLDOWN_START(src, nectar_timer, nectar_buff_duration)

/datum/plant_need/proc/apply_buff(__delta_time)
	//Buff visuals
	if(do_buff_appearance)
		parent.parent?.plant_item.vis_contents |= buff_appearance
		parent.parent?.plant_item.add_filter("buff_outline", 1, outline_filter(1, "#fbffc1cb"))
		var/outline_filter = parent.parent?.plant_item.get_filter("buff_outline")
		animate(outline_filter, color = "#fbffc12c", time = 1.3 SECONDS, loop = -1)
		animate(color = "#fbffc1cb", time = 1.3 SECONDS)
	return

/datum/plant_need/proc/remove_buff(__delta_time)
	if(do_buff_appearance)
		parent.parent?.plant_item.vis_contents -= buff_appearance
		parent.parent?.plant_item.remove_filter("buff_outline")
	return

/*
	Buffed effect
*/
/obj/effect/plant_buff
	vis_flags = VIS_INHERIT_ID
	plane = GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	pixel_x = -16
	pixel_y = 28
	///Reference to our ray mask
	var/icon/ray_mask

/obj/effect/plant_buff/Initialize(mapload)
	. = ..()
	ray_mask = icon('icons/effects/64x64.dmi', "ray mask")

	add_filter("rays", 1, rays_filter(32, "#fbffc1e7"))
	add_filter("mask", 2, alpha_mask_filter(0, 0, ray_mask, null, MASK_INVERSE))

	var/ray_filter = get_filter("rays")
	animate(ray_filter, offset = 100, time = 100 SECONDS, loop = -1)
