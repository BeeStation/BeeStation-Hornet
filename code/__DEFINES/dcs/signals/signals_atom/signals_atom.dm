// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /atom signals
///from base of atom/proc/Initialize(mapload): sent any time a new atom is created
#define COMSIG_ATOM_CREATED "atom_created"
/// from base of atom/examine(): (/mob, list/examine_text)
#define COMSIG_PARENT_EXAMINE "atom_examine"
/// from base of atom/get_examine_name(): (/mob, list/overrides)
#define COMSIG_ATOM_GET_EXAMINE_NAME "atom_examine_name"
///from base of atom/examine_more(): (/mob)
#define COMSIG_PARENT_EXAMINE_MORE "atom_examine_more"
	//Positions for overrides list
	#define EXAMINE_POSITION_ARTICLE (1<<0)
	#define EXAMINE_POSITION_BEFORE (1<<1)
///from base of atom/examine(): (/mob, list/examine_text)
#define COMSIG_ATOM_EXAMINE "atom_examine"
	//End positions
	#define COMPONENT_EXNAME_CHANGED (1<<0)

///	from base of [/atom/proc/update_appearance]: (updates)
#define COMSIG_ATOM_UPDATE_APPEARANCE "atom_update_appearance"
	/// If returned from [COMSIG_ATOM_UPDATE_APPEARANCE] it prevents the atom from updating its name.
	#define COMSIG_ATOM_NO_UPDATE_NAME UPDATE_NAME
	/// If returned from [COMSIG_ATOM_UPDATE_APPEARANCE] it prevents the atom from updating its desc.
	#define COMSIG_ATOM_NO_UPDATE_DESC UPDATE_DESC
	/// If returned from [COMSIG_ATOM_UPDATE_APPEARANCE] it prevents the atom from updating its icon.
	#define COMSIG_ATOM_NO_UPDATE_ICON UPDATE_ICON
///	from base of [/atom/proc/update_name]: (updates)
#define COMSIG_ATOM_UPDATE_NAME "atom_update_name"
///	from base of [/atom/proc/update_desc]: (updates)
#define COMSIG_ATOM_UPDATE_DESC "atom_update_desc"
///from base of [/atom/update_icon]: ()
#define COMSIG_ATOM_UPDATE_ICON "atom_update_icon"
	/// If returned from [COMSIG_ATOM_UPDATE_ICON] it prevents the atom from updating its icon state.
	#define COMSIG_ATOM_NO_UPDATE_ICON_STATE UPDATE_ICON_STATE
	/// If returned from [COMSIG_ATOM_UPDATE_ICON] it prevents the atom from updating its overlays.
	#define COMSIG_ATOM_NO_UPDATE_OVERLAYS UPDATE_OVERLAYS
	#define COMSIG_ATOM_NO_UPDATE_GREYSCALE UPDATE_GREAYSCALE
///from base of [atom/update_icon_state]: ()
#define COMSIG_ATOM_UPDATE_ICON_STATE "atom_update_icon_state"
//from base of atom/update_overlays(): (list/new_overlays)
#define COMSIG_ATOM_UPDATE_OVERLAYS "atom_update_overlays"
///from base of [/atom/update_icon]: (signalOut, did_anything)
#define COMSIG_ATOM_UPDATED_ICON "atom_updated_icon"
///from base of [/atom/proc/smooth_icon]: ()
#define COMSIG_ATOM_SMOOTHED_ICON "atom_smoothed_icon"
///! from base of atom/Entered(): (atom/movable/entering, /atom)
#define COMSIG_ATOM_ENTERED "atom_entered"
///! from base of atom/Exit(): (/atom/movable/exiting, /atom/newloc)
#define COMSIG_ATOM_EXIT "atom_exit"
	#define COMPONENT_ATOM_BLOCK_EXIT 1
///! from base of atom/Exited(): (atom/movable/exiting, atom/newloc)
#define COMSIG_ATOM_EXITED "atom_exited"
///from the [EX_ACT] wrapper macro: (severity, target)
#define COMSIG_ATOM_EX_ACT "atom_ex_act"
///from base of atom/Bumped(): (/atom/movable)
#define COMSIG_ATOM_BUMPED "atom_bumped"
///! from base of atom/emp_act(): (severity)
#define COMSIG_ATOM_EMP_ACT "atom_emp_act"
///! from base of atom/fire_act(): (exposed_temperature, exposed_volume)
#define COMSIG_ATOM_FIRE_ACT "atom_fire_act"
///! from base of atom/bullet_act(): (/obj/projectile, def_zone)
#define COMSIG_ATOM_BULLET_ACT "atom_bullet_act"
	#define COMSIG_ATOM_BULLET_ACT_HIT			(1 << 0)
	#define COMSIG_ATOM_BULLET_ACT_BLOCK		(1 << 1)
	#define COMSIG_ATOM_BULLET_ACT_FORCE_PIERCE	(1 << 2)
///from base of atom/CheckParts(): (list/parts_list, datum/crafting_recipe/R)
#define COMSIG_ATOM_CHECKPARTS "atom_checkparts"
///from base of atom/CheckParts(): (atom/movable/new_craft) - The atom has just been used in a crafting recipe and has been moved inside new_craft.
#define COMSIG_ATOM_USED_IN_CRAFT "atom_used_in_craft"
///! from base of atom/blob_act(): (/obj/structure/blob)
#define COMSIG_ATOM_BLOB_ACT "atom_blob_act"
/// if returned, forces nothing to happen when the atom is attacked by a blob
	#define COMPONENT_CANCEL_BLOB_ACT (1<<0)
///! from base of atom/acid_act(): (acidpwr, acid_volume)
#define COMSIG_ATOM_ACID_ACT "atom_acid_act"
///! from base of atom/rad_act(intensity)
#define COMSIG_ATOM_RAD_ACT "atom_rad_act"
///! from base of atom/narsie_act(): ()
#define COMSIG_ATOM_NARSIE_ACT "atom_narsie_act"
///! from base of atom/ratvar_act(): ()
#define COMSIG_ATOM_RATVAR_ACT "atom_ratvar_act"
///! from base of atom/light_eater_act(): (obj/item/light_eater/light_eater)
#define COMSIG_ATOM_LIGHTEATER_ACT "atom_lighteater_act"
///! from base of atom/eminence_act(): ()
#define COMSIG_ATOM_EMINENCE_ACT "atom_eminence_act"
///! from base of atom/rcd_act(): (/mob, /obj/item/construction/rcd, passed_mode)
#define COMSIG_ATOM_RCD_ACT "atom_rcd_act"
///! from base of atom/teleport_act(): ()
#define COMSIG_ATOM_TELEPORT_ACT "atom_teleport_act"
///! from base of atom/Exited(): (mob/user, obj/item/extrapolator/extrapolator, dry_run, list/result)
#define COMSIG_ATOM_EXTRAPOLATOR_ACT "atom_extrapolator_act"
///!from base of atom/singularity_pull(): (/datum/component/singularity, current_size)
#define COMSIG_ATOM_SING_PULL "atom_sing_pull"
///from obj/machinery/bsa/full/proc/fire(): ()
#define COMSIG_ATOM_BSA_BEAM "atom_bsa_beam_pass"
	#define COMSIG_ATOM_BLOCKS_BSA_BEAM 1
///from base of atom/setDir(): (old_dir, new_dir). Called before the direction changes.
#define COMSIG_ATOM_DIR_CHANGE "atom_dir_change"
///! from base of atom/handle_atom_del(): (atom/deleted)
#define COMSIG_ATOM_CONTENTS_DEL "atom_contents_del"
///! from base of atom/has_gravity(): (turf/location, list/forced_gravities)
#define COMSIG_ATOM_HAS_GRAVITY "atom_has_gravity"
///! from proc/get_rad_contents(): ()
#define COMSIG_ATOM_RAD_PROBE "atom_rad_probe"
	#define COMPONENT_BLOCK_RADIATION 1
///! from base of datum/radiation_wave/radiate(): (strength)
#define COMSIG_ATOM_RAD_CONTAMINATING "atom_rad_contam"
	#define COMPONENT_BLOCK_CONTAMINATION 1
///! from base of datum/radiation_wave/check_obstructions(): (datum/radiation_wave, width)
#define COMSIG_ATOM_RAD_WAVE_PASSING "atom_rad_wave_pass"
	#define COMPONENT_RAD_WAVE_HANDLED 1
///! from internal loop in atom/movable/proc/CanReach(): (list/next)
#define COMSIG_ATOM_CANREACH "atom_can_reach"
	#define COMPONENT_ALLOW_REACH (1<<0)
///for when an atom has been created through processing (atom/original_atom, list/chosen_processing_option)
#define COMSIG_ATOM_CREATEDBY_PROCESSING "atom_createdby_processing"
///when an atom is processed (mob/living/user, obj/item/I, list/atom/results)
#define COMSIG_ATOM_PROCESSED "atom_processed"
///! from the base of atom/intercept_teleport: (channel, turf/origin, turf/destination)
#define COMSIG_ATOM_INTERCEPT_TELEPORT "intercept_teleport"
	#define COMPONENT_BLOCK_TELEPORT 1
#define COMSIG_ATOM_HEARER_IN_VIEW "atom_hearer_in_view" //called when an atom is added to the hearers on get_hearers_in_view(): (list/processing_list, list/hearers)
///called when an atom starts orbiting another atom: (atom)
#define COMSIG_ATOM_ORBIT_BEGIN "atom_orbit_begin"
/// called when an atom stops orbiting another atom: (atom)
#define COMSIG_ATOM_ORBIT_STOP "atom_orbit_stop"

///This signal return value bitflags can be found in __DEFINES/misc.dm
///called for each movable in a turf contents on /turf/attempt_z_impact(): (atom/movable/A, levels)
#define COMSIG_ATOM_INTERCEPT_Z_FALL "movable_intercept_z_impact"
///signal sent out by an atom upon onZImpact : (turf/impacted_turf, levels)
#define COMSIG_ATOM_ON_Z_IMPACT "movable_on_z_impact"

#define COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE "atom_init_success"

///from base of atom/throw_impact, sent by the target hit by a thrown object. (hit_atom, thrown_atom, datum/thrownthing/throwingdatum)
#define COMSIG_ATOM_PREHITBY "atom_pre_hitby"
	#define COMSIG_HIT_PREVENTED (1<<0)
///from base of atom/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
#define COMSIG_ATOM_HITBY "atom_hitby"

///from base of atom/set_opacity(): (new_opacity)
#define COMSIG_ATOM_SET_OPACITY "atom_set_opacity"

/// Sent when the amount of materials in silo connected to remote_materials changes. Does not apply when remote_materials is not connected to a silo.
#define COMSIG_REMOTE_MATERIALS_CHANGED "remote_materials_changed"

/////////////////

/// Check if an emag action should occur, this is inverted, so FALSE means the check succeeds.
#define COMSIG_ATOM_SHOULD_EMAG "atom_should_emag"
/// Do the emag action (if CHECK is FALSE)
#define COMSIG_ATOM_ON_EMAG "atom_on_emag"

/////////////////
/// Radio jamming signals
/////////////////

#define COMSIG_ATOM_JAMMED "become_jammed"						//! Relayed to atoms when they become jammed if they have the jam_receiver components.
#define COMSIG_ATOM_UNJAMMED "become_unjammed"					//! Relayed to atoms when they become unjammed if they have the jam_receiver components.

//////////////////

// From /atom/proc/set_density(new_value) for when an atom changes density
#define COMSIG_ATOM_DENSITY_CHANGED "atom_density_change"
