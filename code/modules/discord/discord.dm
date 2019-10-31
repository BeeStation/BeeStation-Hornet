// discord config option
/datum/config_entry/flag/using_discord

proc/msg2url(var/msg as text)
    var/list/conversions = list(
    "\[fwslash]"="/",
    "\[colon]"=",",
    "\[bslash]"="\\",
    "\[qmark]"="?",
    "\[space]"=" ",
    "\[quote]"="\"",
    "\[nl]" = "\n",
    "@" = "(a)" // no @ abuse
    )
    for(var/c in conversions)
        msg = replacetext(msg, conversions[c], c)
    return msg
    
proc/discordsendmsg(var/channel as text, var/msg as text)
    if(!CONFIG_GET(flag/using_discord))
        return
    msg = msg2url(msg)
    world.Export("http://127.0.0.1:5000/api/[channel]/[msg]")