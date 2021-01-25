module Fission.Web.Server.IPFS.Cluster.Client
  ( API
  , peers
  ) where

import           Fission.Prelude
import           Servant
import           Servant.Client

type API = "peers" :> Get '[PlainText] Text

peers :: ClientM Text
peers = client $ Proxy @API
