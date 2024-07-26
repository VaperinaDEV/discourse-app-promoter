export default function migrate(settings) {
  if (settings.has("app_type")) {
    settings.set("android_app_type", settings.get("app_type"));
    settings.delete("app_type");
  }
  if (settings.has("app_store_link")) {
    settings.set("android_appstore_link", settings.get("app_store_link"));
    settings.delete("app_store_link");
  }
  return settings;
}
