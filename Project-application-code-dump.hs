ProjectQuestionnaire
    createdTs UTCTime
    primaryContactUser UserId
    projectName Text
    projectWebsite Text Maybe
    primaryContactRealName Text
    primaryContactEmail Text
    primaryContactInfoOther Text Maybe
    primaryContactRole Text Maybe
    projectPaidMembersRealName Text Maybe
    projectPaidMembersEmail Text Maybe
    projectPaidMembersRole Text Maybe
    projectUnpaidMembersEmail Text Maybe
    projectUnpaidMembersRole Text Maybe
    projectType Text
    projectDescription Textarea
    projectGoals Textarea
    projectBudgeting Textarea
    projectOrganization Textarea
    projectLicense Text
    projectLicenseOther Text Maybe
    projectFormatRepository Text
    projectAffiliations Textarea Maybe
    projectProfitStatus Text
    projectCooperativeStatus Bool
    projectProfitCooperativeStatusOther Textarea Maybe
    comments Textarea Maybe

HonorQuestionnaireAll
    honorDecisionMaking Text
    honorDecisionMakingOther Textarea Maybe
    honorConflictOfInterest Text
    honorConflictOfInterestOther Textarea Maybe
    honorSourceRelease Text
    honorSourceReleaseOther Textarea Maybe
    honorAdvertising Text
    honorAdvertisingOther Textarea Maybe
    honorOpenStandards Bool
    honorOpenStandardsOther Textarea Maybe
    honorDisabilityAccess Bool
    honorDisabilityAccessOther Textarea Maybe

HonorQuestionnaireWebsite
    honorDataCollectionAll Textarea
    honorDataCollectionOptOut Textarea
    honorDataCollectionOptIn Textarea
    honorThirdPartySharing Textarea
    honorUserDataRemoval Bool
    honorUserDataRemovalOther Textarea Maybe
    honorUserNotification Textarea
    honorWaiverOfRights Text
    honorWaiverOfRightsOther Textarea Maybe
    honorSocialMedia Text
    honorSocialMediaOther Textarea Maybe
    honorSiteAnalytics Text
    honorSiteAnalyticsOther Textarea Maybe

HonorQuestionnaireTech
    honorBackwardsCompatibility Textarea
    honorSupportServices Text
    honorSupportServicesOther Textarea Maybe
    honorProprietaryElements Textarea
    honorFLOCompatibility Bool
    honorFLOCompatibilityOther Textarea Maybe
    honorSaaS Text
    honorSaaSOther Textarea Maybe


module Handler.ProjectApplication where

import Import

import Widgets.Sidebar


projectApplicationForm :: UTCTime -> Entity User -> Form (ProjectQuestionnaire, HonorQuestionnaireAll, HonorQuestionnaireWebsite, HonorQuestionnaireTech)
projectApplicationForm now (Entity user_id user) = renderBootstrap $
    (\  projectName website contactRealName contactEmail otherContactInfo realNamesPaidMembers emailsPaidMembers rolesPaidMembers emailsUnpaidMembers rolesUnpaidMembers projectType projectMission projectGoals projectBudget projectOrganization license licenseComments formatRepository affiliations profitStatus coopStatus profitCoopStatusComments comments 
decisions decisionsComments conflict conflictComments source sourceComments advertising advertisingComments openStandards openStandardsComments disabilityAccess disabilityAccessComments 
dataCollectionAll dataCollectionOut dataCollectionIn thirdParty dataRemoval dataRemovalComments notification rightsWaiver rightsWaiverComments socialMedia socialMediaComments siteAnalytics siteAnalyticsComments 
backwardsCompatibility supportService supportServiceComments proprietaryElements floCompatibility floCompatibilityComments softwareAsService softwareAsServiceComments -> 
(ProjectQuestionnaire projectName website contactRealName contactEmail otherContactInfo realNamesPaidMembers emailsPaidMembers rolesPaidMembers emailsUnpaidMembers rolesUnpaidMembers projectType projectMission projectGoals projectBudget projectOrganization license licenseComments formatRepository affiliations profitStatus coopStatus profitCoopStatusComments comments, HonorQuestionnaireAll decisions decisionsComments conflict conflictComments source sourceComments advertising advertisingComments openStandards openStandardsComments disabilityAccess disabilityAccessComments, 
HonorQuestionnaireWebsite dataCollectionAll dataCollectionOut dataCollectionIn thirdParty dataRemoval dataRemovalComments notification rightsWaiver rightsWaiverComments socialMedia socialMediaComments siteAnalytics siteAnalyticsComments, 
HonorQuestionnaireTech backwardsCompatibility supportService supportServiceComments proprietaryElements floCompatibility floCompatibilityComments softwareAsService softwareAsServiceComments ))
        <$> areq textField "Project name:" Nothing
        <*> aopt textField "Project website URL:" Nothing
        <*> areq textField “Primary contact real name:” Nothing
        <*> areq emailField "Primary contact email:" (Just . userIdent $ user)
        <*> aopt textField "Other contact info (phone, IRC handle, chat ID, etc):" Nothing
        <*> aopt textField "Project role:" Nothing
        <*> aopt textField "Real names of paid project members (comma delineated):" Nothing
        <*> aopt textField "Emails of paid project members (comma delineated):" Nothing
        <*> aopt textField "Project roles of paid project members (comma delineated):" Nothing 
        <*> aopt textField "Emails of unpaid project members (comma delineated):" Nothing
        <*> aopt textField "Project roles of unpaid project members (comma delineated):" Nothing
        <*> areq (selectFieldList type) "Project type:" Nothing
        <*> areq textareaField “Describe your project's vision and mission:” Nothing
        <*> areq textareaField “Describe your project's short-term and long-term goals and deliverables:” Nothing
        <*> areq textareaField “Describe how your project will benefit from and make use of funds raised through Snowdrift.coop:” Nothing
        <*> areq textareaField “Describe your project's organizational structure and team roles:” Nothing
        <*> areq (selectFieldList license) “What is your project's primary licensing scheme?” Nothing
        <*> aopt textField “Comments on licensing scheme (including special terms):” Nothing
        <*> areq textField “Intended format and repository for end product:” Nothing
        <*> aopt textareaField “Affiliations with other projects and organizations :” Nothing
        <*> areq (selectFieldList profit) “Profit/non-profit status of project or umbrella organization:” Nothing
        <*> areq boolField “Co-operative status of project or umbrella organization:” Nothing
        <*> aopt textField “Comments on profit/non-profit/co-operative status (please include any status in progress but not yet confirmed):” Nothing
        <*> aopt textareaField “Is there anything else you want us to know about your project?” Nothing
        <*> areq (selectFieldList decision) “What is your project's decision-making process:” Nothing
        <*> aopt textField “Comments on decision-making process:” Nothing
        <*> areq (selectFieldList conflict) “What is your project's policy for handling potential conflicts-of-interest?” Nothing
        <*> aopt textareaField “Comments on conflict-of-interest policy (please include any team members' potential conflicts with the project mission that should be disclosed upfront):” Nothing
        <*> areq (selectFieldList source) “How much source material do you intend to release?” Nothing
        <*> aopt textField “Comments on release of source material (for research projects, if you will not be releasing source data, please provide a brief rationale):” Nothing
        <*> areq (selectFieldList advertising) “How does your project make use of advertising?” Nothing
        <*> aopt textField “Comments on use of advertising:”
        <*> areq boolField “Does your project use Open Standards wherever applicable?” Nothing
        <*> aopt textField “If not, please provide a brief rationale:” Nothing
        <*> areq boolField “Does your project adhere to disability access standards?” Nothing
        <*> aopt textField “If not, please provide a brief rationale:” Nothing
        <*> areq textfield “List user data your project always collects:” Nothing
        <*> areq textField “List user data collected on opt-out basis:” Nothing
        <*> areq textField “List user data collected on opt-in basis:” Nothing
        <*> areq textField “When does your site release user data to third parties?” Nothing
        <*> areq boolField “Does your site allow users to remove their private data when closing an account?” Nothing
        <*> aopt textField “If not, please provide a brief rationale:” Nothing
        <*> areq textField “Does your site provide advance notice and user response when making major changes (i.e., revision of posted Terms of Use)? List any exceptions.” Nothing
        <*> areq (selectFieldList waiver) “Does your site ask the user to waive any legal rights?” Nothing
        <*> aopt textField “Comments on waiver of rights:” Nothing
        <*> areq (selectFieldList social) “How does your site handle social media integration?” Nothing
        <*> aopt textField “Comments on social media use:” Nothing
        <*> areq (selectFieldList analytics) “How are site analytics processed?” Nothing
        <*> aopt textfield “Comments on site analytics:” Nothing
        <*> areq textareaField “Describe your project's backwards compatibility:” Nothing
        <*> areq (selectFieldList support) “What support services does your project offer for its products?” Nothing
        <*> aopt textField “Comments on support services:” Nothing
        <*> areq textareaField “List any proprietary elements your project requires to function and please provide a brief rationale for including them (i.e., “no FLOSS equivalent”):” Nothing
        <*> areq boolField “Does your project have full native compatibility with standard FLO software packages?” Nothing
        <*> aopt textField “If not, please provide a brief rationale:”
        <*> areq (selectFieldList service) “What is your project's policy on Software as a Service?” Nothing
        <*> aopt textField “Comments on Software as a Service:” Nothing
      
   where
        type = (\ a -> zip a a) $ ["Software and other technology", "FLO Cultural works”, "Journalism", "Education", "Research"]
        license = (\ a -> zip a a) $ [“CC-BY”, “CC-BY-SA”, “GPL v.2”, “GPL v.3”, “LGPL”, “MIT license”, “BSD license”, “Public domain/CC-0/unlicense”, “Other—please specify below”]
        profit = (\ a -> zip a a) $ [“For-profit”, “Certified B-corp”, “Benefit corporation”, “501(c)(3) non-profit”, “Other federal non-profit—please specify below”, “State non-profit”, “Unincorporated/Partnership/Sole proprietorship”, “Other—please specify below”]
        decision = (\ a -> zip a a) $ [“Consensus”, “Supermajority”, “Simple majority”, “Top-down”, “Other—please specify below”]
        conflict = (\ a -> zip a a) $ [“Disclosure required only”, “Risk management/reduction”, “Disqualification”, “Other—please specify below”]
        source = (\a -> zip a a) $ [“Open Data—for research projects”, “Open Access—for research projects”, “Full release of all raw source files”, “Release of intermediate work files”, “Release of final product only”, “Other—please specify below”]
        advertising = (\a -> zip a a) $ [“AdBlock Plus-compliant ads”, “Ethical, relevant, project team-endorsed ads only”, “No advertising”, “Other—please specify below”]
        waiver = (\a -> zip a a) $ [“Standard liability disclaimer only”, “Binding arbitration required”, “User-created content may be used in promotional materials”, “Other—please specify below”]
        social = (\a -> zip a a) $ [“JavaScript buttons with standard tracking”, “JavaScript buttons with opt-in tracking”, “Static or HTML link”, “Other—please specify below”]
        support = (\a -> zip a a) $ [“Informal only”, “Formal support freely available”, “Formal support available by fee or subscription”, “Other—please specify below]
        service = (\a -> zip a a) $ [“Encourage local hosting”, “Opt-in Internet connection of local programs”, “Franklin Street-compliant SaaS”, “Other—please specify below”]

get ProjectApplicationR :: Handler RepHtml
get ProjectApplicationR = do
    user <- requireAuth
    now <- liftIO getCurrentTime
    (projectApplication_form, _) <- generateFormPost $ projectApplicationForm now user
    defaultLayout $(widgetFile "projectApplication")


post ProjectApplicationR :: Handler RepHtml
post ProjectApplicationR = do
    user <- requireAuth
    now <- liftIO getCurrentTime
    ((result, _), _) <- runFormPost $ projectApplicationForm now user

    case result of
        FormSuccess application -> do
            _ <- runDB $ insert application
            setMessage "application submitted"
            redirect ProjectApplicationR

        _ -> do
            setMessage "error submitting application"
            redirect ProjectApplicationR
