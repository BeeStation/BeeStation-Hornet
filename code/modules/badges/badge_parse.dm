/proc/badge_parse(text) //turns :badge: into a badge
	. = text
	if(!CONFIG_GET(flag/badges))
		return
	var/parsed = ""
	var/pos = 1
	var/search = 0
	var/badge = ""
	while(1)
		search = findtext(text, ":", pos)
		parsed += copytext(text, pos, search)
		if(search)
			pos = search
			search = findtext(text, ":", pos + length(text[pos]))
			if(search)
				badge = lowertext(copytext(text, pos + length(text[pos]), search))
				var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/goonchat)
				var/tag = sheet.icon_tag("badge-[badge]")
				if(tag)
					parsed += tag
					pos = search + length(text[pos])
				else
					parsed += copytext(text, pos, search)
					pos = search
				badge = ""
				continue
			else
				parsed += copytext(text, pos, search)
		break
	return parsed
