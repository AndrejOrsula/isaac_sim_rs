//! Rust bindings for Isaac Sim.
pub mod simulation_app;
pub mod utils;

pub use omniverse::*;

pub use simulation_app::SimulationApp;
pub use utils::{
    error::{self, IsaacSimError},
    path::isaac_sim_path,
    result::{self, IsaacSimResult},
};

#[ctor::ctor]
fn verify_requirements() {
    utils::requirements::verify_isaac_sim_requirements().unwrap();
}
