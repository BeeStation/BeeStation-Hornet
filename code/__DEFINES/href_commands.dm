// This is not technically a macro, but for the purpose of this, these are here
#define DEFINE_HREF_COMMAND(_command) \
/datum/hrefcmd/##_command; \
/datum/hrefcmd/var/datum/hrefcmd/##_command/##_command = #_command; \
/datum/hrefcmd/print/##_command = "hrefcmd="+#_command;
#define DEFINE_HREF_PARAM(_command, _param_name) \
/datum/hrefcmd/param/##_command = /datum/hrefcmd/##_command; \
/datum/hrefcmd/##_command/var/##_param_name = #_param_name;

#define HREF_COMMAND(_command) (/datum/hrefcmd/print::##_command+";")
#define HREF_PARAM(_command, _param_name, _param_val) (/datum/hrefcmd/param::##_command::##_param_name+"="+(istext(_param_val) ? _param_val : #_param_val)+";")
#define HREF_SWITCH(_command) (/datum/hrefcmd::##_command)

// list of actual href commands
DEFINE_HREF_COMMAND(reload_tguipanel)

DEFINE_HREF_COMMAND(admin_pm)
DEFINE_HREF_PARAM(admin_pm, msg_target)

DEFINE_HREF_COMMAND(mentor_msg)
DEFINE_HREF_PARAM(mentor_msg, msg_target)

DEFINE_HREF_COMMAND(commandbar_typing)

DEFINE_HREF_COMMAND(openLink)
DEFINE_HREF_PARAM(openLink, link)

DEFINE_HREF_COMMAND(var_edit)
DEFINE_HREF_PARAM(var_edit, Vars)

#undef DEFINE_HREF_COMMAND





// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------
#ifdef SAMPLE_CODE // for sample code
#define DEFINE_HREF_COMMAND(_thing) // for sample code
// Things are written here, but this code won't be compiled.
// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------



	// -------------------------------------------------------
	// ----------  How /datum/hrefcmd workds?  ---------------
	// -------------------------------------------------------

/* --------------------------------------------------
		#1. How to define a href command
*/
// If you want to make a href command, you just need to use DEFINE_HREF_COMMAND()
DEFINE_HREF_COMMAND(sample_command)
// This is exactly identical to below:
/datum/hrefcmd
	var/sample_command = "sample_command"
/datum/hrefcmd/print
	sample_command = "hrefcmd=sample_command"

/* --------------------------------------------------
		#2. How to use defined href command
*/
// Using href command comes with:
/datum/proc/build_href_command()
	return "<a href='byond://?[/datum/hrefcmd/print::sample_command]'>\[CLICK THIS\]</a>"
	// `/datum/hrefcmd/print::sample_command` is identical to "hrefcmd=sample_command"
	//		return "<a href='byond://?hrefcmd=sample_command'>\[CLICK THIS\]</a>"

/datum/proc/build_href_command_wrong_case()
	return "<a href='byond://?[/datum/hrefcmd::sample_command]'>\[CLICK THIS\]</a>"
	// For building a text, putting "/print" is important here
	// because it is automatically written with "hrefcmd="
	// so, this is identical to
	//		return "<a href='byond://?sample_command'>\[CLICK THIS\]</a>"
	// as "hrefcmd=" text is missing


/* --------------------------------------------------
		#3. How to make a clicked href working
*/
/client/Topic(href, href_list, hsrc, hsrc_command)
	// some client/Topic code here
	// ....
	switch(href_command)
		if(/datum/hrefcmd::sample_command)
			to_chat(src, span_danger("sample_command is activated!"))
		if("sample_command") // identical above
			to_chat(src, span_danger("sample_command is activated!"))


		// wrong case
		if(/datum/hrefcmd/print::sample_command) // this is wrong. It has '/print'
			to_chat(src, span_danger("this switch cannot activate sample_command'"))
		if("hrefcmd=sample_command") // identical to the above
			to_chat(src, span_danger("this switch cannot activate sample_command'"))
#endif
