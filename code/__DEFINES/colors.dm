// This is eventually for wjohn to add more color standardization stuff like I keep asking him >:(

#define COLOR_INPUT_DISABLED "#F0F0F0"
#define COLOR_INPUT_ENABLED "#D3B5B5"

#define COLOR_DARKMODE_BACKGROUND "#202020"
#define COLOR_DARKMODE_DARKBACKGROUND "#171717"
#define COLOR_DARKMODE_TEXT "#a4bad6"

#define COLOR_WHITE            "#EEEEEE"
#define COLOR_SILVER           "#C0C0C0"
#define COLOR_GRAY             "#808080"
#define COLOR_FLOORTILE_GRAY   "#8D8B8B"
#define COLOR_ALMOST_BLACK	   "#333333"
#define COLOR_BLACK            "#000000"
#define COLOR_HALF_TRANSPARENT_BLACK    "#0000007A"
#define COLOR_RED              "#FF0000"
#define COLOR_RED_LIGHT        "#FF3333"
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
#define COLOR_MAGENTA          "#FF00FF"
#define COLOR_PURPLE           "#800080"
#define COLOR_ORANGE           "#FF9900"
#define COLOR_BEIGE            "#CEB689"
#define COLOR_BLUE_GRAY        "#75A2BB"
#define COLOR_BROWN            "#BA9F6D"
#define COLOR_DARK_BROWN       "#997C4F"
#define COLOR_DARK_ORANGE      "#C3630C"
#define COLOR_GREEN_GRAY       "#99BB76"
#define COLOR_RED_GRAY         "#B4696A"
#define COLOR_PALE_BLUE_GRAY   "#98C5DF"
#define COLOR_PALE_GREEN_GRAY  "#B7D993"
#define COLOR_PALE_RED_GRAY    "#D59998"
#define COLOR_PALE_PURPLE_GRAY "#CBB1CA"
#define COLOR_PURPLE_GRAY      "#AE8CA8"

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

//Some defines to generalise colours used in lighting.
//Important note on colors. Colors can end up significantly different from the basic html picture, especially when saturated
#define LIGHT_COLOR_WHITE		"#FFFFFF" //! Full white. rgb(255, 255, 255)
#define LIGHT_COLOR_RED        "#FA8282" //! Warm but extremely diluted red. rgb(250, 130, 130)
#define LIGHT_COLOR_GREEN      "#64C864" //! Bright but quickly dissipating neon green. rgb(100, 200, 100)
#define LIGHT_COLOR_BLUE       "#6496FA" //! Cold, diluted blue. rgb(100, 150, 250)

#define LIGHT_COLOR_BLUEGREEN  "#7DE1AF" //! Light blueish green. rgb(125, 225, 175)
#define LIGHT_COLOR_PALEBLUE   "#7DAFE1" //! A pale blue-ish color. rgb(125, 175, 225)
#define LIGHT_COLOR_CYAN       "#7DE1E1" //! Diluted cyan. rgb(125, 225, 225)
#define LIGHT_COLOR_LIGHT_CYAN "#40CEFF" //! More-saturated cyan. rgb(64, 206, 255)
#define LIGHT_COLOR_DARK_BLUE  "#6496FA" //! Saturated blue. rgb(51, 117, 248)
#define LIGHT_COLOR_PINK       "#E17DE1" //! Diluted, mid-warmth pink. rgb(225, 125, 225)
#define LIGHT_COLOR_YELLOW     "#E1E17D" //! Dimmed yellow, leaning kaki. rgb(225, 225, 125)
#define LIGHT_COLOR_BROWN      "#966432" //! Clear brown, mostly dim. rgb(150, 100, 50)
#define LIGHT_COLOR_ORANGE     "#FA9632" //! Mostly pure orange. rgb(250, 150, 50)
#define LIGHT_COLOR_PURPLE     "#952CF4" //! Light Purple. rgb(149, 44, 244)
#define LIGHT_COLOR_LAVENDER   "#9B51FF" //! Less-saturated light purple. rgb(155, 81, 255)

#define LIGHT_COLOR_HOLY_MAGIC	"#FFF743" //! slightly desaturated bright yellow.
#define LIGHT_COLOR_BLOOD_MAGIC	"#D00000" //! deep crimson
#define LIGHT_COLOR_CLOCKWORK 	"#BE8700"

//These ones aren't a direct colour like the ones above, because nothing would fit
#define LIGHT_COLOR_FIRE       "#FAA019" //! Warm orange color, leaning strongly towards yellow. rgb(250, 160, 25)
#define LIGHT_COLOR_LAVA       "#C48A18" //! Very warm yellow, leaning slightly towards orange. rgb(196, 138, 24)
#define LIGHT_COLOR_FLARE      "#FA644B" //! Bright, non-saturated red. Leaning slightly towards pink for visibility. rgb(250, 100, 75)
#define LIGHT_COLOR_SLIME_LAMP "#AFC84B" //! Weird color, between yellow and green, very slimy. rgb(175, 200, 75)
#define LIGHT_COLOR_TUNGSTEN   "#FAE1AF" //! Extremely diluted yellow, close to skin color (for some reason). rgb(250, 225, 175)
#define LIGHT_COLOR_HALOGEN    "#F0FAFA" //! Barely visible cyan-ish hue, as the doctor prescribed. rgb(240, 250, 250)

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
