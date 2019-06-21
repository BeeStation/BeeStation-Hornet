//Floorbot
/mob/living/simple_animal/bot/turtle
	name = "\improper TurtleBot"
	desc = "A little programmable robot that looks like a turtle!"
	icon = 'icons/mob/aibots.dmi'
	icon_state = "turtlebot0"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	radio_key = /obj/item/encryptionkey/headset_rob
	radio_channel = RADIO_CHANNEL_SCIENCE
	bot_type = FLOOR_BOT
	model = "TurtleBot"
	bot_core = /obj/machinery/bot_core/turtle
	window_id = "autofloor"
	window_name = "QwertyTM TurtleBot v1.2"
	path_image_color = "#1B541C"

	var/obj/item/disk/turtle_cartridge/cartridge


/mob/living/simple_animal/bot/turtle/Initialize(mapload, new_toolbox_color)
	. = ..()


/mob/living/simple_animal/bot/turtle/turn_on()
	. = ..()
	update_icon()

/mob/living/simple_animal/bot/turtle/turn_off()
	..()
	update_icon()

/mob/living/simple_animal/bot/turtle/bot_reset()
	..()
	ignore_list = list()
	anchored = FALSE
	update_icon()

/mob/living/simple_animal/bot/turtle/set_custom_texts()
	text_hack = "You corrupt [name]'s sensory and mobility protocols."
	text_dehack = "You detect errors in [name] and reset his programming."
	text_dehack_fail = "[name] is not responding to reset commands!"

/mob/living/simple_animal/bot/turtle/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += "<TT><B>TurtleBot Controls v1.2</B></TT><BR><BR>"
	dat += "Status: <A href='?src=[REF(src)];power=1'>[on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [open ? "opened" : "closed"]<BR>"
	dat += "<B>Cartridge: </B>"
	if(cartridge)
		dat += "[cartridge.name]<BR>"
		dat += "<A href='?src=[REF(src)];operation=eject'>Eject</a> "
		dat += "<A href='?src=[REF(src)];operation=execute'>Execute</a> "
		dat += "<A href='?src=[REF(src)];operation=stop'>Stop</a><BR>"
	else
		dat += "No Cartridge Loaded<BR>"

	return dat

/mob/living/simple_animal/bot/turtle/attackby(obj/item/I , mob/user, params)
	if(istype(I, /obj/item/disk/turtle_cartridge))
		if(!cartridge)
			user.transferItemToLoc(I, src)
			cartridge = I
			cartridge.attach(src)
			to_chat(user, "<span class='notice'>You pop \the [cartridge.name] into \the [src.name]'s slot.</span>")
		else
			to_chat(user, "<span class='notice'>There is already a cartridge in \the [src.name]'s slot!</span>")
		return
	else
		..()

/mob/living/simple_animal/bot/turtle/Topic(href, href_list)
	if(..())
		return TRUE
	switch(href_list["operation"])
		if("eject")
			if(cartridge)
				cartridge.detach()
				cartridge.forceMove(drop_location())
				cartridge = null

		if("execute")
			if(cartridge && !cartridge.running)
				cartridge.execute()

		if("stop")
			if(cartridge && cartridge.running)
				cartridge.stop()

	update_controls()

/mob/living/simple_animal/bot/turtle/handle_automated_action()
	return

/mob/living/simple_animal/bot/turtle/update_icon()
	icon_state = "turtlebot[on]"


/mob/living/simple_animal/bot/turtle/call_mode()
	return
/mob/living/simple_animal/bot/turtle/patrol_step()
	return
/mob/living/simple_animal/bot/turtle/summon_step()
	return
/mob/living/simple_animal/bot/turtle/get_mode()
	return "<b>[cartridge.running ? "Running" : "Idle"]</b>"


/mob/living/simple_animal/bot/turtle/proc/beep(type)
	switch(type)
		if("error")
			playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE, -1)
		if("ping")
			playsound(src, 'sound/machines/chime.ogg', 50, TRUE, -1)
		if("start")
			playsound(src, 'sound/machines/twobeep.ogg', 50, TRUE, -1)
		if("stop")
			playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE, -1)



/obj/machinery/bot_core/turtle
	req_one_access = list(ACCESS_CONSTRUCTION, ACCESS_ROBOTICS)
