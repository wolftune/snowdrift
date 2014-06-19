
module Widgets.ProjectPledges where

import Import

import Model.Project
import Model.Currency

{- projectPledgeSummary and projectPledges are most redundant with just
different widgets. We should probably just have one function and move
the widget stuff into two different hamlet files or something.
There are additional places that using the generalized function would
be useful, such as putting the summary number at /u listing perhaps-}

-- |The summary of pledging to projects shown on user's page
projectPledgeSummary :: UserId -> Widget
projectPledgeSummary user_id = do
    ps <- handlerToWidget $ runDB $ getProjectSummaries user_id

    toWidget [hamlet|
        $if null ps
            not supporting any projects
        $else
            <a href="@{UserPledgesR user_id}">
                $if (length ps) == 1
                    <p>Patron to 1 project
                $else
                    <p>Patron to #{length ps} projects
     |]
-- |The listing of all pledges for a given user, shown on u/#/pledges
projectPledges :: UserId -> Widget
projectPledges user_id = do
    ps <- handlerToWidget $ runDB $ getProjectSummaries user_id

    let cost = summaryShareCost
        shares = getCount . summaryShares
        total x = cost x $* fromIntegral (shares x)

    toWidget [hamlet|
        $if null ps
            not supporting any projects
        $else
            <p>
                Note: For testing purposes only.  No real money is changing hands yet.
            <table .table>
                $forall summary <- ps 
                    <tr>
                        <td>
                            <a href="@{ProjectR (summaryProjectHandle summary)}">
                                #{summaryName summary}
                        <td>#{show (cost summary)}/share
                        <td>
                            $if (shares summary) == 1
                                #{show (shares summary)} share
                            $else
                                #{show (shares summary)} shares
                        <td>#{show (total summary)}
     |]

getProjectSummaries :: UserId -> SqlPersistT Handler [ProjectSummary]
getProjectSummaries user_id = do
    projects_pledges <- fmap (map (second return)) $ select $ from $
        \ (project `InnerJoin` pledge) -> do
            on_ $ project ^. ProjectId ==. pledge ^. PledgeProject
            where_ $ pledge ^. PledgeUser ==. val user_id
            return (project, pledge)

    mapM (uncurry summarizeProject) projects_pledges
