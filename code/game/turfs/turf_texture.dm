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
	var/color = "#ffffffff"
	///The priority of this texture
	var/priority = 1
	///Is this texture cleanable?
	var/cleanable = TRUE

//Effect object we use to hold our groceries
/obj/effect/turf_texture
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	///Associated texture
	var/datum/turf_texture/parent_texture

/obj/effect/turf_texture/Initialize(mapload, datum/turf_texture/_texture)
	. = ..()
	var/datum/turf_texture/texture = new _texture()
	var/mutable_appearance/MA = mutable_appearance(texture.icon, texture.icon_state, plane = FLOOR_PLANE, alpha = 0, color = texture.color)
	MA.appearance_flags = RESET_ALPHA | RESET_COLOR	
	MA.alpha = texture.alpha //Why do I have to set this here, why can't it just work in the proc?
	MA.blend_mode = BLEND_MULTIPLY
	add_overlay(MA)
	parent_texture = _texture

//Subtle hallway wear & tear
/datum/turf_texture/hallway
	icon_state = "hallway"
	alpha = 60

//Deep maint use
/datum/turf_texture/maint
	icon_state = "maint"
	alpha = 80

//Deep maint use for tiles
/datum/turf_texture/maint/tile
	icon_state = "maint_tile"
	alpha = 80
	priority = 2
