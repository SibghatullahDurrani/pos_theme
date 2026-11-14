import 'package:flutter/material.dart';
import 'package:pos_theme/pos_theme.dart';

import '../../widgets/page_scaffold.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});
  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  bool _overlay = false;

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: 'Feedback & status',
      subtitle: 'Alerts, status pills, badges, avatars, progress, skeletons, empty and error states.',
      children: [
        DemoSection(
          title: 'Alerts',
          child: Column(
            children: [
              const PosAlert(
                tone: PosToneKind.info,
                title: 'Offline mode available',
                message: 'Sales will sync automatically when the connection returns.',
              ),
              const SizedBox(height: 10),
              PosAlert(
                tone: PosToneKind.success,
                message: 'Shift closed. Drawer balanced to the cent.',
                onClose: () {},
              ),
              const SizedBox(height: 10),
              PosAlert(
                tone: PosToneKind.warning,
                title: 'Low stock',
                message: '4 products are below their reorder point.',
                action: PosButton.outline(label: 'Review', size: PosButtonSize.sm, onPressed: () {}),
              ),
              const SizedBox(height: 10),
              const PosAlert(
                tone: PosToneKind.danger,
                title: 'Payment terminal offline',
                message: 'Card payments are disabled until the reader reconnects.',
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Status pills',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DemoLabel('Order status'),
              DemoWrap(spacing: 8, children: [for (final s in PosOrderStatus.values) PosStatusPill.order(s)]),
              const SizedBox(height: 12),
              const DemoLabel('Table status'),
              DemoWrap(spacing: 8, children: [for (final s in PosTableStatus.values) PosStatusPill.table(s)]),
              const SizedBox(height: 12),
              const DemoLabel('Styles'),
              const DemoWrap(
                spacing: 8,
                children: [
                  PosStatusPill(label: 'Soft', tone: PosToneKind.info),
                  PosStatusPill(label: 'Solid', tone: PosToneKind.info, style: PosPillStyle.solid),
                  PosStatusPill(label: 'Outline', tone: PosToneKind.info, style: PosPillStyle.outline),
                  PosStatusPill(label: 'Icon', tone: PosToneKind.success, icon: Icons.verified_rounded),
                  PosStatusPill(label: 'Dense', tone: PosToneKind.warning, dense: true),
                ],
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Badges & avatars',
          child: DemoWrap(
            spacing: 20,
            children: [
              const PosCountBadge(count: 3),
              const PosCountBadge(count: 128, tone: PosToneKind.brand),
              const Badge(label: Text('5'), child: Icon(Icons.shopping_bag_outlined, size: 28)),
              const Badge(child: Icon(Icons.notifications_none, size: 28)),
              const PosAvatar(name: 'Ava Thompson'),
              const PosAvatar(name: 'Liam Chen', online: true),
              const PosAvatar(name: 'Sofia Rossi', size: 52, online: false),
              SizedBox(
                width: 120,
                height: 40,
                child: Stack(
                  children: [
                    for (var i = 0; i < 4; i++)
                      Positioned(
                        left: i * 24.0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: context.colors.surface, width: 2),
                          ),
                          child: PosAvatar(name: ['Ava T', 'Mia J', 'Noah P', 'Eli K'][i], size: 36),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const DemoSection(
          title: 'Progress',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DemoLabel('Daily target · 72%'),
              LinearProgressIndicator(value: 0.72),
              SizedBox(height: 16),
              DemoLabel('Syncing…'),
              LinearProgressIndicator(),
              SizedBox(height: 16),
              DemoWrap(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 40, height: 40, child: CircularProgressIndicator(value: 0.4)),
                ],
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Skeleton loaders',
          child: Column(
            children: [
              for (var i = 0; i < 3; i++)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      PosSkeleton(height: 44, circle: true),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [PosSkeleton(width: 180, height: 14), SizedBox(height: 8), PosSkeleton(height: 12)],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        PosGrid(
          children: [
            PosGridItem(
              medium: 4,
              expanded: 4,
              child: PosCard(
                child: PosEmptyState(
                  compact: true,
                  title: 'Cart is empty',
                  message: 'Scan a barcode or tap a product to start a sale.',
                  icon: Icons.shopping_cart_outlined,
                  action: PosButton.outline(label: 'Browse products', size: PosButtonSize.sm, onPressed: () {}),
                ),
              ),
            ),
            PosGridItem(
              medium: 4,
              expanded: 4,
              child: PosCard(
                child: PosErrorState(
                  title: 'Couldn’t load orders',
                  message: 'Check your connection and try again.',
                  onRetry: () {},
                ),
              ),
            ),
            PosGridItem(
              medium: 8,
              expanded: 4,
              child: PosCard(
                padding: EdgeInsets.zero,
                child: SizedBox(
                  height: 260,
                  child: PosLoadingOverlay(
                    loading: _overlay,
                    message: 'Processing payment…',
                    child: Center(
                      child: PosButton(
                        label: 'Show loading overlay',
                        onPressed: () {
                          setState(() => _overlay = true);
                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) setState(() => _overlay = false);
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
