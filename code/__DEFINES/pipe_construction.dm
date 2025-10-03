//Construction Categories
#define PIPE_STRAIGHT			0 //! 2 directions: N/S, E/W
#define PIPE_BENDABLE			1 //! 6 directions: N/S, E/W, N/E, N/W, S/E, S/W
#define PIPE_TRINARY			2 //! 4 directions: N/E/S, E/S/W, S/W/N, W/N/E
#define PIPE_TRIN_M				3 //! 8 directions: N->S+E, S->N+E, N->S+W, S->N+W, E->W+S, W->E+S, E->W+N, W->E+N
#define PIPE_UNARY				4 //! 4 directions: N, S, E, W
#define PIPE_ONEDIR				5 //! 1 direction: N/S/E/W
#define PIPE_UNARY_FLIPPABLE	6 //! 8 directions: N/S/E/W/N-flipped/S-flipped/E-flipped/W-flipped
#define PIPE_ONEDIR_FLIPPABLE	7 //2 direction: N/S/E/W, N-flipped/S-flipped/E-flipped/W-flipped

//Disposal pipe relative connection directions
#define DISP_DIR_BASE	0
#define DISP_DIR_LEFT	1
#define DISP_DIR_RIGHT	2
#define DISP_DIR_FLIP	4
#define DISP_DIR_NONE	8

//Transit tubes
#define TRANSIT_TUBE_STRAIGHT			0
#define TRANSIT_TUBE_STRAIGHT_CROSSING	1
#define TRANSIT_TUBE_CURVED				2
#define TRANSIT_TUBE_DIAGONAL			3
#define TRANSIT_TUBE_DIAGONAL_CROSSING	4
#define TRANSIT_TUBE_JUNCTION			5
#define TRANSIT_TUBE_STATION			6
#define TRANSIT_TUBE_TERMINUS			7
#define TRANSIT_TUBE_POD				8

//the open status of the transit tube station
#define STATION_TUBE_OPEN		0
#define STATION_TUBE_OPENING	1
#define STATION_TUBE_CLOSED		2
#define STATION_TUBE_CLOSING	3

// Reference list for disposal sort junctions. Set the sortType variable on disposal sort junctions to
// the index of the sort department that you want. For example, sortType set to 2 will reroute all packages
// tagged for the Cargo Bay.

/* List of sortType codes for mapping reference
0 Waste
1 Disposals - All unwrapped items and untagged parcels get picked up by a junction with this sortType. Usually leads to the recycler.
2 Cargo Bay
3 QM Office
4 Engineering
5 CE Office
6 Atmospherics
7 Security
8 HoS Office
9 Medbay
10 CMO Office
11 Chemistry
12 Research
13 RD Office
14 Robotics
15 HoP Office
16 Library
17 Chapel
18 Theatre
19 Bar
20 Kitchen
21 Hydroponics
22 Janitor
23 Genetics
24 Testing Range
25 Toxins
26 Dormitories
27 Virology
28 Xenobiology
29 Law Office
30 Detective's Office
*/

//The whole system for the sorttype var is determined based on the order of this list,
//disposals must always be 1, since anything that's untagged will automatically go to disposals, or sorttype = 1 --Superxpdude

//If you don't want to fuck up disposals, add to this list, and don't change the order.
//If you insist on changing the order, you'll have to change every sort junction to reflect the new order. --Pete

/// Safe proc to remove a destination for /datum/map_adjustment.
/proc/exclude_tagger_destination(name_to_remove)
	GLOB.disabled_tagger_locations += name_to_remove
#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
	GLOB.tagger_destination_areas -= name_to_remove // unit test only
#endif

GLOBAL_LIST_INIT(disabled_tagger_locations, list())

GLOBAL_LIST_INIT(TAGGERLOCATIONS, list(
	"Disposals",
	"Cargo Bay",
	"QM Office",
	"Engineering",
	"CE Office",
	"Atmospherics",
	"Security",
	"HoS Office",
	"Medbay",
	"CMO Office",
	"Chemistry",
	"Research",
	"RD Office",
	"Robotics",
	"HoP Office",
	"Library",
	"Chapel",
	"Theatre",
	"Bar",
	"Kitchen",
	"Hydroponics",
	"Janitor Closet",
	"Genetics",
	"Testing Range",
	"Toxins",
	"Dormitories",
	"Virology",
	"Xenobiology",
	"Law Office",
	"Detective's Office",
))

#define MAPPING_HELPER_SORT(name, sort_code) /obj/structure/disposalpipe/sorting/mail/destination/##name {\
	sortType = sort_code;\
}\
/obj/structure/disposalpipe/sorting/mail/destination/##name/flip {\
	flip_type = /obj/structure/disposalpipe/sorting/mail;\
	icon_state = "pipe-j2s";\
	initialize_dirs = DISP_DIR_LEFT | DISP_DIR_FLIP;\
}

MAPPING_HELPER_SORT(disposals, 1)
MAPPING_HELPER_SORT(cargo_bay, 2)
MAPPING_HELPER_SORT(qm_office, 3)
MAPPING_HELPER_SORT(engineering, 4)
MAPPING_HELPER_SORT(ce_office, 5)
MAPPING_HELPER_SORT(atmospherics, 6)
MAPPING_HELPER_SORT(security, 7)
MAPPING_HELPER_SORT(hos_office, 8)
MAPPING_HELPER_SORT(medbay, 9)
MAPPING_HELPER_SORT(cmo_office, 10)
MAPPING_HELPER_SORT(chemistry, 11)
MAPPING_HELPER_SORT(research, 12)
MAPPING_HELPER_SORT(rd_office, 13)
MAPPING_HELPER_SORT(robotics, 14)
MAPPING_HELPER_SORT(hop_office, 15)
MAPPING_HELPER_SORT(library, 16)
MAPPING_HELPER_SORT(chapel, 17)
MAPPING_HELPER_SORT(threatre, 18)
MAPPING_HELPER_SORT(bar, 19)
MAPPING_HELPER_SORT(kitchen, 20)
MAPPING_HELPER_SORT(hydroponics, 21)
MAPPING_HELPER_SORT(janitor_closet, 22)
MAPPING_HELPER_SORT(genetics, 23)
MAPPING_HELPER_SORT(testing_range, 24)
MAPPING_HELPER_SORT(toxins, 25)
MAPPING_HELPER_SORT(dormitories, 26)
MAPPING_HELPER_SORT(virology, 27)
MAPPING_HELPER_SORT(xenobiology, 28)
MAPPING_HELPER_SORT(law_office, 29)
MAPPING_HELPER_SORT(detective_office, 30)

#undef MAPPING_HELPER_SORT

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

GLOBAL_LIST_INIT(tagger_destination_areas, list(
	"Disposals" = list(/area/maintenance/disposal, /area/quartermaster/sorting, /area/janitor),
	"Cargo Bay"  = list(/area/quartermaster),
	"QM Office" = list(/area/quartermaster/qm, /area/quartermaster/qm_bedroom),
	"Engineering" = list(/area/engine, /area/engineering),
	"CE Office" = list(/area/crew_quarters/heads/chief),
	"Atmospherics" = list(/area/engine/atmos, /area/engine/atmospherics_engine),
	"Security" = list(/area/security),
	"HoS Office" = list(/area/crew_quarters/heads/hos),
	"Medbay" = list(/area/medical),
	"CMO Office" = list(/area/crew_quarters/heads/cmo),
	"Chemistry" = list(/area/medical/chemistry, /area/medical/apothecary),
	"Research" = list(/area/science),
	"RD Office" = list(/area/crew_quarters/heads/hor),
	"Robotics" = list(/area/science/robotics),
	"HoP Office" = list(/area/crew_quarters/heads/hop),
	"Library" = list(/area/library),
	"Chapel" = list(/area/chapel),
	"Theatre" = list(/area/crew_quarters/theatre),
	"Bar" = list(/area/crew_quarters/bar, /area/crew_quarters/cafeteria),
	"Kitchen" = list(/area/crew_quarters/kitchen),
	"Hydroponics" = list(/area/hydroponics),
	"Janitor Closet" = list(/area/janitor),
	"Genetics" = list(/area/medical/genetics),
	"Testing Range" = list(/area/science/misc_lab, /area/science/test_area, /area/science/mixing),
	"Toxins" = list(/area/science/misc_lab, /area/science/test_area, /area/science/mixing),
	"Dormitories" = list(/area/crew_quarters/dorms, /area/commons/dorms, /area/crew_quarters/fitness),
	"Virology" = list(/area/medical/virology),
	"Xenobiology" = list(/area/science/xenobiology),
	"Law Office" = list(/area/lawoffice),
	"Detective's Office" = list(/area/security/detectives_office),
))

#endif

