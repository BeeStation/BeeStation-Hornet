// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj/item signals
#define COMSIG_ITEM_ATTACK "item_attack"						//! from base of obj/item/attack(): (/mob/living/target, /mob/living/user)
#define COMSIG_ITEM_ATTACK_SELF "item_attack_self"				//! from base of obj/item/attack_self(): (/mob)
	#define COMPONENT_NO_INTERACT 1
#define COMSIG_ITEM_ATTACK_OBJ "item_attack_obj"				//! from base of obj/item/attack_obj(): (/obj, /mob)
	#define COMPONENT_NO_ATTACK_OBJ 1
#define COMSIG_ITEM_PRE_ATTACK "item_pre_attack"				//! from base of obj/item/pre_attack(): (atom/target, mob/user, params)
	#define COMPONENT_NO_ATTACK 1
#define COMSIG_ITEM_AFTERATTACK "item_afterattack"				//! from base of obj/item/afterattack(): (atom/target, mob/user, params)
#define COMSIG_ITEM_CHECK_WIELDED "item_check_wielded"  //! used to check if the item is wielded for special effects
  #define COMPONENT_IS_WIELDED 1
#define COMSIG_ITEM_DISABLE_EMBED "item_disable_embed"			///from [/obj/item/proc/disableEmbedding]:

///Called when an item is being offered, from [/obj/item/proc/on_offered(mob/living/carbon/offerer)]
#define COMSIG_ITEM_OFFERING "item_offering"
	///Interrupts the offer proc
	#define COMPONENT_OFFER_INTERRUPT (1<<0)
///Called when an someone tries accepting an offered item, from [/obj/item/proc/on_offer_taken(mob/living/carbon/offerer, mob/living/carbon/taker)]
#define COMSIG_ITEM_OFFER_TAKEN "item_offer_taken"
	///Interrupts the offer acceptance
	#define COMPONENT_OFFER_TAKE_INTERRUPT (1<<0)

///for any tool behaviors: (mob/living/user, obj/item/I, list/recipes)
#define COMSIG_ATOM_TOOL_ACT(tooltype) "tool_act_[tooltype]"
	#define COMPONENT_BLOCK_TOOL_ATTACK (1<<0)
//not widely used yet, but has lot of potential

#define COMSIG_ITEM_ATTACK_EFFECT "item_effect_attacked"

//////////////////////////////

// /obj/effect/mine signals
#define COMSIG_MINE_TRIGGERED "minegoboom"						///from [/obj/effect/mine/proc/triggermine]:

// /obj/item/modular_computer/tablet/pda signals
/// Called on tablet (PDA) when the user changes the ringtone: (mob/living/user, new_ringtone)
#define COMSIG_TABLET_CHANGE_RINGTONE "comsig_tablet_change_ringtone"
	#define COMPONENT_STOP_RINGTONE_CHANGE (1<<0)


// /obj/item/radio signals
#define COMSIG_RADIO_NEW_FREQUENCY "radio_new_frequency"		//! called from base of /obj/item/radio/proc/set_frequency(): (list/args)
#define COMSIG_RADIO_MESSAGE "radio_message"

// /obj/item/pen signals
#define COMSIG_PEN_ROTATED "pen_rotated"						//! called after rotation in /obj/item/pen/attack_self(): (rotation, mob/living/carbon/user)

