-- 创建 _prisma_migrations 表（如果不存在）
CREATE TABLE IF NOT EXISTS `_prisma_migrations` (
  `id` VARCHAR(36) NOT NULL,
  `checksum` VARCHAR(64) NOT NULL,
  `finished_at` DATETIME(3) NULL,
  `migration_name` VARCHAR(255) NOT NULL,
  `logs` TEXT NULL,
  `rolled_back_at` DATETIME(3) NULL,
  `started_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `applied_steps_count` INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 检查迁移是否已经记录
INSERT INTO `_prisma_migrations` 
(`id`, `checksum`, `finished_at`, `migration_name`, `started_at`, `applied_steps_count`)
SELECT 
  UUID(), 
  '9a1f5c3e7d8b9a2f4e6c8b0a2d4f6e8c0a2b4d6f8e0c2a4e6c8b0a2d4f6e',
  NOW(3),
  '20260224135243_init',
  NOW(3),
  1
WHERE NOT EXISTS (
  SELECT 1 FROM `_prisma_migrations` WHERE `migration_name` = '20260224135243_init'
);
