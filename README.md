# funny`s- 面白共有サイト 

#### 面白いもの共有サイト

- **目的**
    - XやInstagram、YouTube、TikTok、ニコニコなどで見つけたものを**まとめて共有**できる場所
    - ネガティブ投稿が多いSNSに不満がある人向けに、**面白い投稿が集まる場**を作る
- **想定UI**
    - X（Twitter）風
- **機能アイデア**
    - ログイン機能
    - ランキング（ファニーボタン＝いいね相当）
        - 今日／週間／月間／年間／累計
    - トレンド機能
    
    - リアクション種類を増やす案
        - 泣
        - 楽しい
        - 驚き
        - かっこいい
        - かわいい
        - ⁈
        - それぞれのランキング

## **技術スタック想定**

#### OS

- Ubuntu

#### 開発環境

- Docker

#### フロントエンド

- HTML
- CSS
- Tailwind CSS
- JavaScript
- TypeScript（必要に応じて）

#### バックエンド

- Ruby 3.4.2
- Ruby on Rails　8.1.2

#### 品質・セキュリティ（Gem）

認証

- **devise**：ログインが要るなら最優先
- **omniauth + omniauth-xxx**：Google/GitHubログインやるなら（Deviseと併用が多い）

ページング

- **pagy**：軽くて速い。

検索

- **ransack**：管理画面/一覧検索に便利。

便利系

- **friendly_id**：URLを `posts/123` → `posts/funny-title` みたいにしたいなら
- **rails-i18n**：
- dotenv-rails
- capybara

テスト

- **rspec-rails**
- **factory_bot_rails**
- **faker**

開発効率

- **pry**（or `pry-rails`）：デバッグに便利
- **better_errors**：開発時の例外表示が見やすい
- **bullet**：N+1検知

セキュリティ/品質（CIで効く）

- **brakeman**
- **bundler-audit**
- **rubocop**

#### DB

- Postgres 18

#### テスト

- RSpec
- Playwright

#### CI/CD

- GitHub Actions

#### インフラ（AWS）

- ECS（Fargate）
- RDS
- ALB
- CloudWatch
- Secrets Manager
- Terraform（収益が見込めそうなら）

#### 監視

- Sentry
- Datadog（余裕があれば）

#### ツール

- IDE: Cursor
- 設計（図）: [draw.io](http://draw.io)（クラス図作成）
- レイアウト設計: Figma
- バージョン管理: Git / GitHub
- 依存更新: Dependabot（GitHubで自動アップデート）