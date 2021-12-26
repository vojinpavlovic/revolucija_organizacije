CREATE TABLE `organisations` (
	`name` varchar(20) NOT NULL,
	`level` INT NOT NULL DEFAULT '1',
	`skills` LONGTEXT NOT NULL DEFAULT '{\"members\":1, \"safe\":1,\"teritory\":0,\"boat\":0}';,
	`money` INT NOT NULL DEFAULT '0',
	PRIMARY KEY (`name`)
);