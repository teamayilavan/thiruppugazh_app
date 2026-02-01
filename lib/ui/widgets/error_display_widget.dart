import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// A reusable error display widget with retry functionality.
class ErrorDisplayWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorDisplayWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.anErrorOccurred,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A FutureBuilder wrapper that provides consistent error handling.
class FutureBuilderWithError<T> extends StatelessWidget {
  final Future<T>? future;
  final Widget Function(BuildContext, T) builder;
  final Widget Function(BuildContext, Object, StackTrace)? errorBuilder;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final bool Function(T)? isEmptyCheck;

  const FutureBuilderWithError({
    super.key,
    this.future,
    required this.builder,
    this.errorBuilder,
    this.loadingWidget,
    this.emptyWidget,
    this.isEmptyCheck,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          if (errorBuilder != null) {
            return errorBuilder!(context, snapshot.error!, snapshot.stackTrace!);
          }
          return ErrorDisplayWidget(
            errorMessage: snapshot.error.toString(),
            onRetry: () {
              setStateFn();
            },
          );
        }

        if (!snapshot.hasData || (isEmptyCheck?.call(snapshot.data!) ?? false)) {
          return emptyWidget ?? const SizedBox.shrink();
        }

        return builder(context, snapshot.data as T);
      },
    );
  }

  void setStateFn() {
    // This is a placeholder - actual state management should be done by the parent
    // The parent should create a new future to trigger a retry
  }
}
