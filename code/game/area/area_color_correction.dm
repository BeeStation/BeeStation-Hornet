#define PRIORITY_ABSOLUTE 1
#define PRIORITY_HIGH 10
#define PRIORITY_NORMAL 100
#define PRIORITY_LOW 1000

/*
	colour vs color
*/

/mob
	var/current_correction

/datum/client_colour/area_color
	colour = ""
	priority = PRIORITY_LOW
	fade_in = 10
	fade_out = 10

//Warm-ish
/datum/client_colour/area_color/warm_ish
	colour = list(rgb(255, 0, 0), rgb(3, 253, 0), rgb(5, 0, 250))
//Warm
/datum/client_colour/area_color/warm
	colour = list(rgb(255, 0, 0), rgb(5, 250, 0), rgb(7, 0, 248))
//Cold
/datum/client_colour/area_color/cold
	colour = list(rgb(245, 0, 10), rgb(0, 250, 5), rgb(0, 0, 255))
//Clown
/datum/client_colour/area_color/clown
	colour = list(rgb(255, 0, 255), rgb(255, 255, 0), rgb(0, 255, 255))

#undef PRIORITY_ABSOLUTE
#undef PRIORITY_HIGH
#undef PRIORITY_NORMAL
#undef PRIORITY_LOW
