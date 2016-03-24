module Handler.User.ChangePassphrase where

import Import

import Yesod.Auth.HashDB (validateUser)

import Handler.Utils
import Handler.User.Utils
import Model.User
import View.User

getUserChangePassphraseR :: UserId -> Handler Html
getUserChangePassphraseR user_id = do
    void $ checkEditUser user_id
    user <- runYDB $ get404 user_id
    (form, enctype) <- generateFormPost changePassphraseForm
    defaultLayout $ do
        snowdriftDashTitle "Change Passphrase" $
            userDisplayName (Entity user_id user)
        $(widgetFile "change-passphrase")

postUserChangePassphraseR :: UserId -> Handler Html
postUserChangePassphraseR user_id = do
    void $ checkEditUser user_id
    ((result, form), enctype) <- runFormPost changePassphraseForm
    case result of
        FormSuccess ChangePassphrase {..} -> do
            user <- runYDB $ get404 user_id
            is_valid_passphrase <- validateUser (UniqueUser $ userIdent user)
                                     currentPassphrase
            if is_valid_passphrase
                then resetPassphrase user_id user newPassphrase newPassphrase' $
                         UserChangePassphraseR user_id
                else do
                    alertDanger "Sorry, that is not the correct current passphrase."
                    defaultLayout $(widgetFile "change-passphrase")
        _ -> do
            alertDanger "Oops, failed to update the passphrase."
            defaultLayout $(widgetFile "change-passphrase")