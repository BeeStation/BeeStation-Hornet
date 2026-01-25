/**
 * Update script for the gear migration PR.
 * This script can be executed to migrate a database into the new gear system, the script
 * only makes the changes necessary.
 * Author: PowerfulBacon
 */

-- =======================================
-- Create the purchased gear table
-- =======================================

CREATE TABLE IF NOT EXISTS ss13_loadout_gear (
    ckey VARCHAR(32) NOT NULL,
    gear_path VARCHAR(255) NOT NULL,

    equipped TINYINT(1) NOT NULL DEFAULT 0,
    purchased_amount INT UNSIGNED NOT NULL DEFAULT 0,

	-- ckey + gear_path make the unique key
    PRIMARY KEY (ckey, gear_path)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =======================================
-- Transfer preference gear to the new table
-- Ignore duplicates as the old system has a bug where duplicate records are inserted
-- Ignore donator items because they are handled by the new system.
-- =======================================
INSERT INTO ss13_loadout_gear (ckey, gear_path, equipped, purchased_amount)
SELECT DISTINCT
    p.ckey,
    jt.gear_path,
    0 AS equipped,
    1 AS purchased_amount
FROM ss13_preferences p
JOIN JSON_TABLE(
    p.preference_value,
    '$[*]' COLUMNS (
        gear_path VARCHAR(255) PATH '$'
    )
) AS jt
WHERE p.preference_tag = 'purchased_gear' AND jt.gear_path NOT LIKE '/datum/gear/donator%';

-- =======================================
-- Delete the purchased gear data
-- =======================================
DELETE FROM `ss13_preferences`
WHERE preference_tag = 'purchased_gear';

-- =======================================
-- Update equipped gear
-- =======================================
INSERT INTO ss13_loadout_gear (ckey, gear_path, equipped, purchased_amount)
SELECT
    p.ckey,
    jt.gear_path,
    1 AS equipped,
    0 AS purchased_amount
FROM ss13_preferences p
JOIN JSON_TABLE(
    p.preference_value,
    '$[*]' COLUMNS (
        gear_path VARCHAR(255) PATH '$'
    )
) AS jt
WHERE p.preference_tag = 'equipped_gear'
ON DUPLICATE KEY UPDATE
    equipped = 1;

-- Delete the purchased gear data
DELETE FROM `ss13_preferences`
WHERE preference_tag = 'equipped_gear';

-- =======================================
DROP PROCEDURE IF EXISTS equip_gear;
-- =======================================

DELIMITER $$

-- =======================================
-- Create procedure for equipping gear
-- =======================================
CREATE PROCEDURE equip_gear (
	IN ckey VARCHAR(32),
	IN equipped_gear VARCHAR(255),
	IN unequipped_gear TEXT
)
SQL SECURITY INVOKER
BEGIN

INSERT INTO ss13_loadout_gear (ckey, gear_path, equipped, purchased_amount)
VALUES (ckey, equipped_gear, 1, 0)
ON DUPLICATE KEY UPDATE
	equipped = 1;

UPDATE ss13_loadout_gear SET equipped = 0 WHERE ckey = ckey AND gear_path in (unequipped_gear);

END
$$

-- =======================================
DROP PROCEDURE IF EXISTS purchase_gear
-- =======================================
$$

-- =======================================
-- Create procedure for purchasing gear
-- =======================================
CREATE PROCEDURE purchase_gear (
	IN _ckey VARCHAR(32),
	IN _gear_path VARCHAR(255),
	IN _cost INT
)
SQL SECURITY INVOKER
BEGIN

START TRANSACTION;

-- Lock player row and check balance
SELECT metacoins
INTO @current_metacoins
FROM ss13_player
WHERE ckey = _ckey
FOR UPDATE;

-- Deduct metacoins
UPDATE ss13_player
SET metacoins = metacoins - _cost
WHERE ckey = _ckey and @current_metacoins > _cost;

-- Insert or increment gear purchase
INSERT INTO ss13_loadout_gear (ckey, gear_path, equipped, purchased_amount)
SELECT _ckey, _gear_path, 0, 1
WHERE @current_metacoins > _cost
ON DUPLICATE KEY UPDATE
   purchased_amount = purchased_amount + 1;

SELECT @current_metacoins > _cost;

COMMIT;

END
$$

DELIMITER ;


