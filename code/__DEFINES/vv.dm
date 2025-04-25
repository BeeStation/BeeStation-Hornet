#define VV_NUM "Number"
#define VV_TEXT "Text"
#define VV_MESSAGE "Mutiline Text"
#define VV_ICON "Icon"
#define VV_COLOR "Color"
#define VV_COLOR_MATRIX "Color Matrix"
#define VV_ATOM_REFERENCE "Atom Reference"
#define VV_DATUM_REFERENCE "Datum Reference"
#define VV_MOB_REFERENCE "Mob Reference"
#define VV_CLIENT "Client"
#define VV_ATOM_TYPE "Atom Typepath"
#define VV_DATUM_TYPE "Datum Typepath"
#define VV_TYPE "Custom Typepath"
#define VV_FILE "File"
#define VV_LIST "List"
#define VV_NEW_ATOM "New Atom"
#define VV_NEW_DATUM "New Datum"
#define VV_NEW_TYPE "New Custom Typepath"
#define VV_NEW_LIST "New List"
#define VV_NULL "NULL"
#define VV_INFINITY "Infinity"
#define VV_RESTORE_DEFAULT "Restore to Default"
#define VV_MARKED_DATUM "Marked Datum"
#define VV_TAGGED_DATUM "Tagged Datum"
#define VV_BITFIELD "Bitfield"
#define VV_TEXT_LOCATE "Custom Reference Locate"
#define VV_PROCCALL_RETVAL "Return Value of Proccall"
#define VV_WEAKREF "Weak Reference Datum"

#define VV_MSG_MARKED "<br><font size='1' color='red'><b>Marked Object</b></font>"
#define VV_MSG_TAGGED(num) "<br><font size='1' color='red'><b>Tagged Datum #[num]</b></font>"
#define VV_MSG_EDITED "<br><font size='1' color='red'><b>Var Edited</b></font>"
#define VV_MSG_DELETED "<br><font size='1' color='red'><b>Deleted</b></font>"

#define VV_BIG_SIZED_LIST_THRESHOLD 50

//#define IS_VALID_ASSOC_KEY(V) (istext(V) || ispath(V) || isdatum(V) || islist(V))
#define IS_VALID_ASSOC_KEY(V) (!isnum_safe(V))		//hhmmm..

//General helpers
#define VV_HREF_TARGET_INTERNAL(target, href_key) "?_src_=vars;[HrefToken()];[href_key]=TRUE;[VV_HK_TARGET]=[REF(target)]"
#define VV_HREF_TARGETREF_INTERNAL(targetref, href_key) "?_src_=vars;[HrefToken()];[href_key]=TRUE;[VV_HK_TARGET]=[targetref]"
#define VV_HREF_TARGET(target, href_key, text) "<a href='byond://[VV_HREF_TARGET_INTERNAL(target, href_key)]'>[text]</a>"
#define VV_HREF_TARGETREF(targetref, href_key, text) "<a href='byond://[VV_HREF_TARGETREF_INTERNAL(targetref, href_key)]'>[text]</a>"
#define VV_HREF_TARGET_1V(target, href_key, text, varname) "<a href='byond://[VV_HREF_TARGET_INTERNAL(target, href_key)];[VV_HK_VARNAME]=[varname]'>[text]</a>"		//for stuff like basic varedits, one variable
#define VV_HREF_TARGETREF_1V(targetref, href_key, text, varname) "<a href='byond://[VV_HREF_TARGETREF_INTERNAL(targetref, href_key)];[VV_HK_VARNAME]=[varname]'>[text]</a>"
//! Non-standard helper for special list vv. this doesn't use VV_HK_TARGET and REF because special list doesn't work in a sane sense.
#define VV_HREF_SPECIAL(dmlist_origin_ref, href_action, text, list_index, dmlist_varname) "<a href='byond://?_src_=vars;[HrefToken()];[href_action]=TRUE;dmlist_origin_ref=[dmlist_origin_ref];dmlist_varname=[dmlist_varname];[VV_HK_VARNAME]=[list_index]'>[text]</a>"
#define VV_HREF_SPECIAL_MENU(dmlist_origin_ref, href_action, dmlist_varname) "byond://?_src_=vars;[HrefToken()];[href_action]=TRUE;[VV_HK_DO_LIST_EDIT]=TRUE;dmlist_origin_ref=[dmlist_origin_ref];dmlist_varname=[dmlist_varname]"

#define GET_VV_TARGET locate(href_list[VV_HK_TARGET])
#define GET_VV_VAR_TARGET href_list[VV_HK_VARNAME]

//Helper for getting something to vv_do_topic in general
#define VV_TOPIC_LINK(datum, href_key, text) "<a href='byond://?_src_=vars;[HrefToken()];[href_key]=TRUE;target=[REF(datum)]'>text</a>"

//Helpers for vv_get_dropdown()
#define VV_DROPDOWN_OPTION(href_key, name) . += "<option value='byond://?_src_=vars;[HrefToken()];[href_key]=TRUE;target=[REF(src)]'>[name]</option>"
//Same with VV_DROPDOWN_OPTION, but global proc doesn't have src
#define VV_DROPDOWN_OPTION_APPEARANCE(thing, href_key, name) . += "<option value='byond://?_src_=vars;[HrefToken()];[href_key]=TRUE;target=[REF(thing)]'>[name]</option>"

// VV HREF KEYS
#define VV_HK_TARGET "target"
#define VV_HK_VARNAME "targetvar"		//name or index of var for 1 variable targetting hrefs.

// vv_do_list() keys
#define VV_HK_LIST_ADD "listadd"
#define VV_HK_LIST_EDIT "listedit"
#define VV_HK_LIST_CHANGE "listchange"
#define VV_HK_LIST_REMOVE "listremove"
#define VV_HK_LIST_ERASE_NULLS "listnulls"
#define VV_HK_LIST_ERASE_DUPES "listdupes"
#define VV_HK_LIST_SHUFFLE "listshuffle"
#define VV_HK_LIST_SET_LENGTH "listlen"

// I exist alone here just for special list edit. God, why.
#define VV_HK_DO_LIST_EDIT "do_vv_list_edit"

// vv_do_basic() keys
#define VV_HK_BASIC_EDIT "datumedit"
#define VV_HK_BASIC_CHANGE "datumchange"
#define VV_HK_BASIC_MASSEDIT "massedit"

// /datum
#define VV_HK_DELETE "delete"
#define VV_HK_EXPOSE "expose"
#define VV_HK_CALLPROC "proc_call"
#define VV_HK_MARK "mark"
#define VV_HK_TAG "tag"
#define VV_HK_ADDCOMPONENT "addcomponent"
#define VV_HK_MODIFY_TRAITS "modtraits"

// /datum/weakref
#define VV_HK_WEAKREF_RESOLVE "weakref_resolve"


// /atom
#define VV_HK_MODIFY_TRANSFORM "atom_transform"
#define VV_HK_MODIFY_GREYSCALE "modify_greyscale"
#define VV_HK_ADD_REAGENT "addreagent"
#define VV_HK_TRIGGER_EMP "empulse"
#define VV_HK_TRIGGER_EXPLOSION "explode"
#define VV_HK_AUTO_RENAME "auto_rename"
#define VV_HK_RADIATE "radiate"
#define VV_HK_EDIT_FILTERS "edit_filters"
#define VV_HK_EDIT_COLOR_MATRIX "edit_color_matrix"
#define VV_HK_EDIT_PARTICLES "edit_particles"
#define VV_HK_ARMOR_MOD "mod_obj_armor"
#define VV_HK_ADD_EMITTER "add_emitter"
#define VV_HK_REMOVE_EMITTER "remove_emitter"
#define VV_HK_ADD_AI "add_ai"

// /datum/gas_mixture
#define VV_HK_SET_MOLES "set_moles"
#define VV_HK_EMPTY "empty"
#define VV_HK_SET_TEMPERATURE "set_temp"
#define VV_HK_UPDATE_ACTIVE_TURF "update_active_turfs"

// /obj
#define VV_HK_OSAY "osay"
#define VV_HK_MASS_DEL_TYPE "mass_delete_type"

// /obj/item/card/id
#define VV_ID_PAYDAY "id_payday"
#define VV_ID_GIVE_MINING_POINT "id_give_mining_points"

// /obj/item/organ/cyberimp/arm
#define VV_HK_ADD_IMPLANT_TOOL	"add_implant_tool"
#define VV_HK_DEL_IMPLANT_TOOL	"del_implant_tool"

// /obj/machinery/vendor/exploration
#define VV_ID_GIVE_EXPLO_POINT "id_give_explo_points"

// /obj/machinery/computer/rdconsole
#define VV_ID_GIVE_GENERAL_POINT "give_general_points"
#define VV_ID_GIVE_DISCOVERY_POINT "give_discovery_points"
#define VV_ID_GIVE_NANITE_POINT "give_nanite_points"

// /mob
#define VV_HK_GIB "gib"
#define VV_HK_GIVE_SPELL "give_spell"
#define VV_HK_REMOVE_SPELL "remove_spell"
#define VV_HK_GIVE_DISEASE "give_disease"
#define VV_HK_GODMODE "godmode"
#define VV_HK_DROP_ALL "dropall"
#define VV_HK_REGEN_ICONS "regen_icons"
#define VV_HK_PLAYER_PANEL "player_panel"
#define VV_HK_BUILDMODE "buildmode"
#define VV_HK_DIRECT_CONTROL "direct_control"
#define VV_HK_GIVE_DIRECT_CONTROL "give_direct_control"
#define VV_HK_OFFER_GHOSTS "offer_ghosts"

// /mob/living/carbon
#define VV_HK_MAKE_AI "aiify"
#define VV_HK_MODIFY_BODYPART "mod_bodypart"
#define VV_HK_MODIFY_ORGANS "organs_modify"
#define VV_HK_HALLUCINATION "force_hallucinate"
#define VV_HK_MARTIAL_ART "give_martial_art"
#define VV_HK_GIVE_TRAUMA "give_trauma"
#define VV_HK_CURE_TRAUMA "cure_trauma"
#define VV_HK_GIVE_MUTATION "give_mutation"
#define VV_HK_REMOVE_MUTATION "remove_mutation"

// /mob/living/carbon/human
#define VV_HK_COPY_OUTFIT "copy_outfit"
#define VV_HK_MOD_QUIRKS "quirkmod"
#define VV_HK_MAKE_MONKEY "human_monkify"
#define VV_HK_MAKE_CYBORG "human_cyborgify"
#define VV_HK_MAKE_SLIME "human_slimeify"
#define VV_HK_MAKE_ALIEN "human_alienify"
#define VV_HK_SET_SPECIES "setspecies"
#define VV_HK_PURRBATION "purrbation"
#define VV_HK_RANDOM_NAME "random_name"

// misc
#define VV_HK_SPACEVINE_PURGE "spacevine_purge"
#define VV_HK_MODIFY_CANISTER_GAS "modify_canister_gas"

// paintings
#define VV_HK_REMOVE_PAINTING "remove_painting"

//outfits
#define VV_HK_TO_OUTFIT_EDITOR "outfit_editor"

// Flags for debug_variable() that do little things to what we end up rendering

/// ALWAYS render a reduced list, useful for fuckoff big datums that need to be condensed for the sake of client load
#define VV_ALWAYS_CONTRACT_LIST (1<<0)
#define VV_READ_ONLY (1<<1)


#define VV_LIST_PROTECTED (1) /// Can not vv the list. Doing vv this list is not safe.
#define VV_LIST_READ_ONLY (2) /// Can vv the list, but can not edit.
#define VV_LIST_EDITABLE (3) /// Can vv the list, and edit.

// Becomes read only at live, editable at debug, dynamically
#ifdef DEBUG
#define VV_LIST_READ_ONLY___DEBUG_EDITABLE (3)
#else
#define VV_LIST_READ_ONLY___DEBUG_EDITABLE (2)
#endif

/// A list of all the special byond lists that need to be handled different by vv.
/// manually adding var name is recommanded.
GLOBAL_LIST_INIT(vv_special_lists, list(
	// /datum
	"vars" = VV_LIST_READ_ONLY,
	// /atom
	"overlays" = VV_LIST_EDITABLE,
	"underlays" = VV_LIST_EDITABLE,
	"vis_contents" = VV_LIST_EDITABLE,
	"vis_locs" = VV_LIST_READ_ONLY___DEBUG_EDITABLE,
	"contents" = VV_LIST_EDITABLE,
	"locs" = VV_LIST_READ_ONLY___DEBUG_EDITABLE,
	"verbs" = VV_LIST_READ_ONLY___DEBUG_EDITABLE, // verb is not safe to edit in live server
	"filters" = VV_LIST_PROTECTED, // This is not good to change in vv, yet.
	// /client
	"bounds" = VV_LIST_PROTECTED, // DM document says it's read-only. Better not to edit this.
	"images" = VV_LIST_EDITABLE,
	"screen" = VV_LIST_EDITABLE,
))
// NOTE: this is highly attached to how /datum/vv_ghost works.


#ifndef DEBUG
GLOBAL_PROTECT(vv_special_lists) // changing this in live server is a bad idea
#endif
