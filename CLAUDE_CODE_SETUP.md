# Claude Code への指示｜GitHub初期セットアップ

## やること

以下の手順でGitHubリポジトリを作成し、ファイルをpushする。

---

## 前提情報

- GitHubユーザー名：`ikeue1000`
- ローカルフォルダ：`C:\Users\ikeue\OneDrive - 株式会社じゃばらいず北山\デスクトップ\ikeueデータ\◆経営\Oシリーズ`
- リポジトリ名：`jabarise-o-series`

---

## 手順

### 1. ローカルフォルダに移動

```bash
cd "C:\Users\ikeue\OneDrive - 株式会社じゃばらいず北山\デスクトップ\ikeueデータ\◆経営\Oシリーズ"
```

### 2. Gitの初期化とpush

```bash
git init
git add .
git commit -m "initial commit: ふるさと納税業務システム引継ぎファイル一式"
git branch -M main
git remote add origin https://github.com/ikeue1000/jabarise-o-series.git
git push -u origin main
```

### 3. GitHubでリポジトリが存在しない場合は先に作成

```bash
gh repo create ikeue1000/jabarise-o-series --public --description "ふるさと納税業務システム｜じゃばらいず北山"
```

または GitHub.com で手動作成：
1. https://github.com/new にアクセス
2. Repository name: `jabarise-o-series`
3. Public を選択
4. 「Create repository」をクリック
5. その後 手順2のpushコマンドを実行

### 4. 確認

push完了後、以下のURLでファイルが見えることを確認する：
```
https://github.com/ikeue1000/jabarise-o-series
```

---

## 注意

- pushエラーが出た場合はエラー内容を報告して指示を待つ
- フォルダ構成を勝手に変えない
- OneDriveの同期エラーが出た場合は一時的にOneDriveを停止してから実行する
