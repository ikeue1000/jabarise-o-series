# CHANGELOG.md
# 変更履歴

形式：`[日付] [区分] 内容`
区分：ADD（追加）/ UPDATE（更新）/ FIX（修正）/ DELETE（削除）/ DECISION（判断・方針）

---

## 2026年6月9日

- [ADD] GitHubリポジトリ jabarise-o-series 作成
- [ADD] Manus用引継ぎ5ファイル作成（README / HANDOFF / PROGRESS / TODO / CHANGELOG）
- [DECISION] 仕様書v0.7.2を正本として確定
- [DECISION] フェーズ0（共通DB基盤）を先行着手する方針を確定
- [DECISION] Manusはファイル依存運用とする（セッション間の記憶に依存しない）
- [DECISION] 取込データはAテーブル（寄附・請求判定）とBテーブル（返礼品・配送）の2テーブル構成に確定
- [DECISION] 寄附設定金額は行またいで合計禁止ルールを実装必須とする
- [DECISION] 集計基準は経費項目ごとに設定（受注ベース：委託料・返礼品代、請求書ベース：その他）
- [DECISION] 北竜町の返礼品代はGL由来のため自社集計対象外とする

---

※このファイルは実装変更のたびに追記する。過去の記録は削除しない。

## 2026年6月9日（追記）

- [UPDATE] MANUS_TODOの最初のタスクを「共通DBスキーマ設計」から「指示書0作成」に変更
- [UPDATE] MANUS_TODOの「自治体マスタ初期データ投入」を名称のみ仮登録に修正（コード・料率は推測禁止）
- [ADD] MANUS_HANDOFFに技術前提を追加（ConoHa VPS 4GB・PostgreSQL）
- [DECISION] DBはConoHa VPS上のPostgreSQLで確定。サーバー操作は池上指示のもとで実施
- [DECISION] Manusへの最初の指示は「指示書0作成のみ」。実装着手は指示書0確認後

---

## 2026年6月12日

- [DECISION] 指示書0：共通DB基盤構築指示書 v0.3 を池上確認OKとして確定
- [ADD] フェーズ0実装用SQLファイル5本作成（01_create_tables〜05_verify_phase0）
- [ADD] VPS_SETUP_GUIDE.md 作成（PostgreSQL準備・DB作成手順書）
- [ADD] ConoHa VPS jabarise-o-series-db 上に PostgreSQL 16.14 インストール・起動確認
- [ADD] DBロール jabarise_user 作成（superuser: No）
- [ADD] 空DB jabarise_db 作成・\dt 空確認（Did not find any relations.）
- [ADD] フェーズ0 SQL実行完了（01〜04）・05_verify_phase0 全項目OK（池上確認済み）
- [FIX] MANUS_HANDOFF.md の VPS IP を 160.251.203.233 → 160.251.233.123 に修正
- [UPDATE] MANUS_HANDOFF.md 技術前提を実績値に更新（PostgreSQL 16.14・接続コマンド・SQLファイル設置場所）
- [UPDATE] MANUS_PROGRESS.md をフェーズ0実装完了に更新
- [UPDATE] MANUS_TODO.md からフェーズ0 SQL実行タスクを削除・フェーズ1タスクに更新
