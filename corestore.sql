DROP DATABASE IF EXISTS `core_store`;
CREATE DATABASE `core_store`;
USE `core_store`;


-- таблица месторождений
DROP TABLE IF EXISTS `fields_names` ;
CREATE TABLE `core_store`.`fields_names` (
  `field_id` SERIAL,
  `field_name` VARCHAR(125) NOT NULL,
  PRIMARY KEY (`field_id`));
  
INSERT INTO `fields_names`
  (field_id, field_name)
VALUES
('1','North_Komsomolskoye'),
('2','Odoptu'),
('3','Arukutun-Dagi'),
('4','Chayvo'),
('5','Peschannoye'),
('6','Taezhnoye'),
('7','Lunskoye'),
('8','Piltunskoye'),
('9','Lebedinskoye'),
('10','Suzunskoye');

-- таблица имен скважин
DROP TABLE IF EXISTS `wells` ;
CREATE TABLE `core_store`.`wells` (
  `well_id` SERIAL,
  `wellnum` VARCHAR(45) NOT NULL,
  `field_id` BIGINT UNSIGNED NOT NULL,
  FOREIGN KEY (`field_id`) REFERENCES `fields_names`(`field_id`),
  PRIMARY KEY (`well_id`));
  
INSERT INTO `wells`
  (well_id, wellnum, field_id)
VALUES
(1,'73pl', 1),
(2,'OP-15', 2),
(3,'DP-2U', 3),
(4,'805pl', 1),
(5,'1R', 5),
(6,'3R', 10),
(7,'ODOPTU-6', 2),
(8,'Dagi-7_2', 3),
(9,'4R', 10),
(10,'6R', 9);

-- таблица пластов
DROP TABLE IF EXISTS `layers` ;
CREATE TABLE `core_store`.`layers` (
  `layer_id` SERIAL,
  `well_id` BIGINT UNSIGNED NOT NULL,
  `layer_name` VARCHAR(125) NOT NULL,
  `top` DECIMAL(8,2) NULL,
  `bot` DECIMAL(8,2) NULL,
  FOREIGN KEY (`well_id`) REFERENCES `wells`(`well_id`),
  PRIMARY KEY (`layer_id`));

INSERT INTO `layers`
  (layer_id, well_id, layer_name, top, bot)
VALUES
(1,1, 'PK1', 1170,1173),
(2,1, 'KUZ', 1150,1170),
(3,4, 'PK1', 1138,1210),
(4,4, 'KUZ', 1110,1138),
(5,3, 'X', 1110,1138),
(6,3, 'XI', 1138,1200),
(7,3, 'XII', 1200,1250),
(8,3, 'XIII-1', 1350,1400),
(9,2, 'XX1-1', 1500,1550),
(10,2, 'XXII-2',1600,1650);
  
-- таблица интервалов доблдения керна
DROP TABLE IF EXISTS `intervals` ;
CREATE TABLE `core_store`.`intervals` (
  `interval_id` SERIAL,
  `well_id` BIGINT UNSIGNED NOT NULL,
  `top` DECIMAL(8,2) NULL,
  `bot` DECIMAL(8,2) NULL,
  `recovery` DECIMAL(5,2) NULL,
  `depth_shift` DECIMAL(5,2) NULL,
  FOREIGN KEY (`well_id`) REFERENCES `wells`(`well_id`),
  PRIMARY KEY (`interval_id`));
  
INSERT INTO `intervals`
  (interval_id, well_id, top, bot, recovery, depth_shift)
VALUES
(1,1, 1168,1174,6,1.72),
(2,1, 1174,1180,6,1.72),
(3,1, 1180,1186.77,6.77,1.72),
(4,1, 1186.77,1193.02,6.25,1.72),
(5,1, 1193.02,1198.73,5.71,1.72),
(6,1, 1198.73,1204.63,5.9,1.72),
(7,1, 1204.63,1210,5,2.07),
(8,1, 1210,1214.26,4.26,3.30),
(9,1, 1214.26,1222,7.74,5.50),
(10,1, 1222,1228.27,6,5.62),
(11,1, 1228.27,1234.23,5,5.63),
(12,1, 1234.23,1241.62,7,5.63);

-- таблица поинтервального описания керна
DROP TABLE IF EXISTS `interval_description` ;
CREATE TABLE `core_store`.`interval_description` (
  `description_id` SERIAL,
  `interval_id` BIGINT UNSIGNED NOT NULL,
  `top` DECIMAL(8,2) NOT NULL,
  `bot` DECIMAL(8,2) NOT NULL,
  `description` VARCHAR(125) NOT NULL,
  FOREIGN KEY (`interval_id`) REFERENCES `intervals`(`interval_id`),
  PRIMARY KEY (`description_id`));

INSERT INTO `interval_description`
  (description_id, interval_id, top, bot, description)
VALUES
(1,1, 1168,1174, 'глина'),
(2,2, 1174,1180,'алевролит'),
(3,3, 1180,1186.77,'глина'),
(4,4, 1186.77,1193.02,'песчаник'),
(5,5, 1193.02,1198.73,'алевролит'),
(6,6, 1198.73,1204.63,'глина'),
(7,7, 1204.63,1210,'алевролит'),
(8,8, 1210,1214.26,'глина'),
(9,9, 1214.26,1222,'песчаник'),
(10,10, 1222,1228.27,'глина'),
(11,11, 1228.27,1234.23,'алевролит'),
(12,12, 1234.23,1241.62,'глина');

-- таблица гамма каротажа на керне
DROP TABLE IF EXISTS `interval_gr` ;
CREATE TABLE `core_store`.`interval_gr` (
  `gr_id` SERIAL,
  `interval_id` BIGINT UNSIGNED NOT NULL,
  `top_depth` DECIMAL(8,2) NOT NULL,
  `gr_val` DECIMAL(5) NOT NULL,
  FOREIGN KEY (`interval_id`) REFERENCES `intervals`(`interval_id`),
  PRIMARY KEY (`gr_id`));

-- таблица отобранных образцов
DROP TABLE IF EXISTS `samples` ;
CREATE TABLE `core_store`.`samples` (
  `sample_id` SERIAL,
  `interval_id` BIGINT UNSIGNED NOT NULL,
  `depth_top` DECIMAL(5,2) NOT NULL,
  `lab_num` VARCHAR(45) NULL,
  FOREIGN KEY (`interval_id`) REFERENCES `intervals`(`interval_id`),
  PRIMARY KEY (`sample_id`));

DROP TRIGGER IF EXISTS sample_depth;

DELIMITER //
CREATE TRIGGER sample_depth AFTER INSERT ON `samples` 
FOR EACH ROW
BEGIN
   DECLARE top_of_interval DECIMAL(5,2);
   DECLARE shift_interval DECIMAL(5,2);
   
   SET top_of_interval =(
      SELECT top
      FROM intervals
      where interval_id=NEW.interval_id);
      
   SET shift_interval =(
      SELECT shift
      FROM intervals 
      where interval_id=NEW.interval_id);
   
   INSERT INTO `samples`(depth) VALUES (top_of_interval+depth_top+shift_interval);

END//
DELIMITER ;

  

INSERT INTO `samples`
  (sample_id, interval_id, depth_top, lab_num)
VALUES
(1,1,0.10,'29323/18'),
(2,1,0.64,'29324/18'),
(3,1,0.89,'29325/18'),
(4,1,1.33,'29326/18'),
(5,1,1.49,'29327/18'),
(6,1,1.76,'29328/18'),
(7,1,2.10,'29329/18'),
(8,1,2.58,'29330/18'),
(9,1,2.71,'29331/18'),
(10,1,2.71,'29332/18'),
(11,1,2.81,'29333/18'),
(12,1,2.81,'29334/18'),
(13,1,2.81,'29335/18'),
(14,1,3.04,'29336/18'),
(15,1,3.11,'29337/18'),
(16,1,3.15,'29338/18'),
(17,1,3.22,'29339/18'),
(18,1,3.28,'29340/18'),
(19,1,3.53,'29341/18'),
(20,1,3.53,'29342/18'),
(21,1,3.53,'29343/18'),
(22,1,3.63,'29344/18'),
(23,1,3.72,'29345/18'),
(24,1,3.78,'29346/18'),
(25,1,3.87,'29347/18'),
(26,1,3.95,'29348/18'),
(27,1,4.18,'29349/18'),
(28,1,4.23,'29350/18'),
(29,1,4.44,'29351/18'),
(30,1,4.94,'29352/18'),
(31,1,5.10,''),
(32,1,5.10,'29353/18'),
(33,1,5.29,'29354/18'),
(34,1,5.49,'29355/18'),
(35,1,5.55,'29356/18'),
(36,1,5.77,'29357/18');

-- таблица с резульататми эксперимента Дина-Старка
DROP TABLE IF EXISTS `dean_stark` ;
CREATE TABLE `core_store`.`dean_stark` (
  `measurement_id` SERIAL,
  `sample_id` BIGINT UNSIGNED NULL,
  `water_sat` DECIMAL(5,3) NOT NULL,
  `oil_sat` DECIMAL(5,3) NOT NULL,
  FOREIGN KEY (`sample_id`) REFERENCES `samples`(`sample_id`),
  PRIMARY KEY (`measurement_id`));

INSERT INTO `dean_stark`
  (measurement_id, sample_id, water_sat, oil_sat)
VALUES
(1,1,0.4,'0.5'),
(2,2,0.5,'0.5'),
(3,3,0.6,'0.4'),
(4,4,0.6,'0.3'),
(5,5,0.5,'0.4'),
(6,6,0.6,'0.3'),
(7,7,0.4,'0.4'),
(8,8,0.5,'0.5'),
(9,13,0.3,'0.6'),
(10,21,0.5,'0.4');

-- таблица с резульатами определния пористости
DROP TABLE IF EXISTS `porosity` ;
CREATE TABLE `core_store`.`porosity` (
  `measurement_id` SERIAL,
  `sample_id` BIGINT UNSIGNED NOT NULL,
  `porosity_val` DECIMAL(5,3) NOT NULL,
  `grain_density` DECIMAL(6,3) DEFAULT NULL,
  FOREIGN KEY (`sample_id`) REFERENCES `samples`(`sample_id`),
  PRIMARY KEY (`measurement_id`));
  
INSERT INTO `porosity`
  (measurement_id, sample_id, porosity_val, grain_density)
VALUES
(1,1,0.208,2.47),
(2,2,0.205,2.42),
(3,3,0.158,2.42),
(4,4,0.201,2.49),
(5,5,0.194,2.45),
(6,6,0.229,2.52),
(7,7,0.226,2.55),
(8,8,0.208,2.64),
(9,13,0.251,2.66),
(10,21,0.23,2.59);


-- таблица определения проницаемости
DROP TABLE IF EXISTS `permeability` ;
CREATE TABLE `core_store`.`permeability` (
  `measurement_id` SERIAL,
  `sample_id` BIGINT UNSIGNED NOT NULL,
  `permeability_val` DECIMAL(5,3) NOT NULL,
  FOREIGN KEY (`sample_id`) REFERENCES `samples`(`sample_id`),
  PRIMARY KEY (`measurement_id`));
 
 INSERT INTO `permeability`
  (measurement_id, sample_id, permeability_val)
VALUES
(1,1,5.58),
(2,2,7.40),
(3,3,7.37),
(4,4,7.06),
(5,5,7.396),
(6,6,19.80),
(7,7,8.936),
(8,8,0.97),
(9,13,2.28),
(10,21,1.54);

-- таблица определения отностительного электрического сопротивления на образцах 
DROP TABLE IF EXISTS `resistivity` ;
CREATE TABLE `core_store`.`resistivity` (
  `measurement_id` SERIAL,
  `sample_id` BIGINT UNSIGNED NOT NULL,
  `frf` DECIMAL(6,2) NOT NULL,
  FOREIGN KEY (`sample_id`) REFERENCES `samples`(`sample_id`),
  PRIMARY KEY (`measurement_id`));

INSERT INTO `resistivity`
  (measurement_id, sample_id, frf)
VALUES
(1,1,9.94),
(2,2,7.76),
(3,3,11.85),
(4,4,8.11),
(5,5,7.05),
(6,6,7.22),
(7,7,7.52),
(8,8,10.23),
(9,13,8.32),
(10,21,9.56);






-- таблица интервалов долбления керна по выбранной скважине
CREATE or REPLACE VIEW allcore_well
AS 
  SELECT w.wellnum,
		 i.top,
         i.bot,
         i.top+i.depth_shift as top_shifted,
         i.bot+i.depth_shift as bot_shifted,
         i.recovery,
         i.recovery/(i.bot-i.top)*100 as recovery_percent
  FROM intervals i
    JOIN wells w ON i.well_id = w.well_id
  WHERE 
  w.wellnum = '73pl'
;

-- таблица всех выполненных исследований ФЕС по выбранной скважине
CREATE or REPLACE VIEW allsamples_well
AS 
  select w.wellnum,
         sm.depth_top,
         i.top+sm.depth_top+i.depth_shift as sample_depth_shifted,
         ds.water_sat as water_saturation,
         p.porosity_val as porosity,
         perm.permeability_val as permeability
  FROM samples sm
	JOIN intervals i ON i.interval_id = sm.interval_id
    JOIN wells w ON w.well_id = i.well_id
    JOIN dean_stark ds ON ds.sample_id = sm.sample_id
    JOIN porosity p ON p.sample_id = sm.sample_id
    JOIN permeability perm ON perm.sample_id = sm.sample_id 
  WHERE 
  w.wellnum = '73pl'
  ;
  
  -- запрос на процент выноса керна по скважине
SELECT w.wellnum,
	   SUM(i.recovery)/SUM(i.bot-i.top) as core_recovery_well
FROM intervals i
    JOIN wells w ON i.well_id = w.well_id
WHERE 
  w.wellnum = '73pl' 
;  
  

-- запрос на отображение образцов по пластам
SELECT layer_name,
       l.top,
       l.bot,
	   i.top+sm.depth_top+i.depth_shift as sample_depth
from layers l
     JOIN intervals i ON i.well_id=l.well_id
     JOIN wells w ON w.well_id = i.well_id
     JOIN samples sm ON sm.interval_id=i.interval_id
WHERE 
   w.wellnum = '73pl' 
HAVING sample_depth > top and sample_depth < bot
;
	
