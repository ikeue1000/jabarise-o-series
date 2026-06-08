# 指示書0：共通DB基盤構築指示書 v0.3

作成日：2026年6月9日  
対象フェーズ：フェーズ0（共通DB基盤）  
ステータス：**池上確認待ち（最終確認）**

---

## 1. 本指示書の目的と位置づけ

本指示書は、仕様書 v0.7.2 §5-2・§10-2 に基づき、フェーズ0で構築する共通DB基盤のテーブル定義を整理したものである。

**本指示書の段階では実装は行わない。テーブル定義の確認と合意のみを目的とする。**

---

## 2. 全体方針

| 方針 | 内容 |
|---|---|
| 実装順 | フェーズ0完了後にフェーズ1（Billo）へ進む。同時並行禁止 |
| マスタ一元化 | 自治体・契約・除外条件等は共通DBに1つだけ持つ。アプリ側に複製しない |
| 推測入力禁止 | 不明なコード・料率・区分は空欄のまま設計し、受領後に投入する |
| 後続フェーズ対応 | フェーズ0の時点でCosto・Payoが必要とするデータ構造を持たせる |
| ファイル保管 | 取込ファイル・原本ファイルの実体はVPS上のローカルパスに保存。DBにはパス文字列を保持。後でS3等に移行できる構造にすること |
| DB | ConoHa VPS（4GB）上のPostgreSQL。サーバー操作は池上指示のもとで実施 |

---

## 3. テーブル全体構成（19テーブル）

| # | テーブル名 | 分類 |
|---|---|---|
| 1 | ユーザーマスタ | 権限管理 |
| 2 | 自治体マスタ | 自治体・契約 |
| 3 | 自治体契約マスタ | 自治体・契約 |
| 4 | 契約段階料率マスタ | 自治体・契約 |
| 5 | 除外サイト・除外条件マスタ | 自治体・契約 |
| 6 | 返礼品なし寄附ルールマスタ | 自治体・契約 |
| 7 | 請求項目マスタ | 請求・経費 |
| 8 | ポータルサイトマスタ | ポータル |
| 9 | ポータル支払費目マスタ | ポータル |
| 10 | 事業者マスタ | 事業者 |
| 11 | 手数料種別マスタ | 手数料 |
| 12 | 手数料マスタ | 手数料 |
| 13 | 請求書予定マスタ | 運用補助 |
| 14 | 経費率・返礼率閾値マスタ | 運用補助 |
| 15 | 集計基準マスタ | 運用補助 |
| 16 | 取込ファイル管理 | 証跡 |
| 17 | 原本ファイル管理 | 証跡 |
| 18 | 監査ログ | 証跡 |
| 19 | 月次確定管理 | 確定管理 |

---

## 4. テーブル定義

### 4-1. ユーザーマスタ

**目的**：システム内のログインユーザーを管理する。外部認証は使わず、システム内で完結する。監査ログの操作者管理に利用。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| user_id | SERIAL | PK | ユーザーID（自動採番） |
| login_id | VARCHAR(50) | UNIQUE, NOT NULL | ログインID |
| user_name | VARCHAR(100) | NOT NULL | 氏名 |
| role | VARCHAR(20) | NOT NULL | 権限区分：`経理担当` / `ふるさと担当` / `管理者` / `幹部` |
| is_active | BOOLEAN | NOT NULL, DEFAULT TRUE | 有効フラグ |
| created_at | TIMESTAMP | NOT NULL | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | 更新日時 |

**設計補足**：パスワードハッシュ等の認証情報カラムはフェーズ1の実装指示書で定義する。フェーズ0では構造のみ確定する。

---

### 4-2. 自治体マスタ

**目的**：Billo・Costo・Payo全体の管理単位となる基本マスタ。承認フローのパターンを自治体ごとに設定できる設計にする。

`municipality_id` を内部主キーとし、`municipality_code`（総務省コード）は後から投入できるよう NULL 可の UNIQUE カラムとして分離する。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| municipality_id | SERIAL | PK | 内部主キー（自動採番） |
| municipality_code | CHAR(6) | UNIQUE, NULL可 | 総務省全国地方公共団体コード（6桁）。確認後に投入 |
| municipality_name | VARCHAR(100) | NOT NULL | 自治体名（例：串本町） |
| prefecture | VARCHAR(20) | NULL可 | 都道府県名 |
| approval_flow_pattern | VARCHAR(20) | NOT NULL, DEFAULT '標準' | 承認フローパターン（自治体ごとに設定。選択肢はフェーズ1で確定） |
| is_active | BOOLEAN | NOT NULL, DEFAULT TRUE | 受託中フラグ（受託終了時にFALSEへ） |
| created_at | TIMESTAMP | NOT NULL | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | 更新日時 |

**初期データ**：24自治体の名称のみ仮登録。`municipality_code`・`prefecture` は確認後に投入する。

> 対象自治体：串本町・古座川町・田辺市・すさみ町・由良町・みなべ町・平泉町・涌谷町・豊中市・宮城県美里町・北山村・太地町・新宮市・紀宝町・熊野市・真庭市・広川町・北竜町・紀美野町・かつらぎ町・葛城市・伊賀市・住田町・丹波山村

**設計補足**：`approval_flow_pattern` の具体的な選択肢（例：「経理→管理者」「経理→ふるさと担当→管理者」等）はフェーズ1の月次承認ワークフロー設計時に確定し、自治体マスタ画面で選択できる形にする。

---

### 4-3. 自治体契約マスタ

**目的**：委託料率・契約区分・請求可否・支払代行有無を管理する。Billoの委託料計算・Payoの支払代行判定に利用。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| contract_id | SERIAL | PK | 契約ID（自動採番） |
| municipality_id | INTEGER | NOT NULL, FK → 自治体マスタ | 内部自治体ID |
| contract_type | VARCHAR(20) | NOT NULL | 契約区分：`50%委託型` / `手数料型` / `その他` |
| fee_pattern | VARCHAR(20) | NOT NULL | 料率パターン：`まる抱え型` / `手数料型` / `段階料率型` / `固定委託費型` |
| fee_rate | NUMERIC(6,4) | NULL | 委託料率（例：0.5000 = 50%税込）。段階料率型・固定委託費型はNULL |
| fee_amount_fixed | NUMERIC(12,0) | NULL | 固定委託費額（固定委託費型のみ使用） |
| fee_includes_tax | BOOLEAN | NOT NULL, DEFAULT TRUE | 料率が税込かどうか |
| billing_target | BOOLEAN | NOT NULL, DEFAULT TRUE | 請求対象フラグ |
| payment_agency | BOOLEAN | NOT NULL, DEFAULT FALSE | 支払代行有無 |
| valid_from | DATE | NOT NULL | 適用開始日 |
| valid_to | DATE | NULL | 適用終了日（NULL = 現在有効） |
| notes | TEXT | NULL | 備考（数字変更の経緯等） |
| created_at | TIMESTAMP | NOT NULL | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | 更新日時 |

**設計補足**：`fee_pattern = '段階料率型'` の場合、料率の詳細は次の「契約段階料率マスタ」で管理する。

---

### 4-4. 契約段階料率マスタ

**目的**：段階料率型の契約における各段階の閾値と料率を管理する。現在は2段階、最大5段階以内で設計する。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| tier_id | SERIAL | PK | 段階ID（自動採番） |
| contract_id | INTEGER | NOT NULL, FK → 自治体契約マスタ | 契約ID |
| tier_order | SMALLINT | NOT NULL | 段階順序（1〜5） |
| threshold_amount | NUMERIC(14,0) | NULL | 閾値金額（この金額以下に適用する上限。最終段階はNULL） |
| fee_rate | NUMERIC(6,4) | NOT NULL | 当該段階の委託料率 |
| fee_includes_tax | BOOLEAN | NOT NULL, DEFAULT TRUE | 料率が税込かどうか |
| notes | TEXT | NULL | 備考 |
| created_at | TIMESTAMP | NOT NULL | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | 更新日時 |

**設計補足**：`contract_id` + `tier_order` の組み合わせに一意制約を設ける。最終段階（上限なし）は `threshold_amount = NULL` とする。

---

### 4-5. 除外サイト・除外条件マスタ

**目的**：自治体別の請求対象外を判定する。Billoの除外判定・Costoの経費率管理に利用。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| exclusion_id | SERIAL | PK | 除外条件ID（自動採番） |
| municipality_id | INTEGER | NOT NULL, FK → 自治体マスタ | 内部自治体ID |
| exclusion_type | VARCHAR(30) | NOT NULL | 除外種別：`サイト名除外` / `返礼品なし寄附` / `期間除外` / `その他` |
| site_code | VARCHAR(20) | NULL, FK → ポータルサイトマスタ | 除外対象サイトコード（`サイト名除外` 時のみ使用） |
| exclusion_reason | VARCHAR(200) | NULL | 除外理由（例：途中受託のため直接寄附を除外、クレーム再発送等） |
| valid_from | DATE | NOT NULL | 適用開始日 |
| valid_to | DATE | NULL | 適用終了日（NULL = 現在有効） |
| created_at | TIMESTAMP | NOT NULL | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | 更新日時 |

---

### 4-6. 返礼品なし寄附ルールマスタ

**目的**：返礼品なし寄附に対する委託料・手数料の請求可否を自治体別に管理する。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| rule_id | SERIAL | PK | ルールID（自動採番） |
| municipality_id | INTEGER | NOT NULL, FK → 自治体マスタ | 内部自治体ID |
| billing_fee_allowed | BOOLEAN | NOT NULL | 委託料請求可否 |
| billing_commission_allowed | BOOLEAN | NOT NULL | 手数料請求可否 |
| notes | TEXT | NULL | 例外条件・備考 |
| valid_from | DATE | NOT NULL | 適用開始日 |
| valid_to | DATE | NULL | 適用終了日 |
| created_at | TIMESTAMP | NOT NULL | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | 更新日時 |

---

### 4-7. 請求項目マスタ

**目的**：自治体への請求項目（委託料・返礼品代・送料・郵便代・広告費・システム費等）の請求可否と集計基準を管理する。Billoの請求項目計算・Costoの経費管理に利用。

ポータルサイトへの支払費目（利用料・広告料・決済手数料等）はポータル支払費目マスタで管理するため、本マスタには含めない。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| item_code | VARCHAR(20) | PK | 請求項目コード |
| item_name | VARCHAR(100) | NOT NULL | 項目名 |
| billing_allowed | BOOLEAN | NOT NULL | 請求可否 |
| aggregation_basis | VARCHAR(20) | NOT NULL | 集計基準：`受注ベース` / `請求書ベース` |
| tax_type | VARCHAR(10) | NOT NULL | 税区分：`課税` / `非課税` / `不課税` |
| cost_type | VARCHAR(10) | NOT NULL | 費用区分：`固定費` / `実費` |
| created_at | TIMESTAMP | NOT NULL | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | 更新日時 |

**初期データ**（自治体への請求項目に絞る）：

| item_code | item_name | aggregation_basis |
|---|---|---|
| COMMISSION | 委託料 | 受注ベース |
| RETURN_GIFT | 返礼品代 | 受注ベース |
| SHIPPING | 送料 | 請求書ベース |
| POSTAGE | 郵便代 | 請求書ベース |
| ADVERTISING | 広告費 | 請求書ベース |
| SYSTEM_FEE | システム費用 | 請求書ベース |
| OTHER | その他 | 請求書ベース |

---

### 4-8. ポータルサイトマスタ

**目的**：寄附受付サイトの情報を管理する。Billoのサイト手数料計算・Costoのポータル支払明細管理に利用。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| site_code | VARCHAR(20) | PK | サイトコード |
| site_name | VARCHAR(100) | NOT NULL | サイト名 |
| is_active | BOOLEAN | NOT NULL, DEFAULT TRUE | 利用中フラグ |
| notes | TEXT | NULL | 備考 |
| created_at | TIMESTAMP | NOT NULL | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | 更新日時 |

**初期データ**（20件）：Amazon・ANA・auPAY・JAL・JREMALL・Yahoo・さとふる・セゾン・ふるさとチョイス・ふるさとプレミアム・ふるさと本舗・ふるなび・ふるラボ・ポケマル・まいふる・楽天・三越伊勢丹・窓口・電話・FAX  
※モンベル等追加の可能性あり。`is_active` 管理で対応する。

---

### 4-9. ポータル支払費目マスタ

**目的**：ポータルサイトへの支払を費目単位で分類・管理する。Costoのポータル支払明細管理・経費率算定に利用。ポータルサイトへの支払費目はすべて本マスタで管理し、請求項目マスタには持たない。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| expense_type_code | VARCHAR(20) | PK | 費目コード |
| expense_type_name | VARCHAR(100) | NOT NULL | 費目名 |
| aggregation_basis | VARCHAR(20) | NOT NULL, DEFAULT '請求書ベース' | 集計基準（固定で `請求書ベース`） |
| created_at | TIMESTAMP | NOT NULL | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | 更新日時 |

**初期データ**（仕様書§8-4より）：

| expense_type_code | expense_type_name |
|---|---|
| PORTAL_USAGE | ポータルサイト利用料 |
| PORTAL_AD | 広告料 |
| CREDIT_FEE | クレジット決済手数料 |
| PAYMENT_AGENT | 決済代行料 |
| POINT_COST | ポイント原資 |
| OTHER_PORTAL | その他ポータル関連費 |

---

### 4-10. 事業者マスタ

**目的**：返礼品提供事業者の情報を管理する。Billoの返礼品代計算・Payoの事業者支払管理に利用。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| vendor_code | VARCHAR(20) | PK, UNIQUE | 事業者コード（担当者が任意入力。重複チェック必須） |
| vendor_name | VARCHAR(200) | NOT NULL | 事業者名（正式表記） |
| vendor_name_aliases | TEXT | NULL | 表記ゆれ一覧（改行区切りで保持） |
| payment_agency | BOOLEAN | NOT NULL, DEFAULT FALSE | 支払代行対象フラグ |
| is_active | BOOLEAN | NOT NULL, DEFAULT TRUE | 利用中フラグ |
| created_at | TIMESTAMP | NOT NULL | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | 更新日時 |

**設計補足**：`vendor_code` は担当者が任意入力する略称コード（例：IKE）。登録時・更新時に重複チェックを実施し、重複があれば登録を拒否する。

---

### 4-11. 手数料種別マスタ

**目的**：手数料の種別を管理する。毎年変更の可能性があるため固定一覧にせず、マスタ画面で追加・変更できる設計にする。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| fee_type_code | VARCHAR(20) | PK | 手数料種別コード |
| fee_type_name | VARCHAR(100) | NOT NULL | 手数料種別名（例：基本手数料、広告手数料、決済手数料） |
| is_active | BOOLEAN | NOT NULL, DEFAULT TRUE | 利用中フラグ |
| created_at | TIMESTAMP | NOT NULL | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | 更新日時 |

**設計補足**：手数料種別の追加・変更はマスタ画面から実施する。削除は `is_active = FALSE` で論理削除とし、既存の手数料マスタレコードへの影響を防ぐ。

---

### 4-12. 手数料マスタ

**目的**：サイト別×自治体別×手数料種別の個別手数料率を管理する。Billoのサイト手数料計算に利用。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| fee_id | SERIAL | PK | 手数料ID（自動採番） |
| site_code | VARCHAR(20) | NOT NULL, FK → ポータルサイトマスタ | サイトコード |
| municipality_id | INTEGER | NOT NULL, FK → 自治体マスタ | 内部自治体ID |
| fee_type_code | VARCHAR(20) | NOT NULL, FK → 手数料種別マスタ | 手数料種別コード |
| fee_rate | NUMERIC(6,4) | NULL | 手数料率（例：0.0715 = 7.15%） |
| fee_amount_fixed | NUMERIC(12,0) | NULL | 固定手数料額（率ではなく固定額の場合） |
| fee_includes_tax | BOOLEAN | NOT NULL, DEFAULT TRUE | 税込フラグ |
| valid_from | DATE | NOT NULL | 適用開始日 |
| valid_to | DATE | NULL | 適用終了日 |
| created_at | TIMESTAMP | NOT NULL | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | 更新日時 |

**設計補足**：`fee_rate` と `fee_amount_fixed` はどちらか一方のみ入力する。両方NULLは登録不可とする。

---

### 4-13. 請求書予定マスタ

**目的**：毎月必要な請求書・支払通知書・利用明細の未アップロードを検知する。自治体ごとに異なるため、自治体マスタまたは請求マスタ画面で個別登録できる設計にする。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| schedule_id | SERIAL | PK | 予定ID（自動採番） |
| municipality_id | INTEGER | NOT NULL, FK → 自治体マスタ | 内部自治体ID |
| expense_category | VARCHAR(30) | NOT NULL | 費目種別：`ポータル手数料` / `返礼品代` / `送料` / `システム利用料` / `郵便代` / `広告料` / `その他` |
| site_code | VARCHAR(20) | NULL, FK → ポータルサイトマスタ | 対象サイトコード（ポータル手数料の場合） |
| is_required | BOOLEAN | NOT NULL, DEFAULT TRUE | 必須フラグ |
| notes | TEXT | NULL | 備考（自治体別の差異等） |
| created_at | TIMESTAMP | NOT NULL | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | 更新日時 |

---

### 4-14. 経費率・返礼率閾値マスタ

**目的**：経費率・返礼率・粗利率のアラート閾値を管理する。自治体別設定・変更に対応するためマスタで管理する。Costoの閾値アラートに利用。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| threshold_id | SERIAL | PK | 閾値ID（自動採番） |
| municipality_id | INTEGER | NULL, FK → 自治体マスタ | 内部自治体ID（NULL = 全自治体共通） |
| threshold_type | VARCHAR(20) | NOT NULL | 閾値種別：`経費率` / `返礼率` / `粗利率` |
| threshold_value | NUMERIC(6,4) | NOT NULL | 閾値（例：0.5000 = 50%） |
| alert_level | VARCHAR(10) | NOT NULL | アラートレベル：`警告` / `超過` |
| valid_from | DATE | NOT NULL | 適用開始日 |
| valid_to | DATE | NULL | 適用終了日 |
| created_at | TIMESTAMP | NOT NULL | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | 更新日時 |

**初期値**：経費率 50%（0.5000）・返礼率 30%（0.3000）を全自治体共通（`municipality_id = NULL`）として登録する。

---

### 4-15. 集計基準マスタ

**目的**：受注ベース・請求書ベース・発送完了ベース等の集計基準を定義する。Costo・Billoの集計処理に利用。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| basis_code | VARCHAR(20) | PK | 集計基準コード |
| basis_name | VARCHAR(100) | NOT NULL | 集計基準名 |
| basis_date_field | VARCHAR(100) | NOT NULL | 基準日フィールド名（例：受付日、請求書到着月、発送完了日） |
| description | TEXT | NULL | 説明・注意事項 |
| created_at | TIMESTAMP | NOT NULL | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | 更新日時 |

**初期データ**：

| basis_code | basis_name | basis_date_field |
|---|---|---|
| ORDER_BASE | 受注ベース | 受付日 / 寄附日 |
| INVOICE_BASE | 請求書ベース | 請求書到着月 |
| SHIPMENT_BASE | 発送完了ベース | 発送完了日 |

---

### 4-16. 取込ファイル管理

**目的**：どのCSV・PDF・Excelを取り込んだかの証跡を保持する。Billoの全件データ取込証跡として利用。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| import_file_id | SERIAL | PK | 取込ファイルID（自動採番） |
| municipality_id | INTEGER | NOT NULL, FK → 自治体マスタ | 内部自治体ID |
| file_type | VARCHAR(30) | NOT NULL | ファイル種別：`寄附情報CSV（Aテーブル）` / `配送情報CSV（Bテーブル）` / `その他` |
| original_filename | VARCHAR(255) | NOT NULL | 元ファイル名 |
| stored_path | TEXT | NOT NULL | VPS上の保存パス（後でS3等に移行できる構造とする） |
| target_year_month | CHAR(6) | NOT NULL | 対象年月（例：202601） |
| imported_by_user_id | INTEGER | NOT NULL, FK → ユーザーマスタ | 取込担当者のユーザーID |
| imported_at | TIMESTAMP | NOT NULL | 取込日時 |
| record_count | INTEGER | NULL | 取込件数 |
| notes | TEXT | NULL | 備考 |

---

### 4-17. 原本ファイル管理

**目的**：請求書・支払通知書・ポータル明細等の証跡ファイルを管理する。Billoの請求書管理・Costoのポータル明細証跡に利用。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| original_file_id | SERIAL | PK | 原本ファイルID（自動採番） |
| municipality_id | INTEGER | NOT NULL, FK → 自治体マスタ | 内部自治体ID |
| file_category | VARCHAR(30) | NOT NULL | ファイル区分：`請求書` / `支払通知書` / `ポータル請求書` / `ポータル利用明細` / `その他` |
| original_filename | VARCHAR(255) | NOT NULL | 元ファイル名 |
| stored_path | TEXT | NOT NULL | VPS上の保存パス（後でS3等に移行できる構造とする） |
| target_year_month | CHAR(6) | NOT NULL | 対象年月（例：202601） |
| invoice_number | VARCHAR(100) | NULL | 請求書番号・明細番号 |
| site_code | VARCHAR(20) | NULL, FK → ポータルサイトマスタ | 対象サイトコード（ポータル関連の場合） |
| uploaded_by_user_id | INTEGER | NOT NULL, FK → ユーザーマスタ | アップロード担当者のユーザーID |
| uploaded_at | TIMESTAMP | NOT NULL | アップロード日時 |
| notes | TEXT | NULL | 備考 |

---

### 4-18. 監査ログ

**目的**：マスタ変更・データ取込・承認・差戻し・月次確定等の全操作履歴を保持する。**削除・更新禁止（追記のみ）**。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| log_id | BIGSERIAL | PK | ログID（自動採番） |
| log_type | VARCHAR(30) | NOT NULL | 操作種別：`マスタ変更` / `データ取込` / `AI読取結果` / `目視確認` / `承認` / `差戻し` / `月次確定` / `再オープン` / `CSV出力` / `楽々明細出力` |
| target_table | VARCHAR(100) | NULL | 操作対象テーブル名 |
| target_id | TEXT | NULL | 操作対象レコードID |
| municipality_id | INTEGER | NULL | 関連自治体の内部ID |
| operator_user_id | INTEGER | NOT NULL, FK → ユーザーマスタ | 操作者のユーザーID |
| operator_user_name | VARCHAR(100) | NOT NULL | 操作者の氏名（ユーザー削除後も履歴を保持するため非正規化で保持） |
| operator_role | VARCHAR(20) | NOT NULL | 操作者の権限区分（同上の理由で非正規化） |
| operated_at | TIMESTAMP | NOT NULL | 操作日時 |
| before_value | TEXT | NULL | 変更前の値（JSON形式） |
| after_value | TEXT | NULL | 変更後の値（JSON形式） |
| notes | TEXT | NULL | 備考・コメント |

---

### 4-19. 月次確定管理

**目的**：確定後の数字の後戻りを防止する。確定ロック後の変更は管理者承認が必要。承認フローは自治体マスタの `approval_flow_pattern` に従う。

| カラム名 | 型 | 制約 | 内容 |
|---|---|---|---|
| lock_id | SERIAL | PK | 確定ID（自動採番） |
| municipality_id | INTEGER | NOT NULL, FK → 自治体マスタ | 内部自治体ID |
| target_year_month | CHAR(6) | NOT NULL | 対象年月（例：202601） |
| lock_status | VARCHAR(20) | NOT NULL | 確定ステータス：`未確定` / `確定済` / `再オープン` |
| locked_by_user_id | INTEGER | NULL, FK → ユーザーマスタ | 確定者のユーザーID |
| locked_at | TIMESTAMP | NULL | 確定日時 |
| reopened_by_user_id | INTEGER | NULL, FK → ユーザーマスタ | 再オープン実施者のユーザーID |
| reopened_at | TIMESTAMP | NULL | 再オープン日時 |
| reopen_reason | TEXT | NULL | 再オープン理由 |
| created_at | TIMESTAMP | NOT NULL | 作成日時 |
| updated_at | TIMESTAMP | NOT NULL | 更新日時 |

**設計補足**：`municipality_id` + `target_year_month` の組み合わせに一意制約を設ける。承認フローの具体的なステータス遷移はフェーズ1の月次承認ワークフロー設計時に確定する。

---

## 5. テーブル間の主要リレーション

```
ユーザーマスタ (user_id)
  ├─ 取込ファイル管理 (imported_by_user_id)
  ├─ 原本ファイル管理 (uploaded_by_user_id)
  ├─ 監査ログ (operator_user_id)
  └─ 月次確定管理 (locked_by_user_id / reopened_by_user_id)

自治体マスタ (municipality_id)
  ├─ 自治体契約マスタ
  │   └─ 契約段階料率マスタ (contract_id)
  ├─ 除外サイト・除外条件マスタ
  ├─ 返礼品なし寄附ルールマスタ
  ├─ 手数料マスタ
  ├─ 請求書予定マスタ
  ├─ 経費率・返礼率閾値マスタ（NULL の場合は全自治体共通）
  ├─ 取込ファイル管理
  ├─ 原本ファイル管理
  ├─ 監査ログ
  └─ 月次確定管理

ポータルサイトマスタ (site_code)
  ├─ 除外サイト・除外条件マスタ
  ├─ 手数料マスタ
  ├─ 請求書予定マスタ
  └─ 原本ファイル管理

手数料種別マスタ (fee_type_code)
  └─ 手数料マスタ
```

---

## 6. 特殊ルール（実装時に必ず反映すること）

| 自治体 | ルール | 影響テーブル |
|---|---|---|
| 北竜町 | 返礼品代はGL（総勘定元帳）由来のため自社集計対象外。返礼品代・返礼率・未登録件数はゼロ扱い | 自治体契約マスタ（notes に記録）・経費率閾値マスタ |
| 全自治体共通 | 寄附設定金額は行またいで合計禁止（Bテーブルに複数行ある場合に同じ値が繰り返し入る） | フェーズ1のBテーブル設計時に必ず実装 |

---

## 7. 不明点一覧（残存なし）

v0.1〜v0.2 で列挙した不明点 A-1〜A-6 は全て回答済み。v0.3 時点で設計上の未確定事項はない。

フェーズ1の実装指示書作成時に確定する事項（設計変更ではなく詳細化）：

| 事項 | 確定タイミング |
|---|---|
| 承認フローパターンの具体的な選択肢 | 指示書1（Billoフェーズ1）作成時 |
| 月次確定の詳細ステータス遷移 | 指示書1（Billoフェーズ1）作成時 |
| ユーザーマスタの認証情報カラム | 指示書1（Billoフェーズ1）作成時 |

---

## 8. 完了条件

### 8-1. 指示書レビュー完了条件

本指示書をフェーズ0実装に進めるための確認条件。

1. 本指示書の全テーブル定義・カラム設計について池上確認済みであること
2. 不明点一覧（§7）に未回答の項目がないこと
3. 本指示書が GitHub リポジトリにコミットされていること

### 8-2. フェーズ0実装完了条件

実際にDBを構築し、フェーズ1（Billo）に進むための条件。

1. ConoHa VPS 上に PostgreSQL が構築されていること（池上指示のもとで実施）
2. 本指示書の19テーブルが PostgreSQL 上に作成されていること
3. 自治体マスタに24自治体の名称のみ仮登録が完了していること（`municipality_code`・`prefecture` は確認後に投入）
4. 初期データ（ポータルサイトマスタ20件・請求項目マスタ7件・ポータル支払費目マスタ6件・集計基準マスタ3件・経費率閾値初期値）が投入されていること
5. 監査ログテーブルに削除・更新禁止の制約が設定されていること
6. 上記について池上確認済みであること
