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
///from base of mob/living/set_buckled(): (new_buckled)
#define COMSIG_LIVING_SET_BUCKLED "living_set_buckled"
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

/// from /datum/component/singularity/proc/can_move(), as well as /obj/anomaly/energy_ball/proc/can_move()
/// if a callback returns `SINGULARITY_TRY_MOVE_BLOCK`, then the singularity will not move to that turf
#define COMSIG_ATOM_SINGULARITY_TRY_MOVE "atom_singularity_try_move"
	/// When returned from `COMSIG_ATOM_SINGULARITY_TRY_MOVE`, the singularity will move to that turf
	#define SINGULARITY_TRY_MOVE_BLOCK (1 << 0)
#define COMSIG_LIVING_CAN_TRACK "mob_can_track"					///from base of /mob/living/can_track()
	#define COMPONENT_CANT_TRACK 1
/// from start of /mob/living/handle_breathing(): (delta_time, times_fired)
#define COMSIG_LIVING_HANDLE_BREATHING "living_handle_breathing"

//ALL OF THESE DO NOT TAKE INTO ACCOUNT WHETHER AMOUNT IS 0 OR LOWER AND ARE SENT REGARDLESS!
#define COMSIG_LIVING_STATUS_STUN "living_stun"					//! from base of mob/living/Stun() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_KNOCKDOWN "living_knockdown"		//! from base of mob/living/Knockdown() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_PARALYZE "living_paralyze"			//! from base of mob/living/Paralyze() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_IMMOBILIZE "living_immobilize"		//! from base of mob/living/Immobilize() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_UNCONSCIOUS "living_unconscious"	//! from base of mob/living/Unconscious() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_SLEEP "living_sleeping"			//! from base of mob/living/Sleeping() (amount, update, ignore)
	#define COMPONENT_NO_STUN 1			//For all of them

#define COMSIG_LIVING_ENTER_STASIS	"living_enter_stasis"		//! sent when a mob is put into stasis.
#define COMSIG_LIVING_EXIT_STASIS	"living_exit_stasis"		//! sent when a mob exits stasis.

///From wabbajack(): ()
#define COMSIG_LIVING_PRE_WABBAJACKED "living_mob_wabbajacked"
	/// Return to stop the rest of the wabbajack from triggering.
	#define STOP_WABBAJACK (1 << 0)
///From wabbajack(): (mob/living/new_mob)
#define COMSIG_LIVING_ON_WABBAJACKED "living_wabbajacked"

// basic mob signals
/// Called on /basic when updating its speed, from base of /mob/living/basic/update_basic_mob_varspeed(): ()
#define POST_BASIC_MOB_UPDATE_VARSPEED "post_basic_mob_update_varspeed"
