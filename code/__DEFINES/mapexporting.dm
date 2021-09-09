//Bits to save
#define SAVE_OBJECTS (1 << 1)		//Save objects?
#define SAVE_MOBS (1 << 2)			//Save Mobs?
#define SAVE_TURFS (1 << 3)			//Save turfs?
#define SAVE_AREAS (1 << 4)			//Save areas?
#define SAVE_SPACE (1 << 5)			//Save space areas? (If not they will be saved as NOOP)
#define SAVE_OBJECT_PROPERTIES (1 << 6)	//Save custom properties of objects (obj.on_object_saved() output)
#define SAVE_UNSAFE_OBJECTS (1<<7)	//Bypass basic object safety checks allowing saving indestructible, traitor items etc.
#define SAVE_INDESTRUCTABLE (1 << 8)//Allow indestructible items to be saved?
#define SAVE_ADMINEDITTED (1 << 9)	//Allow items spawned by admins / editted by admins to be saved

#define SAVE_DEFAULT SAVE_OBJECTS | SAVE_TURFS | SAVE_AREAS | SAVE_OBJECT_PROPERTIES
#define SAVE_ADMIN SAVE_OBJECTS | SAVE_MOBS | SAVE_TURFS | SAVE_AREAS | SAVE_OBJECT_PROPERTIES | SAVE_ADMINEDITTED | SAVE_UNSAFE_OBJECTS | SAVE_INDESTRUCTABLE

//Don't really care about shuttles. Will save their turfs and data even if not part. Dont use this?
#define SAVE_SHUTTLEAREA_DONTCARE 0
//Will completely ignore anything in a shuttle area
#define SAVE_SHUTTLEAREA_IGNORE 1
//Will completely ignore anything not in a shuttle area
#define SAVE_SHUTTLEAREA_ONLY 2

//What types variables should be
#define MAPEXPORTER_VAR_NUM 1		//Must be a number
#define MAPEXPORTER_VAR_STRING 2	//Must be a string
#define MAPEXPORTER_VAR_TYPEPATH 3	//Must be a typepath
#define MAPEXPORTER_VAR_ACCESS_LIST 4	//Converts req_access to req_access_txt. (ADDS _TXT TO THE END OF THE VAR NAME)
#define MAPEXPORTER_VAR_COLOUR 5	//Value must be of format "#FFF" or "#FFFFFF"
