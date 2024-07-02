// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj signals

///from base of [/obj/proc/take_damage]: (damage_amount, damage_type, damage_flag, sound_effect, attack_dir, aurmor_penetration)
#define COMSIG_OBJ_TAKE_DAMAGE	"obj_take_damage"
	/// Return bitflags for the above signal which prevents the object taking any damage.
	#define COMPONENT_NO_TAKE_DAMAGE	(1<<0)
#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"	//! from base of obj/deconstruct(): (disassembled)
#define COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH "obj_default_unfasten_wrench"
#define COMSIG_OBJ_HIDE	"obj_hide"		//from base of /turf/proc/levelupdate(). (intact) true to hide and false to unhide

/// from /obj/proc/make_unfrozen()
#define COMSIG_OBJ_UNFREEZE "obj_unfreeze"

// /obj signals for economy
///called when the payment component tries to charge an account.
#define COMSIG_OBJ_ATTEMPT_CHARGE "obj_attempt_simple_charge"
	#define COMPONENT_OBJ_CANCEL_CHARGE  (1<<0)
///Called when a payment component changes value
#define COMSIG_OBJ_ATTEMPT_CHARGE_CHANGE "obj_attempt_simple_charge_change"
