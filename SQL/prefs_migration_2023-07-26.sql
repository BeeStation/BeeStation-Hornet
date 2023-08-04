/*

Tested on MariaDB 10.11

DO NOT RUN WITHOUT TAKING A FULL BACKUP.
DO NOT RUN MORE THAN ONCE.
DO NOT RUN COLUMN REMOVALS UNTIL DATA IS VERIFIED.
- Allows nulls for `SS13_characters` columns (required for partial INSERT INTO ON DUPLICATE KEY UPDATE)
- Alters some datatypes to fit new data.
- Turns `SS13_characters`.`features` and `SS13_characters`.`custom_names` JSON objects into individual columns, removes the original columns.
- Updates `SS13_preferences`.`preference_tag` to text.
- Updates various `SS13_preferences` values to new ones.
- Flips `SS13_preferences`.`key_bindings` JSON structure.
*/

/* CHARACTER PREFERENCES */

/* Add new columns and allow nulls on existing columns. Tweak a few datatypes to allow for new data. */

ALTER TABLE `SS13_characters`
    MODIFY COLUMN `species` VARCHAR(32) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `real_name` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL,
    ADD COLUMN IF NOT EXISTS `human_name` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `real_name`,
    ADD COLUMN IF NOT EXISTS `mime_name` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `human_name`,
    ADD COLUMN IF NOT EXISTS `clown_name` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `mime_name`,
    ADD COLUMN IF NOT EXISTS `cyborg_name` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `clown_name`,
    ADD COLUMN IF NOT EXISTS `ai_name` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `cyborg_name`,
    ADD COLUMN IF NOT EXISTS `religion_name` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `ai_name`,
    ADD COLUMN IF NOT EXISTS `deity_name` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `religion_name`,
    ADD COLUMN IF NOT EXISTS `bible_name` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `deity_name`,
    MODIFY COLUMN `name_is_always_random` TINYINT(1) NULL,
    MODIFY COLUMN `body_is_always_random` TINYINT(1) NULL,
    MODIFY COLUMN `gender` VARCHAR(16) COLLATE 'utf8mb4_general_ci' NULL,
    ADD COLUMN IF NOT EXISTS `body_model` VARCHAR(16) COLLATE 'utf8mb4_general_ci' NULL AFTER `gender`,
    ADD COLUMN IF NOT EXISTS `body_size` VARCHAR(16) COLLATE 'utf8mb4_general_ci' NULL AFTER `body_model`,
    MODIFY COLUMN `age` TINYINT(3) UNSIGNED NULL,
    MODIFY COLUMN `hair_color` VARCHAR(8) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `gradient_color` VARCHAR(8) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `facial_hair_color` VARCHAR(8) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `eye_color` VARCHAR(8) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `skin_tone` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `hair_style_name` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `gradient_style` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `facial_style_name` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `underwear` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `underwear_color` VARCHAR(8) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `undershirt` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `socks` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `backbag` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `jumpsuit_style` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `uplink_loc` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL,
    ADD COLUMN IF NOT EXISTS `pda_theme` VARCHAR(32) COLLATE 'utf8mb4_general_ci' NULL AFTER `uplink_loc`,
    ADD COLUMN IF NOT EXISTS `pda_classic_color` VARCHAR(8) COLLATE 'utf8mb4_general_ci' NULL AFTER `pda_theme`,
    ADD COLUMN IF NOT EXISTS `feature_apid_stripes` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `pda_classic_color`,
    ADD COLUMN IF NOT EXISTS `feature_apid_antenna` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_apid_stripes`,
    ADD COLUMN IF NOT EXISTS `feature_apid_headstripes` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_apid_antenna`,
    ADD COLUMN IF NOT EXISTS `feature_moth_antennae` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_apid_headstripes`,
    ADD COLUMN IF NOT EXISTS `feature_moth_markings` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_moth_antennae`,
    ADD COLUMN IF NOT EXISTS `feature_moth_wings` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_moth_markings`,
    ADD COLUMN IF NOT EXISTS `feature_ethcolor` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_moth_wings`,
    ADD COLUMN IF NOT EXISTS `feature_insect_type` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_ethcolor`,
    ADD COLUMN IF NOT EXISTS `feature_ipc_screen` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_insect_type`,
    ADD COLUMN IF NOT EXISTS `feature_ipc_antenna` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_ipc_screen`,
    ADD COLUMN IF NOT EXISTS `feature_ipc_chassis` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_ipc_antenna`,
    ADD COLUMN IF NOT EXISTS `feature_ipc_screen_color` VARCHAR(8) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_ipc_chassis`,
    ADD COLUMN IF NOT EXISTS `feature_ipc_antenna_color` VARCHAR(8) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_ipc_screen_color`,
    ADD COLUMN IF NOT EXISTS `feature_lizard_body_markings` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_ipc_antenna_color`,
    ADD COLUMN IF NOT EXISTS `feature_lizard_frills` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_lizard_body_markings`,
    ADD COLUMN IF NOT EXISTS `feature_lizard_horns` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_lizard_frills`,
    ADD COLUMN IF NOT EXISTS `feature_lizard_legs` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_lizard_horns`,
    ADD COLUMN IF NOT EXISTS `feature_lizard_snout` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_lizard_legs`,
    ADD COLUMN IF NOT EXISTS `feature_lizard_spines` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_lizard_snout`,
    ADD COLUMN IF NOT EXISTS `feature_lizard_tail` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_lizard_spines`,
    ADD COLUMN IF NOT EXISTS `feature_mcolor` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_lizard_tail`,
    ADD COLUMN IF NOT EXISTS `feature_human_tail` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_mcolor`,
    ADD COLUMN IF NOT EXISTS `feature_human_ears` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_human_tail`,
    ADD COLUMN IF NOT EXISTS `feature_psyphoza_cap` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL AFTER `feature_human_ears`,
    MODIFY COLUMN `helmet_style` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `preferred_ai_core_display` VARCHAR(64) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `preferred_security_department` VARCHAR(32) COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `joblessrole` TINYINT(4) UNSIGNED NULL,
    MODIFY COLUMN `job_preferences` MEDIUMTEXT COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `all_quirks` MEDIUMTEXT COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `equipped_gear` MEDIUMTEXT COLLATE 'utf8mb4_general_ci' NULL,
    MODIFY COLUMN `role_preferences` MEDIUMTEXT COLLATE 'utf8mb4_general_ci' NULL,
    ADD COLUMN IF NOT EXISTS `randomise` MEDIUMTEXT COLLATE 'utf8mb4_general_ci' NULL AFTER `role_preferences`;

/* Copy eye colors onto IPC screen color, now that it's separate */
UPDATE `SS13_characters` SET `feature_ipc_screen` = `eye_color`;

/* Flatten features JSON into its own columns */

UPDATE SS13_characters t1, JSON_TABLE(
    t1.features, '$' COLUMNS(
        body_size_old TEXT PATH '$.body_size',
        mcolor_old TEXT PATH '$.mcolor',
        ethcolor_old TEXT PATH '$.ethcolor',
        tail_lizard_old TEXT PATH '$.lizard_tail',
        snout_old TEXT PATH '$.snout',
        horns_old TEXT PATH '$.horns',
        frills_old TEXT PATH '$.frills',
        spines_old TEXT PATH '$.spines',
        body_markings_old TEXT PATH '$.body_markings',
        moth_wings_old TEXT PATH '$.moth_wings',
        ipc_screen_old TEXT PATH '$.ipc_screen',
        ipc_antenna_old TEXT PATH '$.ipc_antenna',
        ipc_chassis_old TEXT PATH '$.ipc_chassis',
        insect_type_old TEXT PATH '$.insect_type',
        tail_human_old TEXT PATH '$.tail_human',
        ears_old TEXT PATH '$.ears',
        body_model_old TEXT PATH '$.body_model',
        feature_lizard_legs_old TEXT PATH '$.feature_lizard_legs',
        moth_antennae_old TEXT PATH '$.moth_antennae',
        moth_markings_old TEXT PATH '$.moth_markings',
        apid_antenna_old TEXT PATH '$.apid_antenna',
        apid_stripes_old TEXT PATH '$.apid_stripes',
        apid_headstripes_old TEXT PATH '$.apid_headstripes'
    )
) AS jt
SET body_size = jt.body_size_old,
    feature_mcolor = jt.mcolor_old,
    feature_ethcolor = jt.ethcolor_old,
    feature_lizard_tail = jt.tail_lizard_old,
    feature_lizard_snout = jt.snout_old,
    feature_lizard_horns = jt.horns_old,
    feature_lizard_frills = jt.frills_old,
    feature_lizard_spines = jt.spines_old,
    feature_lizard_body_markings = jt.body_markings_old,
    feature_moth_wings = jt.moth_wings_old,
    feature_ipc_screen = jt.ipc_screen_old,
    feature_ipc_antenna = jt.ipc_antenna_old,
    feature_ipc_chassis = jt.ipc_chassis_old,
    feature_insect_type = jt.insect_type_old,
    feature_human_tail = jt.tail_human_old,
    feature_human_ears = jt.ears_old,
    body_model = jt.body_model_old,
    feature_lizard_legs = jt.feature_lizard_legs_old,
    feature_moth_antennae = jt.moth_antennae_old,
    feature_moth_markings = jt.moth_markings_old,
    feature_apid_antenna = jt.apid_antenna_old,
    feature_apid_stripes = jt.apid_stripes_old,
    feature_apid_headstripes = jt.apid_headstripes_old;

/* Flatten custom_names JSON into its own columns */

UPDATE SS13_characters t1, JSON_TABLE(
    t1.custom_names, '$' COLUMNS(
        human_name_old TEXT PATH '$.human',
        mime_name_old TEXT PATH '$.mime',
        clown_name_old TEXT PATH '$.clown',
        cyborg_name_old TEXT PATH '$.cyborg',
        ai_name_old TEXT PATH '$.ai',
        religion_name_old TEXT PATH '$.religion',
        deity_name_old TEXT PATH '$.deity'
    )
) AS jt
SET human_name = jt.human_name_old,
    mime_name = jt.mime_name_old,
    clown_name = jt.clown_name_old,
    cyborg_name = jt.cyborg_name_old,
    ai_name = jt.ai_name_old,
    religion_name = jt.religion_name_old,
    deity_name = jt.deity_name_old;

/* Delete unused data (features and custom_names, which are now flattened) */

ALTER TABLE `SS13_characters` DROP COLUMN IF EXISTS `features`;
ALTER TABLE `SS13_characters` DROP COLUMN IF EXISTS `custom_names`;

/* PLAYER PREFERENCES */

/* Convert tags to strings */

ALTER TABLE `SS13_preferences` MODIFY COLUMN `preference_tag` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci';

UPDATE `SS13_preferences`
    SET `preference_tag` = CASE
    WHEN `preference_tag` = '5' THEN 'last_changelog'
    WHEN `preference_tag` = '6' THEN 'ui_style'
    WHEN `preference_tag` = '7' THEN 'outline_color'
    WHEN `preference_tag` = '8' THEN 'show_balloon_alerts'
    WHEN `preference_tag` = '9' THEN 'default_slot'
    WHEN `preference_tag` = '11' THEN 'ghost_form'
    WHEN `preference_tag` = '12' THEN 'ghost_orbit'
    WHEN `preference_tag` = '13' THEN 'ghost_accs'
    WHEN `preference_tag` = '14' THEN 'ghost_others'
    WHEN `preference_tag` = '15' THEN 'preferred_map'
    WHEN `preference_tag` = '16' THEN 'ignoring'
    WHEN `preference_tag` = '17' THEN 'clientfps'
    WHEN `preference_tag` = '18' THEN 'parallax'
    WHEN `preference_tag` = '19' THEN 'pixel_size'
    WHEN `preference_tag` = '20' THEN 'scaling_method'
    WHEN `preference_tag` = '21' THEN 'tip_delay'
    WHEN `preference_tag` = '24' THEN 'key_bindings'
    WHEN `preference_tag` = '25' THEN 'purchased_gear'
    WHEN `preference_tag` = '26' THEN 'be_special'
    WHEN `preference_tag` = '27' THEN 'pai_name'
    WHEN `preference_tag` = '28' THEN 'pai_description'
    WHEN `preference_tag` = '29' THEN 'pai_comment'
    ELSE `preference_tag`
    END;

/* Convert to new values */

START TRANSACTION;

UPDATE `SS13_preferences` SET `preference_value` = CASE
    WHEN `preference_value` = '1' THEN 'Default sprites'
    WHEN `preference_value` = '50' THEN 'Only directional sprites'
    WHEN `preference_value` = '100' THEN 'Full accessories'
    ELSE `preference_value`
    END WHERE `preference_tag` = 'ghost_accs';

UPDATE `SS13_preferences` SET `preference_value` = CASE
    WHEN `preference_value` = '1' THEN 'White ghosts'
    WHEN `preference_value` = '50' THEN 'Default sprites'
    WHEN `preference_value` = '100' THEN 'Their sprites'
    ELSE `preference_value`
    END WHERE `preference_tag` = 'ghost_others';

UPDATE `SS13_preferences` SET `preference_value` = '-1' WHERE `preference_tag` = 'clientfps' AND `preference_value` = '40';

UPDATE `SS13_preferences` SET `preference_value` = CASE
    WHEN `preference_value` = '-1' THEN 'Insane'
    WHEN `preference_value` = '0' THEN 'High'
    WHEN `preference_value` = '1' THEN 'Medium'
    WHEN `preference_value` = '2' THEN 'Low'
    WHEN `preference_value` = '3' THEN 'Disabled'
    ELSE `preference_value`
    END WHERE `preference_tag` = 'parallax';

/* Finish value conversions */

COMMIT;

/* Convert toggles */

START TRANSACTION;

/* toggles 1 */

INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'sound_adminhelp',IF(`preference_value` & (1<<0) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'sound_midi',IF(`preference_value` & (1<<1) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'sound_ambience',IF(`preference_value` & (1<<2) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'sound_lobby',IF(`preference_value` & (1<<3) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'member_public',IF(`preference_value` & (1<<4) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'intent_style',IF(`preference_value` & (1<<5) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'sound_instruments',IF(`preference_value` & (1<<7) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'sound_ship_ambience',IF(`preference_value` & (1<<8) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'sound_prayers',IF(`preference_value` & (1<<9) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'announce_login',IF(`preference_value` & (1<<10) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'sound_announcements',IF(`preference_value` & (1<<11) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'death_rattle',IF(`preference_value` & (1<<12) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'arrivals_rattle',IF(`preference_value` & (1<<13) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'combohud_lighting',IF(`preference_value` & (1<<14) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'deadmin_always',IF(`preference_value` & (1<<15) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'deadmin_antagonist',IF(`preference_value` & (1<<16) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'deadmin_position_head',IF(`preference_value` & (1<<17) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'deadmin_position_security',IF(`preference_value` & (1<<18) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'deadmin_position_silicon',IF(`preference_value` & (1<<19) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'itemoutline_pref',IF(`preference_value` & (1<<20) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'chat_on_map',IF(`preference_value` & (1<<21) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'see_chat_non_mob',IF(`preference_value` & (1<<22) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'see_rc_emotes',IF(`preference_value` & (1<<23) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '1'
);

/* toggles 2 */

INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'tgui_fancy',IF(`preference_value` & (1<<0) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'tgui_lock',IF(`preference_value` & (1<<1) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'buttons_locked',IF(`preference_value` & (1<<2) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'windowflashing',IF(`preference_value` & (1<<3) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'crew_objectives',IF(`preference_value` & (1<<4) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'ghost_hud',IF(`preference_value` & (1<<5) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'inquisitive_ghost',IF(`preference_value` & (1<<6) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'glasses_color',IF(`preference_value` & (1<<7) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'ambientocclusion',IF(`preference_value` & (1<<8) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'auto_fit_viewport',IF(`preference_value` & (1<<9) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'enable_tips',IF(`preference_value` & (1<<10) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'show_credits',IF(`preference_value` & (1<<11) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'hotkeys',IF(`preference_value` & (1<<12) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'sound_soundtrack',IF(`preference_value` & (1<<13) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'tgui_input',IF(`preference_value` & (1<<14) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'tgui_input_large',IF(`preference_value` & (1<<15) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'tgui_input_swapped',IF(`preference_value` & (1<<16) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'tgui_say',IF(`preference_value` & (1<<17) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'tgui_say_light_mode',IF(`preference_value` & (1<<18) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'tgui_say_show_prefix',IF(`preference_value` & (1<<19) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'sound_adminalert',IF(`preference_value` & (1<<20) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '2'
);

/* chat toggles */

INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'chat_ooc',IF(`preference_value` & (1<<0) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '10'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'chat_dead',IF(`preference_value` & (1<<1) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '10'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'chat_ghostears',IF(`preference_value` & (1<<2) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '10'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'chat_ghostsight',IF(`preference_value` & (1<<3) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '10'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'chat_prayer',IF(`preference_value` & (1<<4) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '10'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'chat_radio',IF(`preference_value` & (1<<5) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '10'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'chat_pullr',IF(`preference_value` & (1<<6) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '10'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'chat_ghostwhisper',IF(`preference_value` & (1<<7) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '10'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'chat_ghostpda',IF(`preference_value` & (1<<8) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '10'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'chat_ghostradio',IF(`preference_value` & (1<<9) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '10'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'chat_bankcard',IF(`preference_value` & (1<<10) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '10'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'chat_ghostlaws',IF(`preference_value` & (1<<11) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '10'
);
INSERT IGNORE INTO `SS13_preferences` (`ckey`, `preference_tag`, `preference_value`) (
    SELECT `ckey`,'chat_ghostfollowmindless',IF(`preference_value` & (1<<12) > 0, 1, 0) AS `preference_value` FROM `SS13_preferences` WHERE `preference_tag` = '10'
);

/* Finish toggle conversions */

COMMIT;

/* Delete unused data (toggles and old PDA preferences, moved to character) */

DELETE FROM `SS13_preferences` WHERE `preference_tag` IN ('1', '2', '10', '22', '23');
