module Model.License.Internal where
import Prelude
import Database.Persist.TH


data LicenseClassificationType = CopyLeft | CopyFree | OtherClassification deriving (Read, Show, Eq, Ord, Bounded, Enum)
derivePersistField "LicenseClassificationType"

data LicenseProjectType = SoftwareLicense | NonSoftwareLicense | AnyLicense deriving (Read, Show, Eq, Ord, Bounded, Enum)
derivePersistField "LicenseProjectType"

data LegalStatus = Unincorporated | CoopNonProfit | OtherNonProfit | BenefitCorp | ForProfit deriving (Read, Show, Eq, Ord, Bounded, Enum)
derivePersistField "LegalStatus"
