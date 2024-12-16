
/*

Contents:
- Stealth Verbs

*/

/obj/item/clothing/suit/space/space_ninja/proc/stealth()
	affecting.say(pick(\
		"Watch your back...",\
		"They never see me coming.",\
		"Don't drop your guard.",\
		"Knowing is half the battle.",\
		"See you soon...",\
		"Be seeing you.",\
		"Not if I see you first.",\
		"Can't hit what you can't see.",\
		"Behind you..."\
	))
	affecting.transfer_messages_to(get_turf(affecting))
	for (var/obj/machinery/light/light in view(7, affecting))
		light.break_light_tube()
	var/datum/effect_system/smoke_spread/smoke = new()
	smoke.set_up(3, affecting.loc)
	smoke.start()
	playsound(affecting.loc, 'sound/effects/bamf.ogg', 50, 2)
	s_coold = 2
	animate(affecting, time = 1 SECONDS, alpha = 0)
	affecting.apply_status_effect(/datum/status_effect/cloaked)
