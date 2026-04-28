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
#define SOUL_GLIMMER_POP_REQ_CREEP_STARTING 6 // Starting value. The pop requirement for additional colour will be increased by +1. (6, 7, 8, 9...) eventually you need 91 pop for Humour.

/*
	Summary for pop count (based on 6 interval)
		Color amount / Pop requirement
			1	0 (0)
			2	0 (7)
			3	0 (14)
			4	22	-- Starts to get a new color since 22 pop
			5	31
			6	41
			7	52
			8	64
			9	77
			10	91
*/
