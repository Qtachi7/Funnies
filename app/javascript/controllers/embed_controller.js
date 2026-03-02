import { Controller } from "@hotwired/stimulus"

// 外部埋め込みウィジェット（TikTok/Instagram）をTurbo対応で動かすコントローラー
export default class extends Controller {
  static values = { platform: String }

  connect() {
    switch (this.platformValue) {
      case "tiktok":
        this.#loadTikTok()
        break
      case "instagram":
        this.#loadInstagram()
        break
    }
  }

  #loadTikTok() {
    this.#loadScript("https://www.tiktok.com/embed.js")
  }

  #loadInstagram() {
    this.#loadScript("https://www.instagram.com/embed.js", () => {
      window.instgrm?.Embeds.process()
    })
  }

  // スクリプトをDOMに1つだけ追加し、ロード完了後にcallbackを実行する。
  // 同じスクリプトを複数のコントローラーが要求した場合も正しく動作する。
  #loadScript(src, callback) {
    let script = document.querySelector(`script[src="${src}"]`)

    if (!script) {
      script = document.createElement("script")
      script.src = src
      script.async = true
      document.head.appendChild(script)
    }

    if (!callback) return

    if (script.dataset.embedReady) {
      // 既にロード完了済み → 即実行
      callback()
    } else {
      // ロード完了を待つ（追加直後でも、既存スクリプトがまだロード中でも対応）
      script.addEventListener("load", () => {
        script.dataset.embedReady = "true"
        callback()
      }, { once: true })
    }
  }
}
