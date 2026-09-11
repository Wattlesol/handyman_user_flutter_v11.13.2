import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/empty_error_state_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/package_data_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/service/package/package_detail_screen.dart';
import 'package:booking_system_flutter/screens/service/service_detail_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class PackageListScreen extends StatefulWidget {
  const PackageListScreen({Key? key}) : super(key: key);

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  late Future<List<BookingPackage>> future;

  static const Color brandBlue = Color(0xFF1F6BFF);
  static const Color brandNavy = Color(0xFF0F2933);

  @override
  void initState() {
    super.initState();
    loadPackages();
  }

  void loadPackages() {
    future = getPackageListAPI();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.package,
      child: SnapHelperWidget<List<BookingPackage>>(
        future: future,
        loadingWidget: LoaderWidget().center(),
        errorBuilder: (error) => NoDataWidget(
          title: error,
          imageWidget: const ErrorStateWidget(),
          retryText: language.reload,
          onRetry: () => setState(() => loadPackages()),
        ),
        onSuccess: (packages) {
          if (packages.isEmpty) {
            return NoDataWidget(
              title: "No service bundles available at the moment.",
              imageWidget: const EmptyStateWidget(),
              retryText: language.reload,
              onRetry: () => setState(() => loadPackages()),
            );
          }

          return AnimatedScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            onSwipeRefresh: () async {
              setState(() => loadPackages());
              return await 1.seconds.delay;
            },
            children: [
              // Header Banner
              Container(
                width: context.width(),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [brandBlue, brandNavy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 28),
                    ),
                    14.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Special Service Bundles",
                            style: boldTextStyle(size: 17, color: Colors.white),
                          ),
                          3.height,
                          Text(
                            "Save more with packaged government & digital services",
                            style: secondaryTextStyle(size: 12, color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              16.height,

              Text(
                "Available Bundles (${packages.length})",
                style: boldTextStyle(size: 16),
              ),
              12.height,

              // Packages List
              ...packages.map((pkg) => _buildPackageCard(pkg)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPackageCard(BookingPackage pkg) {
    num originalPrice = pkg.originalPrice;
    num packagePrice = pkg.price.validate();
    num savings = originalPrice > packagePrice ? (originalPrice - packagePrice) : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image or Banner
          if (pkg.attchments.validate().isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              child: CachedImageWidget(
                url: pkg.attchments!.first.url.validate(),
                height: 140,
                width: context.width(),
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title & Badges
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pkg.name.validate(),
                            style: boldTextStyle(size: 16),
                          ),
                          if (pkg.description.validate().isNotEmpty) ...[
                            4.height,
                            Text(
                              pkg.description.validate(),
                              style: secondaryTextStyle(size: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    8.width,
                    // Price tag
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        PriceWidget(
                          price: packagePrice,
                          size: 17,
                          color: brandBlue,
                        ),
                        if (savings > 0) ...[
                          2.height,
                          PriceWidget(
                            price: originalPrice,
                            size: 12,
                            color: textSecondaryColorGlobal,
                            isLineThroughEnabled: true,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                if (savings > 0) ...[
                  8.height,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Save ${savings.toStringAsFixed(0)} SAR with this bundle",
                      style: boldTextStyle(size: 11, color: Colors.green.shade700),
                    ),
                  ),
                ],

                14.height,
                const Divider(height: 1),
                12.height,

                // Included Services section
                Text(
                  "Included Services (${pkg.serviceList.validate().length})",
                  style: boldTextStyle(size: 13),
                ),
                8.height,

                ...pkg.serviceList.validate().map((service) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: brandBlue, size: 16),
                        8.width,
                        Expanded(
                          child: Text(
                            service.name.validate(),
                            style: primaryTextStyle(size: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PriceWidget(
                          price: service.price.validate(),
                          size: 12,
                          color: textSecondaryColorGlobal,
                        ),
                      ],
                    ),
                  );
                }).toList(),

                14.height,

                // Actions Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: brandBlue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () {
                          PackageDetailScreen(packageData: pkg).launch(context);
                        },
                        child: Text("View Details", style: boldTextStyle(size: 13, color: brandBlue)),
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () {
                          PackageDetailScreen(packageData: pkg).launch(context);
                        },
                        child: Text("Book Bundle", style: boldTextStyle(size: 13, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
