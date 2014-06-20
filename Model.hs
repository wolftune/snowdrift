{-# LANGUAGE TypeSynonymInstances, FlexibleInstances #-}

module Model where

import Prelude
import Yesod
import Yesod.Auth.HashDB (HashDBUser (..))
import Data.Text (Text)
import Database.Persist.Quasi
import Data.Typeable (Typeable)
import Data.ByteString (ByteString)

import Data.Time.Clock (UTCTime)
import Data.Int (Int64)

import Model.Currency (Milray)
import Model.Role.Internal (Role)
import Model.ClosureType.Internal (ClosureType)
import Model.Permission.Internal (PermissionLevel)
import Model.Markdown.Diff (MarkdownDiff)
import Model.ViewType.Internal (ViewType)
import Model.Settings.Internal (UserSettingName)
import Model.ProjectSignup.Internal (ProjectType) 
import Model.License.Internal (LicenseClassificationType, LicenseProjectType, LegalStatus)

import Yesod.Markdown (Markdown)

import Control.Exception (Exception)

-- You can define all of your database entities in the entities file.
-- You can find more information on persistent and how to declare entities
-- at:
-- http://www.yesodweb.com/book/persistent/
share [mkPersist sqlOnlySettings, mkMigrate "migrateAll"]
    $(persistFileWith lowerCaseSettings "config/models")

instance HashDBUser User where
    userPasswordHash = userHash
    userPasswordSalt = userSalt
    setSaltAndPasswordHash salt hash user = user { userHash = Just hash, userSalt = Just salt }

data DBException = DBException deriving (Typeable, Show)

instance Exception DBException where

generateFieldSettings :: Text -> [(Text, Text)] -> FieldSettings a
generateFieldSettings name attrs = FieldSettings { fsLabel = SomeMessage name
                                                 , fsTooltip = Just (SomeMessage name)
                                                 , fsName = Just name
                                                 , fsId = Just name
                                                 , fsAttrs = attrs
                                                 }
