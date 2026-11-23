
/// Round-local baseline for clients without a camera owning their heading.
GLOBAL_VAR_INIT(default_client_dir, NORTH)

/// The trait is the source of truth; NORTH means no direction trait.
/proc/update_default_client_dir()
	var/datum/station_trait/client_view_direction/direction_trait = locate() in SSstation.station_traits
	set_default_client_dir(direction_trait ? direction_trait.view_direction : NORTH)

/proc/set_station_client_direction(newdir)
	if(!(newdir in GLOB.cardinals))
		return FALSE
	if(newdir == NORTH)
		for(var/datum/station_trait/client_view_direction/direction_trait in SSstation.station_traits.Copy())
			direction_trait.revert()
		return TRUE
	var/static/list/direction_traits = list(
		TEXT_SOUTH = /datum/station_trait/client_view_direction/south,
		TEXT_EAST = /datum/station_trait/client_view_direction/east,
		TEXT_WEST = /datum/station_trait/client_view_direction/west,
	)
	return !!SSstation.setup_trait(direction_traits["[newdir]"])

/// Reject diagonals, zero and arbitrary values before changing any clients.
/proc/set_default_client_dir(newdir)
	if(!(newdir in GLOB.cardinals))
		return FALSE
	GLOB.default_client_dir = newdir
	// Include clients still authenticating, not just GLOB.clients.
	for(var/client/viewer in GLOB.clients_unsafe)
		viewer.apply_default_client_dir()
	return TRUE

/client/proc/apply_default_client_dir()
	// Observe mirrors own the heading just like the watched camera does.
	if(!brandish_disconnecting && !brandish_camera && !brandish_mirror)
		setDir(GLOB.default_client_dir)

/client/proc/set_default_client_direction(newdir as text|null)
	set name = "Set Default Client Direction"
	set category = "Debug"
	set desc = "Set a normal-view station trait: NORTH (1) removes it; SOUTH (2), EAST (4), WEST (8). Brandish must be off."
	if(!check_rights_for(src, R_ADMIN | R_DEBUG))
		return
	var/list/directions = list("NORTH" = NORTH, "SOUTH" = SOUTH, "EAST" = EAST, "WEST" = WEST)
	if(isnull(newdir) || newdir == "")
		newdir = input(src, "Choose the default view direction for this round.", "Default client direction", uppertext(dir2text(GLOB.default_client_dir))) as null|anything in directions
		if(isnull(newdir))
			return
	// Input yields; the caller may have lost their rights in the meantime.
	if(!check_rights_for(src, R_ADMIN | R_DEBUG))
		return
	var/direction = directions[uppertext(trim(newdir))]
	if(isnull(direction))
		var/list/numeric_directions = list(TEXT_NORTH = NORTH, TEXT_SOUTH = SOUTH, TEXT_EAST = EAST, TEXT_WEST = WEST)
		direction = numeric_directions[trim(newdir)]
	if(!(direction in GLOB.cardinals))
		to_chat(src, span_warning("Choose NORTH (1), SOUTH (2), EAST (4), or WEST (8)."))
		return
	if(!set_station_client_direction(direction))
		to_chat(src, span_warning("Disable Brandish perspective before adding a default-direction station trait."))
		return
	log_admin("[key_name(src)] set the default client direction to [dir2text(direction)] ([direction]).")
	message_admins("[key_name_admin(src)] set the default client direction to [dir2text(direction)] ([direction]).")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Set Default Client Direction")
