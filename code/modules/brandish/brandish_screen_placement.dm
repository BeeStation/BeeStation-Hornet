/// Keep an item's placement local to upright container artwork. The original
/// offsets are restored when it leaves, so placement cannot leak into drops.
/datum/component/screen_placement
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/world_x
	var/world_y
	var/screen_w
	var/screen_z
	var/atom/anchor

/datum/component/screen_placement/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/item = parent
	anchor = item.loc
	world_x = item.pixel_x
	world_y = item.pixel_y
	screen_w = item.pixel_w
	screen_z = item.pixel_z
	item.pixel_x = 0
	item.pixel_y = 0
	item.pixel_w += world_x
	item.pixel_z += world_y

/datum/component/screen_placement/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/datum/component/screen_placement/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

/datum/component/screen_placement/proc/on_moved(atom/movable/source)
	SIGNAL_HANDLER
	if(source.loc != anchor)
		qdel(src)

/datum/component/screen_placement/Destroy(force = FALSE)
	var/obj/item/item = parent
	if(!QDELETED(item))
		item.pixel_x = world_x
		item.pixel_y = world_y
		item.pixel_w = screen_w
		item.pixel_z = screen_z
	anchor = null
	return ..()
