import 'package:flutter/material.dart';
import 'package:sddomain/export/domain.dart';
import 'package:ssecretdiary/core/navigation/router.dart';
import 'package:common_ui/common_ui.dart';

abstract class BaseState<W extends StatefulWidget> extends State<W>
    with RouteAware {
  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void handleError(dynamic error) {
    switch (error.runtimeType) {
      case NetworkException:
        final exception = error as NetworkException;
        showSimpleErrorDialog(
            context: context,
            title: 'Network error',
            description:
                exception.responseStatusType == ResponseStatusType.NO_NETWORK
                    ? 'No network connection'
                    : exception.message);
        break;
      case ValidationException:
        final exception = error as ValidationException;
        if (exception.validationErrors == null ||
            exception.validationErrors.isEmpty) {
          showSimpleErrorDialog(
              context: context,
              title: 'Validation error',
              description: exception.message);
        }
        break;
      default:
        showSimpleErrorDialog(context: context);
        break;
    }
  }
}
