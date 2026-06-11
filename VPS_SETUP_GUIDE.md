# VPS準備手順書
# jabarise-o-series-db PostgreSQL セットアップ

**対象VPS**: jabarise-o-series-db のみ  
**禁止**: hyoka VPS には絶対に触れないこと  
**禁止**: rootパスワード・SSH秘密鍵・DBパスワード・環境変数をGitHubやチャットに貼らないこと  
**作業範囲**: PostgreSQLインストール〜空DB確認まで。SQLファイルの実行は別指示があるまで行わないこと

---

## STEP 1: VPSにSSH接続する

```bash
ssh <YOUR_USER>@<VPS_IP_ADDRESS>
```

**成功時の表示例**:
```
Welcome to Ubuntu 24.04 LTS ...
<YOUR_USER>@jabarise-o-series-db:~$
```

**確認ポイント**: プロンプトが表示されれば接続成功。`hostname` コマンドで対象VPSであることを確認する。

```bash
hostname
```

**期待値**: `jabarise-o-series-db` または設定したホスト名が表示されること。

---

## STEP 2: システムパッケージを最新化する

```bash
sudo apt update && sudo apt upgrade -y
```

**成功時の表示例**:
```
Reading package lists... Done
...
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
```

**確認ポイント**: エラーなく完了すること。

---

## STEP 3: PostgreSQLをインストールする

```bash
sudo apt install -y postgresql postgresql-contrib
```

**成功時の表示例**:
```
Setting up postgresql-16 ...
...
Processing triggers for systemd ...
```

**確認ポイント**: エラーなく完了すること。バージョンは Ubuntu 24.04 のデフォルト（PostgreSQL 16系）が入る。

---

## STEP 4: PostgreSQLの起動と自動起動設定を確認する

```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql
sudo systemctl status postgresql
```

**成功時の表示例**:
```
● postgresql.service - PostgreSQL RDBMS
     Loaded: loaded (/lib/systemd/system/postgresql.service; enabled; ...)
     Active: active (running) since ...
```

**確認ポイント**: `Active: active (running)` と表示されること。`enabled` になっていること（再起動後も自動起動）。

---

## STEP 5: PostgreSQLのバージョンを確認する

```bash
psql --version
```

**成功時の表示例**:
```
psql (PostgreSQL) 16.x
```

**確認ポイント**: バージョン番号が表示されること。

---

## STEP 6: PostgreSQL用OSユーザーに切り替える

```bash
sudo -i -u postgres
```

**成功時の表示例**:
```
postgres@jabarise-o-series-db:~$
```

**確認ポイント**: プロンプトが `postgres@...` に変わること。

---

## STEP 7: PostgreSQL管理ユーザー（DBロール）を作成する

```bash
createuser --interactive --pwprompt jabarise_user
```

対話形式で以下を入力する:

```
Enter name of role to add: jabarise_user
Enter password for new role: <DB_PASSWORD>
Enter it again: <DB_PASSWORD>
Shall the new role be a superuser? (y/n) n
Shall the new role be allowed to create databases? (y/n) n
Shall the new role be allowed to create more new roles? (y/n) n
```

**成功時の表示例**: プロンプトに戻ること（エラーなし）。

**確認ポイント**: `<DB_PASSWORD>` は安全なパスワードを設定すること。チャットやGitHubには絶対に貼らないこと。

---

## STEP 8: 空DB jabarise_db を作成する

```bash
createdb -O jabarise_user jabarise_db
```

**成功時の表示例**: プロンプトに戻ること（エラーなし）。

**確認ポイント**: エラーが出なければDB作成成功。

---

## STEP 9: DBが作成されたことを確認する

```bash
psql -l
```

**成功時の表示例**:
```
                                  List of databases
     Name      |    Owner     | Encoding | Locale Provider | ...
---------------+--------------+----------+-----------------+----
 jabarise_db   | jabarise_user| UTF8     | libc            | ...
 postgres      | postgres     | UTF8     | libc            | ...
 template0     | postgres     | UTF8     | libc            | ...
 template1     | postgres     | UTF8     | libc            | ...
```

**確認ポイント**: `jabarise_db` が一覧に表示され、Owner が `jabarise_user` であること。

---

## STEP 10: postgresユーザーを抜ける

```bash
exit
```

**確認ポイント**: 元のSSHユーザーのプロンプトに戻ること。

---

## STEP 11: jabarise_user で jabarise_db に接続する

```bash
psql -U jabarise_user -d jabarise_db -h localhost
```

パスワードを求められたら `<DB_PASSWORD>` を入力する。

**成功時の表示例**:
```
psql (16.x)
Type "help" for help.

jabarise_db=>
```

**確認ポイント**: プロンプトが `jabarise_db=>` になること。

---

## STEP 12: \dt で空DBであることを確認する（必須）

psqlプロンプト内で実行する:

```sql
\dt
```

**成功時の表示例（空DBの場合）**:
```
Did not find any relations.
```

**確認ポイント**: `Did not find any relations.` と表示されること。テーブルが1件でも存在する場合は作業を止めて報告すること。

---

## STEP 13: psqlを終了する

```sql
\q
```

**確認ポイント**: SSHのプロンプトに戻ること。

---

## 完了後の報告事項

以下をチャットで報告してください（パスワード・鍵は絶対に含めないこと）:

1. STEP 4: `Active: active (running)` の確認結果
2. STEP 9: `psql -l` の出力（`jabarise_db` が表示されているか）
3. STEP 12: `\dt` の出力（`Did not find any relations.` であるか）

---

## 次のアクション（空DB確認後）

`\dt` で空DBが確認できたら、SQLファイルの実行指示を別途行います。  
**SQLファイルの実行は、池上からの別指示があるまで行わないこと。**
