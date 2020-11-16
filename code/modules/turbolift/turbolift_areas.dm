/area/shuttle/turbolift //Only use subtypes of this area
	requires_power = FALSE //no APCS in the lifts please
	ambient_effects = list('sound/effects/turbolift/elevatormusic.ogg')

/area/shuttle/turbolift/shaft //What the shuttle leaves behind
	name = "turbolift shaft"
	requires_power = TRUE
	ambient_effects = MAINTENANCE

/area/shuttle/turbolift/primary
	name = "primary turbolift"

/area/shuttle/turbolift/secondary
	name = "secondary turbolift"

/area/shuttle/turbolift/tertiary
	name = "tertiary turbolift"
