/*
	These are overlays attached to areas that effect only the floor plane.
	Textures are blended with MULTIPLY, so lower the alpha is the best setting
*/

//Default - pristine
/datum/turf_texture
	///Texture path
	var/icon = 'icons/turf/floor_texture.dmi'
	///Texture state
	var/icon_state = ""
	///The opacity of the texture used
	var/alpha = 255
	///Color adjustment - this isn't used often
	var/color = "#ffffffff"

//Subtle hallway wear & tear
/datum/turf_texture/hallway
	icon_state = "hallway"
	alpha = 45

//Deep maint use
/datum/turf_texture/maint
	icon_state = "maint"
	alpha = 80

