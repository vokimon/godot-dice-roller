{
  "title": "{{ env.PROJECT_NAME }}",
  "description": "{{ env.PROJECT_DESCRIPTION }}",
  "category_id": "1",
  "godot_version": "{{ env.GODOT_VERSION }}",
  "version_string": "{{ env.PROJECT_VERSION }}",
  "cost": "AGPLv3",
  "download_provider": "GitHub",
  "download_commit": "{{ env.GITHUB_SHA }}",
  "browse_url": "{{ context.repository.html_url }}",
  "issues_url": "{{ context.repository.html_url }}/issues",
  "icon_url": "{{ env.PROJECT_ICON }}",
  "previews": [
    {
      "preview_id": "1",
      "type": "video",
      "link": "https://www.youtube.com/watch?v=p_qe9ZKVna4",
      "thumbnail": "https://img.youtube.com/vi/p_qe9ZKVna4/maxresdefault.jpg"
    },
    {
      "preview_id": "2",
      "type": "image",
      "link": "https://raw.githubusercontent.com/vokimon/godot-dice-roller/refs/heads/main/screenshots/example-landscape.png",
      "thumbnail": "https://raw.githubusercontent.com/vokimon/godot-dice-roller/refs/heads/main/screenshots/example-landscape-thumb.jpg"
    },
    {
      "preview_id": "3",
      "type": "image",
      "link": "https://raw.githubusercontent.com/vokimon/godot-dice-roller/refs/heads/main/screenshots/example-portrait.png",
      "thumbnail": "https://raw.githubusercontent.com/vokimon/godot-dice-roller/refs/heads/main/screenshots/example-portrait-thumb.jpg"
    }
  ]
}
