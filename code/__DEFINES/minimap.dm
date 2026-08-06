/// How many pixels wide/tall each turf becomes on a rendered minimap.
/// The source is one pixel per turf, so raising this only nearest-neighbour upscales the same
/// image into a bigger asset. Prefer client/consumer.
#define MINIMAP_PIXEL_MULTIPLIER 1

// Structural colours
#define MINIMAP_COLOR_WALL "#5d6b7a"
#define MINIMAP_COLOR_FLOOR "#232a33"
#define MINIMAP_COLOR_DOOR "#d4b155"
#define MINIMAP_COLOR_WINDOW "#57a8bd"
#define MINIMAP_COLOR_GRILLE "#414d59"

// Department tints, blended 50/50 with the turf colour underneath
#define MINIMAP_COLOR_COMMAND "#4666c4"
#define MINIMAP_COLOR_ENGINEERING "#f0a020"
#define MINIMAP_COLOR_MEDICAL "#4ab8e0"
#define MINIMAP_COLOR_SCIENCE "#a35fd6"
#define MINIMAP_COLOR_SECURITY "#d64545"
#define MINIMAP_COLOR_CARGO "#b07d3a"
#define MINIMAP_COLOR_SERVICE "#4caf72"
#define MINIMAP_COLOR_COMMONS "#3f9e8c"
#define MINIMAP_COLOR_HALLWAY "#6b7684"
#define MINIMAP_COLOR_MAINTENANCE "#39414b"
#define MINIMAP_COLOR_TCOMMS "#3fa3a3"
#define MINIMAP_COLOR_SOLARS "#8a7f3a"
