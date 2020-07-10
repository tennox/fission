-- | Initialize a new Fission app in an existing directory

module Fission.CLI.Command.Account.Link
  ( cmd
  , cmdTxt
  , accountLink
  ) where

import qualified System.Console.ANSI as ANSI
import qualified Crypto.PubKey.Ed25519                  as Ed25519
import           Options.Applicative
import           RIO.FilePath ((</>))

import           Fission.Prelude
import qualified Fission.Internal.UTF8 as UTF8

import           Fission.Authorization.ServerDID
import           Fission.URL
import           Fission.Error.AlreadyExists.Types

import           Fission.Web.Auth.Token.Types
import           Fission.Web.Client
import           Fission.Web.Client.App                 as App

import qualified Fission.CLI.Display.Error              as CLI.Error
import qualified Fission.CLI.Display.Success            as CLI.Success

import           Fission.CLI.Environment                as Environment
import           Fission.CLI.Environment.Override       as Env.Override
import           Fission.CLI.Prompt.BuildDir

import           Fission.CLI.Command.App.Init.Types     as App.Init
import           Fission.CLI.Command.Types

import           Fission.Internal.Orphanage.ClientError ()

import qualified Web.Browser as Web

cmd ::
  ( MonadWebClient m
  , MonadIO        m
  , MonadTime      m
  , ServerDID      m
  , MonadWebAuth   m Token
  , MonadWebAuth   m Ed25519.SecretKey
  , MonadLogger    m
  )
  => Command m App.Init.Options ()
cmd = Command
  { command     = cmdTxt
  , description = "Link your CLI account to a browser account"
  , argParser   = parseOptions
  , handler     = accountLink
  }

cmdTxt :: Text
cmdTxt = "account-link"

-- | Sync the current working directory to the server over IPFS
accountLink ::
  ( MonadWebClient m
  , MonadIO        m
  , MonadTime      m
  , MonadLogger    m
  , ServerDID      m
  , MonadWebAuth   m Token
  , MonadWebAuth   m Ed25519.SecretKey
  )
  => App.Init.Options
  -> m ()
accountLink App.Init.Options {appDir, buildDir} = do
  _ <- liftIO $ Web.openBrowser "https://auth.fission.codes"
  return () 


parseOptions :: Parser App.Init.Options
parseOptions = do
  appDir <- strOption $ mconcat
    [ metavar "PATH"
    , help    "The file path to initialize the app in (app config, etc)"

    , value   "."

    , long    "app-dir"
    , short   'a'
    ]

  OptionalFilePath buildDir <- strOption $ mconcat
    [ metavar "PATH"
    , help    "The file path of the assets or directory to sync"

    , value   ""

    , long    "build-dir"
    , short   'b'
    ]

  return App.Init.Options {..}
