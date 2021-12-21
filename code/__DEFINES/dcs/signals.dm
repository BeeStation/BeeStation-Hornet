// All signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// global signals
// These are signals which can be listened to by any component on any parent
// start global signals with "!", this used to be necessary but now it's just a formatting choice
#define COMSIG_GLOB_NEW_Z "!new_z"								//! from base of datum/controller/subsystem/mapping/proc/add_new_zlevel(): (list/args)
#define COMSIG_GLOB_VAR_EDIT "!var_edit"						//! called after a successful var edit somewhere in the world: (list/args)
#define COMSIG_GLOB_EXPLOSION "!explosion"						//! called after an explosion happened : (epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
#define COMSIG_GLOB_MOB_CREATED "!mob_created"					//! mob was created somewhere : (mob)
#define COMSIG_GLOB_MOB_DEATH "!mob_death"						//! mob died somewhere : (mob , gibbed)
#define COMSIG_GLOB_LIVING_SAY_SPECIAL "!say_special"			//! global living say plug - use sparingly: (mob/speaker , message)
#define COMSIG_GLOB_CARBON_THROW_THING	"!throw_thing"			//! a person somewhere has thrown something : (mob/living/carbon/carbon_thrower, target)
/// called by datum/cinematic/play() : (datum/cinematic/new_cinematic)
#define COMSIG_GLOB_PLAY_CINEMATIC "!play_cinematic"
	#define COMPONENT_GLOB_BLOCK_CINEMATIC 1
/// Random event is trying to roll. (/datum/round_event_control/random_event)
/// Called by (/datum/round_event_control/preRunEvent).
#define COMSIG_GLOB_PRE_RANDOM_EVENT "!pre_random_event"
	/// Do not allow this random event to continue.
	#define CANCEL_PRE_RANDOM_EVENT (1<<0)

/// Signifies that this proc is used to handle signals.
/// Every proc you pass to RegisterSignal must have this.
#define SIGNAL_HANDLER SHOULD_NOT_SLEEP(TRUE)


//////////////////////////////////////////////////////////////////

// /datum signals
#define COMSIG_COMPONENT_ADDED "component_added"				//! when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"			//! before a component is removed from a datum because of RemoveComponent: (/datum/component)
#define COMSIG_PARENT_PREQDELETED "parent_preqdeleted"			//! before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation
#define COMSIG_PARENT_QDELETING "parent_qdeleting"				//! just before a datum's Destroy() is called: (force), at this point none of the other components chose to interrupt qdel and Destroy will be called
#define COMSIG_TOPIC "handle_topic"                             //! generic topic handler (usr, href_list)

/// fires on the target datum when an element is attached to it (/datum/element)
#define COMSIG_ELEMENT_ATTACH "element_attach"
/// fires on the target datum when an element is attached to it  (/datum/element)
#define COMSIG_ELEMENT_DETACH "element_detach"

/// Sent when the amount of materials in material_container changes
#define COMSIG_MATERIAL_CONTAINER_CHANGED "material_container_changed"

// /atom signals
#define COMSIG_ATOM_CREATED "atom_created"						///from base of atom/proc/Initialize(): sent any time a new atom is created
#define COMSIG_PARENT_ATTACKBY "atom_attackby"			        //! from base of atom/attackby(): (/obj/item, /mob/living, params)
	#define COMPONENT_NO_AFTERATTACK 1							//! Return this in response if you don't want afterattack to be called
#define COMSIG_ATOM_HULK_ATTACK "hulk_attack"					//! from base of atom/attack_hulk(): (/mob/living/carbon/human)
#define COMSIG_PARENT_EXAMINE "atom_examine"                    //! from base of atom/examine(): (/mob, list/examine_text)
#define COMSIG_ATOM_GET_EXAMINE_NAME "atom_examine_name"		//! from base of atom/get_examine_name(): (/mob, list/overrides)
	//Positions for overrides list
	#define EXAMINE_POSITION_ARTICLE 1
	#define EXAMINE_POSITION_BEFORE 2
	//End positions
	#define COMPONENT_EXNAME_CHANGED 1
#define COMSIG_ATOM_UPDATE_ICON "atom_update_icon"				//from base of atom/update_icon(): ()
	#define COMSIG_ATOM_NO_UPDATE_ICON_STATE	1
	#define COMSIG_ATOM_NO_UPDATE_OVERLAYS		2
#define COMSIG_ATOM_UPDATE_OVERLAYS "atom_update_overlays"		//from base of atom/update_overlays(): (list/new_overlays)
#define COMSIG_ATOM_ENTERED "atom_entered"                      //! from base of atom/Entered(): (atom/movable/entering, /atom)
#define COMSIG_ATOM_EXIT "atom_exit"							//! from base of atom/Exit(): (/atom/movable/exiting, /atom/newloc)
	#define COMPONENT_ATOM_BLOCK_EXIT 1
#define COMSIG_ATOM_EXITED "atom_exited"						//! from base of atom/Exited(): (atom/movable/exiting, atom/newloc)
#define COMSIG_ATOM_EX_ACT "atom_ex_act"						//! from base of atom/ex_act(): (severity, target)
#define COMSIG_ATOM_BUMPED "atom_bumped"						//from base of atom/Bumped(): (/atom/movable)
#define COMSIG_ATOM_EMP_ACT "atom_emp_act"						//! from base of atom/emp_act(): (severity)
#define COMSIG_ATOM_FIRE_ACT "atom_fire_act"					//! from base of atom/fire_act(): (exposed_temperature, exposed_volume)
#define COMSIG_ATOM_BULLET_ACT "atom_bullet_act"				//! from base of atom/bullet_act(): (/obj/item/projectile, def_zone)
#define COMSIG_ATOM_BLOB_ACT "atom_blob_act"					//! from base of atom/blob_act(): (/obj/structure/blob)
#define COMSIG_ATOM_ACID_ACT "atom_acid_act"					//! from base of atom/acid_act(): (acidpwr, acid_volume)
#define COMSIG_ATOM_EMAG_ACT "atom_emag_act"					//! from base of atom/emag_act(): ()
#define COMSIG_ATOM_RAD_ACT "atom_rad_act"						//! from base of atom/rad_act(intensity)
#define COMSIG_ATOM_NARSIE_ACT "atom_narsie_act"				//! from base of atom/narsie_act(): ()
#define COMSIG_ATOM_RATVAR_ACT "atom_ratvar_act"				//! from base of atom/ratvar_act(): ()
#define COMSIG_ATOM_EMINENCE_ACT "atom_eminence_act"				//! from base of atom/eminence_act(): ()
#define COMSIG_ATOM_RCD_ACT "atom_rcd_act"						//! from base of atom/rcd_act(): (/mob, /obj/item/construction/rcd, passed_mode)
#define COMSIG_ATOM_TELEPORT_ACT "atom_teleport_act"			//! from base of atom/teleport_act(): ()
#define COMSIG_ATOM_EXTRAPOLATOR_ACT "atom_extrapolator_act"	//! from base of atom/Exited(): (mob/user, var/obj/item/extrapolator/E, scan = TRUE)
#define COMSIG_ATOM_SING_PULL "atom_sing_pull"					//! from base of atom/singularity_pull(): (S, current_size)
#define COMSIG_ATOM_BSA_BEAM "atom_bsa_beam_pass"				//from obj/machinery/bsa/full/proc/fire(): ()
	#define COMSIG_ATOM_BLOCKS_BSA_BEAM 1
#define COMSIG_ATOM_SET_LIGHT "atom_set_light"					//! from base of atom/set_light(): (l_range, l_power, l_color)
#define COMSIG_ATOM_DIR_CHANGE "atom_dir_change"				//! from base of atom/setDir(): (old_dir, new_dir)
#define COMSIG_ATOM_CONTENTS_DEL "atom_contents_del"			//! from base of atom/handle_atom_del(): (atom/deleted)
#define COMSIG_ATOM_HAS_GRAVITY "atom_has_gravity"				//! from base of atom/has_gravity(): (turf/location, list/forced_gravities)
#define COMSIG_ATOM_RAD_PROBE "atom_rad_probe"					//! from proc/get_rad_contents(): ()
	#define COMPONENT_BLOCK_RADIATION 1
#define COMSIG_ATOM_RAD_CONTAMINATING "atom_rad_contam"			//! from base of datum/radiation_wave/radiate(): (strength)
	#define COMPONENT_BLOCK_CONTAMINATION 1
#define COMSIG_ATOM_RAD_WAVE_PASSING "atom_rad_wave_pass"		//! from base of datum/radiation_wave/check_obstructions(): (datum/radiation_wave, width)
  #define COMPONENT_RAD_WAVE_HANDLED 1
#define COMSIG_ATOM_CANREACH "atom_can_reach"					//! from internal loop in atom/movable/proc/CanReach(): (list/next)
	#define COMPONENT_BLOCK_REACH 1
#define COMSIG_ATOM_INTERCEPT_TELEPORT "intercept_teleport"		//! called when teleporting into a protected turf: (channel, turf/origin)
	#define COMPONENT_BLOCK_TELEPORT 1
#define COMSIG_ATOM_ORBIT_BEGIN "atom_orbit_begin"           //called when an atom starts orbiting another atom: (atom)
#define COMSIG_ATOM_ORBIT_STOP "atom_orbit_stop"           //called when an atom stops orbiting another atom: (atom)
/////////////////
/* Attack signals. They should share the returned flags, to standardize the attack chain. */
/// tool_act -> pre_attack -> target.attackby (item.attack) -> afterattack
	///Ends the attack chain. If sent early might cause posterior attacks not to happen.
	#define COMPONENT_CANCEL_ATTACK_CHAIN (1<<0)
	///Skips the specific attack step, continuing for the next one to happen.
	#define COMPONENT_SKIP_ATTACK (1<<1)

#define COMSIG_ATOM_ATTACK_GHOST "atom_attack_ghost"			//! from base of atom/attack_ghost(): (mob/dead/observer/ghost)
#define COMSIG_ATOM_ATTACK_HAND "atom_attack_hand"				//! from base of atom/attack_hand(): (mob/user)
#define COMSIG_ATOM_ATTACK_PAW "atom_attack_paw"				//! from base of atom/attack_paw(): (mob/user)
	#define COMPONENT_NO_ATTACK_HAND 1							//works on all 3.
#define COMSIG_ATOM_ATTACK_ANIMAL "attack_animal"				//! from base of atom/animal_attack(): (/mob/user)
//This signal return value bitflags can be found in __DEFINES/misc.dm
#define COMSIG_ATOM_INTERCEPT_Z_FALL "movable_intercept_z_impact"	//called for each movable in a turf contents on /turf/zImpact(): (atom/movable/A, levels)

#define COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE "atom_init_success"

///from base of atom/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
#define COMSIG_ATOM_HITBY "atom_hitby"

/// Sent when the amount of materials in silo connected to remote_materials changes. Does not apply when remote_materials is not connected to a silo.
#define COMSIG_REMOTE_MATERIALS_CHANGED "remote_materials_changed"

/////////////////

#define COMSIG_AREA_POWER_CHANGE "area_power_change"			//! from base of area/proc/power_change(): ()
#define COMSIG_ENTER_AREA "enter_area" 							//! from base of area/Entered(): (/area)
#define COMSIG_EXIT_AREA "exit_area" 							//! from base of area/Exited(): (/area)

#define COMSIG_CLICK "atom_click"								//! from base of atom/Click(): (location, control, params, mob/user)
#define COMSIG_CLICK_SHIFT "shift_click"						//! from base of atom/ShiftClick(): (/mob)
#define COMSIG_CLICK_CTRL "ctrl_click"							//! from base of atom/CtrlClickOn(): (/mob)
#define COMSIG_CLICK_ALT "alt_click"							//! from base of atom/AltClick(): (/mob)
#define COMSIG_CLICK_CTRL_SHIFT "ctrl_shift_click"				//! from base of atom/CtrlShiftClick(/mob)
#define COMSIG_MOUSEDROP_ONTO "mousedrop_onto"					//! from base of atom/MouseDrop(): (/atom/over, /mob/user)
	#define COMPONENT_NO_MOUSEDROP 1
#define COMSIG_MOUSEDROPPED_ONTO "mousedropped_onto"			//! from base of atom/MouseDrop_T: (/atom/from, /mob/user)

// /area signals
#define COMSIG_AREA_ENTERED "area_entered" 						//! from base of area/Entered(): (atom/movable/M)
#define COMSIG_AREA_EXITED "area_exited" 						//! from base of area/Exited(): (atom/movable/M)

// /turf signals
#define COMSIG_TURF_CHANGE "turf_change"						//! from base of turf/ChangeTurf(): (path, list/new_baseturfs, flags, list/transferring_comps)
#define COMSIG_TURF_HAS_GRAVITY "turf_has_gravity"				//! from base of atom/has_gravity(): (atom/asker, list/forced_gravities)
#define COMSIG_TURF_MULTIZ_NEW "turf_multiz_new"				//! from base of turf/New(): (turf/source, direction)
#define COMSIG_TURF_AFTER_SHUTTLE_MOVE "turf_after_shuttle_move"	//! from base of turf/proc/afterShuttleMove: (turf/new_turf)

// /atom/movable signals
#define COMSIG_MOVABLE_PRE_MOVE "movable_pre_move"				//! from base of atom/movable/Moved(): (/atom)
	#define COMPONENT_MOVABLE_BLOCK_PRE_MOVE 1
#define COMSIG_MOVABLE_MOVED "movable_moved"					//! from base of atom/movable/Moved(): (/atom, dir)
#define COMSIG_MOVABLE_CROSS "movable_cross"					//! from base of atom/movable/Cross(): (/atom/movable)
#define COMSIG_MOVABLE_BUMP "movable_bump"						//! from base of atom/movable/Bump(): (/atom)
#define COMSIG_MOVABLE_IMPACT "movable_impact"					//! from base of atom/movable/throw_impact(): (/atom/hit_atom, /datum/thrownthing/throwingdatum)
#define COMSIG_MOVABLE_IMPACT_ZONE "item_impact_zone"			//! from base of mob/living/hitby(): (mob/living/target, hit_zone)
#define COMSIG_MOVABLE_BUCKLE "buckle"							//! from base of atom/movable/buckle_mob(): (mob, force)
#define COMSIG_MOVABLE_UNBUCKLE "unbuckle"						//! from base of atom/movable/unbuckle_mob(): (mob, force)
#define COMSIG_MOVABLE_PRE_THROW "movable_pre_throw"			//! from base of atom/movable/throw_at(): (list/args)
	#define COMPONENT_CANCEL_THROW 1
#define COMSIG_MOVABLE_POST_THROW "movable_post_throw"			//! from base of atom/movable/throw_at(): (datum/thrownthing, spin)
#define COMSIG_MOVABLE_THROW_LANDED "movable_throw_landed"		//! from base of datum/thrownthing/finalize(): (obj/thrown_object, datum/thrownthing) used for when a throw is finished
#define COMSIG_MOVABLE_Z_CHANGED "movable_ztransit" 			//! from base of atom/movable/onTransitZ(): (old_z, new_z)
#define COMSIG_MOVABLE_SECLUDED_LOCATION "movable_secluded" 	//! called when the movable is placed in an unaccessible area, used for stationloving: ()
#define COMSIG_MOVABLE_HEAR "movable_hear"						//! from base of atom/movable/Hear(): (message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	#define HEARING_MESSAGE 1
	#define HEARING_SPEAKER 2
//	#define HEARING_LANGUAGE 3
	#define HEARING_RAW_MESSAGE 4
	/* #define HEARING_RADIO_FREQ 5
	#define HEARING_SPANS 6
	#define HEARING_MESSAGE_MODE 7 */
#define COMSIG_MOVABLE_DISPOSING "movable_disposing"			//! called when the movable is added to a disposal holder object for disposal movement: (obj/structure/disposalholder/holder, obj/machinery/disposal/source)

// /mob signals
#define COMSIG_MOB_LOGIN "mob_login"
#define COMSIG_MOB_LOGOUT "mob_logout"							///from base of /mob/Logout(): ()
#define COMSIG_MOB_DEATH "mob_death"							//! from base of mob/death(): (gibbed)
#define COMSIG_MOB_STATCHANGE "mob_statchange"					//from base of mob/set_stat(): (new_stat)
#define COMSIG_MOB_CLICKON "mob_clickon"						//! from base of mob/clickon(): (atom/A, params)
	#define COMSIG_MOB_CANCEL_CLICKON 1
#define COMSIG_MOB_ALLOWED "mob_allowed"						//! from base of obj/allowed(mob/M): (/obj) returns bool, if TRUE the mob has id access to the obj
#define COMSIG_MOB_RECEIVE_MAGIC "mob_receive_magic"			//! from base of mob/anti_magic_check(): (mob/user, magic, holy, major, self, protection_sources)
	#define COMPONENT_BLOCK_MAGIC 1
#define COMSIG_MOB_HUD_CREATED "mob_hud_created"				//! from base of mob/create_mob_hud(): ()
#define COMSIG_MOB_ATTACK_HAND "mob_attack_hand"				//! from base of
#define COMSIG_MOB_ATTACK_HAND_TURF "mob_attack_hand_turf"		//! from base of turf/attack_hand
#define COMSIG_MOB_HAND_ATTACKED "mob_hand_attacked"			//! from base of
#define COMSIG_MOB_ITEM_ATTACK "mob_item_attack"				//! from base of /obj/item/attack(): (mob/M, mob/user)
	#define COMPONENT_ITEM_NO_ATTACK 1
#define COMSIG_MOB_APPLY_DAMGE	"mob_apply_damage"				//! from base of /mob/living/proc/apply_damage(): (damage, damagetype, def_zone)
#define COMSIG_MOB_ITEM_AFTERATTACK "mob_item_afterattack"		//! from base of obj/item/afterattack(): (atom/target, mob/user, proximity_flag, click_parameters)
#define COMSIG_MOB_ATTACK_RANGED "mob_attack_ranged"			//! from base of mob/RangedAttack(): (atom/A, params)
#define COMSIG_MOB_THROW "mob_throw"							//! from base of /mob/throw_item(): (atom/target)
#define COMSIG_MOB_UPDATE_SIGHT "mob_update_sight"				//! from base of /mob/update_sight(): ()
#define COMSIG_MOB_EXAMINATE "mob_examinate"					//from base of /mob/verb/examinate(): (atom/target)
#define COMSIG_MOB_SAY "mob_say" // from /mob/living/say(): ()
#define COMSIG_MOB_ATTACK_ALIEN "mob_attack_alien"				//! from base of /mob/living/attack_alien(): (user)
#define COMSIG_MOB_MOVESPEED_UPDATED "mob_update_movespeed"		//! From base of mob/update_movespeed():area
	#define COMPONENT_UPPERCASE_SPEECH 1
	// used to access COMSIG_MOB_SAY argslist
	#define SPEECH_MESSAGE 1
	// #define SPEECH_BUBBLE_TYPE 2
	#define SPEECH_SPANS 3
	/* #define SPEECH_SANITIZE 4
	#define SPEECH_LANGUAGE 5
	#define SPEECH_IGNORE_SPAM 6
	#define SPEECH_FORCED 7 */
#define COMSIG_MOB_EMOTE "mob_emote" // from /mob/living/emote(): ()
#define COMSIG_MOB_SWAP_HANDS "mob_swap_hands"        //from base of mob/swap_hand()
  #define COMPONENT_BLOCK_SWAP 1
#define COMSIG_MOB_DEADSAY "mob_deadsay" // from /mob/say_dead(): (mob/speaker, message)
	#define MOB_DEADSAY_SIGNAL_INTERCEPT 1
#define COMSIG_MOB_POINTED "mob_pointed" //from base of /mob/verb/pointed: (atom/A)

///from base of /obj/item/mmi/set_brainmob(): (mob/living/brain/new_brainmob)
#define COMSIG_MMI_SET_BRAINMOB "mmi_set_brainmob"

// /mob/living signals
#define COMSIG_LIVING_REVIVE "living_revive"					//! from base of mob/living/revive() (/mob/living, full_heal, admin_revive)
#define COMSIG_LIVING_RESIST "living_resist"					//! from base of mob/living/resist() (/mob/living)
#define COMSIG_LIVING_IGNITED "living_ignite"					//! from base of mob/living/IgniteMob() (/mob/living)
#define COMSIG_LIVING_EXTINGUISHED "living_extinguished"		//! from base of mob/living/ExtinguishMob() (/mob/living)
#define COMSIG_LIVING_ELECTROCUTE_ACT "living_electrocute_act"	//! from base of mob/living/electrocute_act(): (shock_damage)
#define COMSIG_LIVING_MINOR_SHOCK "living_minor_shock"			//! sent by stuff like stunbatons and tasers: ()
#define COMSIG_PROCESS_BORGCHARGER_OCCUPANT "living_charge"		//! sent from borg recharge stations: (amount, repairs)
#define COMSIG_BORG_SAFE_DECONSTRUCT "borg_safe_decon"			//sent from borg mobs to itself, for tools to catch an upcoming destroy() due to safe decon (rather than detonation)
#define COMSIG_MOB_CLIENT_LOGIN "comsig_mob_client_login"
#define COMSIG_LIVING_TRY_SYRINGE "living_try_syringe"			///From post-can inject check of syringe after attack (mob/user)
#define COMSIG_LIVING_START_PULL "living_start_pull"			///called on /living when someone starts pulling (atom/movable/pulled, state, force)

//ALL OF THESE DO NOT TAKE INTO ACCOUNT WHETHER AMOUNT IS 0 OR LOWER AND ARE SENT REGARDLESS!
#define COMSIG_LIVING_STATUS_STUN "living_stun"					//! from base of mob/living/Stun() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_KNOCKDOWN "living_knockdown"		//! from base of mob/living/Knockdown() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_PARALYZE "living_paralyze"			//! from base of mob/living/Paralyze() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_IMMOBILIZE "living_immobilize"		//! from base of mob/living/Immobilize() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_UNCONSCIOUS "living_unconscious"	//! from base of mob/living/Unconscious() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_SLEEP "living_sleeping"			//! from base of mob/living/Sleeping() (amount, update, ignore)
	#define COMPONENT_NO_STUN 1			//For all of them

// /mob/living/carbon signals
#define COMSIG_CARBON_SOUNDBANG "carbon_soundbang"				//! from base of mob/living/carbon/soundbang_act(): (list(intensity))
#define COMSIG_CARBON_SPECIESCHANGE "mob_carbon_specieschange"	//! from base of mob/living/carbon/set_species(): (new_race)
#define COMSIG_CARBON_GAIN_ORGAN "carbon_gain_organ"			//from /item/organ/proc/Insert() (/obj/item/organ/)
#define COMSIG_CARBON_LOSE_ORGAN "carbon_lose_organ"			//from /item/organ/proc/Remove() (/obj/item/organ/)
#define COMSIG_CARBON_EMBED_RIP "item_embed_start_rip"						// defined twice, in carbon and human's topics, fired when interacting with a valid embedded_object to pull it out (mob/living/carbon/target, /obj/item, /obj/item/bodypart/L)
#define COMSIG_CARBON_EMBED_REMOVAL "item_embed_remove_safe"		// called when removing a given item from a mob, from mob/living/carbon/remove_embedded_object(mob/living/carbon/target, /obj/item)
#define COMSIG_CARBON_CUFF_ATTEMPTED "carbon_attempt_cuff"			///Called when someone attempts to cuff a carbon

// /mob/living/simple_animal/hostile signals
#define COMSIG_HOSTILE_ATTACKINGTARGET "hostile_attackingtarget"
	#define COMPONENT_HOSTILE_NO_ATTACK 1

// /obj/item/grenade signals
#define COMSIG_GRENADE_PRIME "grenade_prime"					//called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GRENADE_ARMED "grenade_armed"					//called in /obj/item/gun/process_fire (user, target, params, zone_override)

// /obj/item/projectile signals (sent to the firer)
#define COMSIG_PROJECTILE_SELF_ON_HIT "projectile_self_on_hit"			// from base of /obj/item/projectile/proc/on_hit(): (atom/movable/firer, atom/target, Angle)
#define COMSIG_PROJECTILE_ON_HIT "projectile_on_hit"			// from base of /obj/item/projectile/proc/on_hit(): (atom/movable/firer, atom/target, Angle)
#define COMSIG_PROJECTILE_BEFORE_FIRE "projectile_before_fire" 			// from base of /obj/item/projectile/proc/fire(): (obj/item/projectile, atom/original_target)
#define COMSIG_PROJECTILE_PREHIT "com_proj_prehit"				// sent to targets during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_RANGE_OUT "projectile_range_out"				// sent to targets during the process_hit proc of projectiles
#define COMSIG_EMBED_TRY_FORCE "item_try_embed"					// sent when trying to force an embed (mainly for projectiles, only used in the embed element)
	#define COMPONENT_EMBED_SUCCESS (1<<1)						// returned when the embed is successful

#define COMSIG_PELLET_CLOUD_INIT "pellet_cloud_init"				// sent to targets during the process_hit proc of projectiles

// /obj/mecha signals
#define COMSIG_MECHA_ACTION_ACTIVATE "mecha_action_activate"	//sent from mecha action buttons to the mecha they're linked to

// /obj signals
#define COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH "obj_default_unfasten_wrench"
#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"				//! from base of obj/deconstruct(): (disassembled)
#define COMSIG_OBJ_SETANCHORED "obj_setanchored"				//! called in /obj/structure/setAnchored(): (value)

// /obj/item signals
#define COMSIG_ITEM_ATTACK "item_attack"						//! from base of obj/item/attack(): (/mob/living/target, /mob/living/user)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"				//! from base of obj/item/attack_self(): (/mob)
	#define COMPONENT_NO_INTERACT 1
#define COMSIG_ITEM_ATTACK_OBJ "item_attack_obj"				//! from base of obj/item/attack_obj(): (/obj, /mob)
	#define COMPONENT_NO_ATTACK_OBJ 1
#define COMSIG_ITEM_PRE_ATTACK "item_pre_attack"				//! from base of obj/item/pre_attack(): (atom/target, mob/user, params)
	#define COMPONENT_NO_ATTACK 1
#define COMSIG_ITEM_AFTERATTACK "item_afterattack"				//! from base of obj/item/afterattack(): (atom/target, mob/user, params)
#define COMSIG_ITEM_EQUIPPED "item_equip"						//! from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_DROPPED "item_drop"							//! from base of obj/item/dropped(): (mob/user)
#define COMSIG_ITEM_PICKUP "item_pickup"						//! from base of obj/item/pickup(): (/mob/taker)
#define COMSIG_ITEM_ATTACK_ZONE "item_attack_zone"				//! from base of mob/living/carbon/attacked_by(): (mob/living/carbon/target, mob/living/user, hit_zone)
#define COMSIG_ITEM_IMBUE_SOUL "item_imbue_soul" 				//! return a truthy value to prevent ensouling, checked in /obj/effect/proc_holder/spell/targeted/lichdom/cast(): (mob/user)
#define COMSIG_ITEM_MARK_RETRIEVAL "item_mark_retrieval"		//! called before marking an object for retrieval, checked in /obj/effect/proc_holder/spell/targeted/summonitem/cast() : (mob/user)
	#define COMPONENT_BLOCK_MARK_RETRIEVAL 1
#define COMSIG_ITEM_HIT_REACT "item_hit_react"					//! from base of obj/item/hit_reaction(): (list/args)
#define COMSIG_ITEM_SHARPEN_ACT "sharpen_act"           //! from base of item/sharpener/attackby(): (amount, max)
  #define COMPONENT_BLOCK_SHARPEN_APPLIED 1
  #define COMPONENT_BLOCK_SHARPEN_BLOCKED 2
  #define COMPONENT_BLOCK_SHARPEN_ALREADY 4
  #define COMPONENT_BLOCK_SHARPEN_MAXED 8
#define COMSIG_ITEM_CHECK_WIELDED "item_check_wielded"  //! used to check if the item is wielded for special effects
  #define COMPONENT_IS_WIELDED 1
#define COMSIG_ITEM_DISABLE_EMBED "item_disable_embed"			///from [/obj/item/proc/disableEmbedding]:
#define COMSIG_MINE_TRIGGERED "minegoboom"						///from [/obj/effect/mine/proc/triggermine]:

// /obj/item/clothing signals
#define COMSIG_SHOES_STEP_ACTION "shoes_step_action"			//! from base of obj/item/clothing/shoes/proc/step_action(): ()

// /obj/item/implant signals
#define COMSIG_IMPLANT_ACTIVATED "implant_activated"			//! from base of /obj/item/implant/proc/activate(): ()
#define COMSIG_IMPLANT_IMPLANTING "implant_implanting"			//! from base of /obj/item/implant/proc/implant(): (list/args)
	#define COMPONENT_STOP_IMPLANTING 1
#define COMSIG_IMPLANT_OTHER "implant_other"					//! called on already installed implants when a new one is being added in /obj/item/implant/proc/implant(): (list/args, obj/item/implant/new_implant)
	//#define COMPONENT_STOP_IMPLANTING 1 //The name makes sense for both
	#define COMPONENT_DELETE_NEW_IMPLANT 2
	#define COMPONENT_DELETE_OLD_IMPLANT 4
#define COMSIG_IMPLANT_EXISTING_UPLINK "implant_uplink_exists"	//! called on implants being implanted into someone with an uplink implant: (datum/component/uplink)
	//This uses all return values of COMSIG_IMPLANT_OTHER

/// called on implants, after a successful implantation: (mob/living/target, mob/user, silent, force)
#define COMSIG_IMPLANT_IMPLANTED "implant_implanted"

/// called on implants, after an implant has been removed: (mob/living/source, silent, special)
#define COMSIG_IMPLANT_REMOVED "implant_removed"

// /obj/item/pda signals
#define COMSIG_PDA_CHANGE_RINGTONE "pda_change_ringtone"		//! called on pda when the user changes the ringtone: (mob/living/user, new_ringtone)
	#define COMPONENT_STOP_RINGTONE_CHANGE 1

// /obj/item/radio signals
#define COMSIG_RADIO_NEW_FREQUENCY "radio_new_frequency"		//! called from base of /obj/item/radio/proc/set_frequency(): (list/args)

// /obj/item/pen signals
#define COMSIG_PEN_ROTATED "pen_rotated"						//! called after rotation in /obj/item/pen/attack_self(): (rotation, mob/living/carbon/user)

// /mob/living/carbon/human signals
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACK "human_melee_unarmed_attack"			//! from mob/living/carbon/human/UnarmedAttack(): (atom/target)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACKBY "human_melee_unarmed_attackby"		//! from mob/living/carbon/human/UnarmedAttack(): (mob/living/carbon/human/attacker)
#define COMSIG_HUMAN_DISARM_HIT	"human_disarm_hit"	//! Hit by successful disarm attack (mob/living/carbon/human/attacker,zone_targeted)

// /datum/species signals
#define COMSIG_SPECIES_GAIN "species_gain"						//! from datum/species/on_species_gain(): (datum/species/new_species, datum/species/old_species)
#define COMSIG_SPECIES_LOSS "species_loss"						//! from datum/species/on_species_loss(): (datum/species/lost_species)

// /datum/song signals
#define COMSIG_SONG_START 	"song_start"						//sent to the instrument when a song starts playing
#define COMSIG_SONG_END		"song_end"	

/*******Component Specific Signals*******/
//Janitor
#define COMSIG_TURF_IS_WET "check_turf_wet"							//! (): Returns bitflags of wet values.
#define COMSIG_TURF_MAKE_DRY "make_turf_try"						//! (max_strength, immediate, duration_decrease = INFINITY): Returns bool.
#define COMSIG_COMPONENT_CLEAN_ACT "clean_act"					//! called on an object to clean it of cleanables. Usualy with soap: (num/strength)

//Food
#define COMSIG_FOOD_EATEN "food_eaten"		//! from base of obj/item/reagent_containers/food/snacks/attack(): (mob/living/eater, mob/feeder)

//Gibs
#define COMSIG_GIBS_STREAK "gibs_streak"						//! from base of /obj/effect/decal/cleanable/blood/gibs/streak(): (list/directions, list/diseases)

//Diseases
#define COMSIG_DISEASE_END "disease_end" 						//from the base of /datum/disease/advance/Destroy(): (GetDiseaseID)

//Mood
#define COMSIG_ADD_MOOD_EVENT "add_mood" //! Called when you send a mood event from anywhere in the code.
#define COMSIG_CLEAR_MOOD_EVENT "clear_mood" //! Called when you clear a mood event from anywhere in the code.

//NTnet
#define COMSIG_COMPONENT_NTNET_RECEIVE "ntnet_receive"			//! called on an object by its NTNET connection component on receive. (sending_id(number), sending_netname(text), data(datum/netdata))

//Nanites
#define COMSIG_HAS_NANITES "has_nanites"						//() returns TRUE if nanites are found
#define COMSIG_NANITE_IS_STEALTHY "nanite_is_stealthy"			//() returns TRUE if nanites have stealth
#define COMSIG_NANITE_DELETE "nanite_delete"					//() deletes the nanite component
#define COMSIG_NANITE_GET_PROGRAMS	"nanite_get_programs"		//(list/nanite_programs) - makes the input list a copy the nanites' program list
#define COMSIG_NANITE_GET_VOLUME "nanite_get_volume"			//(amount) Returns nanite amount
#define COMSIG_NANITE_SET_VOLUME "nanite_set_volume"			//(amount) Sets current nanite volume to the given amount
#define COMSIG_NANITE_ADJUST_VOLUME "nanite_adjust"				//(amount) Adjusts nanite volume by the given amount
#define COMSIG_NANITE_SET_MAX_VOLUME "nanite_set_max_volume"	//(amount) Sets maximum nanite volume to the given amount
#define COMSIG_NANITE_SET_CLOUD "nanite_set_cloud"				//(amount(0-100)) Sets cloud ID to the given amount
#define COMSIG_NANITE_SET_CLOUD_SYNC "nanite_set_cloud_sync"	//(method) Modify cloud sync status. Method can be toggle, enable or disable
#define COMSIG_NANITE_SET_SAFETY "nanite_set_safety"			//(amount) Sets safety threshold to the given amount
#define COMSIG_NANITE_SET_REGEN "nanite_set_regen"				//(amount) Sets regeneration rate to the given amount
#define COMSIG_NANITE_SIGNAL "nanite_signal"					//(code(1-9999)) Called when sending a nanite signal to a mob.
#define COMSIG_NANITE_COMM_SIGNAL "nanite_comm_signal"			//(comm_code(1-9999), comm_message) Called when sending a nanite comm signal to a mob.
#define COMSIG_NANITE_SCAN "nanite_scan"						//(mob/user, full_scan) - sends to chat a scan of the nanites to the user, returns TRUE if nanites are detected
#define COMSIG_NANITE_UI_DATA "nanite_ui_data"					//(list/data, scan_level) - adds nanite data to the given data list - made for ui_data procs
#define COMSIG_NANITE_ADD_PROGRAM "nanite_add_program"			//(datum/nanite_program/new_program, datum/nanite_program/source_program) Called when adding a program to a nanite component
	#define COMPONENT_PROGRAM_INSTALLED		1					//Installation successful
	#define COMPONENT_PROGRAM_NOT_INSTALLED		2				//Installation failed, but there are still nanites
#define COMSIG_NANITE_SYNC "nanite_sync"						//(datum/component/nanites, full_overwrite, copy_activation) Called to sync the target's nanites to a given nanite component

// /datum/component/storage signals
#define COMSIG_CONTAINS_STORAGE "is_storage"						//! () - returns bool.
#define COMSIG_TRY_STORAGE_INSERT "storage_try_insert"				//! (obj/item/inserting, mob/user, silent, force) - returns bool
#define COMSIG_TRY_STORAGE_SHOW "storage_show_to"					//! (mob/show_to, force) - returns bool.
#define COMSIG_TRY_STORAGE_HIDE_FROM "storage_hide_from"			//! (mob/hide_from) - returns bool
#define COMSIG_TRY_STORAGE_HIDE_ALL "storage_hide_all"				//! returns bool
#define COMSIG_TRY_STORAGE_SET_LOCKSTATE "storage_lock_set_state"	//! (newstate)
#define COMSIG_IS_STORAGE_LOCKED "storage_get_lockstate"			//! () - returns bool. MUST CHECK IF STORAGE IS THERE FIRST!
#define COMSIG_TRY_STORAGE_TAKE_TYPE "storage_take_type"			//! (typecache, atom/destination, amount = INFINITY, check_adjacent, force, mob/user, list/inserted) - returns bool - typecache has to be list of types.
#define COMSIG_TRY_STORAGE_FILL_TYPE "storage_fill_type"			//! (type, amount = INFINITY, force = FALSE)			//don't fuck this up. Force will ignore max_items, and amount is normally clamped to max_items.
#define COMSIG_TRY_STORAGE_TAKE "storage_take_obj"					//! (obj, new_loc, force = FALSE) - returns bool
#define COMSIG_TRY_STORAGE_QUICK_EMPTY "storage_quick_empty"		//! (loc) - returns bool - if loc is null it will dump at parent location.
#define COMSIG_TRY_STORAGE_RETURN_INVENTORY "storage_return_inventory"	//! (list/list_to_inject_results_into, recursively_search_inside_storages = TRUE)
#define COMSIG_TRY_STORAGE_CAN_INSERT "storage_can_equip"			//! (obj/item/insertion_candidate, mob/user, silent) - returns bool

// /datum/component/two_handed signals
#define COMSIG_TWOHANDED_WIELD "twohanded_wield"              //from base of datum/component/two_handed/proc/wield(mob/living/carbon/user): (/mob/user)
      #define COMPONENT_TWOHANDED_BLOCK_WIELD 1
#define COMSIG_TWOHANDED_UNWIELD "twohanded_unwield"          //from base of datum/component/two_handed/proc/unwield(mob/living/carbon/user): (/mob/user)

// /datum/action signals
#define COMSIG_ACTION_TRIGGER "action_trigger"						//! from base of datum/action/proc/Trigger(): (datum/action)
	#define COMPONENT_ACTION_BLOCK_TRIGGER 1

// /datum/mind signals
#define COMSIG_MIND_TRANSFER_TO	"mind_transfer_to"					// (mob/old, mob/new)

// /datum/component/clockwork_trap signals
#define COMSIG_CLOCKWORK_SIGNAL_RECEIVED "clock_received"			//! When anything the trap is attatched to is triggered

//Xenobio hotkeys
#define COMSIG_XENO_SLIME_CLICK_CTRL "xeno_slime_click_ctrl"				//! from slime CtrlClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_ALT "xeno_slime_click_alt"					//! from slime AltClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_SHIFT "xeno_slime_click_shift"				//! from slime ShiftClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_SHIFT "xeno_turf_click_shift"				//! from turf ShiftClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_CTRL "xeno_turf_click_alt"					//! from turf AltClickOn(): (/mob)
#define COMSIG_XENO_MONKEY_CLICK_CTRL "xeno_monkey_click_ctrl"				//! from monkey CtrlClickOn(): (/mob)

/// job subsystem has spawned and equipped a new mob
#define COMSIG_GLOB_JOB_AFTER_SPAWN "!job_after_spawn"
///Subsystem signals
///From base of datum/controller/subsystem/Initialize: (start_timeofday)
#define COMSIG_SUBSYSTEM_POST_INITIALIZE "subsystem_post_initialize"

//Heretics stuff
#define COMSIG_HUMAN_VOID_MASK_ACT "void_mask_act"

// Component signals
/// From /datum/port/output/set_output: (output_value)
#define COMSIG_PORT_SET_OUTPUT "port_set_output"
/// From /datum/port/input/set_input: (input_value)
#define COMSIG_PORT_SET_INPUT "port_set_input"
/// Sent when a port calls disconnect(). From /datum/port/disconnect: ()
#define COMSIG_PORT_DISCONNECT "port_disconnect"
/// Sent on the output port when an input port registers on it: (datum/port/input/registered_port)
#define COMSIG_PORT_OUTPUT_CONNECT "port_output_connect"

/// Sent when a [/obj/item/circuit_component] is added to a circuit.
#define COMSIG_CIRCUIT_ADD_COMPONENT "circuit_add_component"
	/// Cancels adding the component to the circuit.
	#define COMPONENT_CANCEL_ADD_COMPONENT (1<<0)

/// Sent when a [/obj/item/circuit_component] is added to a circuit manually, by putting the item inside directly.
/// Accepts COMPONENT_CANCEL_ADD_COMPONENT.
#define COMSIG_CIRCUIT_ADD_COMPONENT_MANUALLY "circuit_add_component_manually"

/// Sent when a circuit is removed from its shell
#define COMSIG_CIRCUIT_SHELL_REMOVED "circuit_shell_removed"

/// Sent to [/obj/item/circuit_component] when it is removed from a circuit. (/obj/item/integrated_circuit)
#define COMSIG_CIRCUIT_COMPONENT_REMOVED "circuit_component_removed"

/// Sent to an atom when a [/obj/item/usb_cable] attempts to connect to something. (/obj/item/usb_cable/usb_cable, /mob/user)
#define COMSIG_ATOM_USB_CABLE_TRY_ATTACH "usb_cable_try_attach"
	/// Attaches the USB cable to the atom. If the USB cables moves away, it will disconnect.
	#define COMSIG_USB_CABLE_ATTACHED (1<<0)

	/// Attaches the USB cable to a circuit. Producers of this are expected to set the usb_cable's
	/// `attached_circuit` variable.
	#define COMSIG_USB_CABLE_CONNECTED_TO_CIRCUIT (1<<1)

	/// Cancels the attack chain, but without performing any other action.
	#define COMSIG_CANCEL_USB_CABLE_ATTACK (1<<2)

/// Sent from /obj/structure/industrial_lift/tram when its travelling status updates. (travelling)
#define COMSIG_TRAM_SET_TRAVELLING "tram_set_travelling"

/// Sent from /obj/structure/industrial_lift/tram when it begins to travel. (obj/effect/landmark/tram/from_where, obj/effect/landmark/tram/to_where)
#define COMSIG_TRAM_TRAVEL "tram_travel"

///for any tool behaviors: (mob/living/user, obj/item/I, list/recipes)
#define COMSIG_ATOM_TOOL_ACT(tooltype) "tool_act_[tooltype]"
	#define COMPONENT_BLOCK_TOOL_ATTACK (1<<0)
//not widely used yet, but has lot of potential

/// Called in /obj/structure/moneybot/add_money(). (to_add)
#define COMSIG_MONEYBOT_ADD_MONEY "moneybot_add_money"

// /obj/machinery/door/airlock signals

//from /obj/machinery/door/airlock/open(): (forced)
#define COMSIG_AIRLOCK_OPEN "airlock_open"
//from /obj/machinery/door/airlock/close(): (forced)
#define COMSIG_AIRLOCK_CLOSE "airlock_close"
///from /obj/machinery/door/airlock/set_bolt():
#define COMSIG_AIRLOCK_SET_BOLT "airlock_set_bolt"
///Sent from /obj/machinery/door/airlock when its touched. (mob/user)
#define COMSIG_AIRLOCK_TOUCHED "airlock_touched"
	#define COMPONENT_PREVENT_OPEN 1

// /obj/machinery/atmospherics/components/binary/valve signals

/// from /obj/machinery/atmospherics/components/binary/valve/toggle(): (on)
#define COMSIG_VALVE_SET_OPEN "valve_toggled"


// /obj/machinery signals

/// Sent from /obj/machinery/open_machine(): (drop)
#define COMSIG_MACHINE_OPEN "machine_open"
/// Sent from /obj/machinery/close_machine(): (atom/movable/target)
#define COMSIG_MACHINE_CLOSE "machine_close"

// Aquarium related signals
#define COMSIG_AQUARIUM_BEFORE_INSERT_CHECK "aquarium_about_to_be_inserted"
#define COMSIG_AQUARIUM_SURFACE_CHANGED "aquarium_surface_changed"
#define COMSIG_AQUARIUM_FLUID_CHANGED "aquarium_fluid_changed"
//Lightning
///Called right before the atom changes the value of light_range to a different one, from base atom/set_light_range(): (new_range)
#define COMSIG_ATOM_SET_LIGHT_RANGE "atom_set_light_range"
///Called right before the atom changes the value of light_power to a different one, from base atom/set_light_power(): (new_power)
#define COMSIG_ATOM_SET_LIGHT_POWER "atom_set_light_power"
///Called right before the atom changes the value of light_color to a different one, from base atom/set_light_color(): (new_color)
#define COMSIG_ATOM_SET_LIGHT_COLOR "atom_set_light_color"
///Called right before the atom changes the value of light_on to a different one, from base atom/set_light_on(): (new_value)
#define COMSIG_ATOM_SET_LIGHT_ON "atom_set_light_on"
///Called right before the atom changes the value of light_flags to a different one, from base atom/set_light_flags(): (new_value)
#define COMSIG_ATOM_SET_LIGHT_FLAGS "atom_set_light_flags"
///Called when the movable tries to change its dynamic light color setting, from base atom/movable/lighting_overlay_set_color(): (color)
#define COMSIG_MOVABLE_LIGHT_OVERLAY_SET_RANGE "movable_light_overlay_set_color"
///Called when the movable tries to change its dynamic light power setting, from base atom/movable/lighting_overlay_set_power(): (power)
#define COMSIG_MOVABLE_LIGHT_OVERLAY_SET_POWER "movable_light_overlay_set_power"
///Called when the movable tries to change its dynamic light range setting, from base atom/movable/lighting_overlay_set_range(): (range)
#define COMSIG_MOVABLE_LIGHT_OVERLAY_SET_COLOR "movable_light_overlay_set_range"
///Called when the movable tries to toggle its dynamic light LIGHTING_ON status, from base atom/movable/lighting_overlay_toggle_on(): (new_state)
#define COMSIG_MOVABLE_LIGHT_OVERLAY_TOGGLE_ON "movable_light_overlay_toggle_on"
