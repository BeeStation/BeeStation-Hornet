//random room spawner. takes random rooms from their appropriate map file and places them. the room will spawn with the spawner in the bottom left corner

/obj/effect/spawner/room
    name = "random room spawner"
    icon = 'icons/effects/landmarks_static.dmi'
    icon_state = "random_room"
    dir = NORTH
    var/room_width = 0
    var/room_height = 0
    ///List of room IDs we want
    var/list/rooms = list()

/obj/effect/spawner/room/New(loc, ...)
    . = ..()
    if(!isnull(SSmapping.random_room_spawners))
        SSmapping.random_room_spawners += src

/obj/effect/spawner/room/Initialize(mapload)
    . = ..()
    if(!length(SSmapping.random_room_templates))
        message_admins("Room spawner created with no templates available. This shouldn't happen.")
        return INITIALIZE_HINT_QDEL
    var/list/possibletemplates = list()
    var/datum/map_template/random_room/candidate
    shuffle_inplace(SSmapping.random_room_templates)
    for(var/ID in SSmapping.random_room_templates)
        candidate = SSmapping.random_room_templates[ID]
        if((!rooms.len && candidate.spawned) || (!rooms.len && (room_height != candidate.template_height || room_width != candidate.template_width)) || (rooms.len && !(candidate.room_id in rooms)))
            candidate = null
            continue
        possibletemplates[candidate] = candidate.weight
    if(possibletemplates.len)
        var/datum/map_template/random_room/template = pick_weight(possibletemplates)
        template.stock --
        template.weight = (template.weight / 2)
        if(template.stock <= 0)
            template.spawned = TRUE
        template.load(get_turf(src), centered = template.centerspawner)

/obj/effect/spawner/room/special/tenxfive_terrestrial
	name = "10x5 terrestrial room"
	room_width = 10
	room_height = 5
	icon_state = "random_room_alternative"
	rooms = list("sk_rdm011_barbershop","sk_rdm031_deltarobotics","sk_rdm039_deltaclutter1","sk_rdm040_deltabotnis","sk_rdm045_deltacafeteria","sk_rdm046_deltaarcade","sk_rdm082_maintmedical","sk_rdm091_skidrow","sk_rdm100_meetingroom","sk_rdm105_phage","sk_rdm125_courtroom","sk_rdm126_gaschamber","sk_rdm127_oldaichamber","sk_rdm128_radiationtherapy","sk_rdm150_smallmedlobby","sk_rdm151_ratburger","sk_rdm152_geneticsoffice","sk_rdm153_hobowithpeter","sk_rdm154_butchersden","sk_rdm155_punjiconveyor","sk_rdm156_oldairlock_interchange","sk_rdm161_kilovault")
/obj/effect/spawner/room/special/tenxten_terrestrial
	name = "10x10 terrestrial room"
	room_width = 10
	room_height = 10
	icon_state = "random_room_alternative"
	rooms = list("sk_rdm033_deltalibrary","sk_rdm060_snakefighter","sk_rdm062_roosterdome","sk_rdm070_pubbybar","sk_rdm083_bigtheatre","sk_rdm098_graffitiroom","sk_rdm102_podrepairbay","sk_rdm106_sanitarium","sk_rdm129_beach","sk_rdm130_benoegg","sk_rdm131_confinementroom","sk_rdm132_conveyorroom","sk_rdm133_oldoffice","sk_rdm134_snowforest","sk_rdm141_6sectorsdown","sk_rdm142_olddiner","sk_rdm143_gamercave","sk_rdm144_smallmagician","sk_rdm145_ladytesla_altar","sk_rdm146_blastdoor_interchange","sk_rdm147_advbotany","sk_rdm148_botany_apiary","sk_rdm157_chess","sk_rdm159_kilosnakepit","sk_rdm167_library_ritual")
/obj/effect/spawner/room/fivexfour
	name = "5x4 room spawner"
	room_width = 5
	room_height = 4

/obj/effect/spawner/room/fivexthree
	name = "5x3 room spawner"
	room_width = 5
	room_height = 3

/obj/effect/spawner/room/threexfive
	name = "3x5 room spawner"
	room_width = 3
	room_height = 5

/obj/effect/spawner/room/tenxten
	name = "10x10 room spawner"
	room_width = 10
	room_height = 10

/obj/effect/spawner/room/tenxfive
	name = "10x5 room spawner"
	room_width = 10
	room_height = 5

/obj/effect/spawner/room/threexthree
	name = "3x3 room spawner"
	room_width = 3
	room_height = 3

/obj/effect/spawner/room/fland
	name = "Special Room (5x10)"
	icon_state = "random_room_alternative"
	room_width = 5
	room_height = 10

