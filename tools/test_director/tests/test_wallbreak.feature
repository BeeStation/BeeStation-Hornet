Feature: Wallbreaking
  Various tests to ensure that wall integrity works as expected.

  Scenario Outline: Simplemob Breaking
    Given player is <mob_type>
    And wall is defined as new /turf/closed/wall
    When player clicks on wall
    Then the wall's integrity should be not be its max_integrity

    Examples:
      | mob_type |
      | /mob/living/simple_animal/hostile/construct/juggernaut |
