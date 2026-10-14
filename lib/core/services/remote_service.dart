import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as prefix;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/routes/app_routes.dart';

// Route segment prefixes
String auth = "auth/";
  String user = "user/";
String statesUrl = "states";
String citiesUrl = "cities";
String categoriesUrl = "categories";
String businessesUrl = "businesses";
String peopleUrl = "people";
String vendorUrl = "vendor/";
String notificationsUrl = "notifications";
String supportUrl = "support/";
String legalUrl = "legal/";

class RemoteService {
  static String baseUrl = "http://192.168.1.21:5000/api/v1";

  static String accessId = "";
  static String authToken = "";
  static var client = http.Client();

  static Map<String, String> header = {
    "Content-type": "application/json; charset=utf-8",
  };

  static Map<String, String> authHeader = {
    "Content-type": "application/json; charset=utf-8",
    "Authorization": "Bearer $authToken",
    "access_id": accessId,
  };

  static void _ensureAuthToken() {
    try {
      final storage = GetStorage();
      final storedToken = storage.read<String>('accessToken');
      if (storedToken != null && storedToken.isNotEmpty) {
        if (authToken != storedToken || !authHeader.containsKey('Authorization') || authHeader['Authorization'] != "Bearer $storedToken") {
          authToken = storedToken;
          initializeAuthHeader(token: storedToken);
        }
      }
    } catch (_) {}
  }

  static Future<void> initializeAuthHeader({String? token, String? id}) async {
    if (token != null) authToken = token;
    if (id != null) accessId = id;

    authHeader = {
      "Content-type": "application/json; charset=utf-8",
      "Authorization": authToken.isNotEmpty ? "Bearer $authToken" : "",
      "access_id": accessId,
    };
    print("initializeAuthHeader +++ $authHeader");
  }

  static void multiLoginDetector() {
    print("Session Expired or 401 Detected! Logging out user...");
    authToken = "";
    accessId = "";
    initializeAuthHeader();
    prefix.Get.offAllNamed(AppRoutes.login);
  }

  static dynamic parseBody(Response res) {
    if (res.body.trim().isEmpty) {
      return {"status": res.statusCode, "message": "Empty response body"};
    }
    try {
      return jsonDecode(res.body);
    } catch (_) {
      return {"status": res.statusCode, "message": res.body};
    }
  }

  // ==========================================
  // 0. DATABASE SEEDER
  // ==========================================
  static Future seedDatabase({Map<String, dynamic>? map}) async {
    try {
      Response res = await client.post(
        Uri.parse("$baseUrl/seed"),
        headers: header,
        body: jsonEncode(map ?? {}),
      );
      print("Seed Database +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  // ==========================================
  // 1. AUTHENTICATION & PROFILE
  // ==========================================
  static Future sendOtp({Map<String, dynamic>? map}) async {
    try {
      Response res = await client.post(
        Uri.parse("$baseUrl/$auth" "send-otp"),
        headers: header,
        body: jsonEncode(map),
      );
      print("Send OTP +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      if (res.statusCode == 401 || res.body == 'Session Expired') {
        multiLoginDetector();
      }
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future verifyOtp({Map<String, dynamic>? map}) async {
    try {
      Response res = await client.post(
        Uri.parse("$baseUrl/$auth" "verify-otp"),
        headers: header,
        body: jsonEncode(map),
      );
      print("Verify OTP +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      if (res.statusCode == 401 || res.body == 'Session Expired') {
        multiLoginDetector();
      }
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future googleSignIn({Map<String, dynamic>? map}) async {
    try {
      Response res = await client.post(
        Uri.parse("$baseUrl/$auth" "google"),
        headers: header,
        body: jsonEncode(map),
      );
      print("Google Sign In +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future appleSignIn({Map<String, dynamic>? map}) async {
    try {
      Response res = await client.post(
        Uri.parse("$baseUrl/$auth" "apple"),
        headers: header,
        body: jsonEncode(map),
      );
      print("Apple Sign In +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future refreshToken({Map<String, dynamic>? map}) async {
    try {
      Response res = await client.post(
        Uri.parse("$baseUrl/$auth" "refresh-token"),
        headers: header,
        body: jsonEncode(map),
      );
      print("Refresh Token +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future getUserProfile() async {
    try {
      Response res = await client.get(
        Uri.parse("$baseUrl/$user" "profile"),
        headers: authHeader,
      );
      print("Get User Profile +++++++++++++");
      print("authHeader +++ $authHeader");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      if (res.statusCode == 401 || res.body == 'Session Expired') {
        multiLoginDetector();
      }
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future getUserBusinesses({Map<String, dynamic>? map}) async {
    try {
      final queryParams = <String, String>{};
      if (map != null) {
        map.forEach((k, v) {
          if (v != null && v.toString().isNotEmpty) {
            queryParams[k] = v.toString();
          }
        });
      }
      final uri = Uri.parse("$baseUrl/$user" "businesses").replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      Response res = await client.get(uri, headers: authHeader);
      print("Get User Businesses +++++++++++++ $map");
      print("authHeader +++ $authHeader");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      if (res.statusCode == 401 || res.body == 'Session Expired') {
        multiLoginDetector();
      }
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future updateUserProfile({Map<String, String>? fields, String? avatarFilePath}) async {
    try {
      if (avatarFilePath != null && avatarFilePath.isNotEmpty) {
        var request = http.MultipartRequest('PUT', Uri.parse("$baseUrl/$user" "profile"));
        request.headers.addAll(authHeader);
        if (fields != null) {
          request.fields.addAll(fields);
        }
        request.files.add(await http.MultipartFile.fromPath('avatar', avatarFilePath));
        print("Update User Profile Multipart +++++++++++++ $fields, avatar: $avatarFilePath");
        var streamedResponse = await request.send();
        var res = await http.Response.fromStream(streamedResponse);
        print("------ STATUS CODE ---- ${res.statusCode}");
        print(res.body);
        return parseBody(res);
      } else {
        Response res = await client.put(
          Uri.parse("$baseUrl/$user" "profile"),
          headers: authHeader,
          body: jsonEncode(fields ?? {}),
        );
        print("Update User Profile JSON +++++++++++++ $fields");
        print("------ STATUS CODE ---- ${res.statusCode}");
        print(res.body);
        return parseBody(res);
      }
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future deleteUserAccount() async {
    try {
      Response res = await client.delete(
        Uri.parse("$baseUrl/$user" "account"),
        headers: authHeader,
      );
      print("Delete User Account +++++++++++++");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      if (res.statusCode == 401 || res.body == 'Session Expired') {
        multiLoginDetector();
      }
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  // ==========================================
  // 2. STATES, CITIES & SECTORS
  // ==========================================
  static Future getStates({Map<String, dynamic>? map}) async {
    try {
      final search = map?['search'] ?? '';
      final uri = Uri.parse("$baseUrl/$statesUrl").replace(
        queryParameters: {
          if (search.toString().isNotEmpty) 'search': search.toString(),
        },
      );
      Response res = await client.get(uri, headers: header);
      print("Get States +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      log("------ Res states ---- ${res.body}");

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future getCitiesByState({required String state, Map<String, dynamic>? map}) async {
    try {
      final search = map?['search'] ?? '';
      final stateSlug = state.trim().toLowerCase().replaceAll(' ', '-');
      final uri = Uri.parse("$baseUrl/$statesUrl/$stateSlug/cities").replace(
        queryParameters: {
          if (search.toString().isNotEmpty) 'search': search.toString(),
        },
      );
      Response res = await client.get(uri, headers: header);
      print("Get Cities By State ($state) +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print("------ Res state cities ---- ${res.body}");

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future getCities({Map<String, dynamic>? map}) async {
    try {
      final state = map?['state'] ?? 'Gujarat';
      final search = map?['search'] ?? '';
      final uri = Uri.parse("$baseUrl/$citiesUrl").replace(
        queryParameters: {
          'state': state,
          if (search.toString().isNotEmpty) 'search': search.toString(),
        },
      );
      Response res = await client.get(uri, headers: header);
      print("Get Cities +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print("------ Res city---- ${res.body}");

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future getCitySectors({required String city, Map<String, dynamic>? map}) async {
    try {
      final search = map?['search'] ?? '';
      final uri = Uri.parse("$baseUrl/$citiesUrl/${city.toLowerCase()}/sectors").replace(
        queryParameters: {
          if (search.toString().isNotEmpty) 'search': search.toString(),
        },
      );
      Response res = await client.get(uri, headers: header);
      print("Get City Sectors ($city) +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  // ==========================================
  // 3. CATEGORIES
  // ==========================================
  static Future getCategories({Map<String, dynamic>? map}) async {
    try {
      final city = map?['city'] ?? '';
      final uri = Uri.parse("$baseUrl/$categoriesUrl").replace(
        queryParameters: {
          if (city.toString().isNotEmpty) 'city': city.toString(),
        },
      );
      Response res = await client.get(uri, headers: header);
      print("Get Categories +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  // ==========================================
  // 4. BUSINESSES LISTING & SEARCH
  // ==========================================
  static Future  getBusinesses({Map<String, dynamic>? map}) async {
    try {
      final queryParams = <String, String>{};
      if (map != null) {
        map.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            queryParams[key] = value.toString();
          }
        });
      }
      final uri = Uri.parse("$baseUrl/$businessesUrl").replace(queryParameters: queryParams);
      Response res = await client.get(uri, headers: authHeader);
      print("Get Businesses +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  // ==========================================
  // 5. PEOPLE LISTING & SEARCH
  // ==========================================
  static Future getPeople({Map<String, dynamic>? map}) async {
    try {
      _ensureAuthToken();
      final queryParams = <String, String>{};
      if (map != null) {
        map.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            queryParams[key] = value.toString();
          }
        });
      }
      final uri = Uri.parse("$baseUrl/$peopleUrl").replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      Response res = await client.get(uri, headers: authHeader);
      print("Get People +++++++++++++ $map");
      print("authHeader +++ $authHeader");
      print("------ STATUS CODE ---- ${res.statusCode}");
      log("------ Res people ----${res.body}");

      var response = parseBody(res);
      if (res.statusCode == 401 || res.body == 'Session Expired') {
        multiLoginDetector();
      }
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future getPersonDetails({required String id}) async {
    try {
      _ensureAuthToken();
      final uri = Uri.parse("$baseUrl/$peopleUrl/$id");
      Response res = await client.get(uri, headers: authHeader);
      print("Get Person Details ($id) +++++++++++++");
      print("------ STATUS CODE ---- ${res.statusCode}");
      log("------ Res Person Details ($id) ---- ${res.body}");

      var response = parseBody(res);
      if (res.statusCode == 401 || res.body == 'Session Expired') {
        multiLoginDetector();
      }
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future getTopRatedBusinesses({Map<String, dynamic>? map}) async {
    try {
      final city = map?['city'] ?? '';
      final limit = map?['limit']?.toString() ?? '10';
      final uri = Uri.parse("$baseUrl/$businessesUrl/top-rated").replace(
        queryParameters: {
          if (city.isNotEmpty) 'city': city,
          'limit': limit,
        },
      );
      Response res = await client.get(uri, headers: header);
      print("Get Top-Rated Businesses +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future getBusinessDetails({required String id}) async {
    try {
      final headers = authToken.isNotEmpty ? authHeader : header;
      Response res = await client.get(
        Uri.parse("$baseUrl/$businessesUrl/$id"),
        headers: headers,
      );
      print("Get Business Details ($id) +++++++++++++");
      print("------ STATUS CODE ---- ${res.statusCode}");
      log("------ Res Business Details ($id) ---- ${res.body}");

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future createBusiness({
    required Map<String, dynamic> fields,
    String? imagePath,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/$businessesUrl");
      var request = http.MultipartRequest('POST', uri);

      if (authToken.isEmpty) {
        try {
          final storage = GetStorage();
          final storedToken = storage.read<String>('accessToken');
          if (storedToken != null && storedToken.isNotEmpty) {
            authToken = storedToken;
          }
        } catch (_) {}
      }

      if (authToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }
      if (accessId.isNotEmpty) {
        request.headers['access_id'] = accessId;
      }

      fields.forEach((k, v) {
        if (v != null) {
          request.fields[k] = v.toString();
        }
      });

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      print("Create Business Multipart +++++++++++++ $fields, image: $imagePath");
      var streamedResponse = await request.send();
      var res = await http.Response.fromStream(streamedResponse);
      print("------ STATUS CODE ---- ${res.statusCode}");
      log("------ Business ---- ${res.body}");
      print(res.body);

      if (res.statusCode == 401) {
        multiLoginDetector();
      }

      return parseBody(res);
    } catch (e) {
      print("Create Business Error: $e");
      return {"status": 400, "message": e.toString(), "success": false};
    }
  }

  // ==========================================
  // 5. FAVORITES (BOOKMARKS)
  // ==========================================
  static Future getUserFavorites({Map<String, dynamic>? map}) async {
    try {
      _ensureAuthToken();
      final page = map?['page']?.toString() ?? '1';
      final limit = map?['limit']?.toString() ?? '20';
      final uri = Uri.parse("$baseUrl/$user" "favorites").replace(
        queryParameters: {'page': page, 'limit': limit},
      );
      Response res = await client.get(uri, headers: authHeader);
      print("Get User Favorites ($uri) +++++++++++++");
      log("Get User Favorite -=-=-=-=- ${res.body}");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      if (res.statusCode == 401 || res.body == 'Session Expired') {
        multiLoginDetector();
      }
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future addFavorite({
    String? personId,
    String? businessId,
    Map<String, dynamic>? map,
  }) async {
    try {
      _ensureAuthToken();
      final targetId = personId ??
          businessId ??
          map?['personId']?.toString() ??
          map?['businessId']?.toString() ??
          '';
      final payload = map ?? {'personId': targetId};
      Response res = await client.post(
        Uri.parse("$baseUrl/$user" "favorites"),
        headers: authHeader,
        body: jsonEncode(payload),
      );
      print("Add Favorite ($targetId) +++++++++++++");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      if (res.statusCode == 401 || res.body == 'Session Expired') {
        multiLoginDetector();
      }
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future removeFavorite({
    String? personId,
    String? businessId,
    Map<String, dynamic>? map,
  }) async {
    try {
      _ensureAuthToken();
      final targetId = personId ??
          businessId ??
          map?['personId']?.toString() ??
          map?['businessId']?.toString() ??
          '';
      final payload = map ?? {'personId': targetId};
      Response res = await client.delete(
        Uri.parse("$baseUrl/$user" "favorites"),
        headers: authHeader,
        body: jsonEncode(payload),
      );
      print("Remove Favorite ($targetId) +++++++++++++");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      if (res.statusCode == 401 || res.body == 'Session Expired') {
        multiLoginDetector();
      }
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  // ==========================================
  // 6. VENDOR BUSINESS MANAGEMENT
  // ==========================================
  static Future getVendorListings({Map<String, dynamic>? map}) async {
    try {
      Response res = await client.get(
        Uri.parse("$baseUrl/$vendorUrl" "listings"),
        headers: authHeader,
      );
      print("Get Vendor Listings +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future createVendorListing({Map<String, dynamic>? map, String? imagePath}) async {
    try {
      if (imagePath != null && imagePath.isNotEmpty) {
        var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/$vendorUrl" "listings"));
        request.headers.addAll(authHeader);
        if (map != null) {
          map.forEach((k, v) => request.fields[k] = v.toString());
        }
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
        print("Create Vendor Listing Multipart +++++++++++++ $map, image: $imagePath");
        var streamedResponse = await request.send();
        var res = await http.Response.fromStream(streamedResponse);
        print("------ STATUS CODE ---- ${res.statusCode}");
        print(res.body);
        return parseBody(res);
      } else {
        Response res = await client.post(
          Uri.parse("$baseUrl/$vendorUrl" "listings"),
          headers: authHeader,
          body: jsonEncode(map ?? {}),
        );
        print("Create Vendor Listing JSON +++++++++++++ $map");
        print("------ STATUS CODE ---- ${res.statusCode}");
        print(res.body);
        return parseBody(res);
      }
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future updateVendorListing({
    required String id,
    Map<String, dynamic>? map,
    String? imagePath,
  }) async {
    try {
      if (imagePath != null && imagePath.isNotEmpty) {
        var request = http.MultipartRequest(
          'PUT',
          Uri.parse("$baseUrl/$vendorUrl" "listings/$id"),
        );
        request.headers.addAll(authHeader);
        if (map != null) {
          map.forEach((k, v) {
            if (v != null && v.toString().isNotEmpty) {
              request.fields[k] = v.toString();
            }
          });
        }
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
        print("Update Vendor Listing Multipart ($id) +++++++++++++ $map, image: $imagePath");
        var streamedResponse = await request.send();
        var res = await http.Response.fromStream(streamedResponse);
        print("------ STATUS CODE ---- ${res.statusCode}");
        print(res.body);
        return parseBody(res);
      } else {
        Response res = await client.put(
          Uri.parse("$baseUrl/$vendorUrl" "listings/$id"),
          headers: authHeader,
          body: jsonEncode(map ?? {}),
        );
        print("Update Vendor Listing ($id) +++++++++++++ $map");
        print("------ STATUS CODE ---- ${res.statusCode}");
        print(res.body);

        var response = parseBody(res);
        return response;
      }
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future deleteVendorListing({required String id}) async {
    try {
      Response res = await client.delete(
        Uri.parse("$baseUrl/$vendorUrl" "listings/$id"),
        headers: authHeader,
      );
      print("Delete Vendor Listing ($id) +++++++++++++");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  // ==========================================
  // 7. NOTIFICATIONS
  // ==========================================
  static Future getNotifications({Map<String, dynamic>? map}) async {
    try {
      final page = map?['page']?.toString() ?? '1';
      final limit = map?['limit']?.toString() ?? '20';
      final uri = Uri.parse("$baseUrl/$notificationsUrl").replace(
        queryParameters: {'page': page, 'limit': limit},
      );
      Response res = await client.get(uri, headers: authHeader);
      print("Get Notifications +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future markNotificationsRead({Map<String, dynamic>? map}) async {
    try {
      Response res = await client.patch(
        Uri.parse("$baseUrl/$notificationsUrl/mark-read"),
        headers: authHeader,
        body: jsonEncode(map ?? {"notificationIds": ["all"]}),
      );
      print("Mark Notifications Read +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future registerDeviceToken({Map<String, dynamic>? map}) async {
    try {
      Response res = await client.post(
        Uri.parse("$baseUrl/$notificationsUrl/device-token"),
        headers: authHeader,
        body: jsonEncode(map),
      );
      print("Register Device Token +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  // ==========================================
  // 8. SUPPORT & FAQS
  // ==========================================
  static Future getFaqs({Map<String, dynamic>? map}) async {
    try {
      Response res = await client.get(
        Uri.parse("$baseUrl/$supportUrl" "faqs"),
        headers: header,
      );
      print("Get FAQs +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  static Future submitSupportInquiry({Map<String, dynamic>? map}) async {
    try {
      Response res = await client.post(
        Uri.parse("$baseUrl/$supportUrl" "inquiry"),
        headers: header,
        body: jsonEncode(map),
      );
      print("Submit Support Inquiry +++++++++++++ $map");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }

  // ==========================================
  // 9. LEGAL POLICIES
  // ==========================================
  static Future getLegalPolicy({required String type}) async {
    try {
      final uri = Uri.parse("$baseUrl/$legalUrl" "terms-and-privacy").replace(
        queryParameters: {'type': type},
      );
      Response res = await client.get(uri, headers: header);
      print("Get Legal Policy ($type) +++++++++++++");
      print("------ STATUS CODE ---- ${res.statusCode}");
      print(res.body);

      var response = parseBody(res);
      return response;
    } catch (e) {
      return {"status": 400, "message": e.toString()};
    }
  }
}

void errorSnackbar({required String title, required String subtitle}) {
  prefix.Get.snackbar(
    title,
    subtitle,
    snackPosition: prefix.SnackPosition.BOTTOM,
    backgroundColor: Colors.redAccent,
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
  );
}
