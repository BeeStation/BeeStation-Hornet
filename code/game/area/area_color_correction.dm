#define PRIORITY_LOW 1000

/*
	colour vs color
*/

/mob
	var/current_correction

/datum/client_colour/area_color
	colour = ""
	priority = PRIORITY_LOW
	fade_in = 15
	fade_out = 15

//Warm-ish
/datum/client_colour/area_color/warm_ish
	colour = list(rgb(255, 0, 0), rgb(3, 252, 0), rgb(5, 0, 250))
//Warm
/datum/client_colour/area_color/warm
	colour = list(rgb(255, 0, 0), rgb(5, 250, 0), rgb(7, 0, 248))
//Cold-ish
/datum/client_colour/area_color/cold_ish
	colour = list(rgb(250, 0, 5), rgb(0, 252, 3), rgb(0, 0, 255))
//Cold
/datum/client_colour/area_color/cold
	colour = list(rgb(245, 0, 10), rgb(0, 250, 5), rgb(0, 0, 255))
//Cold-purple
/datum/client_colour/area_color/cold_purple
	colour = list(rgb(250, 0, 5), rgb(3, 252, 5), rgb(3, 0, 255)) //actually coldish
//Warm-yellow
/datum/client_colour/area_color/warm_yellow
	colour = list(rgb(255, 5, 0), rgb(10, 245, 0), rgb(5, 5, 245))
//Clown
/datum/client_colour/area_color/clown
	colour = list(rgb(0, 0, 255), rgb(255, 0, 0), rgb(0, 255, 0))

#undef PRIORITY_LOW
