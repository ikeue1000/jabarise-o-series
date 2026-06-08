-- 05_verify_phase0.sql
-- フェーズ0 実装確認スクリプト
-- 実行タイミング：01〜04のSQL実行完了後に実行すること
-- 全項目が「OK」であることを確認してから池上に報告すること

-- ============================================================
-- 1. テーブル数が19であること
-- ============================================================
SELECT
    CASE WHEN COUNT(*) = 19 THEN 'OK' ELSE 'NG: ' || COUNT(*) || '件（期待値: 19）' END AS テーブル数チェック,
    COUNT(*) AS 実テーブル数
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE';

-- ============================================================
-- 2. 各テーブルの初期データ件数チェック
-- ============================================================
SELECT
    'municipalities'       AS テーブル名,
    COUNT(*)               AS 実件数,
    24                     AS 期待件数,
    CASE WHEN COUNT(*) = 24 THEN 'OK' ELSE 'NG' END AS 結果
FROM municipalities
UNION ALL
SELECT
    'billing_items',
    COUNT(*),
    7,
    CASE WHEN COUNT(*) = 7 THEN 'OK' ELSE 'NG' END
FROM billing_items
UNION ALL
SELECT
    'portal_sites',
    COUNT(*),
    20,
    CASE WHEN COUNT(*) = 20 THEN 'OK' ELSE 'NG' END
FROM portal_sites
UNION ALL
SELECT
    'portal_expense_types',
    COUNT(*),
    6,
    CASE WHEN COUNT(*) = 6 THEN 'OK' ELSE 'NG' END
FROM portal_expense_types
UNION ALL
SELECT
    'aggregation_bases',
    COUNT(*),
    3,
    CASE WHEN COUNT(*) = 3 THEN 'OK' ELSE 'NG' END
FROM aggregation_bases
UNION ALL
SELECT
    'thresholds',
    COUNT(*),
    2,
    CASE WHEN COUNT(*) = 2 THEN 'OK' ELSE 'NG' END
FROM thresholds
ORDER BY テーブル名;

-- ============================================================
-- 3. audit_logs に UPDATE/DELETE 禁止トリガーが2件存在すること
-- ============================================================

-- 3-1. トリガー2件の存在を自動判定
SELECT
    CASE WHEN COUNT(*) = 2 THEN 'OK' ELSE 'NG: ' || COUNT(*) || '件（期待値: 2）' END AS トリガー件数チェック,
    COUNT(*) AS 実トリガー数
FROM information_schema.triggers
WHERE event_object_schema = 'public'
  AND event_object_table = 'audit_logs'
  AND event_manipulation IN ('UPDATE', 'DELETE');

-- 3-2. トリガーの詳細確認（目視確認用）
SELECT
    trigger_name    AS トリガー名,
    event_manipulation AS 対象操作,
    event_object_table AS 対象テーブル,
    action_timing   AS タイミング
FROM information_schema.triggers
WHERE event_object_schema = 'public'
  AND event_object_table = 'audit_logs'
  AND event_manipulation IN ('UPDATE', 'DELETE')
ORDER BY event_manipulation;

-- ============================================================
-- 4. 補足：billing_items の内容確認（tax_type の確認用）
-- ============================================================
SELECT item_code, item_name, tax_type, cost_type
FROM billing_items
ORDER BY item_code;
