module Model.ProjectSignup.Internal where
import Prelude
import Database.Persist.TH

data ProjectType = Art | CreativeWriting | Education | Journalism | Music | Software | Research | Video | OtherProjectType deriving (Read, Show, Eq, Ord, Bounded, Enum)
derivePersistField "ProjectType"
