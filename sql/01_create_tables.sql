-- 01_create_tables.sql
-- 共通DB基盤 テーブル作成スクリプト

-- 1. ユーザーマスタ
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    login_id VARCHAR(50) UNIQUE NOT NULL,
    user_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. 自治体マスタ
CREATE TABLE municipalities (
    municipality_id SERIAL PRIMARY KEY,
    municipality_code CHAR(6) UNIQUE,
    municipality_name VARCHAR(100) NOT NULL,
    prefecture VARCHAR(20),
    approval_flow_pattern VARCHAR(20) NOT NULL DEFAULT '標準',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. 自治体契約マスタ
CREATE TABLE municipality_contracts (
    contract_id SERIAL PRIMARY KEY,
    municipality_id INTEGER NOT NULL REFERENCES municipalities(municipality_id),
    contract_type VARCHAR(20) NOT NULL,
    fee_pattern VARCHAR(20) NOT NULL,
    fee_rate NUMERIC(6,4),
    fee_amount_fixed NUMERIC(12,0),
    fee_includes_tax BOOLEAN NOT NULL DEFAULT TRUE,
    billing_target BOOLEAN NOT NULL DEFAULT TRUE,
    payment_agency BOOLEAN NOT NULL DEFAULT FALSE,
    valid_from DATE NOT NULL,
    valid_to DATE,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 4. 契約段階料率マスタ
CREATE TABLE contract_fee_tiers (
    tier_id SERIAL PRIMARY KEY,
    contract_id INTEGER NOT NULL REFERENCES municipality_contracts(contract_id),
    tier_order SMALLINT NOT NULL,
    threshold_amount NUMERIC(14,0),
    fee_rate NUMERIC(6,4) NOT NULL,
    fee_includes_tax BOOLEAN NOT NULL DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 8. ポータルサイトマスタ (除外マスタ等で参照するため先に作成)
CREATE TABLE portal_sites (
    site_code VARCHAR(20) PRIMARY KEY,
    site_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 5. 除外サイト・除外条件マスタ
CREATE TABLE exclusions (
    exclusion_id SERIAL PRIMARY KEY,
    municipality_id INTEGER NOT NULL REFERENCES municipalities(municipality_id),
    exclusion_type VARCHAR(30) NOT NULL,
    site_code VARCHAR(20) REFERENCES portal_sites(site_code),
    exclusion_reason VARCHAR(200),
    valid_from DATE NOT NULL,
    valid_to DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 6. 返礼品なし寄附ルールマスタ
CREATE TABLE no_return_gift_rules (
    rule_id SERIAL PRIMARY KEY,
    municipality_id INTEGER NOT NULL REFERENCES municipalities(municipality_id),
    billing_fee_allowed BOOLEAN NOT NULL,
    billing_commission_allowed BOOLEAN NOT NULL,
    notes TEXT,
    valid_from DATE NOT NULL,
    valid_to DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 7. 請求項目マスタ
CREATE TABLE billing_items (
    item_code VARCHAR(20) PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    billing_allowed BOOLEAN NOT NULL,
    aggregation_basis VARCHAR(20) NOT NULL,
    tax_type VARCHAR(10) NOT NULL,
    cost_type VARCHAR(10) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 9. ポータル支払費目マスタ
CREATE TABLE portal_expense_types (
    expense_type_code VARCHAR(20) PRIMARY KEY,
    expense_type_name VARCHAR(100) NOT NULL,
    aggregation_basis VARCHAR(20) NOT NULL DEFAULT '請求書ベース',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 10. 事業者マスタ
CREATE TABLE vendors (
    vendor_code VARCHAR(20) PRIMARY KEY,
    vendor_name VARCHAR(200) NOT NULL,
    vendor_name_aliases TEXT,
    payment_agency BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 11. 手数料種別マスタ
CREATE TABLE fee_types (
    fee_type_code VARCHAR(20) PRIMARY KEY,
    fee_type_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 12. 手数料マスタ
CREATE TABLE commissions (
    fee_id SERIAL PRIMARY KEY,
    site_code VARCHAR(20) NOT NULL REFERENCES portal_sites(site_code),
    municipality_id INTEGER NOT NULL REFERENCES municipalities(municipality_id),
    fee_type_code VARCHAR(20) NOT NULL REFERENCES fee_types(fee_type_code),
    fee_rate NUMERIC(6,4),
    fee_amount_fixed NUMERIC(12,0),
    fee_includes_tax BOOLEAN NOT NULL DEFAULT TRUE,
    valid_from DATE NOT NULL,
    valid_to DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 13. 請求書予定マスタ
CREATE TABLE invoice_schedules (
    schedule_id SERIAL PRIMARY KEY,
    municipality_id INTEGER NOT NULL REFERENCES municipalities(municipality_id),
    expense_category VARCHAR(30) NOT NULL,
    site_code VARCHAR(20) REFERENCES portal_sites(site_code),
    is_required BOOLEAN NOT NULL DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 14. 経費率・返礼率閾値マスタ
CREATE TABLE thresholds (
    threshold_id SERIAL PRIMARY KEY,
    municipality_id INTEGER REFERENCES municipalities(municipality_id),
    threshold_type VARCHAR(20) NOT NULL,
    threshold_value NUMERIC(6,4) NOT NULL,
    alert_level VARCHAR(10) NOT NULL,
    valid_from DATE NOT NULL,
    valid_to DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 15. 集計基準マスタ
CREATE TABLE aggregation_bases (
    basis_code VARCHAR(20) PRIMARY KEY,
    basis_name VARCHAR(100) NOT NULL,
    basis_date_field VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 16. 取込ファイル管理
CREATE TABLE import_files (
    import_file_id SERIAL PRIMARY KEY,
    municipality_id INTEGER NOT NULL REFERENCES municipalities(municipality_id),
    file_type VARCHAR(30) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    stored_path TEXT NOT NULL,
    target_year_month CHAR(6) NOT NULL,
    imported_by_user_id INTEGER NOT NULL REFERENCES users(user_id),
    imported_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_count INTEGER,
    notes TEXT
);

-- 17. 原本ファイル管理
CREATE TABLE original_files (
    original_file_id SERIAL PRIMARY KEY,
    municipality_id INTEGER NOT NULL REFERENCES municipalities(municipality_id),
    file_category VARCHAR(30) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    stored_path TEXT NOT NULL,
    target_year_month CHAR(6) NOT NULL,
    invoice_number VARCHAR(100),
    site_code VARCHAR(20) REFERENCES portal_sites(site_code),
    uploaded_by_user_id INTEGER NOT NULL REFERENCES users(user_id),
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- 18. 監査ログ
CREATE TABLE audit_logs (
    log_id BIGSERIAL PRIMARY KEY,
    log_type VARCHAR(30) NOT NULL,
    target_table VARCHAR(100),
    target_id TEXT,
    municipality_id INTEGER,
    operator_user_id INTEGER NOT NULL REFERENCES users(user_id),
    operator_user_name VARCHAR(100) NOT NULL,
    operator_role VARCHAR(20) NOT NULL,
    operated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    before_value TEXT,
    after_value TEXT,
    notes TEXT
);

-- 19. 月次確定管理
CREATE TABLE monthly_locks (
    lock_id SERIAL PRIMARY KEY,
    municipality_id INTEGER NOT NULL REFERENCES municipalities(municipality_id),
    target_year_month CHAR(6) NOT NULL,
    lock_status VARCHAR(20) NOT NULL,
    locked_by_user_id INTEGER REFERENCES users(user_id),
    locked_at TIMESTAMP,
    reopened_by_user_id INTEGER REFERENCES users(user_id),
    reopened_at TIMESTAMP,
    reopen_reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
