// Object signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument


// /obj signals
/// from base of obj/deconstruct(): (disassembled)
#define COMSIG_OBJ_DECONSTRUCT "obj_deconstruct"
/// from base of code/game/machinery
#define COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH "obj_default_unfasten_wrench"
/// called in /obj/structure/set_anchored(): (value)
#define COMSIG_OBJ_SETANCHORED "obj_setanchored"


// /obj/machinery signals
/// Sent from /obj/machinery/open_machine(): (drop)
#define COMSIG_MACHINE_OPEN "machine_open"
/// Sent from /obj/machinery/close_machine(): (atom/movable/target)
#define COMSIG_MACHINE_CLOSE "machine_close"

///from /obj/machinery/atom_break(damage_flag): (damage_flag)
#define COMSIG_MACHINERY_BROKEN "machinery_broken"
///from base power_change() when power is lost
#define COMSIG_MACHINERY_POWER_LOST "machinery_power_lost"
///from base power_change() when power is restored
#define COMSIG_MACHINERY_POWER_RESTORED "machinery_power_restored"
///from /obj/machinery/set_occupant(atom/movable/O): (new_occupant)
#define COMSIG_MACHINERY_SET_OCCUPANT "machinery_set_occupant"
///from /obj/machinery/destructive_scanner/proc/open(aggressive): Runs when the destructive scanner scans a group of objects. (list/scanned_atoms)

// /obj/machinery/atmospherics/components/unary/cryo_cell signals
/// from /obj/machinery/atmospherics/components/unary/cryo_cell/set_on(bool): (on)
#define COMSIG_CRYO_SET_ON "cryo_set_on"

#define COMSIG_MACHINERY_DESTRUCTIVE_SCAN "machinery_destructive_scan"
///from /obj/machinery/computer/arcade/prizevend(mob/user, prizes = 1)
#define COMSIG_ARCADE_PRIZEVEND "arcade_prizevend"
///from /datum/controller/subsystem/air/proc/start_processing_machine: ()
#define COMSIG_MACHINERY_START_PROCESSING_AIR "start_processing_air"
///from /datum/controller/subsystem/air/proc/stop_processing_machine: ()
#define COMSIG_MACHINERY_STOP_PROCESSING_AIR "stop_processing_air"

///from /obj/machinery/can_interact(mob/user): Called on user when attempting to interact with a machine (obj/machinery/machine)
#define COMSIG_TRY_USE_MACHINE "try_use_machine"
	/// Can't interact with the machine
	#define COMPONENT_CANT_USE_MACHINE_INTERACT (1<<0)
	/// Can't use tools on the machine
	#define COMPONENT_CANT_USE_MACHINE_TOOLS (1<<1)


// /obj/machinery/atmospherics/components/binary/valve signals
/// from /obj/machinery/atmospherics/components/binary/valve/toggle(): (on)
#define COMSIG_VALVE_SET_OPEN "valve_toggled"

/// from /obj/machinery/atmospherics/set_on(active): (on)
#define COMSIG_ATMOS_MACHINE_SET_ON "atmos_machine_set_on"

/// from /obj/machinery/light_switch/set_lights(), sent to every switch in the area: (status)
#define COMSIG_LIGHT_SWITCH_SET "light_switch_set"

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


// /obj/item signals
/// from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_EQUIPPED "item_equip"
/// from base of obj/item/dropped(): (mob/user)
#define COMSIG_ITEM_DROPPED "item_drop"
///Called when an item is dried by a drying rack:
#define COMSIG_ITEM_DRIED "item_dried"
///from base of obj/item/on_grind(): ())
#define COMSIG_ITEM_ON_GRIND "on_grind"
///from base of obj/item/on_juice(): ()
#define COMSIG_ITEM_ON_JUICE "on_juice"
///from /obj/machinery/hydroponics/attackby(obj/item/O, mob/user, params) when an object is used as compost: (mob/user)
#define COMSIG_ITEM_ON_COMPOSTED "on_composted"
/// from base of obj/item/pickup(): (/mob/taker)
#define COMSIG_ITEM_PICKUP "item_pickup"
/// return a truthy value to prevent ensouling, checked in /obj/effect/proc_holder/spell/targeted/lichdom/cast(): (mob/user)
#define COMSIG_ITEM_IMBUE_SOUL "item_imbue_soul"
	#define COMPONENT_BLOCK_IMBUE (1 << 0)
/// called before marking an object for retrieval, checked in /obj/effect/proc_holder/spell/targeted/summonitem/cast() : (mob/user)
#define COMSIG_ITEM_MARK_RETRIEVAL "item_mark_retrieval"
	#define COMPONENT_BLOCK_MARK_RETRIEVAL (1<<0)

///from base of mob/living/carbon/attacked_by(): (mob/living/carbon/target, mob/living/user, hit_zone)
#define COMSIG_ITEM_ATTACK_ZONE "item_attack_zone"
/// from base of obj/item/hit_reaction(): (list/args)
#define COMSIG_ITEM_HIT_REACT "item_hit_react"
	#define COMPONENT_HIT_REACTION_BLOCK (1<<0)
/// from base of item/sharpener/attackby(): (amount, max)
#define COMSIG_ITEM_SHARPEN_ACT "sharpen_act"
	#define COMPONENT_BLOCK_SHARPEN_APPLIED (1<<0)
	#define COMPONENT_BLOCK_SHARPEN_BLOCKED (1<<1)
	#define COMPONENT_BLOCK_SHARPEN_ALREADY (1<<2)
	#define COMPONENT_BLOCK_SHARPEN_MAXED (1<<3)

// /obj signals for economy
///called when the payment component tries to charge an account.
#define COMSIG_OBJ_ATTEMPT_CHARGE "obj_attempt_simple_charge"
	#define COMPONENT_OBJ_CANCEL_CHARGE  (1<<0)
///Called when a payment component changes value
#define COMSIG_OBJ_ATTEMPT_CHARGE_CHANGE "obj_attempt_simple_charge_change"

// /obj/item signals for economy
///called before an item is sold by the exports system.
#define COMSIG_ITEM_PRE_EXPORT "item_pre_sold"
	/// Stops the export from calling sell_object() on the item, so you can handle it manually.
	#define COMPONENT_STOP_EXPORT (1<<0)
///called when an item is sold by the exports subsystem
#define COMSIG_ITEM_EXPORTED "item_sold"
	/// Stops the export from adding the export information to the report, so you can handle it manually.
	#define COMPONENT_STOP_EXPORT_REPORT (1<<0)
///called when a wrapped up structure is opened by hand
#define COMSIG_STRUCTURE_UNWRAPPED "structure_unwrapped"
///called when a wrapped up item is opened by hand
#define COMSIG_ITEM_UNWRAPPED "item_unwrapped"
///called when getting the item's exact ratio for cargo's profit.
#define COMSIG_ITEM_SPLIT_PROFIT "item_split_profits"
///called when getting the item's exact ratio for cargo's profit, without selling the item.
#define COMSIG_ITEM_SPLIT_PROFIT_DRY "item_split_profits_dry"


// /obj/item/clothing signals
///from [/mob/living/carbon/human/Move]: ()
#define COMSIG_SHOES_STEP_ACTION "shoes_step_action"


// /obj/item/implant signals
/// from base of /obj/item/implant/proc/activate(): ()
#define COMSIG_IMPLANT_ACTIVATED "implant_activated"
/// from base of /obj/item/implant/proc/implant(): (list/args)
#define COMSIG_IMPLANT_IMPLANTING "implant_implanting"
	#define COMPONENT_STOP_IMPLANTING (1<<0)
/// called on already installed implants when a new one is being added in /obj/item/implant/proc/implant(): (list/args, obj/item/implant/new_implant)
#define COMSIG_IMPLANT_OTHER "implant_other"
	//#define COMPONENT_STOP_IMPLANTING (1<<0) //The name makes sense for both
	#define COMPONENT_DELETE_NEW_IMPLANT (1<<1)
	#define COMPONENT_DELETE_OLD_IMPLANT (1<<2)
/// called on implants, after a successful implantation: (mob/living/target, mob/user, silent, force)
#define COMSIG_IMPLANT_IMPLANTED "implant_implanted"
/// called on implants, after an implant has been removed: (mob/living/source, silent, special)
#define COMSIG_IMPLANT_REMOVED "implant_removed"
/// called once a mindshield is implanted: (mob/user)
#define COMSIG_MINDSHIELD_IMPLANTED "mindshield_implanted"
	/// Are we the reason for deconversion?
	#define COMPONENT_MINDSHIELD_DECONVERTED (1<<0)
///called on implants being implanted into someone with an uplink implant: (datum/component/uplink)
#define COMSIG_IMPLANT_EXISTING_UPLINK "implant_uplink_exists"
	//This uses all return values of COMSIG_IMPLANT_OTHER

// /obj/item/grenade signals
/// called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GRENADE_PRIME "grenade_prime"
/// called in /obj/item/gun/process_fire (user, target, params, zone_override)
#define COMSIG_GRENADE_ARMED "grenade_armed"


// /obj/projectile signals (sent to the firer)
///from base of /obj/projectile/proc/on_hit(), like COMSIG_PROJECTILE_ON_HIT but on the projectile itself and with the hit limb (if any): (atom/movable/firer, atom/target, Angle, hit_limb)
#define COMSIG_PROJECTILE_SELF_ON_HIT "projectile_self_on_hit"
///from base of /obj/projectile/proc/on_hit(): (atom/movable/firer, atom/target, Angle)
#define COMSIG_PROJECTILE_ON_HIT "projectile_on_hit"
///from base of /obj/projectile/proc/fire(): (obj/projectile, atom/original_target)
#define COMSIG_PROJECTILE_BEFORE_FIRE "projectile_before_fire"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_PREHIT "com_proj_prehit"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_RANGE_OUT "projectile_range_out"
///from [/obj/item/proc/tryEmbed] sent when trying to force an embed (mainly for projectiles and eating glass)
#define COMSIG_EMBED_TRY_FORCE "item_try_embed"
	#define COMPONENT_EMBED_SUCCESS (1<<1)
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PELLET_CLOUD_INIT "pellet_cloud_init"


// /obj/mecha signals
/// sent from mecha action buttons to the mecha they're linked to
#define COMSIG_MECHA_ACTION_ACTIVATE "mecha_action_activate"


///from /obj/item/assembly/proc/pulsed()
#define COMSIG_ASSEMBLY_PULSED "assembly_pulsed"


///from base of /obj/item/mmi/set_brainmob(): (mob/living/brain/new_brainmob)
#define COMSIG_MMI_SET_BRAINMOB "mmi_set_brainmob"
