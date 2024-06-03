# skkeleton\_indicator.nvim

Yet another indicator for [Skkeleton][].

[Skkeleton]: https://github.com/vim-skk/skkeleton

https://github.com/delphinus/skkeleton_indicator.nvim/assets/1239245/54f51c64-aafc-4615-9e7d-ced5489731c3

明るい背景色にも対応しています。

https://github.com/delphinus/skkeleton_indicator.nvim/assets/1239245/4e414ec7-2fdc-4e9c-ac3f-25990e66c7c8

## これは何？

> [!NOTE]
> Skkeleton は Neovim/Vim 両対応ですが、このプラグインは Neovim 専用です。

Skkeleton の状態を入力中に判別しやすいよう、カーソルの側にモードを表示します。AquaSKK にあるようなやつです。

## インストール

> [!WARNING]
> デフォルトブランチ `v2` は Neovim 0.10.0 以降で動作します。もしそれより古いバージョンで動かしたい場合は [`main` ブランチ](https://github.com/delphinus/skkeleton_indicator.nvim/tree/main/)を利用してください。

[lazy.nvim](https://github.com/folke/lazy.nvim) だと以下のように設定します。

```lua
{ "delphinus/skkeleton_indicator.nvim", opts = {} }
```

上記のように設定すれば lazy.nvim が自動的に `setup()` を呼んでくれますが、その他のプラグインマネージャーの場合は明示的に呼んでください。

```lua
require("skkeleton_indicator").setup {}
```

オプションなどは doc を見てください。
