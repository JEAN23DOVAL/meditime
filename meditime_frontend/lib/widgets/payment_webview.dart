import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meditime_frontend/core/constants/api_endpoints.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dio/dio.dart';
import 'package:meditime_frontend/configs/app_colors.dart';

class PaymentWebView extends StatefulWidget {
  final String url;
  final String transactionId;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentCancel;

  const PaymentWebView({
    super.key,
    required this.url,
    required this.transactionId,
    this.onPaymentSuccess,
    this.onPaymentCancel,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isClosed = false;
  Timer? _autoCloseTimer;

  void _goToRdvPage() {
    if (!_isClosed && mounted) {
      _isClosed = true;
      widget.onPaymentSuccess?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (nav) async {
            if (_isClosed) return NavigationDecision.prevent;
            if (nav.url.contains('success') || nav.url.contains('retour')) {
              _goToRdvPage();
              return NavigationDecision.prevent;
            }
            if (nav.url.contains('cancel')) {
              widget.onPaymentCancel?.call();
              await Future.delayed(const Duration(milliseconds: 150));
              _goToRdvPage();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    _autoCloseTimer = Timer(const Duration(seconds: 20), () async {
      if (!_isClosed) {
        await Dio().post(
          '${ApiConstants.baseUrl}/payments/simulate-success',
          data: {'transaction_id': widget.transactionId},
        );
        if (mounted) {
          _goToRdvPage();
        }
      }
    });
  }

  @override
  void dispose() {
    _isClosed = true;
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement sécurisé'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: "Annuler le paiement",
            onPressed: () async {
              try {
                widget.onPaymentCancel?.call();
                await Future.delayed(const Duration(milliseconds: 200));
                _goToRdvPage();
              } catch (_) {}
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}