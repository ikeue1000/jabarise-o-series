-- 02_insert_initial_data.sql
-- 初期データ投入スクリプト

-- 1. 自治体マスタ（24自治体の名称のみ仮登録）
INSERT INTO municipalities (municipality_name) VALUES
('串本町'), ('古座川町'), ('田辺市'), ('すさみ町'), ('由良町'),
('みなべ町'), ('平泉町'), ('涌谷町'), ('豊中市'), ('宮城県美里町'),
('北山村'), ('太地町'), ('新宮市'), ('紀宝町'), ('熊野市'),
('真庭市'), ('広川町'), ('北竜町'), ('紀美野町'), ('かつらぎ町'),
('葛城市'), ('伊賀市'), ('住田町'), ('丹波山村');

-- 2. 請求項目マスタ（7件）
INSERT INTO billing_items (item_code, item_name, billing_allowed, aggregation_basis, tax_type, cost_type) VALUES
('COMMISSION', '委託料', TRUE, '受注ベース', '課税', '実費'),
('RETURN_GIFT', '返礼品代', TRUE, '受注ベース', '課税', '実費'),
('SHIPPING', '送料', TRUE, '請求書ベース', '課税', '実費'),
('POSTAGE', '郵便代', TRUE, '請求書ベース', '課税', '実費'),
('ADVERTISING', '広告費', TRUE, '請求書ベース', '課税', '実費'),
('SYSTEM_FEE', 'システム費用', TRUE, '請求書ベース', '課税', '固定費'),
('OTHER', 'その他', TRUE, '請求書ベース', '課税', '実費');

-- 3. ポータルサイトマスタ（20件）
INSERT INTO portal_sites (site_code, site_name) VALUES
('AMAZON', 'Amazon'),
('ANA', 'ANA'),
('AUPAY', 'auPAY'),
('JAL', 'JAL'),
('JREMALL', 'JREMALL'),
('YAHOO', 'Yahoo'),
('SATOFULL', 'さとふる'),
('SAISON', 'セゾン'),
('CHOICE', 'ふるさとチョイス'),
('PREMIUM', 'ふるさとプレミアム'),
('HONPO', 'ふるさと本舗'),
('FURUNAVI', 'ふるなび'),
('FURULABO', 'ふるラボ'),
('POKEMARU', 'ポケマル'),
('MAIFURU', 'まいふる'),
('RAKUTEN', '楽天'),
('MITSUKOSHI', '三越伊勢丹'),
('MADOGUCHI', '窓口'),
('PHONE', '電話'),
('FAX', 'FAX');

-- 4. ポータル支払費目マスタ（6件）
INSERT INTO portal_expense_types (expense_type_code, expense_type_name) VALUES
('PORTAL_USAGE', 'ポータルサイト利用料'),
('PORTAL_AD', '広告料'),
('CREDIT_FEE', 'クレジット決済手数料'),
('PAYMENT_AGENT', '決済代行料'),
('POINT_COST', 'ポイント原資'),
('OTHER_PORTAL', 'その他ポータル関連費');

-- 5. 集計基準マスタ（3件）
INSERT INTO aggregation_bases (basis_code, basis_name, basis_date_field) VALUES
('ORDER_BASE', '受注ベース', '受付日 / 寄附日'),
('INVOICE_BASE', '請求書ベース', '請求書到着月'),
('SHIPMENT_BASE', '発送完了ベース', '発送完了日');

-- 6. 経費率・返礼率閾値マスタ（全自治体共通の初期値）
INSERT INTO thresholds (threshold_type, threshold_value, alert_level, valid_from) VALUES
('経費率', 0.5000, '警告', '2026-04-01'),
('返礼率', 0.3000, '警告', '2026-04-01');
