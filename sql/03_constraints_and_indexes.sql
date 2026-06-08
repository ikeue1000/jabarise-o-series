-- 03_constraints_and_indexes.sql
-- 制約およびインデックス追加スクリプト

-- 1. 契約段階料率マスタ: 同一契約内で段階順序の重複を防止
ALTER TABLE contract_fee_tiers
ADD CONSTRAINT uq_contract_tier_order UNIQUE (contract_id, tier_order);

-- 2. 契約段階料率マスタ: tier_order は 1～5 の範囲に制限
ALTER TABLE contract_fee_tiers
ADD CONSTRAINT chk_tier_order_range CHECK (tier_order BETWEEN 1 AND 5);

-- 3. 月次確定管理: 自治体と対象年月の組み合わせの重複を防止
ALTER TABLE monthly_locks
ADD CONSTRAINT uq_municipality_year_month UNIQUE (municipality_id, target_year_month);

-- 4. 手数料マスタ: fee_rate と fee_amount_fixed はどちらか一方のみ入力。両方NULL・両方入力は禁止
ALTER TABLE commissions
ADD CONSTRAINT chk_commissions_fee_exclusivity
    CHECK (
        (fee_rate IS NOT NULL AND fee_amount_fixed IS NULL)
        OR
        (fee_rate IS NULL AND fee_amount_fixed IS NOT NULL)
    );

-- 5. インデックスの追加（検索パフォーマンス向上のため）
CREATE INDEX idx_municipality_contracts_municipality_id ON municipality_contracts(municipality_id);
CREATE INDEX idx_exclusions_municipality_id ON exclusions(municipality_id);
CREATE INDEX idx_no_return_gift_rules_municipality_id ON no_return_gift_rules(municipality_id);
CREATE INDEX idx_commissions_municipality_id ON commissions(municipality_id);
CREATE INDEX idx_commissions_site_code ON commissions(site_code);
CREATE INDEX idx_invoice_schedules_municipality_id ON invoice_schedules(municipality_id);
CREATE INDEX idx_import_files_municipality_id ON import_files(municipality_id);
CREATE INDEX idx_original_files_municipality_id ON original_files(municipality_id);
CREATE INDEX idx_audit_logs_operator_user_id ON audit_logs(operator_user_id);
CREATE INDEX idx_monthly_locks_municipality_id ON monthly_locks(municipality_id);
