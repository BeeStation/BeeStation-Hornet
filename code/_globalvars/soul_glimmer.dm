/*
    Colours and assignments for psychic sense
    colour
    color
    :trolled:
*/

//ALL the psychic soul colours
GLOBAL_LIST_INIT(soul_glimmer_colors, list(
	"Azure" = "#0091ff",
	"Vermilion" = "#ff3a1c",
	"Sage" = "#1fff5e",
	"Teal" = "#00ffe5",
	"Terracotta" = "#ffa600",
	"Champagne" = "#ff009d",
	"Sunshine" = "#fff12c",
	"Melancholia" = "#8100FF",
	"Submarine" = "#1f1bff",
	"Humour" = "#e876ff"))

/// TGUI chat colours
GLOBAL_LIST_INIT(soul_glimmer_cfc_list, list(
	"Azure" = "cfc_soul_glimmer_azure",
	"Vermilion" = "cfc_soul_glimmer_vermilion",
	"Sage" = "cfc_soul_glimmer_sage",
	"Teal" = "cfc_soul_glimmer_teal",
	"Terracotta" = "cfc_soul_glimmer_terracotta",
	"Champagne" = "cfc_soul_glimmer_champagne",
	"Sunshine" = "cfc_soul_glimmer_sunshine",
	"Melancholia" = "cfc_soul_glimmer_melancholia",
	"Submarine" = "cfc_soul_glimmer_submarine",
	"Humour" = "cfc_soul_glimmer_humour"))

#define SOUL_GLIMMER_MINIMUM_POP_COLOR 3 // regardless of the pop, 3 colours will always come
#define SOUL_GLIMMER_POP_COUNT_INTERVAL 4 // Starting from 13, for every INTERVAL value, the round will spawn more soul colour
