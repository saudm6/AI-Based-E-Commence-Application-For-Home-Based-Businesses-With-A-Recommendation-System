class SignUpWithEmailAndPasswordFailure {
  final String message;
  const SignUpWithEmailAndPasswordFailure([this.message = "An Unknown error occurred."]);

  // Error message
  factory SignUpWithEmailAndPasswordFailure.code(String code){
    switch(code){
      case 'weak-password' :
        return const SignUpWithEmailAndPasswordFailure('Please enter a stronger password.');
      case 'invalid-password' :
        return const SignUpWithEmailAndPasswordFailure('Email is not valid.');
      case 'email-already-in-use' :
        return const SignUpWithEmailAndPasswordFailure('An account already exists for this email.');
      case 'operation-not-allowed' :
        return const SignUpWithEmailAndPasswordFailure('Operation is not allowed.');
      case 'user-disabled' :
        return const SignUpWithEmailAndPasswordFailure('This user has been disabled');
      default: return SignUpWithEmailAndPasswordFailure();
    }
  }
}
