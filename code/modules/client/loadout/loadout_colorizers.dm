// DO NOT CHANGE display_name
// Colorizers should ideally be restricted to the jobs that they are most relevant to
// This prevents people with lots of colorizer's bags overflowing with useless ones on spawn

/datum/gear/colorizer
    subtype_path = /datum/gear/colorizer
    sort_category = "Colorizers"
    cost = 20000

/datum/gear/colorizer/capcloakroyal
    display_name = "Captain's Cloak Colorizer (Royal)"
    path = /obj/item/colorizer/capcloakroyal
    allowed_roles = list("Captain")

/datum/gear/colorizer/hoscloakroyal
    display_name = "Head of Security's Cloak Colorizer (Royal)"
    path = /obj/item/colorizer/hoscloakroyal
    allowed_roles = list("Head of Security")

/datum/gear/colorizer/rdcloakroyal
    display_name = "Research Director's Cloak Colorizer (Royal)"
    path = /obj/item/colorizer/rdcloakroyal
    allowed_roles = list("Research Director")

/datum/gear/colorizer/iandeathsquad
    display_name = "Ian Colorizer (Death Squad)"
    path = /obj/item/colorizer/iandeathsquad
    allowed_roles = list("Head of Personnel")
    cost = 20000
