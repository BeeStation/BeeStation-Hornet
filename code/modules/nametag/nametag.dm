/atom/proc/instantiate_nametag(client/C)
	maptext_width = 128
	maptext_height = 64
	maptext_y = 24
	maptext_x = -48 // for some reason lol
	maptext = "<center><span class='chatOverhead' style='color: yellow;'>[C.key]</span></center>"

/atom/proc/dismiss_nametag()
	if(!nametag)
		return
	maptext = null