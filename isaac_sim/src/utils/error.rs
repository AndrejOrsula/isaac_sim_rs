use thiserror::Error;

#[derive(Error, Debug)]
pub enum IsaacSimError {
    #[error(transparent)]
    OmniverseError(#[from] omniverse::OmniverseError),

    #[error(transparent)]
    OmniverseSysError(#[from] omniverse::OmniverseSysError),

    #[error(transparent)]
    BuilderUninitializedFieldError(#[from] derive_builder::UninitializedFieldError),

    #[error(transparent)]
    IoError(#[from] std::io::Error),

    #[error("Dependency error: {0}")]
    DependencyError(String),

    #[error("Type error: {0}")]
    TypeError(String),

    #[error("Value error: {0}")]
    ValueError(String),
}

impl From<semver::Error> for IsaacSimError {
    fn from(e: semver::Error) -> Self {
        IsaacSimError::DependencyError(e.to_string())
    }
}
