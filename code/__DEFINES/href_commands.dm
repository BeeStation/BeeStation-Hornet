// This is not technically a macro, but for the purpose of this, these are here
#define define_href_command(_thing) /hrefcmd/var/_thing = #_thing;/hrefcmd/print/_thing = "hrefcmd="+#_thing;
/hrefcmd/parent_type = /datum

define_href_command(reload_tguipanel)
define_href_command(admin_pm)
define_href_command(mentor_msg)
define_href_command(commandbar_typing)
define_href_command(openLink)

#undef define_href_command
