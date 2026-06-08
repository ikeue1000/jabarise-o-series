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

## 2026年6月9日（追記2）

- [FIX] README.mdの技術構成を「未定」から「ConoHa VPS・PostgreSQL前提」に修正
- [FIX] MANUS_PROGRESS.mdのフェーズ0未着手一覧を「指示書0作成→DBスキーマ設計」の順に修正
