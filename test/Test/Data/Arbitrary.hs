{-# LANGUAGE TemplateHaskell #-}
module Test.Data.Arbitrary where

import           Data.DeriveTH
import           Test.Tasty.QuickCheck
import qualified Data.ByteString       as B
import qualified Data.ByteString.Lazy  as L
import qualified Data.Text             as T
import Test.Data

-- xxx = generate (arbitrary :: Gen (Large (Int)))

instance Arbitrary B.ByteString where arbitrary   = fmap B.pack arbitrary

instance Arbitrary L.ByteString where arbitrary   = fmap L.pack arbitrary

instance Arbitrary T.Text where arbitrary   = fmap T.pack arbitrary

-- instance Arbitrary a => Arbitrary (List a) where arbitrary = fmap l2L arbitrary

derive makeArbitrary ''N

derive makeArbitrary ''Tree

derive makeArbitrary ''List

derive makeArbitrary ''Unit

derive makeArbitrary ''Un

derive makeArbitrary ''A

derive makeArbitrary ''B

-- instance Arbitrary Word7 where arbitrary  = toEnum <$> choose (0, 127)
-- derive makeArbitrary ''ASCII

