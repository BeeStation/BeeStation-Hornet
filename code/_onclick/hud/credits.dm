#define CREDIT_ROLL_SPEED 60
#define CREDIT_SPAWN_SPEED 4
#define CREDIT_ANIMATE_HEIGHT (16 * world.icon_size) //13 would cause credits to get stacked at the top of the screen, so we let them go past the top edge
#define CREDIT_EASE_DURATION 12

GLOBAL_LIST(end_titles)

/proc/RollCredits()
	set waitfor = FALSE
	if(!GLOB.end_titles)
		GLOB.end_titles = SSticker.mode.generate_credit_text()
		GLOB.end_titles += "<br>"
		GLOB.end_titles += "<br>"

		if(GLOB.patrons.len)
			GLOB.end_titles += "<center><h1>Thank you to our patrons!</h1>"
			for(var/patron in GLOB.patrons)
				GLOB.end_titles += "<center><h2>[sanitize(patron)]</h2>"
			GLOB.end_titles += "<br>"
			GLOB.end_titles += "<br>"

		var/list/contribs = get_contribs()
		if(contribs.len)
			GLOB.end_titles += "<center><h1>Top Code Contributors</h1>"
			for(var/contrib in contribs)
				GLOB.end_titles += "<center><h2>[sanitize(contrib)]</h2>"
			GLOB.end_titles += "<br>"
			GLOB.end_titles += "<br>"

		GLOB.end_titles += "<center><h1>Thanks for playing!</h1>"
	for(var/client/C in GLOB.clients)
		if(C.prefs.show_credits)
			C.screen += new /atom/movable/screen/credit/title_card(null, null, SSticker.mode.title_icon)
	sleep(CREDIT_SPAWN_SPEED * 3)
	for(var/i in 1 to GLOB.end_titles.len)
		var/C = GLOB.end_titles[i]
		if(!C)
			continue

		create_credit(C)
		sleep(CREDIT_SPAWN_SPEED)


/proc/create_credit(credit)
	new /atom/movable/screen/credit(null, credit)

/atom/movable/screen/credit
	icon_state = "blank"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 0
	screen_loc = "2,2"
	layer = SPLASHSCREEN_LAYER
	var/matrix/target

/atom/movable/screen/credit/Initialize(mapload, credited)
	. = ..()
	maptext = MAPTEXT("<font face='Verdana'>[credited]</font>")
	maptext_height = world.icon_size * 2
	maptext_width = world.icon_size * 13
	var/matrix/M = matrix(transform)
	M.Translate(0, CREDIT_ANIMATE_HEIGHT)
	animate(src, transform = M, time = CREDIT_ROLL_SPEED)
	target = M
	animate(src, alpha = 255, time = CREDIT_EASE_DURATION, flags = ANIMATION_PARALLEL)
	INVOKE_ASYNC(src, .proc/add_to_clients)
	QDEL_IN(src, CREDIT_ROLL_SPEED)

/atom/movable/screen/credit/proc/add_to_clients()
	for(var/client/C in GLOB.clients)
		if(C.prefs.show_credits)
			C.screen += src

/atom/movable/screen/credit/Destroy()
	screen_loc = null
	return ..()

/atom/movable/screen/credit/title_card
	icon = 'icons/title_cards.dmi'
	screen_loc = "4,1"

/atom/movable/screen/credit/title_card/Initialize(mapload, credited, title_icon_state)
	icon_state = title_icon_state
	. = ..()
	maptext = null

/proc/get_contribs()
	var/list/contribs = list()

	if(fexists("[global.config.directory]/contributors.txt"))
		contribs += world.file2list("[global.config.directory]/contributors.txt")

	if(length(contribs) > 20)
		contribs.Cut(21)

	return contribs
