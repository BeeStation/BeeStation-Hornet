// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /mob/living signals
///from base of mob/living/resist() (/mob/living)
#define COMSIG_LIVING_RESIST "living_resist"
///from base of mob/living/IgniteMob() (/mob/living)
#define COMSIG_LIVING_IGNITED "living_ignite"
///from base of mob/living/extinguish_mob() (/mob/living)
#define COMSIG_LIVING_EXTINGUISHED "living_extinguished"
//from base of mob/living/electrocute_act(): (shock_damage, source, siemens_coeff, flags)
#define COMSIG_LIVING_ELECTROCUTE_ACT "living_electrocute_act"
///from base of mob/living/revive() (full_heal, admin_revive)
#define COMSIG_LIVING_REVIVE "living_revive"
///from base of /mob/living/regenerate_limbs(): (noheal, excluded_limbs)
#define COMSIG_LIVING_REGENERATE_LIMBS "living_regen_limbs"
///from base of mob/living/set_buckled(): (new_buckled)
#define COMSIG_LIVING_SET_BUCKLED "living_set_buckled"
///from base of mob/living/set_body_position()
#define COMSIG_LIVING_SET_BODY_POSITION  "living_set_body_position"
#define COMSIG_LIVING_MINOR_SHOCK "living_minor_shock"			//! sent by stuff like stunbatons and tasers: ()
#define COMSIG_PROCESS_BORGCHARGER_OCCUPANT "living_charge"		//! sent from borg recharge stations: (amount, repairs)
#define COMSIG_LIVING_TRY_SYRINGE "living_try_syringe"			///From post-can inject check of syringe after attack (mob/user)
#define COMSIG_LIVING_START_PULL "living_start_pull"			///called on /living when someone starts pulling (atom/movable/pulled, state, force)
/// from base of mob/living/Life() (seconds, times_fired)
#define COMSIG_LIVING_LIFE "living_life"
///from base of mob/living/death(): (gibbed, was_dead_before)
#define COMSIG_LIVING_DEATH "living_death"
/// from base of mob/living/updatehealth(): ()
#define COMSIG_LIVING_UPDATE_HEALTH "living_update_health"
/// Called when a living mob has its resting updated: (resting_state)
#define COMSIG_LIVING_RESTING_UPDATED "resting_updated"
///from base of mob/living/gib(): (no_brain, no_organs, no_bodyparts)
///Note that it is fired regardless of whether the mob was dead beforehand or not.
#define COMSIG_LIVING_GIBBED "living_gibbed"

/// from /datum/component/singularity/proc/can_move(), as well as /obj/anomaly/energy_ball/proc/can_move()
/// if a callback returns `SINGULARITY_TRY_MOVE_BLOCK`, then the singularity will not move to that turf
#define COMSIG_ATOM_SINGULARITY_TRY_MOVE "atom_singularity_try_move"
	/// When returned from `COMSIG_ATOM_SINGULARITY_TRY_MOVE`, the singularity will move to that turf
	#define SINGULARITY_TRY_MOVE_BLOCK (1 << 0)
///from base of /mob/living/can_track()
#define COMSIG_LIVING_CAN_TRACK "mob_can_track"
	#define COMPONENT_CANT_TRACK 1
/// from start of /mob/living/handle_breathing(): (delta_time, times_fired)
#define COMSIG_LIVING_HANDLE_BREATHING "living_handle_breathing"
///(NOT on humans) from mob/living/*/UnarmedAttack(): (atom/target, proximity, modifiers)
#define COMSIG_LIVING_UNARMED_ATTACK "living_unarmed_attack"

//ALL OF THESE DO NOT TAKE INTO ACCOUNT WHETHER AMOUNT IS 0 OR LOWER AND ARE SENT REGARDLESS!

///from base of mob/living/Stun() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_STUN "living_stun"
///from base of mob/living/Knockdown() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_KNOCKDOWN "living_knockdown"
///from base of mob/living/Paralyze() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_PARALYZE "living_paralyze"
///from base of mob/living/Immobilize() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_IMMOBILIZE "living_immobilize"
///from base of mob/living/Unconscious() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_UNCONSCIOUS "living_unconscious"
///from base of mob/living/Sleeping() (amount, ignore_canstun)
#define COMSIG_LIVING_STATUS_SLEEP "living_sleeping"
	#define COMPONENT_NO_STUN (1<<0)		//For all of them
#define COMSIG_LIVING_STATUS_STAGGERED "living_staggered"		///from base of mob/living/Stagger() (amount, ignore_canstun)

#define COMSIG_LIVING_ENTER_STASIS	"living_enter_stasis"		//! sent when a mob is put into stasis.
#define COMSIG_LIVING_EXIT_STASIS	"living_exit_stasis"		//! sent when a mob exits stasis.

// basic mob signals
/// Called on /basic when updating its speed, from base of /mob/living/basic/update_basic_mob_varspeed(): ()
#define POST_BASIC_MOB_UPDATE_VARSPEED "post_basic_mob_update_varspeed"

/// from /datum/status_effect/incapacitating/stamcrit/on_apply()
#define COMSIG_LIVING_ENTER_STAMCRIT "living_enter_stamcrit"
///from /obj/structure/door/crush(): (mob/living/crushed, /obj/machinery/door/crushing_door)
#define COMSIG_LIVING_DOORCRUSHED "living_doorcrush"
///sent when items with siemen coeff. of 0 block a shock: (power_source, source, siemens_coeff, dist_check)
#define COMSIG_LIVING_SHOCK_PREVENTED "living_shock_prevented"
	/// Block the electrocute_act() proc from proceeding
	#define COMPONENT_LIVING_BLOCK_SHOCK (1<<0)
///sent by stuff like stunbatons and tasers: ()
/// Sent to a mob being injected with a syringe when the do_after initiates
#define COMSIG_LIVING_TRY_SYRINGE_INJECT "living_try_syringe_inject"
/// Sent to a mob being withdrawn from with a syringe when the do_after initiates
#define COMSIG_LIVING_TRY_SYRINGE_WITHDRAW "living_try_syringe_withdraw"
///from base of mob/living/set_usable_legs()
#define COMSIG_LIVING_LIMBLESS_SLOWDOWN  "living_limbless_slowdown"
/// Block the Life() proc from proceeding... this should really only be done in some really wacky situations.
#define COMPONENT_LIVING_CANCEL_LIFE_PROCESSING (1<<0)
///From living/set_resting(): (new_resting, silent, instant)
#define COMSIG_LIVING_RESTING "living_resting"

/// From /mob/living/proc/stop_leaning()
#define COMSIG_LIVING_STOPPED_LEANING "living_stopped_leaning"

///From mob/living/proc/wabbajack(): (randomize_type)
#define COMSIG_LIVING_PRE_WABBAJACKED "living_mob_wabbajacked"
	/// Return to stop the rest of the wabbajack from triggering.
	#define STOP_WABBAJACK (1<<0)
///From mob/living/proc/on_wabbajack(): (mob/living/new_mob)
#define COMSIG_LIVING_ON_WABBAJACKED "living_wabbajacked"

/// From /datum/status_effect/shapechange_mob/on_apply(): (mob/living/shape)
#define COMSIG_LIVING_SHAPESHIFTED "living_shapeshifted"
/// From /datum/status_effect/shapechange_mob/after_unchange(): (mob/living/caster)
#define COMSIG_LIVING_UNSHAPESHIFTED "living_unshapeshifted"

/// from /mob/proc/change_mob_type() : ()
#define COMSIG_PRE_MOB_CHANGED_TYPE "mob_changed_type"
	#define COMPONENT_BLOCK_MOB_CHANGE (1<<0)
