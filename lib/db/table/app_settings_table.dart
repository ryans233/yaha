class AppSettings {
  static const tableName = "app_settings";
  static const columnKey = "key";
  static const columnAmountStoriesPerLoad = "amount_stories_per_load";

  int key;
  int amountStoriesPerLoad;

  AppSettings([
    this.key = 0,
    this.amountStoriesPerLoad = 20,
  ]);

  AppSettings.fromJson(Map<String, dynamic> json) {
    this.key = json[columnKey];
    this.amountStoriesPerLoad = json[columnAmountStoriesPerLoad];
  }

  Map<String, dynamic> toJson() => {
    columnKey: key,
    columnAmountStoriesPerLoad: amountStoriesPerLoad,
  };

  @override
  String toString() =>
      "AppSettingsTable{" +
      "key: $key, " +
      "amountStoriesPerLoad: $amountStoriesPerLoad, " +
      "}";
}
