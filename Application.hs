{-# OPTIONS_GHC -fno-warn-orphans #-}
{-# LANGUAGE TupleSections #-}

module Application
    ( makeApplication
    , getApplicationDev
    , makeFoundation
    ) where

import Import
import Settings
-- import Yesod.Auth
import Yesod.Default.Config
import Yesod.Default.Main
import Yesod.Default.Handlers
import Network.Wai.Middleware.RequestLogger
    ( mkRequestLogger, outputFormat, OutputFormat (..), IPAddrSource (..), destination
    )
import qualified Network.Wai.Middleware.RequestLogger as RequestLogger
import qualified Database.Persist
-- import Database.Persist.Sql (runSqlPool)
import Network.HTTP.Client.Conduit (newManager)
import Control.Monad.Logger (runLoggingT, runStderrLoggingT)
import Control.Concurrent (forkIO, threadDelay)
import System.Log.FastLogger (newStdoutLoggerSet, defaultBufSize, flushLogStr)
import Network.Wai.Logger (clockDateCacher)
import Data.Default (def)
import Yesod.Core.Types (loggerSet, Logger (Logger))

import Control.Monad.Trans.Resource

import System.Directory
import Database.Persist.Postgresql (pgConnStr, withPostgresqlConn)

import qualified Data.List as L
import Data.Text as T
import qualified Data.Text.IO as T

import Version

-- Import all relevant handler modules here.
-- Don't forget to add new modules to your cabal file!
import Handler.Home
import Handler.User
import Handler.Widget
import Handler.Project
import Handler.Invitation
import Handler.Invite
import Handler.UpdateShares
import Handler.Volunteer
import Handler.Contact
import Handler.Who
import Handler.PostLogin
import Handler.ToU
import Handler.Privacy
import Handler.Messages
import Handler.Application
import Handler.Applications
import Handler.JsLicense
import Handler.MarkdownTutorial
import Handler.UserBalance
import Handler.UserPledges
import Handler.Wiki
import Handler.Discussion
import Handler.Tags
import Handler.Tickets
import Handler.RepoFeed
import Handler.BuildFeed
import Handler.ProjectSignup
import Handler.License

import Widgets.Navbar

import Data.ByteString (ByteString)
import System.Posix.Env.ByteString

import Control.Monad.Reader

import System.Environment (lookupEnv)

runSql :: MonadSqlPersist m => Text -> m ()
runSql = flip rawExecute [] -- TODO quasiquoter?

version :: (Text, Text)
version = $(mkVersion)

-- This line actually creates our YesodDispatch instance. It is the second half
-- of the call to mkYesodData which occurs in Foundation.hs. Please see the
-- comments there for more details.
mkYesodDispatch "App" resourcesApp

-- probably not thread safe
withEnv :: (MonadIO m) => ByteString -> ByteString -> m a -> m a
withEnv k v action = do
    original <- liftIO $ getEnv k

    liftIO $ setEnv k v True
    result <- action
    liftIO $ maybe (unsetEnv k) (\ v' -> setEnv k v' True) original

    return result

-- This function allocates resources (such as a database connection pool),
-- performs initialization and creates a WAI application. This is also the
-- place to put your migrate statements to have automatic database
-- migrations handled by Yesod.
makeApplication :: AppConfig DefaultEnv Extra -> IO (Application, LogFunc)
makeApplication conf = do
    foundation <- makeFoundation conf

    -- Initialize the logging middleware
    logWare <- mkRequestLogger def
        { outputFormat =
            if development
                then Detailed True
                else Apache FromSocket
        , destination = RequestLogger.Logger $ loggerSet $ appLogger foundation
        }

    -- Create the WAI application and apply middlewares
    app <- toWaiAppPlain foundation
    let logFunc = messageLoggerSource foundation (appLogger foundation)
    return (logWare $ defaultMiddlewaresNoLogging app, logFunc)

-- | Loads up any necessary settings, creates your foundation datatype, and
-- performs some initialization.
makeFoundation :: AppConfig DefaultEnv Extra -> IO App
makeFoundation conf = do
    manager <- newManager
    s <- staticSite
    dbconf <- withYamlEnvironment "config/postgresql.yml" (appEnv conf)
              Database.Persist.loadConfig >>=
              Database.Persist.applyEnv
    p <- Database.Persist.createPoolConfig (dbconf :: Settings.PersistConf)

    loggerSet' <- newStdoutLoggerSet defaultBufSize
    (getter, updater) <- clockDateCacher

    -- If the Yesod logger (as opposed to the request logger middleware) is
    -- used less than once a second on average, you may prefer to omit this
    -- thread and use "(updater >> getter)" in place of "getter" below.  That
    -- would update the cache every time it is used, instead of every second.
    let updateLoop = do
            threadDelay 1000000
            updater
            flushLogStr loggerSet'
            updateLoop
    _ <- forkIO updateLoop

    let logger = Yesod.Core.Types.Logger loggerSet' getter
        foundation = App navbar conf s p manager dbconf logger

    -- Perform database migration using our application's logging settings.
    case appEnv conf of
        Testing -> withEnv "PGDATABASE" "template1" (applyEnv $ persistConfig foundation) >>= \ dbconf' -> do
                let runDBNoTransaction (SqlPersistT r) = runReaderT r

                options <- maybe [] L.words <$> lookupEnv "SNOWDRIFT_TESTING_OPTIONS" 

                unless (elem "nodrop" options) $ do
                    runStderrLoggingT $ runResourceT $ withPostgresqlConn (pgConnStr dbconf') $ runDBNoTransaction $ do
                        liftIO $ putStrLn "dropping database..."
                        runSql "DROP DATABASE IF EXISTS snowdrift_test;"
                        liftIO $ putStrLn "creating database..."
                        runSql "CREATE DATABASE snowdrift_test WITH TEMPLATE snowdrift_test_template;"
                        liftIO $ putStrLn "ready."
        _ -> return ()

    let migration = runResourceT $ do
        Database.Persist.runPool dbconf doMigration p
        runSqlPool migrateTriggers p

    runLoggingT
	migration
	(messageLoggerSource foundation logger)

    now <- getCurrentTime
    let (base, diff) = version
    runLoggingT
        (runResourceT $ Database.Persist.runPool dbconf (insert_ $ Build now base diff) p)
        (messageLoggerSource foundation logger)

    return foundation

-- for yesod devel
getApplicationDev :: IO (Int, Application)
getApplicationDev =
    defaultDevelApp loader (fmap fst . makeApplication)
  where
    loader = Yesod.Default.Config.loadConfig (configSettings Development)
        { csParseExtra = parseExtra
        }

doMigration :: (MonadResource m, MonadBaseControl IO m, MonadIO m, MonadLogger m, MonadThrow m) => SqlPersistT m ()
doMigration = do
    $(logInfo) "creating version table"

    runSql "CREATE TABLE IF NOT EXISTS \"database_version\" (\"id\" SERIAL PRIMARY KEY UNIQUE, \"last_migration\" INT8 NOT NULL);"

    last_migration <- select $ from return

    migration_number <- case last_migration of
        [] -> insert (DatabaseVersion 0) >> return 0
        [Entity _ (DatabaseVersion migration)] -> return migration
        _ -> error "multiple entries in DB version table"

    unfiltered_migration_files <- liftIO $ getDirectoryContents "migrations"

    let migration_files :: [(Int, String)]
        migration_files = L.sort
            $ L.filter ((> migration_number) . fst)
            $ mapMaybe (\ s -> fmap (,s) $ readMaybe =<< L.stripPrefix "migrate" s)
            unfiltered_migration_files

    forM_ (L.map (("migrations/" <>) . snd) migration_files) $ \ file -> do
        $(logWarn) $ "running " <> T.pack file <> "..."
        migration <- liftIO $ T.readFile file
        runSql migration

    let new_last_migration = L.maximum $ migration_number : L.map fst migration_files
    update $ flip set [ DatabaseVersionLastMigration =. val new_last_migration ]

    migrations <- parseMigration' migrateAll

    let (unsafe, safe) = L.partition fst migrations

    unless (L.null $ L.map snd safe) $ do
        let filename = "migrations/migrate" <> show (new_last_migration + 1)

        liftIO $ T.writeFile filename $ T.unlines $ L.map ((`snoc` ';') . snd) safe

        $(logWarn) $ "wrote " <> T.pack (show $ L.length safe) <> " safe statements to " <> T.pack filename

        mapM_ (runSql . snd) migrations

    unless (L.null $ L.map snd unsafe) $ do
        let filename = "migrations/migrate.unsafe"

        liftIO $ T.writeFile filename $ T.unlines $ L.map ((`snoc` ';') . snd) unsafe

        $(logWarn) $ "wrote " <> T.pack (show $ L.length unsafe) <> " safe statements to " <> T.pack filename

        error "Some migration steps were unsafe.  Aborting."

    rolloutStagingWikiPages


rolloutStagingWikiPages :: (MonadBaseControl IO m, MonadIO m, MonadLogger m, MonadResource m, MonadThrow m) => SqlPersistT m ()
rolloutStagingWikiPages = do
    pages <- select $ from $ \ page -> do
        where_ ( page ^. WikiPageTarget `like` val "_staging_%" )
        return page

    forM_ pages $ \ (Entity staged_page_id staged_page) -> do
        let (Just target) = stripPrefix "_staging_" $ wikiPageTarget staged_page
        [ Value page_id ] <- select $ from $ \ page -> do
            where_ ( page ^. WikiPageTarget ==. val target )
            return $ page ^. WikiPageId

        update $ \ edit -> do
            set edit [ WikiEditPage =. val page_id ]
            where_ ( edit ^. WikiEditPage ==. val staged_page_id )

        update $ \ page -> do
            set page [ WikiPageContent =. val (wikiPageContent staged_page) ]
            where_ ( page ^. WikiPageId ==. val page_id )

        [ Value last_staged_edit_edit ] <- select $ from $ \ last_staged_edit -> do
            where_ ( last_staged_edit ^. WikiLastEditPage ==. val staged_page_id )
            return $ last_staged_edit ^. WikiLastEditEdit

        update $ \ last_edit -> do
            set last_edit [ WikiLastEditEdit =. val last_staged_edit_edit ]
            where_ ( last_edit ^. WikiLastEditPage ==. val page_id )

        delete $ from $ \ last_edit -> where_ ( last_edit ^. WikiLastEditPage ==. val staged_page_id )

        delete $ from $ \ page -> where_ ( page ^. WikiPageId ==. val staged_page_id )


migrateTriggers :: (MonadSqlPersist m, MonadBaseControl IO m, MonadThrow m) => m ()
migrateTriggers = runResourceT $ do
    runSql $ T.unlines
        [ "CREATE OR REPLACE FUNCTION log_role_event_trigger() RETURNS trigger AS $role_event$"
        , "    BEGIN"
        , "        IF (TG_OP = 'DELETE') THEN"
        , "            INSERT INTO role_event (time, \"user\", role, project, added) SELECT now(), OLD.\"user\", OLD.role, OLD.project, 'f';"
        , "            RETURN OLD;"
        , "        ELSIF (TG_OP = 'INSERT') THEN"
        , "            INSERT INTO role_event (time, \"user\", role, project, added) SELECT now(), NEW.\"user\", NEW.role, NEW.project, 't';"
        , "            RETURN NEW;"
        , "        END IF;"
        , "        RETURN NULL;"
        , "    END;"
        , "$role_event$ LANGUAGE plpgsql;"
        ]

    runSql "DROP TRIGGER IF EXISTS role_event ON project_user_role;"

    runSql $ T.unlines
        [ "CREATE TRIGGER role_event"
        , "AFTER INSERT OR DELETE ON project_user_role"
        , "    FOR EACH ROW EXECUTE PROCEDURE log_role_event_trigger();"
        ]

    runSql $ T.unlines
        [ "CREATE OR REPLACE FUNCTION log_doc_event_trigger() RETURNS trigger AS $doc_event$"
        , "    BEGIN"
        , "        IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN"
        , "            INSERT INTO doc_event (time, doc, blessed_version) SELECT now(), NEW.id, NEW.current_version;"
        , "            RETURN NEW;"
        , "        END IF;"
        , "        RETURN NULL;"
        , "    END;"
        , "$doc_event$ LANGUAGE plpgsql;"
        ]

    runSql "DROP TRIGGER IF EXISTS doc_event ON doc;"

    runSql $ T.unlines
        [ "CREATE TRIGGER doc_event"
        , "AFTER INSERT OR DELETE ON doc"
        , "    FOR EACH ROW EXECUTE PROCEDURE log_doc_event_trigger();"
        ]

    return ()

