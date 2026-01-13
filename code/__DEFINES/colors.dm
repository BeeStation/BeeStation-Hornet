// This is eventually for wjohn to add more color standardization stuff like I keep asking him >:(


//different types of atom colorations
/// Only used by rare effects like greentext coloring mobs and when admins varedit color
#define ADMIN_COLOUR_PRIORITY 1
/// e.g. purple effect of the revenant on a mob, black effect when mob electrocuted
#define TEMPORARY_COLOUR_PRIORITY 2
/// Color splashed onto an atom (e.g. paint on turf)
#define WASHABLE_COLOUR_PRIORITY 3
/// Color inherent to the atom (e.g. blob color)
#define FIXED_COLOUR_PRIORITY 4
///how many colour priority levels there are.
#define COLOUR_PRIORITY_AMOUNT 5


// NOTE: AVOID USING THIS SUCH AS "<font color=COLOR_MACRO>".
// It's not a correct way to use. All colors look different based on your chat background theme.
// You should check "chat-light-theme.scss" and "chat-dark-theme.scss" if you want a colored chat
#define COLOR_INPUT_DISABLED "#F0F0F0"
#define COLOR_INPUT_ENABLED "#D3B5B5"

#define COLOR_DARKMODE_BACKGROUND "#202020"
#define COLOR_DARKMODE_DARKBACKGROUND "#171717"
#define COLOR_DARKMODE_TEXT "#a4bad6"

#define COLOR_WHITE "#FFFFFF"
#define COLOR_OFF_WHITE "#fff5ed"
#define COLOR_VERY_LIGHT_GRAY "#EEEEEE"
#define COLOR_SILVER "#C0C0C0"
#define COLOR_GRAY "#808080"
#define COLOR_FLOORTILE_GRAY "#8D8B8B"
#define COLOR_ASSISTANT_GRAY "#6E6E6E"
#define COLOR_DARK "#454545"
#define COLOR_WEBSAFE_DARK_GRAY "#484848"
#define COLOR_ALMOST_BLACK "#333333"
#define COLOR_FULL_TONER_BLACK "#101010"
#define COLOR_NEARLY_ALL_BLACK "#111111"
#define COLOR_BLACK "#000000"
#define COLOR_HALF_TRANSPARENT_BLACK "#0000007A"

#define COLOR_RED "#FF0000"
#define COLOR_MOSTLY_PURE_RED "#FF3300"
#define COLOR_DARK_RED "#A50824"
#define COLOR_RED_LIGHT "#FF3333"
#define COLOR_MAROON "#800000"
#define COLOR_SECURITY_RED "#CB0000"
#define COLOR_VIVID_RED "#FF3232"
#define COLOR_SOFT_RED "#FA8282"
/// Color used for default blood
#define COLOR_BLOOD "#CC0000"

#define COLOR_YELLOW "#FFFF00"
#define COLOR_VIVID_YELLOW "#FBFF23"
#define COLOR_GOLD "#FFD700"

#define COLOR_OLIVE "#808000"
#define COLOR_VIBRANT_LIME "#00FF00"
#define COLOR_PALE_GREEN "#20e28e"
#define COLOR_LIME "#32CD32"
#define COLOR_GREEN "#008000"
#define COLOR_DARK_MODERATE_LIME_GREEN "#44964A"
#define COLOR_VERY_DARK_LIME_GREEN "#003300"

#define COLOR_CYAN "#00FFFF"
#define COLOR_DARK_CYAN "#00A2FF"
#define COLOR_TEAL "#008080"
#define COLOR_BLUSH_TEAL "#009696"
#define COLOR_BLUE "#0000FF"
#define COLOR_MODERATE_BLUE "#555CC2"
#define COLOR_BLUE_LIGHT "#33CCFF"
#define COLOR_NAVY "#000080"
#define COLOR_BLUE_GRAY "#75A2BB"

/// Starlight!
#define COLOR_STARLIGHT "#8589fa"

#define COLOR_PINK "#FFC0CB"
#define COLOR_LIGHT_PINK "#FF3CC8"
#define COLOR_MOSTLY_PURE_PINK "#E4005B"
#define COLOR_BLUSH_PINK "#DE5D83"
#define COLOR_FADED_PINK "#ff80d5"
#define COLOR_MAGENTA "#FF00FF"
#define COLOR_STRONG_MAGENTA "#B800B8"
#define COLOR_PURPLE "#800080"
#define COLOR_VIOLET "#B900F7"
#define COLOR_VOID_PURPLE "#53277E"
#define COLOR_AMETHYST "#822BFF"
#define COLOR_STRONG_VIOLET "#6927C5"
#define COLOR_DARK_PURPLE "#551A8B"


#define COLOR_ORANGE "#FF9900"
#define COLOR_LIGHT_ORANGE "#ffc44d"
#define COLOR_ENGINEERING_ORANGE "#FFA62B"
#define COLOR_DARK_ORANGE "#C3630C"
#define COLOR_BEIGE "#CEB689"
#define COLOR_DARK_MODERATE_ORANGE "#8B633B"
#define COLOR_TAN_ORANGE "#FF7B00"


#define COLOR_BROWN "#BA9F6D"
#define COLOR_DARK_BROWN "#997C4F"
#define COLOR_DARKER_BROWN "#330000"
#define COLOR_ORANGE_BROWN "#a9734f"
#define COLOR_CARGO_BROWN "#B18644"
#define COLOR_DRIED_TAN "#ad7257"
#define COLOR_LIGHT_BROWN "#996666"
#define COLOR_BROWNER_BROWN "#663300"

#define COLOR_GREEN_GRAY "#99BB76"
#define COLOR_RED_GRAY "#B4696A"
#define COLOR_PALE_BLUE_GRAY "#98C5DF"
#define COLOR_PALE_GREEN_GRAY "#B7D993"
#define COLOR_PALE_ORANGE "#FFBE9D"
#define COLOR_PALE_RED_GRAY "#D59998"
#define COLOR_PALE_PURPLE_GRAY "#CBB1CA"
#define COLOR_PURPLE_GRAY "#AE8CA8"

//Color defines used by the assembly detailer.
#define COLOR_ASSEMBLY_BLACK "#545454"
#define COLOR_ASSEMBLY_BGRAY "#9497AB"
#define COLOR_ASSEMBLY_WHITE "#E2E2E2"
#define COLOR_ASSEMBLY_RED "#CC4242"
#define COLOR_ASSEMBLY_ORANGE "#E39751"
#define COLOR_ASSEMBLY_BEIGE "#AF9366"
#define COLOR_ASSEMBLY_BROWN "#97670E"
#define COLOR_ASSEMBLY_GOLD "#AA9100"
#define COLOR_ASSEMBLY_YELLOW "#CECA2B"
#define COLOR_ASSEMBLY_GURKHA "#999875"
#define COLOR_ASSEMBLY_LGREEN "#789876"
#define COLOR_ASSEMBLY_GREEN "#44843C"
#define COLOR_ASSEMBLY_LBLUE "#5D99BE"
#define COLOR_ASSEMBLY_BLUE "#38559E"
#define COLOR_ASSEMBLY_PURPLE "#6F6192"


///Pipe colors
#define COLOR_PIPE_AMETHYST "#822BFF"
#define COLOR_PIPE_BLUE "#0000FF"
#define COLOR_PIPE_BROWN "#B26438"
#define COLOR_PIPE_CYAN "#00FFF9"
#define COLOR_PIPE_DARK "#454545"
#define COLOR_PIPE_GREEN "#1EFF00"
#define COLOR_PIPE_GREY "#FFFFFF"
#define COLOR_PIPE_ORANGE "#FF8119"
#define COLOR_PIPE_PURPLE "#8000B6"
#define COLOR_PIPE_RED "#FF0000"
#define COLOR_PIPE_VIOLET "#400080"
#define COLOR_PIPE_YELLOW "#FFC600"

/**
 * Some defines to generalise colours used in lighting.
 *
 * Important note: colors can end up significantly different from the basic html picture, especially when saturated
 */
/// Greens
#define LIGHT_COLOR_GREEN "#3CFF3C"
#define LIGHT_COLOR_VIVID_GREEN "#1AFF4A"
#define LIGHT_COLOR_ELECTRIC_GREEN "#00FF00"

/// Blues & Cyans
#define LIGHT_COLOR_BLUE "#3C78FF"
#define LIGHT_COLOR_FAINT_BLUE "#B4D8FF"
#define LIGHT_COLOR_BLUEGREEN "#3CFFB4"
#define LIGHT_COLOR_CYAN "#3CFFFF"
#define LIGHT_COLOR_BABY_BLUE "#00CCFF"
#define LIGHT_COLOR_ELECTRIC_CYAN "#00FFFF"
#define LIGHT_COLOR_LIGHT_CYAN "#3CD8FF"
#define LIGHT_COLOR_DARK_BLUE "#335CFF"

/// Pink / Purple
#define LIGHT_COLOR_PINK "#FF5CFF"
#define LIGHT_COLOR_PURPLE "#8A00FF"
#define LIGHT_COLOR_LAVENDER "#A066FF"

/// Yellows
#define LIGHT_COLOR_DIM_YELLOW "#FFFF3C"
#define LIGHT_COLOR_BRIGHT_YELLOW "#FFFF66"
#define LIGHT_COLOR_HOLY_MAGIC "#FFF200"

/// Reds / Oranges / Warm
#define LIGHT_COLOR_BLOOD_MAGIC "#FF0000"
#define LIGHT_COLOR_RED "#FF4A4A"
#define LIGHT_COLOR_CLOCKWORK "#FFB000"
#define LIGHT_COLOR_ORANGE "#FF8C1A"
#define LIGHT_COLOR_BROWN "#C8641E"

/// Fire / Special
#define LIGHT_COLOR_FIRE "#FF9A00"
#define LIGHT_COLOR_LAVA "#FF7A00"
#define LIGHT_COLOR_FLARE "#FF4A2A"
#define LIGHT_COLOR_SLIME_LAMP "#B4FF2A"
#define LIGHT_COLOR_TUNGSTEN "#FFD28A"
#define LIGHT_COLOR_HALOGEN "#D8FFFF"

/// Neutral
#define LIGHT_COLOR_WHITE "#FFFFFF"


/// Colors for incident displays
#define COLOR_DISPLAY_RED "#BE3455"
#define COLOR_DISPLAY_YELLOW "#FFF743"
#define COLOR_DISPLAY_GREEN "#3CF046"

// check "chat-light-theme.scss" and "chat-dark-theme.scss"
GLOBAL_LIST_INIT(color_list_blood_brothers, shuffle(list(
	"cfc_red",
	"cfc_purple",
	"cfc_navy",
	"cfc_darkbluesky",
	"cfc_bluesky",
	"cfc_cyan",
	"cfc_lime",
	"cfc_orange",
	"cfc_redorange",
)))

// Do not use this as a font color. try cfc color formats.
GLOBAL_LIST_INIT(color_list_rainbow, list(
	"#FF5050",
	"#FF902A",
	"#D6B20C",
	"#88d818",
	"#42c9eb",
	"#422ED8",
	"#D977FD",
))

// Color Filters
/// Icon filter that creates ambient occlusion
#define AMBIENT_OCCLUSION filter(type="drop_shadow", x=0, y=-2, size=4, color="#04080FAA")
/// Icon filter that creates gaussian blur
#define GAUSSIAN_BLUR(filter_size) filter(type="blur", size=filter_size)

/// The default color for admin say, used as a fallback when the preference is not enabled
#define DEFAULT_ASAY_COLOR COLOR_MOSTLY_PURE_RED
/// The default color for Byond Member / ADMIN OOC, used as a fallback when the preference is not enabled
#define DEFAULT_BONUS_OOC_COLOR "#c43b23"

// Some defines for accessing specific entries in color matrices.

#define CL_MATRIX_RR 1
#define CL_MATRIX_RG 2
#define CL_MATRIX_RB 3
#define CL_MATRIX_RA 4
#define CL_MATRIX_GR 5
#define CL_MATRIX_GG 6
#define CL_MATRIX_GB 7
#define CL_MATRIX_GA 8
#define CL_MATRIX_BR 9
#define CL_MATRIX_BG 10
#define CL_MATRIX_BB 11
#define CL_MATRIX_BA 12
#define CL_MATRIX_AR 13
#define CL_MATRIX_AG 14
#define CL_MATRIX_AB 15
#define CL_MATRIX_AA 16
#define CL_MATRIX_CR 17
#define CL_MATRIX_CG 18
#define CL_MATRIX_CB 19
#define CL_MATRIX_CA 20

#define COLOR_GNOME_RED_ONE "#f10b0b"
#define COLOR_GNOME_RED_TWO "#bc5347"
#define COLOR_GNOME_RED_THREE "#b40f1a"
#define COLOR_GNOME_BLUE_ONE "#2e8ff7"
#define COLOR_GNOME_BLUE_TWO "#312bd6"
#define COLOR_GNOME_BLUE_THREE "#4e409a"
#define COLOR_GNOME_GREEN_ONE "#28da1c"
#define COLOR_GNOME_GREEN_TWO "#50a954"
#define COLOR_GNOME_YELLOW "#f6da3c"
#define COLOR_GNOME_ORANGE "#d56f2f"
#define COLOR_GNOME_BROWN_ONE "#874e2a"
#define COLOR_GNOME_BROWN_TWO "#543d2e"
#define COLOR_GNOME_PURPLE "#ac1dd7"
#define COLOR_GNOME_WHITE "#e8e8e8"
#define COLOR_GNOME_GREY "#a9a9a9"
#define COLOR_GNOME_BLACK "#303030"

/// Default area lighting colours
#define LIGHT_COLOUR_VERY_WARM "#e67727"
#define LIGHT_COLOUR_WARM "#edb560"
#define LIGHT_COLOUR_NEUTRAL "#f1e3a9"
#define LIGHT_COLOUR_COLD "#d1f0ef"
#define LIGHT_COLOUR_VERY_COLD "#c2edec"

#define LIGHT_COLOUR_NIGHT "#758dc3"
