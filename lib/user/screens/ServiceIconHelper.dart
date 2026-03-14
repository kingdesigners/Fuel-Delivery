class ServiceIconHelper {
  static String getIconPath(String serviceName) {
    String name = serviceName.toLowerCase();
    if (name.contains("fuel")) {
      return "assets/icons/ic_fuel_delivery.png";
    } else if (name.contains("oil")) {
      return "assets/icons/ic_engine_oil.png";
    } else if (name.contains("tyre") || name.contains("tire")) {
      return "assets/icons/ic_tyre_change.png";
    } else if (name.contains("battery")) {
      return "assets/icons/ic_product.png";
    } else if (name.contains("ev")) {
      return "assets/icons/ic_product.png";
    }
    return "assets/icons/ic_product.png";
  }
}
