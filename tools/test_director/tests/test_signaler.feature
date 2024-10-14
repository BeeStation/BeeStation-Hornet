Feature: Signal Tests

  Background:
    Given the following code is injected:
      """
      /obj/item/assembly/signaler/debug
        var/passed = FALSE

      /obj/item/assembly/signaler/debug/pulse(radio = FALSE)
        ..()
        passed = TRUE
      """

  Scenario: Test Signaler Usage
    Given remote is defined as new /obj/item/assembly/signaler
    And reciever is defined as new /obj/item/assembly/signaler/debug
    And the remote code is DEFAULT_SIGNALER_CODE
    And set_frequency(FREQ_SIGNALER) is called on remote
    And the reciever code is DEFAULT_SIGNALER_CODE
    And set_frequency(FREQ_SIGNALER) is called on reciever
    When signal() is called on remote
    Then reciever passed should be TRUE
