import { withPluginApi } from "discourse/lib/plugin-api";
import cookie from "discourse/lib/cookie";
import discourseLater from "discourse-common/lib/later";
import AppModal from "../components/modal/app-modal";
import AppInstalledModal from "../components/modal/app-installed-modal";

const cookieAppModal = cookie("app_modal_closed");

export default {
  name: "app-modal",

  initialize() {
    withPluginApi("0.8.7", api => {
      
      const modal = api.container.lookup("service:modal");
      const capabilities = api.container.lookup("service:capabilities");
      
      api.onPageChange((url, title) => {
        if (
          !capabilities.isPwa &&
          !capabilities.wasLaunchedFromDiscourseHub &&
          capabilities.isAndroid &&
          !cookieAppModal
        ) {
          if (
            settings.app_type === "pwa" &&
            !capabilities.isFirefox
          ) {
            const installPrompt = () => {
              return new Promise((resolve, reject) => {
                window.addEventListener("beforeinstallprompt", (event) => {
                  event.preventDefault();
                  window.deferredPrompt = event;
                  resolve();
                });
            
                discourseLater(() => {
                  reject();
                }, 3000);
              });
            };
            
            installPrompt()
              .then(() => {
                modal.show(AppModal);
              })
              .catch(() => {
                modal.show(AppInstalledModal);
              });
          } else if (settings.app_type === "app") {
            modal.show(AppModal);
          }
        } else {
          return;
        }
      });     
    });
  }
};
