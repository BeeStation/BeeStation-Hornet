
#define GRAVITATIONAL_CONSTANT 1

//Once the acceleration towards this object is smaller than this value, it will be ignored.
#define MINIMUM_EFFECTIVE_GRAVITATIONAL_ACCEELRATION 0.0001

#define ORBITAL_UPDATE_RATE (1 SECONDS)	//10 stupidseconds
#define ORBITAL_UPDATE_RATE_SECONDS 1	//1 second
#define ORBITAL_UPDATES_PER_SECOND 1	//1 per second

#define PRIMARY_ORBITAL_MAP "primary"

//Orbital map collision detection
//Objects cannot have a radius greater than this value /3 without refactoring.
#define ORBITAL_MAP_ZONE_SIZE 600		//The size of a collision detection zone on an orbital map.

//Vector position updates
#define MOVE_ORBITAL_BODY(body_to_move, new_x, new_y) \
	do {\
		var/prev_x = body_to_move.position.x;\
		var/prev_y = body_to_move.position.y;\
		body_to_move.position.x = new_x;\
		body_to_move.position.y = new_y;\
		var/datum/orbital_map/attached_map = SSorbits.orbital_maps[body_to_move.orbital_map_index];\
		attached_map.on_body_move(body_to_move, prev_x, prev_y);\
	} while (FALSE)

//Collision flags
#define COLLISION_UNDEFINED (1 << 0) //Default flag
#define COLLISION_SHUTTLES (1 << 1)	//Shuttle collision flag
#define COLLISION_Z_LINKED (1 << 2)	//Z linked collision flag
#define COLLISION_METEOR (1 << 3) //Meteor collisions

//Render modes
//These are defined in OrbitalMapSvg.js
//Its much better to have the defines on the javascript so we don't have to constantly send it across every update.
#define RENDER_MODE_DEFAULT "default"			//Classic white circle with a velocity line
#define RENDER_MODE_PLANET "planet"				//Filled circle
#define RENDER_MODE_BEACON "beacon"				//Some kind of beacon type thing?
#define RENDER_MODE_SHUTTLE "shuttle"			//Maybe a green square with heading line + line indicating where it came from
#define RENDER_MODE_PROJECTILE "projectile"		//No circle, just a straight, short velocity line.
