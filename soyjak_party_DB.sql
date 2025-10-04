-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 04, 2025 at 03:40 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `soyjak_party2`
--

-- --------------------------------------------------------

--
-- Table structure for table `characterequipment`
--

CREATE TABLE `characterequipment` (
  `char_id` int(10) UNSIGNED NOT NULL,
  `item_id` int(10) UNSIGNED NOT NULL,
  `slot_type_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `characterequipment`
--

INSERT INTO `characterequipment` (`char_id`, `item_id`, `slot_type_id`) VALUES
(1, 1, 1),
(16, 1, 1),
(16, 2, 2),
(1, 5, 4),
(1, 13, 3),
(7, 19, 4);

--
-- Triggers `characterequipment`
--
DELIMITER $$
CREATE TRIGGER `trg_bind_on_equip` AFTER INSERT ON `characterequipment` FOR EACH ROW BEGIN
    IF (SELECT bind_on_equip FROM equipment WHERE item_id = NEW.item_id) THEN
        UPDATE equipment
        SET is_bound = TRUE
        WHERE item_id = NEW.item_id;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_item_durability` BEFORE INSERT ON `characterequipment` FOR EACH ROW BEGIN
    DECLARE item_durability INT;
    DECLARE msg_text VARCHAR(255);

    SELECT durability INTO item_durability FROM Equipment WHERE item_id = NEW.item_id;

    IF item_durability = 0 THEN
        SET msg_text = CONCAT('Item ', NEW.item_id, ' has 0 durability and cannot be equipped');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg_text;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_item_level_requirement` BEFORE INSERT ON `characterequipment` FOR EACH ROW BEGIN
    DECLARE req_level INT;
    DECLARE char_level INT;
    DECLARE msg_text VARCHAR(255);

    SELECT level_requirement INTO req_level FROM equipment WHERE item_id = NEW.item_id;
    SELECT level_id INTO char_level FROM charactertable WHERE char_id = NEW.char_id;

    IF char_level < req_level THEN
        SET msg_text = CONCAT('Character level ', char_level, ' too low to equip item ', NEW.item_id, ' (requires ', req_level, ')');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg_text;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `characterstats`
--

CREATE TABLE `characterstats` (
  `char_id` int(10) UNSIGNED NOT NULL,
  `stat_id` int(10) UNSIGNED NOT NULL,
  `value` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `characterstats`
--

INSERT INTO `characterstats` (`char_id`, `stat_id`, `value`) VALUES
(1, 1, 15),
(1, 2, 10),
(1, 4, 12),
(2, 2, 8),
(2, 3, 18),
(2, 4, 6),
(3, 1, 10),
(3, 2, 15),
(3, 3, 5),
(3, 4, 8),
(7, 1, 14),
(7, 2, 12),
(7, 3, 10),
(9, 1, 18),
(9, 2, 15),
(9, 4, 16),
(10, 1, 18),
(10, 2, 15),
(10, 4, 16),
(11, 1, 14),
(11, 2, 12),
(11, 3, 10),
(12, 1, 12),
(12, 2, 9),
(12, 3, 10),
(13, 2, 10),
(13, 3, 11),
(13, 4, 8),
(14, 1, 13),
(14, 2, 11),
(14, 4, 9),
(15, 2, 10),
(15, 3, 11),
(15, 4, 8),
(16, 1, 16),
(16, 2, 15),
(16, 3, 12),
(16, 4, 14),
(17, 1, 13),
(17, 2, 11),
(17, 4, 9),
(30, 1, 10),
(30, 2, 15),
(30, 3, 5),
(30, 4, 8);

-- --------------------------------------------------------

--
-- Table structure for table `charactertable`
--

CREATE TABLE `charactertable` (
  `char_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(50) NOT NULL,
  `player_id` int(10) UNSIGNED NOT NULL,
  `template_id` int(10) UNSIGNED NOT NULL,
  `class_id` int(10) UNSIGNED NOT NULL,
  `level_id` int(10) UNSIGNED NOT NULL,
  `xp` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `charactertable`
--

INSERT INTO `charactertable` (`char_id`, `name`, `player_id`, `template_id`, `class_id`, `level_id`, `xp`, `is_active`) VALUES
(1, 'Chud', 2, 1, 1, 6, 1000, 1),
(2, 'Cobson', 2, 2, 2, 2, 200, 1),
(3, 'Glowjak', 2, 3, 3, 2, 100, 1),
(7, 'Soytan', 2, 13, 4, 2, 100, 1),
(9, 'Kuzjak', 2, 9, 1, 1, 0, 1),
(10, 'Kuzjak', 9, 9, 1, 5, 700, 1),
(11, 'Soytan', 9, 13, 4, 1, 0, 1),
(12, 'Corn cob', 9, 16, 1, 1, 0, 1),
(13, 'Shroomjak', 9, 18, 4, 1, 0, 1),
(14, 'Calmjak', 9, 19, 3, 1, 0, 1),
(15, 'Shroomjak', 5, 18, 4, 1, 50, 1),
(16, 'Lannajak', 5, 20, 3, 2, 150, 1),
(17, 'Calmjak', 5, 19, 3, 1, 50, 1),
(30, 'Glowjak', 22, 3, 3, 1, 0, 1);

--
-- Triggers `charactertable`
--
DELIMITER $$
CREATE TRIGGER `trg_check_level_id` BEFORE INSERT ON `charactertable` FOR EACH ROW BEGIN
    IF NEW.level_id < 1 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'level_id must be >= 1';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_max_characters` BEFORE INSERT ON `charactertable` FOR EACH ROW BEGIN
    DECLARE msg VARCHAR(255);
    DECLARE template_count INT;
    
    -- Check total character count (max 5 per player)
    IF (SELECT COUNT(*) FROM CharacterTable WHERE player_id = NEW.player_id) >= 5 THEN
        SET msg = CONCAT('Player ', NEW.player_id, ' already has 5 characters');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;
    
    -- Check if player already has this template
    SELECT COUNT(*) INTO template_count 
    FROM CharacterTable 
    WHERE player_id = NEW.player_id AND template_id = NEW.template_id;
    
    IF template_count > 0 THEN
        SET msg = CONCAT('Player already has this character');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_xp_level_match` BEFORE INSERT ON `charactertable` FOR EACH ROW BEGIN
    DECLARE required_xp INT;
    DECLARE msg_text VARCHAR(255);

    SELECT xp_required INTO required_xp
    FROM LevelTable
    WHERE level_id = NEW.level_id;

    IF NEW.xp < required_xp THEN
        SET msg_text = CONCAT('XP ', NEW.xp, ' is too low for level ', NEW.level_id, ' (needs at least ', required_xp, ')');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg_text;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `character_template`
--

CREATE TABLE `character_template` (
  `template_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(50) NOT NULL,
  `class_id` int(10) UNSIGNED NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `image` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `character_template`
--

INSERT INTO `character_template` (`template_id`, `name`, `class_id`, `description`, `is_active`, `image`) VALUES
(1, 'Chud', 1, 'A mysterious conspiracist', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423240655173586974/Chudjak.png?ex=68e04066&is=68deeee6&hm=4bde9054d9888dbb99868dee3f6b8a4eb85aa0f77fd4475f52a189dad64c7f03&'),
(2, 'Cobson', 2, 'An extremist warrior', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423241255210455162/Cobson.png?ex=68e040f5&is=68deef75&hm=d493bf997ddd639813ec08d7ea08a9918e4904786c59615c29a50badae29ecf3&'),
(3, 'Glowjak', 3, 'A government agent', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423241671751110708/800px-Super_Glowie_mind_wiping_device.png?ex=68e04159&is=68deefd9&hm=8ec0ac1171c94107f737bec62f4d0b5d0d7a7113c504bd0d98c8b7959994af3b&'),
(4, 'Dr. Soystein', 4, 'A paranoid scientist', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423241907710197914/800px-Soystein.png?ex=68e04191&is=68def011&hm=3f0aab768b38c4f51267eacd0afbf426a6eb4f61998e0c63ab5e733ffb3ba754&'),
(5, 'Impjak', 5, 'A chaotic anarchist', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423922869951529101/Impjak-1.png?ex=68e21303&is=68e0c183&hm=0ceb76afddc76ece63a224b8028d90839d0523edcd5ffdf76cf99c382fe23ff6&'),
(6, 'El Perro Rabioso', 1, 'A fierce conspiracist', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423242164455997521/Perrojak.png?ex=68e041ce&is=68def04e&hm=a6770be96b1fc40d4b7cbd55cbf36f4e0149f483345b59a1821890d38ef3d87c&'),
(7, 'Feraljak', 3, 'A wild glowie', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423242250871246890/800px-Feraljak.png?ex=68e041e3&is=68def063&hm=1932de89fd1621b849e2b9550a94c910179113ae58c2859969a2b212fd8075c0&'),
(8, 'Gapejak', 4, 'A surprised tinfoil', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423242305044877362/232px-Guinnessworldrecordsoyjak.png?ex=68e041f0&is=68def070&hm=5a704e7f4cfdb58b50e8c0f1a5636fb02dcba91c8426ac894bb4b1b51acb7bc3&'),
(9, 'Kuzjak', 1, 'A strong conspiracist', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423242502617432184/Kuz.png?ex=68e0421f&is=68def09f&hm=7f8824947279e1b5a844be47679bb4ce7d454010ad666b239f2d859ca8c700cf&'),
(10, 'Markiplier Soyjak', 2, 'A famous extremist', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423242592262557817/230px-Markiplier.png?ex=68e04234&is=68def0b4&hm=5c721f1c5fc5eb5d5f735d95f11571e8db975e326b9b84001ff03885be4e0fc4&'),
(11, 'Meximutt', 5, 'A southern anarchist', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423242661472637028/61492_-_SoyBooru.png?ex=68e04245&is=68def0c5&hm=eea12b56dc2f40f8f6dae425ee1785935e51a946528fbefb860743b8bf72660c&'),
(12, 'Nojak', 3, 'A mysterious glowie', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423242749427056650/Nojak.png?ex=68e0425a&is=68def0da&hm=f578c0d7b732743f8159a9a27c0a9a6829b0c9330f334dfa29c7d3ed67aca43c&'),
(13, 'Soytan', 4, 'A demonic tinfoil', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423244149083340830/5927620-20SoyBooru.png?ex=68e043a7&is=68def227&hm=8e737f573f5c0a5ff6402411b742de5553a692202735fc0f0f7cf861a8a06437&'),
(14, 'Circlejak', 3, 'A circular glowie', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423244294080434247/Eggjak.png?ex=68e043ca&is=68def24a&hm=de730727ae6e55883b2b645c8b34ee90bca5393316c602f90bdc915c1744d9e8&'),
(15, 'Colorjaks', 2, 'A colorful extremist', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423244404742819951/Original_colorfuljak.png?ex=68e043e4&is=68def264&hm=c3cc9f6e8f37b9a5f51f6bae1ce33bc3a2e664ba60b9b010be9e0c24d1791001&'),
(16, 'Corn cob', 1, 'A corny conspiracist', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423244501211676752/Cornson_marzo_30_2025.png?ex=68e043fb&is=68def27b&hm=e1a5db401c0d5c6619c15a04c73d94ced96357f8b1084c4f4d1eb683394e00de&'),
(17, 'Chadjak', 4, 'A confident tinfoil', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423244597215105134/BCchad.png?ex=68e04412&is=68def292&hm=5c26f7a55eefabb800ac0080c5e11d0fdd27eefa79a10f7c5dfdc957f692c0ce&'),
(18, 'Shroomjak', 4, 'Shroom Dealer', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423562711798648932/849_-_SoyBooru.png?ex=68e0c397&is=68df7217&hm=b988f8639a28d7e443824df6b62b14bdbb82673b128d6cff652e6aecc5edc1df&'),
(19, 'Calmjak', 3, 'Calm', 1, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423562397645410325/2172_-_SoyBooru.png?ex=68e0c34c&is=68df71cc&hm=b7a8abafa2ab5e2ae864fa803511353bb2e7e61649dc04c1e8bdad1b032ca48b&'),
(20, 'Lannajak', 3, 'A Lanna Glowie', 1, 'https://cdn.discordapp.com/attachments/1203015746867830905/1245429003314004061/image.png?ex=68e20265&is=68e0b0e5&hm=2fb3740a17f6c24b515bd75274ad280dd6181519ce903deb51871533398d79ed&');

-- --------------------------------------------------------

--
-- Table structure for table `classtable`
--

CREATE TABLE `classtable` (
  `class_id` int(10) UNSIGNED NOT NULL,
  `class_name` varchar(50) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `classtable`
--

INSERT INTO `classtable` (`class_id`, `class_name`, `description`) VALUES
(1, 'Conspiracist', 'Conspiracist extraordinaire'),
(2, 'Extremist', 'Brute force'),
(3, 'Glowie', 'The Government'),
(4, 'Tinfoil', 'Always paranoid'),
(5, 'Anarchist', 'Chaos brings strength');

-- --------------------------------------------------------

--
-- Table structure for table `equipment`
--

CREATE TABLE `equipment` (
  `item_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(50) NOT NULL,
  `slot_type_id` int(10) UNSIGNED NOT NULL,
  `level_requirement` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `stat_bonus` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`stat_bonus`)),
  `durability` int(10) UNSIGNED DEFAULT 100,
  `max_durability` int(10) UNSIGNED DEFAULT 100,
  `bind_on_equip` tinyint(1) NOT NULL DEFAULT 0,
  `image` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `equipment`
--

INSERT INTO `equipment` (`item_id`, `name`, `slot_type_id`, `level_requirement`, `stat_bonus`, `durability`, `max_durability`, `bind_on_equip`, `image`) VALUES
(1, 'Zischagge Helmet', 1, 1, '{\"Endurance\":3}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423539015755239454/Zischagge_Helmet.png?ex=68e0ad85&is=68df5c05&hm=9863d9b9aa1370bce0bf5a9f4bab7e90b38c4890caa684480bda01ef983d45a4&'),
(2, 'Steel Cuirass', 2, 2, '{\"Strength\":5,\"Endurance\":2}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423538657016549416/cuirassier_cuirass.png?ex=68e0ad2f&is=68df5baf&hm=ede0c2188e45212f9c293a0364d16e7c398d3f98b2ea880139d1ed57355b1b18&'),
(3, 'Combat Boots', 3, 1, '{\"Agility\":4}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423538656718622720/combat_boots.png?ex=68e0ad2f&is=68df5baf&hm=6a2d6fc705dbb6a038234a9d6fdce5820d2f25daa5c783d47f3f9856c3d68c6e&'),
(4, 'Musket', 4, 1, '{\"Strength\":2,\"Agility\":1}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423538716525199370/mus.png?ex=68e0ad3e&is=68df5bbe&hm=baac6d4135d1cdba0dcd4420c90b3830e86c26a70ed5cf02904c5bd012d3fd8b&'),
(5, 'FN SCAR-L', 4, 2, '{\"Strength\":6}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423539016506151015/scar.png?ex=68e0ad85&is=68df5c05&hm=56aa5758eba55bef10551f7a7da6fc86384bf598246afd1142706fb26bb42a04&'),
(6, 'Ballistic Helmet', 1, 1, '{\"Intelligence\":2}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423538657343701027/Ballistic_Helmet.png?ex=68e0ad2f&is=68df5baf&hm=372b212c74a1092e9499f2420edfe444f2b33a458279ab72a4272aadd868a223&'),
(7, 'Kevlar Vest', 2, 2, '{\"Endurance\":3}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423538715246198846/Kevlar_Vest.png?ex=68e0ad3d&is=68df5bbd&hm=6239f57286799cc82ac34fe435b53878a953683485a5a40af15418099e6d4cb5&'),
(8, 'Crye Precision G3 Pants', 3, 3, '{\"Agility\":3}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423245890155577395/APRFPE_100-02-MULTICAM-01.png?ex=68e04546&is=68def3c6&hm=8fcfea56a9cf5a8651ae0a8d85ba5a9b24d8514bd3219b56ff26ef4e8fd9c5f2&'),
(9, 'HK416 DMR', 4, 3, '{\"Agility\":2}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423538694169694319/HK416_DMR.png?ex=68e0ad38&is=68df5bb8&hm=74402a0f2b5425a0506965fdeeacc8fb8f36777e266494416e754c84841a60f6&'),
(10, 'Ballistic Shield', 5, 4, NULL, 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423538657712803840/Ballistic_Shield.png?ex=68e0ad30&is=68df5bb0&hm=14ff15025a5e463bf98bb3bfac81bac447d977987a2d5a5cdd8782362f5b4e6a&'),
(11, 'NVG-31 Night Vision Goggles', 1, 2, '{\"Intelligence\":3}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423538717728964678/NVG-31_Night_Vision_Goggles.png?ex=68e0ad3e&is=68df5bbe&hm=4ed06ab137a712da96af61567df44313e729e87e6189ad140d9c18bc82266c5e&'),
(12, 'Interceptor Body Armor', 2, 4, '{\"Strength\":4}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423538694576537620/Interceptor_Body_Armor.png?ex=68e0ad38&is=68df5bb8&hm=b092112695ee5c0aa935df477ba00f13cfacf5a52e8b4fde0462e4934f9f8a2f&'),
(13, 'Multicam Combat Trousers', 3, 3, '{\"Agility\":4}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423538716063830046/Multicam_Combat_Trousers.png?ex=68e0ad3d&is=68df5bbd&hm=4a200da2bfda82dfd909b2a76776ab75350a56104b6e8f253180e778c717bd40&'),
(14, 'M4A1 Carbine', 4, 5, '{\"Strength\":3,\"Agility\":2}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423538715598389280/M4A1_Carbine.png?ex=68e0ad3d&is=68df5bbd&hm=8bec61f2ad01cceebec1b6f063c54bee8de0e4a7bf47e86f24f76fc5315fe126&'),
(15, 'Riot Shield', 5, 2, '{\"Endurance\":3}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423538715598389280/M4A1_Carbine.png?ex=68e0ad3d&is=68df5bbd&hm=8bec61f2ad01cceebec1b6f063c54bee8de0e4a7bf47e86f24f76fc5315fe126&'),
(16, 'Boonie Hat', 1, 1, '{\"Intelligence\":1}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423538656358174771/Boonie_Hat.png?ex=68e0ad2f&is=68df5baf&hm=bd0e79e96007659b4ff9d7774186067d34e627140089798d2396a7790e3f6cd6&'),
(17, 'Plate Carrier', 2, 2, '{\"Endurance\":2}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423538891641851914/plate.png?ex=68e0ad67&is=68df5be7&hm=51f4e5e51bcff038a33546506ace6657877f65584844a7a4e006686a404bc4ad&'),
(18, 'Tactical Knee Pads', 3, 2, '{\"Agility\":2}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423539015348649984/Tactical_Knee_Pads.png?ex=68e0ad85&is=68df5c05&hm=3b64f06283ee08dcb29819a9fff725c8349f6c1bbdeb804c978870cde9571fa5&'),
(19, 'KA-BAR Fighting Knife', 4, 1, '{\"Agility\":2}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423538695134249021/KA-BAR_Fighting_Knife.png?ex=68e0ad38&is=68df5bb8&hm=e36ffaf6703ad00c4405aff0aa3632f3d26e16d4b4896ba2c8ad007f90e4b1a7&'),
(20, 'Small Arms Shield', 5, 1, '{\"Endurance\":2}', 100, 100, 0, 'https://cdn.discordapp.com/attachments/1045746304510337144/1423539017000943656/Small_Arms_Shield.png?ex=68e0ad85&is=68df5c05&hm=2ec7cfc3412ba3b5726c0be9db966447c05a2e95d3feb39ca201bf1cce9106f6&');

--
-- Triggers `equipment`
--
DELIMITER $$
CREATE TRIGGER `trg_check_durability` BEFORE INSERT ON `equipment` FOR EACH ROW BEGIN
    IF NEW.durability < 0 OR NEW.durability > NEW.max_durability THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'durability must be between 0 and max_durability';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_check_durability_update` BEFORE UPDATE ON `equipment` FOR EACH ROW BEGIN
    IF NEW.durability < 0 OR NEW.durability > NEW.max_durability THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'durability must be between 0 and max_durability';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `leveltable`
--

CREATE TABLE `leveltable` (
  `level_id` int(10) UNSIGNED NOT NULL,
  `level_num` int(10) UNSIGNED NOT NULL,
  `xp_required` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `leveltable`
--

INSERT INTO `leveltable` (`level_id`, `level_num`, `xp_required`) VALUES
(1, 1, 0),
(2, 2, 100),
(3, 3, 250),
(4, 4, 450),
(5, 5, 700),
(6, 6, 1000),
(7, 7, 1350),
(8, 8, 1750),
(9, 9, 2200),
(10, 10, 2700);

-- --------------------------------------------------------

--
-- Table structure for table `player`
--

CREATE TABLE `player` (
  `player_id` int(10) UNSIGNED NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `player`
--

INSERT INTO `player` (`player_id`, `username`, `email`, `created_at`, `is_active`) VALUES
(1, 'westfallen12', 'doglover52@gmail.com', '2025-09-29 12:15:18', 1),
(2, 'cunnylove44', 'assbuster99@gmail.com', '2025-09-29 12:15:18', 1),
(3, 'moonbrain', 'brainorbit@gmail.com', '2025-09-29 12:15:18', 1),
(4, 'chaosking', 'riotlord@gmail.com', '2025-09-29 12:15:18', 1),
(5, 'redpill420', 'wakeupsheeple@gmail.com', '2025-09-29 12:15:18', 1),
(6, 'glowyman', 'secretagent@gmail.com', '2025-09-29 12:15:18', 1),
(7, 'tinfoilhat', 'conspiracy@gmail.com', '2025-09-29 12:15:18', 1),
(8, 'shadowlurker', 'spy@gmail.com', '2025-09-29 12:15:18', 1),
(9, 'memeking', 'lolmaster@gmail.com', '2025-09-29 12:15:18', 1),
(10, 'keyboardwarrior', 'typing@gmail.com', '2025-09-29 12:15:18', 1),
(11, 'soyfarmer', 'beans@gmail.com', '2025-09-29 12:15:18', 1),
(12, 'danklord', 'memes@gmail.com', '2025-09-29 12:15:18', 1),
(13, 'goblinlord', 'loot@gmail.com', '2025-09-29 12:15:18', 1),
(14, 'ratking', 'cheese@gmail.com', '2025-09-29 12:15:18', 1),
(15, 'doomguy', 'guns@gmail.com', '2025-09-29 12:15:18', 1),
(16, 'nightowl', 'midnight@gmail.com', '2025-09-29 12:15:18', 1),
(17, 'lazyscumbag', 'chill@gmail.com', '2025-09-29 12:15:18', 1),
(18, 'paranoidpete', 'watching@gmail.com', '2025-09-29 12:15:18', 1),
(19, 'frenziedfox', 'hunt@gmail.com', '2025-09-29 12:15:18', 1),
(20, 'crazysocks', 'weird@gmail.com', '2025-09-29 12:15:18', 1),
(21, 'chailover40', 'lovechairsomuch@gmail.com', '2025-10-02 13:56:39', 1),
(22, 'latexman70', 'la222@FORFUN.bangkok', '2025-10-04 08:59:48', 1);

-- --------------------------------------------------------

--
-- Table structure for table `slottype`
--

CREATE TABLE `slottype` (
  `slot_type_id` int(10) UNSIGNED NOT NULL,
  `slot_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `slottype`
--

INSERT INTO `slottype` (`slot_type_id`, `slot_name`) VALUES
(2, 'Chest'),
(1, 'Head'),
(3, 'Legs'),
(5, 'Shield'),
(4, 'Weapon');

-- --------------------------------------------------------

--
-- Table structure for table `stat`
--

CREATE TABLE `stat` (
  `stat_id` int(10) UNSIGNED NOT NULL,
  `stat_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `stat`
--

INSERT INTO `stat` (`stat_id`, `stat_name`) VALUES
(2, 'Agility'),
(4, 'Endurance'),
(3, 'Intelligence'),
(1, 'Strength');

-- --------------------------------------------------------

--
-- Table structure for table `template_base_stats`
--

CREATE TABLE `template_base_stats` (
  `template_id` int(10) UNSIGNED NOT NULL,
  `stat_id` int(10) UNSIGNED NOT NULL,
  `base_value` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `template_base_stats`
--

INSERT INTO `template_base_stats` (`template_id`, `stat_id`, `base_value`) VALUES
(1, 1, 15),
(1, 2, 10),
(1, 4, 12),
(2, 2, 8),
(2, 3, 18),
(2, 4, 6),
(3, 1, 10),
(3, 2, 15),
(3, 3, 5),
(3, 4, 8),
(4, 1, 12),
(4, 3, 10),
(4, 4, 9),
(5, 1, 14),
(5, 2, 9),
(5, 3, 8),
(5, 4, 10),
(6, 1, 16),
(6, 2, 12),
(6, 3, 10),
(6, 4, 14),
(7, 2, 14),
(7, 3, 12),
(7, 4, 10),
(8, 1, 10),
(8, 3, 9),
(8, 4, 11),
(9, 1, 18),
(9, 2, 15),
(9, 4, 16),
(10, 1, 13),
(10, 2, 11),
(10, 3, 9),
(11, 2, 12),
(11, 3, 15),
(11, 4, 14),
(12, 1, 9),
(12, 3, 12),
(12, 4, 8),
(13, 1, 14),
(13, 2, 12),
(13, 3, 10),
(14, 1, 10),
(14, 2, 14),
(14, 4, 9),
(15, 2, 11),
(15, 3, 13),
(15, 4, 10),
(16, 1, 12),
(16, 2, 9),
(16, 3, 10),
(17, 1, 15),
(17, 3, 12),
(17, 4, 14),
(18, 2, 10),
(18, 3, 11),
(18, 4, 8),
(19, 1, 13),
(19, 2, 11),
(19, 4, 9),
(20, 1, 16),
(20, 2, 15),
(20, 3, 12),
(20, 4, 14);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `characterequipment`
--
ALTER TABLE `characterequipment`
  ADD PRIMARY KEY (`char_id`,`slot_type_id`),
  ADD KEY `fk_charequip_item` (`item_id`),
  ADD KEY `fk_charequip_slottype` (`slot_type_id`);

--
-- Indexes for table `characterstats`
--
ALTER TABLE `characterstats`
  ADD PRIMARY KEY (`char_id`,`stat_id`),
  ADD KEY `fk_charstats_stat` (`stat_id`);

--
-- Indexes for table `charactertable`
--
ALTER TABLE `charactertable`
  ADD PRIMARY KEY (`char_id`),
  ADD UNIQUE KEY `unique_template_per_player` (`player_id`,`template_id`),
  ADD KEY `fk_character_class` (`class_id`),
  ADD KEY `fk_character_template` (`template_id`),
  ADD KEY `idx_character_player` (`player_id`),
  ADD KEY `idx_character_level_xp` (`level_id`,`xp`);

--
-- Indexes for table `character_template`
--
ALTER TABLE `character_template`
  ADD PRIMARY KEY (`template_id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `fk_template_class` (`class_id`);

--
-- Indexes for table `classtable`
--
ALTER TABLE `classtable`
  ADD PRIMARY KEY (`class_id`),
  ADD UNIQUE KEY `class_name` (`class_name`);

--
-- Indexes for table `equipment`
--
ALTER TABLE `equipment`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `fk_equipment_slottype` (`slot_type_id`);

--
-- Indexes for table `leveltable`
--
ALTER TABLE `leveltable`
  ADD PRIMARY KEY (`level_id`),
  ADD UNIQUE KEY `level_num` (`level_num`);

--
-- Indexes for table `player`
--
ALTER TABLE `player`
  ADD PRIMARY KEY (`player_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `slottype`
--
ALTER TABLE `slottype`
  ADD PRIMARY KEY (`slot_type_id`),
  ADD UNIQUE KEY `slot_name` (`slot_name`);

--
-- Indexes for table `stat`
--
ALTER TABLE `stat`
  ADD PRIMARY KEY (`stat_id`),
  ADD UNIQUE KEY `stat_name` (`stat_name`);

--
-- Indexes for table `template_base_stats`
--
ALTER TABLE `template_base_stats`
  ADD PRIMARY KEY (`template_id`,`stat_id`),
  ADD KEY `fk_template_stats_stat` (`stat_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `charactertable`
--
ALTER TABLE `charactertable`
  MODIFY `char_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `character_template`
--
ALTER TABLE `character_template`
  MODIFY `template_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `classtable`
--
ALTER TABLE `classtable`
  MODIFY `class_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `equipment`
--
ALTER TABLE `equipment`
  MODIFY `item_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `leveltable`
--
ALTER TABLE `leveltable`
  MODIFY `level_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `player`
--
ALTER TABLE `player`
  MODIFY `player_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `slottype`
--
ALTER TABLE `slottype`
  MODIFY `slot_type_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `stat`
--
ALTER TABLE `stat`
  MODIFY `stat_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `characterequipment`
--
ALTER TABLE `characterequipment`
  ADD CONSTRAINT `fk_charequip_character` FOREIGN KEY (`char_id`) REFERENCES `charactertable` (`char_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_charequip_item` FOREIGN KEY (`item_id`) REFERENCES `equipment` (`item_id`),
  ADD CONSTRAINT `fk_charequip_slottype` FOREIGN KEY (`slot_type_id`) REFERENCES `slottype` (`slot_type_id`);

--
-- Constraints for table `characterstats`
--
ALTER TABLE `characterstats`
  ADD CONSTRAINT `fk_charstats_character` FOREIGN KEY (`char_id`) REFERENCES `charactertable` (`char_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_charstats_stat` FOREIGN KEY (`stat_id`) REFERENCES `stat` (`stat_id`);

--
-- Constraints for table `charactertable`
--
ALTER TABLE `charactertable`
  ADD CONSTRAINT `fk_character_class` FOREIGN KEY (`class_id`) REFERENCES `classtable` (`class_id`),
  ADD CONSTRAINT `fk_character_level` FOREIGN KEY (`level_id`) REFERENCES `leveltable` (`level_id`),
  ADD CONSTRAINT `fk_character_player` FOREIGN KEY (`player_id`) REFERENCES `player` (`player_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_character_template` FOREIGN KEY (`template_id`) REFERENCES `character_template` (`template_id`);

--
-- Constraints for table `character_template`
--
ALTER TABLE `character_template`
  ADD CONSTRAINT `fk_template_class` FOREIGN KEY (`class_id`) REFERENCES `classtable` (`class_id`);

--
-- Constraints for table `equipment`
--
ALTER TABLE `equipment`
  ADD CONSTRAINT `fk_equipment_slottype` FOREIGN KEY (`slot_type_id`) REFERENCES `slottype` (`slot_type_id`);

--
-- Constraints for table `template_base_stats`
--
ALTER TABLE `template_base_stats`
  ADD CONSTRAINT `fk_template_stats_stat` FOREIGN KEY (`stat_id`) REFERENCES `stat` (`stat_id`),
  ADD CONSTRAINT `fk_template_stats_template` FOREIGN KEY (`template_id`) REFERENCES `character_template` (`template_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
