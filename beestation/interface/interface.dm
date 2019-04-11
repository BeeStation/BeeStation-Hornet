/client/verb/donate()
	set name = "donate"
	set desc = "Donate to the server"
	set hidden = 1
	var/donateurl = CONFIG_GET(string/donateurl)
	if(donateurl)
		if(alert("This will open the Doantion page in your browser. Are you sure?",,"Yes","No")!="Yes")
			return
		src << link(donateurl)
	else
		to_chat(src, "<span class='danger'>The Donation URL is not set in the server configuration.</span>")
	return

/client/verb/discord()
	set name = "discord"
	set desc = "Join the Discord"
	set hidden = 1
	var/discordurl = CONFIG_GET(string/discordurl)
	if(discordurl)
		if(alert("This will open the Discord invite in your browser. Are you sure?",,"Yes","No")!="Yes")
			return
		src << link(discordurl)
	else
		to_chat(src, "<span class='danger'>The Discord invite is not set in the server configuration.</span>")
	return

/client/verb/map() // i couldn't be fucked to config-ize this
	set name = "map"
	set desc = "View the current map in the webviewer"
	set hidden = 1
	var/map_in_url
	switch(SSmapping.config?.map_name)
		if("Box Station")			map_in_url = "box"
		if("Delta Station")			map_in_url = "delta"
		if("Donutstation")			map_in_url = "donut"
		if("MetaStation")			map_in_url = "meta"
	if(map_in_url)
		if(alert("This will open the current map in your browser. Are you sure?",,"Yes","No")!="Yes")
			return
		src << link("http://beestation13.com/map/[map_in_url]")
	else
		to_chat(src, "<span class='danger'>The current map is either invalid or unavailable.</span>")