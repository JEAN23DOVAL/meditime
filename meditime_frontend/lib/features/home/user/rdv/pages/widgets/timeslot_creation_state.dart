class TimeslotCreationState {
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final bool isValid;
  final bool isLoading;
  final String? errorMessage;
  
  const TimeslotCreationState({
    this.startDateTime,
    this.endDateTime,
    this.isValid = false,
    this.isLoading = false,
    this.errorMessage,
  });
  
  TimeslotCreationState copyWith({
    DateTime? startDateTime,
    DateTime? endDateTime,
    bool? isValid,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TimeslotCreationState(
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      isValid: isValid ?? this.isValid,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
