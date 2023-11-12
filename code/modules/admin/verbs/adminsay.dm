/client/proc/get_admin_say()
	var/msg = tgui_input_text(src, null, "asay \"text\"", encode = FALSE) // we don't encode/sanitize here because cmd_admin_say does it anyways.
	cmd_admin_say(msg)

/client/proc/cmd_admin_say(msg as text)
	set category = "Adminbus"
	set name = "Asay" //Gave this shit a shorter name so you only have to time out "asay" rather than "admin say" to use it --NeoFite
	set hidden = 1
	if(!check_rights(0))
		return

	msg = emoji_parse(copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	mob.log_talk(msg, LOG_ASAY)
	msg = keywords_lookup(msg)

	var/asay_color_pref = (CONFIG_GET(flag/allow_admin_asaycolor) && prefs.read_player_preference(/datum/preference/choiced/asay_color)) || DEFAULT_ASAY_COLOR
	var/asay_cfc_format = asay_color_pref
	msg = "<span class='adminsay'><span class='prefix'>ADMIN:</span> <EM>[key_name(usr, 1)]</EM> [ADMIN_FLW(mob)]: <span class='[asay_cfc_format] message linkify'>[msg]</span>"
	to_chat(GLOB.admins, msg, allow_linkify = TRUE, type = MESSAGE_TYPE_ADMINCHAT)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Asay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
