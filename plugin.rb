# name: discourse-hostname-display
# about: Exposes the backend node name for cluster visibility
# version: 0.1
# authors: kr-nn

enabled_site_setting :node_info_enabled

after_initialize do
  module ::NodeInfo
    class Engine < ::Rails::Engine
      engine_name "node_info"
      isolate_namespace NodeInfo
    end
  end

  NodeInfo::Engine.routes.draw do
    get "/" => "node#show"
  end

  class NodeInfo::NodeController < ::ApplicationController
    requires_plugin "discourse-node-info"

    skip_before_action :check_xhr
    skip_before_action :verify_authenticity_token

    def show
      render json: {
        node: ENV["HOSTNAME"] || `hostname`.strip
      }
    end
  end

  Discourse::Application.routes.append do
    mount ::NodeInfo::Engine, at: "/node-info"
  end
end
