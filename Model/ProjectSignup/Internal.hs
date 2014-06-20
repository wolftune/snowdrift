module Model.ProjectSignup.Internal where
import Prelude
import Database.Persist.TH

data ProjectType = Software | Music | Video | Book | Art | Research deriving (Read, Show, Eq, Ord, Bounded, Enum)
derivePersistField "ProjectType"

data LicenseClassificationType = CopyLeft | CopyFree | NonFree deriving (Read, Show, Eq, Ord, Bounded, Enum)
derivePersistField "LicenseClassificationType"

data LicenseProjectType = SoftwareLicense | NonSoftwareLicense | AnyLicense deriving (Read, Show, Eq, Ord, Bounded, Enum)
derivePersistField "LicenseProjectType"

data LegalStatus = Unincorporated | CoopNonProfit | OtherNonProfit | BenefitCorp | ForProfit deriving (Read, Show, Eq, Ord, Bounded, Enum)
derivePersistField "LegalStatus"
