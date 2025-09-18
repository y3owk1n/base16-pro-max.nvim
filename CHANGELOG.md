# Changelog

## [1.1.0](https://github.com/y3owk1n/base16-pro-max.nvim/compare/v1.0.0...v1.1.0) (2025-09-17)


### Features

* add a `parser` module for yaml parser ([#28](https://github.com/y3owk1n/base16-pro-max.nvim/issues/28)) ([452b2fb](https://github.com/y3owk1n/base16-pro-max.nvim/commit/452b2fbdce50a8e2a803bd30b10aaa8a16a48310))
* allow `config.highlight_group` to be table or function ([#31](https://github.com/y3owk1n/base16-pro-max.nvim/issues/31)) ([a31ebb4](https://github.com/y3owk1n/base16-pro-max.nvim/commit/a31ebb443cfcbb9b85c781915f4b90b7e6a358ef))
* **config:** add `modes` to `color_groups` opts for lualine and any other statusline integration ([#44](https://github.com/y3owk1n/base16-pro-max.nvim/issues/44)) ([d6da9e9](https://github.com/y3owk1n/base16-pro-max.nvim/commit/d6da9e9cdbadfc260cc9abc5746a72ddb401486b))
* configurable border in colors groups ([#37](https://github.com/y3owk1n/base16-pro-max.nvim/issues/37)) ([07bcf6d](https://github.com/y3owk1n/base16-pro-max.nvim/commit/07bcf6d5aadab81a9ed01bfcf242a94833ba25ba))
* configurable markdown headings (1-6) ([#40](https://github.com/y3owk1n/base16-pro-max.nvim/issues/40)) ([fb533b7](https://github.com/y3owk1n/base16-pro-max.nvim/commit/fb533b7f67e92dc8085a22de7b622e4b0c6a0d68))
* **plugins.mini-diff:** add `Over` highlights for overlay ([#59](https://github.com/y3owk1n/base16-pro-max.nvim/issues/59)) ([5472cbc](https://github.com/y3owk1n/base16-pro-max.nvim/commit/5472cbc029982536c962b501d0cbd923370e6542))
* **plugins:** add `fzf-lua` integration ([#41](https://github.com/y3owk1n/base16-pro-max.nvim/issues/41)) ([86bab2c](https://github.com/y3owk1n/base16-pro-max.nvim/commit/86bab2ccea2168a323c1e76a01ac5db4b325f19f))
* **plugins:** add `lualine` ([#42](https://github.com/y3owk1n/base16-pro-max.nvim/issues/42)) ([90ae665](https://github.com/y3owk1n/base16-pro-max.nvim/commit/90ae665dc52f430d3adae968db64987d6cccdb2c))
* **plugins:** add `mini.statusline` ([#48](https://github.com/y3owk1n/base16-pro-max.nvim/issues/48)) ([33a6727](https://github.com/y3owk1n/base16-pro-max.nvim/commit/33a67270f752ccb6ef6f77a8f6eb962dbad0052c))
* **plugins:** add `Telescope` integration ([#36](https://github.com/y3owk1n/base16-pro-max.nvim/issues/36)) ([ba6501b](https://github.com/y3owk1n/base16-pro-max.nvim/commit/ba6501b39e0314b3e92a7c2cb72d8fd20ed9d181))


### Bug Fixes

* better contrast for default statusline highlights ([#45](https://github.com/y3owk1n/base16-pro-max.nvim/issues/45)) ([16e09de](https://github.com/y3owk1n/base16-pro-max.nvim/commit/16e09de8c4e4f91f098fd4fdcb02163560b0ca4e))
* **mini.pick:** link `bordertext` and `cursorline`, update `infoheader` to md h1 ([#38](https://github.com/y3owk1n/base16-pro-max.nvim/issues/38)) ([798e2f9](https://github.com/y3owk1n/base16-pro-max.nvim/commit/798e2f945c51ccd59c440cb99e64cb7831bb89ec))
* **plugins.grugfar:** remove unnecassary mappings, the default looks nice ([#51](https://github.com/y3owk1n/base16-pro-max.nvim/issues/51)) ([4cd161b](https://github.com/y3owk1n/base16-pro-max.nvim/commit/4cd161b131217b727705c4c1535a026a30c432d8))
* remove public `M.blend` function ([#35](https://github.com/y3owk1n/base16-pro-max.nvim/issues/35)) ([83dfe42](https://github.com/y3owk1n/base16-pro-max.nvim/commit/83dfe42a997ad9f69f24dab2e07b104df86e97af))
* standardize `color_groups` function opts similar to `highlight_groups` ([#32](https://github.com/y3owk1n/base16-pro-max.nvim/issues/32)) ([2cc50e5](https://github.com/y3owk1n/base16-pro-max.nvim/commit/2cc50e5d0b10302597eeff625ea614e4019f7e53))
* **types:** add `border` and move `deprecated` to the right section ([#39](https://github.com/y3owk1n/base16-pro-max.nvim/issues/39)) ([4699def](https://github.com/y3owk1n/base16-pro-max.nvim/commit/4699defd65d24561e8206f354d003368a5075497))
* typo on import module ([#58](https://github.com/y3owk1n/base16-pro-max.nvim/issues/58)) ([9051384](https://github.com/y3owk1n/base16-pro-max.nvim/commit/9051384af098eea1c485a3af9ed13fda66db8715))
* update missing validations for `color_groups` ([#50](https://github.com/y3owk1n/base16-pro-max.nvim/issues/50)) ([2bbff85](https://github.com/y3owk1n/base16-pro-max.nvim/commit/2bbff85f738234d8a949a8129e881e5bb051c351))

## 1.0.0 (2025-09-13)


### Features

* allow `setup_globals` for `vim.g.terminal_color_*` and `vim.g.base16_gui*` ([#23](https://github.com/y3owk1n/base16-pro-max.nvim/issues/23)) ([11228df](https://github.com/y3owk1n/base16-pro-max.nvim/commit/11228df6d954bc23367ef02461316dbe2beab9d4))
* **diagnostics:** add more diagnostic highlights ([#6](https://github.com/y3owk1n/base16-pro-max.nvim/issues/6)) ([3c0e0b4](https://github.com/y3owk1n/base16-pro-max.nvim/commit/3c0e0b46e93fb2dc1671ba7d08d685febd13571b))
* **git:** add `gitsigns` integration ([#7](https://github.com/y3owk1n/base16-pro-max.nvim/issues/7)) ([277876b](https://github.com/y3owk1n/base16-pro-max.nvim/commit/277876b9f1267aa135e616859fdafebac0db2c7a))
* init from config ([#1](https://github.com/y3owk1n/base16-pro-max.nvim/issues/1)) ([46a4de0](https://github.com/y3owk1n/base16-pro-max.nvim/commit/46a4de0c8daa98aed605cc45dc0a30a84b1a923e))
* rename to `base16-pro-max.nvim` ([#17](https://github.com/y3owk1n/base16-pro-max.nvim/issues/17)) ([55cc081](https://github.com/y3owk1n/base16-pro-max.nvim/commit/55cc08169b219a3fe530219f56bcb2e1a8d277e8))
* **time-machine:** add `y3owk1n/time-machine.nvim` integration ([#18](https://github.com/y3owk1n/base16-pro-max.nvim/issues/18)) ([6d68630](https://github.com/y3owk1n/base16-pro-max.nvim/commit/6d68630b16db0ab3808d771df199666806e128fb))


### Bug Fixes

* always return `has_plugin` configuration if it's boolean ([#19](https://github.com/y3owk1n/base16-pro-max.nvim/issues/19)) ([a4f2ec1](https://github.com/y3owk1n/base16-pro-max.nvim/commit/a4f2ec14142201507df4321df55e58c3c549704d))
* **gitsigns:** add gitsigns to `known_plugins` for validation ([#10](https://github.com/y3owk1n/base16-pro-max.nvim/issues/10)) ([79cd91c](https://github.com/y3owk1n/base16-pro-max.nvim/commit/79cd91ca8b457db12a89a06f675d1a98b87d50b9))
* guard `_invalidate_cache` function and clear all related cache ([#16](https://github.com/y3owk1n/base16-pro-max.nvim/issues/16)) ([12f13f6](https://github.com/y3owk1n/base16-pro-max.nvim/commit/12f13f65a59b7a0acc18b246cce969799dec25cd))
* **help:** more information for `help` generation ([#21](https://github.com/y3owk1n/base16-pro-max.nvim/issues/21)) ([e7ac5e0](https://github.com/y3owk1n/base16-pro-max.nvim/commit/e7ac5e0a27d97b568f065f1ae3c5727d209f4209))
* improve bold and italic whenever make sense ([#26](https://github.com/y3owk1n/base16-pro-max.nvim/issues/26)) ([397870a](https://github.com/y3owk1n/base16-pro-max.nvim/commit/397870aae06f3948a0d375c3c43ac0d5b1b1dc00))
* make `delimiter` same color as `[@constructor](https://github.com/constructor)` ([#4](https://github.com/y3owk1n/base16-pro-max.nvim/issues/4)) ([2c87f05](https://github.com/y3owk1n/base16-pro-max.nvim/commit/2c87f059c8e59b5ae4ec5a77c267893964e61a11))
* pass `blend_fn` into `config.color_groups` function with pcall ([#13](https://github.com/y3owk1n/base16-pro-max.nvim/issues/13)) ([62f51d2](https://github.com/y3owk1n/base16-pro-max.nvim/commit/62f51d2a750811ecea01fe4c8050818e126e24f5))
* remove italic from `String` ([#27](https://github.com/y3owk1n/base16-pro-max.nvim/issues/27)) ([4115b09](https://github.com/y3owk1n/base16-pro-max.nvim/commit/4115b09ff0c443545afb446e9c5f0bd2727372a8))


### Performance Improvements

* add `bench.lua` script to perform relevant benchmark for those who cares ([#25](https://github.com/y3owk1n/base16-pro-max.nvim/issues/25)) ([bc3fca9](https://github.com/y3owk1n/base16-pro-max.nvim/commit/bc3fca99cf420ede6163d81d7cc540eb915929e9))
* add highlight computation cache ([#15](https://github.com/y3owk1n/base16-pro-max.nvim/issues/15)) ([276afec](https://github.com/y3owk1n/base16-pro-max.nvim/commit/276afecaea468b5ce41b8d591aa2f2c5fce7e4f9))
* optimize color blending with improved caching and RGB parsing ([#14](https://github.com/y3owk1n/base16-pro-max.nvim/issues/14)) ([07f30f1](https://github.com/y3owk1n/base16-pro-max.nvim/commit/07f30f1becf9a0bf36c704071fee61df567a552b))
