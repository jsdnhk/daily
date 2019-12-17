ALTER DATABASE `db_vg_stats`
DEFAULT CHARACTER SET utf8
DEFAULT COLLATE utf8_unicode_ci;

DROP TABLE IF EXISTS `tbl_submit_document_stat`;
CREATE TABLE `tbl_submit_document_stat` (
  `submission_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `submission_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `job_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `length_by_sentence` bigint(20) unsigned NOT NULL,
  `length_by_distinct_token` bigint(20) unsigned NOT NULL,
  `length_by_word` bigint(20) unsigned NOT NULL,
  `length_by_character` bigint(20) unsigned NOT NULL,
  `lexical_diversity` float unsigned NOT NULL,
  `data_by_sentence` json NOT NULL,
  `data_by_fdist` json NOT NULL,
  PRIMARY KEY (`submission_id`),
  UNIQUE KEY `UNIQUE_ID` (`submission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;