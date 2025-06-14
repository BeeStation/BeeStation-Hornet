// This is not technically a macro, but for the purpose of this, these are here
#define DEFINE_HREF_COMMAND(_thing) /datum/hrefcmd/var/_thing = #_thing;/datum/hrefcmd/print/_thing = "hrefcmd="+#_thing;

// list of actual href commands
DEFINE_HREF_COMMAND(reload_tguipanel)
DEFINE_HREF_COMMAND(admin_pm)
DEFINE_HREF_COMMAND(mentor_msg)
DEFINE_HREF_COMMAND(commandbar_typing)
DEFINE_HREF_COMMAND(openLink)

#undef DEFINE_HREF_COMMAND





// -------------------------------------------------------
#ifdef SAMPLE_CODE // for sample code
#define DEFINE_HREF_COMMAND(_thing) // for sample code
// Things are written here, but this code won't be compiled.


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
#undef DEFINE_HREF_COMMAND
