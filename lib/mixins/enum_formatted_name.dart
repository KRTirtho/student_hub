mixin FormattedName on Enum {
  String get formattedName {
    return name.replaceAll("_", " ").split(" ").map((e) {
      if (e == "of") return e;
      return e[0].toUpperCase() + e.substring(1);
    }).join(" ");
  }
}
