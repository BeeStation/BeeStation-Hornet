/*
	These are overlays attached to areas that effect only the floor plane.
	Textures are blended onto turfs with MULTIPLY
*/

//Default - pristine
/datum/turf_texture
	///Texture path
	var/icon = 'icons/turf/turf_texture.dmi'
	///Texture state
	var/icon_state = ""
	///The opacity of the texture used
	var/alpha = 255
	///Color adjustment - this isn't used often
	var/color = "#fff"
	///The priority of this texture
	var/priority = 1
	///Is this texture cleanable?
	var/cleanable = TRUE

//Effect object we use to hold our groceries
/atom/movable/turf_texture
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_MULTIPLY
	plane = FLOOR_PLANE
	appearance_flags = KEEP_TOGETHER
	///Associated texture
	var/datum/turf_texture/parent_texture

CREATION_TEST_IGNORE_SUBTYPES(/atom/movable/turf_texture)

/atom/movable/turf_texture/Initialize(mapload, datum/turf_texture/_texture)
	. = ..()
	var/datum/turf_texture/texture = new _texture()
	var/mutable_appearance/MA = mutable_appearance(texture.icon, texture.icon_state)
	add_overlay(MA)
	parent_texture = _texture
	color = texture.color
	alpha = texture.alpha

//Subtle hallway wear & tear
/datum/turf_texture/hallway
	icon_state = "hallway"
	alpha = 55

/datum/turf_texture/hallway_nonsegmented
	icon_state = "hallway_nonsegmented"
	alpha = 55

//Deep maint use
/datum/turf_texture/maint
	icon_state = "maint"
	alpha = 100

//Deep maint use for tiles
/datum/turf_texture/maint/tile
	icon_state = "maint_tile"
	alpha = 90
	priority = 2
