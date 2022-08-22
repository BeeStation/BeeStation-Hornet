/obj/structure/chair/fancy/sofa //like it's brother fancy chair, this is the father of all sofas
	name = "old father sofa"
	desc = "Now extint, this kind of sofa shouldn't even exists anymore, if you see this wild specimen, contact your local Nanotransen Anti-couch surfer department."
	icon_state = "sofa_middle"
	icon = 'icons/obj/beds_chairs/sofa.dmi'
	buildstackamount = 1
	item_chair = null

/obj/structure/chair/fancy/sofa/old
	color = rgb(141,70,0)
	name = "old sofa"
	desc = "An old design, but still does the job of being a sofa."
	icon_state = "sofa_middle"
	colorable = TRUE

/obj/structure/chair/fancy/sofa/old/left
	icon_state = "sofa_end_left"

/obj/structure/chair/fancy/sofa/old/right
	icon_state = "sofa_end_right"

/obj/structure/chair/fancy/sofa/old/concave
	icon_state = "sofa_corner_in"
	name = "old sofa"
	desc = "this kind of sofa definitely exists and there's nothing wrong with it, this one is concave."

/obj/structure/chair/fancy/sofa/old/convex
	icon_state = "sofa_corner_out"
	name = "old sofa"
	desc = "this kind of sofa definitely exists and there's nothing wrong with it, this one is convex."

/obj/structure/chair/fancy/sofa/old/corner/handle_layer() //only the armrest/back of this chair should cover the mob.
	return

// Original icon ported from Eris(?) and updated to work here.
/obj/structure/chair/fancy/sofa/corp
	name = "corporate sofa"
	desc = "Soft and cushy, yet professional."
	icon_state = "corp_sofa_middle"

/obj/structure/chair/fancy/sofa/corp/left
	icon_state = "corp_sofa_end_left"

/obj/structure/chair/fancy/sofa/corp/right
	icon_state = "corp_sofa_end_right"

/obj/structure/chair/fancy/sofa/corp/concave
	icon_state = "corp_sofa_corner_in"
	desc = "this kind of sofa definitely exists and there's nothing wrong with it, this one is concave."

/obj/structure/chair/fancy/sofa/corp/convex
	icon_state = "corp_sofa_corner_out"
	desc = "this kind of sofa definitely exists and there's nothing wrong with it, this one is convex."

/obj/structure/chair/fancy/sofa/corp/corner/handle_layer()
	return
