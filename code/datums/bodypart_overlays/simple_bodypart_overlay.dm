///For simple overlays that really dont need to be complicated. Sometimes icon_state and icon is enough
///Remember to set the layers or shit wont work
/datum/bodypart_overlay/simple
	///Icon state of the overlay
	var/icon_state
	///Icon of the overlay
	var/icon = 'icons/mob/human/species/misc/bodypart_overlay_simple.dmi'
	///Color we apply to our overlay (none by default)
	var/draw_color

/datum/bodypart_overlay/simple/get_image(obj/item/bodypart/limb, layer_index, layer_real)
	var/iconstate_to_use = icon_state + (layer_index ? "_[layer_index]" : "")
	return mutable_appearance(icon, "[iconstate_to_use]", layer = layer_real)

/datum/bodypart_overlay/simple/color_image(image/overlay, obj/item/bodypart/limb, layer_index)
	overlay.color = draw_color

/datum/bodypart_overlay/simple/icon_render_key(obj/item/bodypart/limb)
	. = ..()
	. += icon_state
	. += draw_color
