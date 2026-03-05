# Funnies

> ポジティブ共有SNS
既存SNSではネガティブな投稿が拡散されやすいアルゴリズム設計が多く、
「楽しいコンテンツだけを見たい」というニーズが満たされていないと感じました。

Funnies は、
「面白さ」「ポジティブさ」を軸にランキング・リアクション設計を行い、
拡散構造そのものを再設計することを目的としています。

X・Instagram・YouTube・TikTok・ニコニコ動画などで見つけた「笑える・感動した」コンテンツのURLを共有し、複数のリアクションで盛り上がれるキュレーションサービスです。

---

## 主な機能

| 機能 | 詳細 |
|---|---|
| **投稿** | URL・タイトル・コメントを入力するだけで投稿できる |
| **埋め込みプレビュー** | X/Twitter は oEmbed (サーバーサイドキャッシュ)、YouTube・ニコニコは iframe、TikTok・Instagram は Stimulus で外部スクリプトを動的ロード |
| **複数リアクション** | funny / laugh / cry / wow / cool / cute / surprised の 7 種類。ログインユーザーはトグル式で ON/OFF |
| **Turbo Stream 更新** | リアクションボタン押下時はページリロードなしでカウントが即時更新 |
| **ランキング** | 今日 / 週間 / 月間 / 年間 / 累計 × リアクション種別でフィルタリング可能 |
| **コメント** | ネストされた返信（parent_id による自己参照）に対応 |
| **フォロー** | ユーザー間の相互フォロー機能 |
| **認証** | Devise によるメール＋パスワード認証。ユーザー名・アバター・カバー画像・自己紹介を設定可能 |
| **ソース自動判別** | URL から投稿元プラットフォームを自動判定し、アイコン・ラベルを表示 |

---

## 技術スタック

### バックエンド
- **Ruby 3.4.2 / Rails 8.1.2**
- **PostgreSQL 18**（マルチDB構成: primary / cache / queue / cable を分離）
- **Solid Queue / Solid Cache / Solid Cable**（Redis 不要の DB バックエンド）
- **Devise** — 認証
- **Pagy** — ページネーション
- **Ransack** — 検索
- **Friendly ID** — スラッグ URL
- **Active Storage** — アバター・カバー画像アップロード

### フロントエンド
- **Hotwire（Turbo + Stimulus）** — SPA ライクな UX を JavaScript フレームワークなしで実現
- **Importmap** — Node.js / バンドラー不要の JS 管理
- **Tailwind CSS**（Play CDN）— ユーティリティファーストな CSS
- **Propshaft** — アセットパイプライン

### インフラ / DevOps
- **Docker / Kamal** — コンテナベースのデプロイ
- **GitHub Actions CI** — PR・main push ごとに 5 ジョブ並列実行

### テスト / 品質
- **RSpec Rails + Factory Bot + Faker + Capybara**
- **Playwright（`capybara-playwright-driver`）** — システムテストで実ブラウザ（Chromium）を使用。失敗時に Trace Viewer 用の `.zip` を自動保存
- **Brakeman** — Rails セキュリティ静的解析
- **Bundler Audit** — Gem 脆弱性チェック
- **RuboCop** (`rubocop-rails-omakase`) — コードスタイル統一
- **Bullet** — N+1 クエリ検出

---

## 設計のポイント

### リアクションのカウント管理
リアクション数は `posts` テーブルの `funny_count` / `laugh_count` 等の非正規化カラムで保持しています。`Reaction` モデルで ON/OFF を管理しつつ、読み取り時に集計クエリが不要になりランキング取得が高速です。

### Turbo Stream によるリアクション更新
リアクションボタンは `form_with` + `ReactionsController#create` で処理し、レスポンスとして `turbo_stream` 形式でボタン部分のみを差し替えます。フルリロードなしで UI が更新されます。

### oEmbed キャッシュ
X/Twitter の埋め込みは外部 oEmbed API をサーバーサイドで取得し、Rails キャッシュ（Solid Cache）に 24 時間保存します。外部 API への不要なリクエストを削減しつつ、ウィジェットの表示が安定します。

### マルチ DB 構成
`config/database.yml` で `primary` / `cache` / `queue` / `cable` を分離。本番環境ではそれぞれ独立した PostgreSQL インスタンスに接続できます。

---

## ドキュメント

| ドキュメント | 内容 |
|---|---|
| [ER図](docs/er_diagram.md) | 全テーブル（アプリ + Solid Queue/Cache/Cable）の定義・リレーション・インデックス |
| [ユースケース図](docs/usecase_diagram.md) | ゲスト / ログインユーザー別のユースケース一覧 |
| [フローチャート](docs/flowchart.md) | 投稿・リアクション・コメント・フォロー・ランキング・登録の処理フロー |

---

## ローカル開発環境のセットアップ（Docker）

**前提:** Docker Desktop（または Docker Engine + Compose Plugin）がインストール済みであること。

> 開発用イメージ（`Dockerfile.dev`）には **Node.js 22 + Playwright Chromium** が含まれているため、システムテストをそのまま実行できます。

```bash
# 1. リポジトリをクローン
git clone https://github.com/your-username/funnies.git
cd funnies

# 2. コンテナをビルド・起動（PostgreSQL + Rails + Playwright）
docker compose up -d --build

# 3. DB 作成 & マイグレーション（初回のみ）
docker compose exec web bin/rails db:create db:migrate

# 4. （任意）シードデータを投入
docker compose exec web bin/rails db:seed
```

ブラウザで http://localhost:3000 を開くと起動しています。

### よく使うコマンド

```bash
# ログを確認
docker compose logs -f web

# Rails コンソール
docker compose exec web bin/rails console

# テスト実行
docker compose exec web bundle exec rspec

# コンテナを停止
docker compose down

# コンテナ・ボリュームごと削除（DB リセット）
docker compose down -v
```

### 環境変数

`compose.yml` にデフォルト値が設定されているため、ローカル開発は `.env` なしで起動できます。変更したい場合はプロジェクトルートに `.env` を作成してください。

```env
DATABASE_HOST=db
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
```

---

## テスト・CI

```bash
# モデル / リクエストスペック
docker compose exec web bundle exec rspec spec/models spec/requests

# システムスペック（Playwright / Chromium）
docker compose exec web bundle exec rspec spec/system

# 全スペック
docker compose exec web bundle exec rspec

# Lint + セキュリティスキャン + テスト一括実行
bin/ci
```

### Playwright Trace Viewer

システムテストが失敗すると `tmp/capybara/traces/` に Trace ファイル（`.zip`）が自動保存されます。以下のコマンドでブラウザ上で再生可能です。

```bash
npx playwright show-trace tmp/capybara/traces/<ファイル名>.zip
```

各ステップのスクリーンショット・ネットワークリクエスト・DOM スナップショットを時系列で確認できます。

### GitHub Actions CI

PR・main へのプッシュのたびに以下が並列実行されます:

1. `scan_ruby` — Brakeman + Bundler Audit
2. `scan_js`   — Importmap audit
3. `lint`      — RuboCop
4. `test`      — RSpec（モデル / リクエスト）
5. `system-test` — RSpec + Playwright（失敗時スクリーンショットを Artifact 保存）

---

## 今後の予定

- [ ] OmniAuth（Google / GitHub ログイン）
- [ ] ファニーボタン（いいね相当の単独リアクション）の強化
- [ ] トレンド機能（時間減衰スコア）
- [ ] 通知機能
- [ ] 本番デプロイ（AWS ECS Fargate + RDS + ALB）

---

## ライセンス

MIT
