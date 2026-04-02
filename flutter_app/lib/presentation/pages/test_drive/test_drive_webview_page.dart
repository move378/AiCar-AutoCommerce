import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:aicar/core/theme/app_colors.dart';

/// 시���찾기 — 브랜드 전시장 WebView 페이지
class TestDriveWebViewPage extends StatefulWidget {
  const TestDriveWebViewPage({
    super.key,
    required this.brandName,
    required this.url,
  });

  final String brandName;
  final String url;

  @override
  State<TestDriveWebViewPage> createState() => _TestDriveWebViewPageState();
}

class _TestDriveWebViewPageState extends State<TestDriveWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.brandName),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _controller.reload(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '페이지를 불러올 수 없습니다',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() => _hasError = false);
                      _controller.reload();
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            )
          else
            WebViewWidget(controller: _controller),
          if (_isLoading)
            const LinearProgressIndicator(
              color: AppColors.secondary,
              backgroundColor: AppColors.surface,
            ),
        ],
      ),
    );
  }
}
