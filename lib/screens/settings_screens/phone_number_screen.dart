import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../provider/profile_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import 'profile_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCountryCode = '+1'; // Default to US for broader appeal
  List<Map<String, String>> _filteredCountryCodes = [];

  // Comprehensive list of country codes
  final List<Map<String, String>> _countryCodes = [
    {'code': '+1', 'name': 'United States', 'flag': '🇺🇸'},
    {'code': '+1', 'name': 'Canada', 'flag': '🇨🇦'},
    {'code': '+44', 'name': 'United Kingdom', 'flag': '🇬🇧'},
    {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
    {'code': '+92', 'name': 'Pakistan', 'flag': '🇵🇰'},
    {'code': '+93', 'name': 'Afghanistan', 'flag': '🇦🇫'},
    {'code': '+33', 'name': 'France', 'flag': '🇫🇷'},
    {'code': '+49', 'name': 'Germany', 'flag': '🇩🇪'},
    {'code': '+86', 'name': 'China', 'flag': '🇨🇳'},
    {'code': '+81', 'name': 'Japan', 'flag': '🇯🇵'},
    {'code': '+82', 'name': 'South Korea', 'flag': '🇰🇷'},
    {'code': '+61', 'name': 'Australia', 'flag': '🇦🇺'},
    {'code': '+7', 'name': 'Russia', 'flag': '🇷🇺'},
    {'code': '+55', 'name': 'Brazil', 'flag': '🇧🇷'},
    {'code': '+52', 'name': 'Mexico', 'flag': '🇲🇽'},
    {'code': '+34', 'name': 'Spain', 'flag': '🇪🇸'},
    {'code': '+39', 'name': 'Italy', 'flag': '🇮🇹'},
    {'code': '+90', 'name': 'Turkey', 'flag': '🇹🇷'},
    {'code': '+20', 'name': 'Egypt', 'flag': '🇪🇬'},
    {'code': '+27', 'name': 'South Africa', 'flag': '🇿🇦'},
    {'code': '+966', 'name': 'Saudi Arabia', 'flag': '🇸🇦'},
    {'code': '+971', 'name': 'UAE', 'flag': '🇦🇪'},
    {'code': '+62', 'name': 'Indonesia', 'flag': '🇮🇩'},
    {'code': '+60', 'name': 'Malaysia', 'flag': '🇲🇾'},
    {'code': '+65', 'name': 'Singapore', 'flag': '🇸🇬'},
    {'code': '+66', 'name': 'Thailand', 'flag': '🇹🇭'},
    {'code': '+84', 'name': 'Vietnam', 'flag': '🇻🇳'},
    {'code': '+63', 'name': 'Philippines', 'flag': '🇵🇭'},
    {'code': '+880', 'name': 'Bangladesh', 'flag': '🇧🇩'},
    {'code': '+94', 'name': 'Sri Lanka', 'flag': '🇱🇰'},
    {'code': '+977', 'name': 'Nepal', 'flag': '🇳🇵'},
    {'code': '+98', 'name': 'Iran', 'flag': '🇮🇷'},
    {'code': '+964', 'name': 'Iraq', 'flag': '🇮🇶'},
    {'code': '+972', 'name': 'Israel', 'flag': '🇮🇱'},
    {'code': '+31', 'name': 'Netherlands', 'flag': '🇳🇱'},
    {'code': '+32', 'name': 'Belgium', 'flag': '🇧🇪'},
    {'code': '+41', 'name': 'Switzerland', 'flag': '🇨🇭'},
    {'code': '+43', 'name': 'Austria', 'flag': '🇦🇹'},
    {'code': '+45', 'name': 'Denmark', 'flag': '🇩🇰'},
    {'code': '+46', 'name': 'Sweden', 'flag': '🇸🇪'},
    {'code': '+47', 'name': 'Norway', 'flag': '🇳🇴'},
    {'code': '+48', 'name': 'Poland', 'flag': '🇵🇱'},
    {'code': '+351', 'name': 'Portugal', 'flag': '🇵🇹'},
    {'code': '+30', 'name': 'Greece', 'flag': '🇬🇷'},
    {'code': '+234', 'name': 'Nigeria', 'flag': '🇳🇬'},
    {'code': '+254', 'name': 'Kenya', 'flag': '🇰🇪'},
    {'code': '+256', 'name': 'Uganda', 'flag': '🇺🇬'},
    {'code': '+255', 'name': 'Tanzania', 'flag': '🇹🇿'},
    {'code': '+233', 'name': 'Ghana', 'flag': '🇬🇭'},
    {'code': '+212', 'name': 'Morocco', 'flag': '🇲🇦'},
    {'code': '+213', 'name': 'Algeria', 'flag': '🇩🇿'},
    {'code': '+216', 'name': 'Tunisia', 'flag': '🇹🇳'},
    {'code': '+218', 'name': 'Libya', 'flag': '🇱🇾'},
    {'code': '+54', 'name': 'Argentina', 'flag': '🇦🇷'},
    {'code': '+56', 'name': 'Chile', 'flag': '🇨🇱'},
    {'code': '+57', 'name': 'Colombia', 'flag': '🇨🇴'},
    {'code': '+51', 'name': 'Peru', 'flag': '🇵🇪'},
    {'code': '+58', 'name': 'Venezuela', 'flag': '🇻🇪'},
    {'code': '+593', 'name': 'Ecuador', 'flag': '🇪🇨'},
    {'code': '+595', 'name': 'Paraguay', 'flag': '🇵🇾'},
    {'code': '+598', 'name': 'Uruguay', 'flag': '🇺🇾'},
    {'code': '+591', 'name': 'Bolivia', 'flag': '🇧🇴'},
  ];

  @override
  void initState() {
    super.initState();
    _filteredCountryCodes = List.from(_countryCodes);
    _detectUserCountry(); // Auto-detect user's country if possible
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Simple country detection based on common patterns
  void _detectUserCountry() {
    // You can implement more sophisticated detection here
    // For now, we'll keep US as default for broader appeal
    // You could use packages like 'geolocator' or 'geocoding' for better detection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.3),
              AppColors.primary,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Text(
                  'add_phone_number'.tr,
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'phone_number_description'.tr,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 1),

                // Phone Number Input Field with Country Code Selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Country Code Selector
                      InkWell(
                        onTap: _showCountryCodePicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getCountryFlag(_selectedCountryCode),
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedCountryCode,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: const Color(0xFF1F2937),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF6B7280),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Phone Number Input
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          cursorColor: AppColors.primary,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(15),
                          ],
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: const Color(0xFF1F2937),
                          ),
                          decoration: InputDecoration(
                            hintText: _getPhoneHint(_selectedCountryCode),
                            hintStyle: GoogleFonts.inter(
                              fontSize: 16,
                              color: const Color(0xFF9CA3AF),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _errorMessage = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.inter(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: Colors.white.withOpacity(0.7),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                        : Text(
                      'continue'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Skip Button
                TextButton(
                  onPressed: _isLoading ? null : _handleSkip,
                  child: Text(
                    'skip_for_now'.tr,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCountryCodePicker() {
    _filteredCountryCodes = List.from(_countryCodes);
    _searchController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'select_country_code'.tr,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),

                  // Search Field
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'search_country'.tr,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          _filterCountries(value);
                        });
                      },
                    ),
                  ),

                  // Country List
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredCountryCodes.length,
                      itemBuilder: (context, index) {
                        final country = _filteredCountryCodes[index];
                        final isSelected = country['code'] == _selectedCountryCode;

                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: AppColors.primary.withOpacity(0.1),
                          leading: Text(
                            country['flag']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            country['name']!,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: const Color(0xFF1F2937),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                country['code']!,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? AppColors.primary : const Color(0xFF6B7280),
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _selectedCountryCode = country['code']!;
                              _errorMessage = null; // Clear any previous errors
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _filterCountries(String query) {
    if (query.isEmpty) {
      _filteredCountryCodes = List.from(_countryCodes);
    } else {
      _filteredCountryCodes = _countryCodes.where((country) {
        final name = country['name']!.toLowerCase();
        final code = country['code']!.toLowerCase();
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) ||
            code.contains(searchQuery) ||
            code.replaceAll('+', '').contains(searchQuery);
      }).toList();
    }
  }

  String _getCountryFlag(String countryCode) {
    final country = _countryCodes.firstWhere(
          (c) => c['code'] == countryCode,
      orElse: () => {'flag': '🌍'},
    );
    return country['flag']!;
  }

  String _getPhoneHint(String countryCode) {
    switch (countryCode) {
      case '+1':
        return '(555) 000-0000';
      case '+44':
        return '7911 123456';
      case '+91':
        return '98765 43210';
      case '+92':
        return '300 1234567';
      case '+33':
        return '6 12 34 56 78';
      case '+49':
        return '171 2345678';
      case '+86':
        return '138 0013 8000';
      case '+81':
        return '90 1234 5678';
      case '+61':
        return '4 1234 5678';
      case '+55':
        return '11 91234-5678';
      case '+7':
        return '912 345-67-89';
      case '+966':
        return '50 123 4567';
      case '+971':
        return '50 123 4567';
      case '+234':
        return '802 123 4567';
      case '+62':
        return '812-3456-7890';
      default:
        return 'enter_phone_number'.tr;
    }
  }

  bool _validatePhoneNumber(String phone) {
    // Remove any spaces or special characters
    phone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Enhanced validation based on country code
    final minLength = _getMinLengthForCountry(_selectedCountryCode);
    final maxLength = _getMaxLengthForCountry(_selectedCountryCode);

    if (phone.length >= minLength && phone.length <= maxLength) {
      return true;
    }

    return false;
  }

  int _getMinLengthForCountry(String countryCode) {
    switch (countryCode) {
      case '+1': // US/Canada
        return 10;
      case '+44': // UK
        return 10;
      case '+91': // India
        return 10;
      case '+92': // Pakistan
        return 10;
      case '+86': // China
        return 11;
      case '+7': // Russia
        return 10;
      default:
        return 7; // International minimum
    }
  }

  int _getMaxLengthForCountry(String countryCode) {
    switch (countryCode) {
      case '+1': // US/Canada
        return 10;
      case '+44': // UK
        return 11;
      case '+91': // India
        return 10;
      case '+92': // Pakistan
        return 10;
      case '+86': // China
        return 11;
      case '+7': // Russia
        return 10;
      default:
        return 15; // International maximum
    }
  }

  String _formatPhoneNumber(String phone) {
    // Remove any spaces or special characters
    phone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Combine country code with phone number
    return '$_selectedCountryCode$phone';
  }

  Future<void> _handleContinue() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      setState(() {
        _errorMessage = 'please_enter_phone_number'.tr;
      });
      return;
    }

    if (!_validatePhoneNumber(phoneNumber)) {
      final minLength = _getMinLengthForCountry(_selectedCountryCode);
      final maxLength = _getMaxLengthForCountry(_selectedCountryCode);
      setState(() {
        _errorMessage = 'invalid_phone_number'.trParams({
          'minLength': minLength.toString(),
          'maxLength': maxLength.toString()
        });
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final formattedPhone = _formatPhoneNumber(phoneNumber);

      // Check if phone number already exists
      final phoneExists = await _authService.isPhoneNumberExists(formattedPhone);

      if (phoneExists) {
        setState(() {
          _errorMessage = 'phone_already_registered'.tr;
          _isLoading = false;
        });
        return;
      }

      // Save phone number to Firestore
      final success = await _authService.savePhoneNumber(formattedPhone);

      if (success) {
        // Update ProfileProvider with phone number
        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
        profileProvider.updatePhoneNumber(formattedPhone);

        _navigateToProfile();
      } else {
        setState(() {
          _errorMessage = 'failed_to_save_phone'.tr;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'error_occurred'.tr;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSkip() async {
    _navigateToProfile();
  }

  void _navigateToProfile() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
    }
  }
}