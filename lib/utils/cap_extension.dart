extension CapExtension on String {
  String get firstCaps =>
      this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';

  String get allInCaps => this.toUpperCase();

  String get capitalizeFirstOfEach => this
      .replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.firstCaps)
      .join(" ");
}
