/datum/antagonist/on_gain()
	..()
	greeting_popup()

/datum/antagonist/proc/greeting_popup()
	if (popup_title && owner && owner.current)
		var/body = "<h1 align='center' style='font-size: 35px;'>[popup_title]</h1><br>"
		body += "<div>Congratulations, you have been assigned to an antagonist role! For more information, scroll up in your chat.</div><br>"
		body += "<div>To view your objectives, either scroll up in chat, or use the <b>Notes</b> verb in the IC tab.</div><br>"
		body += "<div>If you are confused, feel free to ask an mentor or admin for help using the <b>Mentorhelp</b> or <b>Adminhelp</b> verb.</div><br>"
		if (wikilink)
			body += "<div><b>More in depth information about this antagonist role can be found <a href='?action=openLink&link=[url_encode(wikilink)]'>here</a></b></div>"
		var/datum/browser/popup = new(owner.current, "antagpopup-[REF(src)]", "<h1 align='center' style='font-size: 28px;'>Antagonist!</h1>", 700, 350)
		popup.set_content(body)
		popup.open(0)


/datum/antagonist
	var/wikilink
	var/popup_title = "You are an antagonist!"
/datum/antagonist/abductor
	wikilink = "https://tgstation13.org/wiki/Abductor"
	popup_title = "You are an abductor!"
/datum/antagonist/blob
	wikilink = "https://tgstation13.org/wiki/Blob"
	popup_title = "You are a blob!"
/datum/antagonist/brainwashed
	popup_title = "You are a brainwashed victim!"
/datum/antagonist/brother
	popup_title = "You are a blood brother!"
/datum/antagonist/changeling
	wikilink = "https://tgstation13.org/wiki/Changeling"
	popup_title = "You are a changeling!"
/datum/antagonist/clockcult
	wikilink = "https://tgstation13.org/wiki/Clockwork_Cult"
	popup_title = "You are a clockwork cultist!"
/datum/antagonist/obsessed
	wikilink = "https://tgstation13.org/wiki/Creep"
	popup_title = "You are a creep!"
/datum/antagonist/cult
	wikilink = "https://tgstation13.org/wiki/Cult"
	popup_title = "You are a cultist!"
/datum/antagonist/devil
	wikilink = "https://tgstation13.org/wiki/Devil"
	popup_title = "You are a devil!"
/datum/antagonist/disease
	wikilink = "https://tgstation13.org/wiki/Sentient_Disease"
	popup_title = "You are a sentient disease!"
/datum/antagonist/ert
	wikilink = "https://tgstation13.org/wiki/Emergency_Response_Team"
	popup_title = "You are an ERT member!"
/datum/antagonist/ert/deathsquad
	wikilink = "https://tgstation13.org/wiki/Deathsquad"
	popup_title = "You are a deathsquad member!"
/datum/antagonist/fugitive
  popup_title = "You are a fugitive!"
/datum/antagonist/highlander
	wikilink = "https://tgstation13.org/wiki/Highlander"
	popup_title = "You are a highlander!"
/datum/antagonist/hivemind
	wikilink = "https://tgstation13.org/wiki/Hivemind_Host"
	popup_title = "You are a hivemind host!"
/datum/antagonist/hivevessel
	wikilink = "https://tgstation13.org/wiki/Assimilation"
	popup_title = "You are a vessel!"
/datum/antagonist/monkey
	wikilink = "https://tgstation13.org/wiki/Monkey"
	popup_title = "You are a monkey!"
/datum/antagonist/monkey/leader
	popup_title = "You are a monkey leader!"
/datum/antagonist/ninja
	wikilink = "https://tgstation13.org/wiki/Ninja"
	popup_title = "You are a space ninja!"
/datum/antagonist/nukeop
	wikilink = "https://tgstation13.org/wiki/Nuclear_operatives"
	popup_title = "You are a nuclear operative!"
/datum/antagonist/nukeop/leader
	popup_title = "You are a nukeop leader!"
/datum/antagonist/official
	wikilink = "https://tgstation13.org/wiki/Centcom_Official"
	popup_title = "You are a Centcom official!"
/datum/antagonist/overthrow
	wikilink = "https://tgstation13.org/wiki/Overthrow"
	popup_title = "You are a syndicate agent!"
/datum/antagonist/pirate
	wikilink = "https://tgstation13.org/wiki/Pirate"
	popup_title = "You are a space pirate!"
/datum/antagonist/revenant
	wikilink = "https://tgstation13.org/wiki/Revenant"
	popup_title = "You are a revenant!"
/datum/antagonist/rev
	wikilink = "https://tgstation13.org/wiki/Revolution"
	popup_title = "You are a revolutionary!"
/datum/antagonist/santa
	popup_title = "You are santa!"
/datum/antagonist/separatist
	popup_title = "You are a seperatist!"
/datum/antagonist/slaughter
	wikilink = "https://tgstation13.org/wiki/Slaughter_Demon"
	popup_title = "You are a slaughter demon!"
/datum/antagonist/space_dragon
	popup_title = "You are a space dragon!"
/datum/antagonist/survivalist
	popup_title = "You are a survivalist!"
/datum/antagonist/traitor
	wikilink = "https://tgstation13.org/wiki/Traitor"
	popup_title = "You are a traitor!"
/datum/antagonist/traitor/internal_affairs
	popup_title = "You are an interal affairs agent!"
/datum/antagonist/heartbreaker
	popup_title = "You are madly in love!"
/datum/antagonist/wishgranter
	popup_title = "You are a wishgranter avatar!"
/datum/antagonist/wizard
	wikilink = "https://tgstation13.org/wiki/Wizard"
	popup_title = "You are a space wizard!"
