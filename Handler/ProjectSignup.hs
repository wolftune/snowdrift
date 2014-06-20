module Handler.ProjectSignup where

import Import

import Model.ProjectSignup

projectSignupForm :: Html -> MForm Handler (FormResult ProjectSignup, Widget)
projectSignupForm _ = do
    licenses <- lift $ runDB getLicenses

    (projectNameRes, projectNameView) <- mreq textField (generateFieldSettings "Project Name" [("class", "form-control"), ("placeholder", "Project Name")]) Nothing
    (projectWebsiteRes, projectWebsiteView) <- mopt textField (generateFieldSettings "Website" [("class", "form-control"), ("placeholder", "Project Website")]) Nothing
    (projectTypeRes, projectTypeView) <- mreq (multiSelectFieldList getProjectTypes) (generateFieldSettings "Project Type" [("class", "form-control"), ("placeholder", "Project Type(s)")]) Nothing
    (projectLicenseRes, projectLicenseView) <- mreq (multiSelectFieldList $ getLicenseLabels licenses) (generateFieldSettings "License" [("class", "form-control"), ("placeholder", "Select License(s)")]) Nothing
    (projectLocationRes, projectLocationView) <- mreq textField (generateFieldSettings "Location" [("class", "form-control"), ("placeholder", "Location Project is legally based out of")]) Nothing
    (projectLegalStatusRes, projectLegalStatusView) <- mreq (selectFieldList getLegalStatuses) (generateFieldSettings "Legal Status" [("class", "form-control"), ("placeholder", "Legal Status of Project")]) Nothing
    (projectLegalStatusCommentsRes, projectLegalStatusCommentsView) <- mopt textField (generateFieldSettings "Legal Status Comments" [("class", "form-control"), ("placeholder", "Additional Comments about Legal Status")]) Nothing
    (projectMissionRes, projectMissionView) <- mreq textareaField (generateFieldSettings "Mission" [("class", "form-control"), ("placeholder", "Describe your project's vision and mission")]) Nothing
    (projectGoalsRes, projectGoalsView) <- mreq textareaField (generateFieldSettings "Goals" [("class", "form-control"), ("placeholder", "Describe your project's short-term and long-term goals and deliverables")]) Nothing
    (projectFundsRes, projectFundsView) <- mreq textareaField (generateFieldSettings "Funds" [("class", "form-control"), ("placeholder", "Describe how your project will benefit from and make use of funds raised through Snowdrift.coop")]) Nothing

    let projectSignupRes = ProjectSignup 
                <$> projectNameRes 
                <*> projectWebsiteRes
                <*> projectTypeRes
                <*> projectLicenseRes
                <*> projectLocationRes
                <*> projectLegalStatusRes
                <*> projectLegalStatusCommentsRes
                <*> projectMissionRes
                <*> projectGoalsRes 
                <*> projectFundsRes
    let widget = toWidget $(widgetFile "project_signup")
    return (projectSignupRes, widget)


getProjectSignupR :: Handler Html
getProjectSignupR = do
    ((form, widget), enctype) <- runFormGet projectSignupForm 
    defaultLayout $ do
        setTitle "Project Signup Form | Snowdrift.coop"
        [whamlet|
            <form method=POST enctype=#{enctype}>
                ^{widget}
                <input type=submit>
        |]

postProjectSignupR :: Handler Html
postProjectSignupR = do
    ((result, form), _) <- runFormPost $ projectSignupForm 
    defaultLayout $ [whamlet|<H1>Thank you!|]
