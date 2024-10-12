Feature: Crafting Test
  In order to verify crafting interactions with various materials
  a human should use an item in hand and verify that
  a user interface window opens for crafting

  Scenario Outline: Crafting test for different materials
    Given the player is holding <item>
    When the human uses the item
    Then a TGUI window should open

  Examples:
    | item                                              |
    | /obj/item/stack/ore/glass                         |
    | /obj/item/stack/rods                              |
    | /obj/item/stack/sheet/mineral/bananium            |
    | /obj/item/stack/sheet/mineral/adamantine          |
    | /obj/item/stack/sheet/mineral/abductor            |
    | /obj/item/stack/sheet/glass                       |
    | /obj/item/stack/sheet/rglass                      |
    | /obj/item/stack/sheet/plasmaglass                 |
    | /obj/item/stack/sheet/plasmarglass                |
    | /obj/item/stack/sheet/titaniumglass               |
    | /obj/item/stack/sheet/plastitaniumglass           |
    | /obj/item/stack/sheet/mineral/sandstone           |
    | /obj/item/stack/sheet/mineral/diamond             |
    | /obj/item/stack/sheet/mineral/uranium             |
    | /obj/item/stack/sheet/mineral/plasma              |
    | /obj/item/stack/sheet/mineral/gold                |
    | /obj/item/stack/sheet/mineral/silver              |
    | /obj/item/stack/sheet/mineral/copper              |
    | /obj/item/stack/sheet/mineral/titanium            |
    | /obj/item/stack/sheet/mineral/plastitanium        |
    | /obj/item/stack/sheet/iron                        |
    | /obj/item/stack/sheet/plasteel                    |
    | /obj/item/stack/sheet/runed_metal                 |
    | /obj/item/stack/sheet/brass                       |
    | /obj/item/stack/sheet/bronze                      |
    | /obj/item/stack/sheet/wax                         |
    | /obj/item/stack/sheet/sandbags                    |
    | /obj/item/stack/sheet/snow                        |
    | /obj/item/stack/sheet/plastic                     |
    | /obj/item/stack/sheet/cardboard                   |
    | /obj/item/stack/sheet/meat                        |
    | /obj/item/stack/sheet/cotton/cloth                |
    | /obj/item/stack/sheet/cotton/cloth/durathread     |
    | /obj/item/stack/sheet/silk                        |
    | /obj/item/stack/sheet/animalhide/human            |
    | /obj/item/stack/sheet/animalhide/corgi            |
    | /obj/item/stack/sheet/animalhide/gondola          |
    | /obj/item/stack/sheet/animalhide/monkey           |
    | /obj/item/stack/sheet/animalhide/xeno             |
    | /obj/item/stack/sheet/leather                     |
    | /obj/item/stack/sheet/sinew                       |
    | /obj/item/stack/sheet/wood                        |
    | /obj/item/stack/sheet/bamboo                      |
    | /obj/item/stack/sheet/paperframes                 |
    | /obj/item/stack/cable_coil                        |
