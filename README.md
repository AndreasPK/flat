
Haskell implementation of [Flat](http://quid2.org), a minimalist binary data format ([specs](http://quid2.org/docs/Flat.pdf)).

### How To Use It For Fun and Profit

Flat is a binary data format, similar to `binary` or `cereal`.

To (de)serialise a data type, make it an instance of the `Flat` class.

Instances for a few common data types (Bool,Tuples, Lists, String, Text ..) are already defined (in `Data.Flat.Instances`):

There is `Generics` based support to automatically derive instances of additional types.

Let's see some code.

Setup a couple of extensions:

```haskell
{-# LANGUAGE DeriveGeneric, DeriveAnyClass, NoMonomorphismRestriction #-}
```

Import the Flat library:

```haskell
import Data.Flat
import Data.Flat.Pretty
```

Define a couple of custom data types, deriving `Generic` and `Flat`:

```haskell
data Direction = North | South | Center | East | West deriving (Show,Generic,Flat)
data List a = Nil | Cons a (List a) deriving (Show,Generic,Flat)
```

Define a utility function: `bits` encodes the value, `prettyShow` displays it nicely:

```haskell
p = prettyShow . bits
```

Some encodings:

```haskell
p West
"111"
```

```haskell
p (Nil::List Direction)
"0"
```

```haskell
aList = Cons North (Cons South (Cons Center (Cons East (Cons West Nil))))
p aList
"10010111 01110111 10"
```

These encodings shows a pecularity of Flat, it uses an optimal bit-encoding rather than the usual byte-oriented one (so that `aList` fits in less than 3 bytes rather than 11).

For the serialisation to work with byte-oriented devices, we need to add some padding, this is done automatically by the function `flat`:

```haskell
f :: Flat a => a -> String
f = prettyShow . flat
```

```haskell
f West
"11100001"
```

```haskell
f (Nil::List Direction)
"00000001"
```

```haskell
f $ Cons North (Cons South (Cons Center (Cons East (Cons West Nil))))
"10010111 01110111 10000001"
```

The padding is a sequence of 0s terminated by a 1 (why? check the [specs](http://quid2.org/docs/Flat.pdf)) running till the next byte boundary.

For decoding, use `unflat`:

```haskell
unflat . flat $ Cons North (Cons South Nil) :: Decoded (List Direction)
Right (Cons North (Cons South Nil))
```

### Installation

It is not yet on [hackage](https://hackage.haskell.org/) but you can still use it in your [stack](https://docs.haskellstack.org/en/stable/README/) projects by adding a reference to its github location under the 'packages' section:

````
packages:
- location:
   git: https://github.com/tittoassini/flat
   commit: 3ae580d
````

### Compatibility

Tested with [ghc](https://www.haskell.org/ghc/) 7.10.3 and 8.0.1.

### Known Bugs and Infelicities

* Encoding and decoding of String/Text is very slow
* Messy source code
* Contains code 'lifted' and modified from the binary-bits package

-----
[Source code](https://github.com/tittoassini/flat/blob/master/src/README.lhs)
