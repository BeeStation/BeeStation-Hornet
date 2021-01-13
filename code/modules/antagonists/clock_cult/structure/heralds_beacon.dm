/obj/structure/destructible/clockwork/heralds_beacon
	name = "\improper Herald's Beacon"
	desc = "A spire with a strange eldritch energy pulsating around the sides. Legend has it that this is used by servant's of Rat'Var to call upon their deity granting them an immense amount of power."
	icon_state = "stargazer"
	resistance_flags = INDESTRUCTIBLE
	var/used = FALSE
	var/vote_active = FALSE
	var/vote_timer
	var/obj/effect/stargazer_light/light

/obj/structure/destructible/clockwork/heralds_beacon/Initialize()
	. = ..()
	light = new get_turf(src)

/obj/structure/destructible/clockwork/heralds_beacon/attack_hand(mob/user)
	. = ..()
	if(!is_servant_of_ratvar(user))
		return
	if(vote_active)
		deltimer(vote_timer)
		vote_timer = null
		vote_active = FALSE
		light.icon_state = "stargazer_closed"
		light.flick("stargazer_closing")
		hierophant_message("Power surge resolved, [user] has deactivated Herald's Beacon.")
		return
	if(used)
		to_chat(user, "<span class='brass'>Caution: Device in an unusable state.</span>")
		return
	var/option = alert(user,"Are you sure you want to call upon Herald and make your presence known to the station?",,"Yes","No")
	if(option == "No")
		to_chat(user, "<span class='brass'>You think better than to play with powers outside your control.</span>")
		return
	light.icon_state = "stargazer_light"
	light.flick("stargazer_opening")
	hierophant_message("[user] has opted to use the Herald's beacon which will alert the crew to your presence. Interact with the beacon to disable.", span = "<span class='large_brass'>")
	vote_timer = addtimer(CALLBACK(src, .proc/vote_succeed), 60 SECONDS, TIMER_STOPPABLE)
	vote_active = TRUE

/obj/structure/destructible/clockwork/heralds_beacon/proc/vote_succeed(mob/eminence)
	vote_active = FALSE
	used = TRUE
	hierophant_message("The Herald's beacon has been activated!", span = "<span class='large_brass'>")
	light.icon_state = "stargazer_closed"
		light.flick("stargazer_closing")
	new /obj/effect/temp_visual/ratvar/judicial_explosion(get_turf(src))
	sleep(12.6)
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/gateway = GLOB.celestial_gateway
	gateway.declare_war()

/obj/effect/stargazer_light
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "stargazer_closed"
	pixel_y = 10
	layer = FLY_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 160
