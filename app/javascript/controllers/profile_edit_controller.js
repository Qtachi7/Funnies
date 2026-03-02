import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  previewAvatar(event) {
    const file = event.target.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (e) => {
      // 既存のプレースホルダーまたは画像を置き換え
      const container = document.getElementById("avatar-preview")
      container.innerHTML = `<img src="${e.target.result}" class="w-20 h-20 rounded-full object-cover border-2 border-neutral-200">`
    }
    reader.readAsDataURL(file)
  }

  countBio(event) {
    const count = event.target.value.length
    document.getElementById("bio-count").textContent = count
  }
}
