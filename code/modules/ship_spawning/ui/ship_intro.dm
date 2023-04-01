/atom/movable/screen/ship_intro
	alpha = 0
	maptext_width = 512
	maptext_height = 512
	maptext_x = -256
	var/did_move = 5
	var/static/list/displayed_clients = list()
	var/steps = 0
	var/full_text = "ERROR"
	var/mob/parent

/atom/movable/screen/ship_intro/Initialize(mapload, mob/parent)
	. = ..()
	if (parent.client in displayed_clients)
		return
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(client_moved))
	displayed_clients += parent.client

	full_text = "Welcome to BeeSHIP<s>ion</s>.\n\
\n\
You are %NAME%.\n\
The date is is [time2text(world.realtime, "DDD, Month DD")], [GLOB.year_integer+YEAR_OFFSET].\n\
After conducting several unremarkable tests on bluespace-based materials, anomalous\n\
properties were observed. Nanotrasenkept quiet on these discoveries\n\
and proceeded forward with their research on these anomalous\n\
behaviours.\n\
One of the main resources that exhibit anomalous properties is Crilium, a highly reactive\n\
material that leads to electromagenetic disruptions and explosions when exposed to oxygen.\n\
Nanotrasen's rivals believed that Nanotrasen was researching anomalous materials in order\n\
to create unstoppable military weaponry.\n\
After an extensive legal battle, Nanotrasen was forced to move their operations into an\n\
ungoverned sector outside the reach of most modern vessels.\n\
Nanotrasen began swiftly shutting down its opposition in this sector. Their rival\n\
corporations seized this opportunity to form a coalition with the specific goals\n\
to bring down Nanotrasen and force them out of the sector.\n\
This coalition was known as The Syndicate.\n\
\n\
You are now in this world and doing stuff and fighting or something, I don't\n\
really care, just have fun.\n\
You can use the lathes and circuit printers at the bases to make\n\
more weapons and ammunition, mining can be done on asteroids or on lavaland.\n\
\n\
Also in this world killing corgis is like, super illegal and you will get erased\n\
from reality if anybody finds out."
	START_PROCESSING(SSfastprocess, src)
	animate(src, alpha=255, time=30)
	src.parent = parent
	full_text = replacetext(full_text, "%NAME%", parent.name)

/atom/movable/screen/ship_intro/proc/client_moved()
	did_move --

/atom/movable/screen/ship_intro/Destroy()
	. = ..()
	parent = null

/atom/movable/screen/ship_intro/process(delta_time)
	steps += did_move <= 0 ? 30 : 5
	var/display_text = copytext(full_text, 1, steps)
	maptext = "<span class='maptext center big'>[display_text]</span>"
	maptext_y = 0
	for (var/i in 1 to length(display_text))
		if (display_text[i] == "\n")
			maptext_y -= 13
	if (steps > length(full_text))
		STOP_PROCESSING(SSfastprocess, src)
		animate(src, time=5 SECONDS)
		animate(alpha=0, time=5 SECONDS)
		return
