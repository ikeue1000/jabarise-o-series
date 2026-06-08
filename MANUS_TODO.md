# MANUS_TODO.md
# 次にやる作業

最終更新：2026年6月9日
※最大10件まで。増やさないこと。完了したら削除してPROGRESS.mdに移す。

---

## 今すぐやること（フェーズ0）

1. **ConoHa VPS上でPostgreSQLを準備する**
   - 池上確認後に実施
   - 勝手にサーバー操作しない

2. **空のDBを作成する**
   - DB名は jabarise_db を基本とする
   - 既存DBに上書きしない

3. **SQLを順番に実行する**
   - sql/01_create_tables.sql
   - sql/02_insert_initial_data.sql
   - sql/03_constraints_and_indexes.sql
   - sql/04_audit_log_protection.sql
   - sql/05_verify_phase0.sql

4. **05_verify_phase0.sql の結果を池上に報告する**
   - 全項目OKか確認
   - エラーがあれば実行を止める

---

## 次にやること（フェーズ0完了後）

5. **実装指示書1（Billoフェーズ1）の作成**
   - 仕様書v0.7.2 §7をベースに、画面・API・取込処理・判定ロジック・テスト条件を書く
   - 完了条件：池上確認済みであること

6. **Billo：全件データ取込処理**
   - 寄附情報CSV（Aテーブル）と配送情報CSV（Bテーブル）の取込
   - 寄附設定金額の合計禁止ルールを必ず実装
   - 完了条件：北山村・串本町の実データで取込テスト完了

---

## 保留（指示があるまで着手しない）

7. Costo実装（フェーズ2：2026年10月目標）
8. Payo実装（フェーズ3以降）
9. PCA連携（フェーズ4以降）
