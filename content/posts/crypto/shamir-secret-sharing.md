---
title: "Shamir Secret Sharing"
date: 2024-01-14T17:23:56+09:00
author: "https://github.com/tgfukuda"
tags:
    - cryptography
categories: []
draft: false
refs:
    - link: https://en.wikipedia.org/wiki/Shamir's_secret_sharing
    - link: https://eprint.iacr.org/2020/1390.pdf
    - link: https://eprint.iacr.org/2016/194.pdf
    - link: https://en.wikipedia.org/wiki/Lagrange_polynomial
    - link: https://eprint.iacr.org/2021/1397
    - link: https://en.wikipedia.org/wiki/Commitment_scheme
    - link: https://medium.com/toruslabs/what-distributed-key-generation-is-866adc79620
---

## SSS

SSS(Shamir Secret Sharing Scheme)はt-of-nの秘密分散を達成するスキームで, つまりsecret(例えば秘密鍵)をn個のshareに分け,
t個のshareが集まった場合のみに元のデータが復元できるようにする方法の１つです.

### アイデア

SSSは

- 次数$ t $の多項式$ f(x) $は$ t + 1 $個の点$ (i, f(i)) $が与えられた場合に復元可能

ということを利用してsecretを分割します
([ラグランジュ補完](https://en.wikipedia.org/wiki/Lagrange_polynomial)も参考).

secretを$ a_0 $とするとき, dealer(秘密を分散する人)は
$ f(x) = a_0 + a_1x + \cdots + a_tx^t $として, $ i = 1, \ldots, n $を代入し, 各$ (1, f(1)), (2, f(2)), \ldots, (n, f(n)) $を各shareとします.

元の$ f(x) $は$ t + 1 $点が集まった場合のみ復元でき, secretは$ f(0) $から得られます.

#### 受け取った値の検証

dealerはDLPの定義される群$ \mathbb{G} $とその生成元$ G $を使って,
$ A_k = a_k \cdot G $を各partyに送ることで,
$$
\begin{aligned}
\sum^t_{k=0} A_k \cdot i^k &= (\sum^t_{k=0} a_k \cdot i^k) \cdot G \\
&= f(i) \cdot G
\end{aligned}
$$
で$ f(x) $上の点$ (i, f(i)) $であることの確認ができます.

### DealerなしのVerifiableなSSS

dealerありでのSSSSは秘密の分散が目的にもかかわらず,
dealerはsecretを知っていなければならないという問題がありますが,
実際にはdealerなしで,
各partyがprotocolに従ったことの検証を含む形での実行が可能です
(Verifiable Secret Sharing, [VSS](https://eprint.iacr.org/2021/1397)).

具体的には各partyがdealerの役割を行い, それぞれから送られてきたshareの和をshareとすることになります.
$ P_0, P_1, \ldots, P_n $でshareを分割することをベースに説明します.

0. secretの初期化. $ P_i $は$ x_i $をランダムに生成します. [commitment scheme](https://en.wikipedia.org/wiki/Commitment_scheme)などでその正当性を担保します.
1. $ x_i $に対して各$ P_i $は$ f_i(x) $を生成し, $ A^j_i, f_i(j) $を$ P_j $に対して送り, $ P_j $は渡されたshareが$ f_i(j) $であることを確かめます.

この状態で各$ P_i $は手元に
- 自身で生成したsecretの一部$ x_i $と自身で生成した関数の一点$ f_i(i) $
- 各$ P_j $から送られてきたshare $ f_j(i) $とその担保$ A^i_j $

を持つことになります.

secretを$ x = x_0 + x_1 + \cdots + x_n $, 多項式を$ f(x) = \sum^n_{k=0} f_k(x) $とすれば,それらを各partyは知らない一方で,
自身のshareを$ (i, \sum^n_{k=0} f_k(i)) $としてSSSに参加できます.

これを用いて, Distributed Key Generation([DKG](https://medium.com/toruslabs/what-distributed-key-generation-is-866adc79620))などが達成できます.
