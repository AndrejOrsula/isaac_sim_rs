/// Result wrapper for `IsaacSimError`.
pub type IsaacSimResult<T> = std::result::Result<T, crate::IsaacSimError>;

/// Crate-local alias for `IsaacSimResult`.
pub(crate) type Result<T> = IsaacSimResult<T>;
