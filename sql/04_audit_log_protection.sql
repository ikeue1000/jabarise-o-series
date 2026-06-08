-- 04_audit_log_protection.sql
-- 監査ログの削除・更新禁止制約（トリガー）設定スクリプト

-- トリガー関数の作成
CREATE OR REPLACE FUNCTION prevent_audit_log_modification()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION '監査ログ(audit_logs)の更新および削除はシステム制約により禁止されています。';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- UPDATE防止トリガーの作成
CREATE TRIGGER trg_prevent_audit_log_update
BEFORE UPDATE ON audit_logs
FOR EACH ROW
EXECUTE FUNCTION prevent_audit_log_modification();

-- DELETE防止トリガーの作成
CREATE TRIGGER trg_prevent_audit_log_delete
BEFORE DELETE ON audit_logs
FOR EACH ROW
EXECUTE FUNCTION prevent_audit_log_modification();
