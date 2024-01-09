use crate::{
    error::IsaacSimError,
    result::Result,
    utils::version::{isaac_sim_version, isaac_sim_version_runtime},
};
use semver::VersionReq;

/// Verifies that the current environment meets the requirements of Carbonite.
pub(crate) fn verify_isaac_sim_requirements() -> Result<()> {
    let compiletime_version = isaac_sim_version()?;
    let runtime_version = isaac_sim_version_runtime()?;

    // Check if the compile time and runtime versions are compatible
    let req = VersionReq::parse(&format!(
        ">={}.{}",
        compiletime_version.major, compiletime_version.minor
    ))
    .unwrap();
    if !req.matches(&runtime_version) {
        return Err(IsaacSimError::DependencyError(format!(
            "The compile time version of Isaac Sim is \"{compiletime_version}\" but the runtime version is \"{runtime_version}\""
        )));
    }

    Ok(())
}
