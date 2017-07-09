{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import Crowdmatch
import RunPersist

-- NB! The string passed to runPersistKeter must match the APPNAME used in
-- keter.sh to deploy the app. Must fix.
main :: IO ()
main = runPersistKeter "SnowdriftReboot" crowdmatch
