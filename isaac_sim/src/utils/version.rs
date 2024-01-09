use crate::result::Result;
use semver::Version;

/// Returns the version of Carbonite that this crate was compiled against.
///
/// # Errors
///
/// This function will return an error if the version string cannot be parsed.
pub fn isaac_sim_version() -> Result<Version> {
    Ok(Version::parse(parse_isaac_sim_version(include_str!(
        concat!(env!("ISAAC_SIM_PATH"), "/VERSION")
    ))?)?)
}

/// Returns the version of Carbonite available at runtime.
///
/// # Errors
///
/// This function will return an error if the version file cannot be read or if the version string
/// cannot be parsed.
pub fn isaac_sim_version_runtime() -> Result<Version> {
    Ok(Version::parse(parse_isaac_sim_version(
        std::fs::read_to_string(crate::isaac_sim_path().join("VERSION"))?.as_str(),
    )?)?)
}

fn parse_isaac_sim_version(version_file_content: &str) -> Result<&str> {
    Ok(version_file_content
        .split('-')
        .next()
        .ok_or(std::io::Error::new(
            std::io::ErrorKind::InvalidData,
            "Failed to parse version string.",
        ))?)
}
