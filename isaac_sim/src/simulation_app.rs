use crate::result::Result;
use ::pxr::ToCppString;
use autocxx::WithinBox;
use derive_more::{Deref, DerefMut};
use omniverse::{carb, carb_app_path, omni, pxr};
use std::pin::Pin;

#[repr(transparent)]
#[derive(Deref, DerefMut)]
pub struct SimulationApp {
    app: Pin<Box<omni::kit::IApp>>,
}

impl SimulationApp {
    /// Creates a new instance of the simulation application.
    ///
    /// # Errors
    ///
    /// This function will return an error if the underlying application interface cannot be
    /// acquired.
    pub fn new(launch_config: &omni::kit::AppDesc) -> Result<Self> {
        // Load the plugin
        let mut framework = carb::Framework::get();
        framework.as_mut().loadPlugins(
            &carb::PluginLoadingDesc::builder()
                .add_loaded_file_wildcard("omni.kit.app.plugin")
                .add_search_path(&format!("{}/kernel/plugins", carb_app_path().display()))
                .build(),
        );

        // Acquire the application interface
        let app = if let Ok(app) = omni::kit::IApp::tryAcquireExistingInterface() {
            app
        } else {
            omni::kit::IApp::tryAcquireInterface()?
        };

        // Shadow as a safe wrapper
        let mut app = SimulationApp { app };

        // Start the application
        app.as_mut().startup(launch_config);

        // Wait until the application is ready
        while app.as_mut().isRunning() {
            if app.as_mut().isAppReady() {
                break;
            }
            app.update();
        }
        Ok(app)
    }

    #[must_use]
    pub fn create_new_stage(&self) -> bool {
        let mut context = unsafe {
            Box::into_pin(Box::from_raw(omni::usd::UsdManager::createContext(
                &"".into_cpp(),
            )))
        };
        context.as_mut().newStage1()
    }

    #[must_use]
    pub fn get_stage(&self) -> Pin<Box<pxr::UsdStageWeakPtr>> {
        let context = unsafe {
            Box::into_pin(Box::from_raw(omni::usd::UsdManager::createContext(
                &"".into_cpp(),
            )))
        };
        context.getStage().within_box()
    }

    // pub fn load() -> Result<Self> {
    //     todo!()
    // }

    pub fn update(&mut self) {
        self.as_mut().update();
    }

    pub fn run(&mut self) {
        while self.is_running() {
            self.update();
        }
    }

    pub fn is_running(&mut self) -> bool {
        self.as_mut().isRunning()
    }

    /// Logs a message to the console.
    ///
    /// # Safety
    ///
    /// This function is unsafe because it takes a raw pointer to a C string.
    ///
    /// # Panics
    ///
    /// This function will panic if the given message is not a valid C string.
    pub fn log(&mut self, message: &str) {
        unsafe {
            self.as_mut()
                .printAndLog(std::ffi::CString::new(message).unwrap().into_raw());
        }
    }
}

impl Drop for SimulationApp {
    fn drop(&mut self) {
        self.as_mut().shutdown();
    }
}
