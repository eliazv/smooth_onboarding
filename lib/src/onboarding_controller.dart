import 'package:flutter/foundation.dart';

/// Controls the current onboarding page and navigation actions.
class OnboardingController extends ChangeNotifier {
  /// Creates a controller for the onboarding flow.
  OnboardingController({int initialPage = 0}) : _currentPage = initialPage;

  int _currentPage;
  int _totalPages = 0;

  /// The index of the currently visible page.
  int get currentPage => _currentPage;

  /// The total number of onboarding pages.
  int get totalPages => _totalPages;

  /// Whether the current page is the first page.
  bool get isFirstPage => _currentPage <= 0;

  /// Whether the current page is the last page.
  bool get isLastPage => _totalPages > 0 && _currentPage >= _totalPages - 1;

  /// The completion ratio of the onboarding flow.
  double get progress {
    if (_totalPages <= 0) {
      return 0;
    }

    return (_currentPage + 1) / _totalPages;
  }

  /// Attaches the controller to a page count.
  void attach(int totalPages) {
    if (totalPages <= 0) {
      throw ArgumentError.value(
          totalPages, 'totalPages', 'Must be greater than zero.');
    }

    _totalPages = totalPages;
    final int clampedPage = _currentPage.clamp(0, _totalPages - 1);
    if (clampedPage != _currentPage) {
      _currentPage = clampedPage;
    }

    notifyListeners();
  }

  /// Moves to the next page if possible.
  void next() {
    if (isLastPage) {
      return;
    }

    goTo(_currentPage + 1);
  }

  /// Moves to the previous page if possible.
  void previous() {
    if (isFirstPage) {
      return;
    }

    goTo(_currentPage - 1);
  }

  /// Jumps to the last page.
  void skip() {
    if (_totalPages <= 0) {
      return;
    }

    goTo(_totalPages - 1);
  }

  /// Sets the current page to [pageIndex].
  void goTo(int pageIndex) {
    if (_totalPages <= 0) {
      return;
    }

    final int clampedPage = pageIndex.clamp(0, _totalPages - 1);
    if (clampedPage == _currentPage) {
      return;
    }

    _currentPage = clampedPage;
    notifyListeners();
  }
}
