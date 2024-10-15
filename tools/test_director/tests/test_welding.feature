Feature: Welding Tests
  Perform various different tests that involve a welding tool.

  Scenario: Window Repair
    Given welder is defined as new /obj/item/weldingtool
    And player is holding welder
    And window is defined as new /obj/structure/window
    And take_damage(1) is called on window
    And window obj_integrity should not be its max_integrity
    When the player clicks on window
    And waits 10 seconds
    Then window obj_integrity should be its max_integrity
