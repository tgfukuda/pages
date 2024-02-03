---
title: "ECDSAと閾値署名"
date: 2023-12-10T11:31:09+09:00
author: "https://github.com/tgfukuda"
tags:
    - cryptography
    - dsa
categories:
    - dsa
draft: false
refs:
    - link: https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm
    - link: https://zoom-blc.com/what-is-ecdsa
    - link: https://eprint.iacr.org/2020/1390.pdf
    - link: https://eprint.iacr.org/2019/523.pdf
    - link: https://eprint.iacr.org/2011/535.pdf
    - link: https://eprint.iacr.org/2020/521
    - link: https://medium.com/toruslabs/what-distributed-key-generation-is-866adc79620
    - link: https://www.fireblocks.com/blog/gg18-and-gg20-paillier-key-vulnerability-technical-report/
    - link: https://www.secg.org/sec1-v2.pdf
    - link: https://en.bitcoin.it/wiki/Secp256k1
    - link: https://ethereum.org/en/developers/docs/data-structures-and-encoding/rlp/
    - link: https://en.bitcoin.it/wiki/Block_hashing_algorithm
    - link: https://ethereum.stackexchange.com/questions/26/what-is-a-replay-attack
    - link: https://eips.ethereum.org/EIPS/eip-155
    - link: https://eips.ethereum.org/EIPS/eip-695
    - link: https://learnmeabitcoin.com/technical/p2ms
    - link: https://en.bitcoin.it/wiki/Multi-signature
    - link: https://medium.com/silence-laboratories/a-compute-perspective-of-mpc-tss-paillier-in-ecdsa-revisited-3e7e92f4bd0a
    - link: https://www.fireblocks.com/blog/gg18-and-gg20-paillier-key-vulnerability-technical-report/
---

## ECDSA

ECDSAはBitcoin, Ethereumのトランザクションで鍵の保有者によって署名されたことの証明となる署名を担うスキーマです.
有限体上の楕円曲線を群とするDSA.

### アルゴリズム

wikiに載っている通り. 実装の[標準](https://www.secg.org/sec1-v2.pdf)も参照.

Bitcoin, Ethereumで採用されている楕円曲線は[secp256-k1](https://en.bitcoin.it/wiki/Secp256k1).
Hash関数はBitcoinではSHA256, EthereumではKeccac256.

以下では出力となる署名を$ r, s, v $, 各入力と変数を
- 秘密鍵: $ d $
- 公開鍵: $ Q = d * G $
- メッセージ: $ M $
- 楕円曲線のベースポイント: $ G $
とします.

#### 署名

1. メッセージをhashする $ m = H(M) $. 実際のメッセージのhashに当たっては, [RLP](https://ethereum.org/en/developers/docs/data-structures-and-encoding/rlp/)などの理解も必要になります.
2. 乱数$ k $を$ [1, n) $で得る. $ n $は群の位数. プレステ3の事例のように, この$ k $を異なるメッセージに対して再利用してしまうと秘密鍵がリークする.
3. $ R = k * G $を計算し, $ r = R_x \pmod n $で$ r $を得る. $ r = 0 $になったら別の$ k $でやり直し.
4. $ s = (m + r * d) / k $で$ s $を得る.

$ (r, s) $が署名になりますが, [リプレイ攻撃](https://ethereum.stackexchange.com/questions/26/what-is-a-replay-attack)を防ぐのに, $ v $をもつのがblockchainだと一般的.

計算方法はchainによりますが, [EIP-155](https://eips.ethereum.org/EIPS/eip-155)前のtxだと
$ v = 27 + (r \pmod 2) $,
採用後は$ v = chainId * 2 + 35 + (r \pmod 2) $になる.
Ethereumのmainnetは1で, https://chainid.network/ だったり, [EIP-695](https://eips.ethereum.org/EIPS/eip-695)などを使って得られる.

#### 検証

1. $ r, s $が$ [1, n) $であることの検証.
2. $ r = (ms^{-1} * G + rs^{-1}*Q)_x \pmod n $であることの検証.

[こちら]({{< ref "generic-dsa" >}})も参照.

## 閾値署名

Bitcoinにおいては[P2MS](https://learnmeabitcoin.com/technical/p2ms)などが存在し, プロトコルレベルでマルチシグに対応しているので, 複数の鍵があればそのままECDSAを閾値署名に拡張できる.
一方で, EthereumではナイーブなECDSAしか使用できないので, 鍵自体もしくは署名生成自体を分散化対応したものにしなければいけない.

### ECDSAの閾値署名スキーム

[servey](https://eprint.iacr.org/2020/1390.pdf) がよくまとまっているので参照.

- [DKLs19](https://eprint.iacr.org/2019/523.pdf)
- https://bitcointalk.org/index.php?topic=511074.20
- [SPDZ](https://eprint.iacr.org/2011/535.pdf): MPCの応用
- [GG18](https://www.fireblocks.com/blog/gg18-and-gg20-paillier-key-vulnerability-technical-report/)
    - [mpc threshold signature gg18/gg20 vulnerability](https://www.fireblocks.com/blog/gg18-and-gg20-paillier-key-vulnerability-technical-report/)で脆弱性が指摘されているので非推奨
- [Multisig2/FROST](https://bitcoin.stackexchange.com/questions/114182/how-do-musig2-and-frost-compare-for-multisig-key-aggregation-schemes)
- [SSS]({{< ref "shamir-secret-sharing" >}})を使った鍵の分割
