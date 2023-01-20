/*
** Holomap vars and procs on /area
*/

/area
	/// Color of this area on holomaps.
	var/holomap_color = null
	/// Whether the turfs in the area should be drawn onto the "base" holomap.
	var/holomap_should_draw = TRUE

/area/shuttle
	holomap_should_draw = FALSE

/area/ruin
	holomap_should_draw = FALSE

/area/nsv/boarding_pod
	holomap_should_draw = FALSE

// Command //
/area/bridge
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/ai_monitored
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/nsv/briefingroom
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/maintenance/department/bridge
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

// Security //
/area/security
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/ai_monitored/security
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/maintenance/department/security
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

// Science //
/area/science
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/maintenance/department/science
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

// Medical //
/area/medical
	holomap_color = HOLOMAP_AREACOLOR_MEDICAL

/area/maintenance/department/medical
	holomap_color = HOLOMAP_AREACOLOR_MEDICAL

// Engineering //
/area/engineering
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/department/engine
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/department/electrical
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/tcommsat
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/disposal/incinerator
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/solars
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/construction
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/hallway/secondary/construction
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/nsv/engine/engine_room
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/engine
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/maintenance/nsv/ftlroom
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

// Service //
/area/service
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/janitor
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/hydroponics
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/crew_quarters/lounge
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/crew_quarters/cafeteria
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/crew_quarters/kitchen
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/crew_quarters/bar
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/crew_quarters/theatre
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/library
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/chapel
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/lawoffice
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/maintenance/department/crew_quarters
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/maintenance/department/chapel
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/vacant_room
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/vacant_room/commissary
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/vacant_room/commissary/commissary1
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/vacant_room/commissary/commissary2
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/vacant_room/commissary/commissaryFood
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/vacant_room/commissary/commissaryRandom
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

// Cargo //
/area/cargo
	holomap_color = HOLOMAP_AREACOLOR_CARGO

/area/maintenance/department/cargo
	holomap_color = HOLOMAP_AREACOLOR_CARGO

/area/quartermaster
	holomap_color = HOLOMAP_AREACOLOR_CARGO

/area/maintenance/disposal
	holomap_color = HOLOMAP_AREACOLOR_CARGO

// Hallways //
/area/hallway
	holomap_color = HOLOMAP_AREACOLOR_HALLWAYS

/area/hallway/secondary/command
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/hallway/secondary/service
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/hallway/secondary/exit/departure_lounge
	holomap_color = HOLOMAP_AREACOLOR_ESCAPE

/area/hallway/secondary/entry
	holomap_color = HOLOMAP_AREACOLOR_ARRIVALS

/area/hallway/upper/secondary/command
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/hallway/upper/secondary/service
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/hallway/upper/secondary/exit/departure_lounge
	holomap_color = HOLOMAP_AREACOLOR_ESCAPE

/area/hallway/upper/secondary/entry
	holomap_color = HOLOMAP_AREACOLOR_ARRIVALS

/area/nsv/engine/corridor
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

// Maints //
/area/maintenance
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/library/abandoned
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/crew_quarters/abandoned_gambling_den
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/medical/abandoned
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/science/research/abandoned
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/vacant_room/office
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

/area/hydroponics/garden/abandoned
	holomap_color = HOLOMAP_AREACOLOR_MAINTENANCE

// Dorms //
/area/commons
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/area/storage
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/area/crew_quarters
	holomap_color = HOLOMAP_AREACOLOR_DORMS

/area/holodeck
	holomap_color = HOLOMAP_AREACOLOR_DORMS

// Heads //
/area/crew_quarters/heads/captain
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/crew_quarters/heads/xo
	holomap_color = HOLOMAP_AREACOLOR_SERVICE

/area/crew_quarters/heads/hor
	holomap_color = HOLOMAP_AREACOLOR_SCIENCE

/area/crew_quarters/heads/chief
	holomap_color = HOLOMAP_AREACOLOR_ENGINEERING

/area/crew_quarters/heads/hos
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/crew_quarters/heads/cmo
	holomap_color = HOLOMAP_AREACOLOR_MEDICAL

// Dock areas //

/area/docking
	holomap_color =HOLOMAP_AREACOLOR_HANGAR

/area/docking/arrivalaux
	holomap_color =HOLOMAP_AREACOLOR_HANGAR

/area/docking/bridge
	holomap_color =HOLOMAP_AREACOLOR_HANGAR

/area/drydock
	holomap_color =HOLOMAP_AREACOLOR_HANGAR

/area/drydock/security
	holomap_color =HOLOMAP_AREACOLOR_HANGAR
