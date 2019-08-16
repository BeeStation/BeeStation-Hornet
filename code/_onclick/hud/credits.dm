#define CREDIT_ROLL_SPEED 115
#define CREDIT_SPAWN_SPEED 8
#define CREDIT_ANIMATE_HEIGHT (13 * world.icon_size)
#define CREDIT_EASE_DURATION 20

GLOBAL_LIST(end_titles)

/client/proc/RollCredits()
	set waitfor = FALSE
	if(!GLOB.end_titles)
		GLOB.end_titles = SSticker.mode.generate_credit_text()
		GLOB.end_titles += "<center><h1>Thanks for playing!</h1>"
	LAZYINITLIST(credits)
	var/list/_credits = credits
	verbs += /client/proc/ClearCredits
	_credits += new /obj/screen/credit/title_card(null, null, src, SSticker.mode.title_icon)
	sleep(CREDIT_SPAWN_SPEED * 3)
	for(var/I in GLOB.end_titles)
		if(!credits)
			return
		_credits += new /obj/screen/credit(null, I, src)
		sleep(CREDIT_SPAWN_SPEED)
	sleep(CREDIT_ROLL_SPEED - CREDIT_SPAWN_SPEED)
	ClearCredits()
	verbs -= /client/proc/ClearCredits

/client/proc/ClearCredits()
	set name = "Hide Credits"
	set category = "OOC"
	verbs -= /client/proc/ClearCredits
	QDEL_LIST(credits)

/obj/screen/credit
	icon_state = "blank"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 0
	screen_loc = "2,2"
	layer = SPLASHSCREEN_LAYER
	var/client/parent
	var/matrix/target

/obj/screen/credit/Initialize(mapload, credited, client/P)
	. = ..()
	parent = P
	maptext = credited
	maptext_height = world.icon_size * 2
	maptext_width = world.icon_size * 13
	var/matrix/M = matrix(transform)
	M.Translate(0, CREDIT_ANIMATE_HEIGHT)
	animate(src, transform = M, time = CREDIT_ROLL_SPEED)
	target = M
	animate(src, alpha = 255, time = CREDIT_EASE_DURATION, flags = ANIMATION_PARALLEL)
	spawn(CREDIT_ROLL_SPEED - CREDIT_EASE_DURATION)//addtimer doesn't work for more time-critical operations
		FadeOut()
	QDEL_IN(src, CREDIT_ROLL_SPEED)
	P.screen += src

/obj/screen/credit/Destroy()
	var/client/P = parent
	if(parent)
		P.screen -= src
	LAZYREMOVE(P.credits, src)
	parent = null
	return ..()

/obj/screen/credit/proc/FadeOut()
	animate(src, alpha = 0, transform = target, time = CREDIT_EASE_DURATION)

/obj/screen/credit/title_card
	icon = 'icons/title_cards.dmi'
	screen_loc = "4,1"

/obj/screen/credit/title_card/Initialize(mapload, credited, client/P, title_icon_state)
	icon_state = title_icon_state
	. = ..()
	maptext = null

/* CURSE YOU BYOND, LET ME DO HTTPS REQUESTS
/proc/get_patrons()
	var/list/patrons = list()
	var/list/http[] = world.Export("https://www.patreon.com/api/campaigns/[]/pledges?include=patron.null")

	if (http)
		var/status = text2num(http["STATUS"])

		if (status == 200)
			var/response = json_decode(file2text(http["CONTENT"]))
			if (response)
				for(var/item in response["included"])
					if(item["type"] == "user")
						patrons |= user["attributes"]["full_name"]

	return patrons.len ? patrons : null
*/
