// discord config option
/datum/config_entry/flag/using_discord
/datum/config_entry/string/discord_webhook
    config_entry_value = "http://127.0.0.1:5000/api/"

/proc/msg2url(var/msg as text)
    var/list/conversions = list(
    "\[fwslash]"="/",
    "\[colon]"=",",
    "\[bslash]"="\\",
    "\[qmark]"="?",
    "\[space]"=" ",
    "\[quote]"="\"",
    "\[nl]" = "\n",
    "\[ocurly]" = "{",
    "\[ccurly]" = "}",
    "\[hash]" = "#",
    "@" = "(a)" // no @ abuse
    )
    for(var/c in conversions)
        msg = replacetext(msg, conversions[c], c)
    return msg

/proc/discordsendmsg(var/channel as text, var/msg as text)
    if(!CONFIG_GET(flag/using_discord))
        return
    msg = msg2url(msg)
    var/datum/http_request/request = new()
    request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/discord_webhook)][channel]/[msg]")
    request.begin_async()
