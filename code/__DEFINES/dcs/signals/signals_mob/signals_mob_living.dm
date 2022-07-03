// /mob/living signals
/// from base of mob/living/revive() (/mob/living, full_heal, admin_revive)
#define COMSIG_LIVING_REVIVE "living_revive"
/// from base of mob/living/resist() (/mob/living)
#define COMSIG_LIVING_RESIST "living_resist"
/// from base of mob/living/IgniteMob() (/mob/living)
#define COMSIG_LIVING_IGNITED "living_ignite"
/// from base of mob/living/ExtinguishMob() (/mob/living)
#define COMSIG_LIVING_EXTINGUISHED "living_extinguished"
//from base of mob/living/electrocute_act(): (shock_damage, source, siemens_coeff, flags)
#define COMSIG_LIVING_ELECTROCUTE_ACT "living_electrocute_act"
/// sent by stuff like stunbatons and tasers: ()
#define COMSIG_LIVING_MINOR_SHOCK "living_minor_shock"
/// sent from borg recharge stations: (amount, repairs)
#define COMSIG_PROCESS_BORGCHARGER_OCCUPANT "living_charge"
/// sent from borg mobs to itself, for tools to catch an upcoming destroy() due to safe decon (rather than detonation)
#define COMSIG_BORG_SAFE_DECONSTRUCT "borg_safe_decon"
#define COMSIG_MOB_CLIENT_LOGIN "comsig_mob_client_login"
/// From post-can inject check of syringe after attack (mob/user)
#define COMSIG_LIVING_TRY_SYRINGE "living_try_syringe"
/// from base of /mob/living/can_track()
#define COMSIG_LIVING_CAN_TRACK "mob_can_track"
	#define COMPONENT_CANT_TRACK 1

//ALL OF THESE DO NOT TAKE INTO ACCOUNT WHETHER AMOUNT IS 0 OR LOWER AND ARE SENT REGARDLESS!
/// from base of mob/living/Stun() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_STUN "living_stun"
/// from base of mob/living/Knockdown() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_KNOCKDOWN "living_knockdown"
/// from base of mob/living/Paralyze() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_PARALYZE "living_paralyze"
/// from base of mob/living/Immobilize() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_IMMOBILIZE "living_immobilize"
/// from base of mob/living/Unconscious() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_UNCONSCIOUS "living_unconscious"
/// from base of mob/living/Sleeping() (amount, update, ignore)
#define COMSIG_LIVING_STATUS_SLEEP "living_sleeping"
	//For all of them
	#define COMPONENT_NO_STUN 1
