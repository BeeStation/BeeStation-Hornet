/mob/dead/observer/Logout()
	update_z(null)
	if (client)
		client.images -= (GLOB.ghost_images_default+GLOB.ghost_images_simple)
		client.tgui_panel?.clear_dead_popup()

	if(observetarget)
		if(ismob(observetarget))
			var/mob/target = observetarget
			if(target.observers)
				target.observers -= src
				UNSETEMPTY(target.observers)
			observetarget = null
	..()
	// This is one of very few spawn()s left in our codebase
	// Yes it needs to be like this
	// No, you're not allowed to use spawn() yourself, unless you're making something that needs to work outside timers
	// Don't be a dumbass, I will always be watching
	spawn(0)
		if(src && !key)	//we've transferred to another mob. This ghost should be deleted.
			qdel(src)
