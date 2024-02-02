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
#define COMSIG_MOB_ALTCLICKON "mob_altclickon"				//from base of mob/AltClickOn(): (atom/A)
	#define COMSIG_MOB_CANCEL_CLICKON 1

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

	/// Should we stop the current living movement attempt
	#define COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE COMPONENT_MOVABLE_BLOCK_PRE_MOVE
#define COMSIG_MOB_ALLOWED "mob_allowed"						//! from base of obj/allowed(mob/M): (/obj) returns bool, if TRUE the mob has id access to the obj
#define COMSIG_MOB_RECEIVE_MAGIC "mob_receive_magic"			//! from base of mob/anti_magic_check(): (mob/user, magic, holy, major, self, protection_sources)
	#define COMPONENT_BLOCK_MAGIC 1
#define COMSIG_MOB_RECEIVE_ARTIFACT "mob_receive_artifact"			//
	#define COMPONENT_BLOCK_ARTIFACT 1
#define COMSIG_MOB_HUD_CREATED "mob_hud_created"				//! from base of mob/create_mob_hud(): ()
#define COMSIG_MOB_ATTACK_HAND "mob_attack_hand"				//! from base of
#define COMSIG_MOB_ATTACK_HAND_TURF "mob_attack_hand_turf"		//! from base of turf/attack_hand
#define COMSIG_MOB_HAND_ATTACKED "mob_hand_attacked"			//! from base of
#define COMSIG_MOB_ITEM_ATTACK "mob_item_attack"				//! from base of /obj/item/attack(): (mob/M, mob/user)
	#define COMPONENT_ITEM_NO_ATTACK 1
#define COMSIG_MOB_ITEM_ATTACKBY "mob_item_attackby"			//! from base of /obj/item/attack(): (mob/user, src)
#define COMSIG_MOB_EQUIPPED_ITEM "mob_equipped_item"			//! from base of /item/equipped(): (/mob/user, /obj/item, slot)
#define COMSIG_MOB_DROPPED_ITEM "mob_dropped_item"				//! from base of /item/dropped(): (/mob/user, /obj/item, loc)
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
	/// From base of /client/Move()
#define COMSIG_MOB_CLIENT_PRE_LIVING_MOVE "mob_client_pre_living_move"
///Called after a client connects to a mob and all UI elements have been setup
#define COMSIG_MOB_CLIENT_LOGIN "comsig_mob_client_login"
#define COMSIG_MOB_MOUSE_SCROLL_ON "comsig_mob_mouse_scroll_on"	//! from base of /mob/MouseWheelOn(): (atom/A, delta_x, delta_y, params)
/// From /obj/item/proc/attack_self() : (obj/item/used)
#define COMSIG_MOB_ITEM_ATTACK_SELF "mob_item_attack_self"

/// From /obj/item/proc/dropped() : (obj/item/dropped)
#define COMSIG_MOB_ITEM_DROPPED "mob_item_dropped"


/// From /obj/item/reagent_container/food/snacks/proc/on_Consume() : (obj/item/reagent_container/food/snacks/eaten_food)
#define COMSIG_MOB_EATEN_SNACK "mob_eaten_snack"

/// From /atom/proc/attackby() : (atom/attacked, obj/item/attacked_with)
#define COMSIG_MOB_PARENT_ATTACKBY "mob_parent_attackby"

/// From /obj/item/weapon/gun/proc/reload_into_chamber() : (obj/item/weapon/gun/empty_gun)
#define COMSIG_MOB_GUN_EMPTY "mob_gun_empty"

/// From /obj/item/weapon/gun/proc/reload() : (obj/item/weapon/gun/reloaded)
#define COMSIG_MOB_RELOADED_GUN "mob_reloaded_gun"

/// From /mob/proc/get_status_tab_items() : (list/status_list)
#define COMSIG_MOB_GET_STATUS_TAB_ITEMS "mob_get_status_tab_items"

/// From /datum/tutorial/proc/update_objective() : (new_objective)
#define COMSIG_MOB_TUTORIAL_UPDATE_OBJECTIVE "mob_tutorial_update_objective"

/// From /mob/proc/swap_hand() : ()
#define COMSIG_MOB_SWAPPED_HAND "mob_swapped_hand"

/// From /mob/proc/a_intent_change() : (new_intent)
#define COMSIG_MOB_INTENT_CHANGE "mob_intent_change"

/// From /obj/item/grab/proc/progress_passive() : (mob/living/carbon/human/grabber)
#define COMSIG_MOB_AGGRESSIVELY_GRABBED "mob_aggressively_grabbed"
	#define COMSIG_MOB_AGGRESIVE_GRAB_CANCEL (1<<0)

#define COMSIG_MOB_END_TUTORIAL "mob_end_tutorial"
