module Model.ProjectSignup where

import Model.ProjectSignup.Internal
import Import
import Data.List as L
import Data.Text as T

getProjectTypes :: [(Text, ProjectType)]
getProjectTypes = L.map (T.pack . show &&& id) ([minBound .. maxBound] :: [ProjectType])

getLicenseClassificationTypes :: [(Text, LicenseClassificationType)]
getLicenseClassificationTypes = L.map (T.pack . show &&& id) ([minBound .. maxBound] :: [LicenseClassificationType])

getLicenseProjectTypes :: [(Text, LicenseProjectType)]
getLicenseProjectTypes = L.map (getLicenseProjectLabel &&& id) ([minBound .. maxBound] :: [LicenseProjectType])

getLicenseProjectLabel :: LicenseProjectType -> Text
getLicenseProjectLabel x = case x of
                              SoftwareLicense -> "Software License"
                              NonSoftwareLicense -> "Non-Software License"
                              AnyLicense -> "Software & Non-Software License"


getLegalStatuses :: [(Text, LegalStatus)]
getLegalStatuses = L.map (getLegalStatusLabel &&& id) ([minBound .. maxBound] :: [LegalStatus])

getLegalStatusLabel :: LegalStatus -> Text
getLegalStatusLabel x = case x of
                            Unincorporated -> "Unincorporated"
                            CoopNonProfit -> "Cooperative Non-Profit"
                            OtherNonProfit -> "Other Non-Profit"
                            BenefitCorp -> "Benefit Corporation"
                            ForProfit -> "For Profit"


getLicenses :: SqlPersistT Handler [Entity License]
getLicenses = selectList [] [Asc LicenseName]

getLicenseLabels :: [Entity License] -> [(Text, LicenseId)]
getLicenseLabels l = L.map ((licenseName . entityVal) &&& entityKey) l
