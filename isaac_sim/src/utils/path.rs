use std::{env, path::PathBuf};

#[must_use]
pub fn isaac_sim_path() -> PathBuf {
    PathBuf::from(if let Ok(path) = env::var("ISAAC_SIM_PATH") {
        path
    } else {
        env!("ISAAC_SIM_PATH").to_string()
    })
}
