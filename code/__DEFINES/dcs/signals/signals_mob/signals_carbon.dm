// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /mob/living/carbon signals
#define COMSIG_CARBON_SOUNDBANG "carbon_soundbang"				//! from base of mob/living/carbon/soundbang_act(): (list(intensity))
#define COMSIG_CARBON_SPECIESCHANGE "mob_carbon_specieschange"	//! from base of mob/living/carbon/set_species(): (new_race)
#define COMSIG_CARBON_GAIN_ORGAN "carbon_gain_organ"			//from /item/organ/proc/Insert() (/obj/item/organ/)
#define COMSIG_CARBON_LOSE_ORGAN "carbon_lose_organ"			//from /item/organ/proc/Remove() (/obj/item/organ/)
#define COMSIG_CARBON_EMBED_RIP "item_embed_start_rip"						// defined twice, in carbon and human's topics, fired when interacting with a valid embedded_object to pull it out (mob/living/carbon/target, /obj/item, /obj/item/bodypart/L)
#define COMSIG_CARBON_EMBED_REMOVAL "item_embed_remove_safe"		// called when removing a given item from a mob, from mob/living/carbon/remove_embedded_object(mob/living/carbon/target, /obj/item)
#define COMSIG_CARBON_CUFF_ATTEMPTED "carbon_attempt_cuff"			///Called when someone attempts to cuff a carbon
#define COMSIG_CARBON_TRANSFORMED	"carbon_transformed"			//! Called whenever a carbon is transformed into another carbon, i.e monkeyize/humanize (mob/living/carbon/new_body)
