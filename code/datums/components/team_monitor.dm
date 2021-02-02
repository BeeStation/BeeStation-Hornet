#define ALT_APPEARENCE_ID "team_monitor"

//==================
// Helpers
//==================

//A list that tracks everything that should be tracked by team monitors
//Assoc list:
// Key = Frequency
// Value = Components
GLOBAL_LIST_EMPTY(tracker_huds)
GLOBAL_LIST_EMPTY(tracker_beacons)

//Gets the first free team element, useful for creating new teams
//Special key is for what kind of team frequency it should be
//Everything that has a team monitor can be configured to change what frequency it tracks on
//The special key can be used to make keys like synd5 or synd83 to prevent centcom tracking syndies.
/proc/get_free_team_frequency(special_key = "")
	var/sanity = 5
	//5 attempts to find a free team element, should never get that far
	while(sanity > 0)
		sanity --
		var/random_id = rand(1, 999)
		var/key = "[random_id]"
		if(!GLOB.tracker_beacons.Find("[special_key][key]"))
			return key
	//Return something anyways
	var/random_id = rand(1, 999)
	var/key = "[random_id]"
	return key

//Adds a new tracking hud
/proc/add_tracker_hud(frequency_added, datum/component/component_added)
	if(!frequency_added)
		return
	if(islist(GLOB.tracker_huds[frequency_added]))
		GLOB.tracker_huds[frequency_added] += component_added
	else
		GLOB.tracker_huds[frequency_added] = list(component_added)

//Adds a new tracking beacon
/proc/add_tracker_beacon(frequency_added, datum/component/component_added)
	if(!frequency_added)
		return
	if(islist(GLOB.tracker_beacons[frequency_added]))
		GLOB.tracker_beacons[frequency_added] += component_added
	else
		GLOB.tracker_beacons[frequency_added] = list(component_added)

//==================
// Component
//  - HUD COMPONENT
//  - HANDLES POINTING TOWARDS TRACKED BEACONS
//==================

//The component that handles tracking atoms
/datum/component/team_monitor
	//The frequency of the team signals we are trackings
	var/team_freq_key = "debug"	//Key <-- cannot be changed
	var/team_frequency = ""	//Final compiled: Consists of key then numbers between 1 and 999
	//The atoms we are actually tracking
	// Key = Beacon component
	// Value = image
	var/list/tracking = list()
	//Who are we updating for
	var/mob/updating = null
	//Distance from center
	//Probably in pixels or something idk
	var/distance = 15
	//Should we display the hud in the firstplace
	var/hud_visible = TRUE
	//The attached beacon: Ignore this one
	var/datum/component/tracking_beacon/attached_beacon

/datum/component/team_monitor/Initialize(frequency_key, frequency, _attached_beacon)
	var/obj/item/clothing/item = parent
	if(!istype(item))
		return COMPONENT_INCOMPATIBLE

	team_freq_key = frequency_key
	if(frequency != null)
		team_frequency = "[frequency_key][frequency]"
	else
		team_frequency = null

	attached_beacon = _attached_beacon

	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/parent_equipped)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/parent_dequpped)

	get_active_trackers()
	add_tracker_hud(team_frequency, src)

/datum/component/team_monitor/Destroy(force, silent)
	//Unregister signals
	if(parent)
		UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED)
		UnregisterSignal(parent, COMSIG_ITEM_DROPPED)

	if(team_frequency)
		GLOB.tracker_huds[team_frequency] -= src

	. = ..()

//Gets the active trackers for when the team_monitor component
//is initialized while other trackers are already active.
/datum/component/team_monitor/proc/get_active_trackers()
	if(!team_frequency)
		return
	for(var/datum/component/tracking_beacon/beacon as() in GLOB.tracker_beacons[team_frequency])
		if(beacon != attached_beacon && beacon.updating)
			add_to_tracking_network(beacon)

//===========
// Handles the parent being moved and updates the direction of the arrows.
//===========

//When the parent is removed, we need to update our arrows
//Also if we are visible update the arrows of anything tracking us
/datum/component/team_monitor/proc/parent_moved()
	//Update our alt appearences
	update_all_directions()

//Updates the direction of the arrows for all atoms we are tracking
/datum/component/team_monitor/proc/update_all_directions()
	if(!updating)
		return
	for(var/datum/component/tracking_beacon/beacon as() in tracking)
		update_atom_dir(beacon)

//Update the arrow towards another atom
/datum/component/team_monitor/proc/update_atom_dir(datum/component/tracking_beacon/beacon)
	if(!updating)
		return
	var/atom/movable/screen/screen = tracking[beacon]
	if(!screen)
		return
	var/turf/target_turf = get_turf(beacon.parent)
	var/turf/parent_turf = get_turf(parent)
	var/matrix/rotationMatrix = matrix()
	rotationMatrix.Scale(1.5)
	rotationMatrix.Translate(0, -distance)
	rotationMatrix.Turn(Get_Angle(target_turf, parent_turf))
	animate(screen, transform = rotationMatrix, time = 2)

//===========
// Handles being equipped / dequipped
//===========

//The parent equipped an item with a team_monitor, check if its in the right slot and apply the hud
//Also needs to enable other trackers pointers towards us
/datum/component/team_monitor/proc/parent_equipped(datum/source, mob/equipper, slot)
	var/obj/item/clothing/item = parent
	if(!istype(item))
		return
	if(item.slot_flags & slotdefine2slotbit(slot)) //Was equipped to a valid slot for this item?
		show_hud(equipper)
	else
		hide_hud(equipper)

//Disable our hud
//Disable the pointers to us
/datum/component/team_monitor/proc/parent_dequpped(datum/source, mob/user)
	hide_hud(user)

//===========
// Handles hiding / showing the hud when equipped
//===========

/datum/component/team_monitor/proc/show_hud(mob/target)
	updating = target
	//Register parent signal
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/parent_moved)
	//Mob doesnt have a hud, dont add hud arrows
	if(!target.hud_used)
		return
	for(var/datum/component/tracking_beacon/key in tracking)
		var/atom/movable/screen/arrow/arrow = new
		arrow.alpha = 240
		arrow.color = key.colour
		arrow.hud = target.hud_used
		target.hud_used.team_finder_arrows += arrow
		tracking[key] = arrow
	//Update their hud
	target.hud_used.show_hud(target.hud_used.hud_version, target)
	update_all_directions()

/datum/component/team_monitor/proc/hide_hud(mob/target)
	updating = null
	//UnRegister parent signal
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	//Remove our arrows
	for(var/key in tracking)
		var/atom/movable/screen/arrow = tracking[key]
		if(!arrow)
			continue
		if(target.hud_used)
			target.hud_used.team_finder_arrows -= arrow
		qdel(arrow)
		tracking[key] = null
	//Update their hud
	if(target.hud_used)
		target.hud_used.show_hud(target.hud_used.hud_version, target)

//===========
// Handles user interaction
// - Disabling hud transmission
// - Disabling hud view
// - Changing transmission frequency
//===========

/datum/component/team_monitor/proc/toggle_hud(new_hud_status, mob/user)
	hud_visible = new_hud_status
	if(hud_visible && !updating)
		show_hud(user)
	else if(!hud_visible)
		hide_hud(user)

/datum/component/team_monitor/proc/change_frequency(mob/user)
	//Get new frequency
	var/new_freq = input(user, "Enter a new frequency (1 - 999):", "Frequency Change", 1) as num|null
	if(!new_freq)
		to_chat(user, "<span class='warning'>Invalid frequency. Encrypted tracking HUD disabled.</span>")
		team_frequency = null
		return
	if(new_freq < 1 || new_freq > 999)
		to_chat(user, "<span class='warning'>Frequency is out of range. Must be between 1 and 999.</span>")
		team_frequency = null
		return
	set_frequency(new_freq)
	to_chat(user, "<span class='notice'>Tracking HUD now scanning on frequency <i>[team_frequency]</i>.</span>")

/datum/component/team_monitor/proc/set_frequency(new_frequency)
	var/hud_on = hud_visible
	var/mob/user = updating
	//Remove tracking from old frequency
	if(team_frequency)
		if(updating)
			toggle_hud(FALSE, updating)
		//Remove from the global frequency
		GLOB.tracker_huds[team_frequency] -= src
		//Clear tracking
		tracking.Cut()
	team_frequency = "[team_freq_key][new_frequency]"
	//Add tracking to new frequency
	if(!team_frequency)
		return
	//Adds our tracking component to the global list of trackers
	add_tracker_hud(team_frequency, src)
	//Gets the other trackers on our frequency
	get_active_trackers()
	//Show hud if needed
	if(user)
		toggle_hud(hud_on, user)

//Adds a new atom to the tracking monitor, will create a hud element that tracks them
//TODO: Add the screen if already equipped
//Should be the only way atoms are added to the tracking list
/datum/component/team_monitor/proc/add_to_tracking_network(datum/component/tracking_beacon/beacon)
	if(beacon != attached_beacon)
		if(updating?.hud_used)
			var/atom/movable/screen/arrow/arrow = new
			arrow.alpha = 240
			arrow.color = beacon.colour
			arrow.hud = updating.hud_used
			updating.hud_used.team_finder_arrows += arrow
			tracking[beacon] = arrow
			//Update arrow direction
			update_atom_dir(beacon)
			//Update their hud
			updating.hud_used.show_hud(updating.hud_used.hud_version, updating)
		else
			tracking[beacon] = null

//==================
// Component
//  - TRACKER COMPONENT
//  - HANDLES UPDATING TRACKERS WHEN MOVED
//==================

/datum/component/tracking_beacon
	//The frequency of the team signals we are trackings
	var/team_freq_key = "debug"	//Key <-- cannot be changed
	var/team_frequency = ""	//Final compiled: Consists of key then numbers between 1 and 999
	//Are we visible to other trackers?
	var/visible = TRUE
	//Our colour
	var/colour = "#FFFFFF"
	//Who are we updating for
	var/mob/updating = null
	//Do we have an attached monitor?
	var/datum/component/team_monitor/attached_monitor

/datum/component/tracking_beacon/Initialize(frequency_key, frequency, _attached_monitor, comp_visible = TRUE, comp_colour = "#ffffff")
	. = ..()

	//Set vars
	colour = comp_colour
	attached_monitor = _attached_monitor

	//Set the frequency we are transmitting on
	team_freq_key = frequency_key
	if(frequency != null)
		team_frequency = "[frequency_key][frequency]"
	else
		team_frequency = null

	//Add ourselves to the tracking network
	add_tracker_beacon(team_frequency, src)

	//Reigster equipping signals
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/parent_equipped)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/parent_dequpped)

	//Set our visibility on the tracking network
	toggle_visibility(comp_visible)

/datum/component/tracking_beacon/Destroy(force, silent)
	. = ..()

	//Unregister signals
	if(parent)
		UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED)
		UnregisterSignal(parent, COMSIG_ITEM_DROPPED)

	//Unregister movement signal
	if(updating)
		UnregisterSignal(updating, COMSIG_MOVABLE_MOVED)

	//Goodbye, it was a good life
	remove_from_huds()

	//Remove from the global network
	if(team_frequency)
		GLOB.tracker_huds[team_frequency] -= src

//===========
// Equip/Dequip transmission handling
//===========

//The parent equipped an item with a team_monitor, check if its in the right slot and apply the hud
//Also needs to enable other trackers pointers towards us
/datum/component/tracking_beacon/proc/parent_equipped(datum/source, mob/equipper, slot)
	var/obj/item/clothing/item = parent
	if(!istype(item))
		return
	if(item.slot_flags & slotdefine2slotbit(slot)) //Was equipped to a valid slot for this item?
		updating = equipper
		toggle_visibility(TRUE)
		RegisterSignal(updating, COMSIG_MOVABLE_MOVED, .proc/update_position)
	else
		toggle_visibility(FALSE)
		if(updating)
			UnregisterSignal(updating, COMSIG_MOVABLE_MOVED)
			updating = null

//Disable our hud
//Disable the pointers to us
/datum/component/tracking_beacon/proc/parent_dequpped(datum/source, mob/user)
	toggle_visibility(FALSE)
	if(updating)
		UnregisterSignal(updating, COMSIG_MOVABLE_MOVED)
		updating = null

//===========
// Visibility Handling
//===========

//Toggle visibility
//If visibility is disabled we will hide ourselves from others
/datum/component/tracking_beacon/proc/toggle_visibility(new_vis)
	visible = new_vis
	//If we are updating toggle our visibility
	if(updating && visible)
		add_to_huds()
	else
		remove_from_huds()

//===========
// Position Updating
//===========

/datum/component/tracking_beacon/proc/update_position()
	//Update everyone tracking us
	if(!visible)
		return
	if(!team_frequency)
		return
	for(var/datum/component/team_monitor/TM as() in GLOB.tracker_huds[team_frequency])
		if(TM != attached_monitor)
			TM.update_atom_dir(src)

//===========
// Showing on huds
//===========

//Remove ourselves from other tracking components
/datum/component/tracking_beacon/proc/remove_from_huds()
	if(!team_frequency)
		return
	for(var/datum/component/team_monitor/team_monitor as() in GLOB.tracker_huds[team_frequency])
		//Remove ourselves from the tracking list
		var/atom/movable/screen/arrow = team_monitor.tracking[src]
		team_monitor.tracking.Remove(src)
		//Delete the arrow pointing to use
		if(!arrow)
			continue
		if(team_monitor.updating?.hud_used)
			team_monitor.updating.hud_used.team_finder_arrows -= arrow
		qdel(arrow)

//Add ourselves to other tracking components
/datum/component/tracking_beacon/proc/add_to_huds()
	//If we are invisibile, dont bother
	if(!visible)
		return
	//Find other trackers and add ourselves to their tracking network
	if(!team_frequency)
		return
	for(var/datum/component/team_monitor/team_monitor as() in GLOB.tracker_huds[team_frequency])
		if(team_monitor != attached_monitor)
			team_monitor.add_to_tracking_network(src)

//===========
// Handles user interaction
// - Disabling hud transmission
// - Disabling hud view
// - Changing transmission frequency
//===========

/datum/component/tracking_beacon/proc/change_frequency(mob/user)
	//Get new frequency
	var/new_freq = input(user, "Enter a new frequency (1 - 999):", "Frequency Change", 1) as num|null
	if(!new_freq)
		to_chat(user, "<span class='warning'>Invalid frequency. Encrypted tracking beacon disabled.</span>")
		team_frequency = null
		return
	if(new_freq < 1 || new_freq > 999)
		to_chat(user, "<span class='warning'>Frequency is out of range. Must be between 1 and 999.</span>")
		team_frequency = null
		return
	set_frequency(new_freq)
	to_chat(user, "<span class='notice'>Tracking HUD now transmitting on frequency <i>[team_frequency]</i>.</span>")
	//Set frequency of the linked tracker
	if(attached_monitor)
		attached_monitor.set_frequency(new_freq)

/datum/component/tracking_beacon/proc/set_frequency(new_frequency)
	//Remove tracking from old frequency
	if(team_frequency)
		//Disable the beacon on other trackers
		toggle_visibility(FALSE)
		//Remove from the global frequency
		GLOB.tracker_beacons[team_frequency] -= src
	team_frequency = "[team_freq_key][new_frequency]"
	//Add tracking to new frequency
	if(!team_frequency)
		return
	//Adds our tracking component to the global list of trackers
	add_tracker_beacon(team_frequency, src)
	//Set our visibility on the tracking network
	toggle_visibility(visible)

//=======
// Generic Arrow, No special effects
//=======

/atom/movable/screen/arrow
	name = "arrow"
	icon = 'icons/mob/hud.dmi'
	icon_state = "hud_arrow"
	screen_loc = ui_team_finder

#undef ALT_APPEARENCE_ID
