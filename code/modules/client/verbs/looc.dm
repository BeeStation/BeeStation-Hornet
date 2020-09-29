// LOOC ported from Citadel, styling in stylesheet.dm and browseroutput.css

GLOBAL_VAR_INIT(looc_allowed, 1)

/client/verb/looc(msg as text)
    set name = "LOOC"
    set desc = "Local OOC, seen only by those in view."
    set category = "OOC"

    if(GLOB.say_disabled)    //This is here to try to identify lag problems
        to_chat(usr, "<span class='danger'> Speech is currently admin-disabled.</span>")
        return

    if(!mob)        return
    if(!mob.ckey)   return

    msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
    var/raw_msg = msg

    if(!msg)
        return

    if(!(prefs.toggles & CHAT_OOC))
        to_chat(src, "<span class='danger'>You have OOC (and therefore LOOC) muted.</span>")
        return

    if(is_banned_from(mob.ckey, "OOC"))
        to_chat(src, "<span class='danger'>You have been banned from OOC and LOOC.</span>")
        return

    if(!holder)
        if(!CONFIG_GET(flag/looc_enabled))
            to_chat(src, "<span class='danger'>LOOC is disabled.</span>")
            return
        if(!GLOB.dooc_allowed && (mob.stat == DEAD))
            to_chat(usr, "<span class='danger'>LOOC for dead mobs has been turned off.</span>")
            return
        if(prefs.muted & MUTE_OOC)
            to_chat(src, "<span class='danger'>You cannot use LOOC (muted).</span>")
            return
        if(handle_spam_prevention(msg,MUTE_OOC))
            return
        if(findtext(msg, "byond://"))
            to_chat(src, "<B>Advertising other servers is not allowed.</B>")
            log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
            return
        if(mob.stat)
            to_chat(src, "<span class='danger'>You cannot salt in LOOC while unconscious or dead.</span>")
            return
        if(istype(mob, /mob/dead))
            to_chat(src, "<span class='danger'>You cannot use LOOC while ghosting.</span>")
            return

        if(OOC_FILTER_CHECK(raw_msg))
            to_chat(src, "<span class='warning'>That message contained a word prohibited in OOC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ooc_chat'>\"[raw_msg]\"</span></span>")
            return

    msg = emoji_parse(msg)

    mob.log_talk(raw_msg, LOG_OOC, tag="(LOOC)")

    var/list/heard = get_hearers_in_view(7, get_top_level_mob(src.mob))
    for(var/mob/M in heard)
        if(!M.client)
            continue
        var/client/C = M.client
        if (C in GLOB.admins)
            continue //they are handled after that

        if (isobserver(M))
            continue //Also handled later.

        if(C.prefs.toggles & CHAT_OOC)
//            var/display_name = src.key
//            if(holder)
//                if(holder.fakekey)
//                    if(C.holder)
//                        display_name = "[holder.fakekey]/([src.key])"
//                else
//                    display_name = holder.fakekey
            to_chat(C,"<span class='looc'><span class='prefix'>LOOC:</span> <EM>[src.mob.name]:</EM> <span class='message'>[msg]</span></span>")

    for(var/client/C in GLOB.admins)
        if(C.prefs.toggles & CHAT_OOC)
            var/prefix = "(R)LOOC"
            if (C.mob in heard)
                prefix = "LOOC"
            to_chat(C,"<span class='looc'>[ADMIN_FLW(usr)]<span class='prefix'>[prefix]:</span> <EM>[src.key]/[src.mob.name]:</EM> <span class='message'>[msg]</span></span>")

    /*for(var/mob/dead/observer/G in world)
        if(!G.client)
            continue
        var/client/C = G.client
        if (C in GLOB.admins)
            continue //handled earlier.
        if(C.prefs.toggles & CHAT_OOC)
            var/prefix = "(G)LOOC"
            if (C.mob in heard)
                prefix = "LOOC"
        to_chat(C,"<font color='#6699CC'><span class='ooc'><span class='prefix'>[prefix]:</span> <EM>[src.key]/[src.mob.name]:</EM> <span class='message'>[msg]</span></span></font>")*/


/proc/log_looc(text)
    if (CONFIG_GET(flag/log_ooc))
        WRITE_FILE(GLOB.world_game_log, "\[[time_stamp()]]LOOC: [text]")

/mob/proc/get_top_level_mob()
    if(istype(src.loc,/mob)&&src.loc!=src)
        var/mob/M=src.loc
        return M.get_top_level_mob()
    return src

proc/get_top_level_mob(var/mob/S)
    if(istype(S.loc,/mob)&&S.loc!=S)
        var/mob/M=S.loc
        return M.get_top_level_mob()
    return S
