// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /atom signals
///from base of atom/proc/Initialize(mapload): sent any time a new atom is created
#define COMSIG_ATOM_CREATED "atom_created"
///! from base of atom/attackby(): (/obj/item, /mob/living, params)
#define COMSIG_PARENT_ATTACKBY "atom_attackby"
	///! Return this in response if you don't want afterattack to be called
	#define COMPONENT_NO_AFTERATTACK 1
///! from base of atom/attack_hulk(): (/mob/living/carbon/human)
#define COMSIG_ATOM_HULK_ATTACK "hulk_attack"
/// from base of atom/examine(): (/mob, list/examine_text)
#define COMSIG_PARENT_EXAMINE "atom_examine"
/// from base of atom/get_examine_name(): (/mob, list/overrides)
#define COMSIG_ATOM_GET_EXAMINE_NAME "atom_examine_name"
	//Positions for overrides list
	#define EXAMINE_POSITION_ARTICLE (1<<0)
	#define EXAMINE_POSITION_BEFORE (1<<1)
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
///! from base of atom/ex_act(): (severity, target)
#define COMSIG_ATOM_EX_ACT "atom_ex_act"
///from base of atom/Bumped(): (/atom/movable)
#define COMSIG_ATOM_BUMPED "atom_bumped"
///! from base of atom/emp_act(): (severity)
#define COMSIG_ATOM_EMP_ACT "atom_emp_act"
///! from base of atom/fire_act(): (exposed_temperature, exposed_volume)
#define COMSIG_ATOM_FIRE_ACT "atom_fire_act"
///! from base of atom/bullet_act(): (/obj/item/projectile, def_zone)
#define COMSIG_ATOM_BULLET_ACT "atom_bullet_act"
///from base of atom/CheckParts(): (list/parts_list, datum/crafting_recipe/R)
#define COMSIG_ATOM_CHECKPARTS "atom_checkparts"
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
///! from base of atom/Exited(): (mob/user, var/obj/item/extrapolator/E, scan = TRUE)
#define COMSIG_ATOM_EXTRAPOLATOR_ACT "atom_extrapolator_act"
///!from base of atom/singularity_pull(): (/datum/component/singularity, current_size)
#define COMSIG_ATOM_SING_PULL "atom_sing_pull"
///from obj/machinery/bsa/full/proc/fire(): ()
#define COMSIG_ATOM_BSA_BEAM "atom_bsa_beam_pass"
	#define COMSIG_ATOM_BLOCKS_BSA_BEAM 1
///! from base of atom/set_light(): (l_range, l_power, l_color)
#define COMSIG_ATOM_SET_LIGHT "atom_set_light"
///! from base of atom/setDir(): (old_dir, new_dir)
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
	#define COMPONENT_BLOCK_REACH 1
///for when an atom has been created through processing (atom/original_atom, list/chosen_processing_option)
#define COMSIG_ATOM_CREATEDBY_PROCESSING "atom_createdby_processing"
///! called when teleporting into a protected turf: (channel, turf/origin)
#define COMSIG_ATOM_INTERCEPT_TELEPORT "intercept_teleport"
	#define COMPONENT_BLOCK_TELEPORT 1
///called when an atom starts orbiting another atom: (atom)
#define COMSIG_ATOM_ORBIT_BEGIN "atom_orbit_begin"
/// called when an atom stops orbiting another atom: (atom)
#define COMSIG_ATOM_ORBIT_STOP "atom_orbit_stop"

/////////////////
/* Attack signals. They should share the returned flags, to standardize the attack chain. */
/// tool_act -> pre_attack -> target.attackby (item.attack) -> afterattack
	///Ends the attack chain. If sent early might cause posterior attacks not to happen.
	#define COMPONENT_CANCEL_ATTACK_CHAIN (1<<0)
	///Skips the specific attack step, continuing for the next one to happen.
	#define COMPONENT_SKIP_ATTACK (1<<1)

///! from base of atom/attack_ghost(): (mob/dead/observer/ghost)
#define COMSIG_ATOM_ATTACK_GHOST "atom_attack_ghost"
///! from base of atom/attack_hand(): (mob/user)
#define COMSIG_ATOM_ATTACK_HAND "atom_attack_hand"
///! from base of atom/attack_paw(): (mob/user)
#define COMSIG_ATOM_ATTACK_PAW "atom_attack_paw"
	//works on all 3.
	#define COMPONENT_NO_ATTACK_HAND 1
///! from base of atom/animal_attack(): (/mob/user)
#define COMSIG_ATOM_ATTACK_ANIMAL "attack_animal"
///This signal return value bitflags can be found in __DEFINES/misc.dm
///called for each movable in a turf contents on /turf/attempt_z_impact(): (atom/movable/A, levels)
#define COMSIG_ATOM_INTERCEPT_Z_FALL "movable_intercept_z_impact"

#define COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE "atom_init_success"

///from base of atom/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
#define COMSIG_ATOM_HITBY "atom_hitby"

/// Sent when the amount of materials in silo connected to remote_materials changes. Does not apply when remote_materials is not connected to a silo.
#define COMSIG_REMOTE_MATERIALS_CHANGED "remote_materials_changed"

/////////////////
#define COMSIG_CLICK "atom_click"								//! from base of atom/Click(): (location, control, params, mob/user)
#define COMSIG_CLICK_SHIFT "shift_click"						//! from base of atom/ShiftClick(): (/mob)
#define COMSIG_CLICK_CTRL "ctrl_click"							//! from base of atom/CtrlClickOn(): (/mob)
#define COMSIG_CLICK_ALT "alt_click"							//! from base of atom/AltClick(): (/mob)
	#define COMPONENT_INTERCEPT_ALT 1
#define COMSIG_CLICK_CTRL_SHIFT "ctrl_shift_click"				//! from base of atom/CtrlShiftClick(/mob)
#define COMSIG_MOUSEDROP_ONTO "mousedrop_onto"					//! from base of atom/MouseDrop(): (/atom/over, /mob/user)
	#define COMPONENT_NO_MOUSEDROP 1
#define COMSIG_MOUSEDROPPED_ONTO "mousedropped_onto"			//! from base of atom/MouseDrop_T: (/atom/from, /mob/user)

/// Check if an emag action should occur, this is inverted, so FALSE means the check succeeds.
#define COMSIG_ATOM_SHOULD_EMAG "atom_should_emag"
/// Do the emag action (if CHECK is FALSE)
#define COMSIG_ATOM_ON_EMAG "atom_on_emag"
