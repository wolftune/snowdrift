module Model.ProjectSignup where

import Model.ProjectSignup.Internal
import Import
import Data.List as L
import Data.Text as T

getProjectTypeLabel :: ProjectType -> Text
getProjectTypeLabel pt = case pt of
                            Art -> "Art"
                            CreativeWriting -> "Creative Writing"
                            Education -> "Education Material"
                            Journalism -> "Journalism"
                            Music -> "Music"
                            Software -> "Software"
                            Research -> "Scientific Research"
                            Video -> "Video"
                            OtherProjectType -> "Other"

getProjectTypes :: [(Text, ProjectType)]
getProjectTypes = L.map (getProjectTypeLabel &&& id) ([minBound .. maxBound] :: [ProjectType])
