// /mob/living/carbon signals
/// from base of mob/living/carbon/soundbang_act(): (list(intensity))
#define COMSIG_CARBON_SOUNDBANG "carbon_soundbang"
/// from base of mob/living/carbon/set_species(): (new_race)
#define COMSIG_CARBON_SPECIESCHANGE "mob_carbon_specieschange"
/// from /item/organ/proc/Insert() (/obj/item/organ/)
#define COMSIG_CARBON_GAIN_ORGAN "carbon_gain_organ"
//from /item/organ/proc/Remove() (/obj/item/organ/)
#define COMSIG_CARBON_LOSE_ORGAN "carbon_lose_organ"
// defined twice, in carbon and human's topics, fired when interacting with a valid embedded_object to pull it out (mob/living/carbon/target, /obj/item, /obj/item/bodypart/L)
#define COMSIG_CARBON_EMBED_RIP "item_embed_start_rip"
// called when removing a given item from a mob, from mob/living/carbon/remove_embedded_object(mob/living/carbon/target, /obj/item)
#define COMSIG_CARBON_EMBED_REMOVAL "item_embed_remove_safe"
/// Called when someone attempts to cuff a carbon
#define COMSIG_CARBON_CUFF_ATTEMPTED "carbon_attempt_cuff"
///Called when a carbon becomes addicted (source = what addiction datum, addicted_mind = mind of the addicted carbon)
#define COMSIG_CARBON_GAIN_ADDICTION "carbon_gain_addiction"
///Called when a carbon is no longer addicted (source = what addiction datum was lost, addicted_mind = mind of the freed carbon)
#define COMSIG_CARBON_LOSE_ADDICTION "carbon_lose_addiction"

// /mob/living/carbon/human signals
/// from mob/living/carbon/human/UnarmedAttack(): (atom/target)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACK "human_melee_unarmed_attack"
/// from mob/living/carbon/human/UnarmedAttack(): (mob/living/carbon/human/attacker)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACKBY "human_melee_unarmed_attackby"
/// Hit by successful disarm attack (mob/living/carbon/human/attacker,zone_targeted)
#define COMSIG_HUMAN_DISARM_HIT	"human_disarm_hit"
