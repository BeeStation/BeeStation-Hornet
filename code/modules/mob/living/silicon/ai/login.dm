/mob/living/silicon/ai/Login()
	..()
	if(stat != DEAD)
		for(var/each in GLOB.ai_status_displays) //change status
			var/obj/machinery/status_display/ai/O = each
			O.mode = 1
			O.emotion = "Neutral"
			O.update()
	set_eyeobj_visible(TRUE)
	if(multicam_on)
		end_multicam()
	view_core()
	if(!login_warned_temp)
		to_chat(src, "<span class = 'userdanger'>Warning, the way AI is played has changed, please refer to https://github.com/BeeStation/BeeStation-Hornet/pull/6152</span>")
		login_warned_temp = TRUE
