---
title: "SBT(Soul Bound Token)"
date: 2023-02-25T19:39:46+09:00
author: "https://github.com/tgfukuda"
tags:
    - ethereum
    - SBT
    - token
    - EIP
categories:
    - blockchain
draft: true
refs:
    - link: https://vitalik.ca/general/2022/01/26/soulbound.html
    - link: https://deliverypdf.ssrn.com/delivery.php?ID=923094092020029095122005104000026081113000025039022062022072072122008107009003102075053052033000011045114076075006121119093094041072061038014002064095071102087124008072047010085098109014121028111125075082005124016011123108024070101101106086030006016002&EXT=pdf&INDEX=TRUE
    - link: https://eips.ethereum.org/EIPS/eip-5192
    - link: https://eips.ethereum.org/EIPS/eip-5484
    - link: https://eips.ethereum.org/EIPS/eip-4671
    - link: https://eips.ethereum.org/EIPS/eip-5516
    - link: https://eips.ethereum.org/EIPS/eip-5633
    - link: https://eips.ethereum.org/EIPS/eip-5727
    - link: https://eips.ethereum.org/EIPS/eip-4973
    - link: https://eips.ethereum.org/EIPS/eip-4974
    - link: https://eips.ethereum.org/EIPS/eip-5114
    - link: https://ethereum-magicians.org/
    - link: https://github.com/mcortesi/poap
    - link: https://github.com/Proof-Of-Humanity/ProofOfHumanityV2
    - link: https://dl.acm.org/doi/fullHtml/10.1145/3446983.3446992
    - link: https://w3c.github.io/did-core/
    - link: https://w3c-ccg.github.io/vc-api/
---

## Soul Bound Token

Soul Bound Token(SBT)は簡潔にまとめると, 単に既存のトークン(
    [ERC20](https://eips.ethereum.org/EIPS/eip-20)や
    [ERC721](https://eips.ethereum.org/EIPS/eip-721)
)に対して, Non-transferabilityを付加したものになる.

## モチベーション

vitalikの[blog](https://vitalik.ca/general/2022/01/26/soulbound.html)
や[論文](https://deliverypdf.ssrn.com/delivery.php?ID=923094092020029095122005104000026081113000025039022062022072072122008107009003102075053052033000011045114076075006121119093094041072061038014002064095071102087124008072047010085098109014121028111125075082005124016011123108024070101101106086030006016002&EXT=pdf&INDEX=TRUE)によれば, 
blockchain上でSoul(= addressなど)の性質を表すものを保持することでDeSocを実現するというのがモチベーション.

つまり, blockchain上でSoulに対して紐付けられたトークンを持たせることにより, Soul自体に客観的な判断基準を設けることでエコシステムとしての可能性を広げようということに見える.
ぱっと思いつくSoulboundで価値のあるものとしては, 

- 社員証や会員証, 住民票などID的なもの = 投票権等transferされると脆弱性になる一意性を担保するもの
- 免許や権限などその人の能力を表すもの
- ゲームのレアアイテムなど流通させないことで価値のあるもの
- ローンの返済能力やヤフー知恵袋のレビュー, 前科などの評判を表すもの

とか？
これらが単体で機能するというよりは, Soulに対しSBTを用いて何らかの操作を許可したり, 評価を行ったりすることが前提にあり, そういった世界観がDeSocではないだろうか. 

## 関連するEIP

SBTはトークンのサブセットなので, (これだけなら)ethereumの新しい機能は必要にならない.
つまり, DeSocの実現でSBTを利用するために必要なのは, コントラクトとして表現する場合の規格としてどんなものを採用するかの合意を取る(= デファクトを作る)ことになる.
単にERC721の規格だけで良いのか, はたまた全く別の規格があった方が良いのか.

SBTとしてdraft以上のEIPは

- [EIP-5192: Minimal Soulbound NFTs](https://eips.ethereum.org/EIPS/eip-5192)
- [EIP-5484: Consensual Soulbound token](https://eips.ethereum.org/EIPS/eip-5484)
- [EIP-4671: Non Tradable Token](https://eips.ethereum.org/EIPS/eip-4671)
- [EIP-5516: Soulbound Multi-Owner Token](https://eips.ethereum.org/EIPS/eip-5516)
- [Composable Soulbound NFT, EIP-1155 Extension](https://eips.ethereum.org/EIPS/eip-5633)
- [EIP-5727: Semi-Fungible Soulbound Token](https://eips.ethereum.org/EIPS/eip-5727)
- [EIP-4973: Account bound token](https://eips.ethereum.org/EIPS/eip-4973): ゲーム前提
- [EIP-4974: Ratings](https://eips.ethereum.org/EIPS/eip-4974): FT
- [EIP-5114: Soulbound badge](https://eips.ethereum.org/EIPS/eip-5114): Soulとして他のNFTを指す

が主要なものとしてある. 他にも一応あるけど, draftになってなかったり, そもそも
[disscussion](https://ethereum-magicians.org/)で話題に上がった程度.

### SBTを表すEIPを定義する意義

何故既存のトークン規格でも表現できるものに対して新たに規格が必要なのかという点では
Non-transferabilityが強く関係していると思う.

- そもそもrevertするだけのinterfaceを持つ必要がある程度に前提に差のあるものを既存の規格の拡張として表すのは不合理
= 独自規格
- ERC721, ERC1155 (, ERC20)の拡張として実装する場合, トークンの性質上interfaceはあっても実行して意味の無い関数がある = 何らかの判断方法が必要

前者の場合は, 新規に規格を定めなければそもそもSBTを表すデファクトが持てない. これはEIP-5727などの立場.
後者の場合は, 一般的な判断方法として[ERC-165](https://eips.ethereum.org/EIPS/eip-165)があり, 
これに使用するための一般的なSBTで考えられるinterfaceとして定義する必要がある. これはEIP-5192やEIP-5484の立場.

いずれの場合においても, `transfer`, `transferFrom`, `approve`等の前提からして互換性の無い
**既存のinterfaceとの兼ね合い**が問題になっているため, 規格の定義が行われようとしている.

## SBTにおける課題

SBTはNon Transferableである性質上避けられない問題がいくつかある.
これらは任意のSBTで必要となる機能では無いかもしれないが, 
blockchain, ethereumというplatformの性質上向き合わなければならないもの.

### Recovery

やや話は逸れるが, blockchainはecdsaという署名技術をベースに成り立っている性質上,
private keyのrotationや紛失時の復元は重要な問題になる.
これに対して, 既存の方法ではmultisigやhd wallet + mnemonicという方法を用いて保有する資産の保護を行っていた.
しかし, これがSoul, つまりaddressに紐付いてしまっている場合には話が変わってくる.

例えば, あるaddress Aでtokenを持っていて, private keyの流出してしまったため速やかに別アカウントへ移したいとしよう.
通常のtokenなら, 別のaddressを用意してtokenをtransferするだけで済むが, SBTの場合にはこれができない.

この
    addressにtokenを紐付けるという制約 (1)
に対して, 
private keyの扱いを楽にするために考えられているのが**Recovery**だ.

具体的なRecoveryの定義は挙げられていないと思うが,

1. token単位でのrecovery (address Aの所有するtoken 1, 2, ...に対してそれぞれにrecoveryを適用可能)
2. owner単位でのrecovery (address Aに対して別のaddress Bへrecoveryする場合, 保有するtoken全てをBへ移転)

が考えられると思う. DeSoc的な立場で考えるなら2が必要だと思うので, 以降は2でのRecoveryを考える.

#### 既存の鍵管理は不十分なのか

前述のmultisigやhd wallet + mnemonicが制約 (1)を避けるために不十分かという観点では議論の余地はあると思う.


##### hd wallet + mnemonic

まず, hd wallet + mnemonicによる管理では明確にRecoveryは達成できない.
自分の知る限りこの方法は, マスターseedとなるmnemonicを覚えておくことで,
鍵をなくした場合には全て(現実的には一定のdepth)のaccountに関して資産の確認を行いrecoveryしようというのがこの管理になる.

そのため前述のような流出時には通常のkey同様にkey rotationにより回避を行わなければならない.
結局は同様の問題に衝突するため, SBTにおいて必要とされるRecoveryは達成できないはず.

##### multisig

次にmultisigのケース. これは一定意味があると思う.
multisigは, 署名作成に必要な鍵を $n$ ($2 <= n$)個の断片に分割し, 
署名作成に$m$ ($m <= n$)個の断片を集めなければならないようにすることでsecurityを担保する. 
[分霊箱](https://harrypotter.fandom.com/ja/wiki/%E5%88%86%E9%9C%8A%E7%AE%B1)的な方法だと思っていい.

$m, n$を一定大きく保つことで, private keyの紛失/流出いずれが起きても直接的な問題にならないようにしようというのが, 
この方法における対処法のため, そもそもRecoveryの必要な状態にならないようにすれば良いのでは？という観点で, 
SBTでも一定のsecurityがもたらせるのではないかと思う.

しかし, この場合においても$m$が小さい場合には問題になるし, 一部が流出した鍵を使い続けるのかという論点もあると思う.


vitalikらはSBTにおける既存の鍵管理についてはあまり言及していないが, 僕はSBTの性質上onchainで保有者の変更方法自体は
持っていた方が良いと考えている. 

#### Recoveryの方法

具体的なRecoveryとしてvitalikらは*Social Recovery*や*Community Recovery*を上げている.

Community recoveryはSocial recoveryの発展形と言えるので, Social recoveryの概要を示しておく.

Social recoveryはrecoveryのために複数の**guardian**というものを設定する. guardianは保有者と関係のある別のaddressと考えて良い.
guardiansの過半数によって保有者のwalletの鍵の変更を許可するのがSocial recovery.
multisigは署名能力自体を複数に分割するが, Social recoveryは署名能力は１つの鍵が持つものの, 鍵自体の有効性を複数に分割しておくことで鍵を保護する.

基本はcontractによって実現することになると思うが, custody walletの場合はその事業者のAPIとして持つこともあり得る?

とにかく, non-transferabilityを保持したまま(1)の制約を回避するためにコントラクトでこういった機能を持つことが提案されている.

### Non-transferability

一方で, この鍵のrotationで分かるように, naiveにtoken側で`transfer`を行えない実装にするだけではnon-transferabilityをもたらせない.
なぜなら, 上記のrecoveryで用いているようなwrapperを保有者が用いる可能性があり, そのコントラクトのownershipを売買することで,
実質的にtransferが可能になるから.

そのため,
- `transfer`を一定認めたトークンとして設計する. 例えば, オリジナルのownerと現在のownerが同じであることの確認手段を提供し, developerに確認するよう求める.
- コントラクトへのmintを許さない.
などの検討が必要になる.

### (Programmable) Privacy

blockchainのデータはpublicなため, 基本的に全てのネットワーク参加者により取得が可能になる.
そのためaddressの属性を表す目的のSBTにおいてはデータの参照/変更/利用に対して権限設定による管理(= *Programmable Privacy*)が１つの課題となる.

- secret + データのdigestのhashでslotを設定する
- Merkle treeを用いた直接のデータ参照の回避
- ZK proof (特にZK SNARK)によるデータの保有証明

などでonchainデータの保護自体は可能だが, こういったデータに関しては結局publicであることに変わりはない.
interfaceの互換性やgasを考えると, 基本的にはonchainに置くデータ自体をpublicで良いものに限定し,
[ceramic network](https://ceramic.network/)などを用いた[DID](https://w3c.github.io/did-core/)/[VC](https://w3c-ccg.github.io/vc-api/)
を用いた管理と併用することが望ましいと思われる. 

## まとめ

SBT自体はnon-transferであることを付加しただけのトークンになるが, その目的はonchain上のaddressに(offchain的な)属性を付与することにある.
これの実現自体は単にトークンのinterfaceの問題に見えるが, 実際にはコントラクトを用いた擬似的なtransferなど実装上の問題もある.

Privacy担保に関しても重要な論点であり, onchainでの解決に固執するのでは無く, DID/VC等の似た目的を持つ規格と併用し,

- publicの方が良いデータ (address等のidのみから参照されたほうが良いもの)に関してはSBTとして管理
- privateな方が良いデータ (保有者の承認無しで参照できない方が良いもの)に関してはVCとして管理

などonchain/offchainそれぞれの強みを活かした構成とする方が現実的と見える.
