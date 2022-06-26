// Atom x_act() procs signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

/// from base of atom/ex_act(): (severity, target)
#define COMSIG_ATOM_EX_ACT "atom_ex_act"
/// from base of atom/emp_act(): (severity)
#define COMSIG_ATOM_EMP_ACT "atom_emp_act"
/// from base of atom/fire_act(): (exposed_temperature, exposed_volume)
#define COMSIG_ATOM_FIRE_ACT "atom_fire_act"
/// from base of atom/bullet_act(): (/obj/item/projectile, def_zone)
#define COMSIG_ATOM_BULLET_ACT "atom_bullet_act"
///from base of atom/CheckParts(): (list/parts_list, datum/crafting_recipe/R)
#define COMSIG_ATOM_CHECKPARTS "atom_checkparts"
/// from base of atom/acid_act(): (acidpwr, acid_volume)
#define COMSIG_ATOM_ACID_ACT "atom_acid_act"
/// from base of atom/rad_act(intensity)
#define COMSIG_ATOM_RAD_ACT "atom_rad_act"
/// from base of atom/emag_act(): ()
#define COMSIG_ATOM_EMAG_ACT "atom_emag_act"
/// from obj/machinery/bsa/full/proc/fire(): ()
#define COMSIG_ATOM_BSA_BEAM "atom_bsa_beam_pass"
	#define COMSIG_ATOM_BLOCKS_BSA_BEAM (1<<0)

/// from base of atom/narsie_act(): ()
#define COMSIG_ATOM_NARSIE_ACT "atom_narsie_act"
/// from base of atom/ratvar_act(): ()
#define COMSIG_ATOM_RATVAR_ACT "atom_ratvar_act"
/// from base of atom/light_eater_act(): (obj/item/light_eater/light_eater)
#define COMSIG_ATOM_LIGHTEATER_ACT "atom_lighteater_act"
/// from base of atom/eminence_act(): ()
#define COMSIG_ATOM_EMINENCE_ACT "atom_eminence_act"
/// from base of atom/blob_act(): (/obj/structure/blob)
#define COMSIG_ATOM_BLOB_ACT "atom_blob_act"
/// if returned, forces nothing to happen when the atom is attacked by a blob
	#define COMPONENT_CANCEL_BLOB_ACT (1<<0)

/// from base of atom/rcd_act(): (/mob, /obj/item/construction/rcd, passed_mode)
#define COMSIG_ATOM_RCD_ACT "atom_rcd_act"
/// from base of atom/Exited(): (mob/user, var/obj/item/extrapolator/E, scan = TRUE)
#define COMSIG_ATOM_EXTRAPOLATOR_ACT "atom_extrapolator_act"
///for any tool behaviors: (mob/living/user, obj/item/I, list/recipes)
#define COMSIG_ATOM_TOOL_ACT(tooltype) "tool_act_[tooltype]"
	#define COMPONENT_BLOCK_TOOL_ATTACK (1<<0)
///for when an atom has been created through processing (atom/original_atom, list/chosen_processing_option)
#define COMSIG_ATOM_CREATEDBY_PROCESSING "atom_createdby_processing"
///when an atom is processed (mob/living/user, obj/item/I, list/atom/results)
#define COMSIG_ATOM_PROCESSED "atom_processed"
///called on item when microwaved (): (obj/machinery/microwave/M)
#define COMSIG_ITEM_MICROWAVE_ACT "microwave_act"
///called on item when created through microwaving (): (obj/machinery/microwave/M, cooking_efficiency)
#define COMSIG_ITEM_MICROWAVE_COOKED "microwave_cooked"

//Customizable

///called when an atom with /datum/component/customizable_reagent_holder is customized (obj/item/I)
#define COMSIG_ATOM_CUSTOMIZED "atom_customized"
///called when an item is used as an ingredient: (atom/customized)
#define COMSIG_ITEM_USED_AS_INGREDIENT "item_used_as_ingredient"
///called when an edible ingredient is added: (datum/component/edible/ingredient)
#define COMSIG_EDIBLE_INGREDIENT_ADDED "edible_ingredient_added"
