# skkeleton\_indicator.nvim

Yet another indicator for [Skkeleton][].

[Skkeleton]: https://github.com/vim-skk/skkeleton

https://github.com/delphinus/skkeleton_indicator.nvim/assets/1239245/951b87b9-6315-472d-af3e-04497acd8d88

枠線を付けるとこんな感じです。

https://github.com/delphinus/skkeleton_indicator.nvim/assets/1239245/74588fb8-a483-4d81-8046-f017351f9dd2

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
