# フェーズ0：共通DB基盤構築 SQL実行手順

本ディレクトリには、ふるさと納税業務システム（Billo / Costo / Payo）の共通DB基盤を構築するためのSQLスクリプトが含まれています。

## 実行前の注意点

1. **実行環境の確認**
   - 対象DBは ConoHa VPS 上の PostgreSQL です。
   - 実行前に、対象のデータベース（例: `jabarise_db`）が作成され、適切な権限で接続できることを確認してください。

2. **実行タイミング**
   - **池上代表の確認と実行指示が出るまでは、これらのSQLを実行しないでください。**

## ファイル構成と実行順序

必ず以下の順序（ファイル名の番号順）で実行してください。

### 1. `01_create_tables.sql`
- **役割**: 19個のテーブルを作成し、基本的なPK/FK制約を定義します。
- **注意**: 外部キー制約の依存関係を考慮した順序でテーブルを作成しています。

### 2. `02_insert_initial_data.sql`
- **役割**: システム稼働に必要な初期データを投入します。
- **内容**:
  - 自治体マスタ（24自治体の名称のみ仮登録。コード・都道府県はNULL）
  - 請求項目マスタ（7件）
  - ポータルサイトマスタ（20件）
  - ポータル支払費目マスタ（6件）
  - 集計基準マスタ（3件）
  - 経費率・返礼率閾値マスタ（全自治体共通の初期値）

### 3. `03_constraints_and_indexes.sql`
- **役割**: 複合ユニーク制約や、検索パフォーマンス向上のためのインデックスを追加します。
- **内容**: 段階料率の順序重複防止、月次確定の年月重複防止など。

### 4. `04_audit_log_protection.sql`
- **役割**: 監査ログ（`audit_logs` テーブル）の改ざんを防止するためのデータベーストリガーを設定します。
- **内容**: UPDATE および DELETE 操作をブロックするPL/pgSQL関数とトリガーを作成します。

### 5. `05_verify_phase0.sql`
- **役割**: 01～04の実行完了後に実行し、フェーズ0の実装内容を自動判定で確認する確認用SQLです。
- **内容**:
  - テーブル数が19件であること
  - 各テーブルの初期データ件数（municipalities=24、billing_items=7、portal_sites=20、portal_expense_types=6、aggregation_bases=3、thresholds=2）
  - audit_logs に UPDATE/DELETE 禁止トリガーが2件存在すること
  - billing_items の tax_type 内容の目視確認用出力
- **注意**: 必ず 01～04 の実行完了後に実行してください。全項目が「OK」であることを確認してから池上に報告してください。

## 実行コマンド例（psqlを使用する場合）

```bash
# データベースへの接続と実行（ユーザー名、DB名は環境に合わせて変更してください）
psql -U postgres -d jabarise_db -f 01_create_tables.sql
psql -U postgres -d jabarise_db -f 02_insert_initial_data.sql
psql -U postgres -d jabarise_db -f 03_constraints_and_indexes.sql
psql -U postgres -d jabarise_db -f 04_audit_log_protection.sql

# 01～04の実行完了後に実行（全項目 OK であることを確認する）
psql -U postgres -d jabarise_db -f 05_verify_phase0.sql
```
