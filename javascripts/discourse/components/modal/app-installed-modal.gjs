import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import cookie, { removeCookie } from "discourse/lib/cookie";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import I18n from "discourse-i18n";

export default class AppModal extends Component {  
  @service modal;

  @tracked appCookieClosed = cookie("app_modal_closed");

  get cookieExpirationDate() {
    if (settings.app_cookie_lifespan === "none") {
      removeCookie("app_modal_closed", { path: "/" });
    } else {
      return moment().add(1, settings.app_cookie_lifespan).toDate();
    }
  }

  get appInstalledModalTitle() {
    return I18n.t(themePrefix("app_modal.installed_title"));
  }

  get appLabel() {
    return I18n.t(themePrefix("labels.app_name"));
  }

  get isChromeLabel() {
    return I18n.t(themePrefix("labels.chrome"));
  }

  get openPwaLabel() {
    return I18n.t(themePrefix("actions.open_app"));
  }

  get continueBrowserLabel() {
    return I18n.t(themePrefix("actions.continue_browser"));
  }

  @action
  continueBrowser() {
    this.appCookieClosed = true;

    if (this.cookieExpirationDate) {
      const appModalState = { name: settings.app_cookie_name, closed: "true" };
      cookie("app_modal_closed", JSON.stringify(appModalState), {
        expires: this.cookieExpirationDate,
        path: "/",
      });
    }

    this.modal.close();

    window.location.reload();
  }

  @action
  openPwa() {
    window.open("/", "_blank");
  }

  <template>
    <DModal
      @closeModal={{@closeModal}}
      @title={{this.appInstalledModalTitle}}
      class="app-modal"
      @dismissable={{false}}
    >
      <:body>
        <div class="app-modal-wrapper">
          <div class="app-modal-wrapper__app">
            <div class="modal-logo">
              <img src="{{settings.app_logo_img}}"/>
              <span class="logo-label">{{this.appLabel}}</span>
            </div>
    
            <div class="app-button">
              <DButton
                @class="btn-primary"
                @translatedLabel={{this.openPwaLabel}}
                @action={{this.openPwa}}
              />
            </div>
          </div>
                
          <div class="app-modal-wrapper__browser">
            <div class="modal-logo">
              <img src="{{settings.theme_uploads.chrome-logo}}"/>
              <span class="logo-label">{{this.isChromeLabel}}</span>
            </div>
    
            <div class="continue-button">
              <DButton
                @class="btn-default"
                @translatedLabel={{this.continueBrowserLabel}}
                @action={{this.continueBrowser}}
              />
            </div>
          </div>
        </div>
      </:body>
    </DModal>
  </template>
}
