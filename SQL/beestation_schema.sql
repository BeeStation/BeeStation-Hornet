/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table ss13tgdb.SS13_admin
DROP TABLE IF EXISTS `SS13_admin`;
CREATE TABLE IF NOT EXISTS `SS13_admin` (
  `ckey` varchar(32) NOT NULL,
  `rank` varchar(32) NOT NULL,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_admin_log
DROP TABLE IF EXISTS `SS13_admin_log`;
CREATE TABLE IF NOT EXISTS `SS13_admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `round_id` int(11) NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `adminip` int(10) unsigned NOT NULL,
  `operation` enum('add admin','remove admin','change admin rank','add rank','remove rank','change rank flags') NOT NULL,
  `target` varchar(50) DEFAULT NULL,
  `log` varchar(1000) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=374 DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_admin_ranks
DROP TABLE IF EXISTS `SS13_admin_ranks`;
CREATE TABLE IF NOT EXISTS `SS13_admin_ranks` (
  `rank` varchar(32) NOT NULL,
  `flags` smallint(5) unsigned NOT NULL,
  `exclude_flags` smallint(5) unsigned NOT NULL,
  `can_edit_flags` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_ban
DROP TABLE IF EXISTS `SS13_ban`;
CREATE TABLE IF NOT EXISTS `SS13_ban` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `server_name` varchar(32) DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `role` varchar(32) DEFAULT NULL,
  `expiration_time` datetime DEFAULT NULL,
  `applies_to_admins` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `reason` varchar(2048) NOT NULL,
  `ckey` varchar(32) DEFAULT NULL,
  `ip` int(10) unsigned DEFAULT NULL,
  `computerid` varchar(32) DEFAULT NULL,
  `a_ckey` varchar(32) NOT NULL,
  `a_ip` int(10) unsigned NOT NULL,
  `a_computerid` varchar(32) NOT NULL,
  `who` varchar(2048) NOT NULL,
  `adminwho` varchar(2048) NOT NULL,
  `edits` text,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_ckey` varchar(32) DEFAULT NULL,
  `unbanned_ip` int(10) unsigned DEFAULT NULL,
  `unbanned_computerid` varchar(32) DEFAULT NULL,
  `unbanned_round_id` int(11) unsigned DEFAULT NULL,
  `global_ban` tinyint(1) unsigned NOT NULL DEFAULT '1',
  `hidden` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_ban_isbanned` (`ckey`,`role`,`unbanned_datetime`,`expiration_time`),
  KEY `idx_ban_isbanned_details` (`ckey`,`ip`,`computerid`,`role`,`unbanned_datetime`,`expiration_time`),
  KEY `idx_ban_count` (`bantime`,`a_ckey`,`applies_to_admins`,`unbanned_datetime`,`expiration_time`)
) ENGINE=InnoDB AUTO_INCREMENT=4916 DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_characters
DROP TABLE IF EXISTS `SS13_characters`;
CREATE TABLE IF NOT EXISTS `SS13_characters` (
	`slot` INT(11) UNSIGNED NOT NULL,
	`ckey` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`species` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci',
	`real_name` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`name_is_always_random` TINYINT(1) NOT NULL,
	`body_is_always_random` TINYINT(1) NOT NULL,
	`gender` VARCHAR(16) NOT NULL COLLATE 'utf8mb4_general_ci',
	`age` TINYINT(3) UNSIGNED NOT NULL,
	`hair_color` VARCHAR(8) NOT NULL COLLATE 'utf8mb4_general_ci',
	`gradient_color` VARCHAR(8) NOT NULL COLLATE 'utf8mb4_general_ci',
	`facial_hair_color` VARCHAR(8) NOT NULL COLLATE 'utf8mb4_general_ci',
	`eye_color` VARCHAR(8) NOT NULL COLLATE 'utf8mb4_general_ci',
	`skin_tone` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`hair_style_name` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`gradient_style` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`facial_style_name` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`underwear` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`underwear_color` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci',
	`undershirt` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`socks` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`backbag` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`jumpsuit_style` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`uplink_loc` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`features` MEDIUMTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`custom_names` MEDIUMTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`helmet_style` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`preferred_ai_core_display` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`preferred_security_department` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci',
	`joblessrole` TINYINT(4) UNSIGNED NOT NULL,
	`job_preferences` MEDIUMTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`all_quirks` MEDIUMTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`equipped_gear` MEDIUMTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`role_preferences` MEDIUMTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`slot`, `ckey`) USING BTREE
) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;



-- Dumping structure for table ss13tgdb.SS13_connection_log
DROP TABLE IF EXISTS `SS13_connection_log`;
CREATE TABLE IF NOT EXISTS `SS13_connection_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime DEFAULT NULL,
  `server_name` varchar(32) DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `ckey` varchar(45) DEFAULT NULL,
  `ip` int(10) unsigned NOT NULL,
  `computerid` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=564674 DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_death
DROP TABLE IF EXISTS `SS13_death`;
CREATE TABLE IF NOT EXISTS `SS13_death` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pod` varchar(50) NOT NULL,
  `x_coord` smallint(5) unsigned NOT NULL,
  `y_coord` smallint(5) unsigned NOT NULL,
  `z_coord` smallint(5) unsigned NOT NULL,
  `mapname` varchar(32) NOT NULL,
  `server_name` varchar(32) DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) NOT NULL,
  `tod` datetime NOT NULL COMMENT 'Time of death',
  `job` varchar(32) NOT NULL,
  `special` varchar(32) DEFAULT NULL,
  `name` varchar(96) NOT NULL,
  `byondkey` varchar(32) NOT NULL,
  `laname` varchar(96) DEFAULT NULL,
  `lakey` varchar(32) DEFAULT NULL,
  `bruteloss` smallint(5) unsigned NOT NULL,
  `brainloss` smallint(5) unsigned NOT NULL,
  `fireloss` smallint(5) unsigned NOT NULL,
  `oxyloss` smallint(5) unsigned NOT NULL,
  `toxloss` smallint(5) unsigned NOT NULL,
  `cloneloss` smallint(5) unsigned NOT NULL,
  `staminaloss` smallint(5) unsigned NOT NULL,
  `last_words` varchar(255) DEFAULT NULL,
  `suicide` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=233561 DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_feedback
DROP TABLE IF EXISTS `SS13_feedback`;
CREATE TABLE IF NOT EXISTS `SS13_feedback` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `server_name` varchar(32) DEFAULT NULL,
  `key_name` varchar(32) NOT NULL,
  `version` tinyint(3) unsigned NOT NULL,
  `key_type` enum('text','amount','tally','nested tally','associative') NOT NULL,
  `json` json NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=257254 DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_ipintel
DROP TABLE IF EXISTS `SS13_ipintel`;
CREATE TABLE IF NOT EXISTS `SS13_ipintel` (
  `ip` int(10) unsigned NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `intel` double NOT NULL DEFAULT '0',
  PRIMARY KEY (`ip`),
  KEY `idx_ipintel` (`ip`,`intel`,`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_legacy_population
DROP TABLE IF EXISTS `SS13_legacy_population`;
CREATE TABLE IF NOT EXISTS `SS13_legacy_population` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playercount` int(11) DEFAULT NULL,
  `admincount` int(11) DEFAULT NULL,
  `time` datetime NOT NULL,
  `server_name` varchar(32) DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=44238 DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_library
DROP TABLE IF EXISTS `SS13_library`;
CREATE TABLE IF NOT EXISTS `SS13_library` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author` varchar(45) NOT NULL,
  `title` varchar(50) NOT NULL,
  `content` text NOT NULL,
  `category` enum('Any','Fiction','Non-Fiction','Adult','Reference','Religion') NOT NULL,
  `ckey` varchar(32) NOT NULL DEFAULT 'LEGACY',
  `datetime` datetime NOT NULL,
  `deleted` tinyint(1) unsigned DEFAULT NULL,
  `round_id_created` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `deleted_idx` (`deleted`),
  KEY `idx_lib_id_del` (`id`,`deleted`),
  KEY `idx_lib_del_title` (`deleted`,`title`),
  KEY `idx_lib_search` (`deleted`,`author`,`title`,`category`)
) ENGINE=InnoDB AUTO_INCREMENT=326 DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_mentor
DROP TABLE IF EXISTS `SS13_mentor`;
CREATE TABLE IF NOT EXISTS `SS13_mentor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_mentor_memo
DROP TABLE IF EXISTS `SS13_mentor_memo`;
CREATE TABLE IF NOT EXISTS `SS13_mentor_memo` (
  `ckey` varchar(32) NOT NULL,
  `memotext` text NOT NULL,
  `timestamp` datetime NOT NULL,
  `last_editor` varchar(32) DEFAULT NULL,
  `edits` text,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;



-- Dumping structure for table ss13tgdb.SS13_messages
DROP TABLE IF EXISTS `SS13_messages`;
CREATE TABLE IF NOT EXISTS `SS13_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` enum('memo','message','message sent','note','watchlist entry') NOT NULL,
  `targetckey` varchar(32) NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `text` varchar(2048) NOT NULL,
  `timestamp` datetime NOT NULL,
  `expire_timestamp` datetime DEFAULT NULL,
  `severity` text,
  `playtime` int(11) unsigned NULL DEFAULT NULL,
  `server_name` varchar(32) DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `secret` tinyint(1) unsigned NOT NULL,
  `lasteditor` varchar(32) DEFAULT NULL,
  `edits` text,
  `deleted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_msg_ckey_time` (`targetckey`,`timestamp`,`deleted`),
  KEY `idx_msg_type_ckeys_time` (`type`,`targetckey`,`adminckey`,`timestamp`,`deleted`),
  KEY `idx_msg_type_ckey_time_odr` (`type`,`targetckey`,`timestamp`,`deleted`)
) ENGINE=InnoDB AUTO_INCREMENT=5177 DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_metacoin_item_purchases
DROP TABLE IF EXISTS `SS13_metacoin_item_purchases`;
CREATE TABLE IF NOT EXISTS `SS13_metacoin_item_purchases` (
  `ckey` varchar(32) NOT NULL,
  `purchase_date` datetime NOT NULL,
  `item_id` varchar(50) NOT NULL,
  `item_class` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_player
DROP TABLE IF EXISTS `SS13_player`;
CREATE TABLE IF NOT EXISTS `SS13_player` (
  `ckey` varchar(32) NOT NULL,
  `byond_key` varchar(32) NOT NULL DEFAULT 'Player',
  `firstseen` datetime NOT NULL,
  `firstseen_round_id` int(11) unsigned NOT NULL,
  `lastseen` datetime NOT NULL,
  `lastseen_round_id` int(11) unsigned NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `uuid` varchar(64) DEFAULT NULL,
  `lastadminrank` varchar(32) NOT NULL DEFAULT 'Player',
  `accountjoindate` date DEFAULT NULL,
  `flags` smallint(5) unsigned NOT NULL DEFAULT '0',
  `antag_tokens` tinyint(4) unsigned DEFAULT '0',
  `metacoins` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ckey`),
  UNIQUE KEY (`uuid`),
  KEY `idx_player_cid_ckey` (`computerid`,`ckey`),
  KEY `idx_player_ip_ckey` (`ip`,`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_poll_option
DROP TABLE IF EXISTS `SS13_poll_option`;
CREATE TABLE IF NOT EXISTS `SS13_poll_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pollid` int(11) NOT NULL,
  `text` varchar(255) NOT NULL,
  `minval` int(3) DEFAULT NULL,
  `maxval` int(3) DEFAULT NULL,
  `descmin` varchar(32) DEFAULT NULL,
  `descmid` varchar(32) DEFAULT NULL,
  `descmax` varchar(32) DEFAULT NULL,
  `default_percentage_calc` tinyint(1) unsigned NOT NULL DEFAULT '1',
  `deleted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_pop_pollid` (`pollid`)
) ENGINE=InnoDB AUTO_INCREMENT=133 DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_poll_question
DROP TABLE IF EXISTS `SS13_poll_question`;
CREATE TABLE IF NOT EXISTS `SS13_poll_question` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `polltype` enum('OPTION','TEXT','NUMVAL','MULTICHOICE','IRV') NOT NULL,
  `created_datetime` datetime NOT NULL,
  `starttime` datetime NOT NULL,
  `endtime` datetime NOT NULL,
  `question` varchar(255) NOT NULL,
  `subtitle` varchar(255) DEFAULT NULL,
  `adminonly` tinyint(1) unsigned NOT NULL,
  `multiplechoiceoptions` int(2) DEFAULT NULL,
  `createdby_ckey` varchar(32) NOT NULL,
  `createdby_ip` int(10) unsigned NOT NULL,
  `dontshow` tinyint(1) unsigned NOT NULL,
  `minimumplaytime` int(4) NOT NULL,
  `allow_revoting` tinyint(1) unsigned NOT NULL,
  `deleted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_pquest_question_time_ckey` (`question`,`starttime`,`endtime`,`createdby_ckey`,`createdby_ip`),
  KEY `idx_pquest_time_deleted_id` (`starttime`,`endtime`, `deleted`, `id`),
  KEY `idx_pquest_id_time_type_admin` (`id`,`starttime`,`endtime`,`polltype`,`adminonly`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_poll_textreply
DROP TABLE IF EXISTS `SS13_poll_textreply`;
CREATE TABLE IF NOT EXISTS `SS13_poll_textreply` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `replytext` varchar(2048) NOT NULL,
  `adminrank` varchar(32) NOT NULL,
  `deleted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_ptext_pollid_ckey` (`pollid`,`ckey`)
) ENGINE=InnoDB AUTO_INCREMENT=220 DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_poll_vote
DROP TABLE IF EXISTS `SS13_poll_vote`;
CREATE TABLE IF NOT EXISTS `SS13_poll_vote` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `optionid` int(11) NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `adminrank` varchar(32) NOT NULL,
  `rating` int(2) DEFAULT NULL,
  `deleted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_pvote_pollid_ckey` (`pollid`,`ckey`),
  KEY `idx_pvote_optionid_ckey` (`optionid`,`ckey`)
) ENGINE=InnoDB AUTO_INCREMENT=3936 DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_preferences
DROP TABLE IF EXISTS `SS13_preferences`;
CREATE TABLE `SS13_preferences` (
	`ckey` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`preference_tag` INT(11) NOT NULL,
	`preference_value` MEDIUMTEXT NULL COLLATE 'utf8mb4_general_ci',
	UNIQUE INDEX `prefbinding` (`ckey`, `preference_tag`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Dumping structure for table ss13tgdb.SS13_role_time
DROP TABLE IF EXISTS `SS13_role_time`;
CREATE TABLE IF NOT EXISTS `SS13_role_time` (
  `ckey` varchar(32) NOT NULL,
  `job` varchar(32) NOT NULL,
  `minutes` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ckey`,`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_round
DROP TABLE IF EXISTS `SS13_round`;
CREATE TABLE IF NOT EXISTS `SS13_round` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `initialize_datetime` datetime NOT NULL,
  `start_datetime` datetime DEFAULT NULL,
  `shutdown_datetime` datetime DEFAULT NULL,
  `end_datetime` datetime DEFAULT NULL,
  `server_name` varchar(32) DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `commit_hash` char(40) DEFAULT NULL,
  `game_mode` varchar(32) DEFAULT NULL,
  `game_mode_result` varchar(64) DEFAULT NULL,
  `end_state` varchar(64) DEFAULT NULL,
  `shuttle_name` varchar(64) DEFAULT NULL,
  `map_name` varchar(32) DEFAULT NULL,
  `station_name` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6524 DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_schema_revision
DROP TABLE IF EXISTS `SS13_schema_revision`;
CREATE TABLE IF NOT EXISTS `SS13_schema_revision` (
  `major` tinyint(3) unsigned NOT NULL,
  `minor` tinyint(3) unsigned NOT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`major`,`minor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT INTO `SS13_schema_revision` (`major`, `minor`) VALUES (6, 1);



-- Dumping structure for table ss13tgdb.SS13_stickyban
DROP TABLE IF EXISTS `SS13_stickyban`;
CREATE TABLE IF NOT EXISTS `SS13_stickyban` (
  `ckey` varchar(32) NOT NULL,
  `reason` varchar(2048) NOT NULL,
  `banning_admin` varchar(32) NOT NULL,
  `datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_stickyban_matched_cid
DROP TABLE IF EXISTS `SS13_stickyban_matched_cid`;
CREATE TABLE IF NOT EXISTS `SS13_stickyban_matched_cid` (
  `stickyban` varchar(32) NOT NULL,
  `matched_cid` varchar(32) NOT NULL,
  `first_matched` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_matched` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`stickyban`,`matched_cid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_stickyban_matched_ckey
DROP TABLE IF EXISTS `SS13_stickyban_matched_ckey`;
CREATE TABLE IF NOT EXISTS `SS13_stickyban_matched_ckey` (
  `stickyban` varchar(32) NOT NULL,
  `matched_ckey` varchar(32) NOT NULL,
  `first_matched` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_matched` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `exempt` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`stickyban`,`matched_ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- Dumping structure for table ss13tgdb.SS13_stickyban_matched_ip
DROP TABLE IF EXISTS `SS13_stickyban_matched_ip`;
CREATE TABLE IF NOT EXISTS `SS13_stickyban_matched_ip` (
  `stickyban` varchar(32) NOT NULL,
  `matched_ip` int(10) unsigned NOT NULL,
  `first_matched` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_matched` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`stickyban`,`matched_ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `achievements`
--
DROP TABLE IF EXISTS `SS13_achievements`;
CREATE TABLE IF NOT EXISTS `SS13_achievements` (
	`ckey` VARCHAR(32) NOT NULL,
	`achievement_key` VARCHAR(32) NOT NULL,
	`value` INT NULL,
	`last_updated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`ckey`,`achievement_key`)
) ENGINE=InnoDB;

DELIMITER $$
CREATE PROCEDURE `set_poll_deleted`(
	IN `poll_id` INT
)
SQL SECURITY INVOKER
BEGIN
UPDATE `SS13_poll_question` SET deleted = 1 WHERE id = poll_id;
UPDATE `SS13_poll_option` SET deleted = 1 WHERE pollid = poll_id;
UPDATE `SS13_poll_vote` SET deleted = 1 WHERE pollid = poll_id;
UPDATE `SS13_poll_textreply` SET deleted = 1 WHERE pollid = poll_id;
END
$$
DELIMITER ;

DROP TABLE IF EXISTS `SS13_achievement_metadata`;
CREATE TABLE IF NOT EXISTS `SS13_achievement_metadata` (
	`achievement_key` VARCHAR(32) NOT NULL,
	`achievement_version` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
	`achievement_type` enum('achievement','score','award') NULL DEFAULT NULL,
	`achievement_name` VARCHAR(64) NULL DEFAULT NULL,
	`achievement_description` VARCHAR(512) NULL DEFAULT NULL,
	PRIMARY KEY (`achievement_key`)
) ENGINE=InnoDB;





/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
