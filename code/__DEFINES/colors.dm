// This is eventually for wjohn to add more color standardization stuff like I keep asking him >:(


//different types of atom colorations
///how many colour priority levels there are.
#define COLOUR_PRIORITY_AMOUNT 4
/// Only used by rare effects like greentext coloring mobs and when admins varedit color
#define ADMIN_COLOUR_PRIORITY 1
/// e.g. purple effect of the revenant on a mob, black effect when mob electrocuted
#define TEMPORARY_COLOUR_PRIORITY 2
/// Color splashed onto an atom (e.g. paint on turf)
#define WASHABLE_COLOUR_PRIORITY 3
/// Color inherent to the atom (e.g. blob color)
#define FIXED_COLOUR_PRIORITY 4

#define COLOR_INPUT_DISABLED "#F0F0F0"
#define COLOR_INPUT_ENABLED "#D3B5B5"

#define COLOR_DARKMODE_BACKGROUND "#202020"
#define COLOR_DARKMODE_DARKBACKGROUND "#171717"
#define COLOR_DARKMODE_TEXT "#a4bad6"

#define COLOR_WHITE            "#EEEEEE"
#define COLOR_OFF_WHITE			 "#FFF5ED"
#define COLOR_SILVER           "#C0C0C0"
#define COLOR_GRAY             "#808080"
#define COLOR_FLOORTILE_GRAY   "#8D8B8B"
#define COLOR_WEBSAFE_DARK_GRAY  "#484848"
#define COLOR_ALMOST_BLACK	   "#333333"
#define COLOR_FULL_TONER_BLACK	 "#101010"
#define COLOR_BLACK            "#000000"
#define COLOR_HALF_TRANSPARENT_BLACK    "#0000007A"
#define COLOR_RED              "#FF0000"
#define COLOR_RED_LIGHT        "#FF3333"
#define COLOR_DARK_RED		   "#A50824"
#define COLOR_MAROON           "#800000"
#define COLOR_YELLOW           "#FFFF00"
#define COLOR_OLIVE            "#808000"
#define COLOR_LIME             "#32CD32"
#define COLOR_GREEN            "#008000"
#define COLOR_CYAN             "#00FFFF"
#define COLOR_TEAL             "#008080"
#define COLOR_BLUE             "#0000FF"
#define COLOR_BLUE_LIGHT       "#33CCFF"
#define COLOR_NAVY             "#000080"
#define COLOR_PINK             "#FFC0CB"
#define COLOR_FADED_PINK 	   "#ff80d5"
#define COLOR_MAGENTA          "#FF00FF"
#define COLOR_PURPLE           "#800080"
#define COLOR_ORANGE           "#FF9900"
#define COLOR_LIGHT_ORANGE 	   "#ffc44d"
#define COLOR_BEIGE            "#CEB689"
#define COLOR_BLUE_GRAY        "#75A2BB"
#define COLOR_BROWN            "#BA9F6D"
#define COLOR_DARK_BROWN       "#997C4F"
#define COLOR_DARK_ORANGE      "#C3630C"
#define COLOR_GREEN_GRAY       "#99BB76"
#define COLOR_RED_GRAY         "#B4696A"
#define COLOR_PALE_BLUE_GRAY   "#98C5DF"
#define COLOR_PALE_GREEN_GRAY  "#B7D993"
#define COLOR_PALE_ORANGE		"#FFBE9D"
#define COLOR_PALE_RED_GRAY    "#D59998"
#define COLOR_PALE_PURPLE_GRAY "#CBB1CA"
#define COLOR_PURPLE_GRAY      "#AE8CA8"
#define COLOR_DARK_PURPLE 	   "#551A8B"

//Color defines used by the assembly detailer.
#define COLOR_ASSEMBLY_BLACK   "#545454"
#define COLOR_ASSEMBLY_BGRAY   "#9497AB"
#define COLOR_ASSEMBLY_WHITE   "#E2E2E2"
#define COLOR_ASSEMBLY_RED     "#CC4242"
#define COLOR_ASSEMBLY_ORANGE  "#E39751"
#define COLOR_ASSEMBLY_BEIGE   "#AF9366"
#define COLOR_ASSEMBLY_BROWN   "#97670E"
#define COLOR_ASSEMBLY_GOLD    "#AA9100"
#define COLOR_ASSEMBLY_YELLOW  "#CECA2B"
#define COLOR_ASSEMBLY_GURKHA  "#999875"
#define COLOR_ASSEMBLY_LGREEN  "#789876"
#define COLOR_ASSEMBLY_GREEN   "#44843C"
#define COLOR_ASSEMBLY_LBLUE   "#5D99BE"
#define COLOR_ASSEMBLY_BLUE    "#38559E"
#define COLOR_ASSEMBLY_PURPLE  "#6F6192"

//Colours used by blood brothers
#define COLOR_LIST_BLOOD_BROTHERS list(\
	"#FF5050",\
	"#D977FD",\
	"#422ED8",\
	"#2D87A1",\
	"#3ED8FD",\
	"#0EF5CE",\
	"#0DF447",\
	"#D6B20C",\
	"#FF902A",\
)

// Color Filters
/// Icon filter that creates ambient occlusion
#define AMBIENT_OCCLUSION filter(type="drop_shadow", x=0, y=-2, size=4, color="#04080FAA")
/// Icon filter that creates gaussian blur
#define GAUSSIAN_BLUR(filter_size) filter(type="blur", size=filter_size)
