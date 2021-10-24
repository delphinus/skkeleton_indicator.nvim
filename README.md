# skkeleton\_indicator.nvim

Yet another indicator for [Skkeleton][].

[Skkeleton]: https://github.com/vim-skk/skkeleton

![Kapture 2021-10-24 at 21 07 04](https://user-images.githubusercontent.com/1239245/138593442-0ff34ccc-72a9-4e07-8b84-92e26b79f288.gif)

## これは何？

Skkeleton の状態を入力中に判別しやすいよう、カーソルの側にモードを表示します。AquaSKK にあるようなやつです。

NOTE: Skkeleton は Neovim/Vim 両対応ですが、このプラグインは Neovim 専用です。

## 使い方

```lua
require'skkeleton_indicator'.setup{}
```

オプションなどは doc を見てください。
