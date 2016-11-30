{-# LANGUAGE TupleSections #-}
module Main
where
{- Test performance of encoding against other packages -}

{-# LANGUAGE MultiParamTypeClasses ,DeriveGeneric ,DeriveDataTypeable ,ScopedTypeVariables ,GADTs ,NoMonomorphismRestriction ,DeriveGeneric ,DefaultSignatures ,TemplateHaskell ,TypeFamilies ,FlexibleContexts ,CPP #-}

-- cabal update; cabal install binary binary-bits cereal buffer-builder bytes bytestring bits

{-
Compile:
cd /Users/titto/workspace/quid2;cabal install

Run plain, measure time externally:
cd /Users/titto/workspace/quid2;cabal install;time /Users/titto/workspace/quid2/.cabal-sandbox/bin/benchsmall

cd /Users/titto/workspace/quid2;cabal install;time /Users/titto/workspace/quid2/.cabal-sandbox/bin/benchsmall +RTS -sstderr -h;hp2ps -c benchsmall

Profiling
cd /Users/titto/workspace/quid2;cabal install --enable-executable-profiling -p;/Users/titto/workspace/quid2/.cabal-sandbox/bin/benchsmall +RTS -ph -sstderr;cat benchsmall.prof;hp2ps -c benchsmall;profiteur benchsmall.prof;open file:///Users/titto/workspace/quid2/benchsmall.prof.html 

Benchmarking
cd /Users/titto/workspace/quid2;cabal install;/Users/titto/workspace/quid2/.cabal-sandbox/bin/benchsmall

Benchmarking using cbor test suite, see LEGGIMI

Profiling using eventlog:
cd /Users/titto/workspace/quid2;cabal install;time /Users/titto/workspace/quid2/.cabal-sandbox/bin/benchsmall +RTS -l;ghc-events-analyze benchsmall.eventlog;cat benchsmall.totals.txt

-}

{-
Decoding
|               | ln2 |
| binary        | 23  |
| BitEncoderE   | 23  |

DecM
|                    | treeN μs         | ln2 μs | ln3 large ms | tree3 ms| tuple μs | One ns
| new-binary Custom  | 76               |
| binary 0.7.2.2     | 48               |  83    | 150         | 177
| cereal 0.4.1.1     | 58               |        |
| quid2 "binary-bits"| 87               |        |  271          | 426
| .. getBoolFast     | 78               |        |
| .. Custom          |                  |        |
| .. DECODER_BITS    | 50               |        | 256:156-306   | 282:248-312
| .. "binary-strict" | 370              |        | 1052          | 1275
| .. Cstm BitDecoder
| DEC [1]            | 41               | 123    | 95            | 167
| DEC [2]            | [42]             | 88     | [60]          | 167
| DEC [3]            | 40               | [78]   | 132/60        | [163]
| .. DEC1            | 73               | 10     | 232:152-268   | 209:181-232
| .. runDec3         |                  |        | 256:153-300!  | 235:213-250
| .. runDec33        |                  |        | 261:194-304!  | 249:221-273
| .. runDec2         |                  |        | 266           | 238
| .. runDec22        |                  |        | 236:157-279   | 220:213-234
| .. DEC2 custom     |                  |        | 225           | 387
| .. .. Strict       | 56               | 12     |


[1] -DDEC=2 -D__INLINE -DDECODER_DATA -DGOCASES=0 -DDECODER_QUID2

[2] -DDEC=2 -D__INLINE -DDECODER_PRIM -DGOCASES=0 -DDECODER_QUID2

[3] -DDEC=2 -D__INLINE -DDECODER_GETTER -DGOCASES=0 -DDECODER_QUID2

EncDec
|                    | treeN μs| ln2 μs  | ln3 ms | IO ln3 ms | tuple μs | One ns
| new-binary Custom  | 91      | 240     | 25     |  15      | 1.7     | 388
| binary 0.7.2.2     | 57      | 164     | 16-17  |  7-8     | 1       | 562
| .. 0.7.2.3-0.7.4.0 |         |         | !105!  |
| cereal             | 70      | 190     | 16     |  8-9     | 1.2     | 493
| BitEncoderD        | 82      | 239     | 18     |  13-14   | 1.2     | 458
| BitEncoderE Custom | 74      | 201     | 18     |          | 1.2     | 439
| BitEncoderE        | 88      | 248     | 20     |          | 1.5     | 528
| BitEncoderF        |                   | 19

Enc
|                    | treeN | ln2   | ln3 ms | tuple    | One
| new-binary Custom  | 28    | 67    | 3.5    |  655     | 223
| binary 0.7.2.2     | 29    | 89-92 | 4.5    |  563-592 | 315
| cereal             | 28    | 81    | 4      |  551     | 335
| BitEncoderD        | [26]  | 69-75 | 3.8    |  357     | 224
| BitEncoderD Custom | 22-24 | 63-64 | 3.1    |  357     | 224
| BitEncoderE        | 30    | 82    | 4.3    |  585     | 242
| !BitEncoderF       | 27    | [65]  | [3.2]  |  444     | 220
| .. Custom          | 24-25 | [51]  | [2.5]  |  371     | 224
| .. Custom Strict   | 21    | 63    | [10.19]|  353     | 218
| ..Cst toBitBuilderE| 80    | [54]  | [2.86] |  431     | 214

|           | tstEnc lBool | tstEnc lN2 | tstEncodeDecode lBool | tstEncodeDecode lN2 | tstDec lN2
new-binary  | 6.8          | 65-69      | 22.7                  | 232-237             |
binary      |              | 86-88      | 13.7                  | 161-169
binary custom |            | 83-85
cereal      |              | 80-82          | 15.7              | 185-190
ByteBuilder |              | 78            | 20.8               | 236
Data.Binary.Quid2 BitEnc   | 135-141             |
.. BitEncoderF Custom       | 55-56            |
.. BitEncoderE              | 59-60                             | 230                  | 165
.. BitEncoderE Custom       | 51-53        |                    | 160-195              | 136
.. ByteEncoderF             | 121-135      |
.. ByteEncoderF Custom      | 55           |
Byte        |              | 158           | 35                  | 397-413
Byte2       |              | 187           | 37.5                | 412
Bit2 (Coding 64) | 20.8    |               |
Bit2 (Coding 8)  | 22      |               |
Bit  (BitPut orig) | 15-17 | 384           | 55                   | 831-851
Bit3 (BitPut 8)    | 14-17 | 220                                  | 664-690
Bit3 (BitPut 64)   | 15-18 | 242
-}

-- ghc -O2 --make Bench;./Bench
import Criterion.Main
import Criterion.Types
import Types
import Test.Data
import Test.Data.Values
import PkgBinary
import PkgCereal
import PkgCBOR
import PkgFlat
import PkgStore
import qualified Data.Binary.Serialise.CBOR as CBOR
import Data.ByteString.Lazy as B
import Data.ByteString as BS
import qualified Data.Text as T
import Control.Exception
import Control.Monad
import Control.Applicative
import System.Directory
import Debug.Trace (traceEventIO)

event :: String -> IO a -> IO a
event label =
  bracket_ (traceEventIO $ "START " ++ label)
           (traceEventIO $ "STOP "  ++ label)

t = mainBench

-- tl1 = [tstLen PkgBinary tree1
--       ,tstLen PkgBinary tree2
--       ,tstLen PkgBinary lBool
--       --,tstLen PkgBinary lN
--       ]

-- tl2 = [--tstLen PkgFlat tree1
--       -- ,tstLen PkgFlat tree2
--       tstLen PkgFlat lBool
--       --,tstLen PkgFlat lN
--       ]

l = [tstSize tupleT,tstSize tupleBools,tstSize tupleWords,tstSize arr0, tstSize arr1, tstSize asciiStrT,tstSize unicodeStrT,tstSize unicodeTextT , tstSize lN3T, tstSize tree3T]
-- [("tuple",(8.0,3.0,3.0)),("tupleBools",(7.0,4.5,4.5)),("tupleWord",(1.5555555555555556,3.5555555555555554,3.5555555555555554)),("[Bool]",(3.999992000032,4.000015999936,4.000015999936)),("[Word]",(1.3416352722052283,4.691580498057688,4.691580498057688)),("asciiStr",(0.8888925432066282,0.8888952098709245,3.555559506169328)),("unicodeStr",(0.9322290145814176,0.932230773922345,2.345792594816747)),("unicodeText",(0.9960948808600285,0.9960967607312449,1.2532524905160498)),("lN3",(9.41174726647702,4.70587363323851,4.70587363323851)),("tree3",(10.909087272727273,5.454543636363637,5.454543636363637))]
-- tstSize :: (CBOR.Serialise a, Flat a) => (String, a) -> (String,Double)
tstSize nv@(n,v) = (n,) $ (tstLen PkgCBOR v,tstLen PkgBinary v,tstLen PkgStore v)

tstLen:: (Serialize c a, Flat a1) => (a1 -> c a) -> a1 -> Double
tstLen k v = let l0 = lser PkgFlat v
                 l1 = lser k v
             in (l1 / l0)

-- lser :: (Serialize c1 a1) => (a -> c1 a1) -> a -> Double
lser k = fromIntegral . Prelude.length . ser . k

-- main = mainEvents
main = do
  forceCafs
  mainBench
  -- mainProfile
  -- mainAlternatives

mainEvents = mainAlternatives

-- #define PKG_BINARY

mainProfile = mapM_ (\_ -> enc arr1) [1..1000] -- mapM_ (\_ -> enc (0x34::Word) >> enc tree1 >> enc tree2) [1..10]
  where enc = evaluate . B.length . serialize . PkgFlat -- PkgBit2

mainAlternatives = dec_ tupleT >> dec_ tupleBools >> dec_ arr0 >> dec_ arr1 >> dec_ asciiStrT >> dec_ unicodeStrT >> dec_ lN3T >> dec_ tree3T -- dec_ sbs >> dec_ lbs >>
  where
    -- dec1 = evaluate . and . Prelude.map (\_ -> des) $ [1..1]
    -- des = let (Right (PkgFlat a)) = deserialize PkgFlat.serlN2 in (a == lN2)
    dec_ dt@(n,_) = event (Prelude.concat [testName,"_",n]) $ (mapM (\_ -> d dt) [1..1])
#ifdef PKG_BINARY
    d = op "binary" PkgBinary
#elif PKG_QUID2
    d = op "quid2" PkgFlat
#elif PKG_STORE
    d = op "store" PkgStore
#elif PKG_CBOR
    d = op "cbor" PkgCBOR
#endif
#if OP_DEC
    testName = "dec"
    op = decM
#elif OP_ENC
    testName = "enc"
    op _ pkg v = (evaluate . B.length . serialize . pkg $ v)
#elif OP_ENCDEC
    testName = "encDec"
    op = encDecM
#endif
--mainBench = defaultMainWith (defaultConfigFilePath {
mainBench = defaultMainWith (defaultConfig {
                                csvFile=Just "/tmp/testReport.csv"
                                ,reportFile=Just "/tmp/testReport.html"
                                ,junitFile=Just "/tmp/testReport.xml"}) [

{-
   tstEnc (0x34::Word)
  ,tstEnc (0x1289::Word)
  ,tstEnc (0x221289::Word)
  ,tstEnc (0x55221289::Word)
  ,tstEnc (0x1233456712345533::Word)

  ,tstEnc ((-120)::Int)
  ,tstEnc ((-1203321312)::Int)

   tstEnc (3.4512312::Float)
  ,tstEnc (-0.4511231232312::Double)

  ,tstEnc 'z'
  ,tstEnc '中'

  -- sequences
  ,tstEnc hl1
  ,tstEnc hl2
  ,tstEnc hl3

  ,tstEnc s1
  ,tstEnc s2
  ,tstEnc s3
  ,tstEnc s4

  ,tstEnc t1
  ,tstEnc t2
  ,tstEnc t3
  ,tstEnc t4

  ,tstEnc b1
  ,tstEnc b2
  -- ,tstEnc lb1
  -- ,tstEnc lb2

  -- generic
  -- ,tstEnc True
  -- ,tstEnc ('a','b',('c','d',('e','f','g')))
-}
  --

  -- tstEnc treeNT,tstEnc tree3T,tstEnc lN2T,tstEnc lN3T

  -- ,tstEnc oneT

  -- recursive structure  tstEnc lBool

  -- ,tstEnc tree2

  --
  -- ,tstDecM lN2T
  -- tstEncDecM lN2T,tstEncDecM lN3T
  -- tstEncDecM treeNT,tstEncDecM tree3T,tstEncDecM lN2T,tstEncDecM lN3T,
  -- tstDecM treeNT,tstDecM lN2T,tstDecM lN3T,tstDecM tree3T

  -- tstEncDecM tuple0T,tstEncDecM tupleT,
  -- tstEncDecM word8T,tstEncDecM int8T
  --tstEncDecM word64T,tstEncDecM int64T,tstEncDecM integerT,

  --tstEnc tupleT,tstEnc tupleBools,tstEnc tupleWords,tstEnc arr0, tstEnc arr1, tstEnc asciiStrT,tstEnc unicodeStrT,tstEnc unicodeTextT , tstEnc lN3T, tstEnc tree3T
  tstEncDec floatT,tstEncDec doubleT,tstEncDec tupleT,tstEncDec tupleBools,tstEncDec tupleWords,tstEncDec arr0, tstEncDec arr1, tstEncDec asciiStrT,tstEncDec unicodeStrT,tstEncDec unicodeTextT , tstEncDec lN3T, tstEncDec tree3T
  
  -- tstEncDecM tupleT,tstEncDecM tupleBools,tstEncDecM tupleWords,tstEncDecM arr0, tstEncDecM arr1, tstEncDecM asciiStrT,tstEncDecM unicodeStrT,tstEncDecM unicodeTextT , tstEncDecM lN3T, tstEncDecM tree3T
  --tstEncDecM treeNT,tstEncDecM tree3T,tstEncDecM lN2T,tstEncDecM lN3T
  -- ,tstDecM treeNT,tstDecM tree3T,tstDecM lN2T,tstDecM lN3T
  -- ,tstDecM tree3T

  --tstED lN3T,tstED tree3T

  --,tstEncDecM treeNT
{-
  ,tstEncDec treeN
  ,tstEncDec lN2
  ,tstEncDec lN3
  ,tstEncDec (Two,One,(Five,Three,(Three,(),Two)))
  ,tstEncDec One
-}
 -- ,tstEncodeDecode "BEPkg" BEPkg,  tstEncodeDecode "PkgCBOR" PkgCBOR
{-
  ,tstEncodeDecode "PkgBinary" PkgBinary
  -- ,tstEncodeDecode "PkgCereal" PkgCereal
  ,tstEncodeDecode "PkgFlat" PkgFlat
  -- ,tstEncodeDecode "PkgByte" PkgByte
  -- ,tstEncodeDecode "PkgByte2" PkgByte2
  -- ,tstEncodeDecode "PkgBit" PkgBit
  -- ,tstEncodeDecode "PkgBit2" PkgBit2
-}
{-
  ,tstEncodeDeep "BEPkg" BEPkg BEPkg
  ,tstEncodeDeep "PkgBinary" PkgBinary PkgBinary
  ,tstEq
-}
  ]

tstED t = bgroup ("tstEncDecsM") [tstEnc t
                                 --,tstEncM t
                                 ,tstDecM t
                                 ,tstEncDecM t,tstEncDec t]

tstEncDecM lv@(vn,v) =
  bgroup ("tstEncDecM") [
              tst "quid2" PkgFlat
             ,tst "cbor" PkgCBOR
             -- ,tst "new-binary" BEPkg
             ,tst "binary" PkgBinary
             ,tst "store" PkgStore
             --,tst "cereal" PkgCereal
             ]
      where
        tst n c = bench (unwords[n,vn]) $ nfIO (encDecM n c lv)


df n vn = Prelude.concat["/Users/titto/workspace/flat/benchmarks/data/tstEncDec-",vn,"-",n]

encDecM n c (vn,v) = do
          let f = df n vn
          B.writeFile f . serialize . c $ v
          rs <- deserialize . B.fromStrict <$> BS.readFile f
          -- print rs
          let Right r = rs
          when (r /= c v) $ dataErr f
          -- r <- BS.readFile f
          -- evaluate (BS.length r)
          -- evaluate (B.length . serialize . c $ v)

decM n c (vn,v) = do
          let f = df n vn
          Right r <- deserialize . B.fromStrict <$> BS.readFile f
          when (r /= c v) $ dataErr f

dataErr f = error . unwords $ ["Data mismatch on",f]

tstEncM (vn,v) =
  bgroup ("tstEncM") [
              tst "quid2" PkgFlat
             -- tst "new-binary" BEPkg
             ,tst "binary" PkgBinary
             --,tst "cereal" PkgCereal
             ]
      where
        tst n c = bench (unwords[n,vn]) $ nfIO (rw n c)
        rw n c = do
          let f = df n vn
          removeFile f
          B.writeFile f . serialize . c $ v
          -- Right r <- deserialize . B.fromChunks . (:[]) <$> BS.readFile f
          -- when (r /= c v) $ print "Data mismatch"
          r <- BS.readFile f
          evaluate (BS.length r)
          -- print $ BS.length r
          -- evaluate (B.length . serialize . c $ v)

tstDecM d@(vn,v) =
  bgroup ("tstDecM") [
              tst "quid2" PkgFlat
             -- ,tst "new-binary" BEPkg
             ,tst "cbor" PkgCBOR
             ,tst "binary" PkgBinary
--             ,tst "binary-strict" PkgBinaryStrict
             --,tst "cereal" PkgCereal
             ]
      where
        tst n c = bench (unwords[n,vn]) $ nfIO (decM n c d)

{-
        rw n c = do
          let f =
          Right r <- deserialize . B.fromStrict <$> BS.readFile f
          when (r /= c v) $ print "Data mismatch"
          -- r <- BS.readFile f
          -- when (BS.length r < 0) $ print "Data mismatch"
-}

tstEncDec (vn,v) = let nm s = unwords[s,vn] -- unwords [s,Prelude.take 400 $ show v]
 in bgroup ("tstEncDec") [
  bench (nm "flat")   $ nf (encodeInverseOfDecode PkgFlat) v
  ,bench (nm "cbor") $ nf (encodeInverseOfDecode PkgCBOR) v
  ,bench (nm "binary") $ nf (encodeInverseOfDecode PkgBinary) v
  ,bench (nm "store") $ nf (encodeInverseOfDecode PkgStore) v
  --,bench (nm "cereal")     $ nf (encodeInverseOfDecode PkgCereal) v
  ]

encodeInverseOfDecode k v = let x = k v
                                Right r = (deserialize . serialize) x
                            in x == r

tstEnc (vn,v) =
  let nm s = Prelude.concat [s,"-",vn] -- unwords [s,Prelude.take 400 $ show v]
  in bgroup ("tstEnc") [
    bench (nm "flat")  $ nf (encodeOnly PkgFlat) v
    ,bench (nm "cbor")     $ nf (encodeOnly PkgCBOR) v
    ,bench (nm "binary")     $ nf (encodeOnly PkgBinary) v
    ,bench (nm "store")     $ nf (encodeOnly PkgStore) v
    ]
  where encodeOnly k = B.length . serialize . k

tstEncodeDeep name k1 k2 = bgroup ("serialize " ++ name) [
   bench "tree1"  $ nf (encodeOnly k1) tree1
  ,bench "tree2" $ nf (encodeOnly k2) tree2
  ]
  where encodeOnly k = B.length . serialize . k

tstDec = bgroup ("tstDec") [
  bench "Binary lN2" $ nf (\v -> let Right (PkgBinary a) = deserialize PkgBinary.serlN2 in a == v) lN2
  ,bench "Quid2 lN2" $ nf (\v -> let Right (PkgFlat a) = deserialize PkgFlat.serlN2 in a == v) lN2
  ]

tstEncodeDecode name k1 = bgroup ("serialize+deserialise " ++ name) [
  -- bench "tree1" $ whnf (encodeInverseOfDecode k1) tree1
  --,bench "tree2" $ whnf (encodeInverseOfDecode k2) tree2
   -- ,bench "car1" $ whnf encodeInverseOfDecode car1
   bench "lN2" $ nf (encodeInverseOfDecode k1) lN2
  ,bench "lN3" $ nf (encodeInverseOfDecode k1) lN3
  -- bench "treeN" $ nf (encodeInverseOfDecode k1) treeN
  ]

-- dec p b v = let (Right p) = deserialize b in (unPkg p == v)

-- encodeInverseOfDecode :: (Serialize a, Eq a) => (t -> a) -> t -> Bool
{-
tstEq = bgroup ("equal") [
  bench "lBool" $ whnf eq lBool
  ,bench "tree1" $ whnf eq tree1
  ,bench "tree2" $ whnf eq tree2
  ,bench "car1" $ whnf eq car1
  ]
-}

eq v = (v == v) == True