# フローチャート図

> Mermaid 記法。GitHub / VSCode の Mermaid プレビューで表示できます。

---

## 1. 投稿フロー

```mermaid
flowchart TD
    A([ユーザーがホームを開く]) --> B{ログイン済み？}
    B -- No --> C[ログインページへリダイレクト]
    C --> D[メール・パスワードを入力]
    D --> E{認証成功？}
    E -- No --> F[エラーメッセージ表示] --> D
    E -- Yes --> G[ホームへリダイレクト]
    B -- Yes --> G

    G --> H[投稿フォームに URL を入力]
    H --> I{バリデーション}
    I -- URL 形式エラー --> J[エラーメッセージ表示] --> H
    I -- OK --> K[POST /posts]
    K --> L[URL からソース自動判別\ntwitterTwitter / youtube / tiktok ...]
    L --> M[タイトル未入力なら URL から自動生成]
    M --> N[DB 保存]
    N --> O[ホームへリダイレクト\n「投稿しました！」通知]
```

---

## 2. リアクションフロー（Turbo Stream）

```mermaid
flowchart TD
    A([リアクションボタンをクリック]) --> B{ログイン済み？}
    B -- No --> C[ログインページへリダイレクト]
    B -- Yes --> D[POST /posts/:id/reactions\nkind=funny など]

    D --> E{同じ kind のリアクションが\nすでに存在する？}
    E -- Yes --> F[reaction レコードを削除\n＝トグル OFF]
    E -- No --> G[reaction レコードを作成\n＝トグル ON]

    F --> H[post の {kind}_count を再集計]
    G --> H
    H --> I[Turbo Stream レスポンス]
    I --> J[ページ内の reactions パーシャルだけ差し替え]
    J --> K([カウント・ボタン色がリアルタイム更新])
```

---

## 3. コメント投稿フロー

```mermaid
flowchart TD
    A([投稿詳細ページを開く]) --> B{ログイン済み？}
    B -- No --> C[コメントフォームは非表示\nログイン誘導リンクを表示]
    B -- Yes --> D[コメント or 返信フォームに入力]
    D --> E{バリデーション}
    E -- body が空 --> F[エラーメッセージ表示] --> D
    E -- OK --> G[POST /posts/:id/comments\nbody, parent_id]
    G --> H{parent_id あり？}
    H -- Yes --> I[返信コメントとして保存\n自己参照: parent_id]
    H -- No --> J[トップレベルコメントとして保存]
    I --> K[投稿詳細ページへリダイレクト]
    J --> K
```

---

## 4. フォローフロー

```mermaid
flowchart TD
    A([ユーザープロフィールを開く]) --> B{ログイン済み？}
    B -- No --> C[フォローボタンは非表示]
    B -- Yes --> D{自分自身のプロフィール？}
    D -- Yes --> E[フォローボタン非表示\n編集ボタンを表示]
    D -- No --> F{すでにフォロー中？}

    F -- No --> G[「フォロー」ボタン表示]
    G --> H([クリック]) --> I[POST /users/:id/follow]
    I --> J[follows レコード作成]
    J --> K[「フォロー解除」ボタンに切り替え]

    F -- Yes --> L[「フォロー解除」ボタン表示]
    L --> M([クリック]) --> N[DELETE /users/:id/follow]
    N --> O[follows レコード削除]
    O --> G
```

---

## 5. ランキング表示フロー

```mermaid
flowchart TD
    A([ランキングページを開く]) --> B[GET /rankings]
    B --> C{period パラメータ}
    C -- today --> D[当日 00:00〜23:59 の投稿]
    C -- weekly --> E[過去 7 日間の投稿]
    C -- monthly --> F[過去 30 日間の投稿]
    C -- yearly --> G[過去 1 年間の投稿]
    C -- alltime / その他 --> H[全期間の投稿]

    D --> I{kind パラメータ}
    E --> I
    F --> I
    G --> I
    H --> I

    I -- funny / laugh / cry\n/ wow / cool / cute\n/ surprised --> J["対象スコープを {kind}_count DESC で\nソート・上位 20 件取得"]
    I -- 不正な値 --> K[funny にフォールバック] --> J
    J --> L([ランキング一覧を表示])
```

---

## 6. ユーザー登録フロー

```mermaid
flowchart TD
    A([登録ページを開く]) --> B[メール・パスワード・\nユーザー名を入力]
    B --> C[POST /users（Devise）]
    C --> D{バリデーション}

    D -- メール重複 --> E[エラー: すでに使われています] --> B
    D -- ユーザー名重複 --> F[エラー: すでに使われています] --> B
    D -- ユーザー名形式エラー\n半角英数字・_ のみ --> G[エラー表示] --> B
    D -- パスワード短すぎ --> H[エラー: 6文字以上] --> B
    D -- OK --> I[users レコード作成]
    I --> J[自動ログイン]
    J --> K([ホームへリダイレクト])
```
