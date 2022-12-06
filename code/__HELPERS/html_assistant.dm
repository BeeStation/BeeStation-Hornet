/// returns a text after replacing wiki square brackets blacket in a given text into clickable wiki hyperlink
/proc/encode_wiki_link(text_value)
	// replaces [[ ]] into wiki link format
	// "you need to [[guide_to_chemisty read this guide]] please."" will become
	// "you need to <a href='wiki://guide_to_chemisty'>read this guide</a> please."
	var/opencut = findtext(text_value, "\[\[")
	while(opencut)
		var/list/stacker = list()
		stacker += copytext(text_value, 1, opencut)       // >> "you need to
		text_value = splicetext(text_value, 1, opencut+1) // >> [[guide_to_chemisty read this guide]] please."
		var/spacecut = findtext(text_value, " ")
		var/closecut = findtext(text_value, "\]\]")

		// if `spacecut > closecut`, it's [[wikipage]]. if not, it's [[wikipage something long text]]
		var/text_url = spacecut > closecut || !spacecut ? copytext(text_value, 2, closecut) : copytext(text_value, 2, spacecut) // "guide_to_chemisty"
		var/text_clicker = replacetext(spacecut > closecut || !spacecut ? text_url : copytext(text_value, spacecut+1, closecut), "_", " ") // "read this guide"
		stacker += OPEN_WIKI(text_url, text_clicker)  // replace [[ ]] wapper in text_value to hyperlink
		stacker += copytext(text_value, closecut+2)       // >> please."

		text_value = jointext(stacker, "")    // result >> "you need to <a>read this guys</a> please."
		opencut = findtext(text_value, "\[\[")
	return text_value
