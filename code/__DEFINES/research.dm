
#define RDCONSOLE_UI_MODE_NORMAL 1
#define RDCONSOLE_UI_MODE_EXPERT 2
#define RDCONSOLE_UI_MODE_LIST 3

//RDSCREEN screens
#define RDSCREEN_MENU 0
#define RDSCREEN_TECHDISK 1
#define RDSCREEN_DESIGNDISK 20
#define RDSCREEN_DESIGNDISK_UPLOAD 21
#define RDSCREEN_DECONSTRUCT 3
#define RDSCREEN_PROTOLATHE 40
#define RDSCREEN_PROTOLATHE_MATERIALS 41
#define RDSCREEN_PROTOLATHE_CHEMICALS 42
#define RDSCREEN_PROTOLATHE_CATEGORY_VIEW 43
#define RDSCREEN_PROTOLATHE_SEARCH 44
#define RDSCREEN_IMPRINTER 50
#define RDSCREEN_IMPRINTER_MATERIALS 51
#define RDSCREEN_IMPRINTER_CHEMICALS 52
#define RDSCREEN_IMPRINTER_CATEGORY_VIEW 53
#define RDSCREEN_IMPRINTER_SEARCH 54
#define RDSCREEN_SETTINGS 61
#define RDSCREEN_DEVICE_LINKING 62
#define RDSCREEN_TECHWEB 70
#define RDSCREEN_TECHWEB_NODEVIEW 71
#define RDSCREEN_TECHWEB_DESIGNVIEW 72

#define RDSCREEN_NOBREAK "<NO_HTML_BREAK>"

#define RDSCREEN_TEXT_NO_PROTOLATHE "<div><h3>No Protolathe Linked!</h3></div><br>"
#define RDSCREEN_TEXT_NO_IMPRINTER "<div><h3>No Circuit Imprinter Linked!</h3></div><br>"
#define RDSCREEN_TEXT_NO_DECONSTRUCT "<div><h3>No Destructive Analyzer Linked!</h3></div><br>"
#define RDSCREEN_TEXT_NO_TDISK "<div><h3>No Technology Disk Inserted!</h3></div><br>"
#define RDSCREEN_TEXT_NO_DDISK "<div><h3>No Design Disk Inserted!</h3></div><br>"
#define RDSCREEN_TEXT_NO_SNODE "<div><h3>No Technology Node Selected!</h3></div><br>"
#define RDSCREEN_TEXT_NO_SDESIGN "<div><h3>No Design Selected!</h3></div><br>"

#define RDSCREEN_UI_LATHE_CHECK if(QDELETED(linked_lathe)) { return RDSCREEN_TEXT_NO_PROTOLATHE }
#define RDSCREEN_UI_IMPRINTER_CHECK if(QDELETED(linked_imprinter)) { return RDSCREEN_TEXT_NO_IMPRINTER }
#define RDSCREEN_UI_DECONSTRUCT_CHECK if(QDELETED(linked_destroy)) { return RDSCREEN_TEXT_NO_DECONSTRUCT }
#define RDSCREEN_UI_TDISK_CHECK if(QDELETED(t_disk)) { return RDSCREEN_TEXT_NO_TDISK }
#define RDSCREEN_UI_DDISK_CHECK if(QDELETED(d_disk)) { return RDSCREEN_TEXT_NO_DDISK }
#define RDSCREEN_UI_SNODE_CHECK if(!selected_node) { return RDSCREEN_TEXT_NO_SNODE }
#define RDSCREEN_UI_SDESIGN_CHECK if(!selected_design) { return RDSCREEN_TEXT_NO_SDESIGN }

#define RESEARCH_FABRICATOR_SCREEN_MAIN 1
#define RESEARCH_FABRICATOR_SCREEN_CHEMICALS 2
#define RESEARCH_FABRICATOR_SCREEN_MATERIALS 3
#define RESEARCH_FABRICATOR_SCREEN_SEARCH 4
#define RESEARCH_FABRICATOR_SCREEN_CATEGORYVIEW 5

#define DEPARTMENTAL_FLAG_SECURITY		(1<<0)
#define DEPARTMENTAL_FLAG_MEDICAL		(1<<1)
#define DEPARTMENTAL_FLAG_CARGO			(1<<2)
#define DEPARTMENTAL_FLAG_SCIENCE		(1<<3)
#define DEPARTMENTAL_FLAG_ENGINEERING	(1<<4)
#define DEPARTMENTAL_FLAG_SERVICE		(1<<5)
#define DEPARTMENTAL_FLAG_ALL			(1<<6)			//NO THIS DOESN'T ALLOW YOU TO PRINT EVERYTHING, IT'S FOR ALL DEPARTMENTS!
//#define DEPARTMENTAL_FLAG_MINING		(1<<7)

#define DESIGN_ID_IGNORE "IGNORE_THIS_DESIGN"

#define RESEARCH_MATERIAL_RECLAMATION_ID "__materials"

//When adding new types, update the list below!
#define TECHWEB_POINT_TYPE_GENERIC "General Research"
#define TECHWEB_POINT_TYPE_NANITES "Nanite Research"

#define TECHWEB_POINT_TYPE_DEFAULT TECHWEB_POINT_TYPE_GENERIC

//defined here so people don't forget to change this!
#define TECHWEB_POINT_TYPE_LIST_ASSOCIATIVE_NAMES list(\
	TECHWEB_POINT_TYPE_GENERIC = "General Research",\
	TECHWEB_POINT_TYPE_NANITES = "Nanite Research"\
	)

#define TECHWEB_BOMB_POINTCAP		50000 //! Adjust as needed; Stops toxins from nullifying RND progression mechanics. Current Value Cap Radius: 100


//! Swab cell line types
#define CELL_LINE_TABLE_SLUDGE "cell_line_sludge_table"
#define CELL_LINE_TABLE_MOLD "cell_line_mold_table"
#define CELL_LINE_TABLE_MOIST "cell_line_moist_table"
#define CELL_LINE_TABLE_BLOB "cell_line_blob_table"
#define CELL_LINE_TABLE_CLOWN "cell_line_clown_table"

//! Biopsy cell line types
#define CELL_LINE_TABLE_BEAR "cell_line_bear_table"
#define CELL_LINE_TABLE_BLOBBERNAUT "cell_line_blobbernaut_table"
#define CELL_LINE_TABLE_BLOBSPORE "cell_line_blobspore_table"
#define CELL_LINE_TABLE_CARP "cell_line_carp_table"
#define CELL_LINE_TABLE_CAT "cell_line_cat_table"
#define CELL_LINE_TABLE_CHICKEN "cell_line_chicken_table"
#define CELL_LINE_TABLE_COCKROACH "cell_line_cockroach_table"
#define CELL_LINE_TABLE_CORGI "cell_line_corgi_table"
#define CELL_LINE_TABLE_COW "cell_line_cow_table"
#define CELL_LINE_TABLE_GELATINOUS "cell_line_gelatinous_table"
#define CELL_LINE_TABLE_GRAPE "cell_line_grape_table"
#define CELL_LINE_TABLE_MEGACARP "cell_line_megacarp_table"
#define CELL_LINE_TABLE_MOUSE "cell_line_mouse_table"
#define CELL_LINE_TABLE_PINE "cell_line_pine_table"
#define CELL_LINE_TABLE_PUG "cell_line_pug_table"
#define CELL_LINE_TABLE_SLIME "cell_line_slime_table"
#define CELL_LINE_TABLE_SNAKE "cell_line_snake_table"
#define CELL_LINE_TABLE_VATBEAST "cell_line_vatbeast_table"
#define CELL_LINE_TABLE_NETHER "cell_line_nether_table"
#define CELL_LINE_TABLE_GLUTTON "cell_line_glutton_table"

//! All cell virus types
#define CELL_VIRUS_TABLE_GENERIC "cell_virus_generic_table"
#define CELL_VIRUS_TABLE_GENERIC_MOB "cell_virus_generic_mob_table"

//! General defines for vatgrowing
/// Past how much growth can the other cell_lines affect a finished cell line negatively
#define VATGROWING_DANGER_MINIMUM 30
