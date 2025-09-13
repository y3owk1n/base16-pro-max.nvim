# Changelog

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
