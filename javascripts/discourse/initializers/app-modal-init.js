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
      
      const isNoAppNoCookie = !capabilities.isPwa && !capabilities.wasLaunchedFromDiscourseHub && !cookieAppModal;
      const isAndroidPwa = settings.app_type === "pwa" && capabilities.isAndroid;
      const isAndroidApp = settings.app_type === "app" && capabilities.isAndroid;
      const isIOSApp = settings.app_type === "app" && capabilities.isIOS;
      const isIpadOSApp = settings.app_type === "app" && capabilities.isIpadOS;
      
      api.onPageChange((url, title) => {
        if (isNoAppNoCookie) {
          if (isAndroidPwa && !capabilities.isFirefox) {
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
          } else if (
            settings.app_type === "app" ||
            isIOSApp ||
            isIpadOSApp
          ) {
            modal.show(AppModal);
          }
        } else {
          return;
        }
      });
    });
  }
};
