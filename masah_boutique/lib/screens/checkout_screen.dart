import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../providers/cart_provider.dart';
import '../models/store.dart';
import '../data/locations.dart';
import '../utils/money_formatter.dart';
import '../main.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _discountController = TextEditingController();
  final _notesController = TextEditingController();

  String _fulfillmentType = 'delivery';
  Country? _selectedCountry;
  City? _selectedCity;
  bool _isSubmitting = false;
  int _discountAmount = 0;
  String? _appliedDiscount;

  List<Store> _stores = [];
  bool _loadingStores = false;
  Store? _selectedStore;

  @override
  void initState() {
    super.initState();
    _selectedCountry = kCountries.first;
  }

  Future<void> _loadStores() async {
    setState(() => _loadingStores = true);
    try {
      _stores = await apiService.getStores();
    } catch (_) {}
    setState(() => _loadingStores = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context);
    final lang = langProvider.languageCode;
    final isAr = langProvider.isArabic;
    final cartProvider = Provider.of<CartProvider>(context);

    final shipping = _fulfillmentType == 'pickup'
        ? 0
        : (cartProvider.subtotal >= 15000 ? 0 : 1500);
    final total = cartProvider.subtotal + shipping - _discountAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.checkout),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // --- Fulfillment Toggle ---
            _sectionTitle(l10n.fulfillment),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFulfillmentOption(
                    'delivery',
                    Icons.local_shipping_outlined,
                    l10n.delivery,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFulfillmentOption(
                    'pickup',
                    Icons.store_outlined,
                    l10n.storePickup,
                  ),
                ),
              ],
            ),

            // --- Pickup Store Selection ---
            if (_fulfillmentType == 'pickup') ...[
              const SizedBox(height: 20),
              _sectionTitle(l10n.selectStore),
              const SizedBox(height: 12),
              if (_loadingStores)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: kGoldPrimary),
                  ),
                )
              else if (_stores.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      l10n.noStoresAvailable,
                      style: TextStyle(color: kSecondaryText),
                    ),
                  ),
                )
              else
                ..._stores.map((store) => _buildStoreCard(store, lang)),

              // Pickup instructions
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kGoldPrimary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kGoldPrimary.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pickupInstructions,
                      style: TextStyle(
                        color: kGoldPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _pickupInfoRow(Icons.access_time, l10n.pickupReadyTime),
                    const SizedBox(height: 6),
                    _pickupInfoRow(Icons.confirmation_number, l10n.pickupOrderNumber),
                    const SizedBox(height: 6),
                    _pickupInfoRow(Icons.badge_outlined, l10n.pickupIdRequired),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // --- Customer Info ---
            _sectionTitle(l10n.contactInfo),
            const SizedBox(height: 12),
            _buildField(
              _nameController,
              l10n.fullName,
              Icons.person_outline,
              isRequired: true,
            ),
            _buildField(
              _emailController,
              l10n.email,
              Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                    return l10n.invalidEmail;
                  }
                }
                return null;
              },
            ),
            _buildField(
              _phoneController,
              l10n.phone,
              Icons.phone_outlined,
              isRequired: true,
              keyboardType: TextInputType.phone,
            ),

            // --- Address Fields (Delivery only) ---
            if (_fulfillmentType == 'delivery') ...[
              const SizedBox(height: 24),
              _sectionTitle(l10n.shippingAddress),
              const SizedBox(height: 12),

              // Country picker
              _buildPickerTile(
                icon: Icons.public,
                label: l10n.country,
                value: _selectedCountry?.name(lang),
                hint: l10n.selectCountry,
                onTap: () => _showCountryPicker(lang, l10n),
              ),
              const SizedBox(height: 12),

              // City picker
              _buildPickerTile(
                icon: Icons.location_city,
                label: l10n.city,
                value: _selectedCity?.name(lang),
                hint: _selectedCountry != null ? l10n.selectCity : l10n.selectCountryFirst,
                onTap: _selectedCountry != null
                    ? () => _showCityPicker(lang, l10n)
                    : null,
              ),
              const SizedBox(height: 12),

              _buildField(
                _addressController,
                l10n.address,
                Icons.location_on_outlined,
                isRequired: true,
                maxLines: 2,
              ),
            ],

            const SizedBox(height: 24),

            // --- Discount Code ---
            _sectionTitle(l10n.discountCode),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _discountController,
                    decoration: _inputDecoration(l10n.discountCode, Icons.local_offer_outlined),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _appliedDiscount != null ? null : _applyDiscount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGoldPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.apply),
                  ),
                ),
              ],
            ),
            if (_appliedDiscount != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '$_appliedDiscount',
                      style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _appliedDiscount = null;
                          _discountAmount = 0;
                          _discountController.clear();
                        });
                      },
                      child: Text(
                        l10n.remove,
                        style: TextStyle(color: Colors.red.shade300, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // --- Notes ---
            const SizedBox(height: 24),
            _buildField(
              _notesController,
              isAr ? 'ملاحظات (اختياري)' : 'Notes (optional)',
              Icons.note_alt_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // --- Order Summary ---
            _sectionTitle(isAr ? 'ملخص الطلب' : 'Order Summary'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kDivider),
              ),
              child: Column(
                children: [
                  _summaryRow(
                    l10n.subtotal,
                    MoneyFormatter.format(cartProvider.subtotal, lang),
                  ),
                  const SizedBox(height: 8),
                  _summaryRow(
                    l10n.shipping,
                    shipping == 0
                        ? l10n.freeShipping
                        : MoneyFormatter.format(shipping, lang),
                  ),
                  if (_discountAmount > 0) ...[
                    const SizedBox(height: 8),
                    _summaryRow(
                      l10n.discount,
                      '-${MoneyFormatter.format(_discountAmount, lang)}',
                      isDiscount: true,
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: kDivider),
                  ),
                  _summaryRow(
                    l10n.total,
                    MoneyFormatter.format(total, lang),
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // --- Place Order Button ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitOrder(total, shipping),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGoldPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: kGoldPrimary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(l10n.placeOrder),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: kCharcoal,
      ),
    );
  }

  Widget _buildFulfillmentOption(String type, IconData icon, String label) {
    final isSelected = _fulfillmentType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _fulfillmentType = type;
          if (type == 'pickup' && _stores.isEmpty) {
            _loadStores();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? kGoldPrimary.withOpacity(0.08) : kCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? kGoldPrimary : kDivider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? kGoldPrimary : kSecondaryText, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? kGoldPrimary : kSecondaryText,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard(Store store, String lang) {
    final isSelected = _selectedStore?.id == store.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedStore = store),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? kGoldPrimary.withOpacity(0.08) : kCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? kGoldPrimary : kDivider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kGoldPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.store,
                color: isSelected ? kGoldPrimary : kSecondaryText,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name(lang),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: kCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.address(lang),
                    style: TextStyle(color: kSecondaryText, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    store.hours(lang),
                    style: TextStyle(color: kSecondaryText, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: kGoldPrimary, size: 24),
            if (store.phone.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.phone, color: kGoldPrimary, size: 20),
                onPressed: () async {
                  final uri = Uri.parse('tel:${store.phone}');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
            if (store.mapUrl != null)
              IconButton(
                icon: const Icon(Icons.map_outlined, color: kGoldPrimary, size: 20),
                onPressed: () async {
                  final uri = Uri.parse(store.mapUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _pickupInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: kGoldPrimary, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: kSecondaryText, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _inputDecoration(label, icon),
        validator: validator ??
            (isRequired
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.required;
                    }
                    return null;
                  }
                : null),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: kSecondaryText),
      prefixIcon: Icon(icon, color: kGoldPrimary, size: 20),
      filled: true,
      fillColor: kCardBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kGoldPrimary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String label,
    required String? value,
    required String hint,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kDivider),
        ),
        child: Row(
          children: [
            Icon(icon, color: kGoldPrimary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: kSecondaryText, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    value ?? hint,
                    style: TextStyle(
                      color: value != null ? kCharcoal : kSecondaryText,
                      fontSize: 15,
                      fontWeight: value != null ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: kSecondaryText),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? kCharcoal : kSecondaryText,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? Colors.green : (isBold ? kGoldPrimary : kCharcoal),
            fontSize: isBold ? 20 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // --- Bottom Sheet Pickers ---

  void _showCountryPicker(String lang, AppLocalizations l10n) {
    final searchController = TextEditingController();
    List<Country> filtered = List.from(kCountries);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCreamBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              expand: false,
              builder: (ctx, scrollController) {
                return Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: kDivider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.selectCountry,
                        style: playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600, color: kCharcoal),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: l10n.searchCountry,
                          hintStyle: TextStyle(color: kSecondaryText),
                          prefixIcon: const Icon(Icons.search, color: kGoldPrimary),
                          filled: true,
                          fillColor: kCardBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: kDivider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: kDivider),
                          ),
                        ),
                        onChanged: (query) {
                          setSheetState(() {
                            filtered = kCountries
                                .where((c) =>
                                    c.nameEn.toLowerCase().contains(query.toLowerCase()) ||
                                    c.nameAr.contains(query))
                                .toList();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(child: Text(l10n.noResults, style: TextStyle(color: kSecondaryText)))
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) {
                                final country = filtered[i];
                                final isSelected = _selectedCountry?.code == country.code;
                                return ListTile(
                                  leading: Icon(
                                    Icons.public,
                                    color: isSelected ? kGoldPrimary : kSecondaryText,
                                  ),
                                  title: Text(
                                    country.name(lang),
                                    style: TextStyle(
                                      color: isSelected ? kGoldPrimary : kCharcoal,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle, color: kGoldPrimary, size: 20)
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedCountry = country;
                                      _selectedCity = null;
                                    });
                                    Navigator.pop(ctx);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showCityPicker(String lang, AppLocalizations l10n) {
    if (_selectedCountry == null) return;
    final allCities = _selectedCountry!.cities;
    final searchController = TextEditingController();
    List<City> filtered = List.from(allCities);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCreamBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              expand: false,
              builder: (ctx, scrollController) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: kDivider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.selectCity,
                        style: playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600, color: kCharcoal),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: l10n.searchCity,
                          hintStyle: TextStyle(color: kSecondaryText),
                          prefixIcon: const Icon(Icons.search, color: kGoldPrimary),
                          filled: true,
                          fillColor: kCardBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: kDivider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: kDivider),
                          ),
                        ),
                        onChanged: (query) {
                          setSheetState(() {
                            filtered = allCities
                                .where((c) =>
                                    c.nameEn.toLowerCase().contains(query.toLowerCase()) ||
                                    c.nameAr.contains(query))
                                .toList();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(child: Text(l10n.noResults, style: TextStyle(color: kSecondaryText)))
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) {
                                final city = filtered[i];
                                final isSelected = _selectedCity?.nameEn == city.nameEn;
                                return ListTile(
                                  leading: Icon(
                                    Icons.location_city,
                                    color: isSelected ? kGoldPrimary : kSecondaryText,
                                  ),
                                  title: Text(
                                    city.name(lang),
                                    style: TextStyle(
                                      color: isSelected ? kGoldPrimary : kCharcoal,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle, color: kGoldPrimary, size: 20)
                                      : null,
                                  onTap: () {
                                    setState(() => _selectedCity = city);
                                    Navigator.pop(ctx);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // --- Actions ---

  Future<void> _applyDiscount() async {
    final code = _discountController.text.trim();
    if (code.isEmpty) return;

    final result = await apiService.validateDiscount(code);
    if (result != null && mounted) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      int discount = 0;
      if (result['type'] == 'percentage') {
        discount = (cartProvider.subtotal * (result['value'] as num) / 100).round();
      } else {
        discount = (result['value'] as num).toInt();
      }
      setState(() {
        _discountAmount = discount;
        _appliedDiscount = code.toUpperCase();
      });
    } else if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invalidCode),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _submitOrder(int total, int shipping) async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final lang = langProvider.languageCode;

    // Validate pickup store
    if (_fulfillmentType == 'pickup' && _selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectStore),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Validate delivery address
    if (_fulfillmentType == 'delivery') {
      if (_selectedCountry == null || _selectedCity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.selectCountryFirst),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final items = cartProvider.items.map((item) => {
        'productId': item.productId,
        'quantity': item.quantity,
        'size': item.size,
        'color': item.color,
        'price': item.product?.price ?? 0,
        'name': item.product?.name(lang) ?? '',
      }).toList();

      final orderData = <String, dynamic>{
        'items': items,
        'subtotal': cartProvider.subtotal,
        'shipping': shipping,
        'discount': _discountAmount,
        'total': total,
        'fulfillmentType': _fulfillmentType,
        'customerName': _nameController.text.trim(),
        'customerEmail': _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        'customerPhone': _phoneController.text.trim(),
        'shippingAddress': _fulfillmentType == 'delivery'
            ? _addressController.text.trim()
            : '',
        'shippingCity': _fulfillmentType == 'delivery'
            ? (_selectedCity?.nameEn ?? '')
            : '',
        'shippingCountry': _fulfillmentType == 'delivery'
            ? (_selectedCountry?.code ?? '')
            : '',
        'discountCode': _appliedDiscount,
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      };

      if (_fulfillmentType == 'pickup' && _selectedStore != null) {
        orderData['pickupStoreId'] = _selectedStore!.id;
        orderData['pickupStoreName'] = _selectedStore!.name(lang);
        orderData['pickupAddress'] = _selectedStore!.address(lang);
        orderData['pickupHours'] = _selectedStore!.hours(lang);
      }

      final order = await apiService.createOrder(orderData);
      await cartProvider.clearCart();

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/order-confirmation',
          arguments: order,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.error),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
