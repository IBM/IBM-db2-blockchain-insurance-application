
-- Clean up all objects created by the nickname.sql or mqts.sql scripts

DROP VIEW all_tx;
DROP VIEW all_blocks;

DROP TABLE cache_tx;
DROP TABLE cache_blocks;
DROP TABLE mqt_tx;
DROP TABLE mqt_blocks;

DROP NICKNAME nn_tx_opt;
DROP NICKNAME nn_tx;
DROP NICKNAME nn_blocks_opt;
DROP NICKNAME nn_blocks;

DROP USER MAPPING FOR USER SERVER shop_peer;

DROP SERVER shop_peer;

DROP WRAPPER fabric;