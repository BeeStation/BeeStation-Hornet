//spider webs
/datum/mutation/webbing
	name = "Webbing Production"
	desc = "Allows the user to lay webbing, and travel through it."
	quality = POSITIVE
	instability = 15
	power_path = /datum/action/spell/lay_genetic_web

// In the future this could be unified with the spider's web action
/datum/action/spell/lay_genetic_web
	name = "Lay Web"
	desc = "Drops a web. Only you will be able to traverse your web easily, making it pretty good for keeping you safe."
	button_icon = 'icons/hud/actions/actions_animal.dmi'
	button_icon_state = "lay_web"
	mindbound = FALSE
	cooldown_time = 4 SECONDS //the same time to lay a web
	spell_requirements = NONE

	/// How long it takes to lay a web
	var/webbing_time = 4 SECONDS
	/// The path of web that we create
	var/web_path = /obj/structure/spider/stickyweb

/datum/action/spell/lay_genetic_web/on_cast(mob/user, atom/target)
	var/turf/web_spot = user.loc
	if(!isturf(web_spot) || (locate(web_path) in web_spot))
		to_chat(user, ("<span class='warning'>You can't lay webs here!</span>"))
		reset_spell_cooldown()
		return FALSE

	user.visible_message(
		("<span class='notice'>[user] begins to secrete a sticky substance.</span>"),
		("<span class='notice'>You begin to lay a web.</span>"),
	)

	if(!do_after(user, webbing_time, target = web_spot))
		to_chat(user, ("<span class='warning'>Your web spinning was interrupted!</span>"))
		return

	new web_path(web_spot, user)
	return ..()
