//Space Ruin Parents

/area/ruin/space
	default_gravity = ZERO_GRAVITY
	area_flags = UNIQUE_AREA

/area/ruin/space/has_grav
	default_gravity = STANDARD_GRAVITY

/area/ruin/space/has_grav/powered
	requires_power = FALSE

/////////////

/area/ruin/space/way_home
	name = "\improper Salvation"
	always_unpowered = FALSE

// Ruins of "onehalf" ship

/area/ruin/space/has_grav/onehalf/hallway
	name = "\improper Hallway"

/area/ruin/space/has_grav/onehalf/drone_bay
	name = "\improper Mining Drone Bay"

/area/ruin/space/has_grav/onehalf/dorms_med
	name = "\improper Crew Quarters"

/area/ruin/space/has_grav/onehalf/bridge
	name = "\improper Bridge"

/area/ruin/space/has_grav/powered/dinner_for_two
	name = "Dinner for Two"

/area/ruin/space/has_grav/powered/cat_man
	name = "\improper Kitty Den"

/area/ruin/space/has_grav/powered/authorship
	name = "\improper Authorship"

/area/ruin/space/has_grav/powered/aesthetic
	name = "Aesthetic"
	ambientsounds = list('sound/ambience/ambivapor1.ogg')


//Ruin of Hotel

/area/ruin/space/has_grav/hotel
	name = "\improper Hotel"

/area/ruin/space/has_grav/hotel/guestroom
	name = "\improper Hotel Guest Room"

/area/ruin/space/has_grav/hotel/guestroom/room_1
	name = "\improper Hotel Guest Room 1"

/area/ruin/space/has_grav/hotel/guestroom/room_2
	name = "\improper Hotel Guest Room 2"

/area/ruin/space/has_grav/hotel/guestroom/room_3
	name = "\improper Hotel Guest Room 3"

/area/ruin/space/has_grav/hotel/guestroom/room_4
	name = "\improper Hotel Guest Room 4"

/area/ruin/space/has_grav/hotel/guestroom/room_5
	name = "\improper Hotel Guest Room 5"

/area/ruin/space/has_grav/hotel/guestroom/room_6
	name = "\improper Hotel Guest Room 6"

/area/ruin/space/has_grav/hotel/security
	name = "\improper Hotel Security Post"

/area/ruin/space/has_grav/hotel/pool
	name = "\improper Hotel Pool Room"

/area/ruin/space/has_grav/hotel/bar
	name = "\improper Hotel Bar"

/area/ruin/space/has_grav/hotel/power
	name = "\improper Hotel Power Room"

/area/ruin/space/has_grav/hotel/custodial
	name = "\improper Hotel Custodial Closet"

/area/ruin/space/has_grav/hotel/shuttle
	name = "\improper Hotel Shuttle"
	requires_power = FALSE

/area/ruin/space/has_grav/hotel/dock
	name = "\improper Hotel Shuttle Dock"

/area/ruin/space/has_grav/hotel/workroom
	name = "\improper Hotel Staff Room"

/area/ruin/space/has_grav/hotel/secondary_solars
	name = "Hotel Secondary Solar Control"

//Ruin of Derelict Oupost

/area/ruin/space/has_grav/derelictoutpost
	name = "\improper Derelict Outpost"

/area/ruin/space/has_grav/derelictoutpost/cargostorage
	name = "\improper Derelict Outpost Cargo Storage"

/area/ruin/space/has_grav/derelictoutpost/cargobay
	name = "\improper Derelict Outpost Cargo Bay"

/area/ruin/space/has_grav/derelictoutpost/powerstorage
	name = "\improper Derelict Outpost Power Storage"

/area/ruin/space/has_grav/derelictoutpost/dockedship
	name = "\improper Derelict Outpost Docked Ship"

//Ruin of turretedoutpost

/area/ruin/space/has_grav/turretedoutpost
	name = "\improper Turreted Outpost"


//Ruin of old teleporter

/area/ruin/space/oldteleporter
	name = "\improper Old Teleporter"


//Ruin of mech transport

/area/ruin/space/has_grav/powered/mechtransport
	name = "\improper Mech Transport"


//Ruin of gas the lizard

/area/ruin/space/has_grav/gasthelizard
	name = "Gas the lizard"


//Ruin of Deep Storage

/area/ruin/space/has_grav/deepstorage
	name = "Deep Storage"
	camera_networks = list(CAMERA_NETWORK_BUNKER)

/area/ruin/space/has_grav/deepstorage/airlock
	name = "\improper Deep Storage Airlock"

/area/ruin/space/has_grav/deepstorage/power
	name = "\improper Deep Storage Power and Atmospherics Room"

/area/ruin/space/has_grav/deepstorage/hydroponics
	name = "Deep Storage Hydroponics"

/area/ruin/space/has_grav/deepstorage/armory
	name = "\improper Deep Storage Secure Storage"

/area/ruin/space/has_grav/deepstorage/storage
	name = "\improper Deep Storage Storage"

/area/ruin/space/has_grav/deepstorage/dorm
	name = "\improper Deep Storage Dormitory"

/area/ruin/space/has_grav/deepstorage/kitchen
	name = "\improper Deep Storage Kitchen"

/area/ruin/space/has_grav/deepstorage/crusher
	name = "\improper Deep Storage Recycler"


//Ruin of Abandoned Zoo

/area/ruin/space/has_grav/abandonedzoo
	name = "\improper Abandoned Zoo"


//Ruin of ancient Space Station

/area/ruin/space/ancientstation
	name = "Charlie Station Main Corridor"
	icon_state = "green"

/area/ruin/space/ancientstation/powered
	name = "Powered Tile"
	icon_state = "teleporter"
	requires_power = FALSE

/area/ruin/space/ancientstation/space
	name = "Exposed To Space"
	icon_state = "teleporter"
	default_gravity = ZERO_GRAVITY

/area/ruin/space/ancientstation/atmo
	name = "Beta Station Atmospherics"
	icon_state = "red"
	default_gravity = ZERO_GRAVITY
	ambience_index = AMBIENCE_ENGI

/area/ruin/space/ancientstation/betanorth
	name = "Beta Station North Corridor"
	icon_state = "blue"

/area/ruin/space/ancientstation/solar
	name = "Station Solar Array"
	icon_state = "panelsAP"

/area/ruin/space/ancientstation/engi
	name = "Charlie Station Engineering"
	icon_state = "engine"
	ambience_index = AMBIENCE_ENGI

/area/ruin/space/ancientstation/comm
	name = "Charlie Station Command"
	icon_state = "captain"

/area/ruin/space/ancientstation/hydroponics
	name = "Charlie Station Hydroponics"
	icon_state = "garden"

/area/ruin/space/ancientstation/kitchen
	name = "Charlie Station Kitchen"
	icon_state = "kitchen"

/area/ruin/space/ancientstation/sec
	name = "Charlie Station Security"
	icon_state = "red"

/area/ruin/space/ancientstation/deltacorridor
	name = "Delta Station Main Corridor"
	icon_state = "green"

/area/ruin/space/ancientstation/proto
	name = "Delta Station Prototype Lab"
	icon_state = "toxlab"

/area/ruin/space/ancientstation/rnd
	name = "Delta Station Research and Development"
	icon_state = "toxlab"

/area/ruin/space/ancientstation/hivebot
	name = "Hivebot Mothership"
	icon_state = "teleporter"

//DERELICT

/area/ruin/space/derelict
	name = "\improper Derelict Station"

/area/ruin/space/derelict/hallway/primary
	name = "\improper Derelict Primary Hallway"

/area/ruin/space/derelict/hallway/secondary
	name = "\improper Derelict Secondary Hallway"

/area/ruin/space/derelict/hallway/primary/port
	name = "\improper Derelict Port Hallway"

/area/ruin/space/derelict/arrival
	name = "\improper Derelict Arrival Centre"

/area/ruin/space/derelict/storage/equipment
	name = "\improper Derelict Equipment Storage"

/area/ruin/space/derelict/bridge
	name = "\improper Derelict Control Room"

/area/ruin/space/derelict/bridge/access
	name = "\improper Derelict Control Room Access"

/area/ruin/space/derelict/bridge/ai_upload
	name = "\improper Derelict Computer Core"

/area/ruin/space/derelict/solar_control
	name = "\improper Derelict Solar Control"

/area/ruin/space/derelict/se_solar
	name = "\improper South East Solars"

/area/ruin/space/derelict/medical
	name = "\improper Derelict Medbay"

/area/ruin/space/derelict/medical/chapel
	name = "\improper Derelict Chapel"

/area/station/solars/derelict_starboard
	name = "\improper Derelict Starboard Solar Array"

/area/station/solars/derelict_aft
	name = "\improper Derelict Aft Solar Array"

/area/ruin/space/derelict/singularity_engine
	name = "\improper Derelict Singularity Engine"

/area/ruin/space/derelict/gravity_generator
	name = "\improper Derelict Gravity Generator Room"

/area/ruin/space/derelict/atmospherics
	name = "Derelict Atmospherics"

//DJSTATION

/area/ruin/space/djstation
	name = "\improper Ruskie DJ Station"
	icon_state = "DJ"
	default_gravity = STANDARD_GRAVITY

/area/ruin/space/djstation/solars
	name = "\improper DJ Station Solars"
	icon_state = "DJ"
	default_gravity = STANDARD_GRAVITY


//ABANDONED TELEPORTER

/area/ruin/space/abandoned_tele
	name = "\improper Abandoned Teleporter"
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/signal.ogg')

//OLD AI SAT

/area/station/tcommsat/oldaisat
	name = "\improper Abandoned Satellite"

//ABANDONED BOX WHITESHIP

/area/ruin/space/has_grav/whiteship/box

	name = "\improper Abandoned Ship"


//SYNDICATE LISTENING POST STATION

/area/ruin/space/has_grav/listeningstation
	name = "\improper Listening Post"

/area/ruin/space/has_grav/powered/ancient_shuttle
	name = "\improper Ancient Shuttle"

/area/ruin/space/has_grav/powered/macspace
	name = "Mac Space Restaurant"

//POWER PUZLE

/area/ruin/space/has_grav/storage/central
	name = "storage central"
	icon_state = "hallC"

/area/ruin/space/has_grav/storage/central2
	name = "storage Vault"
	icon_state = "red"

/area/ruin/space/has_grav/storage/materials1
	name = "storage materials fore room"
	icon_state = "storage_wing"

/area/ruin/space/has_grav/storage/materials2
	name = "storage Materials secure room"
	icon_state = "storage"

/area/ruin/space/has_grav/storage/materials3
	name = "storage materials miscellaneous"
	icon_state = "yellow"

/area/ruin/space/has_grav/storage/power1
	name = "storage Enginering central"
	icon_state = "yellow"

/area/ruin/space/has_grav/storage/power2
	name = "storage Enginering "
	icon_state = "engi_storage"

/area/ruin/space/has_grav/storage/power3
	name = "storage Crates"
	icon_state = "green"
