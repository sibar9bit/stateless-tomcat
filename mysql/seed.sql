drop database if exists myapp;
create database myapp;
use myapp;

--
-- Table structure for table `tomcat_sessions`
--
DROP TABLE IF EXISTS `tomcat_sessions`;

CREATE TABLE `tomcat_sessions` (
    id              varchar(40) not null PRIMARY KEY,
    valid           char(1) not null,
    max_inactive    int not null,
    last_accessed   bigint not null,
    app_name        varchar(255) not null,
    data            mediumblob not null,
    INDEX kapp_name (app_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
