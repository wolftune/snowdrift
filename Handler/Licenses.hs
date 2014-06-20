module Handler.Licenses where

import Import
import Model.ProjectSignup

licenseEntryForm :: Html -> MForm Handler (FormResult License, Widget)
licenseEntryForm _ = do
    (licenseNameRes, licenseNameView) <- mreq textField (generateFieldSettings "LicenseName" [("class", "form-control"), ("placeholder", "License Name")]) Nothing
    (licenseClassificationRes, licenseClassificationView) <- mreq (selectFieldList getLicenseClassificationTypes) (generateFieldSettings "Classification" [("class", "form-control"), ("placeholder", "License Classification")]) Nothing
    (licenseProjectTypeRes, licenseProjectTypeView) <- mreq (selectFieldList getLicenseProjectTypes) (generateFieldSettings "ProjectType" [("class", "form-control"), ("placeholder", "Project Type")]) Nothing
    (licenseOptionsRes, licenseOptionsView) <- mopt textareaField (generateFieldSettings "Options" [("class", "form-control"), ("placeholder", "License Options")]) Nothing
    (licenseWebsiteRes, licenseWebsiteView) <- mreq textField (generateFieldSettings "Website" [("class", "form-control"), ("placeholder", "Web Link to Legal Text")]) Nothing
--     (licenseIconRes, licenseIconView) <- mopt textField (generateFieldSettings "UploadIcon" [("class", "form-control"), ("placeholder", "Future Icon Upload - Leave blank for now")]) Nothing

    let licenseEntryRes = License
                        <$> licenseNameRes
                        <*> licenseClassificationRes
                        <*> licenseProjectTypeRes
                        <*> licenseOptionsRes
                        <*> licenseWebsiteRes
                        -- <*> licenseIconRes
    let widget = toWidget $(widgetFile "license_entry")
    return (licenseEntryRes, widget)

getLicenseEntryR :: Handler Html
getLicenseEntryR = do
    ((form, widget), enctype) <- runFormGet licenseEntryForm
    defaultLayout $ do
        setTitle "License Entry | Snowdrift.coop"
        [whamlet|
            <form method=POST enctype=#{enctype}>
                ^{widget}
                <input type=submit>
        |]

postLicenseEntryR :: Handler Html
postLicenseEntryR = do
    ((result, form), _) <- runFormPost $ licenseEntryForm
    defaultLayout $ [whamlet|<H1>Thank you!|]

