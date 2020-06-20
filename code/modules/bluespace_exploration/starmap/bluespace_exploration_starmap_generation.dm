#define STARMAP_CELLS 9
#define STARMAP_GRID_SIZE 100
#define DIRECTIONS_X list(0, 1, 0, -1)
#define DIRECTIONS_Y list(1, 0, -1, 0)

//We could use the regex below if we want to check formatting, however if coded right there should never be errors. Nevertheless, this is SUPER important otherwise BS exploration breaks entirely.
//[0-9]*_[0-9]*

/datum/controller/subsystem/bluespace_exploration/proc/generate_starmap()
	//Generate the starmap
	var/list/stars_to_process = list()
	var/list/stars_to_place = list()
	var/sanity = 101
	//Place the starting star
	var/datum/star_system/first_star = new
	first_star.name = "Srolnar-13"	//TODO: Add this to config <3
	first_star.is_station_z = TRUE	//Tell it not to generate shit
	stars_to_process["5_5"] += first_star
	current_system = first_star
	//============Make stars===========
	while(sanity > 0 && LAZYLEN(stars_to_process))
		sanity --
		var/star_coords = stars_to_process[1]
		if(prob(55) || stars_to_place.len < 5)
			stars_to_place[star_coords] = stars_to_process[star_coords]
		var/current_x = text2num(splittext(star_coords, "_")[1])
		var/current_y = text2num(splittext(star_coords, "_")[2])
		for(var/i in 1 to 4)
			var/x_offset = DIRECTIONS_X[i] + current_x
			var/y_offset = DIRECTIONS_Y[i] + current_y
			if("[x_offset]_[y_offset]" in stars_to_process)
				continue
			stars_to_process["[x_offset]_[y_offset]"] = new /datum/star_system
		stars_to_process -= star_coords
	//===========Place stars===========
	for(var/star in stars_to_place)
		var/datum/star_system/SS = stars_to_place[star]
		var/current_x = text2num(splittext(star, "_")[1])
		var/current_y = text2num(splittext(star, "_")[2])
		SS.map_x = (current_x * STARMAP_G`RID_SIZE) + rand(0, STARMAP_GRID_SIZE)
		SS.map_y = (current_y * STARMAP_GRID_SIZE) + rand(0, STARMAP_GRID_SIZE)
		SSbluespace_exploration.star_systems += SS
	//===========Generate Links===========
	//! THIS REQUIRES THE LINK POSITIONS TO BE SET UP FIRST TO WORK
	for(var/star in stars_to_place)
		var/datum/star_system/SS = stars_to_place[star]
		var/current_x = text2num(splittext(star, "_")[1])
		var/current_y = text2num(splittext(star, "_")[2])
		//Connect to surrounding stars
		for(var/i in 1 to 4)
			var/x_offset = DIRECTIONS_X[i] + current_x
			var/y_offset = DIRECTIONS_Y[i] + current_y
			if(!("[x_offset]_[y_offset]" in stars_to_place))
				continue
			SS.linked_stars |= stars_to_place["[x_offset]_[y_offset]"]
			//Create star links if the star we are linked to isn't already linked with us
			var/datum/star_system/connected_system = stars_to_place["[x_offset]_[y_offset]"]
			if(!(SS in connected_system.linked_stars))
				//=====Create a new link=====
				var/datum/star_link/SL = new
				SL.x1 = SS.map_x
				SL.y1 = SS.map_y
				SL.x2 = connected_system.map_x
				SL.y2 = connected_system.map_y
				connected_system.linked_stars += SS
				SSbluespace_exploration.star_links += SL
	message_admins("Successfully generated [LAZYLEN(SSbluespace_exploration.star_systems)] star systems.")

#undef DIRECTIONS_X
#undef DIRECTIONS_Y
#undef STARMAP_GRID_SIZE
#undef STARMAP_CELLS
