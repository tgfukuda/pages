---
title: "Generic DSA"
date: 2023-12-10T11:58:18+09:00
author: "https://github.com/tgfukuda"
tags:
    - cryptography
    - dsa
categories:
    - dsa
draft: true
refs:
    - link: https://citeseerx.ist.psu.edu/document?repid=rep1&type=pdf&doi=31802861a53d62ba4af1584344ad1fc0c8103886
    - link: https://eprint.iacr.org/2019/114.pdf
    - link: https://eprint.iacr.org/2016/013.pdf
    - link: https://ocw.snu.ac.kr/sites/default/files/NOTE/1c-dlp-ecdsa.pdf
    - link: https://www.rfc-editor.org/rfc/rfc6979
    - link: https://en.wikipedia.org/wiki/Chinese_remainder_theorem
    - link: https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm
    - link: https://en.bitcoin.it/wiki/Secp256k1
    - link: https://en.bitcoin.it/wiki/Elliptic_Curve_Digital_Signature_Algorithm
---

# Generic DSA

G-DSA (Generic Digital Signature Algorithm)はSchnorr署名,
Elgamal署名などに基づき, 一般の群に対するDLPをセキュリティの根拠にするDSA.
RSAは異なるもののECDSA, EdDSAなどはこれの亜種になるので簡単にまとめておきます.

## Security: DLP

任意の巡回群$ G $とその生成元$ g $に対して, $ h \in G $が与えられたときに$ g^k \equiv h $なるkを求める問題.
この問題は常に難しいわけではないものの,
$ G $によっては難しい(=効率的なアルゴリズムが無いと思われている)ため,
その難しさを仮定してDSAのセキュリティの根拠として採用しています.

## Key Generation

**公開情報**:

- 長さ$ l $($ l \equiv 0 \pmod{64} \land 512 \leq l \leq 1024 $)の素数$ p $
- 160bitの$ p-1 $の素因数$ q $
- $ \mathbb{Z}_p $上の位数$ q $の巡回群$ G $とその生成元$g$
- メッセージの集合$ M $として, ２つのhash関数$ H \in M \mapsto \mathbb{Z}_q, H' \in G \mapsto \mathbb{Z}_q $

**秘密鍵**: 一様にランダムな$ x \in \mathbb{Z}_q $の秘密鍵$ x $

**公開鍵**: $ G \ni y = g^x $

ただし, 多くのアルゴリズムでこの条件のみでは不十分で, 群の性質を用いた攻撃を避けるための工夫がなされていることが多い.

## Signature Algorithm

任意のメッセージ$ m \in M $に対して, hash値$ H(m) $を計算します.
乱数$ k \in \mathbb{Z}_q $を用意し, $ r = H'(R) $,$ R = g^k $と
$ s \equiv k^{-1}(H(m) + xr) \pmod q $を計算します. pair ($ r, s $)が署名になります.

$k, k^{-1}$はsymmetricで扱いやすい方で定義されるので, 署名によってそれぞれを入れ替えた定義になっている可能性に注意.

### $ k $の役割

$ k $は相異なるメッセージ$ m, m' $に対して署名値$ (r, s), (r', s') $が得られた場合に,
鍵がリークすることを防ぐ目的で組み込まれている.

同一の$ k $で$ s - s' $を計算すると,
$$
\begin{aligned}
s - s' &= k^{-1}(H(m) + xr) \pmod q - k^{-1}(H(m') + xr) \pmod q \\
&= k^{-1}((H(m) + xr) - (H(m') + xr)) \pmod q \\
&= k^{-1}(H(m) - H(m')) \pmod q
\end{aligned}
$$

$ H(m) - H(m') \in \mathbb{Z}_q $であり, $ H(m), H(m') $は公開情報から計算できて, $ k^{-1} = (s - s')(H(m) - H(m'))^{-1} \pmod q $で計算できるので,
$ x = r^{-1}(sk - H(m)) \pmod q $が計算できてしまう.

{{< notice info >}}
同一のメッセージに対しては同じ$ k $を用いても問題無い
($H(m) - H(m') \equiv 0 \pmod q$になる)ので,
[RFC 6979](https://www.rfc-editor.org/rfc/rfc6979)やEdDSAなどのように決定的に$ k $を計算するスキームもある.
{{< /notice >}}

## Verification Algorithm

$ M, (r, s), y $に対して,

1. $ r, s \in \mathbb{Z}_q $
2. $ R' = g^{H(m)s^{-1} \pmod{q}}y^{rs^{-1} \pmod q} \in G $を計算して, $ H'(R') = r $だったら受理

これは
$$
\begin{aligned}
R' &= g^{H(m)s^{-1} \pmod q}y^{rs^{-1} \pmod q} \\
&= g^{H(m)s^{-1} \pmod q}g^{xrs^{-1} \pmod q} \\
&= g^{H(m)s^{-1} + xrs^{-1} \pmod q} \\
&= g^{(H(m) + xr)s^{-1} \pmod q} \\
&= g^{kk^{-1}(H(m) + xr)s^{-1} \pmod q} \\
&= g^{kss^{-1} \pmod q} \\
&= g^{k} \\
&= R
\end{aligned}
$$
で$ H'(R') = r $なら署名が正しいことが言える.

{{< hr >}}

# ECDSA

ECDSAがG-DSAとしてどう当てはまるかを[secp256k1](https://en.bitcoin.it/wiki/Secp256k1)でみると,
- $ l $: $ 2^{256} - 2^{32} - 2^9 - 2^8 - 2^7 - 2^6 - 2^4 - 1 $
- $ G $: 有限体上の楕円曲線$ y^2 = x^3 + 7 $の点の集合とその点の加算で定義される群
- $ q $: 0xFFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE BAAEDCE6 AF48A03B BFD25E8C D0364141
- $ H $: SHA256, $ H' $: 各点からx座標への射

{{< hr >}}

# 補足

{{< accordion "中国剰余定理(CRT)と拡張ユークリッドを用いた$ \mathbb{Z}_p $上の逆元計算をGPTに説明させたやつ" close >}}
## Calculating the Inverse using Chinese Remainder Theorem

1. **Prime Factorization:**
   Start by factoring the modulus $ p $ into its prime factors. If $ p $ is a prime number, then its only prime factor is itself. Let $ p = p_1 \times p_2 \times \ldots \times p_k $, where $ p_1, p_2, \ldots, p_k $ are the prime factors of $ p $.

2. **Compute Partial Modular Inverses:**
   For each prime factor $ p_i $, compute the modular inverse $ x_i $ of $ a $ modulo $ p_i $:
   $$ a \cdot x_i \equiv 1 \pmod{p_i} $$

3. **Apply Chinese Remainder Theorem:**
   Use the CRT to combine the partial modular inverses $ x_i $ into a single value $ x $ that is the modular inverse of $ a $ modulo $ p $:
   $$ x \equiv \sum_{i=1}^{k} a_i \cdot x_i \cdot y_i \pmod{p} $$
   where $ a_i = \frac{p}{p_i} $, and $ y_i $ is the modular inverse of $ a_i $ modulo $ p_i $.

4. **Final Result:**
   The value $ x $ obtained from step 3 is the modular inverse of $ a $ modulo $ p $.

It's important to note that the Chinese Remainder Theorem can only be applied when the moduli $ p_i $ are pairwise coprime, and the existence of an inverse depends on whether $ a $ is relatively prime to $ p $. If $ gcd(a, p) = 1 $, then $ a $ has an inverse modulo $ p $.

## Compute Partial Modular Inverses using Extended Euclidean Algorithm

For each prime factor $ p_i $, compute the modular inverse $ x_i $ of $ a $ modulo $ p_i $ using the Extended Euclidean Algorithm:

1. **Extended Euclidean Algorithm:**
   The Extended Euclidean Algorithm finds the coefficients $ x $ and $ y $ such that $ ax + by = \text{gcd}(a, b) $. In our case, $ a $ is the modulus $ p_i $ and $ b $ is the element $ a $.

   The algorithm proceeds as follows:
   - Initialize $ r_1 = a $, $ r_2 = b $, $ x_1 = 1 $, $ x_2 = 0 $, $ y_1 = 0 $, $ y_2 = 1 $.
   - Iterate until $ r_n $ is zero:
     - $ q_n = \lfloor \frac{r_{n-2}}{r_{n-1}} \rfloor $
     - $ r_n = r_{n-2} - q_n \cdot r_{n-1} $
     - $ x_n = x_{n-2} - q_n \cdot x_{n-1} $
     - $ y_n = y_{n-2} - q_n \cdot y_{n-1} $

2. **Modular Inverse:**
   After completing the Extended Euclidean Algorithm, if the greatest common divisor $ r_n $ is 1, then $ x_{n-1} $ is the modular inverse of $ a $ modulo $ p_i $.

   The modular inverse $ x_i $ satisfies the equation:
   \[a \cdot x_i \equiv 1 \pmod{p_i}\]

3. **Repeat for Each Prime Factor:**
   Repeat the Extended Euclidean Algorithm for each prime factor $ p_i $ to obtain the partial modular inverses $ x_i $ for all $ i $.


{{< /accordion >}}
