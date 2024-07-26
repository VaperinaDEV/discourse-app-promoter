import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import cookie, { removeCookie } from "discourse/lib/cookie";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import { and, eq, not, or } from "truth-helpers";
import I18n from "discourse-i18n";

export default class AppModal extends Component {  
  @service capabilities;
  @service modal;

  @tracked appCookieClosed = cookie("app_modal_closed");

  get cookieExpirationDate() {
    if (settings.app_cookie_lifespan === "none") {
      removeCookie("app_modal_closed", { path: "/" });
    } else {
      return moment().add(1, settings.app_cookie_lifespan).toDate();
    }
  }

  get isApple() {
    return this.capabilities.isApple;
  }

  get isAndroid() {
    return this.capabilities.isAndroid;
  }

  get isOpera() {
    return this.capabilities.isOpera;
  }

  get isFirefox() {
    return this.capabilities.isFirefox;
  }

  get isChrome() {
    return this.capabilities.isChrome;
  }

  get isSafari() {
    return this.capabilities.isSafari;
  }

  get appModalTitle() {
    return I18n.t(themePrefix("app_modal.title"));
  }

  get appLabel() {
    return I18n.t(themePrefix("labels.app_name"));
  }

  get isOperaLabel() {
    return I18n.t(themePrefix("labels.opera"));
  }

  get isFirefoxLabel() {
    return I18n.t(themePrefix("labels.firefox"));
  }

  get isChromeLabel() {
    return I18n.t(themePrefix("labels.chrome"));
  }

  get isSafariLabel() {
    return I18n.t(themePrefix("labels.safari"));
  }

  get installPwaLabel() {
    return I18n.t(themePrefix("actions.install_pwa"));
  }

  get openAppLabel() {
    return I18n.t(themePrefix("actions.open_app"));
  }

  get continueBrowserLabel() {
    return I18n.t(themePrefix("actions.continue_browser"));
  }

  @action
  installPwa() {
    const promptEvent = window.deferredPrompt;
    if (!promptEvent) {
      // The deferred prompt isn't available.
      return;
    }
    // Show the install prompt.
    promptEvent.prompt();
    // Reset the deferred prompt variable, since
    // prompt() can only be called once.
    window.deferredPrompt = null;    
  }

  @action
  openAndroidApp() {
    window.location.href = settings.android_appstore_link;
  }

  @action
  openAppleApp() {
    window.location.href = settings.apple_appstore_link;
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

  <template>
    <DModal
      @closeModal={{@closeModal}}
      @title={{this.appModalTitle}}
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
              {{#if this.isAndroid}}
                {{#if (eq settings.android_app_type "pwa")}}
                  <DButton
                    @class="btn-primary"
                    @translatedLabel={{this.installPwaLabel}}
                    @action={{this.installPwa}}
                  />
                {{else if (eq settings.android_app_type "app")}}
                  <DButton
                    @class="btn-primary"
                    @translatedLabel={{this.openAppLabel}}
                    @action={{this.openAndroidApp}}
                  />
                {{/if}}
              {{else if this.isApple}}
                {{#if settings.ios_app}}
                  <DButton
                    @class="btn-primary"
                    @translatedLabel={{this.openAppLabel}}
                    @action={{this.openAppleApp}}
                  />
                {{/if}}
              {{/if}}
            </div>
          </div>
                
          <div class="app-modal-wrapper__browser">
            <div class="modal-logo">
              {{#if this.isOpera}}
                <img src="{{settings.theme_uploads.opera-logo}}"/>
                <span class="logo-label">{{this.isOperaLabel}}</span>
              {{else if this.isFirefox}}
                <img src="{{settings.theme_uploads.firefox-logo}}"/>
                <span class="logo-label">{{this.isFirefoxLabel}}</span>
              {{else if this.isChrome}}
                <img src="{{settings.theme_uploads.chrome-logo}}"/>
                <span class="logo-label">{{this.isChromeLabel}}</span>
              {{else if this.isSafari}}
                <img src="{{settings.theme_uploads.safari-logo}}"/>
                <span class="logo-label">{{this.isSafariLabel}}</span>
              {{/if}}
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
