// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /mob/living/carbon signals

///from base of mob/living/carbon/soundbang_act(): (list(intensity))
#define COMSIG_CARBON_SOUNDBANG "carbon_soundbang"
///from /item/organ/proc/Insert() (/obj/item/organ/)
#define COMSIG_CARBON_GAIN_ORGAN "carbon_gain_organ"
///from /item/organ/proc/Remove() (/obj/item/organ/)
#define COMSIG_CARBON_LOSE_ORGAN "carbon_lose_organ"
///from /mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop, silent)
#define COMSIG_CARBON_UNEQUIP_SHOECOVER "carbon_unequip_shoecover"
#define COMSIG_CARBON_EQUIP_SHOECOVER "carbon_equip_shoecover"
///defined twice, in carbon and human's topics, fired when interacting with a valid embedded_object to pull it out (mob/living/carbon/target, /obj/item, /obj/item/bodypart/L)
#define COMSIG_CARBON_EMBED_RIP "item_embed_start_rip"
///called when removing a given item from a mob, from mob/living/carbon/remove_embedded_object(mob/living/carbon/target, /obj/item)
#define COMSIG_CARBON_EMBED_REMOVAL "item_embed_remove_safe"
///Called when someone attempts to cuff a carbon
#define COMSIG_CARBON_CUFF_ATTEMPTED "carbon_attempt_cuff"

//! from base of mob/living/carbon/set_species(): (new_race)
#define COMSIG_CARBON_SPECIESCHANGE "mob_carbon_specieschange"

///from base of /obj/item/bodypart/proc/try_attach_limb(): (new_limb, special)
#define COMSIG_CARBON_ATTACH_LIMB "carbon_attach_limb"
	#define COMPONENT_NO_ATTACH (1<<0)
/// Called from bodypart being attached /obj/item/bodypart/proc/try_attach_limb(mob/living/carbon/new_owner, special)
#define COMSIG_BODYPART_ATTACHED "bodypart_attached"
///from base of /obj/item/bodypart/proc/try_attach_limb(): (new_limb, special)
#define COMSIG_CARBON_POST_ATTACH_LIMB "carbon_post_attach_limb"
/// Called from carbon losing a limb /obj/item/bodypart/proc/drop_limb(obj/item/bodypart/lost_limb, dismembered)
#define COMSIG_CARBON_REMOVE_LIMB "carbon_remove_limb"
/// Called from carbon losing a limb /obj/item/bodypart/proc/drop_limb(obj/item/bodypart/lost_limb, dismembered)
#define COMSIG_CARBON_POST_REMOVE_LIMB "carbon_post_remove_limb"
/// Called from bodypart being removed /obj/item/bodypart/proc/drop_limb(mob/living/carbon/old_owner, dismembered)
#define COMSIG_BODYPART_REMOVED "bodypart_removed"
#define COMSIG_CARBON_TRANSFORMED	"carbon_transformed"			//! Called whenever a carbon is transformed into another carbon, i.e monkeyize/humanize (mob/living/carbon/new_body)

///from /mob/living/carbon/human/get_visible_name(), not sent if the mob has TRAIT_UNKNOWN: (identity)
#define COMSIG_HUMAN_GET_VISIBLE_NAME "human_get_visible_name"
	//Index for the name of the face
	#define VISIBLE_NAME_FACE 1
	//Index for the name of the id
	#define VISIBLE_NAME_ID 2
	//Index for whether their name is being overriden instead of obsfuscated
	#define VISIBLE_NAME_FORCED 3
///from /mob/living/carbon/human/get_id_name; only returns if the mob has TRAIT_UNKNOWN and it's being overriden: (identity)
#define COMSIG_HUMAN_GET_FORCED_NAME "human_get_forced_name"
