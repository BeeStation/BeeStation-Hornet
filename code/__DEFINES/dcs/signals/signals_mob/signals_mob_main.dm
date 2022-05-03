// /mob signals
#define COMSIG_MOB_LOGIN "mob_login"
/// from base of /mob/Logout(): ()
#define COMSIG_MOB_LOGOUT "mob_logout"
/// from base of mob/death(): (gibbed)
#define COMSIG_MOB_DEATH "mob_death"
/// from base of mob/set_stat(): (new_stat)
#define COMSIG_MOB_STATCHANGE "mob_statchange"
/// from base of mob/clickon(): (atom/A, params)
#define COMSIG_MOB_CLICKON "mob_clickon"
	#define COMSIG_MOB_CANCEL_CLICKON (1<<0)
/// from base of obj/allowed(mob/M): (/obj) returns bool, if TRUE the mob has id access to the obj
#define COMSIG_MOB_ALLOWED "mob_allowed"
/// from base of mob/anti_magic_check(): (mob/user, magic, holy, major, self, protection_sources)
#define COMSIG_MOB_RECEIVE_MAGIC "mob_receive_magic"
	#define COMPONENT_BLOCK_MAGIC (1<<0)
/// from base of mob/create_mob_hud(): ()
#define COMSIG_MOB_HUD_CREATED "mob_hud_created"
/// from base of atom/attack_hand(): (mob/user, modifiers)
#define COMSIG_MOB_ATTACK_HAND "mob_attack_hand"
/// from base of turf/attack_hand
#define COMSIG_MOB_ATTACK_HAND_TURF "mob_attack_hand_turf"
/// from base of
#define COMSIG_MOB_HAND_ATTACKED "mob_hand_attacked"
/// from base of /obj/item/attack(): (mob/M, mob/user)
#define COMSIG_MOB_ITEM_ATTACK "mob_item_attack"
	#define COMPONENT_ITEM_NO_ATTACK 1
#define COMSIG_MOB_EQUIPPED_ITEM "mob_equipped_item"			//! from base of /item/equipped(): (/mob/user, /obj/item, slot)
#define COMSIG_MOB_DROPPED_ITEM "mob_dropped_item"				//! from base of /item/dropped(): (/mob/user, /obj/item, loc)
/// from base of /mob/living/proc/apply_damage(): (damage, damagetype, def_zone)
#define COMSIG_MOB_APPLY_DAMGE	"mob_apply_damage"
/// from base of obj/item/afterattack(): (atom/target, mob/user, proximity_flag, click_parameters)
#define COMSIG_MOB_ITEM_AFTERATTACK "mob_item_afterattack"
/// from base of mob/RangedAttack(): (atom/A, params)
#define COMSIG_MOB_ATTACK_RANGED "mob_attack_ranged"
/// from base of /mob/throw_item(): (atom/target)
#define COMSIG_MOB_THROW "mob_throw"
/// from base of /mob/update_sight(): ()
#define COMSIG_MOB_UPDATE_SIGHT "mob_update_sight"
/// from base of /mob/verb/examinate(): (atom/target)
#define COMSIG_MOB_EXAMINATE "mob_examinate"
/// from /mob/living/say(): ()
#define COMSIG_MOB_SAY "mob_say"
/// from base of /mob/living/attack_alien(): (user)
#define COMSIG_MOB_ATTACK_ALIEN "mob_attack_alien"
/// From base of mob/update_movespeed():area
#define COMSIG_MOB_MOVESPEED_UPDATED "mob_update_movespeed"
	#define COMPONENT_UPPERCASE_SPEECH 1
	/// used to access COMSIG_MOB_SAY argslist
	#define SPEECH_MESSAGE 1
	#define SPEECH_BUBBLE_TYPE 2
	#define SPEECH_SPANS 3
	#define SPEECH_SANITIZE 4
	#define SPEECH_LANGUAGE 5
	#define SPEECH_IGNORE_SPAM 6
	#define SPEECH_FORCED 7
/// from /mob/living/emote(): ()
#define COMSIG_MOB_EMOTE "mob_emote"
///from base of mob/swap_hand()
#define COMSIG_MOB_SWAP_HANDS "mob_swap_hands"
  #define COMPONENT_BLOCK_SWAP 1
/// from /mob/say_dead(): (mob/speaker, message)
#define COMSIG_MOB_DEADSAY "mob_deadsay"
	#define MOB_DEADSAY_SIGNAL_INTERCEPT 1
///from base of /mob/verb/pointed: (atom/A)
#define COMSIG_MOB_POINTED "mob_pointed"
