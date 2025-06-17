#define DEFINE_HREF_GROUP(_group_name) \
/datum/hrefcmd/##_group_name; \
/datum/hrefcmd/var/datum/hrefcmd/##_group_name/##_group_name = #_group_name; \
/datum/hrefcmd/print/##_group_name = "hrefcmd="+#_group_name;
#define DEFINE_HREF_PARAM(_group_name, _param_name) \
/datum/hrefcmd/param/##_group_name = /datum/hrefcmd/##_group_name; \
/datum/hrefcmd/##_group_name/var/##_param_name = #_param_name;

#define HREF_GROUP(_group_name) (/datum/hrefcmd/print::##_group_name+";")
#define HREF_PARAM(_param_key, _param_val) (/datum/hrefcmd/param::##_param_key+"="+(istext(_param_val) ? _param_val : #_param_val)+";")

#define NAMEOF_HREF(_href_key) (/datum/hrefcmd::##_href_key || /datum/hrefcmd/param::##_href_key) // + is a trick
#define LOCATE_HREF(_href_key, _list) (_list[NAMEOF_HREF(_href_key)])


// list of actual href commands //
DEFINE_HREF_GROUP(reload_tguipanel)

DEFINE_HREF_GROUP(admin_pm)
DEFINE_HREF_PARAM(admin_pm, msg_target)

DEFINE_HREF_GROUP(mentor_msg)
DEFINE_HREF_PARAM(mentor_msg, msg_target)

DEFINE_HREF_GROUP(commandbar_typing)

DEFINE_HREF_GROUP(openLink)
DEFINE_HREF_PARAM(openLink, link)

DEFINE_HREF_GROUP(var_edit)
DEFINE_HREF_PARAM(var_edit, Vars)

#undef DEFINE_HREF_GROUP





// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------
#ifdef SAMPLE_CODE // for sample code
#define DEFINE_HREF_GROUP(_thing) // for sample code
// Things are written here, but this code won't be compiled.
// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------



	// -------------------------------------------------------
	// ----------  How /datum/hrefcmd workds?  ---------------
	// -------------------------------------------------------

/* --------------------------------------------------
		#1. How to define a href command
*/
// If you want to make a href command, you just need to use DEFINE_HREF_GROUP()
DEFINE_HREF_GROUP(sample_group_name)
// This is exactly identical to below:
/datum/hrefcmd
	var/sample_group_name = "sample_group_name"
/datum/hrefcmd/print
	sample_group_name = "hrefcmd=sample_group_name"

/* --------------------------------------------------
		#2. How to use defined href command
*/
// Using href command comes with:
/datum/proc/build_href_group_name()
	return "<a href='byond://?[/datum/hrefcmd/print::sample_group_name]'>\[CLICK THIS\]</a>"
	// `/datum/hrefcmd/print::sample_group_name` is identical to "hrefcmd=sample_group_name"
	//		return "<a href='byond://?hrefcmd=sample_group_name'>\[CLICK THIS\]</a>"

/datum/proc/build_href_group_name_wrong_case()
	return "<a href='byond://?[/datum/hrefcmd::sample_group_name]'>\[CLICK THIS\]</a>"
	// For building a text, putting "/print" is important here
	// because it is automatically written with "hrefcmd="
	// so, this is identical to
	//		return "<a href='byond://?sample_group_name'>\[CLICK THIS\]</a>"
	// as "hrefcmd=" text is missing


/* --------------------------------------------------
		#3. How to make a clicked href working
*/
/client/Topic(href, href_list, hsrc, hsrc_group_name)
	// some client/Topic code here
	// ....
	switch(href_group_name)
		if(/datum/hrefcmd::sample_group_name)
			to_chat(src, span_danger("sample_group_name is activated!"))
		if("sample_group_name") // identical above
			to_chat(src, span_danger("sample_group_name is activated!"))


		// wrong case
		if(/datum/hrefcmd/print::sample_group_name) // this is wrong. It has '/print'
			to_chat(src, span_danger("this switch cannot activate sample_group_name'"))
		if("hrefcmd=sample_group_name") // identical to the above
			to_chat(src, span_danger("this switch cannot activate sample_group_name'"))
#endif
