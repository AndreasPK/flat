{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PackageImports        #-}
module PkgFlat(PkgFlat(..),Flat,serlN2) where

import           Control.Exception
import           Data.ByteString.Lazy   as L
import           Data.Flat
import           Test.Data
import           Test.Data.Values
import Types

data PkgFlat a = PkgFlat a deriving (Eq,Show)

instance Arbitrary a => Arbitrary (PkgFlat a) where arbitrary = fmap PkgFlat arbitrary

instance Flat a => Serialize PkgFlat a where
  serialize (PkgFlat a) = flat a
  deserialize = either (Left . error) (Right . PkgFlat) . unflat
  pkg = PkgFlat
  unpkg (PkgFlat a) = a

instance Flat N
instance Flat a => Flat (List a)
instance Flat a => Flat (Tree a)
instance Flat Car
instance Flat Acceleration
instance Flat Consumption
instance Flat CarModel
instance Flat OptionalExtra
instance Flat Engine

s = L.unpack $ flat $ lN2

serlN2 = L.pack [5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,5,51,130,153,193,76,224,166,112,83,56,41,156,20,206,10,103,129]