// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /mob/living/carbon signals
///Called when a carbon becomes addicted (source = what addiction datum, addicted_mind = mind of the addicted carbon)
#define COMSIG_CARBON_GAIN_ADDICTION "carbon_gain_addiction"
///Called when a carbon is no longer addicted (source = what addiction datum was lost, addicted_mind = mind of the freed carbon)
#define COMSIG_CARBON_LOSE_ADDICTION "carbon_lose_addiction"

///from base of mob/living/carbon/soundbang_act(): (list(intensity))
#define COMSIG_CARBON_SOUNDBANG "carbon_soundbang"
///from /item/organ/proc/Insert() (/obj/item/organ/)
#define COMSIG_CARBON_GAIN_ORGAN "carbon_gain_organ"
///from /item/organ/proc/Remove() (/obj/item/organ/)
#define COMSIG_CARBON_LOSE_ORGAN "carbon_lose_organ"
///from /mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop, silent)
#define COMSIG_CARBON_EQUIP_HAT "carbon_equip_hat"
///from /mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop, silent)
#define COMSIG_CARBON_UNEQUIP_HAT "carbon_unequip_hat"
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


///from base of /obj/item/bodypart/proc/can_attach_limb(): (new_limb, special) allows you to fail limb attachment
#define COMSIG_ATTEMPT_CARBON_ATTACH_LIMB "attempt_carbon_attach_limb"
	#define COMPONENT_NO_ATTACH (1<<0)
///from base of /obj/item/bodypart/proc/try_attach_limb(): (new_limb, special)
#define COMSIG_CARBON_ATTACH_LIMB "carbon_attach_limb"
/// Called from bodypart being attached /obj/item/bodypart/proc/try_attach_limb(mob/living/carbon/new_owner, special)
#define COMSIG_BODYPART_ATTACHED "bodypart_attached"
///from base of /obj/item/bodypart/proc/try_attach_limb(): (new_limb, special)
#define COMSIG_CARBON_POST_ATTACH_LIMB "carbon_post_attach_limb"
/// Called from carbon losing a limb /obj/item/bodypart/proc/drop_limb(obj/item/bodypart/lost_limb, dismembered)
#define COMSIG_CARBON_POST_REMOVE_LIMB "carbon_post_remove_limb"
///from /obj/item/bodypart/proc/receive_damage, sent from the limb owner (limb, brute, burn)
#define COMSIG_CARBON_LIMB_DAMAGED "carbon_limb_damaged"
	#define COMPONENT_PREVENT_LIMB_DAMAGE (1 << 0)

///Called when a carbon gets a brain trauma (source = carbon, trauma = what trauma was added, resilience = the resilience of the trauma given, if set differently from the default) - this is before on_gain()
#define COMSIG_CARBON_GAIN_TRAUMA "carbon_gain_trauma"
	/// Return if you want to prevent the carbon from gaining the brain trauma.
	#define COMSIG_CARBON_BLOCK_TRAUMA (1 << 0)
/// Called from update_health_hud, whenever a bodypart is being updated on the health doll
#define COMSIG_BODYPART_UPDATING_HEALTH_HUD "bodypart_updating_health_hud"
	/// Return to override that bodypart's health hud with your own icon
	#define COMPONENT_OVERRIDE_BODYPART_HEALTH_HUD (1<<0)

/// Called from /obj/item/bodypart/check_for_injuries (mob/living/carbon/examiner, list/check_list)
#define COMSIG_BODYPART_CHECKED_FOR_INJURY "bodypart_injury_checked"
/// Called from /obj/item/bodypart/check_for_injuries (obj/item/bodypart/examined, list/check_list)
#define COMSIG_CARBON_CHECKING_BODYPART "carbon_checking_injury"

/// Called from carbon losing a limb /obj/item/bodypart/proc/drop_limb(obj/item/bodypart/lost_limb, dismembered)
#define COMSIG_CARBON_REMOVE_LIMB "carbon_remove_limb"
/// Called from bodypart being removed /obj/item/bodypart/proc/drop_limb(mob/living/carbon/old_owner, dismembered)
#define COMSIG_BODYPART_REMOVED "bodypart_removed"

#define COMSIG_CARBON_TRANSFORMED	"carbon_transformed"			//! Called whenever a carbon is transformed into another carbon, i.e monkeyize/humanize (mob/living/carbon/new_body)

/// Called from bodypart changing owner, which could be on attach or detachment. Either argument can be null. (mob/living/carbon/new_owner, mob/living/carbon/old_owner)
#define COMSIG_BODYPART_CHANGED_OWNER "bodypart_changed_owner"

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

///Called when a carbon's health hud is updated. (source = carbon, shown_health_amount)
#define COMSIG_CARBON_UPDATING_HEALTH_HUD "carbon_health_hud_update"
	/// Return if you override the carbon's health hud with something else
	#define COMPONENT_OVERRIDE_HEALTH_HUD (1<<0)
