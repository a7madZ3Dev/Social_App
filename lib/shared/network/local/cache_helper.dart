import 'package:shared_preferences/shared_preferences.dart';

import '../../components/constants.dart';

class CacheHelper {
  // save data in cache
  static Future<void> saveData({String? uid}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(kUid, uid!);
  }

  // get data from cache
  static Future<dynamic> getData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? value = preferences.getString(kUid);
    if (value != null) {
      return value;
    } else {
      return '';
    }
  }

  // delete data in cache
  static Future<bool> deleteData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.remove(kUid);
  }
}
