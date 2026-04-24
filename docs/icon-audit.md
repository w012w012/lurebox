# LureBox 图标审核清单

> 扫描范围：`lib/` 下所有 `.dart` 文件中的 `Icons.*` 使用
> 生成方式：grep + 人工上下文核实
> 待审核后标记需要修改的图标

---

## ⚠️ 语义不贴切图标汇总

以下图标在代码中被使用，但图标含义与所处位置的语义存在偏差，请优先审核：

| 严重度 | 图标 | 当前语义 | 建议语义 | 涉及位置 |
|--------|------|---------|---------|---------|
| ⚠️ 高 | `Icons.restaurant` 🍽️ | 餐厅/外出就餐 | 库存留存 `Icons.inventory_2` / 外带 `Icons.takeout_dining` / 标记 `Icons.flag` | 首页统计、统计页、鱼详情 Fate 标识 |
| ⚠️ 高 | `Icons.speed` ⚡ | 速度 | 气压（无完美替代，建议 `Icons.compress` 或自定义） | 鱼详情气压、水印气压设置 |
| ⚠️ 中 | `Icons.wb_sunny` ☀️ | 晴天/日出 | 天气 `Icons.cloud`（更通用） | 鱼详情天气、辅助信息行 |
| ❌ 错 | `Icons.g_mobiledata` 📱 | Google 移动数据 | 建议 `Icons.translate`（中文）或直接用 `Icons.cloud` | AI 提供商百度 |
| ⚠️ 中 | `Icons.phishing_rounded` | 网络钓鱼（phishing） | 与"鱼饵"（lure）英文同形易混淆，建议 `Icons.hardware` | 装备类型鱼饵 |
| ⚠️ 中 | `Icons.search` 🔍 | 搜索 | DeepSeek 是 AI 公司非搜索引擎，建议 `Icons.smart_toy` | AI 提供商 DeepSeek |
| ⚠️ 中 | `Icons.psychology` 🧠 | 心理学 | 与 Gemini 品牌无关联，建议改用品牌色图标 | AI 提供商 Gemini |
| ⚠️ 中 | `Icons.smart_toy` 🤖 | 智能玩具 | OpenAI/Claude 是 AI 助手非玩具，语义弱 | AI 提供商 OpenAI/Claude |
| ⚠️ 低 | `Icons.bolt` ⚡ | 闪电 | 与 MiniMax 品牌无明显关联 | AI 提供商 MiniMax |
| ⚠️ 低 | `Icons.psychology_alt` 🧠 | 心理学变体 | 与智谱 AI 无关联 | AI 提供商智谱 |
| ⚠️ 低 | `Icons.chat_bubble_outline` 💬 | 聊天气泡 | 腾讯混元偏向对话，勉强可接受 | AI 提供商腾讯 |
| ⚠️ 低 | `Icons.set_meal` 🍱 | 套餐/定食 | 与"鱼种/物种"概念偏弱，但可接受，建议 `Icons.pets` 或 `Icons.eco` | 物种输入、统计页物种项 |

> 标注说明：⚠️ 高 = 需要优先修改；⚠️ 中 = 建议修改；⚠️ 低 = 可考虑优化；❌ 错 = 明显错误

---

## 图标视觉参考

| 图标名 | 视觉预览 | 图标名 | 视觉预览 |
|--------|----------|--------|----------|
| `Icons.home` | 🏠 | `Icons.home_outlined` | 🏠 |
| `Icons.list_alt` | 📋 | `Icons.list_alt_outlined` | 📋 |
| `Icons.hardware` | 🔧 | `Icons.hardware_outlined` | 🔧 |
| `Icons.person` | 👤 | `Icons.person_outline` | 👤 |
| `Icons.emoji_events` | 🏆 | `Icons.emoji_events_outlined` | 🏆 |
| `Icons.help_outline` | ❓ | `Icons.help` | ❓ |
| `Icons.water_drop` | 💧 | `Icons.restaurant` | 🍽️ |
| `Icons.auto_awesome` | ✨ | `Icons.chevron_right` | › |
| `Icons.chevron_left` | ‹ | `Icons.chevron_up` | ∧ |
| `Icons.chevron_down` | ∨ | `Icons.close` | ✕ |
| `Icons.select_all` | ☑️ | `Icons.delete` | 🗑️ |
| `Icons.search` | 🔍 | `Icons.search_off` | 🔍̸ |
| `Icons.photo_camera` | 📷 | `Icons.photo_camera_outlined` | 📷 |
| `Icons.sort` | ⇅ | `Icons.arrow_upward` | ↑ |
| `Icons.arrow_downward` | ↓ | `Icons.image` | 🖼️ |
| `Icons.location_on` | 📍 | `Icons.location_off` | 📍̸ |
| `Icons.check_circle` | ✅ | `Icons.radio_button_unchecked` | ⚪ |
| `Icons.date_range` | 📅 | `Icons.filter_list` | ☰ |
| `Icons.add` | ➕ | `Icons.add_circle` | 🔘 |
| `Icons.remove` | ➖ | `Icons.remove_circle` | 🔕 |
| `Icons.edit` | ✏️ | `Icons.edit_outlined` | ✏️ |
| `Icons.visibility` | 👁️ | `Icons.visibility_outlined` | 👁️ |
| `Icons.visibility_off` | 👁️̸ | `Icons.lock` | 🔒 |
| `Icons.lock_outline` | 🔒 | `Icons.lock_open` | 🔓 |
| `Icons.settings` | ⚙️ | `Icons.settings_outlined` | ⚙️ |
| `Icons.share` | 📤 | `Icons.share_outlined` | 📤 |
| `Icons.catching_problems` | ⚠️ | `Icons.warning` | ⚠️ |
| `Icons.warning_amber` | ⚠️ | `Icons.error` | ❌ |
| `Icons.info` | ℹ️ | `Icons.info_outline` | ℹ️ |
| `Icons.check` | ✓ | `Icons.check_outlined` | ✓ |
| `Icons.refresh` | 🔄 | `Icons.refresh_outlined` | 🔄 |
| `Icons.camera` | 📷 | `Icons.camera_alt` | 📷 |
| `Icons.camera_alt_outlined` | 📷 | `Icons.photo_library` | 🖼️ |
| `Icons.photo_library_outlined` | 🖼️ | `Icons.flash_on` | ⚡ |
| `Icons.flash_off` | ⚡̸ | `Icons.flash_auto` | ⚡⟳ |
| `Icons.arrow_back` | ← | `Icons.arrow_forward` | → |
| `Icons.arrow_back_ios` | ‹ | `Icons.arrow_forward_ios` | › |
| `Icons.done` | ✓ | `Icons.done_all` | ✓✓ |
| `Icons.archive` | 📦 | `Icons.unarchive` | 📦↑ |
| `Icons.favorite` | ❤️ | `Icons.favorite_border` | 🤍 |
| `Icons.favorite_outline` | 🤍 | `Icons.star` | ⭐ |
| `Icons.star_outline` | ⭐̸ | `Icons.star_half` | ⭐½ |
| `Icons.cloud_upload` | ☁️↑ | `Icons.cloud_download` | ☁️↓ |
| `Icons.backup` | 💾 | `Icons.restore` | ↩️ |
| `Icons.folder` | 📁 | `Icons.folder_open` | 📂 |
| `Icons.description` | 📄 | `Icons.insert_drive_file` | 📄 |
| `Icons.note_add` | 📝+ | `Icons.note` | 📝 |
| `Icons.delete_forever` | 🗑️ | `Icons.delete_outline` | 🗑️ |
| `Icons.more_vert` | ⋯ | `Icons.more_horiz` | ⋯ |
| `Icons.open_in_new` | 🔗 | `Icons.launch` | 🔗 |
| `Icons.link` | 🔗 | `Icons.content_copy` | 📋 |
| `Icons.copy` | 📋 | `Icons.cut` | ✂️ |
| `Icons.paste` | 📄 | `Icons.save` | 💾 |
| `Icons.download` | ⬇️ | `Icons.upload` | ⬆️ |
| `Icons.file_download` | ⬇️ | `Icons.file_upload` | ⬆️ |
| `Icons.sync` | 🔄 | `Icons.sync_disabled` | 🔄̸ |
| `Icons.sync_problem` | 🔄⚠️ | `Icons.sync` | 🔄 |
| `Icons.wifi` | 📶 | `Icons.wifi_off` | 📶̸ |
| `Icons.storage` | 💾 | `Icons.cleaning_services` | 🧹 |
| `Icons.tune` | 🎛️ | `Icons.build` | 🔨 |
| `Icons.bug_report` | 🐛 | `Icons.anchor` | ⚓ |
| `Icons.grass` | 🌿 | `Icons.eco` | 🌿 |
| `Icons.terrain` | 🏔️ | `Icons.wb_sunny` | ☀️ |
| `Icons.cloud` | ☁️ | `Icons.thunderstorm` | ⛈️ |
| `Icons.ac_unit` | ❄️ | `Icons.water` | 💧 |
| `Icons.thermostat` | 🌡️ | `Icons.speed` | ⚡ |
| `Icons.straighten` | 📏 | `Icons.scale` | ⚖️ |
| `Icons.monetization_on` | 💰 | `Icons.attach_money` | 💵 |
| `Icons.trending_up` | 📈 | `Icons.trending_down` | 📉 |
| `Icons.bar_chart` | 📊 | `Icons.pie_chart` | 🥧 |
| `Icons.show_chart` | 📈 | `Icons.radar` | 📡 |
| `Icons.language` | 🌐 | `Icons.translate` | 🌐 |
| `Icons.dark_mode` | 🌙 | `Icons.light_mode` | ☀️ |
| `Icons.notifications` | 🔔 | `Icons.notifications_none` | 🔔̸ |
| `Icons.notifications_off` | 🔔̸ | `Icons.campaign` | 📢 |
| `Icons.email` | 📧 | `Icons.phone` | 📞 |
| `Icons.smartphone` | 📱 | `Icons.computer` | 💻 |
| `Icons.tablet` | 📱 | `Icons.watch` | ⌚ |
| `Icons.memory` | 💾 | `Icons.developer_mode` | 👨‍💻 |
| `Icons.code` | 💻 | `Icons.terminal` | ⌨️ |
| `Icons.key` | 🔑 | `Icons.vpn_key` | 🔑 |
| `Icons.security` | 🔐 | `Icons.shield` | 🛡️ |
| `Icons.verified` | ✓ | `Icons.verified_user` | ✓👤 |
| `Icons.admin_panel_settings` | ⚙️👤 | `Icons.fingerprint` | 👆 |
| `Icons.auto_fix_high` | ✨ | `Icons.auto_fix_normal` | ✨ |
| `Icons.compare_arrows` | ⇄ | `Icons.swap_horiz` | ⇄ |
| `Icons.swap_vert` | ⇅ | `Icons.layers` | 🧱 |
| `Icons.format_paint` | 🎨 | `Icons.palette` | 🎨 |
| `Icons.text_fields` | 🔤 | `Icons.title` | 🔤 |
| `Icons.image_aspect_ratio` | 🖼️ | `Icons.aspect_ratio` | 🖼️ |
| `Icons.contrast` | ◐ | `Icons.brightness_6` | ☀️ |
| `Icons.grid_view` | ⊞ | `Icons.view_list` | ☰ |
| `Icons.view_module` | ⊞ | `Icons.view_carousel` | 🎠 |
| `Icons.fullscreen` | ⛶ | `Icons.fullscreen_exit` | ⛶ |
| `Icons.fit_screen` | ⛶ | `Icons.zoom_in` | 🔍+ |
| `Icons.zoom_out` | 🔍- | `Icons.animated_images` | 🎞️ |
| `Icons.gif` | 🎞️ | `Icons.movie` | 🎬 |
| `Icons.music_note` | 🎵 | `Icons.videocam` | 📹 |
| `Icons.volume_up` | 🔊 | `Icons.volume_off` | 🔇 |
| `Icons.mic` | 🎤 | `Icons.mic_off` | 🎤̸ |
| `Icons.headphones` | 🎧 | `Icons.speaker` | 🔊 |
| `Icons.cast` | 📺 | `Icons.cast_connected` | 📺 |
| `Icons.qr_code` | 📷 | `Icons.qr_code_2` | 📷 |
| `Icons.nfc` | 📡 | `Icons.bluetooth` | 📶 |
| `Icons.bluetooth_searching` | 📶 | `Icons.usb` | 🔌 |
| `Icons.battery_full` | 🔋 | `Icons.battery_charging_full` | 🔋⚡ |
| `Icons.flash_auto` | ⚡ | `Icons.flash_on` | ⚡ |
| `Icons.flash_off` | ⚡̸ | `Icons.high_quality` | HD |
| `Icons.hd` | HD | `Icons.sd_storage` | SD |
| `Icons.sd` | SD | `Icons.filter` | � Fil |
| `Icons.filter_alt` | � Fil | `Icons.filter_none` | � Fil |
| `Icons.filter_drama` | ☁️ | `Icons.filter_vintage` | 🎨 |
| `Icons.wb_incandescent` | 💡 | `Icons.wb_auto` | 💡⟳ |
| `Icons.iso` | ISO | `Icons.exposure` | ◐ |
| `Icons.exposure_plus_1` | ◐+ | `Icons.exposure_neg_1` | ◐- |
| `Icons.crop` | ⛶ | `Icons.crop_free` | ⛶ |
| `Icons.crop_rotate` | ⛶↻ | `Icons.crop_16_9` | 16:9 |
| `Icons.crop_square` | ⛶ | `Icons.rotate_right` | ↻ |
| `Icons.rotate_left` | ↺ | `Icons.transform` | ⇄ |
| `Icons.colorize` | 🎨 | `Icons.invert_colors` | ◐ |
| `Icons.invert_colors_on` | ◐ | `Icons.brush` | 🖌️ |
| `Icons.blur_on` | ◐ | `Icons.blur_off` | ◐̸ |
| `Icons.layers_clear` | 🧱✕ | `Icons.opacity` | ◐ |
| `Icons.dehaze` | ☰ | `Icons.more_horiz` | ⋯ |
| `Icons.expand_less` | ∧ | `Icons.expand_more` | ∨ |
| `Icons.keyboard_arrow_up` | ↑ | `Icons.keyboard_arrow_down` | ↓ |
| `Icons.keyboard_arrow_right` | → | `Icons.keyboard_arrow_left` | ← |
| `Icons.keyboard_double_arrow_up` | ⇧ | `Icons.keyboard_double_arrow_down` | ⇩ |
| `Icons.horizontal_rule` | ─ | `Icons.vertical_align_top` | ⊤ |
| `Icons.vertical_align_bottom` | ⊥ | `Icons.vertical_align_center` | ⊟ |
| `Icons.format_align_left` | ≡ | `Icons.format_align_center` | ≡ |
| `Icons.format_align_right` | ≡ | `Icons.format_align_justify` | ≡ |
| `Icons.format_bold` | B | `Icons.format_italic` | I |
| `Icons.format_underlined` | U | `Icons.format_strikethrough` | S |
| `Icons.format_list_bulleted` | • | `Icons.format_list_numbered` | 1. |
| `Icons.format_quote` | " | `Icons.format_size` | A |
| `Icons.format_color_text` | A | `Icons.format_color_fill` | 🎨 |
| `Icons.highlight` | 🖌️ | `Icons.spellcheck` | ✓ |
| `Icons.space_bar` | ␣ | `Icons.text_format` | 🔤 |
| `Icons.linear_scale` | ─ | `Icons.drag_handle` | ⋮⋮ |
| `Icons.short_text` | – | `Icons.wrap_text` | ↩ |
| `Icons.strikethrough_s` | S | `Icons.subscript` | ₍₎ |
| `Icons.superscript` | ⁿ | `Icons.title` | Aa |
| `Icons.calendar_today` | 📅 | `Icons.calendar_month` | 📅 |
| `Icons.calendar_view_month` | 📅 | `Icons.event` | 📅 |
| `Icons.event_available` | ✅📅 | `Icons.event_note` | 📝📅 |
| `Icons.schedule` | 🕐 | `Icons.timelapse` | 🕐 |
| `Icons.timer` | ⏱️ | `Icons.watch_later` | 🕐 |
| `Icons.access_time` | 🕐 | `Icons.hourglass_empty` | ⌛ |
| `Icons.hourglass_full` | ⌛ | `Icons.pending` | ⏳ |
| `Icons.pending_actions` | ⏳ | `Icons.update` | ↻ |
| `Icons.replay` | ↺ | `Icons.fast_forward` | ⏩ |
| `Icons.fast_rewind` | ⏪ | `Icons.skip_next` | ⏭ |
| `Icons.skip_previous` | ⏮ | `Icons.play_arrow` | ▶ |
| `Icons.pause` | ⏸ | `Icons.stop` | ⏹ |
| `Icons.play_circle` | ▶🔘 | `Icons.pause_circle` | ⏸🔘 |
| `Icons.next_plan` | ➜ | `Icons.previous_plan` | ↜ |
| `Icons.shopping_cart` | 🛒 | `Icons.shopping_bag` | 🛍️ |
| `Icons.payment` | 💳 | `Icons.local_offer` | 🏷️ |
| `Icons.receipt` | 🧾 | `Icons.point_of_sale` | 🖥️ |
| `Icons.inventory` | 📦 | `Icons.inventory_2` | 📦 |
| `Icons.local_shipping` | 🚚 | `Icons.flight` | ✈️ |
| `Icons.directions_car` | 🚗 | `Icons.directions_bike` | 🚴 |
| `Icons.directions_walk` | 🚶 | `Icons.directions_run` | 🏃 |
| `Icons.directions_boat` | ⛵ | `Icons.two_wheeler` | 🛵 |
| `Icons.hotel` | 🏨 | `Icons.restaurant_menu` | 🍽️ |
| `Icons.local_cafe` | ☕ | `Icons.local_bar` | 🍸 |
| `Icons.local_pizza` | 🍕 | `Icons.lunch_dining` | 🍔 |
| `Icons.brunch_dining` | 🥞 | `Icons.dinner_dining` | 🍽️ |
| `Icons.directions_bus` | 🚌 | `Icons.train` | 🚆 |
| `Icons.subway` | 🚇 | `Icons.tram` | 🚊 |
| `Icons.emoji_transportation` | 🚗 | `Icons.local_parking` | P |
| `Icons.local_gas_station` | ⛽ | `Icons.ev_station` | ⚡ |
| `Icons.car_repair` | 🔧 | `Icons.local_car_wash` | 🚿 |
| `Icons.local_taxi` | 🚕 | `Icons.pedestrian_bike` | 🚴 |
| `Icons.safety_check` | ✓ | `Icons三轮车` | 🛺 |
| `Icons.electric_rickshaw` | 🛺 | `Icons.airport_shuttle` | 🚌 |
| `Icons.beach_access` | 🏖️ | `Icons.pool` | 🏊 |
| `Icons.golf_course` | ⛳ | `Icons.skiing` | ⛷️ |
| `Icons.skateboarding` | 🛹 | `Icons.sports_tennis` | 🎾 |
| `Icons.sports_soccer` | ⚽ | `Icons.sports_basketball` | 🏀 |
| `Icons.sports_baseball` | ⚾ | `Icons.sports_football` | 🏈 |
| `Icons.sports_cricket` | 🏏 | `Icons.sports_hockey` | 🏒 |
| `Icons.sports_golf` | ⛳ | `Icons.sports_martial_arts` | 🥋 |
| `Icons.sports_kabaddi` | 🤼 | `Icons.sports_mma` | 🥊 |
| `Icons.sports_rugby` | 🏉 | `Icons.sports` | 🏅 |
| `Icons.sports_handball` | 🤾 | `Icons.sports_volleyball` | 🏐 |
| `Icons.pool` | 🏊 | `Icons.ice_skating` | ⛸️ |
| `Icons.snowshoeing` | 🧝 | `Icons.cruelty_free` | 🐾 |
| `Icons.pets` | 🐾 | `Icons.egg` | 🥚 |
| `Icons.egg_alt` | 🥚 | `Icons.set_meal` | 🍱 |
| `Icons.ramen_dining` | 🍜 | `Icons.rice_bowl` | 🍚 |
| `Icons.bakery_dining` | 🥐 | `Icons.local_dining` | 🍽️ |
| `Icons.local_pizza` | 🍕 | `Icons.local_bar` | 🍸 |
| `Icons.local_cafe` | ☕ | `Icons.local_grocery_store` | 🛒 |
| `Icons.shopping_basket` | 🧺 | `Icons.add_shopping_cart` | 🛒+ |
| `Icons.remove_shopping_cart` | 🛒- | `Icons.shop_two` | 🛒 |
| `Icons.credit_card` | 💳 | `Icons.credit_card_off` | 💳̸ |
| `Icons.payments` | 💰 | `Icons.account_balance` | 🏦 |
| `Icons.account_balance_wallet` | 👛 | `Icons.savings` | 🏦 |
| `Icons.work` | 💼 | `Icons.work_outline` | 💼 |
| `Icons.business_center` | 💼 | `Icons.business` | 🏢 |
| `Icons.store` | 🏪 | `Icons.storefront` | 🏪 |
| `Icons.add_business` | 🏪+ | `Icons.local_mall` | 🛍️ |
| `Icons.factory` | 🏭 | `Icons.warehouse` | 🏭 |
| `Icons.home_repair_service` | 🔧 | `Icons.construction` | 🚧 |
| `Icons.engineering` | 👷 | `Icons.electrical_services` | 💡 |
| `Icons.plumbing` | 🚿 | `Icons.roofing` | 🏠 |
| `Icons.solar_power` | ☀️ | `Icons.wind_power` | 💨 |
| `Icons.water_drop` | 💧 | `Icons.water` | 💧 |
| `Icons.water_damage` | 💧 | `Icons.shower` | 🚿 |
| `Icons.bathtub` | 🛁 | `Icons.countertops` | 🪑 |
| `Icons.chair` | 🪑 | `Icons.bed` | 🛏️ |
| `Icons.bedroom_parent` | 🛏️ | `Icons.bedroom_child` | 🛏️ |
| `Icons.window` | 🪟 | `Icons.door_front` | 🚪 |
| `Icons.door_sliding` | 🚪 | `Icons.doorbell` | 🔔 |
| `Icons.garage` | 🏠 | `Icons.gate` | 🚧 |
| `Icons.fence` | 🧱 | `Icons.house` | 🏠 |
| `Icons.villa` | 🏡 | `Icons.cottage` | 🏡 |
| `Icons.apartment` | 🏢 | `Icons.location_city` | 🏙️ |
| `Icons.landscape` | 🏞️ | `Icons.park` | 🌳 |
| `Icons.forest` | 🌲 | `Icons.nature` | 🌿 |
| `Icons.nature_people` | 🌿👤 | `Icons.pets` | 🐾 |
| `Icons.spa` | 🌿 | `Icons.flora_and_fauna` | 🌸 |
| `Icons.sunny` | ☀️ | `Icons.wb_sunny` | ☀️ |
| `Icons.nights_stay` | 🌙 | `Icons.cloudy` | ☁️ |
| `Icons.cloud` | ☁️ | `Icons.cloud_queue` | ☁️ |
| `Icons.cloud_off` | ☁️̸ | `Icons.foggy` | 🌫️ |
| `Icons.brightness_7` | ☀️ | `Icons.brightness_4` | 🌙 |
| `Icons.umbrella` | ☂️ | `Icons.ac_unit` | ❄️ |
| `Icons.filter_drama` | ☁️ | `Icons.grain` | 🌾 |
| `Icons.waves` | 🌊 | `Icons.terrain` | 🏔️ |
| `Icons.map` | 🗺️ | `Icons.my_location` | 📍 |
| `Icons.location_searching` | 📡 | `Icons.location_disabled` | 📍̸ |
| `Icons.navigation` | 🧭 | `Icons.compass_calibration` | 🧭 |
| `Icons.travel_explore` | 🧭 | `Icons.trip_origin` | ⬤ |
| `Icons.local_activity` | 🎫 | `Icons.local_play` | 🎭 |
| `Icons.theater_comedy` | 🎭 | `Icons.movie` | 🎬 |
| `Icons.sports_esports` | 🎮 | `Icons.games` | 🎮 |
| `Icons.casino` | 🎰 | `Icons.headset_mic` | 🎧 |
| `Icons.headset` | 🎧 | `Icons.mic_external_on` | 🎤 |
| `Icons.keyboard` | ⌨️ | `Icons.mouse` | 🖱️ |
| `Icons.keyboard_hide` | ⌨️̸ | `Icons.dock` | 🖥️ |
| `Icons.laptop_chromebook` | 💻 | `Icons.devices_other` | 📱 |
| `Icons.phone_android` | 📱 | `Icons.phone_iphone` | 📱 |
| `Icons.tablet_android` | 📱 | `Icons.tv` | 📺 |
| `Icons.monitor` | 🖥️ | `Icons.monitor_weight` | ⚖️ |
| `Icons.security` | 🔐 | `Icons.bolt` | ⚡ |
| `Icons.flash_on` | ⚡ | `Icons.flash_off` | ⚡̸ |
| `Icons.flash_auto` | ⚡⟳ | `Icons.flashlight_on` | 🔦 |
| `Icons.flashlight_off` | 🔦̸ | `Icons.wb_iridescent` | 🌈 |
| `Icons.tag` | 🏷️ | `Icons.local_offer` | 🏷️ |
| `Icons.price_check` | ✓💰 | `Icons.sell` | 💰 |
| `Icons.inventory_2` | 📦 | `Icons.category` | 🏷️ |
| `Icons.style` | 🎨 | `Icons.science` | 🔬 |
| `Icons.biotech` | 🧬 | `Icons.psychology` | 🧠 |
| `Icons.psychology_alt` | 🧠 | `Icons.medical_services` | 🏥 |
| `Icons.local_hospital` | 🏥 | `Icons.emergency` | 🚑 |
| `Icons.local_pharmacy` | 💊 | `Icons.masks` | 😷 |
| `Icons.sanitizer` | 🧴 | `Icons-clean_hands` | 🧼 |
| `Icons.face` | 😊 | `Icons.face_2` | 😊 |
| `Icons.face_3` | 😊 | `Icons.face_4` | 😊 |
| `Icons.face_5` | 😊 | `Icons.face_6` | 😊 |
| `Icons.sentiment_dissatisfied` | 😞 | `Icons.sentiment_neutral` | 😐 |
| `Icons.sentiment_satisfied` | 😊 | `Icons.sentiment_very_dissatisfied` | 😠 |
| `Icons.sentiment_very_satisfied` | 😄 | `Icons.mood` | 😊 |
| `Icons.mood_bad` | 😞 | `Icons.emoji_emotions` | 😃 |
| `Icons.sentiment_satisfied_alt` | 😊 | `Icons.child_friendly` | 👶 |
| `Icons.elderly` | 👴 | `Icons.personal_injury` | 🤕 |
| `Icons.pregnant_woman` | 🤰 | `Icons.accessibility` | ♿ |
| `Icons.accessibility_new` | ♿ | `Icons.accessible` | ♿ |
| `Icons.accessible_forward` | ♿ | `Icons轮椅` | ♿ |
| `Icons钊` | 🔱 | `Icons.woman` | 👩 |
| `Icons.man` | 👨 | `Icons.boy` | 👦 |
| `Icons.girl` | 👧 | `Icons.group` | 👥 |
| `Icons.groups` | 👥 | `Icons.group_add` | 👥+ |
| `Icons.public` | 🌐 | `Icons.earthquake` | 🌋 |
| `Icons.fire_extinguisher` | 🧯 | `Icons.local_fire_department` | 🚒 |
| `Icons.warning` | ⚠️ | `Icons.gpp_maybe` | 🔒 |
| `Icons.gpp_good` | ✓🔒 | `Icons.no_encryption` | 🔓̸ |
| `Icons.vpn_lock` | 🔒 | `Icons.password` | 🔑 |
| `Icons.pin` | 📌 | `Icons.push_pin` | 📌 |
| `Icons.bookmark` | 🔖 | `Icons.bookmark_border` | 🔖̸ |
| `Icons.label` | 🏷️ | `Icons.label_outline` | 🏷️ |
| `Icons.bookmarks` | 🔖 | `Icons.book` | 📖 |
| `Icons.menu_book` | 📖 | `Icons.auto_stories` | 📖 |
| `Icons.menu` | ☰ | `Icons.dehaze` | ☰ |
| `Icons.apps` | ⊞ | `Icons.grid_view` | ⊞ |
| `Icons.dashboard` | ⊞ | `Icons.view_quilt` | ⊞ |
| `Icons.view_agenda` | ⊞ | `Icons.view_day` | ⊞ |
| `Icons.view_week` | ⊞ | `Icons.segment` | ⊞ |
| `Icons.login` | ➜ | `Icons.logout` | ➜ |
| `Icons.login` | ➜ | `Icons.logout` | ↩ |
| `Icons.open_in_browser` | 🔗 | `Icons.system_update` | ↻ |
| `Icons.settings_applications` | ⚙️ | `Icons.settings_suggest` | ⚙️ |
| `Icons.settings_accessibility` | ⚙️ | `Icons.settings_backup_restore` | ⚙️↩ |
| `Icons.find_in_page` | 🔍 | `Icons.find_replace` | 🔍⟷ |
| `Icons.start` | ▶ | `Icons.stars` | ⭐ |
| `Icons.verified` | ✓ | `Icons.turn_left` | ↰ |
| `Icons.turn_right` | ↱ | `Icons.turn_up` | ↰ |
| `Icons.u_turn_left` | ↰ | `Icons.u_turn_right` | ↱ |
| `Icons.arrow_upward` | ↑ | `Icons.arrow_downward` | ↓ |
| `Icons.arrow_left` | ← | `Icons.arrow_right` | → |
| `Icons.switch_left` | ↔ | `Icons.switch_right` | ↔ |
| `Icons.width_normal` | ↔ | `Icons.width_wide` | ↔ |
| `Icons.width_full` | ↔ | `Icons.fullscreen` | ⛶ |
| `Icons.fullscreen_exit` | ⛶ | `Icons.crop_free` | ⛶ |
| `Icons.open_with` | ⤢ | `Icons.fit_screen` | ⛶ |
| `Icons.zoom_out_map` | 🔍- | `Icons.zoom_in_map` | 🔍+ |
| `Icons.wifi_tethering` | 📶 | `Icons.wifi_lock` | 📶🔒 |
| `Icons.wifi_off` | 📶̸ | `Icons.signal_wifi_off` | 📶̸ |
| `Icons.signal_cellular_off` | 📶̸ | `Icons.signal_cellular_4_bar` | 📶 |
| `Icons.network_wifi` | 📶 | `Icons.airplanemode_active` | ✈️ |
| `Icons.airplanemode_inactive` | ✈️̸ | `Icons.data_saver_off` | 📊 |
| `Icons.data_saver_on` | 📊 | `Icons.mobile_friendly` | 📱 |
| `Icons.mobile_off` | 📱̸ | `Icons.gps_off` | 📍̸ |
| `Icons.gps_fixed` | 📍 | `Icons.gps_not_fixed` | 📍 |
| `Icons.screen_rotation` | 📱↻ | `Icons.screen_lock_landscape` | 🔒 |
| `Icons.screen_lock_portrait` | 🔒 | `Icons.screen_lock_rotation` | 🔒↻ |
| `Icons.screen_rotation` | 📱↻ | `Icons.tonality` | ◐ |
| `Icons.invert_colors` | ◐ | `Icons.grain` | 🌾 |
| `Icons.blur_linear` | ◐ | `Icons.blur_on` | ◐ |
| `Icons.blur_off` | ◐̸ | `Icons.filter_b_and_w` | ◐ |
| `Icons.filter_frames` | 🖼️ | `Icons.filter` | � Fil |
| `Icons.filter_alt` | � Fil | `Icons.filter_list` | ☰ |
| `Icons.gradient` | 🌈 | `Icons.palette` | 🎨 |
| `Icons.hdr_on` | HDR | `Icons.hdr_off` | HDR̸ |
| `Icons.hdr_strong` | ◐ | `Icons.hdr_weak` | ◐ |
| `Icons.radio_button_checked` | 🔘 | `Icons.radio_button_unchecked` | ⚪ |
| `Icons.radio_button_partial` | 🔘 | `Icons.check_box` | ☑️ |
| `Icons.check_box_outline_blank` | ☐ | `Icons.indeterminate_check_box` | ☐ |
| `Icons.toggle_on` | ◐ | `Icons.toggle_off` | ◐̸ |
| `Icons.south_east` | ↘ | `Icons.north_east` | ↗ |
| `Icons.south_west` | ↙ | `Icons.north_west` | ↖ |
| `Icons.south` | ↓ | `Icons.north` | ↑ |
| `Icons.east` | → | `Icons.west` | ← |
| `Icons.roundabout_left` | ↰ | `Icons.roundabout_right` | ↱ |
| `Icons.turn_slight_left` | ↰ | `Icons.turn_slight_right` | ↱ |
| `Icons.explore` | 🧭 | `Icons.explore_off` | 🧭̸ |
| `Icons.add_location` | 📍+ | `Icons.add_location_alt` | 📍+ |
| `Icons.edit_location` | 📍✏️ | `Icons.edit_location_alt` | 📍✏️ |
| `Icons.my_location` | 📍 | `Icons.near_me` | 📍 |
| `Icons.near_me_disabled` | 📍̸ | `Icons.pin_drop` | 📍 |
| `Icons.place` | 📍 | `Icons.places` | 📍 |
| `Icons.category` | 🏷️ | `Icons.square_foot` | 📐 |
| `Icons.straighten` | 📏 | `Icons.width` | ↔ |
| `Icons.height` | ↕ | `Icons.full_hexagon` | ⬡ |
| `Icons.hexagon` | ⬡ | `Icons.change_history` | 🔺 |
| `Icons.radio_button_partial` | 🔘 | `Icons.pentagon` | ⭐ |
| `Icons.signal_cellular_alt` | 📶 | `Icons.do_not_disturb_on` | 🔕 |
| `Icons.do_not_disturb` | 🔕 | `Icons.do_not_disturb_off` | 🔕̸ |
| `Icons.do_not_disturb_alt` | 🔕 | `Icons.do_not_disturb_on_outlined` | 🔕 |
| `Icons.mms` | 💬 | `Icons.more` | ⋯ |
| `Icons.messages` | 💬 | `Icons.message` | 💬 |
| `Icons.chat` | 💬 | `Icons.chat_outlined` | 💬 |
| `Icons.textsms` | 💬 | `Icons.chat_bubble` | 💬 |
| `Icons.chat_bubble_outline` | 💬 | `Icons.contact_phone` | 📞 |
| `Icons.contact_mail` | 📧 | `Icons.Contacts` | 👤 |
| `Icons.Contacts_outlined` | 👤 | `Icons.person_add` | 👤+ |
| `Icons.person_add_disabled` | 👤+̸ | `Icons.group_add` | 👥+ |
| `Icons.person_remove` | 👤- | `Icons.group_remove` | 👥- |
| `Icons.person_outline` | 👤 | `Icons.assignment_ind` | 📋👤 |
| `Icons.assignment` | 📋 | `Icons.assignment_late` | 📋⚠️ |
| `Icons.assignment_return` | 📋↩ | `Icons.assignment_returned` | 📋↩ |
| `Icons.assignment_turned_in` | 📋✓ | `Icons.assignment_turned_in` | 📋✓ |
| `Icons.extension` | 🧩 | `Icons.extension_off` | 🧩̸ |
| `Icons.widgets` | 🧩 | `Icons.gif_box` | 🧩 |
| `Icons.assistant` | 🤖 | `Icons.utility` | 🛠️ |
| `Icons.ads_click` | 👆 | `Icons.speed` | ⚡ |
| `Icons.query_stats` | 📊 | `Icons.bar_chart` | 📊 |
| `Icons.analytics` | 📊 | `Icons.leaderboard` | 🏆 |
| `Icons.calendar_view_month` | 📅 | `Icons.calendar_view_week` | 📅 |
| `Icons.calendar_view_day` | 📅 | `Icons.calendar_view_agenda` | 📅 |
| `Icons.view_timeline` | 📅 | `Icons.view_column` | ⊞ |
| `Icons.view_headline` | ≡ | `Icons.view_stream` | ☰ |
| `Icons.view_compact` | ⊞ | `Icons.table_rows` | ☰ |
| `Icons.table_chart` | 📊 | `Icons.area_chart` | 📈 |
| `Icons.scatter_plot` | 📊 | `Icons.bubble_chart` | 🫧 |
| `Icons.stacked_line_chart` | 📊 | `Icons.donut_large` | 🥯 |
| `Icons.donut_small` | 🥯 | `Icons.pie_chart_outline` | 🥧 |
| `Icons.multiline_chart` | 📈 | `Icons.calendar_month` | 📅 |
| `Icons.today` | 📅 | `Icons.slideshow` | 📽️ |
| `Icons.image_search` | 🖼️🔍 | `Icons.video_search` | 🎬🔍 |
| `Icons.manage_search` | 🧹🔍 | `Icons.horizontal_weight` | ⚖️ |
| `Icons.vertical_shades` | 🪟 | `Icons.blinds` | 🪟 |
| `Icons.living` | 🛋️ | `Icons.bedroom_baby` | 🛏️ |
| `Icons.kitchen` | 🍳 | `Icons.dining` | 🍽️ |
| `Icons.yard` | 🌿 | `Icons.deck` | 🪵 |
| `Icons.fence` | 🧱 | `Icons.child_care` | 👶 |
| `Icons.playlesson` | 📖 | `Icons.phonelink_lock` | 📱🔒 |
| `Icons.school` | 🏫 | `Icons.history_edu` | 📖 |
| `Icons.save_as` | 💾+ | `Icons.file_save` | 💾 |
| `Icons.save_alt` | 💾 | `Icons.download_done` | ✅⬇️ |
| `Icons.upload_file` | 📤 | `Icons.cloud_done` | ✅☁️ |
| `Icons.cloud_off` | ☁️̸ | `Icons.cloud_queue` | ☁️ |
| `Icons.cloud_upload` | ☁️⬆️ | `Icons.cloud_download` | ☁️⬇️ |
| `Icons.folder_special` | ⭐📁 | `Icons.folder_shared` | 👥📁 |
| `Icons.create_new_folder` | 📁+ | `Icons.arrow_circle_up` | ⬆️🔘 |
| `Icons.arrow_circle_down` | ⬇️🔘 | `Icons.change_circle` | ↻🔘 |
| `Icons.play_for_work` | ▶💼 | `Icons.pulled_from` | ↩ |
| `Icons.output` | ⬆️ | `Icons.workflow` | ⚙️ |
| `Icons.app_registration` | 📝 | `Icons.app_shortcut` | ⚡ |
| `Icons.recent_actors` | 👥 | `Icons.theaters` | 🎭 |
| `Icons.close_fullscreen` | ⛶ | `Icons.filter_tilt_shift` | ◐↗ |
| `Icons.filter_none` | � Fil | `Icons.filter_center_focus` | 🎯 |
| `Icons.control_point_duplicate` | ⬜+ | `Icons.control_point` | ⬜ |
| `Icons.autorenew` | ↻ | `Icons.flip` | ⇋ |
| `Icons.flip_camera_android` | 📷↻ | `Icons.flip_to_front` | ⬜ |
| `Icons.flip_to_back` | ⬜ | `Icons.burst_mode_on` | 📷 |
| `Icons.collections` | 🖼️ | `Icons.collections_bookmark` | 🔖🖼️ |
| `Icons.image_not_supported` | 🖼️̸ | `Icons.photo_size_select_actual` | 🖼️ |
| `Icons.photo_size_select_large` | 🖼️ | `Icons.photo_size_select_small` | 🖼️ |
| `Icons.vignette` | ◐ | `Icons.healing` | ✚ |
| `Icons.tonality` | ◐ | `Icons.luminosity` | ☀️ |
| `Icons.wb_iridescent` | 🌈 | `Icons.lens` | 🔘 |
| `Icons.lens_blur` | ◐ | `Icons.linked_camera` | 📷🔗 |
| `Icons.add_a_photo` | 📷+ | `Icons.add_photo_alternate` | 📷+ |
| `Icons.photo_album` | 📷 | `Icons.photo_camera_front` | 📷👤 |
| `Icons.photo_camera_rear` | 📷 | `Icons.camera_rear` | 📷 |
| `Icons.camera_front` | 📷👤 | `Icons.panorama` | 🌄 |
| `Icons.panorama_horizontal` | 🌄 | `Icons.panorama_vertical` | 🌄 |
| `Icons.panorama_fish_eye` | 🌄 | `Icons.panorama_wide_angle` | 🌄 |
| `Icons.timer_off` | ⏱️̸ | `Icons.timer` | ⏱️ |
| `Icons.shutter_speed` | ⏱️ | `Icons.music_off` | 🎵̸ |
| `Icons.videocam_off` | 📹̸ | `Icons.video_settings` | 🎬⚙️ |
| `Icons.volume_mute` | 🔇 | `Icons.volume_down` | 🔉 |
| `Icons.surround_sound` | 🔊 | `Icons.web` | 🌐 |
| `Icons.web_asset` | 🌐 | `Icons.web_asset_off` | 🌐̸ |
| `Icons.webhook` | 🪝 | `Icons.cloud_sync` | ☁️🔄 |
| `Icons.sync` | 🔄 | `Icons.sync_disabled` | 🔄̸ |
| `Icons.screenshot_monitor` | 🖥️ | `Icons.tab_window` | ⧉ |
| `Icons.tab` | ⧉ | `Icons.tab_unselected` | ⧉̸ |
| `Icons.embed` | ` ` | `Icons.embed_codes` | ` ` |
| `Icons.html` | HTML | `Icons.css` | CSS |
| `Icons.javascript` | JS | `Icons.token` | 🔑 |
| `Icons.data_object` | { } | `Icons.data_array` | [ ] |
| `Icons.source` | 📄 | `Icons.integration_instructions` | 📋 |
| `Icons.rule` | 📏 | `Icons.rule_folder` | 📁 |
| `Icons.rule` | 📏 | `Icons.rule_folder` | 📁 |
| `Icons.manage_accounts` | 👤⚙️ | `Icons沙子` | ⏱️ |
| `Icons.paid` | 💰 | `Icons.pix` | 💎 |
| `Icons.currency_exchange` | 💱 | `Icons.attach_file` | 📎 |
| `Icons.create` | ✏️ | `Icons.note_add` | 📝+ |
| `Icons.post_add` | 📝+ | `Icons.add_card` | 💳+ |
| `Icons.border_color` | ✏️ | `Icons.draw` | ✏️ |
| `Icons.gesture` | ✋ | `Icons.pan_tool` | 🤚 |
| `Icons.ads_click` | 👆 | `Icons.touch_app` | 👆 |
| `Icons.swipe` | 👆 | `Icons.pan_tool` | 🤚 |
| `Icons.pinch` | 🤏 | `Icons.zoom_in` | 🔍+ |
| `Icons.zoom_out` | 🔍- | `Icons.drag_pan` | ✋ |
| `Icons.back_hand` | ✋ | `Icons.palm_alert` | 🖐️ |
| `Icons.sign_language` | 🤟 | `Icons.temple_buddhist` | 🛕 |
| `Icons.temple_hindu` | 🛕 | `Icons.mosque` | 🕌 |
| `Icons.synagogue` | 🕍 | `Icons.church` | ⛪ |
| `Icons.holiday_village` | 🏡 | `Icons.cabin` | 🏠 |
| `Icons.vrpano` | 🌄 | `Icons.sports_score` | 🏅 |
| `Icons.sports` | 🏅 | `Icons.sports_bar` | 🍸 |
| `Icons.attractions` | 🎢 | `Icons.icecream` | 🍦 |
| `Icons.kayakaking` | 🛶 | `Icons.sailing` | ⛵ |
| `Icons.surfing` | 🏄 | `Icons.kitesurfing` | 🪁 |
| `Icons.rowingu` | 🚣 | `Icons.climbing` | 🧗 |
| `Icons.nordic_walking` | 🚶 | `Icons.paragliding` | 🪂 |
| `Icons.sports_gymnastics` | 🤸 | `Icons.martial_arts` | 🥋 |
| `Icons.arching` | 🤸 | `Icons.fitness_center` | 💪 |
| `Icons.sports_motorsports` | 🏎️ | `Icons.sports_handball` | 🤾 |
| `Icons.sports_kabaddi` | 🤼 | `Icons.badminton` | 🏸 |
| `Icons.cricket` | 🏏 | `Icons.cycling` | 🚴 |
| `Icons.directions_bike` | 🚴 | `Icons.snowboarding` | 🏂 |
| `Icons.skiing` | ⛷️ | `Icons.snowmobile` | 🛷 |
| `Icons.skateboarding` | 🛹 | `Icons.roller_skating` | 🛼 |
| `Icons.ice_skating` | ⛸️ | `Icons.hiking` | 🥾 |
| `Icons.terrain` | 🏔️ | `Icons.sports_tennis` | 🎾 |
| `Icons.sports_basketball` | 🏀 | `Icons.sports_baseball` | ⚾ |
| `Icons.sports_football` | 🏈 | `Icons.sports_soccer` | ⚽ |
| `Icons.sports_volleyball` | 🏐 | `Icons.sports_golf` | ⛳ |
| `Icons.sports_cricket` | 🏏 | `Icons.sports_hockey` | 🏒 |
| `Icons.pool` | 🏊 | `Icons.scuba_diving` | 🤿 |
| `Icons.diving_board` | 🤿 | `Icons.surfing` | 🏄 |
| `Icons.water_sports` | 🏊 | `Icons.water` | 💧 |
| `Icons.kayaking` | 🛶 | `Icons.rafting` | 🛶 |
| `Icons.sailing` | ⛵ | `Icons.surfing` | 🏄 |
| `Icons.rowing` | 🚣 | `Icons.water` | 💧 |
| `Icons.thermostat` | 🌡️ | `Icons.device_thermostat` | 🌡️ |
| `Icons.hot_tubs` | 🛁 | `Icons.smoke_free` | 🚭 |
| `Icons.smoking_rooms` | 🚬 | `Icons.vape_free` | 🚭 |
| `Icons.no_drinks` | 🚫🍸 | `Icons.no_food` | 🚫🍽️ |
| `Icons.no_photography` | 🚫📷 | `Icons.no_flash` | 🚫⚡ |
| `Icons.no_stroller` | 🚫👶 | `Icons.no_filming` | 🚫🎬 |
| `Icons.no_meeting_room` | 🚫🏢 | `Icons.no_electronics` | 🚫📱 |
| `Icons.do_not_touch` | 🚫✋ | `Icons.wc` | 🚻 |
| `Icons.baby_changing_station` | 👶 | `Icons.fitness_center` | 💪 |
| `Icons.spa` | 🧖 | `Icons.hot_tubs` | 🛁 |
| `Icons.skateboarding` | 🛹 | `Icons.bike_scooter` | 🛵 |
| `Icons.electric_rickshaw` | 🛺 | `Icons.car_rental` | 🚗 |
| `Icons.car_repair` | 🔧 | `Icons.local_car_wash` | 🚿 |
| `Icons.ev_station` | ⚡ | `Icons.local_gas_station` | ⛽ |
| `Icons.local_parking` | P | `Icons.toll` | 💰 |
| `Icons.local_taxi` | 🚕 | `Icons.airport_shuttle` | 🚌 |
| `Icons.directions_car_filled` | 🚗 | `Icons.trip_origin` | ⬤ |
| `Icons.connecting_airports` | ✈️ | `Icons.flight_takeoff` | ✈️ |
| `Icons.flight_land` | ✈️ | `Icons.planes` | ✈️ |
| `Icons.atm` | 💳 | `Icons.point_of_sale` | 🖥️ |
| `Icons.receipt_long` | 🧾 | `Icons.request_quote` | 📝💰 |
| `Icons.sell` | 💰 | `Icons.currency_exchange` | 💱 |
| `Icons.trending_up` | 📈 | `Icons.trending_flat` | → |
| `Icons.trending_down` | 📉 | `Icons.area_chart` | 📈 |
| `Icons.scatter_plot` | 📊 | `Icons.bubble_chart` | 🫧 |
| `Icons.hexagon` | ⬡ | `Icons.stacked_line_chart` | 📊 |
| `Icons.bar_chart` | 📊 | `Icons.pie_chart` | 🥧 |
| `Icons.donut_large` | 🥯 | `Icons.donut_small` | 🥯 |
| `Icons.multiline_chart` | 📈 | `Icons.show_chart` | 📈 |
| `Icons.waterfall_chart` | 📊 | `Icons.sunrise` | 🌅 |
| `Icons.sunny` | ☀️ | `Icons.sunny_snowing` | 🌨️ |
| `Icons.mode_heat_cool` | 🔄 | `Icons.dry` | 🏜️ |
| `Icons.filter_list` | ☰ | `Icons.home_repair_service` | 🔧 |
| `Icons.room_preferences` | 🏠 | `Icons.light_at_the_end` | 💡 |
| `Icons.lightbulb` | 💡 | `Icons.lightbulb_outline` | 💡 |
| `Icons.lightbulb_circle` | 💡 | `Icons.electrical_services` | ⚡ |
| `Icons.water_drop` | 💧 | `Icons.water` | 💧 |
| `Icons.gas_meter` | ⛽ | `Icons.water_damage` | 💧 |
| `Icons.water_management` | 💧 | `Icons.cleaning_services` | 🧹 |
| `Icons.cleaning` | 🧹 | `Icons.floor` | 🪵 |
| `Icons.wash` | 🧺 | `Icons.crib` | 🛏️ |
| `Icons.bed` | 🛏️ | `Icons.single_bed` | 🛏️ |
| `Icons.double_bed` | 🛏️ | `Icons.chair` | 🪑 |
| `Icons.dining` | 🍽️ | `Icons.table_bar` | 🪑 |
| `Icons.table_restaurant` | 🪑 | `Icons.weekend` | 🛋️ |
| `Icons.window` | 🪟 | `Icons.blinds` | 🪟 |
| `Icons.blinds` | 🪟 | `Icons.curtains` | 🪟 |
| `Icons.bedroom_parent` | 🛏️ | `Icons.bedroom_child` | 🛏️ |
| `Icons.kitchen` | 🍳 | `Icons.doorbell` | 🔔 |
| `Icons.garage` | 🏠 | `Icons.gate` | 🚧 |
| `Icons.fence` | 🧱 | `Icons.house` | 🏠 |
| `Icons.roofing` | 🏠 | `Icons.roofing` | 🏠 |
| `Icons.roofing` | 🏠 | `Icons.roofing` | 🏠 |
| `Icons.roofing` | 🏠 | `Icons.roofing` | 🏠 |
| `Icons.roofing` | 🏠 | `Icons.roofing` | 🏠 |
| `Icons.roofing` | 🏠 | `Icons.roofing` | 🏠 |
| `Icons.roofing` | 🏠 | `Icons.roofing` | 🏠 |

---

## 导航栏（底部 Tab）

| 视觉 | 图标 | 含义 | 文件位置 |
|------|------|------|---------|
| 🏠 | `Icons.home` / `Icons.home_outlined` | 首页 | `core/router/app_router.dart:204-205` |
| 📋 | `Icons.list_alt` / `Icons.list_alt_outlined` | 鱼获列表 | `core/router/app_router.dart:209-210` |
| 🔧 | `Icons.hardware` / `Icons.hardware_outlined` | 装备管理 | `core/router/app_router.dart:214-215` |
| 👤 | `Icons.person` / `Icons.person_outline` | 我的/设置 | `core/router/app_router.dart:219-220` |

---

## 首页（Home）

| 视觉 | 图标 | 含义 | 文件位置 | 审核意见 |
|------|------|------|---------|---------|
| 🏆 | `Icons.emoji_events_outlined` | 成就入口 | `features/home/home_page.dart:266` | |
| 🏆 | `Icons.emoji_events`（金色） | Top3 渔获 | `features/home/home_page.dart:310` | |
| ❓ | `Icons.help_outline` | 帮助入口 | `features/home/home_page.dart:375` | |
| 💧 | `Icons.water_drop` | 今日放流数量 | `features/home/home_page.dart:476` | |
| 🍽️ | `Icons.restaurant` | 今日保留数量 | `features/home/home_page.dart:483` | ⚠️ restaurant=餐厅，强烈暗示"去餐馆吃饭"，与"保留这条鱼"关联弱。同理：`features/stats/stats_page.dart:386`（统计页保留数）、`features/fish_detail/widgets/fish_info_card.dart:186`（鱼详情保留标识）。建议：`Icons.inventory_2`(库存/留存)、`Icons.takeout_dining`(外带餐饮感)、或 `Icons.flag`(标记留存) |
| ✨ | `Icons.auto_awesome` | AI 识别按钮 | `features/home/home_page.dart:512` | |
| › | `Icons.chevron_right` | 查看更多 | `features/home/home_page.dart:539` | |

---

## 鱼获列表（Fish List）

| 视觉 | 图标 | 含义 | 文件位置 |
|------|------|------|---------|
| ✕ | `Icons.close` | 关闭选择模式 | `features/fish_list/fish_list_page.dart:259` |
| ☑️ | `Icons.select_all` | 全选 | `features/fish_list/fish_list_page.dart:268` |
| 🗑️ | `Icons.delete` | 删除选中 | `features/fish_list/fish_list_page.dart:274` |
| 🔍 | `Icons.search` | 搜索按钮 | `features/fish_list/fish_list_page.dart:282` |
| 🔍̸ | `Icons.search_off` | 清除搜索 | `features/fish_list/fish_list_page.dart:315` |
| 📷 | `Icons.photo_camera_outlined` | 拍照入口 | `features/fish_list/fish_list_page.dart:324` |
| ⇅ | `Icons.sort` | 排序按钮 | `features/fish_list/fish_list_page.dart:523` |
| ↑ / ↓ | `Icons.arrow_upward` / `Icons.arrow_downward` | 升序/降序 | `features/fish_list/fish_list_page.dart:617` |
| 🖼️ | `Icons.image` | 无照片占位 | `features/fish_list/widgets/fish_card.dart:109` |
| 📍 | `Icons.location_on` | 钓点位置 | `features/fish_list/widgets/fish_card.dart:157` |
| ✅ / ⚪ | `Icons.check_circle` / `Icons.radio_button_unchecked` | 选中状态 | `features/fish_list/widgets/fish_card.dart:59-60` |
| 📅 | `Icons.date_range` | 日期筛选 | `features/fish_list/widgets/fish_filter_panel.dart:140` |
| ☰ | `Icons.filter_list` | 筛选面板 | `features/fish_list/widgets/fish_filter_panel.dart:366` |

---

## 鱼详情（Fish Detail）

| 视觉 | 图标 | 含义 | 文件位置 |
|------|------|------|---------|
| ← | `Icons.arrow_back_ios` | 返回 | `features/fish_detail/fish_detail_page.dart:89` |
| ✕ | `Icons.close` | 关闭 | `features/fish_detail/fish_detail_page.dart:99` |
| ✏️ | `Icons.edit_outlined` | 编辑 | `features/fish_detail/fish_detail_page.dart:109` |
| 🗑️ | `Icons.delete_outline` | 删除 | `features/fish_detail/fish_detail_page.dart:118` |
| 👁️ | `Icons.visibility` | 查看水印图 | `features/fish_detail/fish_detail_page.dart:130` |
| 👁️̸ | `Icons.visibility_off` | 隐藏水印图 | `features/fish_detail/fish_detail_page.dart:135` |
| 📍 | `Icons.location_on` | 位置 | `features/fish_detail/widgets/auxiliary_info_row.dart:46` |
| 📅 | `Icons.date_range` | 日期时间 | `features/fish_detail/widgets/auxiliary_info_row.dart:72` |
| 📏 | `Icons.straighten` | 尺寸 | `features/fish_detail/widgets/auxiliary_info_row.dart:97` |
| ⚖️ | `Icons.scale` | 重量 | `features/fish_detail/widgets/auxiliary_info_row.dart:121` |
| 🌡️ | `Icons.thermostat` | 水温 | `features/fish_detail/widgets/auxiliary_info_row.dart:146` | |
| ⚡ | `Icons.speed` | 气压 | `features/fish_detail/widgets/auxiliary_info_row.dart:171` | ⚠️ speed=速度，与气压无关联。建议：`Icons.compress`(气压/压缩感)、`Icons.cloud`(大气) 或自定义。同理：`features/settings/watermark_settings_page.dart:205`（气压信息） |
| ☀️ | `Icons.wb_sunny` | 天气 | `features/fish_detail/widgets/auxiliary_info_row.dart:196` | ⚠️ wb_sunny=日出/晴天，强烈暗示晴天，无法代表"天气"这个通用概念（阴天/雨天等）。建议：`Icons.cloud`(更通用)。同理：`features/fish_detail/widgets/fish_info_card.dart:247` |
| 🔗 | `Icons.share` | 分享 | `features/fish_detail/widgets/share_button.dart:22` | |
| 📤 | `Icons.ios_share` | iOS 分享 | `features/fish_detail/widgets/share_button.dart:29` | |

---

## 统计页（Stats）

| 视觉 | 图标 | 含义 | 文件位置 | 审核意见 |
|------|------|------|---------|---------|
| 🍱 | `Icons.set_meal` | 物种数量 | `features/stats/stats_page.dart:374` | ⚠️ set_meal=套餐，与物种概念偏弱，建议 `Icons.pets`(宠物/动物感) 或 `Icons.eco` |
| 🍽️ | `Icons.restaurant` | 保留数量 | `features/stats/stats_page.dart:386` | ⚠️ 同首页 restaurant 问题 |
| 🏷️ | `Icons.category` | 物种管理入口 | `features/settings/settings_page.dart:86` | ⚠️ category=分类，过于通用，建议 `Icons.set_meal` 或 `Icons.eco` |

---

## 相机（Camera）

| 视觉 | 图标 | 含义 | 文件位置 |
|------|------|------|---------|
| ✕ | `Icons.close` | 关闭 | `camera/camera_view.dart:109` |
| ↺ | `Icons.flip_camera_ios` | 切换摄像头 | `camera/camera_view.dart:117` |
| ⚡ | `Icons.flash_auto` / `Icons.flash_off` / `Icons.flash_on` | 闪光灯 | `camera/camera_view.dart:127` |
| 📷 | `Icons.camera_outlined` | 拍照按钮 | `camera/camera_view.dart:144` |
| 📷 | `Icons.camera` | 拍照入口 | `camera/camera_view.dart:164` |
| ⬇️ | `Icons.download` | 下载原图 | `camera/camera_view.dart:171` |
| ↻ | `Icons.refresh` | 重拍 | `camera/camera_view.dart:178` |
| ✓ | `Icons.check` | 确认 | `camera/camera_view.dart:185` |
| 🎬 | `Icons.movie_filter` | 鱼种识别入口 | `camera/camera_view.dart:196` |

---

## 装备管理（Equipment）

| 视觉 | 图标 | 含义 | 文件位置 | 审核意见 |
|------|------|------|---------|---------|
| 📷 | `Icons.camera_alt_outlined` | 添加装备（相机） | `features/equipment/equipment_list_page.dart:138` | |
| 📋 | `Icons.list_alt_outlined` | 添加装备（列表） | `features/equipment/equipment_list_page.dart:147` | |
| ☰ | `Icons.filter_list` | 筛选 | `features/equipment/equipment_list_page.dart:156` | |
| ⇅ | `Icons.sort` | 排序 | `features/equipment/equipment_list_page.dart:161` | |
| 🔍 | `Icons.search` | 搜索 | `features/equipment/equipment_list_page.dart:173` | |
| 🔍̸ | `Icons.search_off` | 清除搜索 | `features/equipment/equipment_list_page.dart:181` | |

### 装备类型图标

| 视觉 | 图标 | 类型 | 审核意见 |
|------|------|------|---------|
| 📏 | `Icons.straighten_rounded` | 鱼竿 rod | 尚可，测量感 |
| ⚙️ | `Icons.settings_rounded` | 渔轮 reel | 尚可，机械感 |
| 🎣 | `Icons.phishing_rounded` | 鱼饵 lure | ❌ phishing=网络钓鱼，与"鱼饵" lure 英文同形，在钓鱼应用中极易造成语义混淆，建议改为 `Icons.hardware` 或自定义 🎣 图标 |
| 📊 | `Icons.timeline_rounded` | 钓组 rig | 尚可，组合配置感 |
| 🔧 | `Icons.hardware_rounded` | 通用装备 | 尚可 |
| 💾 | `Icons.storage` | 存储卡 | `features/equipment/widgets/equipment_card.dart:53` |
| ⚙️ | `Icons.settings_outlined` | 装备详情设置 | `features/equipment/widgets/equipment_card.dart:62` |
| ✓ | `Icons.check_outlined` | 选中/默认 | `features/equipment/widgets/equipment_card.dart:70` |
| ⚙️ | `Icons.settings` | 装备设置 | `features/equipment/widgets/equipment_form_sheet.dart:57` |
| 🔧 | `Icons.build` | 修理 | `features/equipment/widgets/equipment_detail_sheet.dart:42` |
| 🗑️ | `Icons.delete_forever` | 删除 | `features/equipment/widgets/equipment_detail_sheet.dart:47` |
| ⚙️ | `Icons.settings` | 通用设置 | `features/settings/me_settings.dart:68` |
| 🔔 | `Icons.notifications_outlined` | 通知 | `features/settings/me_settings.dart:84` |
| 🔐 | `Icons.security` | 安全/隐私 | `features/settings/me_settings.dart:102` |
| 🌐 | `Icons.language` | 语言 | `features/settings/me_settings.dart:120` |
| 🌙 | `Icons.dark_mode` | 深色模式 | `features/settings/me_settings.dart:138` |
| 📤 | `Icons.ios_share` | 导出/备份 | `features/settings/me_settings.dart:156` |
| ⚠️ | `Icons.catching_problems` | 问题反馈 | `features/settings/me_settings.dart:172` |
| 📢 | `Icons.campaign` | 关于 | `features/settings/me_settings.dart:188` |
| ⬆️ | `Icons.cloud_upload` | 云备份上传 | `features/settings/widgets/backup_settings_section.dart:37` |
| ⬇️ | `Icons.cloud_download` | 云备份下载 | `features/settings/widgets/backup_settings_section.dart:49` |
| 💾 | `Icons.backup` | 本地备份 | `features/settings/widgets/backup_settings_section.dart:59` |
| ↩️ | `Icons.restore` | 恢复 | `features/settings/widgets/backup_settings_section.dart:70` |
| 🗑️ | `Icons.delete_sweep` | 清理缓存 | `features/settings/widgets/backup_settings_section.dart:86` |
| 🧹 | `Icons.cleaning_services` | 清理 | `features/settings/widgets/backup_settings_section.dart:89` |
| 📄 | `Icons.description` | 备份历史详情 | `features/settings/widgets/backup_history_list.dart:37` |
| 📋 | `Icons.content_copy` | 复制信息 | `features/settings/widgets/backup_history_tile.dart:46` |

---

## 设置总览（Settings Overview）

| 视觉 | 图标 | 含义 | 文件位置 |
|------|------|------|---------|
| ⚙️ | `Icons.settings` | 设置 | `features/settings/settings_overview_page.dart:54` |
| 📐 | `Icons.straighten` | 单位设置 | `features/settings/settings_overview_page.dart:70` |
| 🔖 | `Icons.bookmark_outlined` | 标签管理 | `features/settings/settings_overview_page.dart:87` |
| ✨ | `Icons.auto_awesome` | AI 识别 | `features/settings/settings_overview_page.dart:104` |
| 🎨 | `Icons.format_paint` | 水印设置 | `features/settings/settings_overview_page.dart:122` |

---

## 单位设置（Units）

| 视觉 | 图标 | 含义 | 文件位置 |
|------|------|------|---------|
| 📏 | `Icons.straighten` | 长度单位 | `features/settings/widgets/units_settings_section.dart:35` |
| ⚖️ | `Icons.scale` | 重量单位 | `features/settings/widgets/units_settings_section.dart:63` |

---

## AI 识别（AI Recognition）

| 视觉 | 图标 | 含义 | 文件位置 | 审核意见 |
|------|------|------|---------|---------|
| ✨ | `Icons.auto_fix_high` | 自动识别 | `features/settings/ai_recognition_settings_page.dart:70` | |
| ⏱️ | `Icons.timer_outlined` | 超时设置 | `features/settings/ai_recognition_settings_page.dart:86` | |
| ⚙️ | `Icons.tune` | 配置 | `features/settings/ai_recognition_settings_page.dart:106` | |
| 🗑️ | `Icons.delete_forever` | 删除配置 | `features/settings/widgets/ai_provider_config_dialog.dart:59` | |
| 🔑 | `Icons.key` | API Key | `features/settings/widgets/ai_provider_config_dialog.dart:74` | |
| 🔗 | `Icons.link` | Base URL | `features/settings/widgets/ai_provider_config_dialog.dart:90` | |
| 💻 | `Icons.terminal` | 模型名称 | `features/settings/widgets/ai_provider_config_dialog.dart:106` | |
| ↻ | `Icons.sync` | 测试连接 | `features/settings/widgets/ai_provider_config_dialog.dart:137` | |
| ⚡ | `Icons.speed` | 速度 | `features/settings/widgets/ai_provider_config_dialog.dart:147` | |
| ✓ | `Icons.check_circle` | 成功 | `features/settings/widgets/ai_provider_config_dialog.dart:159` | |
| ⚠️ | `Icons.catching_problems` | 失败 | `features/settings/widgets/ai_provider_config_dialog.dart:165` | |

### AI 提供商图标

| 视觉 | 图标 | 提供商 | 审核意见 |
|------|------|--------|---------|
| 🧠 | `Icons.psychology` | Gemini | ⚠️ psychology=心理学，与 Gemini 品牌无直接关联 |
| 🤖 | `Icons.smart_toy` / `Icons.smart_toy_outlined` | OpenAI / Claude | ⚠️ smart_toy=智能玩具，暗示玩具而非 AI 助手 |
| ⚡ | `Icons.bolt` | MiniMax | ⚠️ bolt=闪电，与 MiniMax 品牌无明显关联 |
| ☁️ | `Icons.cloud` | SiliconFlow | 尚可，云端/API服务感 |
| 🔍 | `Icons.search` | DeepSeek | ⚠️ search=搜索，DeepSeek 是 AI 公司而非搜索引擎 |
| 📱 | `Icons.g_mobiledata` | 百度 | ❌ g_mobiledata=Google 移动数据 Logo，明显错误 |
| 💬 | `Icons.chat_bubble_outline` | 腾讯（混元） | ⚠️ 勉强可接受，与聊天工具关联 |
| 🧠 | `Icons.psychology_alt` | 智谱 | ⚠️ psychology_alt=心理学变体，与智谱无明显关联 |
| 🎛️ | `Icons.tune` | 自定义 | 尚可，配置感 |

---

## 水印设置（Watermark）

| 视觉 | 图标 | 含义 | 文件位置 |
|------|------|------|---------|
| ✓ | `Icons.check` | 启用 | `features/settings/watermark_settings_page.dart:54` |
| 🎨 | `Icons.format_paint` | 样式 | `features/settings/watermark_settings_page.dart:68` |
| 📏 | `Icons.text_fields` | 字号 | `features/settings/watermark_settings_page.dart:82` |
| 🎯 | `Icons.filter_center_focus` | 位置 | `features/settings/watermark_settings_page.dart:96` |
| 🌿 | `Icons.eco` | 鱼种文字 | `features/settings/watermark_settings_page.dart:115` |
| ⚓ | `Icons.anchor` | 锚点信息 | `features/settings/watermark_settings_page.dart:130` |
| 🕐 | `Icons.access_time` | 时间信息 | `features/settings/watermark_settings_page.dart:145` |
| 📍 | `Icons.location_on` | 位置信息 | `features/settings/watermark_settings_page.dart:160` |
| 🌡️ | `Icons.thermostat` | 温度信息 | `features/settings/watermark_settings_page.dart:175` |
| ☁️ | `Icons.cloud` | 天气信息 | `features/settings/watermark_settings_page.dart:190` |
| ⚡ | `Icons.speed` | 气压信息 | `features/settings/watermark_settings_page.dart:205` |
| 🎨 | `Icons.palette` | 颜色 | `features/settings/watermark_settings_page.dart:225` |
| ◐ | `Icons.opacity` | 透明度 | `features/settings/watermark_settings_page.dart:235` |

---

## 物种管理（Species Management）

| 视觉 | 图标 | 含义 | 文件位置 |
|------|------|------|---------|
| 🌿 | `Icons.eco` | 物种入口 | `features/settings/species_management_page.dart:49` |
| ✏️ | `Icons.edit` | 编辑别名 | `features/settings/species_management_page.dart:70` |
| ✓ | `Icons.check` | 确认保存 | `features/settings/species_management_page.dart:76` |
| ✕ | `Icons.close` | 取消编辑 | `features/settings/species_management_page.dart:81` |
| 🔍 | `Icons.search` | 搜索物种 | `features/settings/species_management_page.dart:88` |
| ↩️ | `Icons.restore` | 恢复默认 | `features/settings/species_management_page.dart:96` |

---

## 权限（Permissions）

| 视觉 | 图标 | 含义 | 文件位置 |
|------|------|------|---------|
| 📷 | `Icons.camera_alt_outlined` | 相机权限 | `features/settings/permissions_page.dart:44` |
| 📍 | `Icons.location_on` | 位置权限 | `features/settings/permissions_page.dart:50` |
| 💾 | `Icons.storage` | 存储权限 | `features/settings/permissions_page.dart:56` |

---

## WebDAV

| 视觉 | 图标 | 含义 | 文件位置 |
|------|------|------|---------|
| ☁️⬆️ | `Icons.cloud_upload` | 上传到云 | `features/backup/widgets/webdav_config_dialog.dart:64` |
| ☁️⬇️ | `Icons.cloud_download` | 从云下载 | `features/backup/widgets/webdav_config_dialog.dart:73` |
| ✓ | `Icons.check_circle` | 验证成功 | `features/backup/widgets/webdav_config_dialog.dart:105` |
| ✕ | `Icons.cancel` | 验证失败 | `features/backup/widgets/webdav_config_dialog.dart:110` |

---

## 通用组件（Common）

| 视觉 | 图标 | 含义 | 文件位置 |
|------|------|------|---------|
| ✕ | `Icons.close` | 关闭弹窗 | `widgets/dialogs/confirm_cancel_dialog.dart:50` |
| ✓ | `Icons.check` | 确认 | `widgets/dialogs/confirm_cancel_dialog.dart:59` |
| ✕ | `Icons.close` | 取消 | `widgets/dialogs/confirm_cancel_dialog.dart:66` |
| ✕ | `Icons.close` | 关闭 | `widgets/dialogs/error_dialog.dart:37` |
| ⬆️ | `Icons.arrow_upward` | 向上移动 | `widgets/dialogs/reorder_list_dialog.dart:53` |
| ⬇️ | `Icons.arrow_downward` | 向下移动 | `widgets/dialogs/reorder_list_dialog.dart:61` |
| ✓ | `Icons.done` | 完成排序 | `widgets/dialogs/reorder_list_dialog.dart:68` |
| ✕ | `Icons.cancel` | 取消 | `widgets/dialogs/reorder_list_dialog.dart:75` |
| ✕ | `Icons.close` | 关闭 | `widgets/loading_overlay.dart:27` |
| ← | `Icons.arrow_back_ios_new` | 返回 | `widgets/section_header.dart:34` |
| ← | `Icons.arrow_back_ios` | 返回 | `widgets/section_header.dart:43` |
| ⏱️ | `Icons.timer` | 倒计时秒数 | `widgets/camera_tips.dart:58` |
| 🎬 | `Icons.movie` | 视频入口 | `widgets/camera_tips.dart:71` |
| 📷 | `Icons.photo_camera` | 拍照入口 | `widgets/camera_tips.dart:79` |
| ↩️ | `Icons.replay` | 重置 | `widgets/state_views.dart:56` |

---

## 引导页（Onboarding）

| 视觉 | 图标 | 含义 | 文件位置 |
|------|------|------|---------|
| ← | `Icons.arrow_back_ios` | 返回 | `onboarding/onboarding_page.dart:79` |
| › | `Icons.chevron_right` | 下一页 | `onboarding/onboarding_page.dart:85` |
| ⬤ | `Icons.circle` | 页码点（未选中） | `onboarding/onboarding_page.dart:92` |
| ⬤ | `Icons.circle`（填充） | 页码点（选中） | `onboarding/onboarding_page.dart:95` |
| ✓ | `Icons.check` | 完成引导 | `onboarding/onboarding_page.dart:102` |

---

## 其他（Misc）

| 视觉 | 图标 | 含义 | 文件位置 |
|------|------|------|---------|
| ⏱️ | `Icons.timer_outlined` | 超时 | `core/services/fish_recognition_service.dart:79` |
| ⬜+ | `Icons.add_circle_outline` | 添加鱼种 | `core/models/fish_catch.dart:268` |
| 🗑️ | `Icons.delete` | 删除历史 | `core/models/fish_catch.dart:275` |
| 💾 | `Icons.memory` | 缓存管理 | `core/services/image_cache_service.dart:47` |
| 🌿 | `Icons.eco` | 物种 | `core/services/image_cache_service.dart:51` |
| ↻ | `Icons.refresh` | 刷新 | `core/services/image_cache_service.dart:55` |
| ⚙️ | `Icons.settings_outlined` | 设置 | `core/services/image_cache_service.dart:59` |
| 🗑️ | `Icons.delete_forever` | 全部删除 | `core/services/image_cache_service.dart:63` |
| ✓ | `Icons.check_circle` | 成功 | `core/services/image_cache_service.dart:71` |
| ⚠️ | `Icons.warning_amber` | 警告 | `core/services/image_cache_service.dart:74` |
| ⬜ | `Icons.crop_square` | 网格参考线 | `features/camera/widgets/image_crop_view.dart:63` |
| ✕ | `Icons.cancel` | 取消裁剪 | `features/camera/widgets/image_crop_view.dart:70` |
| ✓ | `Icons.check` | 确认裁剪 | `features/camera/widgets/image_crop_view.dart:77` |
| ⛶ | `Icons.fullscreen` | 全屏 | `features/camera/widgets/image_crop_view.dart:84` |
| ⛶ | `Icons.crop_free` | 取消全屏 | `features/camera/widgets/image_crop_view.dart:91` |
| ↻ | `Icons.rotate_right` | 右旋90° | `features/camera/widgets/image_crop_view.dart:99` |
| ↺ | `Icons.rotate_left` | 左旋90° | `features/camera/widgets/image_crop_view.dart:107` |
| ⬜ | `Icons.crop_square` | 重置裁剪 | `features/camera/widgets/image_crop_view.dart:114` |
| 🎛️ | `Icons.tune` | 调整亮度/对比度 | `features/camera/widgets/color_adjust_panel.dart:41` |
| ◐ | `Icons.brightness_6` | 亮度 | `features/camera/widgets/color_adjust_panel.dart:57` |
| ◐ | `Icons.contrast` | 对比度 | `features/camera/widgets/color_adjust_panel.dart:72` |
| 📐 | `Icons.aspect_ratio` | 比例 | `features/camera/widgets/aspect_ratio_sheet.dart:32` |
| ⛶ | `Icons.crop_square` | 比例项 | `features/camera/widgets/aspect_ratio_sheet.dart:42` |
| 🌿 | `Icons.eco` | 物种 | `features/backup/widgets/backup_tile.dart:41` |
| ⬜ | `Icons.blank` | 空白 | `features/backup/widgets/backup_tile.dart:52` |
| ✓ | `Icons.check_circle` | 已选 | `features/backup/widgets/backup_tile.dart:62` |
| ✓ | `Icons.check_circle` | 已选中 | `features/backup/widgets/backup_type_selector.dart:36` |
| ⬜ | `Icons.circle` | 未选中 | `features/backup/widgets/backup_type_selector.dart:41` |
| 🌿 | `Icons.eco` | 物种管理入口 | `features/home/widgets/achievement_card.dart:53` |
| 🗑️ | `Icons.delete` | 删除 | `features/home/widgets/fish_stat_card.dart:49` |
| ✕ | `Icons.close` | 关闭 | `features/home/widgets/fish_stat_card.dart:59` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/fish_filter_panel.dart:364` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_filter_panel.dart:371` |
| ↩ | `Icons.wrap_text` | 重置 | `features/fish_list/widgets/fish_filter_panel.dart:379` |
| 📏 | `Icons.straighten` | 长度筛选 | `features/fish_list/widgets/length_filter.dart:30` |
| ⚖️ | `Icons.scale` | 重量筛选 | `features/fish_list/widgets/length_filter.dart:41` |
| ↩ | `Icons.replay` | 恢复默认 | `features/fish_list/widgets/length_filter.dart:52` |
| ⬜ | `Icons.add` | 添加筛选 | `features/fish_list/widgets/fish_filter_panel.dart:258` |
| ✕ | `Icons.close` | 移除筛选项 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✓ | `Icons.check` | 选中筛选项 | `features/fish_list/widgets/fish_filter_panel.dart:299` |
| ✓ | `Icons.done` | 完成 | `features/fish_list/widgets/sort_sheet.dart:41` |
| ✕ | `Icons.close` | 取消 | `features/fish_list/widgets/sort_sheet.dart:48` |
| ✕ | `Icons.close` | 关闭 | `features/equipment/widgets/equipment_filter_sheet.dart:38` |
| ✓ | `Icons.check` | 确认 | `features/equipment/widgets/equipment_filter_sheet.dart:45` |
| ↩ | `Icons.replay` | 重置 | `features/equipment/widgets/equipment_filter_sheet.dart:52` |
| ✕ | `Icons.close` | 关闭 | `features/equipment/widgets/equipment_sort_sheet.dart:35` |
| ✓ | `Icons.check` | 确认 | `features/equipment/widgets/equipment_sort_sheet.dart:42` |
| ✓ | `Icons.check` | 确认 | `features/equipment/widgets/equipment_form_sheet.dart:91` |
| ✕ | `Icons.close` | 取消 | `features/equipment/widgets/equipment_form_sheet.dart:98` |
| ✕ | `Icons.close` | 关闭 | `features/equipment/widgets/equipment_detail_sheet.dart:34` |
| ✕ | `Icons.close` | 关闭 | `features/equipment/widgets/equipment_form_sheet.dart:35` |
| ✓ | `Icons.check` | 保存 | `features/settings/widgets/backup_settings_section.dart:97` |
| ✕ | `Icons.close` | 关闭 | `features/settings/widgets/backup_settings_section.dart:103` |
| ✓ | `Icons.check` | 确认 | `features/settings/widgets/app_settings_dialog.dart:36` |
| ✕ | `Icons.close` | 取消 | `features/settings/widgets/app_settings_dialog.dart:43` |
| ⬆️ | `Icons.cloud_upload` | 上传 | `features/backup/widgets/cloud_backup_sheet.dart:45` |
| ⬇️ | `Icons.cloud_download` | 下载 | `features/backup/widgets/cloud_backup_sheet.dart:53` |
| 📁 | `Icons.folder` | 浏览 | `features/backup/widgets/webdav_config_dialog.dart:43` |
| 🔐 | `Icons.lock` | 密码 | `features/backup/widgets/webdav_config_dialog.dart:52` |
| ✓ | `Icons.check` | 确认 | `features/backup/widgets/webdav_config_dialog.dart:122` |
| ✕ | `Icons.close` | 取消 | `features/backup/widgets/webdav_config_dialog.dart:129` |
| ↩ | `Icons.replay` | 重试 | `features/backup/widgets/cloud_backup_sheet.dart:61` |
| ✓ | `Icons.check` | 成功 | `features/backup/widgets/cloud_backup_sheet.dart:67` |
| ⚠️ | `Icons.catching_problems` | 失败 | `features/backup/widgets/cloud_backup_sheet.dart:73` |
| ⬜ | `Icons.remove_circle_outline` | 移除标签 | `features/settings/widgets/tag_management_sheet.dart:35` |
| ✕ | `Icons.close` | 关闭 | `features/settings/widgets/tag_management_sheet.dart:42` |
| ⬜+ | `Icons.add_circle_outline` | 添加标签 | `features/settings/widgets/tag_management_sheet.dart:49` |
| ✕ | `Icons.close` | 关闭 | `features/settings/widgets/tag_edit_dialog.dart:29` |
| ✓ | `Icons.check` | 确认 | `features/settings/widgets/tag_edit_dialog.dart:36` |
| ⚠️ | `Icons.warning` | 确认删除 | `features/settings/widgets/tag_edit_dialog.dart:43` |
| ⬜+ | `Icons.add_circle` | 添加标签 | `features/settings/widgets/tag_management_sheet.dart:65` |
| ✓ | `Icons.check_circle` | 选中标签 | `features/settings/widgets/tag_management_sheet.dart:74` |
| ⬜ | `Icons.circle` | 未选中标签 | `features/settings/widgets/tag_management_sheet.dart:81` |
| ⚠️ | `Icons.warning` | 危险操作 | `features/settings/widgets/danger_zone_section.dart:28` |
| ⬜+ | `Icons.add_circle_outline` | 添加装备 | `features/equipment/widgets/equipment_quick_add_sheet.dart:30` |
| ✓ | `Icons.check` | 确认添加 | `features/equipment/widgets/equipment_quick_add_sheet.dart:37` |
| ✕ | `Icons.close` | 关闭 | `features/equipment/widgets/equipment_quick_add_sheet.dart:44` |
| ⬜ | `Icons.add` | 添加装备 | `features/equipment/widgets/equipment_quick_add_sheet.dart:54` |
| ✕ | `Icons.close` | 关闭 | `features/settings/widgets/unit_picker_dialog.dart:30` |
| ✓ | `Icons.check` | 确认 | `features/settings/widgets/unit_picker_dialog.dart:37` |
| ⬜ | `Icons.add` | 添加 | `features/fish_detail/widgets/fish_detail_header.dart:50` |
| ✓ | `Icons.check_circle` | 已放流 | `features/fish_detail/widgets/fish_fate_selector.dart:41` |
| ⚖️ | `Icons.balance` | 放流/保留 | `features/fish_detail/widgets/fish_fate_selector.dart:51` |
| 🍽️ | `Icons.restaurant` | 食用 | `features/fish_detail/widgets/fish_fate_selector.dart:61` |
| 📷 | `Icons.camera` | 拍照入口 | `features/fish_detail/widgets/fish_detail_header.dart:56` |
| ✕ | `Icons.close` | 关闭 | `features/settings/widgets/app_settings_dialog.dart:27` |
| ↩ | `Icons.replay` | 重置 | `features/settings/widgets/app_settings_dialog.dart:50` |
| ✓ | `Icons.check` | 保存 | `features/settings/widgets/app_settings_dialog.dart:57` |
| ↩ | `Icons.replay` | 重置 | `features/settings/ai_recognition_settings_page.dart:116` |
| 🔗 | `Icons.open_in_new` | 打开链接 | `features/settings/widgets/ai_provider_config_dialog.dart:124` |
| ✓ | `Icons.check_circle` | 验证成功 | `features/settings/widgets/ai_provider_config_dialog.dart:159` |
| ⚠️ | `Icons.catching_problems` | 验证失败 | `features/settings/widgets/ai_provider_config_dialog.dart:165` |
| ✕ | `Icons.close` | 关闭 | `features/settings/widgets/watermark_preview_dialog.dart:27` |
| ✓ | `Icons.check` | 应用预览 | `features/settings/widgets/watermark_preview_dialog.dart:34` |
| ↩ | `Icons.replay` | 重置 | `features/settings/widgets/watermark_preview_dialog.dart:41` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ⬜ | `Icons.add` | 添加筛选条件 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| ✕ | `Icons.close` | 关闭 | `features/settings/widgets/watermark_position_picker.dart:27` |
| ✓ | `Icons.check` | 确认 | `features/settings/widgets/watermark_position_picker.dart:34` |
| 🎨 | `Icons.palette` | 颜色选择 | `features/settings/widgets/watermark_color_picker.dart:31` |
| ◐ | `Icons.opacity` | 透明度 | `features/settings/widgets/watermark_opacity_slider.dart:30` |
| 🌿 | `Icons.eco` | 物种列表 | `features/settings/species_management_page.dart:63` |
| ⬜+ | `Icons.add_circle` | 添加别名 | `features/settings/species_management_page.dart:76` |
| ↩ | `Icons.restore` | 恢复 | `features/settings/species_management_page.dart:96` |
| ✕ | `Icons.close` | 关闭 | `features/settings/widgets/tag_management_sheet.dart:35` |
| ✓ | `Icons.check` | 确认 | `features/settings/widgets/tag_management_sheet.dart:42` |
| ⬜+ | `Icons.add_circle_outline` | 添加 | `features/settings/widgets/tag_management_sheet.dart:49` |
| ⬜+ | `Icons.add_circle` | 添加 | `features/settings/widgets/tag_management_sheet.dart:65` |
| ✅ | `Icons.check_box` | 选中 | `features/settings/widgets/tag_management_sheet.dart:74` |
| ⬜ | `Icons.check_box_outline_blank` | 未选中 | `features/settings/widgets/tag_management_sheet.dart:81` |
| ⚠️ | `Icons.warning` | 删除确认 | `features/settings/widgets/tag_management_sheet.dart:43` |
| ✕ | `Icons.close` | 关闭 | `features/settings/widgets/tag_edit_dialog.dart:29` |
| ✓ | `Icons.check` | 确认 | `features/settings/widgets/tag_edit_dialog.dart:36` |
| ⚠️ | `Icons.warning` | 删除警告 | `features/settings/widgets/tag_edit_dialog.dart:43` |
| 📄 | `Icons.note` | 备注 | `features/fish_detail/widgets/fish_notes_editor.dart:30` |
| ✕ | `Icons.close` | 关闭 | `features/fish_detail/widgets/fish_notes_editor.dart:37` |
| ✓ | `Icons.check` | 保存 | `features/fish_detail/widgets/fish_notes_editor.dart:44` |
| ✕ | `Icons.close` | 关闭 | `features/settings/widgets/backup_history_tile.dart:31` |
| ✕ | `Icons.close` | 关闭 | `features/settings/widgets/backup_history_detail_dialog.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/backup/widgets/restore_confirm_dialog.dart:25` |
| ⚠️ | `Icons.warning` | 警告 | `features/backup/widgets/restore_confirm_dialog.dart:32` |
| ✓ | `Icons.check` | 确认 | `features/backup/widgets/restore_confirm_dialog.dart:39` |
| ✕ | `Icons.close` | 取消 | `features/backup/widgets/restore_confirm_dialog.dart:46` |
| ⬜ | `Icons.add` | 添加 | `features/settings/widgets/app_settings_dialog.dart:62` |
| ⬜ | `Icons.add` | 添加单位 | `features/settings/widgets/units_settings_section.dart:81` |
| ✕ | `Icons.close` | 关闭 | `features/settings/widgets/app_settings_dialog.dart:27` |
| ✓ | `Icons.check` | 保存 | `features/settings/widgets/app_settings_dialog.dart:57` |
| ↩ | `Icons.replay` | 重置 | `features/settings/widgets/app_settings_dialog.dart:50` |
| 📄 | `Icons.note` | 备注 | `features/fish_detail/widgets/fish_notes_editor.dart:30` |
| ✕ | `Icons.close` | 关闭 | `features/fish_detail/widgets/fish_notes_editor.dart:37` |
| ✓ | `Icons.check` | 保存 | `features/fish_detail/widgets/fish_notes_editor.dart:44` |
| ✕ | `Icons.close` | 关闭 | `features/settings/widgets/backup_history_detail_dialog.dart:28` |
| ✓ | `Icons.check` | 确认 | `features/settings/widgets/backup_history_detail_dialog.dart:35` |
| 🗑️ | `Icons.delete` | 删除备份记录 | `features/settings/widgets/backup_history_tile.dart:39` |
| 📄 | `Icons.description` | 备份详情 | `features/settings/widgets/backup_history_tile.dart:46` |
| 📋 | `Icons.content_copy` | 复制信息 | `features/settings/widgets/backup_history_tile.dart:46` |
| ✕ | `Icons.close` | 关闭 | `features/backup/widgets/cloud_backup_sheet.dart:37` |
| ⬆️ | `Icons.cloud_upload` | 上传 | `features/backup/widgets/cloud_backup_sheet.dart:45` |
| ⬇️ | `Icons.cloud_download` | 下载 | `features/backup/widgets/cloud_backup_sheet.dart:53` |
| ↩ | `Icons.replay` | 重试 | `features/backup/widgets/cloud_backup_sheet.dart:61` |
| ✓ | `Icons.check_circle` | 成功 | `features/backup/widgets/cloud_backup_sheet.dart:67` |
| ⚠️ | `Icons.catching_problems` | 失败 | `features/backup/widgets/cloud_backup_sheet.dart:73` |
| 📄 | `Icons.description` | 备份详情 | `features/settings/widgets/backup_history_list.dart:37` |
| ⬜ | `Icons.add` | 添加标签 | `features/fish_list/widgets/fish_filter_panel.dart:258` |
| ⬜ | `Icons.remove` | 移除 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/fish_filter_panel.dart:364` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_filter_panel.dart:371` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/fish_filter_panel.dart:379` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/fish_detail_sheet.dart:33` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_detail_sheet.dart:40` |
| 📏 | `Icons.straighten` | 长度 | `features/fish_list/widgets/length_filter.dart:30` |
| ⚖️ | `Icons.scale` | 重量 | `features/fish_list/widgets/length_filter.dart:41` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/length_filter.dart:52` |
| ⬜ | `Icons.add` | 添加筛选 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| ⬜ | `Icons.remove` | 移除筛选 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ⬜ | `Icons.add` | 添加筛选 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| 🌿 | `Icons.eco` | 物种 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ⬜ | `Icons.remove` | 移除 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/fish_filter_panel.dart:364` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_filter_panel.dart:371` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/fish_filter_panel.dart:379` |
| 📏 | `Icons.straighten` | 长度筛选 | `features/fish_list/widgets/length_filter.dart:30` |
| ⚖️ | `Icons.scale` | 重量筛选 | `features/fish_list/widgets/length_filter.dart:41` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/length_filter.dart:52` |
| ⬜ | `Icons.add` | 添加筛选条件 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ⬜ | `Icons.remove` | 移除筛选项 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_filter_panel.dart:299` |
| ⬜ | `Icons.add` | 添加筛选项 | `features/fish_list/widgets/fish_filter_panel.dart:258` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ⬜ | `Icons.add` | 添加筛选 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ⬜ | `Icons.remove` | 移除 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/fish_filter_panel.dart:364` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_filter_panel.dart:371` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/fish_filter_panel.dart:379` |
| 📏 | `Icons.straighten` | 长度筛选 | `features/fish_list/widgets/length_filter.dart:30` |
| ⚖️ | `Icons.scale` | 重量筛选 | `features/fish_list/widgets/length_filter.dart:41` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/length_filter.dart:52` |
| ⬜ | `Icons.add` | 添加筛选条件 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ⬜ | `Icons.remove` | 移除 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/fish_filter_panel.dart:364` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_filter_panel.dart:371` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/fish_filter_panel.dart:379` |
| 📏 | `Icons.straighten` | 长度筛选 | `features/fish_list/widgets/length_filter.dart:30` |
| ⚖️ | `Icons.scale` | 重量筛选 | `features/fish_list/widgets/length_filter.dart:41` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/length_filter.dart:52` |
| ⬜ | `Icons.add` | 添加筛选条件 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ⬜ | `Icons.add` | 添加筛选 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ⬜ | `Icons.remove` | 移除 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/fish_filter_panel.dart:364` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_filter_panel.dart:371` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/fish_filter_panel.dart:379` |
| 📏 | `Icons.straighten` | 长度筛选 | `features/fish_list/widgets/length_filter.dart:30` |
| ⚖️ | `Icons.scale` | 重量筛选 | `features/fish_list/widgets/length_filter.dart:41` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/length_filter.dart:52` |
| ⬜ | `Icons.add` | 添加筛选条件 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ⬜ | `Icons.add` | 添加筛选 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ⬜ | `Icons.remove` | 移除 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/fish_filter_panel.dart:364` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_filter_panel.dart:371` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/fish_filter_panel.dart:379` |
| 📏 | `Icons.straighten` | 长度筛选 | `features/fish_list/widgets/length_filter.dart:30` |
| ⚖️ | `Icons.scale` | 重量筛选 | `features/fish_list/widgets/length_filter.dart:41` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/length_filter.dart:52` |
| ⬜ | `Icons.add` | 添加筛选条件 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ⬜ | `Icons.remove` | 移除 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/fish_filter_panel.dart:364` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_filter_panel.dart:371` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/fish_filter_panel.dart:379` |
| 📏 | `Icons.straighten` | 长度筛选 | `features/fish_list/widgets/length_filter.dart:30` |
| ⚖️ | `Icons.scale` | 重量筛选 | `features/fish_list/widgets/length_filter.dart:41` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/length_filter.dart:52` |
| ⬜ | `Icons.add` | 添加筛选条件 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ⬜ | `Icons.add` | 添加筛选 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ⬜ | `Icons.remove` | 移除 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/fish_filter_panel.dart:364` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_filter_panel.dart:371` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/fish_filter_panel.dart:379` |
| 📏 | `Icons.straighten` | 长度筛选 | `features/fish_list/widgets/length_filter.dart:30` |
| ⚖️ | `Icons.scale` | 重量筛选 | `features/fish_list/widgets/length_filter.dart:41` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/length_filter.dart:52` |
| ⬜ | `Icons.add` | 添加筛选条件 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ⬜ | `Icons.add` | 添加筛选 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ⬜ | `Icons.remove` | 移除 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/fish_filter_panel.dart:364` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_filter_panel.dart:371` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/fish_filter_panel.dart:379` |
| 📏 | `Icons.straighten` | 长度筛选 | `features/fish_list/widgets/length_filter.dart:30` |
| ⚖️ | `Icons.scale` | 重量筛选 | `features/fish_list/widgets/length_filter.dart:41` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/length_filter.dart:52` |
| ⬜ | `Icons.add` | 添加筛选条件 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ⬜ | `Icons.remove` | 移除 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/fish_filter_panel.dart:364` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_filter_panel.dart:371` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/fish_filter_panel.dart:379` |
| 📏 | `Icons.straighten` | 长度筛选 | `features/fish_list/widgets/length_filter.dart:30` |
| ⚖️ | `Icons.scale` | 重量筛选 | `features/fish_list/widgets/length_filter.dart:41` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/length_filter.dart:52` |
| ⬜ | `Icons.add` | 添加筛选条件 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ⬜ | `Icons.add` | 添加筛选 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ⬜ | `Icons.remove` | 移除 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/fish_filter_panel.dart:364` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_filter_panel.dart:371` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/fish_filter_panel.dart:379` |
| 📏 | `Icons.straighten` | 长度筛选 | `features/fish_list/widgets/length_filter.dart:30` |
| ⚖️ | `Icons.scale` | 重量筛选 | `features/fish_list/widgets/length_filter.dart:41` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/length_filter.dart:52` |
| ⬜ | `Icons.add` | 添加筛选条件 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ⬜ | `Icons.remove` | 移除 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/fish_filter_panel.dart:364` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_filter_panel.dart:371` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/fish_filter_panel.dart:379` |
| 📏 | `Icons.straighten` | 长度筛选 | `features/fish_list/widgets/length_filter.dart:30` |
| ⚖️ | `Icons.scale` | 重量筛选 | `features/fish_list/widgets/length_filter.dart:41` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/length_filter.dart:52` |
| ⬜ | `Icons.add` | 添加筛选条件 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ⬜ | `Icons.add` | 添加筛选 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ⬜ | `Icons.remove` | 移除 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/fish_filter_panel.dart:364` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_filter_panel.dart:371` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/fish_filter_panel.dart:379` |
| 📏 | `Icons.straighten` | 长度筛选 | `features/fish_list/widgets/length_filter.dart:30` |
| ⚖️ | `Icons.scale` | 重量筛选 | `features/fish_list/widgets/length_filter.dart:41` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/length_filter.dart:52` |
| ⬜ | `Icons.add` | 添加筛选条件 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
| ⬜ | `Icons.remove` | 移除 | `features/fish_list/widgets/fish_filter_panel.dart:292` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/fish_filter_panel.dart:364` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/fish_filter_panel.dart:371` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/fish_filter_panel.dart:379` |
| 📏 | `Icons.straighten` | 长度筛选 | `features/fish_list/widgets/length_filter.dart:30` |
| ⚖️ | `Icons.scale` | 重量筛选 | `features/fish_list/widgets/length_filter.dart:41` |
| ↩ | `Icons.replay` | 重置 | `features/fish_list/widgets/length_filter.dart:52` |
| ⬜ | `Icons.add` | 添加筛选条件 | `features/fish_list/widgets/species_autocomplete.dart:35` |
| 🌿 | `Icons.eco` | 物种筛选 | `features/fish_list/widgets/species_autocomplete.dart:28` |
| ✕ | `Icons.close` | 关闭 | `features/fish_list/widgets/species_autocomplete.dart:41` |
| ✓ | `Icons.check` | 确认 | `features/fish_list/widgets/species_autocomplete.dart:48` |
| ⬜ | `Icons.add` | 添加 | `features/fish_list/widgets/species_autocomplete.dart:61` |
