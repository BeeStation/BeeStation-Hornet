// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj/item signals
///from base of obj/item/equipped(): (/mob/equipper, slot)
#define COMSIG_ITEM_EQUIPPED "item_equip"
///from base of obj/item/on_grind(): ())
#define COMSIG_ITEM_ON_GRIND "on_grind"
///from base of obj/item/on_juice(): ()
#define COMSIG_ITEM_ON_JUICE "on_juice"
///from /obj/machinery/hydroponics/attackby(obj/item/O, mob/user, params) when an object is used as compost: (mob/user)
#define COMSIG_ITEM_ON_COMPOSTED "on_composted"
///Called when an item is dried by a drying rack:
#define COMSIG_ITEM_DRIED "item_dried"
///from base of obj/item/dropped(): (mob/user)
#define COMSIG_ITEM_DROPPED "item_drop"
///from base of obj/item/pickup(): (/mob/taker)
#define COMSIG_ITEM_PICKUP "item_pickup"

/// Sebt from obj/item/ui_action_click(): (mob/user, datum/action)
#define COMSIG_ITEM_UI_ACTION_CLICK "item_action_click"
	/// Return to prevent the default behavior (attack_selfing) from ocurring.
	#define COMPONENT_ACTION_HANDLED (1<<0)

#define COMSIG_ITEM_ATTACK_ZONE "item_attack_zone"				//! from base of mob/living/carbon/attacked_by(): (mob/living/carbon/target, mob/living/user, hit_zone)
#define COMSIG_ITEM_IMBUE_SOUL "item_imbue_soul" 				//! return a truthy value to prevent ensouling, checked in /obj/effect/proc_holder/spell/targeted/lichdom/cast(): (mob/user)
#define COMSIG_ITEM_MARK_RETRIEVAL "item_mark_retrieval"		//! called before marking an object for retrieval, checked in /obj/effect/proc_holder/spell/targeted/summonitem/cast() : (mob/user)
	#define COMPONENT_BLOCK_MARK_RETRIEVAL 1
#define COMSIG_ITEM_HIT_REACT "item_hit_react"					//! from base of obj/item/hit_reaction(): (mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	#define COMPONENT_HIT_REACTION_BLOCK (1<<0)
#define COMSIG_ITEM_SHARPEN_ACT "sharpen_act"           //! from base of item/sharpener/attackby(): (amount, max)
  #define COMPONENT_BLOCK_SHARPEN_APPLIED 1
  #define COMPONENT_BLOCK_SHARPEN_BLOCKED 2
  #define COMPONENT_BLOCK_SHARPEN_ALREADY 4
  #define COMPONENT_BLOCK_SHARPEN_MAXED 8
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
#define COMSIG_RADIO_MESSAGE "radio_message"					//! called from radio subtype procs in /obj/item/radio/talk_into(): (mob/living/user, treated_message, channel, list/message_mods)

// /obj/item/pen signals
#define COMSIG_PEN_ROTATED "pen_rotated"						//! called after rotation in /obj/item/pen/attack_self(): (rotation, mob/living/carbon/user)

/// Puts a target atom into the push (datum/source, datum/target)
#define COMSIG_ITEM_PUSH_BUFFER "push_buffer"
	#define COMPONENT_BUFFER_STORE_SUCCESS (1 << 0)
/// Puts a target atom into the push (datum/source, mob/user)
#define COMSIG_ITEM_FLUSH_BUFFER "flush_buffer"

// Deployable signals
/// Tell a deployable item to force its deployment  (datum/source, atom/location)
#define COMSIG_DEPLOYABLE_FORCE_DEPLOY "force_deploy"
	#define DEPLOYMENT_SUCCESS	(1 << 0)	//Indicates that something was successfully deployed
