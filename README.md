# skkeleton\_indicator.nvim

> [!WARNING]
> Neovim 0.10.0 以降を使う場合はデフォルトブランチである
> [`v2` ブランチ](https://github.com/delphinus/skkeleton_indicator.nvim)を利用してください。`main` ブランチは今後更新されません。

Yet another indicator for [Skkeleton][].

[Skkeleton]: https://github.com/vim-skk/skkeleton

https://github.com/delphinus/skkeleton_indicator.nvim/assets/1239245/951b87b9-6315-472d-af3e-04497acd8d88

**NEW!!** 枠線を付けられるようになりました。

https://github.com/delphinus/skkeleton_indicator.nvim/assets/1239245/74588fb8-a483-4d81-8046-f017351f9dd2

## これは何？

Skkeleton の状態を入力中に判別しやすいよう、カーソルの側にモードを表示します。AquaSKK にあるようなやつです。

NOTE: Skkeleton は Neovim/Vim 両対応ですが、このプラグインは Neovim 専用です。

## 使い方

```lua
require'skkeleton_indicator'.setup{}
```

オプションなどは doc を見てください。
