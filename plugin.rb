# name: discourse-hostname-display
# about: Expose backend node hostname for diagnostics
# version: 0.1
# authors: kr-nn

# add theme component here under js:
# api.onPageChange(async () => {
#   if (window.location.pathname.startsWith("/admin")) {
#     if (!document.getElementById("discourse-node-info")) {
#       const nodeName = await getNodeName();
#       const nodeInfo = document.createElement("div");
#       nodeInfo.id = "discourse-node-info";
#       nodeInfo.className = "alert alert-info";
#       nodeInfo.style.position = "fixed";
#       nodeInfo.style.bottom = "1em";
#       nodeInfo.style.right = "1em";
#       nodeInfo.style.zIndex = "10000";
#       nodeInfo.style.maxWidth = "300px";

#       nodeInfo.textContent = `Node: ${nodeName}`;
#       document.body.appendChild(nodeInfo);
#     }
#   }
# });

after_initialize do
  module ::DiscourseNodeInfo
    class Engine < ::Rails::Engine
      engine_name "discourse_node_info"
      isolate_namespace DiscourseNodeInfo
    end
  end

  class ::DiscourseNodeInfo::NodeController < ::ApplicationController
    skip_before_action :check_xhr
    skip_before_action :verify_authenticity_token

    def show
      render json: { node: ENV["HOSTNAME"] || `hostname`.strip }
    end
  end

  DiscourseNodeInfo::Engine.routes.draw do
    get "/" => "node#show"
  end

  Discourse::Application.routes.append do
    mount ::DiscourseNodeInfo::Engine, at: "/node-info"
  end
end
