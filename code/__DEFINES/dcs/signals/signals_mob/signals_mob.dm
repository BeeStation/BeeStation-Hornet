// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /mob signals
#define COMSIG_MOB_LOGIN "mob_login"
#define COMSIG_MOB_LOGOUT "mob_logout"							///from base of /mob/Logout(): ()
#define COMSIG_MOB_DEATH "mob_death"							//! from base of mob/death(): (gibbed)
#define COMSIG_MOB_STATCHANGE "mob_statchange"					//from base of mob/set_stat(): (new_stat)
#define COMSIG_MOB_CLICKON "mob_clickon"						//! from base of mob/clickon(): (atom/A, params)
#define COMSIG_MOB_MIDDLECLICKON "mob_middleclickon"			//from base of mob/MiddleClickOn(): (atom/A)
///from base of mob/AltClickOn(): (atom/A)
#define COMSIG_MOB_ALTCLICKON "mob_altclickon"
	#define COMSIG_MOB_CANCEL_CLICKON (1<<0)
///from base of mob/alt_click_on_secodary(): (atom/A)
#define COMSIG_MOB_ALTCLICKON_SECONDARY "mob_altclickon_secondary"

/// from /mob/proc/key_down(): (key, client/client, full_key)
#define COMSIG_MOB_KEYDOWN "mob_key_down"

/// From base of /mob/living/simple_animal/bot/proc/bot_step()
#define COMSIG_MOB_BOT_PRE_STEP "mob_bot_pre_step"
	/// Should always match COMPONENT_MOVABLE_BLOCK_PRE_MOVE as these are interchangeable and used to block movement.
	#define COMPONENT_MOB_BOT_BLOCK_PRE_STEP COMPONENT_MOVABLE_BLOCK_PRE_MOVE
/// From base of /mob/living/simple_animal/bot/proc/bot_step()
#define COMSIG_MOB_BOT_STEP "mob_bot_step"

/// From base of /client/Move()
#define COMSIG_MOB_CLIENT_PRE_MOVE "mob_client_pre_move"
	/// Should always match COMPONENT_MOVABLE_BLOCK_PRE_MOVE as these are interchangeable and used to block movement.
	#define COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE COMPONENT_MOVABLE_BLOCK_PRE_MOVE
/// From base of /client/Move()
#define COMSIG_MOB_CLIENT_MOVED "mob_client_moved"
/// From base of /mob/proc/reset_perspective() : ()
#define COMSIG_MOB_RESET_PERSPECTIVE "mob_reset_perspective"
///from base of obj/allowed(mob/M): (/obj) returns ACCESS_ALLOWED if mob has id access to the obj
#define COMSIG_MOB_TRIED_ACCESS "tried_access"
	#define ACCESS_ALLOWED (1<<0)
	#define ACCESS_DISALLOWED (1<<1)
	#define LOCKED_ATOM_INCOMPATIBLE (1<<2)
/// from base of /datum/view_data/proc/afterViewChange() : (view)
#define COMSIG_VIEWDATA_UPDATE "viewdata_update"

///from base of mob/can_cast_magic(): (mob/user, magic_flags, charge_cost)
#define COMSIG_MOB_RESTRICT_MAGIC "mob_cast_magic"
///from base of mob/can_block_magic(): (mob/user, casted_magic_flags, charge_cost)
#define COMSIG_MOB_RECEIVE_MAGIC "mob_receive_magic"
	#define COMPONENT_MAGIC_BLOCKED (1<<0)
#define COMSIG_MOB_RECEIVE_ARTIFACT "mob_receive_artifact"			//
	#define COMPONENT_BLOCK_ARTIFACT 1

#define COMSIG_MOB_ATTACK_ALIEN "mob_attack_alien"				//! from base of /mob/living/attack_alien(): (user)
#define COMSIG_MOB_MOVESPEED_UPDATED "mob_update_movespeed"		//! From base of mob/update_movespeed():area


#define COMSIG_MOB_HUD_CREATED "mob_hud_created"				//! from base of mob/create_mob_hud(): ()
#define COMSIG_MOB_ATTACK_HAND_TURF "mob_attack_hand_turf"		//! from base of turf/attack_hand
#define COMSIG_MOB_HAND_ATTACKED "mob_hand_attacked"			//! from base of
#define COMSIG_MOB_DROPPED_ITEM "mob_dropped_item"				//! from base of /item/dropped(): (/mob/user, /obj/item, loc)
#define COMSIG_MOB_APPLY_DAMGE	"mob_apply_damage"				//! from base of /mob/living/proc/apply_damage(): (damage, damagetype, def_zone)
#define COMSIG_MOB_THROW "mob_throw"							//! from base of /mob/throw_item(): (atom/target)
#define COMSIG_MOB_UPDATE_SIGHT "mob_update_sight"				//! from base of /mob/update_sight(): ()
///from base of /mob/verb/examinate(): (atom/target, list/examine_strings)
#define COMSIG_MOB_EXAMINING "mob_examining"
///from base of /mob/verb/examinate(): (atom/target)
#define COMSIG_MOB_EXAMINATE "mob_examinate"

////from /mob/living/say(): ()
#define COMSIG_MOB_SAY "mob_say"
	#define COMPONENT_UPPERCASE_SPEECH (1<<0)
	// used to access COMSIG_MOB_SAY argslist
	#define SPEECH_MESSAGE 1
	// #define SPEECH_BUBBLE_TYPE 2
	#define SPEECH_SPANS 3
	/* #define SPEECH_SANITIZE 4
	#define SPEECH_LANGUAGE 5
	#define SPEECH_IGNORE_SPAM 6
	#define SPEECH_FORCED 7 */
	#define SPEECH_RANGE 8

///from /datum/component/speechmod/handle_speech(): ()
#define COMSIG_TRY_MODIFY_SPEECH "try_modify_speech"
	///Return value if we prevent speech from being modified
	#define PREVENT_MODIFY_SPEECH 1

#define COMSIG_MOB_EMOTE "mob_emote" // from /mob/living/emote(): ()
#define COMSIG_MOB_SWAP_HANDS "mob_swap_hands"        //from base of mob/swap_hand()
	#define COMPONENT_BLOCK_SWAP 1
#define COMSIG_MOB_DEADSAY "mob_deadsay" // from /mob/say_dead(): (mob/speaker, message)
	#define MOB_DEADSAY_SIGNAL_INTERCEPT 1
#define COMSIG_MOB_POINTED "mob_pointed" //from base of /mob/verb/pointed: (atom/A)
///Mob is trying to open the wires of a target [/atom], from /datum/wires/interactable(): (atom/target)
#define COMSIG_TRY_WIRES_INTERACT "try_wires_interact"
	#define COMPONENT_CANT_INTERACT_WIRES (1<<0)
	/// From base of /client/Move()
#define COMSIG_MOB_CLIENT_PRE_LIVING_MOVE "mob_client_pre_living_move"
	/// Should we stop the current living movement attempt
	#define COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE COMPONENT_MOVABLE_BLOCK_PRE_MOVE
///Called after a client connects to a mob and all UI elements have been setup
#define COMSIG_MOB_CLIENT_LOGIN "comsig_mob_client_login"
#define COMSIG_MOB_MOUSE_SCROLL_ON "comsig_mob_mouse_scroll_on"	//! from base of /mob/MouseWheelOn(): (atom/A, delta_x, delta_y, params)
//from base of client/MouseUp(): (/client, object, location, control, params)
#define COMSIG_CLIENT_MOUSEDRAG "client_mousedrag"

/// Called when a mob pulls the trigger of a gun. From /obj/item/gun/proc/pull_trigger(): (atom/target, mob/living/user, params = null, aimed = GUN_NOT_AIMED)
#define COMSIG_MOB_PULL_TRIGGER "pull_trigger"
	/// Cancel the trigger pull
	#define CANCEL_TRIGGER_PULL (1 << 0)

/// Called before a mob fires a gun (mob/source, obj/item/gun, atom/target, aimed)
#define COMSIG_MOB_BEFORE_FIRE_GUN "before_fire_gun"
	#define GUN_HIT_SELF (1 << 0)

/// Sent from /mob/living/basic/proc/look_dead() : ()
#define COMSIG_BASICMOB_LOOK_DEAD "basicmob_look_dead"
/// Sent from /mob/living/basic/proc/look_alive() : ()
#define COMSIG_BASICMOB_LOOK_ALIVE "basicmob_look_alive"

/// Signal sent when a blackboard key is set to a new value
#define COMSIG_AI_BLACKBOARD_KEY_SET(blackboard_key) "ai_blackboard_key_set_[blackboard_key]"

/// Signal sent when a blackboard key is cleared
#define COMSIG_AI_BLACKBOARD_KEY_CLEARED(blackboard_key) "ai_blackboard_key_clear_[blackboard_key]"
