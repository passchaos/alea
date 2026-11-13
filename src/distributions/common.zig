pub const Error = error{
    EmptyRange,
    NonFinite,
    InvalidProbability,
    InvalidInput,
    InvalidCovariance,
    InvalidWeight,
    InsufficientNonZero,
    Overflow,
    InvalidParameter,
    InvalidLength,
    LibmvecUnavailable,
    LibmUnavailable,
};
