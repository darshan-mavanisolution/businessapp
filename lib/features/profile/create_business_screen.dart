import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/themes/app_colors.dart';
import '../../core/services/remote_service.dart';
import '../business_listing/business_controller.dart';



class CreateBusinessScreen extends StatefulWidget {
  const CreateBusinessScreen({super.key});

  @override
  State<CreateBusinessScreen> createState() => _CreateBusinessScreenState();
}

class _CreateBusinessScreenState extends State<CreateBusinessScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _sectorController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _openingTimeController = TextEditingController();
  final _closingTimeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _specializationInputController = TextEditingController();

  // Dynamic Categories from API
  String? _selectedCategory;
  List<String> _categories = [];
  bool _isLoadingCategories = false;

  // Dynamic States & Dependent Cities from API
  String? _selectedState;
  List<String> _states = [];
  bool _isLoadingStates = false;

  String? _selectedCity;
  List<String> _cities = [];
  bool _isLoadingCities = false;

  // Dynamic Sectors from API (Dependent on City)
  String? _selectedSector;
  List<String> _sectors = [];
  bool _isLoadingSectors = false;

  final List<String> _specializations = [];
  File? _selectedImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Use preloaded categories from BusinessController if available
    if (Get.isRegistered<BusinessController>()) {
      final bController = Get.find<BusinessController>();
      final loadedCats = bController.apiCategories.map((c) => c.name).where((n) => n.isNotEmpty).toList();
      if (loadedCats.isNotEmpty) {
        _categories = List<String>.from(loadedCats);
        _selectedCategory = _categories.first;
      }
    }
    _fetchCategories();
    _fetchStates();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final res = await RemoteService.getCategories();
      if (res != null && (res['success'] == true || res['status'] == 200 || res is List)) {
        final list = (res is List ? res : (res['data'] ?? res['categories'] ?? res['result'])) as List?;
        if (list != null && list.isNotEmpty) {
          final parsed = list.map((item) {
            if (item is Map) {
              return (item['name'] ?? item['title'] ?? item['category'] ?? '').toString();
            }
            return item.toString();
          }).where((name) => name.trim().isNotEmpty).toList();

          if (parsed.isNotEmpty) {
            if (mounted) {
              setState(() {
                _categories = parsed;
                if (_selectedCategory == null || !_categories.contains(_selectedCategory)) {
                  _selectedCategory = _categories.first;
                }
              });
            }
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      if (mounted) {
        setState(() {
          if (_categories.isEmpty) {
            _categories = [
              'Doctors',
              'Advocates',
              'Hotels',
              'Restaurants',
              'Electronics',
              'Education',
              'Automobile',
              'IT & Technology',
              'Retail',
              'Finance & Banking',
              'Hospitality',
              'Health & Fitness',
              'Others',
            ];
            if (_selectedCategory == null || !_categories.contains(_selectedCategory)) {
              _selectedCategory = _categories.first;
            }
          }
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _fetchStates() async {
    setState(() => _isLoadingStates = true);
    try {
      final res = await RemoteService.getStates();
      if (res != null && (res['success'] == true || res['status'] == 200 || res is List)) {
        final list = (res is List ? res : (res['data'] ?? res['states'] ?? res['result'])) as List?;
        if (list != null && list.isNotEmpty) {
          final parsed = list.map((item) {
            if (item is Map) {
              return (item['name'] ?? item['state'] ?? '').toString();
            }
            return item.toString();
          }).where((s) => s.trim().isNotEmpty).toSet().toList();

          if (parsed.isNotEmpty && mounted) {
            setState(() {
              _states = parsed;
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching states: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStates = false;
        });
      }
    }
  }

  Future<void> _fetchCitiesForState(String state) async {
    setState(() {
      _isLoadingCities = true;
      _cities.clear();
      _selectedCity = null;
      _cityController.clear();
      _sectors.clear();
      _selectedSector = null;
      _sectorController.clear();
    });

    List<String> fetchedCities = [];
    try {
      // 1. Try getCitiesByState
      var res = await RemoteService.getCitiesByState(state: state);
      var list = (res != null && (res['success'] == true || res['status'] == 200 || res is List))
          ? (res is List ? res : (res['data'] ?? res['cities'] ?? res['result'])) as List?
          : null;

      // 2. If empty, try getCities with state filter
      if (list == null || list.isEmpty) {
        res = await RemoteService.getCities(map: {'state': state});
        list = (res != null && (res['success'] == true || res['status'] == 200 || res is List))
            ? (res is List ? res : (res['data'] ?? res['cities'] ?? res['result'])) as List?
            : null;
      }

      if (list != null && list.isNotEmpty) {
        fetchedCities = list.map((item) {
          if (item is Map) {
            return (item['name'] ?? item['city'] ?? item['cityName'] ?? item['title'] ?? '').toString();
          }
          return item.toString();
        }).where((c) => c.trim().isNotEmpty).toSet().toList();
      }
    } catch (e) {
      debugPrint('Error fetching cities for $state: $e');
    }

    if (mounted) {
      setState(() {
        _cities = fetchedCities;
        _isLoadingCities = false;
        if (_cities.isNotEmpty) {
          _selectedCity = _cities.first;
          _cityController.text = _selectedCity!;
          _fetchSectorsForCity(_selectedCity!);
        } else {
          _sectors.clear();
          _selectedSector = null;
          _sectorController.clear();
        }
      });
    }
  }

  Future<void> _fetchSectorsForCity(String city) async {
    setState(() {
      _isLoadingSectors = true;
      _sectors.clear();
      _selectedSector = null;
      _sectorController.clear();
    });

    List<String> fetchedSectors = [];
    try {
      var res = await RemoteService.getCitySectors(city: city);
      var list = (res != null && (res['success'] == true || res['status'] == 200 || res is List))
          ? (res is List ? res : (res['data'] ?? res['sectors'] ?? res['result'])) as List?
          : null;

      if (list != null && list.isNotEmpty) {
        fetchedSectors = list.map((item) {
          if (item is Map) {
            return (item['name'] ?? item['sector'] ?? item['sectorName'] ?? item['title'] ?? '').toString();
          }
          return item.toString();
        }).where((s) => s.trim().isNotEmpty).toSet().toList();
      }
    } catch (e) {
      debugPrint('Error fetching sectors for $city: $e');
    }

    if (mounted) {
      setState(() {
        _sectors = fetchedSectors;
        _isLoadingSectors = false;
        if (_sectors.isNotEmpty) {
          _selectedSector = _sectors.first;
          _sectorController.text = _selectedSector!;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _sectorController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _specializationInputController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        'Image Error',
        'Failed to select image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void _showImagePickerSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: textPrimary),
              title: Text('Choose from Gallery', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: textPrimary),
              title: Text('Take a Photo', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            if (_selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                onTap: () {
                  Get.back();
                  setState(() => _selectedImage = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _addSpecialization() {
    final text = _specializationInputController.text.trim();
    if (text.isNotEmpty && !_specializations.contains(text)) {
      setState(() {
        _specializations.add(text);
        _specializationInputController.clear();
      });
    }
  }

  void _clearAllFields() {
    _nameController.clear();
    _specialtyController.clear();
    _descriptionController.clear();
    _cityController.clear();
    _sectorController.clear();
    _addressController.clear();
    _phoneController.clear();
    _whatsappController.clear();
    _emailController.clear();
    _openingTimeController.clear();
    _closingTimeController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _specializationInputController.clear();
    if (mounted) {
      setState(() {
        _selectedImage = null;
        _specializations.clear();
        _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
        _selectedState = null;
        _selectedCity = null;
        _cities.clear();
        _selectedSector = null;
        _sectors.clear();
      });
    }
  }

  Future<void> _submitBusiness() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      Get.snackbar(
        'Invalid Phone Number',
        'Please enter a valid 10-digit phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    final whatsapp = _whatsappController.text.trim();
    if (whatsapp.isNotEmpty && whatsapp.length != 10) {
      Get.snackbar(
        'Invalid WhatsApp Number',
        'WhatsApp number must be exactly 10 digits',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    final selectedCity = _selectedCity ?? _cityController.text.trim();
    final selectedSector = _selectedSector ?? _sectorController.text.trim();
    if (_selectedState == null || _selectedState!.trim().isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please select a State',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }
    if (selectedCity.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please select a City',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    final fields = {
      'businessName': _nameController.text.trim(),
      'name': _nameController.text.trim(),
      'category': _selectedCategory ?? 'Doctors',
      'specialty': _specialtyController.text.trim(),
      'description': _descriptionController.text.trim(),
      'state': _selectedState ?? '',
      'city': selectedCity,
      'sector': selectedSector,
      'address': _addressController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'whatsappNumber': _whatsappController.text.trim().isNotEmpty
          ? _whatsappController.text.trim()
          : _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'openingTime': _openingTimeController.text.trim(),
      'closingTime': _closingTimeController.text.trim(),
      'latitude': _latitudeController.text.trim(),
      'longitude': _longitudeController.text.trim(),
      'specializations': _specializations.join(','),
    };

    final res = await RemoteService.createBusiness(
      fields: fields,
      imagePath: _selectedImage?.path,
    );

    setState(() => _isLoading = false);

    if (res != null && (res['success'] == true || res['status'] == 200 || res['status'] == 201)) {
      if (Get.isRegistered<BusinessController>()) {
        Get.find<BusinessController>().fetchBusinesses();
      }
      _clearAllFields();
      Get.back(result: true);
      Get.snackbar(
        'Success',
        res['message'] ?? 'Business created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } else {
      final errMsg = res?['message'] ?? 'Failed to create business. Please try again.';
      Get.snackbar(
        'Failed',
        errMsg.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final btnBg = isDark ? Colors.white : Colors.black;
    final btnText = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Business Create',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Image Upload Section
                _buildImagePickerBox(cardBg, border, textPrimary, textSecondary),

                const SizedBox(height: 24),

                // Section 1: Basic Information
                _buildSectionHeader('Basic Information', textPrimary),
                const SizedBox(height: 12),

                _buildInputField(
                  label: 'Business Name *',
                  controller: _nameController,
                  hint: 'e.g. Apollo Clinic',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  cardBg: cardBg,
                  border: border,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Business name is required' : null,
                ),

                const SizedBox(height: 14),

                _buildCategoryDropdown(cardBg, border, textPrimary, textSecondary),

                const SizedBox(height: 14),

                _buildInputField(
                  label: 'Specialty *',
                  controller: _specialtyController,
                  hint: 'e.g. General Physician, Orthopedic',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  cardBg: cardBg,
                  border: border,
                ),

                const SizedBox(height: 14),

                _buildInputField(
                  label: 'Description',
                  controller: _descriptionController,
                  hint: 'Describe your business or services...',
                  maxLines: 3,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  cardBg: cardBg,
                  border: border,
                ),

                const SizedBox(height: 24),

                // Section 2: Contact Details
                _buildSectionHeader('Contact Details', textPrimary),
                const SizedBox(height: 12),

                _buildInputField(
                  label: 'Phone Number *',
                  controller: _phoneController,
                  hint: 'Enter 10-digit phone number',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  maxLength: 10,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  cardBg: cardBg,
                  border: border,
                  validator: (val) {
                    final text = val?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'Phone number is required';
                    }
                    if (text.length != 10) {
                      return 'Phone number must be exactly 10 digits';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                _buildInputField(
                  label: 'WhatsApp Number',
                  controller: _whatsappController,
                  hint: 'Enter 10-digit WhatsApp number (optional)',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  maxLength: 10,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  cardBg: cardBg,
                  border: border,
                  validator: (val) {
                    final text = val?.trim() ?? '';
                    if (text.isNotEmpty && text.length != 10) {
                      return 'WhatsApp number must be exactly 10 digits';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                _buildInputField(
                  label: 'Email Address',
                  controller: _emailController,
                  hint: 'contact@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  cardBg: cardBg,
                  border: border,
                ),

                const SizedBox(height: 24),

                // Section 3: Location Details
                _buildSectionHeader('Location Details', textPrimary),
                const SizedBox(height: 12),

                _buildStateDropdown(cardBg, border, textPrimary, textSecondary),
                const SizedBox(height: 14),

                _buildCityDropdown(cardBg, border, textPrimary, textSecondary),
                const SizedBox(height: 14),

                _buildSectorDropdown(cardBg, border, textPrimary, textSecondary),

                const SizedBox(height: 14),

                _buildInputField(
                  label: 'Full Address *',
                  controller: _addressController,
                  hint: '101 Ring Road, Near Majura Gate',
                  maxLines: 2,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  cardBg: cardBg,
                  border: border,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Address is required' : null,
                ),

                // const SizedBox(height: 14),
                //
                // Row(
                //   children: [
                //     Expanded(
                //       child: _buildInputField(
                //         label: 'Latitude',
                //         controller: _latitudeController,
                //         hint: '21.1895',
                //         keyboardType: const TextInputType.numberWithOptions(decimal: true),
                //         textPrimary: textPrimary,
                //         textSecondary: textSecondary,
                //         cardBg: cardBg,
                //         border: border,
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     Expanded(
                //       child: _buildInputField(
                //         label: 'Longitude',
                //         controller: _longitudeController,
                //         hint: '72.8252',
                //         keyboardType: const TextInputType.numberWithOptions(decimal: true),
                //         textPrimary: textPrimary,
                //         textSecondary: textSecondary,
                //         cardBg: cardBg,
                //         border: border,
                //       ),
                //     ),
                //   ],
                // ),

                // const SizedBox(height: 24),
                //
                // // Section 4: Operating Hours
                // _buildSectionHeader('Operating Hours', textPrimary),
                // const SizedBox(height: 12),
                //
                // Row(
                //   children: [
                //     Expanded(
                //       child: _buildTimePickerField(
                //         label: 'Opening Time',
                //         controller: _openingTimeController,
                //         cardBg: cardBg,
                //         border: border,
                //         textPrimary: textPrimary,
                //         textSecondary: textSecondary,
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     Expanded(
                //       child: _buildTimePickerField(
                //         label: 'Closing Time',
                //         controller: _closingTimeController,
                //         cardBg: cardBg,
                //         border: border,
                //         textPrimary: textPrimary,
                //         textSecondary: textSecondary,
                //       ),
                //     ),
                //   ],
                // ),

                const SizedBox(height: 24),

                // Section 5: Specializations Tags
                _buildSectionHeader('Specializations', textPrimary),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border),
                        ),
                        // padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          controller: _specializationInputController,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Add specialization (e.g. Cardiology)',
                            hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.6), fontSize: 13.5),
                            border: InputBorder.none,
                            // contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onSubmitted: (_) => _addSpecialization(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _addSpecialization,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: btnBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.add, color: btnText, size: 22),
                      ),
                    ),
                  ],
                ),

                if (_specializations.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _specializations.map((spec) {
                      return Chip(
                        label: Text(
                          spec,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        backgroundColor: cardBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: border),
                        ),
                        deleteIcon: Icon(Icons.close_rounded, size: 16, color: textSecondary),
                        onDeleted: () {
                          setState(() => _specializations.remove(spec));
                        },
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 36),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitBusiness,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnBg,
                      foregroundColor: btnText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: btnText,
                            ),
                          )
                        : Text(
                            'Create Business',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: btnText,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textPrimary) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
    );
  }

  Widget _buildImagePickerBox(Color cardBg, Color border, Color textPrimary, Color textSecondary) {
    return InkWell(
      onTap: () => _showImagePickerSheet(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 170,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, style: BorderStyle.solid),
        ),
        clipBehavior: Clip.antiAlias,
        child: _selectedImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Change Photo',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: textSecondary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      color: textPrimary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Upload Business Photo',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to browse camera or gallery',
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCategoryDropdown(Color cardBg, Color border, Color textPrimary, Color textSecondary) {
    final hasMatch = _categories.contains(_selectedCategory);
    final effectiveValue = hasMatch
        ? _selectedCategory
        : (_categories.isNotEmpty ? _categories.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Category *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            if (_isLoadingCategories)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: effectiveValue,
              hint: Text(
                _isLoadingCategories ? 'Loading categories...' : 'Select Category',
                style: TextStyle(
                  color: textSecondary.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              isExpanded: true,
              dropdownColor: cardBg,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
              style: TextStyle(
                color: textPrimary,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedCategory = val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStateDropdown(Color cardBg, Color border, Color textPrimary, Color textSecondary) {
    final hasMatch = _states.contains(_selectedState);
    final effectiveValue = hasMatch ? _selectedState : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'State *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
            if (_isLoadingStates)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: effectiveValue,
              hint: Text(
                _isLoadingStates ? 'Loading states from API...' : 'Select State (e.g. Gujarat, Rajasthan)',
                style: TextStyle(
                  color: textSecondary.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              isExpanded: true,
              dropdownColor: cardBg,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
              style: TextStyle(
                color: textPrimary,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
              items: _states.map((st) {
                return DropdownMenuItem<String>(
                  value: st,
                  child: Text(st),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null && val != _selectedState) {
                  setState(() {
                    _selectedState = val;
                    _selectedCity = null;
                    _cityController.clear();
                    _sectors.clear();
                    _selectedSector = null;
                    _sectorController.clear();
                  });
                  _fetchCitiesForState(val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityDropdown(Color cardBg, Color border, Color textPrimary, Color textSecondary) {
    final bool isStateSelected = _selectedState != null && _selectedState!.isNotEmpty;
    final bool isEnabled = isStateSelected && !_isLoadingCities;
    final hasMatch = _cities.contains(_selectedCity);
    final effectiveValue = hasMatch ? _selectedCity : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'City *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isStateSelected ? textSecondary : textSecondary.withValues(alpha: 0.5),
              ),
            ),
            if (_isLoadingCities)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isEnabled ? cardBg : cardBg.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isEnabled ? border : border.withValues(alpha: 0.35),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: effectiveValue,
              hint: Row(
                children: [
                  if (!isStateSelected) ...[
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 15,
                      color: textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    !isStateSelected
                        ? 'Select state first to enable cities'
                        : _isLoadingCities
                            ? 'Loading $_selectedState cities...'
                            : 'Select City (e.g. ${_cities.isNotEmpty ? _cities.first : 'Surat'})',
                    style: TextStyle(
                      color: isEnabled
                          ? textSecondary.withValues(alpha: 0.6)
                          : textSecondary.withValues(alpha: 0.45),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              isExpanded: true,
              dropdownColor: cardBg,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isEnabled ? textSecondary : textSecondary.withValues(alpha: 0.3),
              ),
              style: TextStyle(
                color: textPrimary,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
              items: isEnabled
                  ? _cities.map((ct) {
                      return DropdownMenuItem<String>(
                        value: ct,
                        child: Text(ct),
                      );
                    }).toList()
                  : null,
              onChanged: isEnabled
                  ? (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCity = val;
                          _cityController.text = val;
                        });
                        _fetchSectorsForCity(val);
                      }
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectorDropdown(Color cardBg, Color border, Color textPrimary, Color textSecondary) {
    final bool isCitySelected = _selectedCity != null && _selectedCity!.isNotEmpty;
    final bool isEnabled = isCitySelected && !_isLoadingSectors && _sectors.isNotEmpty;
    final hasMatch = _sectors.contains(_selectedSector);
    final effectiveValue = hasMatch ? _selectedSector : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sector',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isCitySelected ? textSecondary : textSecondary.withValues(alpha: 0.5),
              ),
            ),
            if (_isLoadingSectors)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isEnabled ? cardBg : cardBg.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isEnabled ? border : border.withValues(alpha: 0.35),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: effectiveValue,
              hint: Row(
                children: [
                  if (!isCitySelected) ...[
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 15,
                      color: textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    !isCitySelected
                        ? 'Select city first to enable sectors'
                        : _isLoadingSectors
                            ? 'Loading $_selectedCity sectors...'
                            : (_sectors.isNotEmpty
                                ? 'Select Sector (Optional)'
                                : 'No sectors found for $_selectedCity'),
                    style: TextStyle(
                      color: isEnabled
                          ? textSecondary.withValues(alpha: 0.6)
                          : textSecondary.withValues(alpha: 0.45),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              isExpanded: true,
              dropdownColor: cardBg,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isEnabled ? textSecondary : textSecondary.withValues(alpha: 0.3),
              ),
              style: TextStyle(
                color: textPrimary,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
              items: isEnabled
                  ? _sectors.map((sec) {
                      return DropdownMenuItem<String>(
                        value: sec,
                        child: Text(sec),
                      );
                    }).toList()
                  : null,
              onChanged: isEnabled
                  ? (val) {
                      if (val != null) {
                        setState(() {
                          _selectedSector = val;
                          _sectorController.text = val;
                        });
                      }
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    required Color textPrimary,
    required Color textSecondary,
    required Color cardBg,
    required Color border,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            validator: validator,
            style: TextStyle(
              color: textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: hint,
              hintStyle: TextStyle(
                color: textSecondary.withValues(alpha: 0.6),
                fontSize: 13.5,
              ),
              errorStyle: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.symmetric(vertical: maxLines > 1 ? 14 : 14),
            ),
          ),
        ),
      ],
    );
  }
}
