	/* 1. Used to declare href types */
//! Declare a name of a href category/type
//! `DECLARE_HREF_TYPE(_type_name)`
#define DECLARE_HREF_TYPE(_type_name) \
/datum/hrefcmd/##_type_name; \
/datum/hrefcmd/var/datum/hrefcmd/##_type_name/##_type_name = #_type_name;
//! Declare a parameter name of a declared href category/type.
//! `DECLARE_HREF_PARAM(_type_name, _param_name)`
#define DECLARE_HREF_PARAM(_type_name, _param_name) \
/datum/hrefcmd/param/##_type_name = /datum/hrefcmd/##_type_name; \
/datum/hrefcmd/##_type_name/var/##_param_name = #_param_name;


	/* 2. Used to write hyperlink texts */
//! Used to build HREF text
//! `HREF_TYPE(_type_name)`
#define HREF_TYPE(_type_name) ("hrefcmd="+/datum/hrefcmd::##_type_name+";")
//! Used to build HREF text based on href type
//! `HREF_TYPE(_type_name, _param_val)`
#define HREF_PARAM(_param_key, _param_val) (/datum/hrefcmd/param::##_param_key+"="+(istext(_param_val) ? _param_val : #_param_val)+";")


	/* 3. Used to get names and values for code failproofs, usually after topic called. */
//! Used get the string of the href key. This exists to prevent typo.
#define NAMEOF_HREF(_href_key) (/datum/hrefcmd::##_href_key || /datum/hrefcmd/param::##_href_key) // operator || is a trick. It's to access two types. If /param version(name::thing) is given, the first one(/hrefcmd) will be null, and then it will lead to /hrefcmd/param/name::thing
//! Used get a value from a href_list based on the given key
#define LOCATE_HREF(_href_key, _list) (_list[NAMEOF_HREF(_href_key)])


	/* 4. list of actual href commands */
DECLARE_HREF_TYPE(hrefcmd) // Only required for NAMEOF_HREF(hrefcmd)

DECLARE_HREF_TYPE(href_login)
DECLARE_HREF_PARAM(href_login, ip)
DECLARE_HREF_PARAM(href_login, nonce)
DECLARE_HREF_PARAM(href_login, seeker_port)
DECLARE_HREF_PARAM(href_login, session_token)
DECLARE_HREF_PARAM(href_login, from_ui)

DECLARE_HREF_TYPE(reload_tguipanel)

DECLARE_HREF_TYPE(admin_pm)
DECLARE_HREF_PARAM(admin_pm, msg_target)

DECLARE_HREF_TYPE(mentor_msg)
DECLARE_HREF_PARAM(mentor_msg, msg_target)

// check 'typing_indicator.html'
DECLARE_HREF_TYPE(commandbar_typing)
DECLARE_HREF_PARAM(commandbar_typing, param_verb)
DECLARE_HREF_PARAM(commandbar_typing, argument_length)

DECLARE_HREF_TYPE(openLink)
DECLARE_HREF_PARAM(openLink, link)

DECLARE_HREF_TYPE(var_edit)
DECLARE_HREF_PARAM(var_edit, Vars)
DECLARE_HREF_PARAM(var_edit, target)
DECLARE_HREF_PARAM(var_edit, target_varname)
DECLARE_HREF_PARAM(var_edit, dmlist_origin_ref)
DECLARE_HREF_PARAM(var_edit, dmlist_varname)
DECLARE_HREF_PARAM(var_edit, mobToDamage)
DECLARE_HREF_PARAM(var_edit, adjustDamage)
DECLARE_HREF_PARAM(var_edit, datumedit)
DECLARE_HREF_PARAM(var_edit, varnameedit)
DECLARE_HREF_PARAM(var_edit, rotatedatum)
DECLARE_HREF_PARAM(var_edit, rotatedir)

#undef DECLARE_HREF_TYPE


//////////////////////////////////////////////////////////////////////////////

// some janky defines for debug purpose. You really don't have to care this
#ifdef DEBUG
#define HREF_DEBUG
#endif
#ifdef LOWMEMORYMODE
#ifndef HREF_DEBUG
#define HREF_DEBUG
#endif
#endif

#ifdef HREF_DEBUG
/client
	var/check_my_topic_href = TRUE // handy variable in development to check href values
#else
/client
	var/check_my_topic_href = FALSE
#endif
